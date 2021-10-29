/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */
import rv32i_types::*;

module cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input logic clk,
    input logic rst,
    input [31:0] mem_address,
    input logic load_valid0,
    input logic load_valid1,
    input logic valid_in,
    input logic load_lru,
    input logic lru_in,
    input logic [31:0] write_en0,
    input logic [31:0] write_en1,
    input logic load_tag0,
    input logic load_tag1,
    input logic datamux_sel,
    input logic load_dirty0,
    input logic load_dirty1,
    input logic dirty_in,
    input logic line0_in_sel,
    input logic line1_in_sel,
    input logic addr_sel,
    input logic [3:0] mem_byte_enable,
    input rv32i_word mem_wdata,
    input logic [255:0] pmem_rdata,
    output logic [31:0] pmem_address,
    output logic [255:0] mem_rdata256,
    output logic [255:0] pmem_wdata,
    output logic tag0_hit,
    output logic tag1_hit,
    output logic valid0_out,
    output logic valid1_out,
    output logic lru_out,
    output logic dirty0_out,
    output logic dirty1_out
   
);

rv32i_word mem_addr;
assign mem_addr = mem_address;
//assign pmem_address = {mem_address[31:5], 5'b00000};

// logic [2:0] offset;
// assign logic [2:0] offset = mem_address[4:2];

//lru
//logic load_lru, lru_in, lru_out;

//tag
//logic load_tag0, load_tag1;
logic [23:0] tag0_out, tag1_out;

//line
logic cache_read;
//logic [31:0] write_en0, write_en1;
logic [255:0] line0_in, line1_in, line0_out, line1_out;

//valid
//logic load_valid0, load_valid1, valid_in, valid0_out, valid1_out;

//cmp
//logic tag0_hit, tag1_hit;

//dirty
//logic load_dirty0, load_dirty1, dirty_in, dirty0_out, dirty1_out;

array #(3, 1) lru (
    .*, 
    .read (1'b1),
    .load (load_lru),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (lru_in),
    .dataout (lru_out)
);

array #(3, 24) tag0 (
    .*,
    .read (1'b1),
    .load (load_tag0),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (mem_address[31:8]),
    .dataout (tag0_out)
);
array #(3, 24) tag1 (
    .*,
    .read (1'b1),
    .load (load_tag1),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (mem_address[31:8]),
    .dataout (tag1_out)
);
data_array #(5, 3) line0 (
    .*,
    .read (1'b1),
    .write_en (write_en0),
    .rindex  (mem_address[7:5]),
    .windex  (mem_address[7:5]),
    .datain  (line0_in),
    .dataout (line0_out)
);
data_array #(5, 3) line1 (
    .*,
    .read (1'b1),
    .write_en (write_en1),
    .rindex  (mem_address[7:5]),
    .windex  (mem_address[7:5]),
    .datain  (line1_in),
    .dataout (line1_out)
);

array #(3, 1) valid0 (
    .*, 
    .read (1'b1),
    .load (load_valid0),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (valid_in),
    .dataout (valid0_out)
);
array #(3, 1) valid1 (
    .*, 
    .read (1'b1),
    .load (load_valid1),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (valid_in),
    .dataout (valid1_out)
);

array #(3, 1) dirty0 (
    .*, 
    .read (1'b1),
    .load (load_dirty0),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (dirty_in),
    .dataout (dirty0_out)
);
array #(3, 1) dirty1 (
    .*, 
    .read (1'b1),
    .load (load_dirty1),
    .rindex (mem_address[7:5]),
    .windex (mem_address[7:5]),
    .datain (dirty_in),
    .dataout (dirty1_out)
);

cache_cmp cmp (
    .*,
    .tag_in (mem_address[31:8])
);

always_comb
    begin
        unique case (datamux_sel)
            1'b0: mem_rdata256 = line0_out;
            1'b1: mem_rdata256 = line1_out;

            // etc.
            default: mem_rdata256 = line0_out;
        endcase
        unique case (line0_in_sel)
            1'b0: line0_in = pmem_rdata;
            1'b1: begin
                line0_in = line0_out;
                for (int i = 0; i < 4; i++) begin
                    if (mem_byte_enable[i])
                        line0_in[8*({mem_address[4:2], 2'b00} + i) +: 8] = mem_wdata[8*i +: 8];
                end
            end

            // etc.
            default: line0_in = pmem_rdata;
        endcase
        unique case (line1_in_sel)
            1'b0: line1_in = pmem_rdata;
            1'b1: begin
                line1_in = line1_out;
                for (int i = 0; i < 4; i++) begin
                    if (mem_byte_enable[i])
                        line1_in[8*({mem_address[4:2], 2'b00} + i) +: 8] = mem_wdata[8*i +: 8];
                end
            end

            // etc.
            default: line1_in = pmem_rdata;
        endcase
        unique case (lru_out)
            1'b0: pmem_wdata = line0_out;
            1'b1: pmem_wdata = line1_out;

            // etc.
            default: pmem_wdata = line0_out;
        endcase
        unique case (addr_sel)
            1'b0: pmem_address = {mem_address[31:5], 5'b00000};
            1'b1: begin
                if (lru_out)
                    pmem_address = {tag1_out, mem_address[7:5], 5'b00000};
                else
                    pmem_address = {tag0_out, mem_address[7:5], 5'b00000};
            end
            default: pmem_address = {mem_address[31:5], 5'b00000};
        endcase
    end


endmodule : cache_datapath

module cache_cmp
(
    input logic [23:0] tag_in,
    input logic [23:0] tag0_out,
    input logic [23:0] tag1_out,
    output logic tag0_hit,
    output logic tag1_hit
);

    always_comb
    begin
        if (tag_in == tag0_out)
            tag0_hit = 1'b1;
        else
            tag0_hit = 1'b0;
        if (tag_in == tag1_out)
            tag1_hit = 1'b1;
        else
            tag1_hit = 1'b0;
    end
endmodule : cache_cmp