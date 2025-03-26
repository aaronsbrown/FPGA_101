module seq_player #(
    parameter NOTE_COUNT = 3
)(
    input clk,
    input rst,
    input pulse_choose_note,
    input busy,
    output reg pulse_send_note,
    output [7:0] midi_note,
    output [7:0] midi_velocity,
    output [STEP_IDX_WIDTH-1:0] step_idx  
);
    localparam STEP_IDX_WIDTH = $clog2(NOTE_COUNT);
    localparam WAIT_FOR_TICK = 2'd0,
               SEND_NOTE = 2'd1;
    reg [1:0] state;
    

    note_counter nc (
        .clk(clk),
        .rst(rst),
        .enable(pulse_choose_note),
        .count(step_idx)
    );

     // note_sequence
    note_sequence #( .N(NOTE_COUNT) ) ns (
        .clk(clk),
        .index(step_idx),
        .note(midi_note),
        .velocity(midi_velocity)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pulse_send_note <=0;
            state <= WAIT_FOR_TICK;
        end else begin
            case (state)
                WAIT_FOR_TICK: begin
                    pulse_send_note <= 0; // Clear send pulse
                    // When the transmitter isn't busy and we get a pulse to choose a note...
                    if (!busy && pulse_choose_note)
                        state <= SEND_NOTE;
                end
                SEND_NOTE: begin
                    pulse_send_note <= 1; // Assert pulse for one cycle to trigger sending
                    state <= WAIT_FOR_TICK;
                end
            endcase
        end
    
    end

endmodule
