`timescale 1ns/1ps
// `include "../simulation_smoke_test/d_ff.v"


module counter_nb_tb;
    parameter N = 4;
    reg clk, reset;
    wire [N-1:0] q;

    counter_nb #(.N(N)) uut (
        .clk(clk),
        .reset(reset),
        .q(q)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    always forever #5 clk = ~clk;
    
    initial begin
        
        $dumpfile("waveform_counter_nbit.vcd");
        $dumpvars(0, counter_nb_tb);

        $monitor( "Time =%0t | clk=%b | reset=%b | q=%4b", $time, clk, reset, q);

        // Initial conditions: start with reset asserted
        clk = 0;      // clock initial value (redundant because always block drives it)
        reset = 1;    // hold reset initially

        // Wait for one clock cycle to ensure proper reset duration
        @(posedge clk);
        reset = 0;    // de-assert reset after one rising clock edge

        // Test reasserting reset mid-operation:
        repeat(18) @(posedge clk);
        
        $finish;
        end

endmodule