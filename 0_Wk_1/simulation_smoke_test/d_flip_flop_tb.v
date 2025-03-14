`timescale 1ns/1ps

module d_flip_flop_tb;
    reg clk, d;
    wire q;

    d_flip_flop uut (
        .clk(clk),
        .d(d),
        .q(q)
    );

    initial begin
        clk = 0;
    end

    always begin
        #5 clk = ~clk;
        //$display("Time=%0t | clk=%b", $time, clk);  // ✅ Print clock state

    end

    initial begin
        // ✅ Monitor changes
        $monitor("Time=%0t | clk=%b | d=%b | q=%b", $time, clk, d, q);


        $dumpfile("waveform_data_flip_flop.vcd");
        $dumpvars(0, d_flip_flop_tb);
        
        d = 0; #10;
        d = 1; #10;
        d = 0; #10;
        d = 1; #10;
        
        #50 $finish;

        end

endmodule