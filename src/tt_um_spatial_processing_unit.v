//////////////////////////////////////////////////////////////////////////////////
// Company: University of Minnesota
// Engineer: Logan Gall (adapted)
// 
// Create Date: 01/20/2025 Original; Adapted: 02/2025
// Design Name: SPU MVP Prototype 
// Module Name: tt_um_spatial_processing_unit  // Note the prefix "tt_um_"
// Description: Top-level module for Tiny Tapeout 10 performing either:
//              - Vector Manhattan Distance, or
//              - Vector Box Area,
//              based on the 2-bit OpSel signal from uio_in[7:6].
//   • Ports:
//         clk, rst_n, ui_in[7:0], uo_out[7:0],
//         uio_in[7:0], uio_out[7:0], uio_oe[7:0], ena.
//   • Signal packing:
//         ui_in[3:0] = A (4 bits)
//         ui_in[7:4] = B (4 bits)
//         uio_in[2:0] = C (3 bits)
//         uio_in[5:3] = D (3 bits)
//         uio_in[7:6] = OpSel (2 bits)
//   • Reset is active low (rst_n); an internal active-high reset is generated.
//   • The design runs at ~50 MHz.
//////////////////////////////////////////////////////////////////////////////////

module tt_um_spatial_processing_unit (
    input  wire [7:0] ui_in,   // [7:4] = Op, [3:0] = Q
    output wire [7:0] uo_out,  // [7:4] = M,  [3:0] = N
    input  wire [7:0] uio_in,  // [7:4] = A / C, [3:0] = B / D
    output wire [7:0] uio_out, // Not used - tie to zero
    output wire [7:0] uio_oe,  // Not used - tie to zero
    input  wire       ena,
    input  wire       clk,     // 50 MHz assumed
    input  wire       rst_n    // Active low reset
);

    // Generate active-high internal reset:
    wire reset = ~rst_n;

    // Extract design signals from physical pins:
    wire [3:0] A = uio_in[7:4];  // THESE NEED A MUX/SEL
    wire [3:0] B = uio_in[3:0];
    wire [3:0] C = uio_in[7:4];
    wire [3:0] D = uio_in[3:0];
    wire [3:0] Op = ui_in[7:4];
    wire [3:0] Q  = ui_in[3:0];

    // Register the inputs (including OpSel) with asynchronous reset:
    reg [3:0] A_reg, B_reg;
    reg [3:0] C_reg, D_reg;
    reg [3:0] M_reg, N_reg;
    reg [3:0] Op_reg, Q_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A_reg    <= 4'd0; // RESET ALL TO 0, 4-bits each
            B_reg    <= 4'd0;
            C_reg    <= 4'd0;
            D_reg    <= 4'd0;
            M_reg    <= 4'd0;
            N_reg    <= 4'd0;
            Op_reg   <= 4'd0;
            Q_reg    <= 4'd0;
        end else begin
            A_reg    <= A; // THESE NEED TO BE UPDATED
            B_reg    <= B;
            C_reg    <= C;
            D_reg    <= D;
            Op_reg   <= Op;
            Q_reg    <= Q;
        end
    end

    // Instantiate the Vector Manhattan Distance module:
    wire [3:0] dist_M;
    wire [3:0] dist_N;
    VectorManhattanDistance vmd_inst (
        .A(A_reg),
        .B(B_reg),
        .C(C_reg),
        .D(D_reg),
        .Distance_high(dist_M),
        .Distance_low(dist_N)
    );

    // Instantiate the Vector Box Area module:
    wire [3:0] area_M;
    wire [3:0] area_N;
    VectorBoxArea vba_inst (
        .A(A_reg),
        .B(B_reg),
        .C(C_reg),
        .D(D_reg),
        .Area_high(area_M),
        .Area_low(area_N)
    );

    // Select the result based on OpSel:
    //   2'b00: Vector Manhattan Distance
    //   2'b01: Vector Box Area
    //   Others: 0
    reg [7:0] result;
    always @(posedge clk or posedge reset) begin
        if (reset)
            result <= 8'd0;
        else begin
            case (Op_reg)
                2'b00: result <= {dist_M, dist_N};
                2'b01: result <= {area_M, area_N};
                default: result <= 8'd0;
            endcase
        end
    end

    // Drive the output:
    assign uo_out = result;

    // Tie unused outputs to zero:
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
