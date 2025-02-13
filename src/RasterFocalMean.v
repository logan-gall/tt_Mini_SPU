module RasterFocalMean(
    input  wire [3:0] A, 
    input  wire [3:0] B, 
    input  wire [2:0] C, 
    input  wire [2:0] D, 
    output wire [3:0] Mean_high,
    output wire [3:0] Mean_low
);
    // Extend C and D to 4 bits:
    wire [3:0] C_ext = {1'b0, C};
    wire [3:0] D_ext = {1'b0, D};

    wire [7:0] sum = A + B + C_ext + D_ext;
    wire [7:0] mean = sum >> 2;
    
    assign Mean_high = mean[7:4];
    assign Mean_low  = mean[3:0];
endmodule
