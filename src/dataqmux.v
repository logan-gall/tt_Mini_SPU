module DataQMUX( 
    input  wire [3:0] UIOh,  // 4-bit
    input  wire [3:0] UIOl,  // 4-bit
    input  wire [3:0] M,  // 4-bit
    input  wire [3:0] N,  // 4-bit
    input  wire [3:0] Q, // 4-bit
    input  wire       clk,// 1-bit

    output reg [3:0] toA,  // 4-bit
    output reg [3:0] toB,  // 4-bit
    output reg [3:0] toC,  // 4-bit
    output reg [3:0] toD   // 4-bit
);

/*
	Design explanation - why the ISA was designed in a certain way...
	0000 NOP - Special case, just pass through
	00xx all others it means zero out CD, AB, or ABCD

	01xx - that means select UIO as the Input (this will be most cases)

	10xx - that means select MN as the Input (this will not be as common)

	11xx - reserved/open (no current use case at the moment...)
		Note: If there are no use cases, then I might make it 1s to CD, AB, or ABCD 
		      This would follow the 00xx design, but be 1's instead of 0's

	xx01 - take input and select CD as Output
	xx10 - take input and select AB as Output
	xx11 - take input and duplicate A/C=high, B/D=low
	xx00 - take input and duplicate, but this time A/B=high, B/D=low (rare?)
*/


always @(posedge clk) begin
    case (Q)

        // NoIO: Maintain values
        4'b0000: begin 
            toA <= toA; 
            toB <= toB; 
            toC <= toC; 
            toD <= toD;
        end
        // ZeroCD: Set C and D to 0
        4'b0001: begin 
            toA <= toA; 
            toB <= toB; 
            toC <= 4'b0000; 
            toD <= 4'b0000;
        end
        // ZeroAB: Set A and B to 0
        4'b0010: begin 
            toA <= 4'b0000; 
            toB <= 4'b0000; 
            toC <= toC; 
            toD <= toD;
        end
        // ZeroABCD: Set all to 0
        4'b0011: begin 
            toA <= 4'b0000; 
            toB <= 4'b0000; 
            toC <= 4'b0000; 
            toD <= 4'b0000;
        end
        // UIO In (01xx)
        // UIOACBD: A/B = UIOh, C/D = UIOl
        4'b0100: begin 
            toA <= UIOh; 
            toB <= UIOh; 
            toC <= UIOl; 
            toD <= UIOl;
        end
        // UIOCD: C = UIOh, D = UIOl
        4'b0101: begin 
            toA <= toA; 
            toB <= toB; 
            toC <= UIOh; 
            toD <= UIOl;
        end
        // UIOAB: A = UIOh, B = UIOl
        4'b0110: begin 
            toA <= UIOh; 
            toB <= UIOl; 
            toC <= toC; 
            toD <= toD;
        end
        // UIOABCD: A/C = UIOh, B/D = UIOl
        4'b0111: begin 
            toA <= UIOh; 
            toB <= UIOl; 
            toC <= UIOh; 
            toD <= UIOl;
        end
        // MN In (10xx)
        // MNACBD: A/B = M, C/D = N
        4'b1000: begin 
            toA <= M; 
            toB <= M; 
            toC <= N; 
            toD <= N;
        end
        // MNCD: C = M, D = N
        4'b1001: begin 
            toA <= toA; 
            toB <= toB; 
            toC <= M; 
            toD <= N;
        end
        // MNAB: A = M, B = N
        4'b1010: begin 
            toA <= M; 
            toB <= N; 
            toC <= toC; 
            toD <= toD;
        end
        // MNABCD: A/C = M, B/D = N
        4'b1011: begin 
            toA <= M; 
            toB <= N; 
            toC <= M; 
            toD <= N;
        end
        // Default case to avoid latches
        default: begin 
            toA <= 4'b0000; 
            toB <= 4'b0000; 
            toC <= 4'b0000; 
            toD <= 4'b0000;
        end
    endcase

end

endmodule

