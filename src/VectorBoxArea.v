
module VectorBoxArea(
    input  wire [3:0] A, 
    input  wire [3:0] B, 
    input  wire [2:0] C, 
    input  wire [2:0] D, 
    output wire [3:0] Area_high, 
    output wire [3:0] Area_low
);
    wire [3:0] C_ext = {1'b0, C};
    wire [3:0] D_ext = {1'b0, D};
    
    wire [3:0] deltaX = (C_ext >= A) ? (C_ext - A) : (A - C_ext);
    wire [3:0] deltaY = (D_ext >= B) ? (D_ext - B) : (B - D_ext);
    
    wire [7:0] area = deltaX * deltaY;
    
    assign Area_high = area[7:4];
    assign Area_low  = area[3:0];
endmodule
