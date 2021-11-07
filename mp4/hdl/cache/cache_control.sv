/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

import cache_types::*;

module cache_control (
    input clk,
    input rst,

    // Inputs
    // CPU
    input mem_read,
    input mem_write,
    // Cache Datapath
    input hit,
    input dirty0, dirty1,
    input lru,
    // RAM
    input ram_resp_o,

    // Outputs
    // CPU
    output logic mem_resp,
    // Cache Datapth
    output write_data_sel_t write_data_sel,      //Select mem_wdata256 or ram_line_o
    output logic load,
    output write_en_sel_t write_en_sel,        //Select mem_byte_enable256 or '1
    output logic valid,
    output logic dirty,
    output logic lru_load,
    output ram_addr_sel_t ram_addr_sel,        //Select mem_address or writeback_address
    // RAM
    output logic ram_read_i,
    output logic ram_write_i
);

// State Enum
typedef enum logic[2:0] { IDLE, LOOKUP, WRITEBACK, FETCH, READWRITE
} State;

State state, next_state;

always_ff @ (posedge clk, posedge rst) begin : FF_LOGIC
    if (rst) state <= IDLE;
    else     state <= next_state;
end

always_comb begin : NEXT_STATE_LOGIC
    next_state = state;

    case (state)
        IDLE: begin
            if (mem_read | mem_write)                  next_state = LOOKUP;
        end
        LOOKUP: begin
            if (hit)                                   next_state = IDLE;
            else if ((~lru & dirty0) | (lru & dirty1)) next_state = WRITEBACK;
            else                                       next_state = FETCH;
        end
        WRITEBACK: begin
            if (ram_resp_o)                            next_state = FETCH;
        end
        FETCH: begin
            if (ram_resp_o)                            next_state = READWRITE;
        end
        READWRITE: begin
            next_state = IDLE;
        end
        default: next_state = State'('x);
    endcase
end

always_comb begin : OUTPUT_LOGIC
    // Defaults
    mem_resp       = 0;
    load           = 0;
    write_data_sel = write_data_sel_t'(0);
    write_en_sel   = write_en_sel_t'(0);
    valid          = 0;
    dirty          = 0;
    lru_load       = 0;
    ram_addr_sel   = ram_addr_sel_t'(0);
    ram_read_i     = 0;
    ram_write_i    = 0;

    case (state)
        IDLE: begin
            // Defaults
        end
        LOOKUP: begin
            if (hit) begin
                mem_resp = 1;
                lru_load = 1;
                
                if (mem_write) begin
                    load           = 1;
                    write_data_sel = CPU_DATA;
                    write_en_sel   = CPU_EN;
                    valid          = 1;
                    dirty          = 1;
                end
            end
        end
        WRITEBACK: begin
            ram_addr_sel = TAG_ADDR;
            ram_write_i  = 1;
        end
        FETCH: begin
            load           = 1;
            write_data_sel = RAM_DATA;
            write_en_sel   = ALL_EN;
            valid          = 1;
            ram_read_i     = 1;
        end
        READWRITE: begin
            // TODO: HIT signal should be high here! (Check to make sure on waveforms and add assertion in TB)
            mem_resp = 1;
            lru_load = 1;

            if (mem_write) begin
                load           = 1;
                write_data_sel = CPU_DATA;
                write_en_sel   = CPU_EN;
                valid          = 1;
                dirty          = 1;
            end
        end
        default: begin
            mem_resp       = 'x;
            load           = 'x;
            write_data_sel = write_data_sel_t'('x);
            write_en_sel   = write_en_sel_t'('x);
            valid          = 'x;
            dirty          = 'x;
            lru_load       = 'x;
            ram_addr_sel   = ram_addr_sel_t'('x);
            ram_read_i     = 'x;
            ram_write_i    = 'x;
        end
    endcase
end

endmodule : cache_control
