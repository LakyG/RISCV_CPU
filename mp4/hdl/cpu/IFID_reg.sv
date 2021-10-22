// `include "rv32i_types.sv"
// `include "control_word.sv"
// `include "pipeline_registers_if.sv"

module IFID_reg (
    input clk,
    input rst,
    pipeline_registers_if.IFID IFID_if
);

    //TODO: The IR needs to flush when the flush signal goes high (check how this should be handled)
    ir IR (
        .*,
        .load(IFID_if.en),
        .in(IFID_if.imem_rdata_in),
        
        .funct3(IFID_if.funct3),
        .funct7(IFID_if.funct7),
        .opcode(IFID_if.opcode),
        .i_imm(IFID_if.i_imm),
        .s_imm(IFID_if.s_imm),
        .b_imm(IFID_if.b_imm),
        .u_imm(IFID_if.u_imm),
        .j_imm(IFID_if.j_imm),
        .rs1(IFID_if.rs1),
        .rs2(IFID_if.rs2),
        .rd(IFID_if.rd)
    );

    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            IFID_if.pc          <= '0;
            IFID_if.pc_plus4    <= '0;
        end
        // else if (IFID_if.en && IFID_if.flush) begin
        //     IFID_if.pc          <= '0;
        //     IFID_if.pc_plus4    <= '0;
        // end
        else if (IFID_if.en) begin
            IFID_if.pc          <= IFID_if.pc_in;
            IFID_if.pc_plus4    <= IFID_if.pc_plus4_in;
        end
    end

endmodule