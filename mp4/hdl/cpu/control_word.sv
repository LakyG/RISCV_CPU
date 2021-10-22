package control_word;
import rv32i_types::*;

typedef struct packed {
    alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    regfilemux::regfilemux_sel_t regfilemux_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
    alu_ops aluop;
    logic load_regfile;
    logic mem_read;
    logic mem_write;
    rv32i_opcode opcode; //TODO: add this to the control.sv logic
    logic [2:0] funct3;
    branch_funct3_t cmpop;
} rv32i_control_word;

endpackage : control_word