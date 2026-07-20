`timescale 1ns/1ps
//------------------------------------------------------------------------------
// tb_divider.sv — self-checking testbench for divider.sv (plain Icarus, no cocotb)
// Golden reference = SystemVerilog's own '/' and '%' operators.
//
// Stimulus is driven on the NEGEDGE so inputs are stable at the DUT's sampling
// posedge (avoids the start-signal race). Outputs are sampled just after the
// posedge (#1) so we read post-update values.
//------------------------------------------------------------------------------
module tb_divider;

    localparam int WIDTH     = 32;
    localparam int FRAC_BITS = 0;
    localparam int N         = WIDTH + FRAC_BITS;

    logic                       clk, rst, start;
    logic [WIDTH-1:0]           dividend, divisor;
    logic                       busy, done, dbz;
    logic [WIDTH+FRAC_BITS-1:0] quotient;
    logic [WIDTH-1:0]           remainder;

    int tests = 0, errors = 0;

    // ---- device under test ----
    divider #(.WIDTH(WIDTH), .FRAC_BITS(FRAC_BITS)) dut (
        .clk(clk), .rst(rst), .start(start),
        .dividend(dividend), .divisor(divisor),
        .busy(busy), .done(done),
        .quotient(quotient), .remainder(remainder), .dbz(dbz)
    );

    // ---- clock: 10 ns period ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- optional waveform dump (open dv.vcd in GTKWave if you need to debug) ----
    initial begin
        $dumpfile("dv.vcd");
        $dumpvars(0, tb_divider);
    end

    // ---- reset ----
    task automatic apply_reset();
        rst = 1; start = 0; dividend = 0; divisor = 0;
        repeat (2) @(negedge clk);
        rst = 0;
        @(negedge clk);
    endtask

    // ---- run one divide and self-check against / and % ----
    task automatic check(input logic [WIDTH-1:0] d, input logic [WIDTH-1:0] v);
        logic [WIDTH+FRAC_BITS-1:0] exp_q, scaled;
        logic [WIDTH-1:0]           exp_r;
        logic                       exp_z;
        bit                         got_done;

        // drive stimulus on the negedge so start is stable at the sampling posedge
        @(negedge clk);
        dividend = d; divisor = v; start = 1'b1;
        @(negedge clk);
        start = 1'b0;

        // wait for done (sample just after the posedge)
        got_done = 0;
        for (int t = 0; t < 2*N + 20; t++) begin
            @(posedge clk); #1;
            if (done) begin got_done = 1; break; end
        end

        tests++;
        if (!got_done) begin
            $display("[FAIL] %0d / %0d : timed out (no done)", d, v);
            errors++; return;
        end

        // golden reference (SystemVerilog's own / and %)
        if (v == 0) begin
            exp_q = '0; exp_r = '0; exp_z = 1'b1;
        end else begin
            scaled = d << FRAC_BITS;
            exp_q  = scaled / v;
            exp_r  = scaled % v;
            exp_z  = 1'b0;
        end

        if (quotient !== exp_q || remainder !== exp_r || dbz !== exp_z) begin
            $display("[FAIL] %0d / %0d : got q=%0d r=%0d dbz=%0b | exp q=%0d r=%0d dbz=%0b",
                     d, v, quotient, remainder, dbz, exp_q, exp_r, exp_z);
            errors++;
        end
    endtask

    // ---- test sequence ----
    initial begin
        apply_reset();

        // directed edge cases
        check(0, 0);  check(5, 0);                          // divide-by-zero
        check(10, 1); check(255, 1);                        // / 1
        check(7, 10); check(0, 7);                          // quotient 0
        check(42, 42); check({WIDTH{1'b1}}, {WIDTH{1'b1}}); // equal -> 1
        check({WIDTH{1'b1}}, 1);                            // max / 1
        check(13, 3); check(100, 7);                        // arbitrary
        $display("-- directed cases done --");

        for (int k = 0; k < 1000; k++)                      // random
            check($urandom, $urandom);

        $display("========================================");
        $display("  tests=%0d  errors=%0d  ->  %s",
                 tests, errors, (errors==0) ? "ALL PASS" : "FAIL");
        $display("========================================");
        $finish;
    end
endmodule