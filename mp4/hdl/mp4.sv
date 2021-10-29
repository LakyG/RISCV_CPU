import rv32i_types::*;
import control_word::*;

module mp4(
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
logic [255:0] i_pmem_wdata;
logic [255:0] i_pmem_rdata;
logic [3:0] imem_byte_enable;
logic i_pmem_resp;
//TODO: After implementing the caches, adapters and the arbiter, add them here
cache icache (
    .*,
    .mem_address(imem_address),
    .mem_wdata(imem_wdata),
    .mem_read(imem_read),
    .mem_write(imem_write),
    .pmem_rdata(i_pmem_rdata),
    .pmem_resp(i_pmem_resp),
    .mem_byte_enable(imem_byte_enable),
    .pmem_address(i_pmem_address),
    .pmem_read(i_pmem_read),
    .pmem_write(i_pmem_write),
    .mem_resp(imem_resp),
    .mem_rdata(imem_rdata),
    .pmem_wdata(i_pmem_wdata)

);
//dcache
logic dmem_read;
logic [31:0] dmem_address;
logic dmem_resp;
logic [31:0] dmem_rdata;
logic [31:0] dmem_wdata;
rv32i_word d_pmem_address;
logic d_pmem_read;
logic d_pmem_write;
logic [255:0] d_pmem_wdata;
logic [255:0] d_pmem_rdata;
logic [3:0] dmem_byte_enable;
logic d_pmem_resp;
//TODO: After implementing the caches, adapters and the arbiter, add them here
cache dcache (
    .*,
    .mem_address(dmem_address),
    .mem_wdata(dmem_wdata),
    .mem_read(dmem_read),
    .mem_write(dmem_write),
    .pmem_rdata(d_pmem_rdata),
    .pmem_resp(d_pmem_resp),
    .mem_byte_enable(dmem_byte_enable),
    .pmem_address(d_pmem_address),
    .pmem_read(d_pmem_read),
    .pmem_write(d_pmem_write),
    .mem_resp(dmem_resp),
    .mem_rdata(dmem_rdata),
    .pmem_wdata(d_pmem_wdata)

);

//arbiter arbiter();
//cacheline_adpater cacheline_adapter();

endmodule : mp4
