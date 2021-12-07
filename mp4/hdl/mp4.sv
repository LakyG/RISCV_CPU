import rv32i_types::*;
import control_word::*;

module mp4 #(
    parameter s_offset = 5,
    parameter size = (2**s_offset)*8,   // Cacheline size (bits)

    parameter i_s_index = 5,            // 2^i_s_index number of I-Cache sets
    parameter i_num_ways = 4,           // I-Cache Associativity
    parameter d_s_index = 5,            // 2^d_s_indix number of D-Cache sets
    parameter d_num_ways = 4,           // D-Cache Associativity
    
    parameter predict_s_index = 7,      // Number of sets in Branch Predicitor (BPT and BTB)
    parameter predict_g_history = 7     // Number of bits for the Global History Register
)
(
    input clk,
    input rst,

    // I Cache Ports
    // output logic imem_read,
    // output logic [31:0] imem_address,
    
    // input logic imem_resp,
    // input logic [31:0] imem_rdata,

    // // D Cache Ports
    // output logic dmem_read,
    // output logic dmem_write,
    // output logic [3:0] dmem_byte_enable,
    // output logic [31:0] dmem_address,
    // output logic [31:0] dmem_wdata,

    // input logic dmem_resp,
    // input logic [31:0] dmem_rdata
    input pmem_resp,
    input [63:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output rv32i_word pmem_address,
    output [63:0] pmem_wdata
);

cpu # (.predict_s_index(predict_s_index), .predict_g_history(predict_g_history)) cpu (.*);

//icache
logic imem_read;
logic [31:0] imem_address;
logic imem_resp;
logic [31:0] imem_rdata;
logic [31:0] imem_wdata;
rv32i_word i_pmem_address;
logic i_pmem_read;
logic i_pmem_write;
logic [size-1:0] i_pmem_wdata;
logic [size-1:0] i_pmem_rdata;
logic [3:0] imem_byte_enable;
logic i_pmem_resp;
logic [31:0] ishadow_address;

cache #(.s_offset(s_offset), .s_index(i_s_index), .num_ways(i_num_ways)) icache(
    .*,
    // .mem_address(imem_address),
    // .mem_wdata('0),
    // .mem_read(imem_read),
    // .mem_write('0),
    // .pmem_rdata(i_pmem_rdata),
    // .pmem_resp(i_pmem_resp),
    // .mem_byte_enable('0),
    // .pmem_address(i_pmem_address),
    // .pmem_read(i_pmem_read),
    // .pmem_write('0),
    // .mem_resp(imem_resp),
    // .mem_rdata(imem_rdata),
    // .pmem_wdata('0)

    // From CPU
    .mem_read(imem_read),
    .mem_write('0),
    .mem_byte_enable('0),
    .mem_address(imem_address),
    .mem_wdata('0),
    // To CPU
    .mem_resp(imem_resp),
    .mem_rdata(imem_rdata),
    // FROM RAM
    .line_o(i_pmem_rdata),
    .resp_o(i_pmem_resp),
    // TO RAM
    .line_i(),
    .address_i(i_pmem_address),
    .read_i(i_pmem_read),
    .write_i(),
    .shadow_address(ishadow_address)
);

//dcache
logic dmem_read;
logic dmem_write;
logic [31:0] dmem_address;
logic dmem_resp;
logic [31:0] dmem_rdata;
logic [31:0] dmem_wdata;
rv32i_word d_pmem_address_L1;
logic d_pmem_read_L1;
logic d_pmem_write_L1;
logic [size-1:0] d_pmem_wdata_L1;
logic [size-1:0] d_pmem_rdata_L1;
logic [3:0] dmem_byte_enable;
logic d_pmem_resp_L1;
logic [31:0] dshadow_address, dshadow_address2;

cache #(.s_offset(s_offset), .s_index(d_s_index), .num_ways(d_num_ways)) dcache(
    .*,
    // .mem_address(dmem_address),
    // .mem_wdata(dmem_wdata),
    // .mem_read(dmem_read),
    // .mem_write(dmem_write),
    // .pmem_rdata(d_pmem_rdata),
    // .pmem_resp(d_pmem_resp),
    // .mem_byte_enable(dmem_byte_enable),
    // .pmem_address(d_pmem_address),
    // .pmem_read(d_pmem_read),
    // .pmem_write(d_pmem_write),
    // .mem_resp(dmem_resp),
    // .mem_rdata(dmem_rdata),
    // .pmem_wdata(d_pmem_wdata)

    // From CPU
    .mem_read(dmem_read),
    .mem_write(dmem_write),
    .mem_byte_enable(dmem_byte_enable),
    .mem_address(dmem_address),
    .mem_wdata(dmem_wdata),
    // To CPU
    .mem_resp(dmem_resp),
    .mem_rdata(dmem_rdata),
    // FROM RAM
    .line_o(d_pmem_rdata_L1),
    .resp_o(d_pmem_resp_L1),
    // TO RAM
    .line_i(d_pmem_wdata_L1),
    .address_i(d_pmem_address_L1),
    .read_i(d_pmem_read_L1),
    .write_i(d_pmem_write_L1),
    .shadow_address(dshadow_address)
);

//l2 dcache
rv32i_word d_pmem_address;
logic d_pmem_read;
logic d_pmem_write;
logic [size-1:0] d_pmem_wdata;
logic [size-1:0] d_pmem_rdata;
logic d_pmem_resp;
logic [3:0] l2dmem_byte_enable;


//comment this out if using L2 cache
assign d_pmem_address = d_pmem_address_L1;
assign d_pmem_read = d_pmem_read_L1;
assign d_pmem_write = d_pmem_write_L1;
assign d_pmem_wdata = d_pmem_wdata_L1;
assign d_pmem_rdata_L1 = d_pmem_rdata;
assign d_pmem_resp_L1 = d_pmem_resp;

// cache #(.s_offset(s_offset), .s_index(5), .num_ways(d_num_ways), .input_size(256)) l2dcache(
//     .*,

//     // From l1cache
//     .mem_read(d_pmem_read_L1),
//     .mem_write(d_pmem_write_L1),
//     .mem_byte_enable(l2dmem_byte_enable),
//     .mem_address(d_pmem_address_L1),
//     .mem_wdata(d_pmem_wdata_L1),
//     // To l1cache
//     .mem_resp(d_pmem_resp_L1),
//     .mem_rdata(d_pmem_rdata_L1),
//     // FROM RAM
//     .line_o(d_pmem_rdata),
//     .resp_o(d_pmem_resp),
//     // TO RAM
//     .line_i(d_pmem_wdata),
//     .address_i(d_pmem_address),
//     .read_i(d_pmem_read),
//     .write_i(d_pmem_write),
//     .shadow_address(dshadow_address2)
// );
logic [size-1:0] pmem_wdata_c;
logic [size-1:0] pmem_rdata_c;
logic [31:0] pmem_address_c;
logic pmem_read_c;
logic pmem_write_c;
logic pmem_resp_c;


arbiter #(.s_offset(s_offset)) arbiter(.*);

cacheline_adaptor #(.s_offset(s_offset)) cacheline_adaptor
(
    .*,
    .reset_n(~rst),
    .line_i(pmem_wdata_c),
    .line_o(pmem_rdata_c),
    .address_i(pmem_address_c),
    .read_i(pmem_read_c),
    .write_i(pmem_write_c),
    .resp_o(pmem_resp_c),
    .burst_i(pmem_rdata),
    .burst_o(pmem_wdata),
    .address_o(pmem_address),
    .read_o(pmem_read),
    .write_o(pmem_write),
    .resp_i(pmem_resp)
);

endmodule : mp4
