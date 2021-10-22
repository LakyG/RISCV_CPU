package control_word;
import rv32i_types::*;

typedef struct packed {
    pcmux::pcmux_sel_t pcmux_sel;
    alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    regfilemux::regfilemux_sel_t regfilemux_sel;
    marmux::marmux_sel_t marmux_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
    alu_ops aluop;
    logic load_pc;
    logic load_ir;
    logic load_regfile;
    logic load_mar;
    logic load_mdr;
    logic load_data_out;
    logic mem_read;
    logic mem_write;
    logic [2:0] funct3;
    branch_funct3_t cmpop;
} rv32i_control_word;

endpackage : control_word