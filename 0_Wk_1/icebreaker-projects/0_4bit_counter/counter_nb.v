module counter_nb #(parameter N = 4) (
    input wire clk, reset,
    output reg [N-1:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= {N{1'b0}};
        end else begin
            q <= q + 1;
        end
        
    end

endmodule
