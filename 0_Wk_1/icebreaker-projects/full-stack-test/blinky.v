module blinky (
    input clk,
    output reg led
);
    
    reg [22:0] counter = 0;  // Smaller counter (faster blink)

    always @(posedge clk) begin
        counter <= counter + 1;
        led <= counter[22];  // Faster blink
    end
endmodule
