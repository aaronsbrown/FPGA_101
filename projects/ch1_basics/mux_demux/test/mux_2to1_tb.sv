`timescale 1ns / 1ps

module mux_2to1_tb;

    // Testbench signals
    reg        sel;
    reg [1:0]  d;
    wire       o;  // Change the name to match the port mapping

    // Instantiate the device under test (DUT)
    mux2to1 uut (
        .i_sel(sel),
        .i_data(d),
        .o_selected(o)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, mux_2to1_tb);

        // Apply stimulus
        d = 2'b10;
        sel = 1;
        #10;
        // Use the helper function for assertion.
        // Adjust the expected value as appropriate (here we assume o should be 1)
        pretty_print_assert_cond(o == 1, "output should be 1");

        // Change stimulus and test another scenario
        sel = 0;
        #10;
        pretty_print_assert_cond(o == 0, "output should be 0");

        $finish;
    end

endmodule