`timescale 1ns / 1ps

module pulse_generator_tb;
    // Declare testbench signals

    reg clk, reset;
    wire pulse;


    // Instantiate the DUT
    pulse_generator #( .CYCLE_TIME(4) ) uut (
        .reset(reset),
        .clk_in(clk),
        .pulse(pulse)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, pulse_generator_tb);
        
        // Add testbench stimulus

        clk = 0;
        reset = 1;
        trigger = 0;

        @(posedge clk);
        reset = 0;

        repeat(40) @(posedge clk);

        $display("Test complete at time %0t", $time);
        $finish;
    end

endmodule
