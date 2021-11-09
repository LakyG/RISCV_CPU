// `include "rv32i_types.sv"
// `include "control_word.sv"
// `include "pipeline_registers_if.sv"

module IFID_reg (
    input clk,
    input rst,
    pipeline_registers_if.IFID IFID_if
);

    logic IR_load;
    logic [2:0] funct3;
    rv32i_types::rv32i_opcode opcode;
    logic [31:0] i_imm;
    rv32i_types::rv32i_reg rs1, rs2, rd;
    logic [31:0] ir_in;


    always_comb begin
        //Defaults
        IR_load = 1;
        
        IFID_if.funct3 = funct3;
        IFID_if.opcode = opcode;
        IFID_if.i_imm = i_imm;
        IFID_if.rs1 = rs1;
        IFID_if.rs2 = rs2;
        IFID_if.rd = rd;
        ir_in = IFID_if.imem_rdata_in;

        if (IFID_if.en && IFID_if.flush) begin
            // IR_load = 0;

            // // Set to a NOP --> ADDI x0, x0, 0
            // IFID_if.funct3 = rv32i_types::alu_add;
            // IFID_if.opcode = rv32i_types::op_imm;
            // IFID_if.i_imm = '0;
            // IFID_if.rs1 = '0;
            // IFID_if.rs2 = '0;
            // IFID_if.rd = '0;
            IR_load = 1;
            ir_in = 32'h13;

        end
    end

    ir IR (
        .*,
        .load(IR_load),
        .in(ir_in),
        
        .funct3(funct3),
        .funct7(IFID_if.funct7),
        .opcode(opcode),
        .i_imm(i_imm),
        .s_imm(IFID_if.s_imm),
        .b_imm(IFID_if.b_imm),
        .u_imm(IFID_if.u_imm),
        .j_imm(IFID_if.j_imm),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            IFID_if.pc          <= 32'h60;
            IFID_if.pc_plus4    <= 32'h64;
        end
        else if (IFID_if.en && IFID_if.flush) begin
            IFID_if.pc          <= '0;
            IFID_if.pc_plus4    <= '0;
        end
        else if (IFID_if.en) begin
            IFID_if.pc          <= IFID_if.pc_in;
            IFID_if.pc_plus4    <= IFID_if.pc_plus4_in;
        end
    end

endmodule