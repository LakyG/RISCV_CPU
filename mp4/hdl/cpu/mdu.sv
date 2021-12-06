import rv32i_types::*;

module mdu
(
    input clk,
    input rst,
    input logic start,
    input logic [2:0] funct3,
    input logic [31:0] a, b,
    output logic [31:0] f,
    output logic done
);

muldiv_funct3_t op;
assign op = muldiv_funct3_t'(funct3);

logic [63:0] product;
logic [31:0] quotient;
logic [63:0] f_temp;
logic sign;
logic [31:0] unsigned_a, unsigned_b;
assign unsigned_a = a[31] ? (~a) + 1 : a;
assign unsigned_b = b[31] ? (~b) + 1 : b;

logic [31:0] mult_a, mult_b;
logic mult_start, mult_done;
multiplier mult(
    .clk,
    .rst,
    .start(mult_start),
    .A(mult_a),
    .B(mult_b),
    .M(product),
    .done(mult_done)
);

logic div_start, div_done;
logic [31:0] div_a, div_b, q, r;


divider d(
    .clk,
    .rst,
    .start(div_start),
    .a(div_a),
    .b(div_b),
    .q,
    .r,
    .done(div_done)
);

always_comb
begin
    //product = '0;
    quotient = '0;
    f_temp = '0;
    sign = '0;
    mult_a = a;
    mult_b = b;
    div_a = a;
    div_b = b;
    done = 1'b1;
    div_start = 1'b0;
    mult_start = 1'b0;
    f = '0;
    unique case (op)
        mul:  begin
            sign = a[31] ^ b[31];
            mult_a = unsigned_a;
            mult_b = unsigned_b;
            if (start) begin
                mult_start = 1'b1;
                done = 1'b0;
                if (mult_done) begin
                    f_temp = sign ? (~product) + 1 : product;
                    f = f_temp[31:0];
                    done = 1'b1;
                end
            end
            
        end
        mulh:  begin
            sign = a[31] ^ b[31];
            mult_a = unsigned_a;
            mult_b = unsigned_b;
            if (start) begin
                mult_start = 1'b1;
                done = 1'b0;
                if (mult_done) begin
                    f_temp = sign ? (~product) + 1 : product;
                    f = f_temp[63:32];
                    done = 1'b1;
                end
            end
        
        end
        mulhsu:  begin
            sign = a[31];
            mult_a = unsigned_a;
            mult_b = b;
            if (start) begin
                mult_start = 1'b1;
                done = 1'b0;
                if (mult_done) begin
                    f_temp = sign ? (~product) + 1 : product;
                    f = f_temp[63:32];
                    done = 1'b1;
                end
            end
            
        end
        mulhu:  begin
            mult_a = a;
            mult_b = b;
            if (start) begin
                mult_start = 1'b1;
                done = 1'b0;
                if (mult_done) begin
                    f_temp = product;
                    f = f_temp[63:32];
                    done = 1'b1;
                end
            end
            
        end 
        div:  begin
            sign = a[31] ^ b[31];
            div_a = unsigned_a;
            div_b = unsigned_b;
            if (start) begin
                div_start = 1'b1;
                done = 1'b0;
                if (div_done) begin
                    quotient = q;
                    f = sign ? (~quotient) + 1 : quotient;
                    done = 1'b1;
                end
            end
        end
        divu:  begin
            div_a = a;
            div_b = b;
            if (start) begin
                div_start = 1'b1;
                done = 1'b0;
                if (div_done) begin
                    quotient = q;
                    f = quotient;
                    done = 1'b1;
                end
            end
        end
        rem:  begin
            sign = a[31];
            div_a = unsigned_a;
            div_b = unsigned_b;
            if (start) begin
                div_start = 1'b1;
                done = 1'b0;
                if (div_done) begin
                    quotient = r;
                    f = sign ? (~quotient) + 1 : quotient;
                    done = 1'b1;
                end
            end
        end
        remu:  begin
            div_a = a;
            div_b = b;
            if (start) begin
                div_start = 1'b1;
                done = 1'b0;
                if (div_done) begin
                    quotient = r;
                    f = quotient;
                    done = 1'b1;
                end
            end
        end

    endcase
end

endmodule : mdu
