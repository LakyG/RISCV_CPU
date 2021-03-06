`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)
// `include "pipeline_registers_if.sv"
import rv32i_types::*;
import datapath_mux_types::*;

module datapath # (
    parameter predict_s_index = 7,
    parameter predict_g_history = 7
)
(
    input clk,
    input rst,
    // input load_mdr,
    output logic dmem_read,
    output logic dmem_write,
    input rv32i_word dmem_rdata,
    input logic dmem_resp,
    output rv32i_word dmem_wdata, // signal used by RVFI Monitor
	output rv32i_word dmem_address,
    output logic [3:0] dmem_byte_enable,

    input rv32i_word imem_rdata,
    input logic imem_resp,
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

pipeline_registers_if #(.s_history(predict_g_history)) IFID_if();
pipeline_registers_if #(.s_history(predict_g_history)) IDEX_if();
pipeline_registers_if #(.s_history(predict_g_history)) EXMEM_if();
pipeline_registers_if #(.s_history(predict_g_history)) MEMWB_if();

//regfile
rv32i_word regfilemux_out;
rv32i_word rm_out;
assign rm_out = regfilemux_out;
rv32i_word regfilemux_out_mem;

//pc
rv32i_word pc;
rv32i_word pc_plus4;
assign pc_plus4 = pc + 4;
logic load_pc;
rv32i_word next_pc;
rv32i_opcode IF_opcode;
assign IF_opcode = rv32i_opcode'(imem_rdata[6:0]);

//hazard
logic predict_en;

//alu
rv32i_word alumux1_out, alumux2_out;
rv32i_word alu_out, alu_EX, mdu_EX;
rv32i_word alu_out_mod2;
assign alu_out_mod2 = {alu_out[31:1], 1'b0};
rv32i_word forwardingmux1_out;
rv32i_word forwardingmux2_out;
forwardingmux_t forwardingmux1_sel;
forwardingmux_t forwardingmux2_sel;
rv32i_word forwardingmux1;
rv32i_word forwardingmux2;
assign forwardingmux1 = forwardingmux1_out;
assign forwardingmux2 = forwardingmux2_out;
logic mdu_start, mdu_done;

//cmp
rv32i_word cmpmux_out;
logic br_en;

//branch prediction
logic predictionFailed;
rv32i_word expected_next_pc;
rv32i_word predicted_pc;

predictmux_t predicted_direction;
rv32i_word predicted_target;
logic [predict_g_history-1:0] g_history;

//dmem
store_funct3_t store_funct3;
rv32i_opcode dmem_opcode;
logic [31:0] alu_address;
assign store_funct3 = EXMEM_if.en ? store_funct3_t'(IDEX_if.control_word.funct3) : store_funct3_t'(EXMEM_if.control_word.funct3);
assign dmem_opcode = EXMEM_if.en ? IDEX_if.control_word.opcode : EXMEM_if.control_word.opcode;
assign alu_address = EXMEM_if.en ? alu_out : EXMEM_if.alu_out;

//IFID_if
assign IFID_if.pc_in = pc;
assign IFID_if.pc_plus4_in = pc_plus4;
assign IFID_if.next_pc_in = next_pc;
assign IFID_if.imem_rdata_in = imem_rdata;
assign IFID_if.predicted_direction_in = predicted_direction;
assign IFID_if.g_history_in = g_history;
assign imem_address = load_pc ? next_pc : pc;
//assign imem_address = pc;

//IDEX_if
assign IDEX_if.pc_in = IFID_if.pc;
assign IDEX_if.pc_plus4_in = IFID_if.pc_plus4;
assign IDEX_if.next_pc_in = IFID_if.next_pc;
assign IDEX_if.imem_rdata_in = IFID_if.imem_rdata;
assign IDEX_if.predicted_direction_in = IFID_if.predicted_direction;
assign IDEX_if.g_history_in = IFID_if.g_history;
assign IDEX_if.i_imm_in = IFID_if.i_imm;
assign IDEX_if.s_imm_in = IFID_if.s_imm;
assign IDEX_if.b_imm_in = IFID_if.b_imm;
assign IDEX_if.u_imm_in = IFID_if.u_imm;
assign IDEX_if.j_imm_in = IFID_if.j_imm;
assign IDEX_if.rd_in = IFID_if.rd;
assign IDEX_if.rs1_in = IFID_if.rs1;
assign IDEX_if.rs2_in = IFID_if.rs2;
assign IDEX_if.funct7_in = IFID_if.funct7;

//EXMEM_if
assign EXMEM_if.pc_in = IDEX_if.pc;
assign EXMEM_if.pc_plus4_in = IDEX_if.pc_plus4;
assign EXMEM_if.next_pc_in = IDEX_if.next_pc;
assign EXMEM_if.imem_rdata_in = IDEX_if.imem_rdata;
assign EXMEM_if.control_word_in = IDEX_if.control_word;
assign EXMEM_if.u_imm_in = IDEX_if.u_imm;
assign EXMEM_if.rs1_in = IDEX_if.rs1;
assign EXMEM_if.rs2_in = IDEX_if.rs2;
assign EXMEM_if.rd_in = IDEX_if.rd;
assign EXMEM_if.br_en_in = br_en;
assign EXMEM_if.rs1_out_in = forwardingmux1;
assign EXMEM_if.rs2_out_in = forwardingmux2;
assign EXMEM_if.alu_out_in = alu_out;

// assign dmem_read = EXMEM_if.control_word.dmem_read;
// assign dmem_write = EXMEM_if.control_word.dmem_write;
// assign dmem_address = {EXMEM_if.alu_out[31:2], 2'b0};

assign dmem_read = EXMEM_if.en ? IDEX_if.control_word.dmem_read : EXMEM_if.control_word.dmem_read;
assign dmem_write = EXMEM_if.en ? IDEX_if.control_word.dmem_write : EXMEM_if.control_word.dmem_write;
assign dmem_address = EXMEM_if.en ? {alu_out[31:2], 2'b0} : {EXMEM_if.alu_out[31:2], 2'b0};
assign dmem_wdata = EXMEM_if.en ? forwardingmux2 : EXMEM_if.rs2_out;

//MEMWB_if
assign MEMWB_if.pc_in = EXMEM_if.pc;
assign MEMWB_if.pc_plus4_in = EXMEM_if.pc_plus4;
assign MEMWB_if.next_pc_in = EXMEM_if.next_pc;
assign MEMWB_if.imem_rdata_in = EXMEM_if.imem_rdata;
assign MEMWB_if.control_word_in = EXMEM_if.control_word;
assign MEMWB_if.u_imm_in = EXMEM_if.u_imm;
assign MEMWB_if.rs1_in = EXMEM_if.rs1;
assign MEMWB_if.rs2_in = EXMEM_if.rs2;
assign MEMWB_if.rd_in = EXMEM_if.rd;
assign MEMWB_if.br_en_in = EXMEM_if.br_en;
assign MEMWB_if.alu_out_in = EXMEM_if.alu_out;
assign MEMWB_if.dmem_rdata_in = dmem_rdata;
assign MEMWB_if.dmem_byte_enable_in = dmem_byte_enable;
assign MEMWB_if.rs1_out_in = EXMEM_if.rs1_out;
assign MEMWB_if.rs2_out_in = EXMEM_if.rs2_out;

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
//assign test = IDEX_if.control_word.alumux1_sel;
// if (IDEX_if.control_word.alumux1_sel == alumux::rs1_out)
//     assign test = forwardingmux1_out;
// else
//     assign test = 32'b1;
                            
pc_register PC(
    .*,
    .load (load_pc),
    .in (next_pc),
    .out (pc)
);

// Branch Prediction
local_prediction_table #(.s_index(predict_s_index), .s_history(predict_g_history)) bpt (
    .*,
    .predict_en(predict_en),
    .curr_pc(pc),
    .resolved_pc(IDEX_if.pc),
    .predictionFailed(predictionFailed),
    .g_history(g_history),
    .resolved_g_history(IDEX_if.g_history),
    .IF_opcode(IF_opcode),

    .predicted_direction(predicted_direction)
);

target_buffer #(.s_index(predict_s_index)) btb (
    .*,
    .predict_en(predict_en),
    .curr_pc(pc),
    .resolved_pc(IDEX_if.pc),
    .predictionFailed(predictionFailed),
    .expected_next_pc(expected_next_pc),
    .g_history(g_history),
    .resolved_g_history(IDEX_if.g_history),
    .EX_opcode(IDEX_if.control_word.opcode),

    .predicted_target(predicted_target)
);

