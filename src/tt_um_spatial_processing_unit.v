//////////////////////////////////////////////////////////////////////////////////
// Company: University of Minnesota
// Engineer: Logan Gall (adapted)
// 
// Create Date: 01/20/2025 Original; Adapted: 02/2025
// Design Name: SPU MVP Prototype 
// Module Name: tt_um_spatial_processing_unit  // Note the prefix "tt_um_"
// Description: Top-level module for Tiny Tapeout 10 performing a simple addition.
//   • Uses the following ports exactly:
//         clk, rst_n, ui_in[7:0], uo_out[7:0], 
//         uio_in[7:0], uio_out[7:0], uio_oe[7:0], ena.
//   • Packs the design inputs from ui_in and uio_in as follows:
//         ui_in[3:0] = A (4 bits)
//         ui_in[7:4] = B (4 bits)
//         uio_in[2:0] = C (3 bits)
//         uio_in[5:3] = D (3 bits)
//         uio_in[7:6] = (ignored)
//   • Reset is active low (rst_n); an internal reset is generated.
//   • The design runs at ~50 MHz.
//////////////////////////////////////////////////////////////////////////////////

module tt_um_spatial_processing_unit (
    input  wire [7:0] ui_in,   // Dedicated 8-bit input: [3:0]=A, [7:4]=B
    output wire [7:0] uo_out,  // Dedicated 8-bit output (sum result)
    input  wire [7:0] uio_in,  // Additional 8-bit input: [2:0]=C, [5:3]=D, [7:6]=ignored
    output wire [7:0] uio_out, // Not used - tie to zero
    output wire [7:0] uio_oe,  // Not used - tie to zero
    input  wire       ena,     // Unused (can be tied high)
    input  wire       clk,     // Clock input (50 MHz assumed)
    input  wire       rst_n    // Active low reset
);

    // Generate an active-high reset for internal logic:
    wire reset = ~rst_n;

    // Extract design signals from the physical pins:
    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = ui_in[7:4];
    // uio_in is used solely for additional inputs:
    wire [2:0] C = uio_in[2:0];
    wire [2:0] D = uio_in[5:3];

    // Input registration
    reg [3:0] A_reg, B_reg;
    reg [2:0] C_reg, D_reg;
    
    // Synchronize inputs on clock edge with asynchronous reset (active high reset)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A_reg <= 4'd0;
            B_reg <= 4'd0;
            C_reg <= 3'd0;
            D_reg <= 3'd0;
        end else begin
            A_reg <= A;
            B_reg <= B;
            C_reg <= C;
            D_reg <= D;
        end
    end

    // Simple addition operation: sum = A + B + C + D
    reg [7:0] sum;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 8'd0;
        end else begin
            sum <= A_reg + B_reg + C_reg + D_reg;
        end
    end

    // Drive the dedicated output port with our 8-bit sum.
    assign uo_out = sum;

    // Since we are not driving any bidirectional signals, set these to zero.
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
