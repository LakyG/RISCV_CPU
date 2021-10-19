`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module datapath
(
    input clk,
    input rst,
    input load_mdr,
    input rv32i_word mem_rdata,
    output rv32i_word mem_wdata, // signal used by RVFI Monitor
	 output rv32i_word mem_address,
    /* You will need to connect more signals to your datapath module*/
    input load_ir,
    input load_regfile,
    input alu_ops aluop,
    input load_pc,
    input load_mar,
	input logic load_data_out,
    input pcmux::pcmux_sel_t pcmux_sel,
    input alumux::alumux1_sel_t alumux1_sel,
    input alumux::alumux2_sel_t alumux2_sel,
    input regfilemux::regfilemux_sel_t regfilemux_sel,
    input marmux::marmux_sel_t marmux_sel,
    input cmpmux::cmpmux_sel_t cmpmux_sel,
    output rv32i_opcode opcode_out,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic br_en,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    input branch_funct3_t cmpop,
    output logic [1:0] addr_2bit
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
rv32i_word mem_addr;

assign mem_addr = mem_address;

logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;
logic [4:0] rs1_ir, rs2_ir, rd;
assign rs1 = rs1_ir;
assign rs2 = rs2_ir;
assign opcode_out = opcode;

//regfile
logic [31:0] regfilemux_out;
logic [31:0] rs1_out, rs2_out;

//alu
logic [31:0] alumux1_out, alumux2_out, alu_out;

//mar
logic [31:0] marmux_out, mar_out;
assign mem_address = {mar_out[31:2], 2'b0};
assign addr_2bit = mar_out[1:0];

logic [31:0] cmpmux_out;

logic [31:0] data_out;
always_comb begin
    unique case (addr_2bit)
        2'b00: mem_wdata = data_out;
        2'b01: mem_wdata = data_out << 8;
        2'b10: mem_wdata = data_out << 16;
        2'b11: mem_wdata = data_out << 24;
        default: mem_wdata = data_out;
    endcase
end


/***************************** Registers *************************************/
// Keep Instruction register named `IR` for RVFI Monitor
ir IR(
    .*,
    .load (load_ir),
    .in (mdrreg_out),
    .rs1 (rs1_ir),
    .rs2 (rs2_ir)

);

register MDR(
    .clk  (clk),
    .rst (rst),
    .load (load_mdr),
    .in   (mem_rdata),
    .out  (mdrreg_out)
);

regfile regfile(
    .*,
    .load (load_regfile),
    .in (regfilemux_out),
    .src_a (rs1_ir),
    .src_b (rs2_ir),
    .dest (rd),
    .reg_a (rs1_out),
    .reg_b (rs2_out)
 

);

alu ALU(
    .*,
    .a (alumux1_out),
    .b (alumux2_out),
    .f (alu_out)
);

pc_register PC(
    .*,
    .load (load_pc),
    .in (pcmux_out),
    .out (pc_out)
);

register MAR(
    .clk  (clk),
    .rst (rst),
    .load (load_mar),
    .in   (marmux_out),
    .out  (mar_out)
);

register mem_data_out(
    .clk  (clk),
    .rst (rst),
    .load (load_data_out),
    .in   (rs2_out),
    .out  (data_out)
);

cmp CMP(.*);




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
        pcmux::pc_plus4: pcmux_out = pc_out + 4;
        pcmux::alu_out: pcmux_out = alu_out;
        pcmux::alu_mod2: pcmux_out = {alu_out[31:1], 1'b0}; 
        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (regfilemux_sel)
        regfilemux::alu_out: regfilemux_out = alu_out;
        regfilemux::br_en: regfilemux_out = {31'b0, br_en}; 
        regfilemux::u_imm: regfilemux_out = u_imm; 
        regfilemux::lw: regfilemux_out = mdrreg_out; 
        regfilemux::pc_plus4: regfilemux_out = pc_out + 4;
        regfilemux::lb: begin
            unique case (addr_2bit)
                2'b00: regfilemux_out = {{24{mdrreg_out[7]}},mdrreg_out[7:0]};
                2'b01: regfilemux_out = {{24{mdrreg_out[15]}},mdrreg_out[15:8]};
                2'b10: regfilemux_out = {{24{mdrreg_out[23]}},mdrreg_out[23:16]};
                2'b11: regfilemux_out = {{24{mdrreg_out[31]}},mdrreg_out[31:24]};
                default: regfilemux_out = mdrreg_out;
            endcase
            
        end
        regfilemux::lbu: begin
            unique case (addr_2bit)
                2'b00: regfilemux_out = {24'b0,mdrreg_out[7:0]};
                2'b01: regfilemux_out = {24'b0,mdrreg_out[15:8]};
                2'b10: regfilemux_out = {24'b0,mdrreg_out[23:16]};
                2'b11: regfilemux_out = {24'b0,mdrreg_out[31:24]};
                default: regfilemux_out = mdrreg_out;
            endcase
            
        end
        regfilemux::lh: begin
            unique case (addr_2bit)
                2'b00: regfilemux_out = {{16{mdrreg_out[15]}},mdrreg_out[15:0]};
                2'b01: regfilemux_out = {{16{mdrreg_out[23]}},mdrreg_out[23:8]};
                2'b10: regfilemux_out = {{16{mdrreg_out[31]}},mdrreg_out[31:16]};
                default: regfilemux_out = mdrreg_out;
            endcase
            
        end
        regfilemux::lhu: begin
            unique case (addr_2bit)
                2'b00: regfilemux_out = {16'b0,mdrreg_out[15:0]};
                2'b01: regfilemux_out = {16'b0,mdrreg_out[23:8]};
                2'b10: regfilemux_out = {16'b0,mdrreg_out[31:16]};
                default: regfilemux_out = mdrreg_out;
            endcase
            
        end
        

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (alumux1_sel)
        alumux::rs1_out: alumux1_out = rs1_out;
        alumux::pc_out: alumux1_out = pc_out;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (alumux2_sel)
        alumux::i_imm: alumux2_out = i_imm;
        alumux::u_imm: alumux2_out = u_imm;
        alumux::b_imm: alumux2_out = b_imm;
        alumux::s_imm: alumux2_out = s_imm;
        alumux::j_imm: alumux2_out = j_imm;
        alumux::rs2_out: alumux2_out = rs2_out;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (marmux_sel)
        marmux::pc_out: marmux_out = pc_out;
        marmux::alu_out: marmux_out = alu_out;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    unique case (cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = rs2_out;
        cmpmux::i_imm: cmpmux_out = i_imm;

        // etc.
        default: `BAD_MUX_SEL;
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