
// Vector Manhattan Distance Module
module VectorManhattanDistance(
    input  wire [3:0] A,  // 4-bit
    input  wire [3:0] B,  // 4-bit
    input  wire [2:0] C,  // now 3-bit; will be extended
    input  wire [2:0] D,  // now 3-bit; will be extended
    output wire [3:0] Distance_high, 
    output wire [3:0] Distance_low
);

    wire [3:0] C_ext = {1'b0, C}; // zero-extend 3-bit to 4-bit
    wire [3:0] D_ext = {1'b0, D};

    wire [3:0] deltaX = (A >= C_ext) ? (A - C_ext) : (C_ext - A);
    wire [3:0] deltaY = (B >= D_ext) ? (B - D_ext) : (D_ext - B);
    
    wire [7:0] distance = deltaX + deltaY;
    
    assign Distance_high = distance[7:4];
    assign Distance_low  = distance[3:0];
endmodule
