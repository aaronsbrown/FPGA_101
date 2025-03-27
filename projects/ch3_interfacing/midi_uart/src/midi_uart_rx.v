module midi_uart_rx #(
    parameter CLK_FREQ = 100_000_000,  // System clock frequency in Hz
    parameter BAUD_RATE = 115200       // UART baud rate
) (
    input  wire clk,
    input  wire reset,     // Active-high reset
    input  wire rx,        // UART RX input
    output reg  [7:0] data_out,
    output reg  valid      // Goes high for 1 cycle when a full byte is received
);

    // Calculate how many clock cycles each bit lasts
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // State machine states
    localparam IDLE       = 3'd0;
    localparam START_BIT  = 3'd1;
    localparam DATA_BITS  = 3'd2;
    localparam STOP_BIT   = 3'd3;

    reg [2:0]  state       = IDLE;
    reg [3:0]  bit_index   = 0;       // Which bit of the byte we're on
    reg [15:0] clk_count   = 0;       // Counts how many cycles have passed
    reg [7:0]  rx_shiftreg = 0;       // Shift register to collect data bits

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= IDLE;
            bit_index   <= 0;
            clk_count   <= 0;
            data_out    <= 8'b0;
            valid       <= 0;
            rx_shiftreg <= 8'b0;
        end else begin
            valid <= 0; // Default: not asserting valid

            case (state)
                IDLE: begin
                    // Wait for RX to go low (start bit)
                    if (rx == 0) begin
                        state     <= START_BIT;
                        clk_count <= 0;
                    end
                end

                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT - 1)/2) begin
                        // Sample halfway into start bit
                        if (rx == 0) begin
                            // Still a valid start bit
                            state     <= DATA_BITS;
                            bit_index <= 0;
                        end else begin
                            // False start
                            state <= IDLE;
                        end
                        clk_count <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA_BITS: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        // Sample the data bit
                        rx_shiftreg[bit_index] <= rx;
                        clk_count <= 0;
                        // Move to next bit
                        if (bit_index == 7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP_BIT: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        // Sample stop bit (should be 1)
                        state <= IDLE;
                        clk_count <= 0;
                        data_out <= rx_shiftreg;
                        valid <= 1;  // Byte received
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

            endcase
        end
    end

endmodule