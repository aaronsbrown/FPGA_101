`timescale 1ns / 1ps

module seg7_display_tb;
    // Declare testbench signals
    reg clk, reset;
    reg [7:0] digit;
    reg [6:0] seg7;
    reg [3:0] select;

    // Instantiate the DUT
    seg7_display uut (
        .clk(clk),
        .reset(reset),
        .number(digit),
        .seg7(seg7),
        .select(select)
    );

    always begin
        // Clock generation
        #5 clk = ~clk;
    end

    initial begin
        // Add testbench stimulus

        $dumpfile("waveform.vcd");
        $dumpvars(0, seg7_display_tb);  

        digit = 210;
        clk = 0;
        reset = 1;

        @(posedge clk);
        reset = 0;

        repeat(48) @(posedge clk);

        $display("Test complete at time %0t", $time);

        $finish;
    end

endmodule
