/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module cache_control (
    input logic clk,
    input logic rst,
    input logic mem_read,
    input logic mem_write,
    input logic tag0_hit,
    input logic tag1_hit,
    input logic valid0_out,
    input logic valid1_out,
    input logic pmem_resp,
    input logic lru_out,
    input logic dirty0_out,
    input logic dirty1_out,
    output logic datamux_sel,
    output logic load_lru,
    output logic lru_in,
    output logic pmem_read,
    output logic pmem_write,
    output logic [31:0] write_en0,
    output logic [31:0] write_en1,
    output logic load_tag0,
    output logic load_tag1,
    output logic load_valid0,
    output logic load_valid1,
    output logic valid_in,
    output logic mem_resp,
    output logic load_dirty0,
    output logic load_dirty1,
    output logic dirty_in,
    output logic line0_in_sel,
    output logic line1_in_sel,
    output logic addr_sel
);


enum int unsigned {
    /* List of states */
    start, load1, load2, write1, write2
} state, next_states;


function void set_defaults();
    datamux_sel = 1'b0;
    load_lru = 1'b0;
    lru_in = 1'b0;
    pmem_read = 1'b0;
    write_en0 = 32'b0;
    write_en1 = 32'b0;
    load_tag0 = 1'b0;
    load_tag1 = 1'b0;
    pmem_write = 1'b0;
    load_valid0 = 1'b0;
    load_valid1 = 1'b0;
    valid_in = 1'b0;
    mem_resp = 1'b0;
    load_dirty0 = 1'b0;
    load_dirty1 = 1'b0;
    dirty_in = 1'b0;
    line0_in_sel = 1'b0;
    line1_in_sel = 1'b0;
    addr_sel = 1'b0;
endfunction

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)

        start:;
        load1: begin
            if (tag0_hit & valid0_out) begin
                mem_resp = 1'b1;
                datamux_sel = 1'b0;
                load_lru = 1'b1;
                lru_in = 1'b1;

            end
            else if (tag1_hit & valid1_out) begin
                mem_resp = 1'b1;
                datamux_sel = 1'b1;
                load_lru = 1'b1;
                lru_in = 1'b0;
            end

        end
        load2: begin
            if (!pmem_resp)
                pmem_read = 1'b1;
            else begin
                if (lru_out) begin
                    write_en1 = {32{1'b1}};
                    line1_in_sel = 1'b0;
                    load_tag1 = 1'b1;
                    load_valid1 = 1'b1;
                    valid_in = 1'b1;
                end
                else begin
                    write_en0 = {32{1'b1}};
                    line0_in_sel = 1'b0;
                    load_tag0 = 1'b1;
                    load_valid0 = 1'b1;
                    valid_in = 1'b1;
                end
            end

        end
        //temp

        write1: begin
            // if (!pmem_resp)
            //     pmem_write = 1'b1;
            // else
            //     mem_resp = 1'b1;
            if (tag0_hit & valid0_out) begin
                mem_resp = 1'b1;
                load_lru = 1'b1;
                lru_in = 1'b1;
                load_dirty0 = 1'b1;
                dirty_in = 1'b1;
                line0_in_sel = 1'b1;
                write_en0 = {32{1'b1}};
            end
            else if (tag1_hit & valid1_out) begin
                mem_resp = 1'b1;
                load_lru = 1'b1;
                lru_in = 1'b0;
                load_dirty1 = 1'b1;
                dirty_in = 1'b1;
                line1_in_sel = 1'b1;
                write_en1 = {32{1'b1}};
            end

            
        end
        //temp
        write2: begin
            addr_sel = 1'b1;
            if (!pmem_resp) 
                pmem_write = 1'b1;
            else begin
                if (lru_out) begin
                    load_dirty1 = 1'b1;
                    dirty_in = 1'b0;
                end
                else begin
                    load_dirty0 = 1'b1;
                    dirty_in = 1'b0;
                end
            end



            
        end

    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    unique case (state)

        start: begin
            if (mem_read)
                next_states = load1;
            else if (mem_write)
                next_states = write1;
            else 
                next_states = start;
        end
        load1: begin
            if ((tag0_hit & valid0_out) | (tag1_hit & valid1_out))
                next_states = start;
            else if ((lru_out & dirty1_out) | ((~lru_out) & dirty0_out))
                next_states = write2;
            else
                next_states = load2;
        end
        load2: begin
            if (pmem_resp)
                next_states = start;
            else
                next_states = load2;
        end
        //temp
        write1: begin
            // if (pmem_resp)
            //     next_states = start;
            // else
            //     next_states = write1;
            if ((tag0_hit & valid0_out) | (tag1_hit & valid1_out))
                next_states = start;
            else if ((lru_out & dirty1_out) | ((~lru_out) & dirty0_out))
                next_states = write2;
            else
                next_states = load2;
        end
        //temp
        write2: begin
            if (pmem_resp)
                next_states = start;
            else
                next_states = write2;
        end

        default: next_states = start;
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst) begin
        state <= start;
    end
    else begin
        state <= next_states;
    end
end

endmodule : cache_control
