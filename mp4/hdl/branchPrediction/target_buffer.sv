import rv32i_types::*;
import datapath_mux_types::*;

module target_buffer #(
    parameter s_index = 7   // Number of bits used to index
)
(
    input clk,
    //input rst,

    input logic predict_en,
    input rv32i_word curr_pc,
    input rv32i_word resolved_pc,
    input logic predictionFailed,
    input rv32i_word expected_next_pc,

    output rv32i_word predicted_target
);

    localparam addr_start = 2;
    localparam num_sets = 2**s_index;

    logic [s_index-1:0] curr_index;
    logic [s_index-1:0] resolved_index; 

    assign curr_index = curr_pc[addr_start +: s_index];
    assign resolved_index = resolved_pc[addr_start +: s_index];

    /*
    // TODO: Create new BRAM for BTB that have a RST signal
    generate
        case (s_index)
            6: begin
                BRAM_64x32bitBTB targets (
                    .clock(clk),
                    .data(expected_next_pc),
                    .rdaddress(curr_index),
                    .wraddress(resolved_index),
                    .wren(predictionFailed),
                    .q(predicted_target)
                );
            end
            7: begin
                BRAM_128x32bitBTB targets (
                    .clock(clk),
                    .data(expected_next_pc),
                    .rdaddress(curr_index),
                    .wraddress(resolved_index),
                    .wren(predictionFailed),
                    .q(predicted_target)
                );
            end
            8: begin
                BRAM_256x32bitBTB targets (
                    .clock(clk),
                    .data(expected_next_pc),
                    .rdaddress(curr_index),
                    .wraddress(resolved_index),
                    .wren(predictionFailed),
                    .q(predicted_target)
                );
            end
            9: begin
                BRAM_512x32bitBTB targets (
                    .clock(clk),
                    .data(expected_next_pc),
                    .rdaddress(curr_index),
                    .wraddress(resolved_index),
                    .wren(predictionFailed),
                    .q(predicted_target)
                );
            end
            default: begin
    */
                rv32i_word targets [num_sets-1:0];
                rv32i_word next_targets [num_sets-1:0];

                assign predicted_target = targets[curr_index];

                always_ff @(posedge clk/*, posedge rst*/) begin
                    /*
                    if (rst) begin
                        for (int i = 0; i < num_sets; i++) begin
                            targets[i] <= '0;
                        end
                    end
                    else */if (predict_en) begin
                        targets <= next_targets;
                    end
                end

                always_comb begin
                    next_targets = targets;

                    if (predictionFailed) begin
                        next_targets[resolved_index] = expected_next_pc;
                    end
                end
    /*
            end
        endcase
    endgenerate
    */

endmodule : target_buffer