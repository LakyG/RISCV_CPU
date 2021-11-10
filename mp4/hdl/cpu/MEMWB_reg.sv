// `include "rv32i_types.sv"
// `include "control_word.sv"
// `include "pipeline_registers_if.sv"

module MEMWB_reg (
    input clk,
    input rst,
    pipeline_registers_if.MEMWB MEMWB_if
);

    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            MEMWB_if.pc             <= '0;
            MEMWB_if.pc_plus4       <= '0;
            MEMWB_if.next_pc        <= '0;
            MEMWB_if.imem_rdata     <= '0;
            MEMWB_if.control_word   <= '0;
            MEMWB_if.u_imm          <= '0;
            MEMWB_if.rs1            <= '0;
            MEMWB_if.rs2            <= '0;
            MEMWB_if.rs1_out        <= '0;
            MEMWB_if.rs2_out        <= '0;
            MEMWB_if.rd             <= '0;
            MEMWB_if.br_en          <= '0;
            MEMWB_if.alu_out        <= '0;
            MEMWB_if.dmem_rdata     <= '0;
        end
        // else if (MEMWB_if.en && MEMWB_if.flush) begin
        //     MEMWB_if.pc             <= '0;
        //     MEMWB_if.pc_plus4       <= '0;
        //     EXMEM_if.next_pc        <= '0;
        //     EXMEM_if.imem_rdata     <= '0;
        //     MEMWB_if.control_word   <= '0;
        //     MEMWB_if.u_imm          <= '0;
        //     MEMWB_if.rs1            <= '0;
        //     MEMWB_if.rs2            <= '0;
        //     MEMWB_if.rs1_out        <= '0;
        //     MEMWB_if.rs2_out        <= '0;
        //     MEMWB_if.rd             <= '0;
        //     MEMWB_if.br_en          <= '0;
        //     MEMWB_if.alu_out        <= '0;
        //     MEMWB_if.dmem_rdata     <= '0;
        // end
        else if (MEMWB_if.en) begin
            MEMWB_if.pc             <= MEMWB_if.pc_in;
            MEMWB_if.pc_plus4       <= MEMWB_if.pc_plus4_in;
            MEMWB_if.next_pc        <= MEMWB_if.next_pc_in;
            MEMWB_if.imem_rdata     <= MEMWB_if.imem_rdata_in;
            MEMWB_if.control_word   <= MEMWB_if.control_word_in;
            MEMWB_if.u_imm          <= MEMWB_if.u_imm_in;
            MEMWB_if.rs1            <= MEMWB_if.rs1_in;
            MEMWB_if.rs2            <= MEMWB_if.rs2_in;
            MEMWB_if.rs1_out        <= MEMWB_if.rs1_out_in;
            MEMWB_if.rs2_out        <= MEMWB_if.rs2_out_in;
            MEMWB_if.rd             <= MEMWB_if.rd_in;
            MEMWB_if.br_en          <= MEMWB_if.br_en_in;
            MEMWB_if.alu_out        <= MEMWB_if.alu_out_in;
            MEMWB_if.dmem_rdata     <= MEMWB_if.dmem_rdata_in;
        end
    end

endmodule