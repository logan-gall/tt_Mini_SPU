`timescale 1ns / 1ps
module TensorMultiply(
    input  wire [3:0] A, 
    input  wire [3:0] B, 
    input  wire [2:0] C, 
    input  wire [2:0] D, 
    output wire [3:0] Tensor_high,
    output wire [3:0] Tensor_low
);
    // Truncate each input to its 2 least-significant bits.
    wire [1:0] A_trunc = A[1:0];
    wire [1:0] B_trunc = B[1:0];
    wire [1:0] C_trunc = C[1:0];
    wire [1:0] D_trunc = D[1:0];
    
    wire [3:0] product1 = A_trunc * B_trunc;
    wire [3:0] product2 = C_trunc * D_trunc;
    
    assign Tensor_high = product2;
    assign Tensor_low  = product1;
endmodule
