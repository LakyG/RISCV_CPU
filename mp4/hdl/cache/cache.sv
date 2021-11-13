/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

import cache_types::*;
import rv32i_types::*;

module cache #(
    parameter s_offset = 4,
    parameter size = (2**s_offset)*8, //cacheline size
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index, //24
    parameter s_mask   = 2**s_offset, //32
    parameter s_line   = 8*s_mask, //256
    parameter num_sets = 2**s_index, //8
    parameter num_ways = 2,
    parameter width = 1 //log(num_ways)
)
(
    input clk,
    input rst,

    // From CPU
    input logic mem_read,
    input logic mem_write,
    input logic [3:0] mem_byte_enable,
    input rv32i_word mem_address,
    input rv32i_word mem_wdata,
    // To CPU
    output logic mem_resp,
    output rv32i_word mem_rdata,

    // FROM RAM
    input logic [size-1:0] line_o,
    input logic resp_o,
    // TO RAM
    output logic [size-1:0] line_i,
    output logic [31:0] address_i,
    output logic read_i,
    output logic write_i
);

// Datapath to Control
logic hit;
logic [num_ways-1:0] dirty_out;
logic [width-1:0] lru;

// Control to Datapath
write_data_sel_t write_data_sel;
logic load;
write_en_sel_t write_en_sel;
logic valid;
logic dirty;
logic lru_load;
ram_addr_sel_t ram_addr_sel;

// Bus Adapter to Datapath
logic [s_line-1:0] mem_wdata256;
logic [s_mask-1:0] mem_byte_enable256;

// Datapath to Bus Adapter
logic [s_line-1:0] mem_rdata256;

cache_control #(.s_offset(s_offset)) control (
    .*,
    // Input from RAM
    .ram_resp_o(resp_o),
    // Output to RAM
    .ram_read_i(read_i),
    .ram_write_i(write_i)
);

cache_datapath #(.s_offset(s_offset)) datapath (
    .*,
    // Input from RAM
    .ram_line_o(line_o),
    // Output to RAM
    .ram_line_i(line_i),
    .ram_address_i(address_i),
    .valid_in(valid),
    .dirty_in(dirty),
    .hit_out(hit)

);

bus_adapter #(.s_offset(s_offset)) bus_adapter (
    .*,
    .address(mem_address)
);

endmodule : cache