global_history #(.s_history(predict_g_history)) gpt (
    .*,
    .predict_en(predict_en),
    .prev_direction(predicted_direction),
    .IF_opcode(IF_opcode),

    .g_history(g_history)
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
    .f (alu_EX)
);

mdu MDU(
    .clk,
    .rst,
    .start(mdu_start),
    .funct3 (IDEX_if.control_word.funct3),
    .a (forwardingmux1),
    .b (forwardingmux2),
    .f (mdu_EX),
    .done(mdu_done)
);

cmp CMP(
    .rs1_out (forwardingmux1_out),
    .cmpmux_out(cmpmux_out),
    .cmpop (IDEX_if.control_word.cmpop),
    .br_en (br_en)
);

hazard_unit hazard(
    .imem_resp(imem_resp),
    .dmem_resp(dmem_resp),
    .rs1_id(IFID_if.rs1),
    .rs2_id(IFID_if.rs2),
    .predictionFailed(predictionFailed),
    .opcode(IDEX_if.control_word.opcode),
    .dmem_read_mem(EXMEM_if.control_word.dmem_read),
    .dmem_write_mem(EXMEM_if.control_word.dmem_write),

    .rd_ex(IDEX_if.rd),
    .pc_en(load_pc),
    .IFID_en(IFID_if.en),
    .IDEX_en(IDEX_if.en),
    .EXMEM_en(EXMEM_if.en),
    .MEMWB_en(MEMWB_if.en),
    .IFID_flush(IFID_if.flush),
    .IDEX_flush(IDEX_if.flush),
    .predict_en(predict_en),
    .mdu_done(mdu_done)
);

