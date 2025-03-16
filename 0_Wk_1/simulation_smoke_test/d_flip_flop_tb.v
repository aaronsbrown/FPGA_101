`timescale 1ns/1ps
`include "d_flip_flop.v"

module d_flip_flop_tb;
    reg clk, reset, d;
    wire q;

    d_flip_flop uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    initial begin
        clk = 0;
        reset = 1;
        d = 0;
        #10;
        reset = 0;
    end

    always forever #5 clk = ~clk;

    
    initial begin
        // ✅ Monitor changes
        $monitor("Time=%0t | clk=%b | reset=%b | d=%b | q=%b", $time, clk, reset, d, q);


        $dumpfile("waveform_data_flip_flop.vcd");
        $dumpvars(0, d_flip_flop_tb);
        
        d = 0; #10;
        d = 1; #10;
        d = 0; #10;
        d = 1; #10;

        reset = 1; 
        #10 reset = 0;
        
        #50 $finish;

        end

endmodule