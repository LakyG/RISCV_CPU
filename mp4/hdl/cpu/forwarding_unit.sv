import rv32i_types::*;
import datapath_mux_types::*;

module forwarding_unit (
    // EX Stage
    input rv32i_reg IDEX_rs1,
    input rv32i_reg IDEX_rs2,
    logic [2:0] funct3,
    output forwardingmux_t forwardingmux1_sel,
    output forwardingmux_t forwardingmux2_sel,


    // MEM Stage
    input rv32i_reg EXMEM_rd,
    input logic EXMEM_load_reg,

    // WB Stage
    input rv32i_reg MEMWB_rd,
    input logic MEMWB_load_reg
);
    arith_funct3_t arith_funct3;

    assign arith_funct3 = arith_funct3_t'(funct3);

    always_comb begin
        forwardingmux1_sel = forwardingmux_t'(alumux_out);
        forwardingmux2_sel = forwardingmux_t'(alumux_out);


        // MEM Stage Forwarding
        if (EXMEM_load_reg && (EXMEM_rd != '0)) begin
           if (EXMEM_rd == IDEX_rs1) begin
                if ((arith_funct3 == slt) | (arith_funct3 == sltu))
                    forwardingmux1_sel = forwardingmux_t'(mem_br_en); 
                else
                    forwardingmux1_sel = forwardingmux_t'(mem_alu_out); 
           end
           if (EXMEM_rd == IDEX_rs2) begin
               if ((arith_funct3 == slt) | (arith_funct3 == sltu))
                    forwardingmux2_sel = forwardingmux_t'(mem_br_en); 
                else
                    forwardingmux2_sel = forwardingmux_t'(mem_alu_out);
           end
        end

        // WB Stage Forwarding
        if (MEMWB_load_reg && (MEMWB_rd != '0)) begin
            if (~(EXMEM_load_reg && (EXMEM_rd != '0) && (EXMEM_rd == IDEX_rs1))) begin
                if (MEMWB_rd == IDEX_rs1) begin
                    forwardingmux1_sel = forwardingmux_t'(wb_regfile_mux);
                end
            end

            if (~(EXMEM_load_reg && (EXMEM_rd != '0) && (EXMEM_rd == IDEX_rs2))) begin
                if (MEMWB_rd == IDEX_rs2) begin 
                    forwardingmux2_sel = forwardingmux_t'(wb_regfile_mux);
                end
            end
        end
    end

endmodule : forwarding_unit