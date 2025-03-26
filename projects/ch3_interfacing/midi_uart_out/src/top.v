// -----------------------------------------------------------------------------
// Module: top
// Description:
//   This is the top-level module for the MIDI UART output project. It periodically
//   sends a MIDI note (0x3C, Middle C) over UART at a 1 Hz interval. The module
//   includes pause functionality using a push button on the Alchitry Io board,
//   allowing the user to toggle MIDI note transmission on or off.
// -----------------------------------------------------------------------------

module top (
    input clk,                   // 100 MHz system clock
    input rst_n,                 // Active-low reset
    input usb_rx,                // Unused UART receive input
    output usb_tx,               // UART transmit output
    output [7:0] led,            // Debug LEDs
    input wire [4:0] io_button   // Button inputs from Alchitry Io board
);
    
    localparam BTN_PAUSE = 0;  // Button index for pause control

    // Pause control logic
    wire conditioned_edge_pause;   // 1-cycle pulse on pause button press
    reg is_paused;                 // Pause state toggle

    // Reset signal (active high for internal use)
    wire reset = ~rst_n;

    // Pulse generation and UART control
    wire send, busy;
    wire send_if_not_paused = send & ~is_paused; // Send signal conditioned on pause state

    // MIDI note to transmit (Middle C)
    reg [7:0] data = 8'h3C;
    
    // Debounce and detect edge of pause button
    button_conditioner b_pause (
        .clk(clk),
        .raw_button(io_button[BTN_PAUSE]),
        .conditioned_button_edge(conditioned_edge_pause) // Conditioned edge output for button press
    );

    // Generates a 1 Hz pulse to trigger MIDI send
    pulse_generator pg (
        .reset(!rst_n),
        .clk_in(clk),
        .pulse(send) // Output pulse to indicate when to send MIDI data
    );

    // UART transmitter module
    midi_uart_out ut (
        .clk(clk),
        .reset(~rst_n),
        .send(send_if_not_paused), // Send signal only if not paused
        .data(data),
        .tx(usb_tx),
        .busy(busy) // Indicates if UART is busy transmitting
    );

    // LED debug indicators
    // led[6] shows the raw send pulse
    // led[7] shows when UART is busy transmitting
    always @(*) begin
        led[6] = send;
        led[7] = busy;
    end

    // Toggle pause state on rising edge of pause button
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            is_paused <= 1'b0; // Initialize pause state to not paused
        end else if(conditioned_edge_pause) begin
            is_paused <= ~is_paused; // Toggle pause state on button press
        end
    end

endmodule
