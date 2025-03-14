module blinky (
    input clk,   // Input clock
    output reg [7:0] led  // 8 LEDs to blink
);
    reg [28:0] counter = 0;  // 25-bit counter to slow down blinking

    always @(posedge clk) begin
        counter <= counter + 1;
        // Each LED toggles at different bits of the counter to create different blink speeds
        led[0] <= counter[28];  // LED0 blinks at a rate based on the most significant bit
        led[1] <= counter[27];
        led[2] <= counter[26];
        led[3] <= counter[25];
        led[4] <= counter[24];
        led[5] <= counter[23];
        led[6] <= counter[22];
        led[7] <= counter[21];  // LED7 blinks the slowest
    end
endmodule
