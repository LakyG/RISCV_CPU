import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module control
(
    input clk,
    input rst,
    input rv32i_opcode opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic br_en,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    output pcmux::pcmux_sel_t pcmux_sel,
    output alumux::alumux1_sel_t alumux1_sel,
    output alumux::alumux2_sel_t alumux2_sel,
    output regfilemux::regfilemux_sel_t regfilemux_sel,
    output marmux::marmux_sel_t marmux_sel,
    output cmpmux::cmpmux_sel_t cmpmux_sel,
    output alu_ops aluop,
    output logic load_pc,
    output logic load_ir,
    output logic load_regfile,
    output logic load_mar,
    output logic load_mdr,
    output logic load_data_out,
    input logic mem_resp,
	output logic mem_read,
    output logic mem_write,
    output logic [3:0] mem_byte_enable,
    output branch_funct3_t cmpop,
    input logic [1:0] addr_2bit
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
assign rs1_addr = rs1;
assign rs2_addr = rs2;

always_comb
begin : trap_check
    trap = 0;
    rmask = '0;
    wmask = '0;

    case (opcode)
        op_lui, op_auipc, op_imm, op_reg, op_jal, op_jalr:;

        op_br: begin
            case (branch_funct3)
                beq, bne, blt, bge, bltu, bgeu:;
                default: trap = 1;
            endcase
        end

        op_load: begin
            case (load_funct3)
                lw: rmask = 4'b1111;
                lh, lhu: rmask = 4'bXXXX /* Modify for MP1 Final */ ;
                // lh, lhu: begin
                //     unique case (addr_2bit):
                //         2'b00: rmask = 4'b0011;
                //         2'b10: rmask = 4'b1100;
                //         default: rmask = 4'b1111;
                //     endcase
                // end
                lb, lbu: rmask = 4'bXXXX /* Modify for MP1 Final */ ;
                // lb, lbu: begin
                //     unique case (addr_2bit):
                //         2'b00: rmask = 4'b0001;
                //         2'b01: rmask = 4'b0010;
                //         2'b10: rmask = 4'b0100;
                //         2'b11: rmask = 4'b1000;
                //         default: rmask = 4'b1111;
                //     endcase
                // end
                default: trap = 1;
            endcase
        end

        op_store: begin
            case (store_funct3)
                sw: wmask = 4'b1111;
                sh: begin
                    unique case (addr_2bit)
                        2'b00: wmask = 4'b0011;
                        2'b01: wmask = 4'b0110;
                        2'b10: wmask = 4'b1100;
                        default: wmask = 4'b1111;
                    endcase
                end
                sb: begin
                    unique case (addr_2bit)
                        2'b00: wmask = 4'b0001;
                        2'b01: wmask = 4'b0010;
                        2'b10: wmask = 4'b0100;
                        2'b11: wmask = 4'b1000;
                        default: wmask = 4'b1111;
                    endcase
                end
                default: trap = 1;
            endcase
        end

        default: trap = 1;
    endcase
end
/*****************************************************************************/

enum int unsigned {
    /* List of states */
    fetch1, fetch2, fetch3, decode, imm, br, lui, auipc, calc_addr, ld1, ld2, st1, st2, sreg, jal, jalr
} state, next_states;

/************************* Function Definitions *******************************/
/**
 *  You do not need to use these functions, but it can be nice to encapsulate
 *  behavior in such a way.  For example, if you use the `loadRegfile`
 *  function, then you only need to ensure that you set the load_regfile bit
 *  to 1'b1 in one place, rather than in many.
 *
 *  SystemVerilog functions must take zero "simulation time" (as opposed to 
 *  tasks).  Thus, they are generally synthesizable, and appropraite
 *  for design code.  Arguments to functions are, by default, input.  But
 *  may be passed as outputs, inouts, or by reference using the `ref` keyword.
**/

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