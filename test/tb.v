`default_nettype none
`timescale 1ns / 1ps

/* This testbench instantiates the module and creates wires that can be driven by 
   cocotb or additional Verilog stimulus.
*/
module tb ();

//---------------------------------------------------------------------
// VCD Dump (for waveform viewing with tools such as gtkwave)
initial begin
  $dumpfile("tb.vcd");
  $dumpvars(0, tb);
  #1;
end

//---------------------------------------------------------------------
// Declare signals (inputs, outputs, clock, reset, etc.)
reg clk;
reg rst_n;
reg ena;
reg [7:0] ui_in;
reg [7:0] uio_in;
wire [7:0] uo_out;
wire [7:0] uio_out;
wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

//---------------------------------------------------------------------
// DUT instantiation 
// (Replace 'tt_um_example' with your actual module name if needed.)
tt_um_spatial_processing_unit user_project (
    // Include power ports if running a gate-level simulation:
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
);

//---------------------------------------------------------------------
// Clock Generation (50 MHz clock: 20 ns period, toggling every 10 ns)
initial begin
  clk = 0;
  forever #10 clk = ~clk;
end

//---------------------------------------------------------------------
// Additional Verilog Testbench Stimulus Process
// This block applies your tests on top of the template. 
// (Ensure that cocotb is not simultaneously trying to drive these same signals.)
initial begin
  // Initialize signals and assert reset.
  ena    = 1'b1;
  rst_n  = 0;
  ui_in  = 8'h00;
  uio_in = 8'h00;
  
  // Hold reset for 30 ns then release.
  #30;
  rst_n = 1;
  
  // Wait a few cycles after reset.
  #20;
  
  //==========================================================================
  // Test 1: Raster Focal Mean (OpSel = 00)
  // ui_in: {B, A} = {8, 4}; uio_in: {OpSel=00, D=2, C=6}
  ui_in  = {4'd8, 4'd4};
  uio_in = {2'b00, 3'd2, 3'd6};
  #40;
  $display("Time: %0t | [Raster Focal Mean] A=4, B=8, C=6, D=2, OpSel=00 | Result = %h", $time, uo_out);
  
  //==========================================================================
  // Test 2: Vector Manhattan Distance (OpSel = 01)
  // ui_in: {B, A} = {3, 5}; uio_in: {OpSel=01, D=7, C=1}
  ui_in  = {4'd3, 4'd5};
  uio_in = {2'b01, 3'd7, 3'd1};
  #40;
  $display("Time: %0t | [Vector Manhattan Distance] A=5, B=3, C=1, D=7, OpSel=01 | Result = %h", $time, uo_out);
  
  //==========================================================================
  // Test 3: Vector Box Area (OpSel = 10)
  // ui_in: {B, A} = {3, 2}; uio_in: {OpSel=10, D=1, C=5}
  ui_in  = {4'd3, 4'd2};
  uio_in = {2'b10, 3'd1, 3'd5};
  #40;
  $display("Time: %0t | [Vector Box Area] A=2, B=3, C=5, D=1, OpSel=10 | Result = %h", $time, uo_out);
  
  //==========================================================================
  // Test 4: Tensor Multiply (OpSel = 11)
  // ui_in: {B, A} = {3, 2}; uio_in: {OpSel=11, D=5, C=4}
  ui_in  = {4'd3, 4'd2};
  uio_in = {2'b11, 3'd5, 3'd4};
  #40;
  $display("Time: %0t | [Tensor Multiply] A=2, B=3, C=4, D=5, OpSel=11 | Result = %h", $time, uo_out);
  
  // Finish simulation.
  #50;
  $finish;
end

endmodule
