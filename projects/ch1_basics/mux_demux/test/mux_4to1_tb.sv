`timescale 1ns / 1ps

module mux_4to1_tb;

    // Testbench signals
    reg [1:0]  sel;
    reg [3:0]  d;
    wire       o;  

    // Instantiate the device under test (DUT)
     mux_4to1 uut (
        .i_sel(sel),
        .i_data(d),
        .o_selected(o)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, mux_4to1_tb);

        // Apply stimulus
        d = 4'b0110;
        
        sel = 'b00;
        #10;
        pretty_print_assert(o == 0, "output should be 0");

        // Change stimulus and test another scenario
        sel = 'b01;
        #10;
        pretty_print_assert(o == 1, "output should be 1");

        // Change stimulus and test another scenario
        sel = 'b10;
        #10;
        pretty_print_assert(o == 1, "output should be 1");

        // Change stimulus and test another scenario
        sel = 'b11;
        #10;
        pretty_print_assert(o == 0, "output should be 0");

        $finish;
    end

endmodule