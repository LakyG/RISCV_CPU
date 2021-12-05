// `include "rv32i_types.sv"
// `include "control_word.sv"
// `include "pipeline_registers_if.sv"

module IDEX_reg (
    input clk,
    input rst,
    pipeline_registers_if.IDEX IDEX_if
);

    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            IDEX_if.pc              <= '0;
            IDEX_if.pc_plus4        <= '0;
            IDEX_if.next_pc         <= '0;
            IDEX_if.imem_rdata      <= '0;
            IDEX_if.predicted_direction <= 1'b0;
            IDEX_if.i_imm           <= '0;
            IDEX_if.s_imm           <= '0;
            IDEX_if.b_imm           <= '0;
            IDEX_if.u_imm           <= '0;
            IDEX_if.j_imm           <= '0;
            IDEX_if.rs1             <= '0;
            IDEX_if.rs2             <= '0;
            IDEX_if.rd              <= '0;
            IDEX_if.control_word    <= '0;
            IDEX_if.rs1_out         <= '0;
            IDEX_if.rs2_out         <= '0;
        end
        else if (IDEX_if.en && IDEX_if.flush) begin
            IDEX_if.pc              <= '0;
            IDEX_if.pc_plus4        <= '0;
            IDEX_if.next_pc         <= '0;
            IDEX_if.imem_rdata      <= '0;
            IDEX_if.predicted_direction <= 1'b0;
            IDEX_if.i_imm           <= '0;
            IDEX_if.s_imm           <= '0;
            IDEX_if.b_imm           <= '0;
            IDEX_if.u_imm           <= '0;
            IDEX_if.j_imm           <= '0;
            IDEX_if.rs1             <= '0;
            IDEX_if.rs2             <= '0;
            IDEX_if.rd              <= '0;
            IDEX_if.control_word    <= '0;
            IDEX_if.rs1_out         <= '0;
            IDEX_if.rs2_out         <= '0;
        end
        else if (IDEX_if.en) begin
            IDEX_if.pc              <= IDEX_if.pc_in;
            IDEX_if.pc_plus4        <= IDEX_if.pc_plus4_in;
            IDEX_if.next_pc         <= IDEX_if.next_pc_in;
            IDEX_if.imem_rdata      <= IDEX_if.imem_rdata_in;
            IDEX_if.predicted_direction <= IDEX_if.predicted_direction_in;
            IDEX_if.i_imm           <= IDEX_if.i_imm_in;
            IDEX_if.s_imm           <= IDEX_if.s_imm_in;
            IDEX_if.b_imm           <= IDEX_if.b_imm_in;
            IDEX_if.u_imm           <= IDEX_if.u_imm_in;
            IDEX_if.j_imm           <= IDEX_if.j_imm_in;
            IDEX_if.rs1             <= IDEX_if.rs1_in;
            IDEX_if.rs2             <= IDEX_if.rs2_in;
            IDEX_if.rd              <= IDEX_if.rd_in;
            IDEX_if.control_word    <= IDEX_if.control_word_in;
            IDEX_if.rs1_out         <= IDEX_if.rs1_out_in;
            IDEX_if.rs2_out         <= IDEX_if.rs2_out_in;
        end
    end

endmodule