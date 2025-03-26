module sequencer #(
    parameter MIDI_CHANNEL = 4'd0
) (
    input   wire clk,                // 100 MHz system clock
    input   wire rst,                // async reset
    input   wire btn_inc_bpm,        // BPM up
    input   wire btn_dec_bpm,        // BPM down
    output  wire [7:0] leds,
    output  wire [23:0] io_leds,        // Debug LEDs
    output  wire [6:0] seg_display, // 7-segment display for BPM
    output  wire [3:0] seg_select,
    output  wire tx  
);

    // === BPM Clock Generator ===
    wire [7:0] bpm;
    wire [4:0] beats;
    wire [4:0] beat_triggers;
    bpm_clock u_bpm_clock (
        .clk(clk),
        .reset(rst),
        .bpm_inc(btn_inc_bpm),
        .bpm_dec(btn_dec_bpm),
        .beats(beats),
        .beat_triggers(beat_triggers),
        .o_bpm(bpm)
    );

    // === Step Sequencer ===
    wire pulse_8th = beat_triggers[1];
    wire [2:0] step_idx;
    seq_player u_seq_player(
        .clk(clk),
        .rst(rst),
        .pulse_choose_note(pulse_8th),
        .busy(busy),
        .pulse_send_note(trigger_send_note),
        .midi_note(midi_note),
        .midi_velocity(midi_velocity),
        .step_idx(step_idx)
    );

    // === MIDI Output ===
    wire busy;
    wire trigger_send_note;
    wire [6:0] midi_note;
    wire [6:0] midi_velocity;
   
    midi_note_sender u_midi_note_sender(
        .clk(clk),
        .reset(rst),
        .trigger(trigger_send_note),
        .channel(MIDI_CHANNEL),
        .note(midi_note),
        .velocity(midi_velocity),
        .tx(tx),
        .busy(busy)
    );
   

    // === LED Debug ===
    // localparam LED_WIDTH = 24;
    assign io_leds = { 21'b0, step_idx };
    assign leds[4:0] = beats;

    // === 7-Segment Display ===
    seg7_display u_seg7_display (
        .clk(clk),
        .reset(rst),
        .number(bpm),
        .seg7(seg_display),
        .select(seg_select)
    );

endmodule
