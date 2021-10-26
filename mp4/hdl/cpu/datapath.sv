`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)
// `include "pipeline_registers_if.sv"
import rv32i_types::*;


module datapath
(
    input clk,
    input rst,
    // input load_mdr,
    output logic dmem_read,
    output logic dmem_write,
    input rv32i_word dmem_rdata,
    output rv32i_word dmem_wdata, // signal used by RVFI Monitor
	output rv32i_word dmem_address,
    output logic [3:0] dmem_byte_enable,

    input rv32i_word imem_rdata,
    output rv32i_word imem_address
    /* You will need to connect more signals to your datapath module*/
    // input load_ir,
    // input load_regfile,
    // input alu_ops aluop,
    // input load_pc,
    // input load_mar,
	// input logic load_data_out,
    // input pcmux::pcmux_sel_t pcmux_sel,
    // input alumux::alumux1_sel_t alumux1_sel,
    // input alumux::alumux2_sel_t alumux2_sel,
    // input regfilemux::regfilemux_sel_t regfilemux_sel,
    // input marmux::marmux_sel_t marmux_sel,
    // input cmpmux::cmpmux_sel_t cmpmux_sel,
    // output rv32i_opcode opcode_out,
    // output logic [2:0] funct3,
    // output logic [6:0] funct7,
    // output logic br_en,
    // output logic [4:0] rs1,
    // output logic [4:0] rs2,
    // input branch_funct3_t cmpop,
    // output logic [1:0] addr_2bit
);

/******************* Signals Needed for RVFI Monitor *************************/
rv32i_word pcmux_out;
rv32i_word mdrreg_out;

rv32i_word pc_out;
rv32i_opcode opcode;
/*****************************************************************************/

//ir
//logic [2:0] funct3;
//logic [6:0] funct7;
//rv32i_word mem_addr;

//assign mem_addr = mem_address;

logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;
logic [4:0] rs1_ir, rs2_ir, rd;
//assign rs1 = rs1_ir;
//assign rs2 = rs2_ir;
//assign opcode_out = opcode;

pipeline_registers_if IFID_if();
pipeline_registers_if IDEX_if();
pipeline_registers_if EXMEM_if();
pipeline_registers_if MEMWB_if();

//regfile
rv32i_word regfilemux_out;
//pc
rv32i_word pc;
logic load_pc;
pcmux::pcmux_sel_t pcmux_sel;
//alu
logic [31:0] alumux1_out, alumux2_out;
//cmp
logic [31:0] cmpmux_out;
logic br_en;
//dmem
store_funct3_t store_funct3;
assign store_funct3 = store_funct3_t'(EXMEM_if.control_word.funct3);

//IFID_if
assign IFID_if.pc_in = pc;
assign IFID_if.pc_plus4_in = pc + 4;
assign IFID_if.imem_rdata_in = imem_rdata;
assign imem_address = pc;

//IDEX_if
assign IDEX_if.pc_in = IFID_if.pc;
assign IDEX_if.pc_plus4_in = IFID_if.pc_plus4;
assign IDEX_if.i_imm_in = IFID_if.i_imm;
assign IDEX_if.s_imm_in = IFID_if.s_imm;
assign IDEX_if.b_imm_in = IFID_if.b_imm;
assign IDEX_if.u_imm_in = IFID_if.u_imm;
assign IDEX_if.j_imm_in = IFID_if.j_imm;
assign IDEX_if.rd_in = IFID_if.rd;
assign IDEX_if.rs1_in = IFID_if.rs1;
assign IDEX_if.rs2_in = IFID_if.rs2;

//EXMEM_if
assign EXMEM_if.pc_in = IDEX_if.pc;
assign EXMEM_if.pc_plus4_in = IDEX_if.pc_plus4;
assign EXMEM_if.control_word_in = IDEX_if.control_word;
assign EXMEM_if.u_imm_in = IDEX_if.u_imm;
assign EXMEM_if.rs1_in = IDEX_if.rs1;
assign EXMEM_if.rs2_in = IDEX_if.rs2;
assign EXMEM_if.rd_in = IDEX_if.rd;
assign EXMEM_if.rs2_out_in = IDEX_if.rs2_out;

assign dmem_read = EXMEM_if.control_word.dmem_read;
assign dmem_write = EXMEM_if.control_word.dmem_write;
assign dmem_address = EXMEM_if.alu_out;
assign dmem_wdata = EXMEM_if.rs2_out;

