import rv32i_types::*; /* Import types defined in rv32i_types.sv */
import pcmux::*;

module hazard_unit
(
    // Memory Control
    //input logic imem_resp,
    //input logic dmem_resp,

    input logic br_en,

    // PC Control
    //output logic pc_en,
    output pcmux_sel_t pcmux_sel
    
    // Pipeline Register Control
    // output logic IFID_en,
    // output logic IFID_flush,
    // output logic IDEX_en,
    // output logic IDEX_flush,
    // output logic EXMEM_en,
    // output logic MEMWB_en
);

    assign pcmux_sel = pcmux_sel_t'(br_en);

endmodule : hazard_unit