forwarding_unit forwarding(
    .IDEX_rs1(IDEX_if.rs1),
    .IDEX_rs2(IDEX_if.rs2),
    .forwardingmux1_sel(forwardingmux1_sel),
    .forwardingmux2_sel(forwardingmux2_sel),

    // MEM Stage
    .EXMEM_rd(EXMEM_if.rd),
    .EXMEM_load_reg(EXMEM_if.control_word.load_regfile),

    // WB Stage
    .MEMWB_rd(MEMWB_if.rd),
    .MEMWB_load_reg(MEMWB_if.control_word.load_regfile)
);
/*****************************************************************************/

// Branch Prediction Result
always_comb begin
    expected_next_pc = IDEX_if.pc_plus4;

    unique case (IDEX_if.control_word.opcode)
        rv32i_types::op_br: begin
            if (br_en)          expected_next_pc = alu_out;
        end
        rv32i_types::op_jal:    expected_next_pc = alu_out;
        rv32i_types::op_jalr:   expected_next_pc = alu_out_mod2;
        default: expected_next_pc = IDEX_if.pc_plus4;
    endcase 

    predictionFailed = 0;
    if (IDEX_if.next_pc != expected_next_pc) begin
        predictionFailed = 1;
    end
end

/******************************** Muxes **************************************/
always_comb begin : MUXES
    // We provide one (incomplete) example of a mux instantiated using
    // a case statement.  Using enumerated types rather than bit vectors
    // provides compile time type safety.  Defensive programming is extremely
    // useful in SystemVerilog.  In this case, we actually use
    // Offensive programming --- making simulation halt with a fatal message
    // warning when an unexpected mux select value occurs
    if (IDEX_if.funct7 == 7'b1 && IDEX_if.control_word.opcode == op_reg) begin
        alu_out = mdu_EX;
        mdu_start = 1'b1;
    end
    else begin
        alu_out = alu_EX;
        mdu_start = 1'b0;

    end

    unique case (predicted_direction)
        datapath_mux_types::nottaken: predicted_pc = pc_plus4;
        datapath_mux_types::taken:    predicted_pc = predicted_target;
        default: `BAD_MUX_SEL;
    endcase

    unique case (nextpcmux_t'(predictionFailed))
        datapath_mux_types::predicted: next_pc = predicted_pc;
        datapath_mux_types::expected:  next_pc = expected_next_pc;
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
        alumux::rs1_out: alumux1_out = forwardingmux1;
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
        alumux::rs2_out: alumux2_out = forwardingmux2;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    // Forwarding Unit Mux 1
    unique case (forwardingmux1_sel)
        datapath_mux_types::alumux_out:         forwardingmux1_out = IDEX_if.rs1_out;
        datapath_mux_types::mem_regfile_mux:    forwardingmux1_out = regfilemux_out_mem;
        datapath_mux_types::wb_regfile_mux:     forwardingmux1_out = rm_out;
    endcase

    // Forwarding Unit Mux 2
    unique case (forwardingmux2_sel)
        datapath_mux_types::alumux_out:         forwardingmux2_out = IDEX_if.rs2_out;
        datapath_mux_types::mem_regfile_mux:    forwardingmux2_out = regfilemux_out_mem;
        datapath_mux_types::wb_regfile_mux:     forwardingmux2_out = rm_out;
    endcase

    // MEM Stage Regfile Mux
    unique case (EXMEM_if.control_word.regfilemux_sel)
        regfilemux::alu_out:    regfilemux_out_mem = EXMEM_if.alu_out;
        regfilemux::br_en:      regfilemux_out_mem = {'0, EXMEM_if.br_en}; 
        regfilemux::u_imm:      regfilemux_out_mem = EXMEM_if.u_imm;  
        regfilemux::pc_plus4:   regfilemux_out_mem = EXMEM_if.pc_plus4;
        default:                regfilemux_out_mem = EXMEM_if.alu_out;
    endcase

    unique case (IDEX_if.control_word.cmpmux_sel)
        cmpmux::rs2_out: cmpmux_out = forwardingmux2;
        cmpmux::i_imm: cmpmux_out = IDEX_if.i_imm;

        // etc.
        default: `BAD_MUX_SEL;
    endcase

    if (dmem_opcode == rv32i_types::op_store) begin
        unique case (store_funct3)
            sw: dmem_byte_enable = 4'b1111;
            sh: begin
                unique case (alu_address[1:0])
                    2'b00: dmem_byte_enable = 4'b0011;
                    2'b01: dmem_byte_enable = 4'b0110;
                    2'b10: dmem_byte_enable = 4'b1100;
                    default: dmem_byte_enable = 4'b1111;
                endcase
            end
            sb: begin
                unique case (alu_address[1:0])
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
    else begin
        dmem_byte_enable = '0;
    end

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