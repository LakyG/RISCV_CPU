`include "rv32i_types.sv"
`include "control_word.sv"
`include "pipeline_registers_if.sv"

module IFID_reg (
    input CLK,
    input rst,
    input pipeline_registers_if.IFID IFID_if
);

    always_ff @ (posedge CLK, posedge rst) begin
        
    end

endmodule