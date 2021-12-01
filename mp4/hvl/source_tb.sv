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
    $display("Compilation Successful");
    tb_itf.path_mb.put("memory.lst");
    tb_itf.rst = 1'b1;
    repeat (5) @(posedge tb_itf.clk);
    tb_itf.rst = 1'b0;
end

/************************* Performance Counters ******************************/

logic [31:0] instr_count;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) instr_count <= '0;
    else begin
        if (rvfi.commit) instr_count <= instr_count + 1;
    end
end

logic [31:0] i_mem_request_count;
logic [31:0] i_hit_count;
logic [31:0] d_mem_request_count;
logic [31:0] d_hit_count;

//I-Cache Hit Rate
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (dut.cpu.rst) begin
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
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (dut.cpu.rst) begin
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

/*****************************************************************************/

/**************************** Halting Conditions *****************************/
int timeout = 100_000_000;

always @(posedge tb_itf.clk) begin
    if (rvfi.halt) begin
        $display("Number of Cycles: %d", dut.cpu.datapath.clock_cycles);
        $display("Number of Instructions: %d", instr_count);
        $display("Branch Prediction Accuracy: %.1f%%",
            ((dut.cpu.datapath.br_j_instrs - dut.cpu.datapath.br_j_misses)*1.0 / dut.cpu.datapath.br_j_instrs) * 100);
        $display("I-Cache Hit Rate: %.1f%%",
            (i_hit_count*1.0 / i_mem_request_count) * 100);
        $display("D-Cache Hit Rate: %.1f%%",
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
