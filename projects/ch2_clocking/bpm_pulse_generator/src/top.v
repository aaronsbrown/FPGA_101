module top (
    input clk,
    input rst_n,
    input usb_rx,
    output usb_tx,
    output [7:0] led
);
    wire [4:0] o_beats;

    bpm_pulse_generator #(
        .BPM(60)
    ) pulse_gen (
        .clk(clk),
        .reset(~rst_n),
        .beats(o_beats)
    );

    assign led[4:0] = o_beats;

endmodule
