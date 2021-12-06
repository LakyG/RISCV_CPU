import rv32i_types::*;
import datapath_mux_types::*;

module local_prediction_table #(
    parameter s_index = 7   // Number of bits used to index
)
(
    input clk,
    //input rst,

    input logic predict_en,
    input rv32i_word curr_pc,
    input rv32i_word resolved_pc,
    input logic predictionFailed,

    output predictmux_t predicted_direction
);

    localparam addr_start = 2;
    localparam num_sets = 2**s_index;

    typedef enum bit [1:0] {N_TAKE='0, STRONG_N_TAKE, TAKE, STRONG_TAKE} state_t;

    state_t state [num_sets-1:0];
    state_t next_state [num_sets-1:0];

    logic [s_index-1:0] curr_index;
    logic [s_index-1:0] resolved_index; 

    // logic [1:0] curr_state;
    // logic [1:0] resolved_state;
    // state_t new_state;

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
    // always_comb begin
    //     unique case (state_t'(curr_state))
    //         STRONG_N_TAKE,
    //         N_TAKE:        predicted_direction = datapath_mux_types::nottaken;
    //         TAKE,
    //         STRONG_TAKE:   predicted_direction = datapath_mux_types::taken;
    //         default:       predicted_direction = datapath_mux_types::nottaken;
    //     endcase
    // end

    always_ff @ (posedge clk/*, posedge rst*/) begin
        /*
        if (rst) begin
            for (int i = 0; i < num_sets; i++) begin
                state[i] <= N_TAKE;
            end
        end
        else */if (predict_en) begin
            state <= next_state;
        end
    end

    // TODO: instead of passing the PC from the IF stage, need to pass next_pc because
    //the BTB and BPT now take 1 cycle. Do this for BTB as well.
    // always_comb begin
    //     case (state_t'(resolved_state))
    //         STRONG_N_TAKE: begin
    //             if (predictionFailed) new_state = N_TAKE;
    //             else                  new_state = STRONG_N_TAKE;
    //         end
    //         N_TAKE: begin
    //             if (predictionFailed) new_state = TAKE;
    //             else                  new_state = STRONG_N_TAKE;
    //         end
    //         TAKE: begin
    //             if (predictionFailed) new_state = N_TAKE;
    //             else                  new_state = STRONG_TAKE;
    //         end
    //         STRONG_TAKE: begin
    //             if (predictionFailed) new_state = TAKE;
    //             else                  new_state = STRONG_TAKE;
    //         end
    //         default: new_state = N_TAKE;
    //     endcase
    // end

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

    // generate
    //     case (s_index)
    //         6: begin
                
    //         end
    //         7: begin
    //             BRAM_128x2bitBPT dir (
    //                 // .clock(clk),
    //                 // .data(new_state),
    //                 // .rdaddress(curr_index),
    //                 // .wraddress(resolved_index),
    //                 // .wren(predict_en),
    //                 // .q(curr_state)

    //                 .address_a(curr_index),
    //                 .address_b(resolved_index),
    //                 .clock(clk),
    //                 .data_a('0),
    //                 .data_b(new_state),
    //                 .wren_a('0),
    //                 .wren_b(predict_en),
    //                 .q_a(curr_state),
    //                 .q_b(resolved_state)
    //             );
    //         end
    //         8: begin
                
    //         end
    //         9: begin
                
    //         end
    //         default: begin
    //         end
    //     endcase
    // endgenerate

endmodule : local_prediction_table