import rv32i_types::*;
import control_word::*;

module mp4 #(
    parameter s_offset = 5,
    parameter s_index = 4,
    parameter num_ways = 2,
    parameter size = (2**s_offset)*8 //cacheline size
)
(
    input clk,
    input rst,

    // TODO: change the port sizes/widths here to match what is needed by the CACHELINE ADAPTER
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

cpu cpu (.*);

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

cache #(.s_offset(s_offset)) icache(
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
rv32i_word d_pmem_address;
logic d_pmem_read;
logic d_pmem_write;
logic [size-1:0] d_pmem_wdata;
logic [size-1:0] d_pmem_rdata;
logic [3:0] dmem_byte_enable;
logic d_pmem_resp;
logic [31:0] dshadow_address;

cache #(.s_offset(s_offset), .s_index(s_index), .num_ways(num_ways)) dcache(
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
    .line_o(d_pmem_rdata),
    .resp_o(d_pmem_resp),
    // TO RAM
    .line_i(d_pmem_wdata),
    .address_i(d_pmem_address),
    .read_i(d_pmem_read),
    .write_i(d_pmem_write),
    .shadow_address(dshadow_address)
);

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