//MEMWB_if
assign MEMWB_if.pc_in = EXMEM_if.pc;
assign MEMWB_if.pc_plus4_in = EXMEM_if.pc_plus4;
assign MEMWB_if.control_word_in = EXMEM_if.control_word;
assign MEMWB_if.u_imm_in = EXMEM_if.u_imm;
assign MEMWB_if.rs1_in = EXMEM_if.rs1;
assign MEMWB_if.rs2_in = EXMEM_if.rs2;
assign MEMWB_if.rd_in = EXMEM_if.rd;
assign MEMWB_if.br_en_in = EXMEM_if.br_en;
assign MEMWB_if.alu_out_in = EXMEM_if.alu_out;
assign MEMWB_if.dmem_rdata_in = dmem_rdata;



/***************************** Registers *************************************/
// Keep Instruction register named `IR` for RVFI Monitor
// ir IR(
//     .*,
//     .load (load_ir),
//     .in (mdrreg_out),
//     .rs1 (rs1_ir),
//     .rs2 (rs2_ir)

// );

// register MDR(
//     .clk  (clk),
//     .rst (rst),
//     .load (load_mdr),
//     .in   (mem_rdata),
//     .out  (mdrreg_out)
// );

IFID_reg IFID(.*);
IDEX_reg IDEX(.*);
EXMEM_reg EXMEM(.*);
MEMWB_reg MEMWB(.*);

pc_register PC(
    .*,
    .load (load_pc),
    .in (pcmux_out),
    .out (pc)
);



control control(
    .opcode (IFID_if.opcode),
    .funct3 (IFID_if.funct3),
    .funct7 (IFID_if.funct7),
    .ctrl (IDEX_if.control_word_in)
);


regfile regfile(
    .*,
    .load (MEMWB_if.control_word.load_regfile),
    .in (regfilemux_out),
    .src_a (IFID_if.rs1),
    .src_b (IFID_if.rs2),
    .dest (MEMWB_if.rd),
    .reg_a (IDEX_if.rs1_out_in),
    .reg_b (IDEX_if.rs2_out_in)
    

);

alu ALU(
    .aluop (IDEX_if.control_word.aluop),
    .a (alumux1_out),
    .b (alumux2_out),
    .f (EXMEM_if.alu_out_in)
);



// register MAR(
//     .clk  (clk),
//     .rst (rst),
//     .load (load_mar),
//     .in   (marmux_out),
//     .out  (mar_out)
// );

// register mem_data_out(
//     .clk  (clk),
//     .rst (rst),
//     .load (load_data_out),
//     .in   (rs2_out),
//     .out  (data_out)
// );

cmp CMP(
    .rs1_out (IDEX_if.rs1_out),
    .cmpmux_out,
    .cmpop (IDEX_if.control_word.cmpop),
    .br_en (EXMEM_if.br_en_in)
);

hazard_unit hazard(
    .br_en(EXMEM_if.br_en_in),
    .opcode(IDEX_if.control_word.opcode),
    .pc_en(load_pc),
    .pcmux_sel(pcmux_sel)
    
);




/*****************************************************************************/

/******************************* ALU and CMP *********************************/
/*****************************************************************************/

