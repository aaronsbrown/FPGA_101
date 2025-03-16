`timescale 1ns/1ps
//`include "../simulation_smoke_test/d_ff.v"


module register_4b_tb;
    reg clk, reset;
    reg [3:0] d;
    wire [3:0] q;

    register_4b uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    always forever #5 clk = ~clk;
    
    initial begin
        
        $dumpfile("waveform_register_4bit.vcd");
        $dumpvars(0, register_4b_tb);
        
        $monitor("Time=%0t | clk=%b | reset=%b | d3=%b | d2=%b | d1=%b | d0=%b | q3=%b | q2=%b | q1=%b | q0=%b", $time, clk, reset, d[3], d[2], d[1], d[0], q[3], q[2], q[1], q[0]);

        // Initial conditions: start with reset asserted
        clk = 0;      // clock initial value (redundant because always block drives it)
        reset = 1;    // hold reset initially
        d = 4'b0000;        // initial d value

        // Wait for one clock cycle to ensure proper reset duration
        @(posedge clk);
        reset = 0;    // de-assert reset after one rising clock edge

        // Apply stimulus aligned with clock edges:
        @(posedge clk);
        d = 4'b0000;        // drive d = 0
        @(posedge clk);
        d = 4'b0001;        // drive d = 1
        @(posedge clk);
        d = 4'b0010;        // drive d = 2
        @(posedge clk);
        d = 4'b0100;        // drive d = 4
        @(posedge clk);
        d = 4'b1000;        // drive d = 8
        
        // Test reasserting reset mid-operation:
        repeat(2) @(posedge clk);
        reset = 1;    // assert reset again to test asynchronous behavior
        @(posedge clk);
        reset = 0;    // de-assert reset
        
        // Apply stimulus aligned with clock edges:
        @(posedge clk);
        d = 4'b1111;        // drive d = 15
        @(posedge clk);
       
        repeat(5) @(posedge clk);
        $finish;

        end

endmodule