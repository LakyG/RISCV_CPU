import rv32i_types::*;
import datapath_mux_types::*;

module local_prediction_table #(
    parameter s_index = 7   // Number of bits used to index
)
(
    input clk,
    input rst,

    input logic predict_en,
    input rv32i_word curr_pc,
    input rv32i_word resolved_pc,
    input logic predictionFailed,

    output predictmux_t predicted_direction
);

    localparam addr_start = 2;
    localparam num_sets = 2**s_index;

    typedef enum bit [1:0] {STRONG_N_TAKE, N_TAKE, TAKE, STRONG_TAKE} state_t;

    state_t state [num_sets-1:0];
    state_t next_state [num_sets-1:0];

    logic [s_index-1:0] curr_index;
    logic [s_index-1:0] resolved_index; 

    assign curr_index = curr_pc[addr_start +: s_index];
    assign resolved_index = resolved_pc[addr_start +: s_index];

    // Get the predicted direction based on the current state
    always_comb begin
        unique case (state_t'(state[curr_index]))
            STRONG_N_TAKE,
            N_TAKE:        predicted_direction = datapath_mux_types::nottaken;
            TAKE,
            STRONG_TAKE:   predicted_direction = datapath_mux_types::taken;
            default:       predicted_direction = datapath_mux_types::nottaken;
        endcase
    end

    always_ff @ (posedge clk, posedge rst) begin
        if (rst) begin
            for (int i = 0; i < num_sets; i++) begin
                state[i] <= N_TAKE;
            end
        end
        else if (predict_en) begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;

        case (state_t'(state[resolved_index]))
            STRONG_N_TAKE: begin
                if (predictionFailed) next_state[resolved_index] = N_TAKE;
                else                  next_state[resolved_index] = STRONG_N_TAKE;
            end
            N_TAKE: begin
                if (predictionFailed) next_state[resolved_index] = TAKE;
                else                  next_state[resolved_index] = STRONG_N_TAKE;
            end
            TAKE: begin
                if (predictionFailed) next_state[resolved_index] = N_TAKE;
                else                  next_state[resolved_index] = STRONG_TAKE;
            end
            STRONG_TAKE: begin
                if (predictionFailed) next_state[resolved_index] = TAKE;
                else                  next_state[resolved_index] = STRONG_TAKE;
            end
        endcase
    end

endmodule : local_prediction_table