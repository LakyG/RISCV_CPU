module divider(
    input clk,
    input rst,
    input logic start,
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] q,
    output logic [31:0] r,
    output logic done
);


logic [63:0] RQ;
logic [6:0] count;
logic started;


task divide;
    if (count > 0) begin
        if (RQ[63]) begin
            RQ = RQ << 1;
            RQ[63:32] = RQ[63:32] + {1'b0, b[30:0]};

        end
        else begin
            RQ = RQ << 1;
            RQ[63:32] = RQ[63:32] - {1'b0, b[30:0]};
        end
        if (RQ[63]) begin
            RQ[0] = 1'b0;
        end
        else begin
            RQ[0] = 1'b1;
        end
        
        count = count - 1;
    end 
endtask

always_ff @(posedge clk) begin
    if (rst) begin
        count = 6'd32;
        done = 0;
        RQ[63:32] = '0;
        RQ[31:0] = '0;
        started = 1'b0;
    end
    else if (start & (~started) & (~done)) begin
        count = 6'd32;
        done = 0;
        RQ[63:32] = '0;
        RQ[31:0] = a;
        started = 1'b1;
    end
    else if (started) begin
        if (count > 0) begin
            divide();
            divide();
            divide();
            divide();
            // divide();
            // divide();
            // divide();
            // divide();
        end
        else begin
            done = 1;
            q = RQ[31:0];
            r = RQ[63] ? RQ[63:32]+{1'b0, b[30:0]} : RQ[63:32];
            started = 1'b0;
        end

    end
    else 
        done = 1'b0;
end

endmodule