module top (
    input clk,
    input rst_n,
    output usb_tx
);
    localparam N = 3;

    localparam WAIT_FOR_TICK = 2'd0,
               SEND_NOTE = 2'd1;
    reg [1:0] state;

    wire rst = ~rst_n;
    reg pulse_choose_note;
    reg [N-1:0] note_selection;
    reg [7:0] midi_note;
    reg pulse_send_note;
    wire busy;


    // pulse generator
    pulse_generator pg (
        .reset(rst),
        .clk_in(clk),
        .pulse(pulse_choose_note)
    );

    // note_counter -- increments note_selection on pulse_choose_note
    note_counter nc (
        .clk(clk),
        .rst(rst),
        .enable(pulse_choose_note),
        .count(note_selection)
    );

    // note_sequence
    note_sequence #( .N(N) ) ns (
        .clk(clk),
        .index(note_selection),
        .note(midi_note)
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
     
    always @(posedge clk or posedge rst) begin

        if(rst) begin
            pulse_choose_note <= 0;
            pulse_send_note <=0;
            note_selection <=0;
            midi_note <=0;
            state <= WAIT_FOR_TICK;
        end else begin
            case (state)
                WAIT_FOR_TICK: begin
                    pulse_send_note <= 0;
                    if (!busy && pulse_choose_note)
                        state <= SEND_NOTE;
                end
                SEND_NOTE: begin
                    pulse_send_note <= 1;
                    state <= WAIT_FOR_TICK;
                end
            endcase
        end

    end


endmodule
