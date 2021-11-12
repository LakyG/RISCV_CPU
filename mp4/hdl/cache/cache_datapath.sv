/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

import cache_types::*;

module cache_datapath #(
    parameter s_offset = 5,
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
    
    // Inputs
    // CPU
    input mem_write,
    input mem_read,
    input logic [s_mask-1:0] mem_address,
    input logic [s_line-1:0] mem_wdata256,
    input logic [s_mask-1:0] mem_byte_enable256,
    // Controller
    input write_data_sel_t write_data_sel,
    input load,
    input write_en_sel_t write_en_sel,
    input valid_in,
    input dirty_in,
    input lru_load,
    input ram_addr_sel_t ram_addr_sel,
    // RAM
    input logic [s_line-1:0] ram_line_o,

    // Outputs
    // CPU
    output logic [s_line-1:0] mem_rdata256,
    // Controller
    output logic hit_out,
    output logic [num_ways-1:0] dirty_out,
    output logic [num_ways-1:0] lru,
    // RAM
    output logic [s_line-1:0] ram_line_i,
    output logic [s_mask-1:0] ram_address_i
);

    // Internal Signals
    logic [num_ways-1:0] valid;
    logic [num_ways-1:0][s_tag-1:0] tag;
    logic [num_ways-1:0][s_line-1:0] block;
    logic [num_ways-1:0] hit;
    //logic hit0, hit1;

    logic [31:0] write_en;

    logic [width-1:0] block_sel;

    logic dirty_val;
    logic valid_val;
    logic [num_ways-1:0][s_mask-1:0] write_val;
    logic [num_ways-1:0] load_val;

    logic [s_line-1:0] write_data;

    logic read;

    logic [s_index-1:0] index;
    logic [s_tag-1:0] tag_in;

    logic [width-1:0] latest_block;
    logic lru_val;



    //------------------ Array Module Instantiations ------------------//
    genvar j;
    generate
        for (j = 0; j < num_ways; j++) begin : MODULES
            array VALID (
                .clk(clk),
                .rst(rst),
                .read(read),
                .load(load_val[j]),
                .rindex(index),
                .windex(index),
                .datain(valid_val),
                .dataout(valid[j])
            );
            array DIRTY (
                .clk(clk),
                .rst(rst),
                .read(read),
                .load(load_val[j]),
                .rindex(index),
                .windex(index),
                .datain(dirty_val),
                .dataout(dirty_out[j])
            );
            array #(.width(s_tag)) TAG (
                .clk(clk),
                .rst(rst),
                .read(read),
                .load(load_val[j]),
                .rindex(index),
                .windex(index),
                .datain(tag_in),
                .dataout(tag[j])
            );
            data_array DATA0 (
                .clk(clk),
                .rst(rst),
                .read(read),
                .write_en(write_val[j]),
                .rindex(index),
                .windex(index),
                .datain(write_data),
                .dataout(block[j])
            );
        end

    endgenerate
    lru LRU (
        .clk(clk),
        .rst(rst),
        .read(read),
        .load(lru_load),
        .rindex(index),
        .windex(index),
        .hit_ways(latest_block),
        .evict_ways(lru)
    );
    // // Way-0
    // array VALID0 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .load(load_val0),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(valid_val0),
    //     .dataout(valid0)
    // );
    // array DIRTY0 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .load(load_val0),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(dirty_val0),
    //     .dataout(dirty0)
    // );
    // array #(.width(s_tag)) TAG0 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .load(load_val0),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(tag),
    //     .dataout(tag0)
    // );
    // data_array DATA0 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .write_en(write_val0),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(write_data),
    //     .dataout(block0)
    // );
    // // Way-1
    // array VALID1 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .load(load_val1),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(valid_val1),
    //     .dataout(valid1)
    // );
    // array DIRTY1 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .load(load_val1),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(dirty_val1),
    //     .dataout(dirty1)
    // );
    // array #(.width(s_tag)) TAG1 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .load(load_val1),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(tag),
    //     .dataout(tag1)
    // );
    // data_array DATA1 (
    //     .clk(clk),
    //     .rst(rst),
    //     .read(read),
    //     .write_en(write_val1),
    //     .rindex(index),
    //     .windex(index),
    //     .datain(write_data),
    //     .dataout(block1)
    // );
    /*
    BRAM_1bit LRU (
        .address(index),
        .clock(clk),
        .data(lru_val),
        .rden(read),
        .wren(lru_load),
        .q(lru)
    );
    // Way-0
    BRAM_1bit VALID0 (
        .address(index),
        .clock(clk),
        .data(valid_val0),
        .rden(read),
        .wren(load_val0),
        .q(valid0)
    );
    BRAM_1bit DIRTY0 (
        .address(index),
        .clock(clk),
        .data(dirty_val0),
        .rden(read),
        .wren(load_val0),
        .q(dirty0)
    );
    BRAM_24bit TAG0 (
        .address(index),
        .clock(clk),
        .data(tag),
        .rden(read),
        .wren(load_val0),
        .q(tag0)
    );
    BRAM_data_256bit DATA0 (
        .address(index),
        .byteena(write_val0),
        .clock(clk),
        .data(write_data),
        .rden(read),
        .wren(|write_val0),
        .q(block0)
    );
    // Way-1
    BRAM_1bit VALID1 (
        .address(index),
        .clock(clk),
        .data(valid_val1),
        .rden(read),
        .wren(load_val1),
        .q(valid1)
    );
    BRAM_1bit DIRTY1 (
        .address(index),
        .clock(clk),
        .data(dirty_val1),
        .rden(read),
        .wren(load_val1),
        .q(dirty1)
    );
    BRAM_24bit TAG1 (
        .address(index),
        .clock(clk),
        .data(tag),
        .rden(read),
        .wren(load_val1),
        .q(tag1)
    );
    BRAM_data_256bit DATA1 (
        .address(index),
        .byteena(write_val1),
        .clock(clk),
        .data(write_data),
        .rden(read),
        .wren(|write_val1),
        .q(block1)
    );
    */

    //------------------ Datapath Logic ------------------//
    assign index = mem_address[s_offset +: s_index];
    assign tag_in = mem_address[s_offset+s_index +: s_tag];

    assign read = mem_read | mem_write;

    // assign hit[0] = valid0 & (tag_in == tag[0]);
    // assign hit[1] = valid1 & (tag_in == tag[1]);

    always_comb begin : HIT_SELECT
        hit_out = hit ? 1 : 0;
        latest_block = 0;
        for (int i = 0; i < num_ways; i++) begin
            hit[i] = valid[i] & (tag_in == tag[i]);
            if (hit[i])
                latest_block = i;
        end
        
        
        // case ({hit1, hit0})
        //     2'b00: latest_block = 0;
        //     2'b01: latest_block = 0;
        //     2'b10: latest_block = 1;
        //     2'b11: latest_block = 'x;
        // endcase
    end

    assign lru_val = ~latest_block;

    //------------------ Muxes and Demux ------------------//
    always_comb begin : WRITE_ENABLE_SELECT
        case (write_en_sel)
            ALL_DIS: write_en = '0;
            ALL_EN:  write_en = '1;
            CPU_EN:  write_en = mem_byte_enable256;
        endcase
    end

    always_comb begin : DEMUXES
        dirty_val = dirty_in;
        valid_val = valid_in;
        for (int i = 0; i < num_ways; i++) begin
            if (i == block_sel) begin
                write_val[i] = write_en;
                load_val[i] = load;
            end
            else begin
                write_val[i] = '0;
                load_val[i] = 0;
            end
        end
        

        // case (block_sel)
        //     0: begin
        //         dirty_val0 = dirty;
        //         dirty_val1 = 0;
        //         valid_val0 = valid;
        //         valid_val1 = 0;
        //         write_val0 = write_en;
        //         write_val1 = '0;
        //         load_val0  = load;
        //         load_val1  = 0;
        //     end
        //     1: begin
        //         dirty_val0 = 0;
        //         dirty_val1 = dirty;
        //         valid_val0 = 0;
        //         valid_val1 = valid;
        //         write_val0 = '0;
        //         write_val1 = write_en;
        //         load_val0  = 0;
        //         load_val1  = load;
        //     end
        //     default: begin
        //         dirty_val0 = 'x;
        //         dirty_val1 = 'x;
        //         valid_val0 = 'x;
        //         valid_val1 = 'x;
        //         write_val0 = 'x;
        //         write_val1 = 'x;
        //         load_val0  = 'x;
        //         load_val1  = 'x;
        //     end
        // endcase
    end

    always_comb begin : WRITE_DATA_SELECT
        case (write_data_sel)
            CPU_DATA: write_data = mem_wdata256;
            RAM_DATA: write_data = ram_line_o;
        endcase
    end

    always_comb begin : RAM_ADDR_SELECT
        case (ram_addr_sel)
            CPU_ADDR:    ram_address_i = {mem_address[31:5], 5'b0};
            TAG_ADDR: begin
                ram_address_i = {tag[lru], index, 5'b0};
            end
        endcase
    end

    always_comb begin : READ_BLOCK_SELECT
        mem_rdata256 = block[latest_block];
    end

    always_comb begin : DATA_BLOCK_SELECT
        ram_line_i = block[lru];
    end

    always_comb begin : BLOCK_SELECT
        if (hit_out) block_sel = latest_block;
        else     block_sel = lru;
    end

endmodule : cache_datapath
