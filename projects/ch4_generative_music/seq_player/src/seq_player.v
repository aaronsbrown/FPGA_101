module seq_player #(
    parameter STEP_IDX_WIDTH = 3'b011
)(
    input clk,
    input rst,
    input pulse_choose_note,
    input busy,
    output reg pulse_send_note,
    output [6:0] midi_note,
    output [6:0] midi_velocity,
    output [STEP_IDX_WIDTH-1:0] step_idx  
);

    // localparam STEP_IDX_WIDTH = NOTE_COUNT;
    localparam WAIT_FOR_TICK = 2'd0,
               SEND_NOTE = 2'd1;
    reg [1:0] state;
    

    note_counter u_note_counter (
        .clk(clk),
        .rst(rst),
        .enable(pulse_choose_note),
        .count(step_idx)
    );

     // note_sequence
    note_sequence #( .INDEX_WIDTH(STEP_IDX_WIDTH) ) u_note_sequence (
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