/******************************** Muxes **************************************/
always_comb begin : MUXES
    // We provide one (incomplete) example of a mux instantiated using
    // a case statement.  Using enumerated types rather than bit vectors
    // provides compile time type safety.  Defensive programming is extremely
    // useful in SystemVerilog.  In this case, we actually use
    // Offensive programming --- making simulation halt with a fatal message
    // warning when an unexpected mux select value occurs
    unique case (pcmux_sel)
        pcmux::pc_plus4: pcmux_out = IFID_if.pc_plus4_in;
        pcmux::alu_out: pcmux_out = EXMEM_if.alu_out_in;
        pcmux::alu_mod2: pcmux_out = {EXMEM_if.alu_out_in[31:1], 1'b0}; 
        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (MEMWB_if.control_word.regfilemux_sel)
        regfilemux::alu_out: regfilemux_out = MEMWB_if.alu_out;
        regfilemux::br_en: regfilemux_out = {31'b0, MEMWB_if.br_en}; 
        regfilemux::u_imm: regfilemux_out = MEMWB_if.u_imm; 
        regfilemux::lw: regfilemux_out = MEMWB_if.dmem_rdata; 
        regfilemux::pc_plus4: regfilemux_out = MEMWB_if.pc_plus4;
        regfilemux::lb: begin
            unique case (MEMWB_if.alu_out[1:0])
                2'b00: regfilemux_out = {{24{MEMWB_if.dmem_rdata[7]}},MEMWB_if.dmem_rdata[7:0]};
                2'b01: regfilemux_out = {{24{MEMWB_if.dmem_rdata[15]}},MEMWB_if.dmem_rdata[15:8]};
                2'b10: regfilemux_out = {{24{MEMWB_if.dmem_rdata[23]}},MEMWB_if.dmem_rdata[23:16]};
                2'b11: regfilemux_out = {{24{MEMWB_if.dmem_rdata[31]}},MEMWB_if.dmem_rdata[31:24]};
                default: regfilemux_out = MEMWB_if.dmem_rdata;
            endcase
            
        end
        regfilemux::lbu: begin
            unique case (MEMWB_if.alu_out[1:0])
                2'b00: regfilemux_out = {24'b0,MEMWB_if.dmem_rdata[7:0]};
                2'b01: regfilemux_out = {24'b0,MEMWB_if.dmem_rdata[15:8]};
                2'b10: regfilemux_out = {24'b0,MEMWB_if.dmem_rdata[23:16]};
                2'b11: regfilemux_out = {24'b0,MEMWB_if.dmem_rdata[31:24]};
                default: regfilemux_out = MEMWB_if.dmem_rdata;
            endcase
            
        end
        regfilemux::lh: begin
            unique case (MEMWB_if.alu_out[1:0])
                2'b00: regfilemux_out = {{16{MEMWB_if.dmem_rdata[15]}},MEMWB_if.dmem_rdata[15:0]};
                2'b01: regfilemux_out = {{16{MEMWB_if.dmem_rdata[23]}},MEMWB_if.dmem_rdata[23:8]};
                2'b10: regfilemux_out = {{16{MEMWB_if.dmem_rdata[31]}},MEMWB_if.dmem_rdata[31:16]};
                default: regfilemux_out = MEMWB_if.dmem_rdata;
            endcase
            
        end
        regfilemux::lhu: begin
            unique case (MEMWB_if.alu_out[1:0])
                2'b00: regfilemux_out = {16'b0,MEMWB_if.dmem_rdata[15:0]};
                2'b01: regfilemux_out = {16'b0,MEMWB_if.dmem_rdata[23:8]};
                2'b10: regfilemux_out = {16'b0,MEMWB_if.dmem_rdata[31:16]};
                default: regfilemux_out = MEMWB_if.dmem_rdata;
            endcase
            
        end
        

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (IDEX_if.control_word.alumux1_sel)
        alumux::rs1_out: alumux1_out = IDEX_if.rs1_out;
        alumux::pc_out: alumux1_out = IDEX_if.pc;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (IDEX_if.control_word.alumux2_sel)
        alumux::i_imm: alumux2_out = IDEX_if.i_imm;
        alumux::u_imm: alumux2_out = IDEX_if.u_imm;
        alumux::b_imm: alumux2_out = IDEX_if.b_imm;
        alumux::s_imm: alumux2_out = IDEX_if.s_imm;
        alumux::j_imm: alumux2_out = IDEX_if.j_imm;
        alumux::rs2_out: alumux2_out = IDEX_if.rs2_out;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    // unique case (marmux_sel)
    //     marmux::pc_out: marmux_out = pc_out;
    //     marmux::alu_out: marmux_out = alu_out;

    //     // etc.
    //     default: `BAD_MUX_SEL;
    // endcase

    unique case (IDEX_if.control_word.cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = IDEX_if.rs2_out;
        cmpmux::i_imm: cmpmux_out = IDEX_if.i_imm;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (store_funct3)
        sw: dmem_byte_enable = 4'b1111;
        sh: begin
            unique case (dmem_address[1:0])
                2'b00: dmem_byte_enable = 4'b0011;
                2'b01: dmem_byte_enable = 4'b0110;
                2'b10: dmem_byte_enable = 4'b1100;
                default: dmem_byte_enable = 4'b1111;
            endcase
        end
        sb: begin
            unique case (dmem_address[1:0])
                2'b00: dmem_byte_enable = 4'b0001;
                2'b01: dmem_byte_enable = 4'b0010;
                2'b10: dmem_byte_enable = 4'b0100;
                2'b11: dmem_byte_enable = 4'b1000;
                default: dmem_byte_enable = 4'b1111;
            endcase
        end
        default: dmem_byte_enable = 4'b1111;
    endcase

    

end
/*****************************************************************************/
endmodule : datapath


module cmp
(
    input logic [31:0] rs1_out,
    input logic [31:0] cmpmux_out,
    input branch_funct3_t cmpop,
    output logic br_en
);

    always_comb
    begin
        br_en = 1'b0;
        unique case (cmpop)
            beq: begin
                if (rs1_out == cmpmux_out)
                    br_en = 1;
            end
            bne: begin
                if (rs1_out != cmpmux_out)
                    br_en = 1;
            end
            blt: begin
                if ($signed(rs1_out) < $signed(cmpmux_out))
                    br_en = 1;
            end
            bge: begin
                if ($signed(rs1_out) >= $signed(cmpmux_out))
                    br_en = 1;
            end
            bltu: begin
                if (rs1_out < cmpmux_out)
                    br_en = 1;
            end
            bgeu: begin
                if (rs1_out >= cmpmux_out)
                    br_en = 1;
            end

            default:;
        endcase
    end
endmodule : cmp