// -----------------------------------------------------------------------------
// Module: pulse_generator
// Description:
//   This module generates a single-cycle pulse every CYCLE_TIME clock cycles.
//   Useful for periodic triggering events such as 1Hz beat generation.
// -----------------------------------------------------------------------------

module pulse_generator #(
    parameter CYCLE_TIME = 100_000_000  // Number of clock cycles between pulses
) (
    input   wire    reset,              // Active-high asynchronous reset
    input   wire    clk_in,             // Input clock
    output  reg     pulse               // Output pulse signal (1 clk cycle wide)
);

    reg [26:0] counter;                 // Counter to track clock cycles
    
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;               // Reset counter
            pulse <= 0;                 // Clear pulse
        end else begin
            if(counter == CYCLE_TIME - 1) begin
                pulse <= 1;             // Generate 1-cycle pulse
                counter <= 0;           // Reset counter after pulse
            end else begin
                pulse <= 0;             // Keep pulse low between triggers
                counter <= counter + 1; // Increment counter
            end
        end
    end

endmodule