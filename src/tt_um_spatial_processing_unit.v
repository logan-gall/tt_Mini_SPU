`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Minnesota
// Engineer: Logan Gall (adapted)
// 
// Create Date: 01/20/2025 Original; Adapted: 02/2025
// Design Name: SPU MVP Prototype 
// Module Name: tt_um_spatial_processing_unit  // Note the prefix "tt_um_"
// Description: Top-level module adapted for Tiny Tapeout 10. 
//   • Uses the following ports exactly:
//         clk, rst_n, ui_in[7:0], uo_out[7:0], 
//         uio_in[7:0], uio_out[7:0], uio_oe[7:0], ena.
//   • Packs the design inputs from ui_in and uio_in as follows:
//         ui_in[3:0] = A (4 bits)
//         ui_in[7:4] = B (4 bits)
//         uio_in[2:0] = C (3 bits)
//         uio_in[5:3] = D (3 bits)
//         uio_in[7:6] = OpSel (2 bits)
//   • Reset is active low (rst_n); an internal reset is generated.
//   • The design runs at ~50 MHz.
//////////////////////////////////////////////////////////////////////////////////

module tt_um_spatial_processing_unit (
    input  wire [7:0] ui_in,   // Dedicated 8-bit input: [3:0]=A, [7:4]=B
    output wire [7:0] uo_out,  // Dedicated 8-bit output (ResultHigh & ResultLow)
    input  wire [7:0] uio_in,  // Additional 8-bit input: [2:0]=C, [5:3]=D, [7:6]=OpSel
    output wire [7:0] uio_out, // Not used - tie to zero
    output wire [7:0] uio_oe,  // Not used - tie to zero
    input  wire       ena,     // Unused (can be tied high)
    input  wire       clk,     // Clock input (50 MHz assumed)
    input  wire       rst_n    // Active low reset
);

    // Generate an active-high reset for internal logic:
    wire reset = ~rst_n;

    // Extract our design signals from the physical pins:
    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = ui_in[7:4];
    // uio_in is used solely for additional inputs:
    wire [2:0] C = uio_in[2:0];
    wire [2:0] D = uio_in[5:3];
    wire [1:0] OpSel = uio_in[7:6];

    // Input registration
    reg [3:0] A_reg, B_reg;
    reg [2:0] C_reg, D_reg;
    reg [1:0] OpSel_reg;
    reg [3:0] ResultHigh, ResultLow;
    
    // Synchronize inputs on clock edge with asynchronous reset (active high reset)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A_reg <= 4'd0;
            B_reg <= 4'd0;
            C_reg <= 3'd0;
            D_reg <= 3'd0;
            OpSel_reg <= 2'd0;
            ResultHigh <= 4'd0;
            ResultLow  <= 4'd0;
        end else begin
            A_reg <= A;
            B_reg <= B;
            C_reg <= C;
            D_reg <= D;
            OpSel_reg <= OpSel;
        end
    end

    // Intermediate wires for operation results
    wire [3:0] vector_distance_high, vector_distance_low;
    wire [3:0] raster_mean_high,     raster_mean_low;
    wire [3:0] vector_area_high,     vector_area_low;
    wire [3:0] tensor_high,          tensor_low;
    
    // Instantiate operation modules
    VectorManhattanDistance vector_distance_op (
        .A(A_reg),
        .B(B_reg),
        .C(C_reg),  // C is now 3 bits; see note below for zero-extension if needed.
        .D(D_reg),  // D is now 3 bits.
        .Distance_high(vector_distance_high),
        .Distance_low(vector_distance_low)
    );
    
    VectorBoxArea vector_area_op (
        .A(A_reg),
        .B(B_reg),
        .C(C_reg),
        .D(D_reg),
        .Area_high(vector_area_high),
        .Area_low(vector_area_low)
    );
    
    RasterFocalMean raster_mean_op (
        .A(A_reg),
        .B(B_reg),
        .C(C_reg),
        .D(D_reg),
        .Mean_high(raster_mean_high),
        .Mean_low(raster_mean_low)
    );

    TensorMultiply tensor_multiply_op (
        .A(A_reg),
        .B(B_reg),
        .C(C_reg),
        .D(D_reg),
        .Tensor_high(tensor_high),
        .Tensor_low(tensor_low)
    );

    // Operation execution based on the 2-bit OpSel:
    // 00: Raster Focal Mean, 01: Vector Manhattan Distance,
    // 10: Vector Box Area, 11: Tensor Multiply.
    always @(posedge clk) begin
        case (OpSel_reg)
            2'b00: begin
                ResultHigh <= raster_mean_high;
                ResultLow  <= raster_mean_low;
            end
            2'b01: begin
                ResultHigh <= vector_distance_high;
                ResultLow  <= vector_distance_low;
            end
            2'b10: begin
                ResultHigh <= vector_area_high;
                ResultLow  <= vector_area_low;
            end
            2'b11: begin
                ResultHigh <= tensor_high;
                ResultLow  <= tensor_low;
            end
            default: begin
                ResultHigh <= 4'd0;
                ResultLow  <= 4'd0;
            end
        endcase
    end

    // Drive the dedicated output port with our 8-bit result.
    assign uo_out = {ResultHigh, ResultLow};

    // Since we are not driving any bidirectional signals, set these to zero.
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
