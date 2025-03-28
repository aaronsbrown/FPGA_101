//-----------------------------------------------------------------------------
// Module: midi_note_sender
// Description:
//   Takes a single 'trigger' pulse and sends a complete 3-byte MIDI Note On
//   message (Status, Note, Velocity) using the midi_uart_tx module.
//   Handles the multi-byte sequence and manages the overall busy signal.
//   Includes latching for inputs and a wait state for robust busy handling.
//
//   Version: Includes WAIT_LAST_BYTE state.
//-----------------------------------------------------------------------------
module midi_note_sender (
    input clk,
    input reset,           // Active high asynchronous reset
    input trigger,         // One-cycle pulse to start sending a note
    input [3:0] channel,   // MIDI Channel (0-15)
    input [6:0] note,      // MIDI Note Number (0-127)
    input [6:0] velocity,  // MIDI Velocity (0-127)
    output tx,             // Serial TX output (to FPGA pin)
    output busy            // High when this module is busy sending the sequence
);

    // --- State Definitions ---
    // Use 3 bits for 5 states
    localparam [2:0] IDLE = 3'd0,           // Waiting for trigger
                     SEND_STATUS = 3'd1,    // Preparing/Sending Status byte
                     SEND_NOTE = 3'd2,      // Preparing/Sending Note byte
                     SEND_VELOCITY = 3'd3,  // Preparing/Sending Velocity byte
                     WAIT_LAST_BYTE = 3'd4; // Waiting for UART to finish Velocity byte

    reg [2:0] state;

    // --- Input Latching Registers ---
    // Capture inputs when trigger arrives to avoid race conditions
    reg [6:0] latched_note;
    reg [6:0] latched_velocity;
    reg [3:0] latched_channel;
    // ------------------------------

    // --- UART Interface Signals ---
    reg uart_send;     // Goes to midi_uart_tx 'send' input (pulse)
    reg uart_send_d;   // Internal signal to help generate one-cycle pulse
    reg [7:0] uart_data; // Goes to midi_uart_tx 'data' input

    // Busy signal FROM the uart instance
    wire uart_is_busy; // Connects to midi_uart_tx 'busy' output

    // --- Instantiate the UART TX module ---
    // IMPORTANT: Ensure parameters (especially BAUD_RATE) are correct here
    //            or overridden correctly for debugging (like the 10 baud test).
    midi_uart_tx #(
        // .CLK_FREQ(100_000_000), // Assuming default or correctly set elsewhere
        .BAUD_RATE(31250)       // Standard MIDI Baud Rate
    ) uart (
        .clk(clk),
        .reset(reset),
        .send(uart_send),
        .data(uart_data),
        .tx(tx),
        .busy(uart_is_busy)
    );

    // --- Module Busy Output Logic ---
    // This module is busy whenever its state machine is not IDLE.
    // The WAIT_LAST_BYTE state ensures we stay busy until the UART is truly finished.
    assign busy = (state != IDLE);

    // --- State Machine Logic ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all state and control signals
            state <= IDLE;
            uart_send <= 1'b0;
            uart_send_d <= 1'b0;
            uart_data <= 8'b0;
            latched_note <= 7'b0;
            latched_velocity <= 7'b0;
            latched_channel <= 4'b0;
        end else begin
            // Manage the one-cycle pulse generation for uart_send
            // uart_send gets the value uart_send_d had in the previous cycle
            uart_send <= uart_send_d;
            // Default uart_send_d to 0, it will be set high for one cycle when needed
            uart_send_d <= 1'b0;

            // State transitions
            case (state)
                IDLE: begin
                    // If triggered and the UART is not still busy from a previous operation
                    // (Shouldn't be needed because of WAIT_LAST_BYTE, but safe)
                    if (trigger && !uart_is_busy) begin
                        // Latch the current inputs
                        latched_note <= note;
                        latched_velocity <= velocity;
                        latched_channel <= channel;
                        // Start the sequence
                        state <= SEND_STATUS;
                    end
                end

                SEND_STATUS: begin
                    // Wait until the UART hardware is free
                    if (!uart_is_busy) begin
                        // Prepare Status byte (Note On = 0x9)
                        uart_data <= {4'h9, latched_channel};
                        // Schedule the UART 'send' pulse for the next clock cycle
                        uart_send_d <= 1'b1;
                        // Move to the next state
                        state <= SEND_NOTE;
                    end
                end

                SEND_NOTE: begin
                    // Wait until the UART hardware has finished sending the Status byte
                    if (!uart_is_busy) begin
                        // Prepare Note byte (ensure MSB is 0)
                        uart_data <= {1'b0, latched_note};
                        // Schedule the UART 'send' pulse for the next clock cycle
                        uart_send_d <= 1'b1;
                        // Move to the next state
                        state <= SEND_VELOCITY;
                    end
                end

                SEND_VELOCITY: begin
                    // Wait until the UART hardware has finished sending the Note byte
                    if (!uart_is_busy) begin
                        // Prepare Velocity byte (ensure MSB is 0)
                        uart_data <= {1'b0, latched_velocity};
                        // Schedule the UART 'send' pulse for the next clock cycle
                        uart_send_d <= 1'b1;
                        // Go to wait state to ensure this last byte completes
                        state <= WAIT_LAST_BYTE;
                    end
                end

                WAIT_LAST_BYTE: begin
                    // Stay here until the UART hardware has finished sending the Velocity byte
                    if (!uart_is_busy) begin
                        // Sequence complete, return to idle
                        state <= IDLE;
                    end
                end

                default: state <= IDLE; // Ensure defined behavior for invalid states

            endcase
        end
    end

endmodule