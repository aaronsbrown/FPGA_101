`timescale 1ns/1ps

module clock_divider_tb;
    reg clk, reset;
    wire clk_out;

    clock_divider #( .DIV_FACTOR(4) ) uut (
        .clk_in(clk),
        .reset(reset),
        .clk_out(clk_out)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    always #5 clk = ~clk;
    
    initial begin
        
        $dumpfile("waveform.vcd");
        $dumpvars(0, clock_divider_tb);

        $monitor( "Time =%0t | clk_in=%b | reset=%b | clk_out=%b", $time, clk, reset, clk_out);

        // Initial conditions: start with reset asserted
        clk = 0;      // clock initial value (redundant because always block drives it)
        reset = 1;    // hold reset initially

        // Wait for one clock cycle to ensure proper reset duration
        @(posedge clk);
        reset = 0;    // de-assert reset after one rising clock edge

        // Test reasserting reset mid-operation:
        repeat(40) @(posedge clk);

        reset = 1;
        repeat(5) @(posedge clk);
        reset = 0;

        repeat(10) @(posedge clk);

        $display("Test complete at time %0t", $time);
        $finish;
        end

endmodule