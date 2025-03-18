`timescale 1ns/1ps
`include "../simulation_smoke_test/d_ff.v"


module d_ff_tb;
    reg clk, reset, d;
    wire q;

    d_ff uut (
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
        $dumpvars(0, d_ff_tb);
        
        d = 0; #10;
        d = 1; #10;
        d = 0; #10;
        d = 1; #10;

        reset = 1; 
        #10 reset = 0;
        
        #50 $finish;

        end

endmodule