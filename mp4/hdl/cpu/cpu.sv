import rv32i_types::*;
import control_word::*;

module cpu # (
    parameter predict_s_index = 7
)
(
    input clk,
    input rst,

    // I Cache Ports
    output logic imem_read,
    output logic [31:0] imem_address,
    
    input logic imem_resp,
    input logic [31:0] imem_rdata,

    // D Cache Ports
    output logic dmem_read,
    output logic dmem_write,
    output logic [3:0] dmem_byte_enable,
    output logic [31:0] dmem_address,
    output logic [31:0] dmem_wdata,

    input logic dmem_resp,
    input logic [31:0] dmem_rdata
);

/******************* Signals Needed for RVFI Monitor *************************/
logic load_pc;
logic load_regfile;
/*****************************************************************************/

alu_ops aluop;
logic load_ir, load_mar, load_mdr, load_data_out;
logic [2:0] funct3;
logic [6:0] funct7;
logic br_en;
logic [4:0] rs1;
logic [4:0] rs2;
rv32i_opcode opcode;
branch_funct3_t cmpop;
logic [1:0] addr_2bit;
rv32i_control_word ctrl;

/**************************** Control Signals ********************************/
pcmux::pcmux_sel_t pcmux_sel;
alumux::alumux1_sel_t alumux1_sel;
alumux::alumux2_sel_t alumux2_sel;
regfilemux::regfilemux_sel_t regfilemux_sel;
marmux::marmux_sel_t marmux_sel;
cmpmux::cmpmux_sel_t cmpmux_sel;
/*****************************************************************************/

assign imem_read = 1;

/* Instantiate MP 1 top level blocks here */

//TODO: Move Control and Hazard (and Forwarding) to CPU module (not datapath)
// Keep control named `control` for RVFI Monitor
// control control(
//     .opcode(opcode),
//     .funct3(funct3),
//     .funct7(funct7),
//     .ctrl(ctrl)
// );

// Keep datapath named `datapath` for RVFI Monitor
datapath #(.predict_s_index(predict_s_index)) datapath(
    .clk(clk),
    .rst(rst),

    .dmem_read(dmem_read),
    .dmem_write(dmem_write),
    .dmem_rdata(dmem_rdata),
    .dmem_resp(dmem_resp),
    .dmem_wdata(dmem_wdata),
	.dmem_address(dmem_address),
    .dmem_byte_enable(dmem_byte_enable),
    
    .imem_rdata(imem_rdata),
    .imem_resp(imem_resp),
    .imem_address(imem_address)
);

endmodule : cpu
