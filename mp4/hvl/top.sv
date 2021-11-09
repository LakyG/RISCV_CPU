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

// Stop simulation on timeout (stall detection), halt
always @(posedge itf.clk) begin
    if (itf.halt)
        $finish;
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

assign rvfi.commit = 0; // TODO: Set high when a valid instruction is modifying regfile or PC
                                // --> This should be the WB stage??
                                // --> When will data be valid?? Need to set rvfi.valid
                                // --> We don't want flushed instructions to be valid
                                // --> 
assign rvfi.halt = 0;   // TODO: Set high when you detect an infinite loop
initial rvfi.order = 0; //TODO:
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

/*
//The following signals need to be set:
//Instruction and trap:
    rvfi.inst
    rvfi.trap // Similar to MP2 (checking for invalid instructions i.e. when an instruction doesn't exist)

//Regfile:
    rvfi.rs1_addr
    rvfi.rs2_addr
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.load_regfile
    rvfi.rd_addr
    rvfi.rd_wdata

//PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

//Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

//Please refer to rvfi_itf.sv for more information.
*/

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2

//The following signals need to be set:
//icache signals:
    assign itf.inst_read = dut.imem_read;
    assign itf.inst_addr = dut.imem_address;
    assign itf.inst_resp = dut.imem_resp;
    assign itf.inst_rdata = dut.imem_rdata;

//dcache signals:
    assign itf.data_read = dut.dmem_read;
    assign itf.data_write = dut.dmem_write;
    assign itf.data_mbe = dut.dmem_byte_enable;
    assign itf.data_addr = dut.dmem_address;
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

endmodule
