module fpga_counter_top (
    input   wire    clk,
    input   wire    rst_n,
    input   wire    usb_rx,
    output  wire    usb_tx,
    output  wire    [7:0] led
);

    parameter N = 8;

    wire [N-1:0] q;
    wire div_clk;

    clock_divider #(
        .DIV_FACTOR(12500000)
    )
    divider (
        .reset(~rst_n),
        .clk_in(clk),
        .clk_out(div_clk)
    );

    counter_nb #( 
        .N(N) 
    ) counter (
        .clk(div_clk),
        .reset(~rst_n),
        .q(q)
    );

    assign led = (N > 8) ? q[7:0] : { {(8-N){1'b0}}, q };

endmodule

