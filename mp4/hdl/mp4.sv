import rv32i_types::*;
import control_word::*;

module mp4(
    input clk,
    input rst,

    // TODO: change the port sizes/widths here to match what is needed by the CACHELINE ADAPTER
    // I Cache Ports
    output logic imem_read,
    output logic [31:0] imem_address,
    
    input logic imem_resp,
    input logic [31:0] imem_rdata,

    // D Cache Ports
    output logic dmem_read,
    output logic dmem_write,
    output logic [3:0] dmem_byte_enable,
    output logic [31:0] dmem_address,
    output logic [31:0] dmem_wdata,

    input logic dmem_resp,
    input logic [31:0] dmem_rdata
);

cpu cpu (.*);

//TODO: After implementing the caches, adapters and the arbiter, add them here
//cache icache ();
//cache dcache ();

endmodule : mp4
