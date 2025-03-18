`timescale 1ns/1ps

module fpga_counter_top_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg usb_rx;
    wire usb_tx;
    wire [7:0] led;

    // Instantiate the Device Under Test (DUT)
    fpga_counter_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .usb_rx(usb_rx),
        .usb_tx(usb_tx),
        .led(led)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation stimulus
    initial begin
        // Dump waveform for GTKWave
        $dumpfile("waveform.vcd");
        $dumpvars(0, fpga_counter_top_tb);
        
        // Initialize inputs
        rst_n = 0;
        usb_rx = 0; // Assuming USB RX is not used in this simulation

        // Apply reset
        #20;
        rst_n = 1;

        // Let the simulation run long enough to see counter activity
        #1000000;  // Adjust simulation duration as needed

        $finish;
    end

endmodule
