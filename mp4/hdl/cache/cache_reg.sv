// `include "rv32i_types.sv"
// `include "control_word.sv"
// `include "pipeline_registers_if.sv"

module cache_reg #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index, //24
    parameter s_mask   = 2**s_offset, //32
    parameter s_line   = 8*s_mask //256
)
(
    input clk,
    input rst,
    input logic load_reg,
    // input logic mem_read_in,
    // input logic mem_write_in,
    input logic [31:0] mem_address_in,
    // output logic mem_read,
    // output logic mem_write,
    output logic [31:0] mem_address_bus,
    input logic [s_line-1:0] mem_rdata256_in,
    output logic [s_line-1:0] mem_rdata256,
    input logic [s_line-1:0] mem_wdata256,
    input logic [s_mask-1:0] mem_byte_enable256,
    output logic [s_line-1:0] mem_wdata256_out,
    output logic [s_mask-1:0] mem_byte_enable256_out
);
    //assign mem_address_bus = mem_address_in;
    assign mem_rdata256 = mem_rdata256_in;
    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            //mem_rdata256 <= '0;
            mem_address_bus <= '0;
            mem_wdata256_out <= '0;
            mem_byte_enable256_out <= '0;
        end
        else if (load_reg) begin
            // mem_read <= mem_read_in;
            // mem_write <= mem_write_in;
            mem_address_bus <= mem_address_in;
            //mem_rdata256 <= mem_rdata256_in;
            mem_wdata256_out <= mem_wdata256;
            mem_byte_enable256_out <= mem_byte_enable256;
        end
    end

endmodule