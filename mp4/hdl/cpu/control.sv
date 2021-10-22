import rv32i_types::*; /* Import types defined in rv32i_types.sv */
import control_word::*;

module control
(
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output rv32i_control_word ctrl
);

/***************** USED BY RVFIMON --- ONLY MODIFY WHEN TOLD *****************/
logic trap;
logic [4:0] rs1_addr, rs2_addr;
logic [3:0] rmask, wmask;

branch_funct3_t branch_funct3;
store_funct3_t store_funct3;
load_funct3_t load_funct3;
arith_funct3_t arith_funct3;

assign arith_funct3 = arith_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);

/**
 *  Rather than filling up an always_block with a whole bunch of default values,
 *  set the default values for controller output signals in this function,
 *   and then call it at the beginning of your always_comb block.
**/
function void set_defaults();
    ctrl.load_mar = 1'b0;
    ctrl.marmux_sel = marmux::pc_out;
    ctrl.load_mdr = 1'b0;
    ctrl.mem_read = 1'b0;
    ctrl.load_ir = 1'b0;
    ctrl.load_pc = 1'b0;
    ctrl.pcmux_sel = pcmux::pc_plus4;
    ctrl.load_regfile = 1'b0;
    ctrl.regfilemux_sel = regfilemux::u_imm;
	ctrl.aluop = alu_add;
	ctrl.alumux1_sel = alumux::pc_out;
    ctrl.alumux2_sel = alumux::u_imm;
    ctrl.load_mar = 1'b0;
    ctrl.marmux_sel = marmux::pc_out;
    ctrl.load_data_out = 1'b0;
    ctrl.mem_write = 1'b0;
    ctrl.cmpmux_sel = cmpmux::rs2_out;
    ctrl.cmpop = branch_funct3;
    ctrl.funct3 = funct3;
endfunction

/**
 *  Use the next several functions to set the signals needed to
 *  load various registers
**/
function void loadPC(pcmux::pcmux_sel_t sel);
    ctrl.load_pc = 1'b1;
    ctrl.pcmux_sel = sel;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
    ctrl.load_regfile = 1'b1;
    ctrl.regfilemux_sel = sel;
endfunction

function void loadMAR(marmux::marmux_sel_t sel);
    ctrl.load_mar = 1'b1;
    ctrl.marmux_sel = sel;
endfunction

function void loadMDR();
endfunction

/**
 * SystemVerilog allows for default argument values in a way similar to
 *   C++.
**/
function void setALU(alumux::alumux1_sel_t sel1,
                               alumux::alumux2_sel_t sel2,
                               logic setop = 1'b0, alu_ops op = alu_add);
    /* Student code here */
    ctrl.alumux1_sel = sel1;
    ctrl.alumux2_sel = sel2;

    if (setop)
        ctrl.aluop = op; // else default value
endfunction



/*****************************************************************************/

    /* Remember to deal with rst signal */

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (opcode)
        op_lui: begin
            loadRegfile(regfilemux::u_imm);
            loadPC(pcmux::pc_plus4);
        end
        op_auipc: begin
            loadPC(pcmux::pc_plus4);
            setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_add);
            loadRegfile(regfilemux::alu_out);
        end
        op_store: begin
            ctrl.load_data_out = 1'b1;
            setALU(alumux::rs1_out, alumux::s_imm, 1'b1, alu_add);
            ctrl.mem_write = 1'b1;
            loadPC(pcmux::pc_plus4);
        end
        op_load: begin
            setALU(alumux::rs1_out, alumux::s_imm, 1'b1, alu_add);
            ctrl.load_mdr = 1'b1;
            ctrl.mem_read = 1'b1;
            unique case (load_funct3)
                lw: loadRegfile(regfilemux::lw);
                lh: loadRegfile(regfilemux::lh);
                lhu: loadRegfile(regfilemux::lhu);
                lb: loadRegfile(regfilemux::lb);
                lbu: loadRegfile(regfilemux::lbu);
                default: loadRegfile(regfilemux::lw);
            endcase
            loadPC(pcmux::pc_plus4);
        end
        op_imm: begin
            unique case (arith_funct3)
                slt: begin
                    loadPC(pcmux::pc_plus4);
                    ctrl.cmpop = blt;
                    ctrl.cmpmux_sel = cmpmux::i_imm;
                    loadRegfile(regfilemux::br_en);
                end
                sltu: begin
                    loadPC(pcmux::pc_plus4);
                    ctrl.cmpop = bltu;
                    ctrl.cmpmux_sel = cmpmux::i_imm;
                    loadRegfile(regfilemux::br_en);
                end
                sr: begin
                    loadPC(pcmux::pc_plus4);
                    loadRegfile(regfilemux::alu_out);
                    if (funct7 == 7'b0100000)
                        setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_sra);
                    else
                        setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_srl);
                end
                default: begin
                    loadPC(pcmux::pc_plus4);
                    setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_ops'(funct3));
                    loadRegfile(regfilemux::alu_out);
                end
            endcase
        end
        op_br: begin
            ctrl.cmpmux_sel = cmpmux::rs2_out;
            setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
        end
        op_reg: begin
            unique case (arith_funct3)
                slt: begin
                    loadPC(pcmux::pc_plus4);
                    ctrl.cmpop = blt;
                    ctrl.cmpmux_sel = cmpmux::rs2_out;
                    loadRegfile(regfilemux::br_en);
                end
                sltu: begin
                    loadPC(pcmux::pc_plus4);
                    ctrl.cmpop = bltu;
                    ctrl.cmpmux_sel = cmpmux::rs2_out;
                    loadRegfile(regfilemux::br_en);
                end
                sr: begin
                    loadPC(pcmux::pc_plus4);
                    loadRegfile(regfilemux::alu_out);
                    if (funct7 == 7'b0100000)
                        setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sra);
                    else
                        setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_srl);
                end
                add: begin
                    loadPC(pcmux::pc_plus4);
                    loadRegfile(regfilemux::alu_out);
                    if (funct7 == 7'b0100000)
                        setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sub);
                    else
                        setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_add);
                end
                default: begin
                    loadPC(pcmux::pc_plus4);
                    setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_ops'(funct3));
                    loadRegfile(regfilemux::alu_out);
                end
            endcase
        end
        op_jal: begin
            loadRegfile(regfilemux::pc_plus4);
            setALU(alumux::pc_out, alumux::j_imm, 1'b1, alu_add);
            loadPC(pcmux::alu_out);
        end
        op_jalr: begin
            loadRegfile(regfilemux::pc_plus4);
            setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
            loadPC(pcmux::alu_mod2);
        end
        default:;
    endcase
end

endmodule:control