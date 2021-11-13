/* DO NOT MODIFY. WILL BE OVERRIDDEN BY THE AUTOGRADER.
A module to help your CPU (which likes to deal with 4 bytes
at a time) talk to your cache (which likes to deal with 32
bytes at a time).*/

module bus_adapter #(
    parameter s_offset = 4,
    parameter size = (2**s_offset)*8 //cacheline size
)
(
    output [size-1:0] mem_wdata256,
    input [size-1:0] mem_rdata256,
    input [31:0] mem_wdata,
    output [31:0] mem_rdata,
    input [3:0] mem_byte_enable,
    output logic [(2**s_offset-1):0] mem_byte_enable256,
    input [31:0] address
);
localparam num_sets = 2**(s_offset-2);

assign mem_wdata256 = {num_sets{mem_wdata}};
assign mem_rdata = mem_rdata256[(32*address[s_offset-1:2]) +: 32];
logic [(2**s_offset-5):0] zeros = '0;
assign mem_byte_enable256 = {zeros, mem_byte_enable} << (address[s_offset-1:2]*4);

endmodule : bus_adapter
