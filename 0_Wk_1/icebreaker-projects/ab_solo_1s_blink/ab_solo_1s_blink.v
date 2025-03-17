module ab_solo_1s_blink (clk, rst_n, led, usb_rx, usb_tx);

    input wire clk;
    output wire [7:0] led;

    input wire rst_n;
    
    input wire usb_rx;
    output wire usb_tx;

    // 27 bit register!
    parameter N = 26;
    reg [N-1:0] d;
    wire [N-1:0] q;

    register_nb #( .N(N) ) counter (
        .clk(clk),
        .reset(!rst_n),
        .d(d),
        .q(q)
    );

    always @(posedge clk) begin
        d <= q + 1;
    end

    assign led[0] = q[N-1];

endmodule