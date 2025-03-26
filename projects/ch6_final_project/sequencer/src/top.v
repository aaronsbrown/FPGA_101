module top (
    input clk,
    input rst_n,
    // output [7:0] led,
    output usb_tx,
    output reg [23:0] io_led,
    output reg [7:0] io_segment,
    output reg [3:0] io_select,
    input wire [4:0] io_button
);

    localparam BTN_INC = 0;
    localparam BTN_DEC = 2;

    reg conditioned_button_edge_inc;
    reg conditioned_button_edge_dec;

    button_conditioner b_inc (
        .clk(clk),
        .raw_button(io_button[BTN_INC]),
        .conditioned_button_edge(conditioned_button_edge_inc)
    );

    button_conditioner b_dec (
        .clk(clk),
        .raw_button(io_button[BTN_DEC]),
        .conditioned_button_edge(conditioned_button_edge_dec)
    );

    sequencer u_sequencer (
        .clk(clk),
        .rst(~rst_n),
        .btn_inc_bpm(conditioned_button_edge_inc),
        .btn_dec_bpm(conditioned_button_edge_dec),
        .leds(io_led),
        .seg_display(io_segment[6:0]),
        .seg_select(io_select),
        .tx(usb_tx)
    );

endmodule
