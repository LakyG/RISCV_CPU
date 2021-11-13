/* A register array to be used for tag arrays, LRU array, etc. */

module lru #(
    parameter s_index = 3, //number of index bits
    //parameter num_ways = 2, //number of ways
    parameter width = 1 //log(num_ways)
)
(
    clk,
    rst,
    read,
    load,
    rindex,
    windex,
    hit_ways,
    evict_ways
);



localparam num_sets = 2**s_index;
localparam num_ways = 2**width;

input clk;
input rst;
input read;
input load;
input [s_index-1:0] rindex;
input [s_index-1:0] windex;
input [width-1:0] hit_ways;
output logic [width-1:0] evict_ways;

logic [num_ways-2:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
//logic [width-1:0] _dataout;
logic [num_ways-2:0] datain;
logic [num_ways-2:0] rdataout;
logic [num_ways-2:0] wdataout;
//assign evict_ways = _dataout;

always_comb begin
    wdataout = data[windex];
    rdataout = data[rindex];
    datain = wdataout;
    //dataout = '0;
    evict_ways = '0;

    if (read) begin
        for (int i = 0; i < width; i++) begin
                automatic int index = i ? 2**i - 1 + evict_ways[width-i +: width-1] : 0;
                evict_ways[width-1-i] = rdataout[index];            
        end
    end
    if (load) begin
        for (int i = 0; i < width; i++) begin
                automatic int index = (2**i) - 1 + (hit_ways>>(width-i));
                datain[index] =~hit_ways[i];            
        end
    end
end

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
        // if (read)
        //     dataout <= (load  & (rindex == windex)) ? datain : data[rindex];

        if(load)
            data[windex] <= datain;
    end
end

endmodule : lru
