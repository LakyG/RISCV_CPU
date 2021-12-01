import rv32i_types::*;
import pcmux::*;

module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

logic commit;
assign commit = dut.cpu.datapath.load_pc;

int timeout = 100_000_000;
//int timeout = 100_000;

always_comb begin
    itf.halt = 0;
    if (dut.cpu.datapath.load_pc) begin
        unique case (dut.cpu.datapath.MEMWB.MEMWB_if.control_word.opcode)
            op_br,
            op_jal: begin
                if (dut.cpu.datapath.MEMWB.MEMWB_if.pc == dut.cpu.datapath.MEMWB.MEMWB_if.alu_out) begin
                    itf.halt = 1;
                end
            end
            default: itf.halt = 0;
        endcase
    end
end

logic [31:0] instr_count;
always_ff @(posedge itf.clk, posedge itf.rst) begin
    if (itf.rst) instr_count <= '0;
    else begin
        if (commit) instr_count <= instr_count + 1;
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

// Stop simulation on timeout (stall detection), halt
always @(posedge itf.clk) begin
    if (itf.halt) begin
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

/************************ Signals necessary for monitor **********************/
// This section not required until CP2

// TODO: Any additional signals that are added to the pipeline just for the RVFI monitor should be added as 'non-syntheziable' code
// --> Use the "synth... translate_..." comment (see Lab 3 slides)
// --> Try to keep any RVFI monitor signals as decoupled from our pipeline as possible. Use a separate struct for these signals.

// TODO:  things might change here if we implement pipelined caches, branch prediction, etc.

assign rvfi.commit = commit;
assign rvfi.halt = itf.halt;
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1;
//The following signals need to be set:
//Instruction and trap:
    assign rvfi.inst = dut.cpu.datapath.MEMWB.MEMWB_if.imem_rdata;
    //assign rvfi.trap //TODO: Similar to MP2 (checking for invalid instructions i.e. when an instruction doesn't exist)

//Regfile:
    assign rvfi.rs1_addr = dut.cpu.datapath.MEMWB.MEMWB_if.rs1;
    assign rvfi.rs2_addr = dut.cpu.datapath.MEMWB.MEMWB_if.rs2;
    assign rvfi.rs1_rdata = dut.cpu.datapath.MEMWB.MEMWB_if.rs1_out;
    assign rvfi.rs2_rdata = dut.cpu.datapath.MEMWB.MEMWB_if.rs2_out;
    assign rvfi.load_regfile = dut.cpu.datapath.MEMWB.MEMWB_if.control_word.load_regfile;
    assign rvfi.rd_addr = dut.cpu.datapath.MEMWB.MEMWB_if.rd;
    
    always_comb begin
        if (dut.cpu.datapath.MEMWB.MEMWB_if.rd != 0) begin
            rvfi.rd_wdata = dut.cpu.datapath.regfilemux_out;
        end
        else begin
            rvfi.rd_wdata = '0;
        end
    end

//PC:
    assign rvfi.pc_rdata = dut.cpu.datapath.MEMWB.MEMWB_if.pc;
    //assign rvfi.pc_wdata = dut.cpu.datapath.MEMWB.MEMWB_if.next_pc;
    always_comb begin
        if (dut.cpu.datapath.EXMEM.EXMEM_if.pc != '0) begin
            rvfi.pc_wdata = dut.cpu.datapath.EXMEM.EXMEM_if.pc;
        end
        else if (dut.cpu.datapath.IDEX.IDEX_if.pc != '0) begin
            rvfi.pc_wdata = dut.cpu.datapath.IDEX.IDEX_if.pc;
        end
        else if (dut.cpu.datapath.IFID.IFID_if.pc != '0) begin
            rvfi.pc_wdata = dut.cpu.datapath.IFID.IFID_if.pc;
        end
        else begin
            rvfi.pc_wdata = dut.cpu.datapath.pc;
        end
    end

//Memory:
    always_comb begin
        if (dut.cpu.datapath.MEMWB.MEMWB_if.control_word.opcode == rv32i_types::op_store) begin
            rvfi.mem_addr = dut.cpu.datapath.MEMWB.MEMWB_if.alu_out;
        end
        else begin
            rvfi.mem_addr = '0;
        end
    end
    assign rvfi.mem_rmask = '1;
    assign rvfi.mem_wmask = dut.cpu.datapath.MEMWB.MEMWB_if.dmem_byte_enable;
    assign rvfi.mem_rdata = dut.cpu.datapath.MEMWB.MEMWB_if.dmem_rdata;
    assign rvfi.mem_wdata = dut.cpu.datapath.MEMWB.MEMWB_if.rs2_out;

//Please refer to rvfi_itf.sv for more information.

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2

//The following signals need to be set:
//icache signals:
    assign itf.inst_read = dut.imem_read;
    assign itf.inst_addr = dut.ishadow_address;
    assign itf.inst_resp = dut.imem_resp;
    assign itf.inst_rdata = dut.imem_rdata;

//dcache signals:
    assign itf.data_read = dut.dmem_read;
    assign itf.data_write = dut.dmem_write;
    assign itf.data_mbe = dut.dmem_byte_enable;
    assign itf.data_addr = dut.dshadow_address;
    assign itf.data_wdata = dut.dmem_wdata;
    assign itf.data_resp = dut.dmem_resp;
    assign itf.data_rdata = dut.dmem_rdata;

//Please refer to tb_itf.sv for more information.

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
//assign itf.registers = '{default: '0};
assign itf.registers = dut.cpu.datapath.regfile.data;

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),

    // .imem_read(itf.inst_read),
    // .imem_address(itf.inst_addr),
    // .imem_resp(itf.inst_resp),
    // .imem_rdata(itf.inst_rdata),

    // .dmem_read(itf.data_read),
    // .dmem_write(itf.data_write),
    // .dmem_byte_enable(itf.data_mbe),
    // .dmem_address(itf.data_addr),
    // .dmem_wdata(itf.data_wdata),
    // .dmem_resp(itf.data_resp),
    // .dmem_rdata(itf.data_rdata)

    .pmem_resp(itf.mem_resp),
    .pmem_rdata(itf.mem_rdata),
    .pmem_read(itf.mem_read),
    .pmem_write(itf.mem_write),
    .pmem_address(itf.mem_addr),
    .pmem_wdata(itf.mem_wdata)
);
/***************************** End Instantiation *****************************/

    // Assertions

endmodule
