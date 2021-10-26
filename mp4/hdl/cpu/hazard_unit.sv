import rv32i_types::*; /* Import types defined in rv32i_types.sv */
import pcmux::*;

module hazard_unit
(
    // Memory Control
    //input logic imem_resp,
    //input logic dmem_resp,

    input logic br_en,
    input rv32i_opcode opcode,

    // PC Control
    output logic pc_en,
    output pcmux_sel_t pcmux_sel
    
    // Pipeline Register Control
    // output logic IFID_en,
    // output logic IFID_flush,
    // output logic IDEX_en,
    // output logic IDEX_flush,
    // output logic EXMEM_en,
    // output logic MEMWB_en
);

    assign pc_en = 1;

always_comb begin
    unique case (opcode)
        op_br: pcmux_sel = pcmux_sel_t'(br_en);
        op_jal: pcmux_sel = pcmux::alu_out;
        op_jalr: pcmux_sel = pcmux::alu_mod2;
    endcase
end

endmodule : hazard_unit