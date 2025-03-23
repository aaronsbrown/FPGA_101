module top (
    input clk,                   // 100 MHz system clock
    input rst_n,                 // Active-low reset
    input usb_rx,                // Unused UART receive input
    output usb_tx,               // UART transmit output
    output [7:0] led,            // Debug LEDs
    input wire [4:0] io_button   // Button inputs from Alchitry Io board
);

endmodule
