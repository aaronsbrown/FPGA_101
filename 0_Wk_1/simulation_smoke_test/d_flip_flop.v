module d_flip_flop(
    input clk,
    input d,
    output reg q
);

    initial q = 0;

    always @(posedge clk) begin
        q <= d;
    end
endmodule