module main;

    reg  [7:0] ui_in;   // [7:4] = Op, [3:0] = Q
    wire [7:0] uo_out;  // [7:4] = M,  [3:0] = N
    reg  [7:0] uio_in;  // [7:4] = A/C, [3:0] = B/D
    wire [7:0] uio_out; // Tied to zero
    wire [7:0] uio_oe;  // Tied to zero
    reg        ena;
    reg        clk;
    reg        rst_n;

    // For testing: registers to load values
    reg [3:0] Op, Q;
    reg [3:0] A,  B;
    reg [3:0] C,  D;
    integer i;

    // Instantiate the design under test (DUT)
    tt_umn_tinyspu tinytapeoutsim(
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    always #10 clk = ~clk; // 50 MHz clock

    initial begin
        // Initialization
        clk   = 0;
        rst_n = 1;
        ena   = 0;
        ui_in  = 8'b0;
        uio_in = 8'b0;

        $display("Starting simulation...");

        // Hold reset for multiple cycles
        #50 rst_n = 0;
        #50 rst_n = 1;

        // Enable processing
        #30 ena = 1;

        // ---- SETUP MEMORY ----
        // Load A and B using Q = 4'b0110
        Q = 4'b0110;
        A = 4;
        B = 5;
        ui_in  = {4'b0000, Q}; // NoOp with Q command to load A/B
        uio_in = {A, B};       // Load A and B

        #40; // Wait for data propagation

        // Load C and D using Q = 4'b0101
        Q = 4'b0101;
        ui_in  = {4'b0000, Q}; // NoOp with Q command to load C/D
        C = 6;
        D = 7;
        uio_in = {C, D};       // Load C and D

        #40; // Wait for data propagation

        // ---- EXECUTE OPERATIONS ----
        for (i = 0; i < 16; i = i + 1) begin
            Op = i[3:0]; // Cycle through operations 0000 - 1111
            Q = 4'b0000; // No register update during operation
            ui_in = {Op, Q}; // Apply operation
            
            #40; // Allow time for processing

            // Display results
            $display("Time = %0t", $time);
            $display("Op  = %b (%0d)", Op, Op);
            $display("A   = %d, B = %d, C = %d, D = %d", A, B, C, D);
            $display("M   = %d, N = %d", uo_out[7:4], uo_out[3:0]);
            $display("------------------------------");
        end

        $finish;
    end

    // Monitor changes in outputs
    initial begin
        $monitor("MONITOR: At time %0t: uo_out = %b (M: %d, N: %d)", 
                  $time, uo_out, uo_out[7:4], uo_out[3:0]);
    end

endmodule
