// This is the interface for all the pipeline stages

// `include "rv32i_types.sv"
// `include "control_word.sv"
import rv32i_types::*;
import control_word::*;

interface pipeline_registers_if();


    // Pipeline Control
    logic en;
    logic flush;

    // IF/ID
    rv32i_word pc_in;
    rv32i_word pc_plus4_in;
    rv32i_word imem_rdata_in;

    rv32i_word pc;
    rv32i_word pc_plus4;
    logic [2:0] funct3;
    logic [6:0] funct7;
    rv32i_opcode opcode;
    logic [31:0] i_imm;
    logic [31:0] s_imm;
    logic [31:0] b_imm;
    logic [31:0] u_imm;
    logic [31:0] j_imm;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    // ID/EX
    rv32i_control_word control_word_in;
    logic [31:0] i_imm_in;
    logic [31:0] s_imm_in;
    logic [31:0] b_imm_in;
    logic [31:0] u_imm_in;
    logic [31:0] j_imm_in;
    logic [4:0] rs1_in;
    logic [4:0] rs2_in;
    logic [4:0] rd_in;
    rv32i_word rs1_out_in;
    rv32i_word rs2_out_in;

    rv32i_control_word control_word;
    rv32i_word rs1_out;
    rv32i_word rs2_out;

    // EX/MEM
    logic br_en_in;
    rv32i_word alu_out_in;    

    logic br_en;
    rv32i_word alu_out;

    // MEM/WB
    rv32i_word dmem_rdata_in;

    rv32i_word dmem_rdata;

    modport IFID (
        input en,
        input flush,

        input pc_in,
        input pc_plus4_in,
        input imem_rdata_in,

        output pc,
        output pc_plus4,
        output funct3,
        output funct7,
        output opcode,
        output i_imm,
        output s_imm,
        output b_imm,
        output u_imm,
        output j_imm,
        output rs1,
        output rs2,
        output rd
    );

    modport IDEX (
        input en,
        input flush,

        input pc_in,
        input pc_plus4_in,

        input control_word_in,
        input i_imm_in,
        input s_imm_in,
        input b_imm_in,
        input u_imm_in,
        input j_imm_in,
        input rs1_in,
        input rs2_in,
        input rd_in,
        input rs1_out_in,
        input rs2_out_in,

        output pc,
        output pc_plus4,
        output i_imm,
        output s_imm,
        output b_imm,
        output u_imm,
        output j_imm,
        output rs1,
        output rs2,
        output rd,

        output control_word,
        output rs1_out,
        output rs2_out
    );

    modport EXMEM (
        input en,

        input pc_in,
        input pc_plus4_in,
        input control_word_in,
        input u_imm_in,
        input rs1_in,
        input rs2_in,
        input rd_in,
        input rs2_out_in,

        input br_en_in,
        input alu_out_in,

        output pc,
        output pc_plus4,
        output control_word,
        output u_imm,
        output rs1,
        output rs2,
        output rd,
        output rs2_out,

        output br_en,
        output alu_out
    );

    modport MEMWB (
        input en,

        input pc_in,
        input pc_plus4_in,
        input control_word_in,
        input u_imm_in,
        input rs1_in,
        input rs2_in,
        input rd_in,
        input br_en_in,
        input alu_out_in,

        input dmem_rdata_in,

        output pc,
        output pc_plus4,
        output control_word,
        output u_imm,
        output rs1,
        output rs2,
        output rd,
        output br_en,
        output alu_out,

        output dmem_rdata
    );
    
endinterface