`ifndef SOURCE_TB
`define SOURCE_TB

`define MAGIC_MEM 0
`define PARAM_MEM 1
`define MEMORY `PARAM_MEM
//`define MEMORY `MAGIC_MEM

// Set these to 1 to enable the feature
`define USE_SHADOW_MEMORY 1
`define USE_RVFI_MONITOR 1

`include "tb_itf.sv"

module source_tb(
    tb_itf.magic_mem magic_mem_itf,
    tb_itf.mem mem_itf,
    tb_itf.sm sm_itf,
    tb_itf.tb tb_itf,
    rvfi_itf rvfi
);

initial begin
    $dumpfile("vcd_comp3.vcd");
    $dumpvars(0, dut);
    $dumpon;

    $display("Compilation Successful");
    tb_itf.path_mb.put("memory.lst");
    tb_itf.rst = 1'b1;
    repeat (5) @(posedge tb_itf.clk);
    tb_itf.rst = 1'b0;
end

/************************* Performance Counters ******************************/

// Clock Cycles
int clock_cycles;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) clock_cycles <= '0;
    else clock_cycles <= clock_cycles + 1;
end

// Instruction Counter
int instr_count;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) instr_count <= '0;
    else begin
        if (rvfi.commit) instr_count <= instr_count + 1;
    end
end

//I-Cache Hit Rate
int i_mem_request_count;
int i_hit_count;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) begin
        i_mem_request_count <= '0;
        i_hit_count <= '0;
    end
    else begin
        if ((dut.icache.control.mem_read | dut.icache.control.mem_write) &&
                (dut.icache.control.state == dut.icache.control.IDLE ||
                dut.icache.control.state == dut.icache.control.LOOKUP) &&
                ~dut.arbiter.pmem_read_c && ~dut.arbiter.pmem_write_c)
            i_mem_request_count <= i_mem_request_count + 1;

        if (dut.icache.control.hit && dut.icache.control.state == dut.dcache.control.LOOKUP &&
                ~dut.arbiter.pmem_read_c && ~dut.arbiter.pmem_write_c)
            i_hit_count <= i_hit_count + 1;
    end
end

//D-Cache Hit Rate
int d_mem_request_count;
int d_hit_count;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) begin
        d_mem_request_count <= '0;
        d_hit_count <= '0;
    end
    else begin
        if ((dut.dcache.control.mem_read | dut.dcache.control.mem_write) &&
                (dut.dcache.control.state == dut.dcache.control.IDLE ||
                dut.dcache.control.state == dut.dcache.control.LOOKUP) &&
                ~dut.arbiter.pmem_read_c && ~dut.arbiter.pmem_write_c)
            d_mem_request_count <= d_mem_request_count + 1;

        if (dut.dcache.control.hit &&
                (dut.dcache.control.state == dut.dcache.control.LOOKUP ||
                dut.dcache.control.state == dut.dcache.control.LOOKUPWRITE) &&
                ~dut.arbiter.pmem_read_c && ~dut.arbiter.pmem_write_c)
            d_hit_count <= d_hit_count + 1;
    end
end

// Branch-Jump Prediction Accuracy
int br_instrs;
int j_instrs;
int br_misses;
int j_misses;
int br_j_instrs;
int br_j_misses;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) begin
        br_instrs <= '0;
        j_instrs <= '0;
        br_misses <= '0;
        j_misses <= '0;
    end
    else begin
        if ((dut.cpu.datapath.IFID_if.opcode == rv32i_types::op_br) && dut.cpu.datapath.IDEX_if.en) begin
            br_instrs <= br_instrs + 1;
        end
        if ((dut.cpu.datapath.IFID_if.opcode == rv32i_types::op_jal ||
             dut.cpu.datapath.IFID_if.opcode == rv32i_types::op_jalr) && dut.cpu.datapath.IDEX_if.en) begin
            j_instrs <= j_instrs + 1;
        end

        if (dut.cpu.datapath.predictionFailed && dut.cpu.datapath.IFID_if.en &&
            dut.cpu.datapath.IDEX_if.control_word.opcode == rv32i_types::op_br) begin
            br_misses <= br_misses + 1;
        end
        if (dut.cpu.datapath.predictionFailed && dut.cpu.datapath.IFID_if.en &&
            (dut.cpu.datapath.IFID_if.opcode == rv32i_types::op_jal ||
             dut.cpu.datapath.IFID_if.opcode == rv32i_types::op_jalr)) begin
            j_misses <= j_misses + 1;
        end
    end
end
assign br_j_instrs = br_instrs + j_instrs;
assign br_j_misses = br_misses + j_misses;

// Stall & Bubble Counter
int stall_count;
int bubble_count;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) begin
        stall_count  <= '0;
        bubble_count <= '0;
    end
    else begin
        // Stalls
        if (~dut.cpu.datapath.IFID_if.en && ~dut.cpu.datapath.IDEX_if.en) begin
            stall_count <= stall_count + 1;
        end

        // Bubbles
        if (~dut.cpu.datapath.IFID_if.en && dut.cpu.datapath.IDEX_if.en) begin
            bubble_count <= bubble_count + 1;
        end
    end    
end

/*****************************************************************************/

/**************************** Halting Conditions *****************************/
int timeout = 100_000_000;

always @(posedge tb_itf.clk) begin
    if (rvfi.halt) begin
        $display("Number of Cycles: %d", clock_cycles);
        $display("Number of Instructions: %d", instr_count);
        $display("Cycles Per Instruction (CPI): %.2f", clock_cycles*1.0 / instr_count);
        $display("Number of Stalls: %d --> ", stall_count, "Percentage of Total: %.1f%%",
            ((stall_count*1.0) / clock_cycles) * 100);
        $display("Number of Bubbles: %d --> ", bubble_count, "Percentage of Total: %.1f%%",
            ((bubble_count*1.0) / clock_cycles) * 100);
        $display("Number of BR Instructions: %d --> ", br_instrs, "BR Prediction Accuracy: %.1f%%", 
            ((br_instrs - br_misses)*1.0 / br_instrs) * 100);
        $display("Number of J Instructions: %d --> ", j_instrs, "J Prediction Accuracy: %.1f%%", 
            ((j_instrs - j_misses)*1.0 / j_instrs) * 100);
        $display("Total Branch Prediction Accuracy: %.1f%%",
            ((br_j_instrs - br_j_misses)*1.0 / br_j_instrs) * 100);
        $display("Number of I-Requests: %d --> ", i_mem_request_count, "I-Cache Hit Rate: %.1f%%",
            (i_hit_count*1.0 / i_mem_request_count) * 100);
        $display("Number of D-Requests: %d --> ", d_mem_request_count, "D-Cache Hit Rate: %.1f%%",
            (d_hit_count*1.0 / d_mem_request_count) * 100);
        
        $finish;
    end
    if (timeout == 0) begin
        $display("TOP: Timed out");
        $finish;
    end
    timeout <= timeout - 1;
end

always @(rvfi.errcode iff (rvfi.errcode != 0)) begin
    repeat(5) @(posedge itf.clk);
    $display("TOP: Errcode: %0d", rvfi.errcode);
    $finish;
end

/************************** End Halting Conditions ***************************/
`define PARAM_RESPONSE_NS 50 * 10
`define PARAM_RESPONSE_CYCLES $ceil(`PARAM_RESPONSE_NS / `PERIOD_NS)
`define PAGE_RESPONSE_CYCLES $ceil(`PARAM_RESPONSE_CYCLES / 2.0)

generate
    if (`MEMORY == `MAGIC_MEM) begin : memory
        magic_memory_dp mem(magic_mem_itf);
    end
    else if (`MEMORY == `PARAM_MEM) begin : memory
        ParamMemory #(`PARAM_RESPONSE_CYCLES, `PAGE_RESPONSE_CYCLES, 4, 256, 512) mem(mem_itf);
    end
endgenerate

generate
    if (`USE_SHADOW_MEMORY) begin
        shadow_memory sm(sm_itf);
    end

    if (`USE_RVFI_MONITOR) begin
        /* Instantiate RVFI Monitor */
        riscv_formal_monitor_rv32imc monitor(
            .clock(rvfi.clk),
            .reset(rvfi.rst),
            .rvfi_valid(rvfi.commit),
            .rvfi_order(rvfi.order),
            .rvfi_insn(rvfi.inst),
            .rvfi_trap(rvfi.trap),
            .rvfi_halt(rvfi.halt),
            .rvfi_intr(1'b0),
            .rvfi_mode(2'b00),
            .rvfi_rs1_addr(rvfi.rs1_addr),
            .rvfi_rs2_addr(rvfi.rs2_addr),
            .rvfi_rs1_rdata(rvfi.rs1_addr ? rvfi.rs1_rdata : 0),
            .rvfi_rs2_rdata(rvfi.rs2_addr ? rvfi.rs2_rdata : 0),
            .rvfi_rd_addr(rvfi.load_regfile ? rvfi.rd_addr : 0),
            .rvfi_rd_wdata(rvfi.load_regfile ? rvfi.rd_wdata : 0),
            .rvfi_pc_rdata(rvfi.pc_rdata),
            .rvfi_pc_wdata(rvfi.pc_wdata),
            .rvfi_mem_addr({rvfi.mem_addr[31:2], 2'b0}),
            .rvfi_mem_rmask(rvfi.mem_rmask),
            .rvfi_mem_wmask(rvfi.mem_wmask),
            .rvfi_mem_rdata(rvfi.mem_rdata),
            .rvfi_mem_wdata(rvfi.mem_wdata),
            .rvfi_mem_extamo(1'b0),
            .errcode(rvfi.errcode)
        );
    end
endgenerate

endmodule

`endif
