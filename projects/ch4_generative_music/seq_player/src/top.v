module top (
    input clk,
    input rst_n,
    output usb_tx
);
    
    wire rst = ~rst_n;
    reg pulse_choose_note;
    reg [7:0] midi_note;
    reg pulse_send_note;
    wire busy;

    // pulse generator
    pulse_generator pg (
        .reset(rst),
        .clk_in(clk),
        .pulse(pulse_choose_note)
    );

    seq_player u_seq_player(
        .clk(clk),
        .rst(rst),
        .pulse_choose_note(pulse_choose_note),
        .busy(busy),
        .pulse_send_note(pulse_send_note),
        .midi_note(midi_note)
    );

    // midi_note_sender
    midi_note_sender mns (
        .clk(clk),
        .reset(rst),
        .trigger(pulse_send_note),
        .channel(4'd0),
        .note(midi_note),
        .velocity(7'd100),
        .tx(usb_tx),
        .busy(busy)
    );
     
endmodule
