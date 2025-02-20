module TinySPU( 
    input  wire [3:0] A,  // 4-bit
    input  wire [3:0] B,  // 4-bit
    input  wire [3:0] C,  // 4-bit
    input  wire [3:0] D,  // 4-bit
    input  wire [3:0] Op, // 4-bit
    input  wire       clk,// 1-bit

    output reg [3:0] M,  // 4-bit
    output reg [3:0] N   // 4-bit
);

    wire [3:0] M0, N0, M1, N1, M2, N2, M3, N3, M4, N4, M5, N5, M6, N6, M7, N7, M8, N8;
    wire [3:0] M9, N9, M10, N10, M11, N11, M12, N12, M13, N13, M14, N14, M15, N15;

    // Instantiate all operation modules

    // Control SPU Ops
    NOP             op0000 (.A(A), .B(B), .C(C), .D(D), .M(M0),  .N(N0));
    OneMN           op0001 (.A(A), .B(B), .C(C), .D(D), .M(M1),  .N(N1));
    NOP             op0010 (.A(A), .B(B), .C(C), .D(D), .M(M2),  .N(N2));
    ZeroMN          op0011 (.A(A), .B(B), .C(C), .D(D), .M(M3),  .N(N3));

    // Dual 4-bit Vector Ops
    DistDir         op0100 (.A(A), .B(B), .C(C), .D(D), .M(M4),  .N(N4));  
    AreaPerim       op0101 (.A(A), .B(B), .C(C), .D(D), .M(M5),  .N(N5));
    BasicBuffer     op0110 (.A(A), .B(B), .C(C), .D(D), .M(M6),  .N(N6));
    AttrReclass     op0111 (.A(A), .B(B), .C(C), .D(D), .M(M7),  .N(N7));

    // Dual 4-bit Raster Ops
    FocalMeanRow    op1000 (.A(A), .B(B), .C(C), .D(D), .M(M8),  .N(N8)); 
    FocalSumRow     op1001 (.A(A), .B(B), .C(C), .D(D), .M(M9),  .N(N9));
    FocalMaxRow     op1010 (.A(A), .B(B), .C(C), .D(D), .M(M10), .N(N10));
    FocalMaxPoolRow op1011 (.A(A), .B(B), .C(C), .D(D), .M(M11), .N(N11));

    // Multispectral raster operations
    NormDiffIndex   op1100 (.A(A), .B(B), .C(C), .D(D), .M(M12), .N(N12)); 
    NOP             op1101 (.A(A), .B(B), .C(C), .D(D), .M(M13), .N(N13)); 

    // Single 8-bit Ops
    MHDist8         op1110 (.A(A), .B(B), .C(C), .D(D), .M(M14), .N(N14));
    DotProduct      op1111 (.A(A), .B(B), .C(C), .D(D), .M(M15), .N(N15));

    reg [3:0] Mt, Nt;

    // Select the output based on Op
    always @(posedge clk) begin
        case (Op)
            4'd0:    begin Mt = M0;   Nt = N0;   end
            4'd1:    begin Mt = M1;   Nt = N1;   end
            4'd2:    begin Mt = M2;   Nt = N2;   end
            4'd3:    begin Mt = M3;   Nt = N3;   end
            4'd4:    begin Mt = M4;   Nt = N4;   end
            4'd5:    begin Mt = M5;   Nt = N5;   end
            4'd6:    begin Mt = M6;   Nt = N6;   end
            4'd7:    begin Mt = M7;   Nt = N7;   end
            4'd8:    begin Mt = M8;   Nt = N8;   end
            4'd9:    begin Mt = M9;   Nt = N9;   end
            4'd10:   begin Mt = M10;  Nt = N10;  end
            4'd11:   begin Mt = M11;  Nt = N11;  end
            4'd12:   begin Mt = M12;  Nt = N12;  end
            4'd13:   begin Mt = M13;  Nt = N13;  end
            4'd14:   begin Mt = M14;  Nt = N14;  end
            4'd15:   begin Mt = M15;  Nt = N15;  end
            default: begin Mt = 4'd0; Nt = 4'd0; end // Default case
        endcase
        //$display("TinySPU M=%d N=%d Mt=%d Nt=%d", M, N, Mt, Nt);
    end

    always @(posedge clk) begin
        M <= Mt;
        N <= Nt;
    end

endmodule
