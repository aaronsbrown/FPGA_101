// -----------------------------------------------------------------------------
// Module: midi_uart_tx
// Description:
//   This module transmits an 8-bit byte over a UART serial connection using
//   8N1 format (1 start bit, 8 data bits, 1 stop bit). It takes a one-cycle
//   'send' pulse and emits the UART-encoded byte over the 'tx' output.
// -----------------------------------------------------------------------------

module midi_uart_tx #(
    parameter integer CLK_FREQ = 100_000_000,                 // Clock frequency in Hz
    parameter BAUD_RATE = 115200           // UART baud rate
) (
    input clk,                             // System clock
    input reset,                           // Asynchronous reset (active high)
    input send,                            // One-cycle send pulse
    input [7:0] data,                      // Byte to transmit
    output reg tx,                         // UART serial output
    output reg busy                        // High when transmitting
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;     // Clock cycles per UART bit

    reg [9:0] shift_reg;              // Shift register: {stop, data[7:0], start}
    reg [3:0] bit_index;              // Index for current bit being sent (0-9)
    reg [15:0] clk_count;             // Clock cycle counter for baud timing

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1;                  // Idle state for UART is high
            busy <= 0;                // Not transmitting
            clk_count <= 0;           // Reset clock counter
            bit_index <= 0;           // Reset bit index
        end else begin
            if (!busy) begin           // If not busy transmitting
                if (send) begin        // If send signal is high
                    // Load UART frame: {1 stop bit, 8 data bits, 1 start bit}
                    shift_reg <= {1'b1, data, 1'b0};
                    busy <= 1;          // Set busy flag
                    bit_index <= 0;     // Start with the first bit
                    clk_count <= 0;     // Reset clock counter
                end
            end else begin               // If busy transmitting
                clk_count <= clk_count + 1; // Increment clock counter

                // After CLKS_PER_BIT cycles, send the next bit
                if (clk_count == CLKS_PER_BIT - 1) begin
                    tx <= shift_reg[bit_index];  // Output current bit
                    bit_index <= bit_index + 1;   // Move to the next bit
                    clk_count <= 0;                // Reset clock counter

                    if (bit_index == 9) begin     // If all bits have been sent
                        busy <= 0;                 // Clear busy flag
                        tx <= 1;                   // Return to idle state
                    end
                end
            end
        end
    end

endmodule
