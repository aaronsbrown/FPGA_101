`timescale 1ns/1ps
`include "../simulation_smoke_test/d_ff.v"

module d_ff_tb;
    reg clk, reset, d;
    wire q;

    // Instantiate the D flip-flop under test
    d_ff uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    always forever #5 clk = ~clk;

    initial begin
        // Setup waveform dump and monitor
        $dumpfile("waveform_d_ff.vcd");
        $dumpvars(0, d_ff_tb);
        $monitor("Time=%0t | clk=%b | reset=%b | d=%b | q=%b", $time, clk, reset, d, q);

        // Initial conditions: start with reset asserted
        clk = 0;      // clock initial value (redundant because always block drives it)
        reset = 1;    // hold reset initially
        d = 0;        // initial d value

        // Wait for one clock cycle to ensure proper reset duration
        @(posedge clk);
        reset = 0;    // de-assert reset after one rising clock edge

        // Apply stimulus aligned with clock edges:
        @(posedge clk);
        d = 0;        // drive d = 0
        @(posedge clk);
        d = 1;        // drive d = 1
        @(posedge clk);
        d = 0;        // drive d = 0
        @(posedge clk);
        d = 1;        // drive d = 1

        // Test reasserting reset mid-operation:
        @(posedge clk);
        reset = 1;    // assert reset again to test asynchronous behavior
        @(posedge clk);
        reset = 0;    // de-assert reset

        // Continue simulation for a few more cycles to observe behavior
        repeat (5) @(posedge clk);

        $finish;      // end simulation
    end

endmodule