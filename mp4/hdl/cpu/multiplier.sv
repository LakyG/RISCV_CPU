module multiplier #(
	parameter width = 32,
	parameter g1 = 10,
	parameter r1 = 2,
	parameter g2 = 7,
	parameter r2 = 1,
	parameter g3 = 5,
	parameter r3 = 0,
	parameter g4 = 3,
	parameter r4 = 1,
	parameter g5 = 2,
	parameter r5 = 1,
	parameter g6 = 1,
	parameter r6 = 2,
	parameter g7 = 1,
	parameter r7 = 1,
	parameter g8 = 1,
	parameter r8 = 0
	
)
(
    input clk,
    input rst,
    input start,
	input logic [width-1:0] A,
	input logic [width-1:0] B,
	output logic [2*width-1:0] M,
    output logic done
);
    logic [2*width-1:0] product;
	//stage 1 partial product
	logic [width-1:0][2*width-1:0] pp;
	always_comb begin
		for (int i = 0; i < width; i++) begin
			pp[i] = (A & {width{B[i]}}) << i;
		end
	end
	//stage 2 addition step 1
	logic [g1*2-1+r1:0][2*width-1:0] s1;
	wire [g1:0] temp1;
	genvar j;
	genvar i;
    generate
        for (j = 0; j < g1; j++) begin : STEP1J
            for (i = 0; i < 2*width-1; i++) begin : STEP1I
				FA fa1(
					.A(pp[j*3][i]),
					.B(pp[j*3+1][i]),
					.Ci(pp[j*3+2][i]),
					.S(s1[j*2][i]),
					.Co(s1[j*2+1][i+1])
				);
			end
			FA fa11(
					.A(pp[j*3][2*width-1]),
					.B(pp[j*3+1][2*width-1]),
					.Ci(pp[j*3+2][2*width-1]),
					.S(s1[j*2][2*width-1]),
					.Co(temp1[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g1; k++) begin
			s1[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r1; k++) begin
			s1[g1*2+k] = pp[g1*3+k];
		end
	end


	//stage 2 step 2
	logic [g2*2-1+r2:0][2*width-1:0] s2;
	wire [g2:0] temp2;
	generate
        for (j = 0; j < g2; j++) begin : STEP2J
            for (i = 0; i < 2*width-1; i++) begin: STEP2I
				FA fa2(
					.A(s1[j*3][i]),
					.B(s1[j*3+1][i]),
					.Ci(s1[j*3+2][i]),
					.S(s2[j*2][i]),
					.Co(s2[j*2+1][i+1])
				);
			end
			FA fa22(
					.A(s1[j*3][2*width-1]),
					.B(s1[j*3+1][2*width-1]),
					.Ci(s1[j*3+2][2*width-1]),
					.S(s2[j*2][2*width-1]),
					.Co(temp2[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g2; k++) begin
			s2[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r2; k++) begin
			s2[g2*2+k] = s1[g2*3+k];
		end
	end
	//stage 2 step 3
	logic [g3*2-1+r3:0][2*width-1:0] s3;
	wire [g3:0] temp3;
	generate
        for (j = 0; j < g3; j++) begin : STEP3J
            for (i = 0; i < 2*width-1; i++) begin: STEP3I
				FA fa3(
					.A(s2[j*3][i]),
					.B(s2[j*3+1][i]),
					.Ci(s2[j*3+2][i]),
					.S(s3[j*2][i]),
					.Co(s3[j*2+1][i+1])
				);
			end
			FA fa33(
					.A(s2[j*3][2*width-1]),
					.B(s2[j*3+1][2*width-1]),
					.Ci(s2[j*3+2][2*width-1]),
					.S(s3[j*2][2*width-1]),
					.Co(temp3[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g3; k++) begin
			s3[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r3; k++) begin
			s3[g3*2+k] = s2[g3*3+k];
		end
	end
	//stage 2 step 4
	logic [g4*2-1+r4:0][2*width-1:0] s4;
	wire [g4:0] temp4;
	generate
        for (j = 0; j < g4; j++) begin : STEP4J
            for (i = 0; i < 2*width-1; i++) begin: STEP4I
				FA fa4(
					.A(s3[j*3][i]),
					.B(s3[j*3+1][i]),
					.Ci(s3[j*3+2][i]),
					.S(s4[j*2][i]),
					.Co(s4[j*2+1][i+1])
				);
			end
			FA fa44(
					.A(s3[j*3][2*width-1]),
					.B(s3[j*3+1][2*width-1]),
					.Ci(s3[j*3+2][2*width-1]),
					.S(s4[j*2][2*width-1]),
					.Co(temp4[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g4; k++) begin
			s4[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r4; k++) begin
			s4[g4*2+k] = s3[g4*3+k];
		end
	end

	//stage 2 step 5
	logic [g5*2-1+r5:0][2*width-1:0] s5;
	wire [g5:0] temp5;
	generate
        for (j = 0; j < g5; j++) begin : STEP5J
            for (i = 0; i < 2*width-1; i++) begin: STEP5I
				FA fa5(
					.A(s4[j*3][i]),
					.B(s4[j*3+1][i]),
					.Ci(s4[j*3+2][i]),
					.S(s5[j*2][i]),
					.Co(s5[j*2+1][i+1])
				);
			end
			FA fa55(
					.A(s4[j*3][2*width-1]),
					.B(s4[j*3+1][2*width-1]),
					.Ci(s4[j*3+2][2*width-1]),
					.S(s5[j*2][2*width-1]),
					.Co(temp5[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g5; k++) begin
			s5[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r5; k++) begin
			s5[g5*2+k] = s4[g5*3+k];
		end
	end
	//stage 2 step 6
	logic [g6*2-1+r6:0][2*width-1:0] s6;
	wire [g6:0] temp6;
	generate
        for (j = 0; j < g6; j++) begin : STEP6J
            for (i = 0; i < 2*width-1; i++) begin: STEP6I
				FA fa6(
					.A(s5[j*3][i]),
					.B(s5[j*3+1][i]),
					.Ci(s5[j*3+2][i]),
					.S(s6[j*2][i]),
					.Co(s6[j*2+1][i+1])
				);
			end
			FA fa66(
					.A(s5[j*3][2*width-1]),
					.B(s5[j*3+1][2*width-1]),
					.Ci(s5[j*3+2][2*width-1]),
					.S(s6[j*2][2*width-1]),
					.Co(temp6[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g6; k++) begin
			s6[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r6; k++) begin
			s6[g6*2+k] = s5[g6*3+k];
		end
	end
	//stage 2 step 7
	logic [g7*2-1+r7:0][2*width-1:0] s7;
	wire [g7:0] temp7;
	generate
        for (j = 0; j < g7; j++) begin : STEP7J
            for (i = 0; i < 2*width-1; i++) begin: STEP7I
				FA fa7(
					.A(s6[j*3][i]),
					.B(s6[j*3+1][i]),
					.Ci(s6[j*3+2][i]),
					.S(s7[j*2][i]),
					.Co(s7[j*2+1][i+1])
				);
			end
			FA fa77(
					.A(s6[j*3][2*width-1]),
					.B(s6[j*3+1][2*width-1]),
					.Ci(s6[j*3+2][2*width-1]),
					.S(s7[j*2][2*width-1]),
					.Co(temp7[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g7; k++) begin
			s7[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r7; k++) begin
			s7[g7*2+k] = s6[g7*3+k];
		end
	end
	//stage 2 step 8
	logic [g8*2-1+r8:0][2*width-1:0] s8;
	wire [g8:0] temp8;
	generate
        for (j = 0; j < g8; j++) begin : STEP8J
            for (i = 0; i < 2*width-1; i++) begin: STEP8I
				FA fa8(
					.A(s7[j*3][i]),
					.B(s7[j*3+1][i]),
					.Ci(s7[j*3+2][i]),
					.S(s8[j*2][i]),
					.Co(s8[j*2+1][i+1])
				);
			end
			FA fa88(
					.A(s7[j*3][2*width-1]),
					.B(s7[j*3+1][2*width-1]),
					.Ci(s7[j*3+2][2*width-1]),
					.S(s8[j*2][2*width-1]),
					.Co(temp8[j])
				);
        end

    endgenerate
	always_comb begin
		for (int k = 0; k < g8; k++) begin
			s8[k*2+1][0] = 1'b0;
		end
		for (int k = 0; k < r8; k++) begin
			s8[g8*2+k] = s7[g8*3+k];
		end
	end
	//stage 3
	assign product = s8[0] + s8[1];

    logic started;
    always_ff @(posedge clk) begin
    if (rst) begin
        M = '0;
        started = 1'b0;
        done = 1'b0;
    end
    else if (start & (~started) & (~done)) begin
        started = 1'b1;
    end
    else if (started) begin
        M = product;
        done = 1'b1;
        started = 1'b0;
    end
    else 
        done = 1'b0;
end

endmodule