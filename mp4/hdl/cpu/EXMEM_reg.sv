// `include "rv32i_types.sv"
// `include "control_word.sv"
// `include "pipeline_registers_if.sv"

module EXMEM_reg (
    input clk,
    input rst,
    pipeline_registers_if.EXMEM EXMEM_if
);

    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            EXMEM_if.pc             <= '0;
            EXMEM_if.pc_plus4       <= '0;
            EXMEM_if.next_pc        <= '0;
            EXMEM_if.imem_rdata     <= '0;
            EXMEM_if.control_word   <= '0;
            EXMEM_if.u_imm          <= '0;
            EXMEM_if.rs1            <= '0;
            EXMEM_if.rs2            <= '0;
            EXMEM_if.rd             <= '0;
            EXMEM_if.rs1_out        <= '0;
            EXMEM_if.rs2_out        <= '0;
            EXMEM_if.br_en          <= '0;
            EXMEM_if.alu_out        <= '0;
        end
        // else if (EXMEM_if.en && EXMEM_if.flush) begin
        //     EXMEM_if.pc             <= '0;
        //     EXMEM_if.pc_plus4       <= '0;
        //     EXMEM_if.next_pc        <= '0;
        //     EXMEM_if.imem_rdata     <= '0;
        //     EXMEM_if.control_word   <= '0;
        //     EXMEM_if.u_imm          <= '0;
        //     EXMEM_if.rs1            <= '0;
        //     EXMEM_if.rs2            <= '0;
        //     EXMEM_if.rd             <= '0;
        //     EXMEM_if.rs1_out        <= '0;
        //     EXMEM_if.rs2_out        <= '0;
        //     EXMEM_if.br_en          <= '0;
        //     EXMEM_if.alu_out        <= '0;
        // end
        else if (EXMEM_if.en) begin
            EXMEM_if.pc             <= EXMEM_if.pc_in;
            EXMEM_if.pc_plus4       <= EXMEM_if.pc_plus4_in;
            EXMEM_if.next_pc        <= EXMEM_if.next_pc_in;
            EXMEM_if.imem_rdata     <= EXMEM_if.imem_rdata_in;
            EXMEM_if.control_word   <= EXMEM_if.control_word_in;
            EXMEM_if.u_imm          <= EXMEM_if.u_imm_in;
            EXMEM_if.rs1            <= EXMEM_if.rs1_in;
            EXMEM_if.rs2            <= EXMEM_if.rs2_in;
            EXMEM_if.rd             <= EXMEM_if.rd_in;
            EXMEM_if.rs1_out        <= EXMEM_if.rs1_out_in;
            EXMEM_if.rs2_out        <= EXMEM_if.rs2_out_in;
            EXMEM_if.br_en          <= EXMEM_if.br_en_in;
            EXMEM_if.alu_out        <= EXMEM_if.alu_out_in;
        end
    end

endmodule