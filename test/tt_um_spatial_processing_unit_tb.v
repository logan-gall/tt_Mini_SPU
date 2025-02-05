`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for the tt_um_spatial_processing_unit
// This testbench verifies the four operations of the Spatial Processing Unit:
//  00 → Raster Focal Mean  
//  01 → Vector Manhattan Distance  
//  10 → Vector Box Area  
//  11 → Tensor Multiply
//
// The inputs are "packed" into two 8-bit buses as follows:
//   ui_in[3:0] = A, ui_in[7:4] = B
//   uio_in[2:0] = C, uio_in[5:3] = D, uio_in[7:6] = OpSel
//////////////////////////////////////////////////////////////////////////////////

module tt_um_spatial_processing_unit_tb;

    // Clock and reset signals
    reg clk;
    reg rst_n;
    
    // Physical input buses: ui_in and uio_in
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    
    // Enable (unused in logic; can be tied high)
    reg ena;
    
    // Physical outputs (uo_out carries the 8-bit result)
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Instantiate the top-level design
    tt_um_spatial_processing_unit dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Clock generation: 50 MHz clock (20 ns period, toggle every 10 ns)
    initial clk = 0;
    always #10 clk = ~clk;
    
    initial begin
        // Initialize signals
        ena   = 1'b1;
        rst_n = 0;       // Assert active-low reset
        ui_in = 8'h00;
        uio_in = 8'h00;
        
        // Hold reset for 30 ns then deassert it
        #30;
        rst_n = 1;
        
        // Wait a few cycles after reset
        #20;
        
        //==========================================================================
        // 1. Test Raster Focal Mean (OpSel = 00)
        //    Pack values: A = 4, B = 8, C = 6, D = 2.
        //    Expected: (4 + 8 + (0+6) + (0+2)) >> 2 = 20 >> 2 = 5.
        //    ui_in: [7:4]=B, [3:0]=A → {8,4}.
        //    uio_in: [7:6]=00, [5:3]=D=2, [2:0]=C=6 → {00, 2, 6}.
        //==========================================================================
        ui_in  = {4'd8, 4'd4};      // B=8, A=4
        uio_in = {2'b00, 3'd2, 3'd6};  // OpSel=00, D=2, C=6
        #40;
        $display("Time: %0t | [Raster Focal Mean] A=4, B=8, C=6, D=2, OpSel=00 | Result = %h", $time, uo_out);
        
        //==========================================================================
        // 2. Test Vector Manhattan Distance (OpSel = 01)
        //    Pack values: A = 5, B = 3, C = 1, D = 7.
        //    Expected: |5-1| + |3-7| = 4 + 4 = 8.
        //    ui_in: {B, A} = {3, 5} →  ui_in = 8'h35.
        //    uio_in: {OpSel=01, D=7, C=1} →  uio_in = {01, 7, 1}.
        //==========================================================================
        ui_in  = {4'd3, 4'd5};      // B=3, A=5
        uio_in = {2'b01, 3'd7, 3'd1};  // OpSel=01, D=7, C=1
        #40;
        $display("Time: %0t | [Vector Manhattan Distance] A=5, B=3, C=1, D=7, OpSel=01 | Result = %h", $time, uo_out);
        
        //==========================================================================
        // 3. Test Vector Box Area (OpSel = 10)
        //    Pack values: A = 2, B = 3, C = 5, D = 1.
        //    Expected: |5-2| * |1-3| = 3 * 2 = 6.
        //    ui_in: {B, A} = {3, 2}.
        //    uio_in: {OpSel=10, D=1, C=5} → {10, 1, 5}.
        //==========================================================================
        ui_in  = {4'd3, 4'd2};      // B=3, A=2
        uio_in = {2'b10, 3'd1, 3'd5};  // OpSel=10, D=1, C=5
        #40;
        $display("Time: %0t | [Vector Box Area] A=2, B=3, C=5, D=1, OpSel=10 | Result = %h", $time, uo_out);

        //==========================================================================
        // 4. Test Tensor Multiply (OpSel = 11)
        //    Pack values: A = 2, B = 3, C = 4, D = 5.
        //    Tensor Multiply uses the two least-significant bits:
        //       A[1:0]=2 (2'b10) and B[1:0]=3 (2'b11) → product1 = 2*3 = 6.
        //       C[1:0] from 4 (3'b100 → 2'b00) and D[1:0] from 5 (3'b101 → 2'b01) → product2 = 0*1 = 0.
        //    Expected: Result = {product2, product1} = {0, 6} = 0x06.
        //    ui_in: {B, A} = {3, 2}.
        //    uio_in: {OpSel=11, D=5, C=4} → {11, 5, 4}.
        //==========================================================================
        ui_in  = {4'd3, 4'd2};      // B=3, A=2
        uio_in = {2'b11, 3'd5, 3'd4};  // OpSel=11, D=5, C=4
        #40;
        $display("Time: %0t | [Tensor Multiply] A=2, B=3, C=4, D=5, OpSel=11 | Result = %h", $time, uo_out);
        
        // Finish simulation after a short delay
        #50;
        $finish;
    end

endmodule
