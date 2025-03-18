module d_ff (
    input clk,
    input reset,
    input d,
    output reg q
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
           q <= 0; 
        end else begin
            q <= d;
        end
    end
endmodule

module register_4b (
    input clk, 
    input reset,
    input [3:0] d,
    output [3:0] q
);
    d_ff dff0(clk, reset, d[0], q[0]);
    d_ff dff1(clk, reset, d[1], q[1]);
    d_ff dff2(clk, reset, d[2], q[2]);
    d_ff dff3(clk, reset, d[3], q[3]);
endmodule

module register_nb #(parameter N = 4) (clk, reset, d, q);
    input clk, reset;
    input [N-1:0] d;
    output [N-1:0] q;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen
            d_ff dff_inst(clk, reset, d[i], q[i]);
        end
    endgenerate
endmodule