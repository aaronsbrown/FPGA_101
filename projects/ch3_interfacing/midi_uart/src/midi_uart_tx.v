// -----------------------------------------------------------------------------
// Module: midi_uart_tx
// Description:
//   Transmits an 8-bit byte over a UART serial connection using 8N1 format
//   (1 start bit, 8 data bits, 1 stop bit).
//   Takes a one-cycle 'send' pulse and outputs the byte serially on 'tx'.
//   The 'busy' signal indicates when the module is actively transmitting,
//   including the start, data, and stop bit times.
//
//   Parameters:
//     CLK_FREQ  : System clock frequency in Hz.
//     BAUD_RATE : Desired serial baud rate in Hz (e.g., 31250 for MIDI).
//
//   Ports:
//     clk    : System clock input.
//     reset  : Active high asynchronous reset.
//     send   : One-cycle high pulse to initiate transmission of 'data'.
//              Ignored if 'busy' is high.
//     data   : 8-bit data byte to transmit.
//     tx     : Serial data output line. Idle state is high.
//     busy   : Output signal, high while actively transmitting a frame.
//              (Corrected logic to cover full stop bit duration).
//
//   Timing: Assumes 'data' is stable when 'send' is pulsed high.
// -----------------------------------------------------------------------------

module midi_uart_tx #(
    parameter integer CLK_FREQ = 100_000_000,  // System clock frequency in Hz
    parameter integer BAUD_RATE = 31250        // Standard MIDI baud rate
) (
    input clk,                             // System clock
    input reset,                           // Asynchronous reset (active high)
    input send,                            // One-cycle send pulse
    input [7:0] data,                      // Byte to transmit
    output reg tx,                         // UART serial output
    output reg busy                        // High when transmitting
);

    // Calculate clock cycles per UART bit period
    // Ensure CLK_FREQ and BAUD_RATE are accurate for your system
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // Determine required width for the bit period counter
    // Use $clog2 to calculate the minimum number of bits needed to store CLKS_PER_BIT - 1
    localparam integer COUNTER_WIDTH = $clog2(CLKS_PER_BIT);

    // Sanity check during elaboration (simulation/synthesis)
    initial begin
        if (CLKS_PER_BIT < 16) begin // Check if timing resolution is potentially too low
           $display("Warning: [%m] CLKS_PER_BIT is low (%0d). Check CLK_FREQ (%0d) and BAUD_RATE (%0d). Timing accuracy might be compromised.", CLKS_PER_BIT, CLK_FREQ, BAUD_RATE);
        end
        if (CLKS_PER_BIT == 0) begin
             $fatal(1,"Error: [%m] CLKS_PER_BIT calculated as 0. BAUD_RATE is likely higher than CLK_FREQ or parameters are invalid.", CLKS_PER_BIT);
        end
    end

    // Internal state registers
    reg [9:0] shift_reg;      // Shift register: {Stop, Data[7:0], Start}
                               // Loaded as {1'b1 (Stop), data[7:0], 1'b0 (Start)}
    reg [3:0] bit_index;      // Tracks current bit being sent (0=Start, 1-8=Data, 9=Stop)
    reg [COUNTER_WIDTH-1:0] clk_count; // Counts clock cycles within a bit period

    // State machine / Control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset to idle state
            tx <= 1'b1;        // TX line idle high
            busy <= 1'b0;      // Not busy
            clk_count <= 0;
            bit_index <= 0;
            // shift_reg doesn't strictly need reset, loaded before use
        end else begin
            if (busy) begin
                // --- Currently Transmitting ---
                clk_count <= clk_count + 1;

                // Check if the timing for the current bit is complete
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0; // Reset counter for the next bit

                    // Check if we just finished the *Stop Bit*
                    if (bit_index == 9) begin
                        // Finished sending the stop bit, transaction complete
                        busy <= 1'b0;
                        // TX line should already be high (stop bit value), but ensure it stays high for idle
                        tx <= 1'b1;
                        // bit_index will reset on next 'send'
                    end else begin
                        // Finished Start or Data bit, move to the next bit
                        bit_index <= bit_index + 1;
                        // Output the next bit from the shift register
                        tx <= shift_reg[bit_index + 1];
                    end
                end
                // else: continue counting within the current bit period, tx holds its value

            end else begin // Not busy (idle state)
                tx <= 1'b1; // Keep TX line high when idle

                // Check for a request to send a new byte
                if (send) begin
                    // Load the shift register with the frame {Stop, Data, Start}
                    shift_reg <= {1'b1, data, 1'b0};
                    // Start transmission
                    busy <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;   // Start with index 0 (Start Bit)
                    tx <= 1'b0;       // Drive TX low for the Start Bit immediately
                end
                // else: remain idle
            end
        end
    end

endmodule