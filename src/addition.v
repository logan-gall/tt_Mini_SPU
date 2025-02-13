//////////////////////////////////////////////////////////////////////////////////
// Company: University of Minnesota
// Engineer: Logan Gall (adapted)
// 
// Create Date: 02/2025
// Design Name: Addition Operation
// Module Name: addition
// Description: This module performs a simple addition of its inputs A, B, C, and D.
//              The operation is performed synchronously on the rising edge of clk,
//              with an asynchronous active-high reset.
//////////////////////////////////////////////////////////////////////////////////

module addition (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] C,
    input  wire [2:0] D,
    output reg  [7:0] sum
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            sum <= 8'd0;
        else
            sum <= A + B + C + D;
    end
endmodule
