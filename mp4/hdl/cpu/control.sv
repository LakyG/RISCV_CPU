import rv32i_types::*; /* Import types defined in rv32i_types.sv */
import control_word::*;

module control
(
    input clk,
    input rst,
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output rv32i_control_word ctrl
);

/**
 *  Rather than filling up an always_block with a whole bunch of default values,
 *  set the default values for controller output signals in this function,
 *   and then call it at the beginning of your always_comb block.
**/
function void set_defaults();
    load_mar = 1'b0;
    marmux_sel = marmux::pc_out;
    load_mdr = 1'b0;
    mem_read = 1'b0;
    load_ir = 1'b0;
    load_pc = 1'b0;
    pcmux_sel = pcmux::pc_plus4;
    load_regfile = 1'b0;
    regfilemux_sel = regfilemux::u_imm;
	aluop = alu_add;
	alumux1_sel = alumux::pc_out;
    alumux2_sel = alumux::u_imm;
    load_mar = 1'b0;
    marmux_sel = marmux::pc_out;
    load_data_out = 1'b0;
    mem_write = 1'b0;
    mem_byte_enable = 4'b0000;
    cmpmux_sel = cmpmux::rs2_out;
    cmpop = branch_funct3;
endfunction

/**
 *  Use the next several functions to set the signals needed to
 *  load various registers
**/
function void loadPC(pcmux::pcmux_sel_t sel);
    load_pc = 1'b1;
    pcmux_sel = sel;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
    load_regfile = 1'b1;
    regfilemux_sel = sel;
endfunction

function void loadMAR(marmux::marmux_sel_t sel);
    load_mar = 1'b1;
    marmux_sel = sel;
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
    alumux1_sel = sel1;
    alumux2_sel = sel2;

    if (setop)
        aluop = op; // else default value
endfunction

function automatic void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
endfunction

/*****************************************************************************/

    /* Remember to deal with rst signal */

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)

        fetch1: begin
            load_mar = 1'b1;
            marmux_sel = marmux::pc_out;
        end
        fetch2: begin
            load_mdr = 1'b1;
            mem_read = 1'b1;
        end
        fetch3: begin
            load_ir = 1'b1;
        end
        decode:;
        lui: begin
            loadRegfile(regfilemux::u_imm);
            loadPC(pcmux::pc_plus4);
        end
        auipc: begin
            loadPC(pcmux::pc_plus4);
            setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_add);
            loadRegfile(regfilemux::alu_out);

        end
        calc_addr: begin
            if (opcode == op_store) begin
                loadMAR(marmux::alu_out);
                load_data_out = 1'b1;
                setALU(alumux::rs1_out, alumux::s_imm, 1'b1, alu_add);
            end
            else begin
                loadMAR(marmux::alu_out);
                setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
            end
        end
        st1: begin
            mem_write = 1'b1;
            mem_byte_enable = wmask;
        end
        st2: begin
            loadPC(pcmux::pc_plus4);
        end
        ld1: begin
            load_mdr = 1'b1;
            mem_read = 1'b1;
        end
        ld2: begin
            loadPC(pcmux::pc_plus4);
            //loadRegfile(regfilemux::lw);
            mem_byte_enable = rmask;
            unique case (load_funct3)
                lw: loadRegfile(regfilemux::lw);
                lh: loadRegfile(regfilemux::lh);
                lhu: loadRegfile(regfilemux::lhu);
                lb: loadRegfile(regfilemux::lb);
                lbu: loadRegfile(regfilemux::lbu);
                default: loadRegfile(regfilemux::lw);
            endcase
        end
        imm: begin
            // loadPC(pcmux::pc_plus4);
            // setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_ops'(funct3));
            // loadRegfile(regfilemux::alu_out);
            unique case (arith_funct3)
                slt: begin
                    loadPC(pcmux::pc_plus4);
                    cmpop = blt;
                    cmpmux_sel = cmpmux::i_imm;
                    loadRegfile(regfilemux::br_en);
                end
                sltu: begin
                    loadPC(pcmux::pc_plus4);
                    cmpop = bltu;
                    cmpmux_sel = cmpmux::i_imm;
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
        br: begin
            cmpmux_sel = cmpmux::rs2_out;
            setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
            if (br_en) begin
                loadPC(pcmux::alu_out);
                // setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
            end
            else begin
                loadPC(pcmux::pc_plus4);
            end
        end
        sreg: begin
            unique case (arith_funct3)
                slt: begin
                    loadPC(pcmux::pc_plus4);
                    cmpop = blt;
                    cmpmux_sel = cmpmux::rs2_out;
                    loadRegfile(regfilemux::br_en);
                end
                sltu: begin
                    loadPC(pcmux::pc_plus4);
                    cmpop = bltu;
                    cmpmux_sel = cmpmux::rs2_out;
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
        jal: begin
            loadRegfile(regfilemux::pc_plus4);
            setALU(alumux::pc_out, alumux::j_imm, 1'b1, alu_add);
            loadPC(pcmux::alu_out);
        end
        jalr: begin
            loadRegfile(regfilemux::pc_plus4);
            setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
            loadPC(pcmux::alu_mod2);
        end


        default:;
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    unique case (state)

        fetch1: begin
            next_states = fetch2;
        end
        fetch2: begin
            if (mem_resp) begin
                next_states = fetch3;
            end
            else begin
                next_states = state;
            end
        end
        fetch3: begin
            next_states = decode;
        end
        decode: begin
            unique case (opcode)
                op_lui: next_states = lui;
                op_auipc: next_states = auipc;
                op_store: next_states = calc_addr;
                op_load: next_states = calc_addr;
                op_imm: next_states = imm;
                op_br: next_states = br;
                op_reg: next_states = sreg;
                op_jal: next_states = jal;
                op_jalr: next_states = jalr;
                default: next_states = fetch1;
            endcase
        end
        lui: begin
            next_states = fetch1;
        end
        auipc: begin
            next_states = fetch1;
        end
        calc_addr: begin
            if (opcode == op_store) begin
                next_states = st1;
            end
            else begin
                next_states = ld1;
            end
        end
        st1: begin
            if (mem_resp) begin
                next_states = st2;
            end
            else begin
                next_states = state;
            end
        end
        st2: begin
            next_states = fetch1;
        end
        ld1: begin
            if (mem_resp) begin
                next_states = ld2;
            end
            else begin
                next_states = state;
            end
        end
        ld2: begin
            next_states = fetch1;
        end
        imm: begin
            next_states = fetch1;
        end
        br: begin
            next_states = fetch1;
        end
        sreg: begin
            next_states = fetch1;
        end
        jal: begin
            next_states = fetch1;
        end 
        jalr: begin
            next_states = fetch1;
        end 

        default: begin
            next_states = state;
        end
        
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst) begin
        state <= fetch1;
    end
    else begin
        state <= next_states;
    end
end

endmodule : control