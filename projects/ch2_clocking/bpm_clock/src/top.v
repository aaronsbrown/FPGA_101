module top (
    input wire  clk,
    input wire  rst_n,
    output reg [7:0] led,
    input wire usb_rx,
    output reg usb_tx,
    output reg [23:0 ] io_led,
    output reg [7:0] io_segment,
    output reg [3:0] io_select,
    input wire [4:0] io_button,
    input wire [23:0] io_dip
);
    
    // TODO: Add comments or localparams to clarify beat-to-LED mapping
    // Example: led[0] = quarter, led[1] = eighth, led[2] = sixteenth

    // TODO: Convert one of the beat outputs (e.g., sixteenth note) from toggle mode to one-cycle pulse mode
    // Tip: Set beats[2] <= 1 for one cycle when counter hits, then clear back to 0 in the else block

    // TODO: Create a 7-segment display module to show the current BPM value
    // Hint: This will require splitting bpm_current into digits and mapping each to 7-segment segments

    // TODO: Route current BPM value to the display driver once implemented
    // You can use io_segment and io_select to control which digits are active

    // TODO: (Optional) Consider sending beat pulses to Teensy or external gear
    // This may use GPIOs or DAC/CV outputs to drive external synth or MIDI components

    // TODO: (Optional) Add tap tempo functionality using a button and timestamping logic
    // This is more advanced but lets you "tap in" the desired BPM by measuring time between presses

    localparam BTN_INC = 0;
    localparam BTN_DEC = 2;

    reg [7:0] bpm;
    reg [4:0] o_beats;
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

    bpm_clock beat_clock (
        .clk(clk),
        .reset(~rst_n),
        .bpm_inc(conditioned_button_edge_inc),
        .bpm_dec(conditioned_button_edge_dec),
        .beats(o_beats),
        .o_bpm(bpm)
    );

    wire slow_clk;
    clock_divider #(
        .DIV_FACTOR(50_000)
    ) clk_div (
        .reset(~rst_n),
        .clk_in(clk),
        .clk_out(slow_clk)
    );

    seg7_display u_display (
        .clk(slow_clk),
        .reset(~rst_n),
        .number(bpm),
        .seg7( io_segment[6:0] ),
        .select(io_select)
    );

    always @(*) begin
        usb_tx = usb_rx;
        io_led = 24'h000000;
        //io_segment = 8'hff;
        //io_select = 4'hf;
    end

    assign led[4:0] = o_beats;
    assign led[6] = io_button[BTN_DEC];
    assign led[7] = io_button[BTN_INC];
    //assign led = { 3'h0, io_button[4:0] };

endmodule
