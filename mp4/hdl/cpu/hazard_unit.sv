import rv32i_types::*; /* Import types defined in rv32i_types.sv */
import pcmux::*;

module hazard_unit
(
    // Memory Control
    input logic imem_resp,
    input logic dmem_resp,

    // From ID Stage
    input rv32i_reg rs1_id,
    input rv32i_reg rs2_id,

    // From EX Stage
    input logic br_en,
    input rv32i_opcode opcode,
    input rv32i_reg rd_ex,

    // From MEM Stage
    input logic dmem_read_mem,
    input logic dmem_write_mem,

    // PC Control
    output logic pc_en,
    output pcmux_sel_t pcmux_sel,
    
    // Pipeline Register Control
    output logic IFID_en,
    output logic IDEX_en,
    output logic EXMEM_en,
    output logic MEMWB_en,

    output logic IFID_flush,
    output logic IDEX_flush
);

    logic branch_missprediction;
    logic jump_instr;
    logic br_j_flush;
    logic dmem_request;
    logic load_use_hazard;

    assign branch_missprediction = br_en && (opcode == rv32i_types::op_br);
    assign jump_instr = (opcode == rv32i_types::op_jal) || (opcode == rv32i_types::op_jalr);

    // Check if a flush due to branch misprediction or jump is needed
    assign br_j_flush = branch_missprediction | jump_instr;

    // Check for any D-Mem request
    assign dmem_request = dmem_read_mem | dmem_write_mem;

    // Check for Load-Use Hazard
    assign load_use_hazard = (opcode == rv32i_types::op_load) && (rd_ex == rs1_id || rd_ex == rs2_id);

    // PC Enable
    always_comb begin
        pc_en = 0;

        // if (~load_use_hazard) begin                                 // Check for Load-Use Hazard
        //     if ((imem_resp && ~dmem_request) || br_j_flush) begin   // Check for PC enable conditions
        //         pc_en = 1;
        //     end 
        // end

        if (IFID_en || br_j_flush) begin
            pc_en = 1;
        end
    end

    // PC Select Mux
    always_comb begin
        unique case (opcode)
            op_br: pcmux_sel = pcmux_sel_t'(br_en);
            op_jal: pcmux_sel = pcmux::alu_out;
            op_jalr: pcmux_sel = pcmux::alu_mod2;
            default: pcmux_sel = pcmux::pc_plus4;
        endcase
    end

    //Pipeline Register Enable and Flush
    always_comb begin
        IFID_en  = 0;
        IDEX_en  = 0;
        EXMEM_en = 0;
        MEMWB_en = 0;
        IFID_flush = 0;
        IDEX_flush = 0;

        if (imem_resp && dmem_resp) begin
            IFID_en  = 1;
            IDEX_en  = 1;
            EXMEM_en = 1;
            MEMWB_en = 1;
        end
        else if (imem_resp && ~dmem_request) begin
            IFID_en  = 1;
            IDEX_en  = 1;
            EXMEM_en = 1;
            MEMWB_en = 1;
        end
        else if (~imem_resp && ~dmem_request) begin
            IFID_en  = 1;
            IDEX_en  = 1;
            EXMEM_en = 1;
            MEMWB_en = 1;
            IFID_flush = 1;
        end

        // Check for Branch Misprediction (MP3-CP2 is static branch prediction)
        if (br_j_flush) begin
            IFID_flush = 1;
            IDEX_flush = 1;
        end

        // Load-Use Hazard Stall
        if (load_use_hazard) begin
            IDEX_flush = 1;
        end

        if (load_use_hazard) begin
            IFID_en = 0;
        end
    end
endmodule : hazard_unit
