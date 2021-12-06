module FA(
    input logic A,
    input logic B,
    input logic Ci,
    output logic Co,
    output logic S
);
    assign Co = (A & B) | (A & Ci) | (B & Ci);
    assign S = A ^ B ^ Ci;
endmodule