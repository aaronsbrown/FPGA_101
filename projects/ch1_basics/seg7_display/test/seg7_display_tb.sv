`timescale 1ns / 1ps

module seg7_display_tb;
    // Declare testbench signals
    reg clk, slow_clk, reset;
    reg [7:0] digit;
    reg [6:0] seg7;
    reg [3:0] select;

    clock_divider #(
        .DIV_FACTOR(10)
    ) clk_div (
        .reset(reset),
        .clk_in(clk),
        .clk_out(slow_clk)
    );


    // Instantiate the DUT
    seg7_display uut (
        .clk(slow_clk),
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
        
        $dumpfile("waveform.vcd");
        $dumpvars(0, seg7_display_tb);  

        // Add testbench stimulus
        digit = 210;
        clk = 0;
        reset = 1;

        @(posedge clk);
        reset = 0;
    
        repeat(5) @(posedge clk);
        pretty_print_assert_8bit(select, 4'b1110, "select should be b1110");
        pretty_print_assert_8bit(seg7, {1'b0, 7'b1000000}, "seg7 should be b1000000");

        repeat(20) @(posedge clk);
        pretty_print_assert_8bit(select, 4'b1101, "select should be b1101");
        pretty_print_assert_8bit(seg7, {1'b0, 7'b1111001}, "seg7 should be b1000000");

        repeat(20) @(posedge clk);
        pretty_print_assert_8bit(select, 4'b1011, "select should be b1011");
        pretty_print_assert_8bit(seg7, {1'b0, 7'b0100100}, "seg7 should be b1000000");

        repeat(20) @(posedge clk);
        pretty_print_assert_8bit(select, 4'b1110, "select should be b1110");
        pretty_print_assert_8bit(seg7, {1'b0, 7'b1000000}, "seg7 should be b1000000");


        $display("Test complete at time %0t", $time);
        $finish;
    end

endmodule
