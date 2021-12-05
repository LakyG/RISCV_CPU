/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

import cache_types::*;

module cache_datapath #(
    parameter s_offset = 4,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index, //24
    parameter s_mask   = 2**s_offset, //32
    parameter s_line   = 8*s_mask, //256
    parameter num_sets = 2**s_index, //8
    parameter num_ways = 2,
    parameter width = $clog2(num_ways) //1 //log(num_ways)
)
(
    input clk,
    input rst,
    
    // Inputs
    // CPU
    input mem_write,
    input mem_read,
    input logic [31:0] mem_address,
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
    output logic [width-1:0] lru,
    // RAM
    output logic [s_line-1:0] ram_line_i,
    output logic [31:0] ram_address_i,
    output logic [31:0] mem_address_bus
);

    // Internal Signals
    logic [num_ways-1:0] valid;
    logic [num_ways-1:0][s_tag-1:0] tag;
    logic [num_ways-1:0][s_line-1:0] block;
    logic [num_ways-1:0] hit;

    logic [s_mask-1:0] write_en;

    logic [width-1:0] block_sel;

    logic dirty_val;
    logic valid_val;
    logic [num_ways-1:0][s_mask-1:0] write_val;
    logic [num_ways-1:0] load_val;

    logic [s_line-1:0] write_data;
    logic [s_line-1:0] mem_rdata256_in;
    logic [s_line-1:0] mem_wdata256_out;
    logic [s_mask-1:0] mem_byte_enable256_out;


    logic read;

    logic [s_index-1:0] index;
    logic [s_index-1:0] windex;
    logic [s_tag-1:0] tag_in;

    logic [width-1:0] latest_block;
    logic lru_val;

    //------------------ Array Module Instantiations ------------------//
    genvar j;
    
    generate
        case (s_index)
            3: begin
                for (j = 0; j < num_ways; j++) begin : MODULES
                    BRAM_8x1bit VALID (
                        .clock(clk),
                        .data(valid_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(valid[j])
                    );
                    BRAM_8x1bit DIRTY (
                        .clock(clk),
                        .data(dirty_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(dirty_out[j])
                    );
                    BRAM_8x24bitTag TAG (
                        .clock(clk),
                        .data(tag_in),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(tag[j])
                    );
                    BRAM_8x256bitData DATA (
                        .byteena_a(write_val[j]),
                        .clock(clk),
                        .data(write_data),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(|write_val[j]),
                        .q(block[j])
                    );
                end
            end
            4: begin
                for (j = 0; j < num_ways; j++) begin : MODULES
                    BRAM_16x1bit VALID (
                        .clock(clk),
                        .data(valid_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(valid[j])
                    );
                    BRAM_16x1bit DIRTY (
                        .clock(clk),
                        .data(dirty_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(dirty_out[j])
                    );
                    BRAM_16x23bitTag TAG (
                        .clock(clk),
                        .data(tag_in),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(tag[j])
                    );
                    BRAM_16x256bitData DATA (
                        .byteena_a(write_val[j]),
                        .clock(clk),
                        .data(write_data),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(|write_val[j]),
                        .q(block[j])
                    );
                end
            end
            5: begin
                for (j = 0; j < num_ways; j++) begin : MODULES
                    BRAM_32x1bit VALID (
                        .clock(clk),
                        .data(valid_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(valid[j])
                    );
                    BRAM_32x1bit DIRTY (
                        .clock(clk),
                        .data(dirty_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(dirty_out[j])
                    );
                    BRAM_32x22bitTag TAG (
                        .clock(clk),
                        .data(tag_in),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(tag[j])
                    );
                    BRAM_32x256bitData DATA (
                        .byteena_a(write_val[j]),
                        .clock(clk),
                        .data(write_data),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(|write_val[j]),
                        .q(block[j])
                    );
                end
            end
            6: begin
                for (j = 0; j < num_ways; j++) begin : MODULES
                    BRAM_64x1bit VALID (
                        .clock(clk),
                        .data(valid_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(valid[j])
                    );
                    BRAM_64x1bit DIRTY (
                        .clock(clk),
                        .data(dirty_val),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(dirty_out[j])
                    );
                    BRAM_64x21bitTag TAG (
                        .clock(clk),
                        .data(tag_in),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(load_val[j]),
                        .q(tag[j])
                    );
                    BRAM_64x256bitData DATA (
                        .byteena_a(write_val[j]),
                        .clock(clk),
                        .data(write_data),
                        .rdaddress(index),
                        .rden(read),
                        .wraddress(windex),
                        .wren(|write_val[j]),
                        .q(block[j])
                    );
                end
            end
            default: begin
                for (j = 0; j < num_ways; j++) begin : MODULES
                    array #(.s_index(s_index)) VALID (
                        .clk(clk),
                        .rst(rst),
                        .read(read),
                        .load(load_val[j]),
                        .rindex(index),
                        .windex(windex),
                        .datain(valid_val),
                        .dataout(valid[j])
                    );
                    array #(.s_index(s_index)) DIRTY (
                        .clk(clk),
                        .rst(rst),
                        .read(read),
                        .load(load_val[j]),
                        .rindex(index),
                        .windex(windex),
                        .datain(dirty_val),
                        .dataout(dirty_out[j])
                    );
                    array #(.width(s_tag), .s_index(s_index)) TAG (
                        .clk(clk),
                        .rst(rst),
                        .read(read),
                        .load(load_val[j]),
                        .rindex(index),
                        .windex(windex),
                        .datain(tag_in),
                        .dataout(tag[j])
                    );
                    data_array #(.s_offset(s_offset), .s_index(s_index)) DATA (
                        .clk(clk),
                        .rst(rst),
                        .read(read),
                        .write_en(write_val[j]),
                        .rindex(index),
                        .windex(windex),
                        .datain(write_data),
                        .dataout(block[j])
                    );
                end
            end
        endcase
    endgenerate

    lru #(.s_index(s_index), .num_ways(num_ways)) LRU (
        .clk(clk),
        .rst(rst),
        .read(read),
        .load(lru_load),
        .rindex(index),
        .windex(windex),
        .hit_ways(latest_block),
        .evict_ways(lru)
    );

    cache_reg cache_reg (
        .*,
        .load_reg(mem_read | mem_write),
        .mem_address_in(mem_address)
    );
    

    //------------------ Datapath Logic ------------------//
    assign index = mem_address[s_offset +: s_index];
    assign windex = mem_address_bus[s_offset +: s_index];
    assign tag_in = mem_address_bus[s_offset+s_index +: s_tag];

    assign read = mem_read | mem_write;


    assign hit_out = ~(hit == '0);

    always_comb begin : HIT_SELECT
        latest_block = 0;
        for (int i = 0; i < num_ways; i++) begin
            hit[i] = valid[i] & (tag_in == tag[i]);
            if (hit[i])
                latest_block = i;
        end
    end

    assign lru_val = ~latest_block;

    //------------------ Muxes and Demux ------------------//
    always_comb begin : WRITE_ENABLE_SELECT
        case (write_en_sel)
            ALL_DIS: write_en = '0;
            ALL_EN:  write_en = '1;
            CPU_EN:  write_en = mem_byte_enable256_out;
        endcase
    end

    always_comb begin : DEMUXES
        dirty_val = dirty_in;
        valid_val = valid_in;
        unique case (load)
            1'b1: begin
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
            end
            1'b0: begin
                write_val = '0;
                load_val = '0;
            end
            default: begin
                write_val = '0;
                load_val = '0;
            end
        endcase
    end

    always_comb begin : WRITE_DATA_SELECT
        case (write_data_sel)
            CPU_DATA: write_data = mem_wdata256_out;
            RAM_DATA: write_data = ram_line_o;
        endcase
    end

    logic [s_offset-1:0] zeros = '0;

    always_comb begin : RAM_ADDR_SELECT
        case (ram_addr_sel)
            CPU_ADDR:    ram_address_i = {mem_address[31:s_offset], zeros};
            TAG_ADDR: begin
                ram_address_i = {tag[lru], index, zeros};
            end
        endcase
    end

    always_comb begin : READ_BLOCK_SELECT
        mem_rdata256_in = block[latest_block];
    end

    always_comb begin : DATA_BLOCK_SELECT
        ram_line_i = block[lru];
    end

    always_comb begin : BLOCK_SELECT
        if (hit_out) block_sel = latest_block;
        else     block_sel = lru;
    end

endmodule : cache_datapath