/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */
import rv32i_types::*;

module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input rst,
    input rv32i_word mem_address,
    input rv32i_word mem_wdata,
    input logic mem_read,
    input logic mem_write,
    input logic [255:0] pmem_rdata,
    input pmem_resp,
    input logic [3:0] mem_byte_enable,
    output rv32i_word pmem_address,
    output logic pmem_read,
    output logic pmem_write,
    output logic mem_resp,
    output rv32i_word mem_rdata,
    output logic [255:0] pmem_wdata
);

logic tag0_hit;
logic tag1_hit;
logic valid0_out;
logic valid1_out;
 logic lru_out;
 logic datamux_sel;
 logic load_lru;
 logic lru_in;
 logic [31:0] write_en0;
 logic [31:0] write_en1;
  logic load_tag0;
 logic load_tag1;
 logic load_valid0;
 logic load_valid1;
 logic valid_in;
logic [255:0] mem_wdata256;
logic [255:0] mem_rdata256;
logic [31:0] mem_byte_enable256;

logic dirty0_out;
logic dirty1_out;
 logic load_dirty0;
 logic load_dirty1;
 logic dirty_in;
 logic line0_in_sel;
 logic line1_in_sel;
logic addr_sel;

cache_control control
(
    .*
);

cache_datapath datapath
(
    .*
);

bus_adapter bus_adapter
(
    .*,
    .address(mem_address)
);

endmodule : cache
