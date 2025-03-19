module bpm_pulse_generator #(
    parameter BPM = 120,
    parameter CLOCK_FREQ = 100_000_000
) (
    input wire clk,
    input wire reset,
    output reg [4:0] beats
);

    localparam integer QUARTER_NOTE_CYCLES = (CLOCK_FREQ * 60) / BPM; 
    localparam integer WHOLE_NOTE_CYCLES = QUARTER_NOTE_CYCLES * 4;
    localparam integer HALF_NOTE_CYCLES = QUARTER_NOTE_CYCLES * 2;
    localparam integer EIGHTH_NOTE_CYCLES = QUARTER_NOTE_CYCLES / 2;
    localparam integer SIXTEENTH_NOTE_CYCLES = QUARTER_NOTE_CYCLES / 4;
    
    localparam  WN_WIDTH = $clog2(WHOLE_NOTE_CYCLES);
    reg [WN_WIDTH-1:0] whole_note_counter ;
    
    localparam  HN_WIDTH = $clog2(HALF_NOTE_CYCLES);
    reg [HN_WIDTH-1:0] half_note_counter;

    localparam  QN_WIDTH = $clog2(QUARTER_NOTE_CYCLES);
    reg [QN_WIDTH-1:0] quarter_note_counter;
    
    localparam  EN_WIDTH = $clog2(EIGHTH_NOTE_CYCLES);
    reg [EN_WIDTH-1:0] eighth_note_counter;
    
    localparam  SN_WIDTH = $clog2(SIXTEENTH_NOTE_CYCLES);
    reg [SN_WIDTH-1:0] sixteenth_note_counter;
        


    always @(posedge clk or posedge reset) begin
        if(reset) begin
            whole_note_counter <= 0;
            half_note_counter <= 0;
            quarter_note_counter <= 0;
            eighth_note_counter <= 0;
            sixteenth_note_counter <= 0;
            beats <= 5'b00000;
        end else begin
            
          if (whole_note_counter == WHOLE_NOTE_CYCLES - 1 ) begin
                whole_note_counter <= 0;
                beats[0] <= ~beats[0];
            end else begin
                whole_note_counter <= whole_note_counter + 1;
            end

            if (half_note_counter == HALF_NOTE_CYCLES - 1 ) begin
                half_note_counter <= 0;
                beats[1] <= ~beats[1];
            end else begin
                half_note_counter <= half_note_counter + 1;
            end 
            
            if (quarter_note_counter == QUARTER_NOTE_CYCLES - 1 ) begin
                quarter_note_counter <= 0;
                beats[2] <= ~beats[2];
            end else begin
                quarter_note_counter <= quarter_note_counter + 1;
            end

            if (eighth_note_counter == EIGHTH_NOTE_CYCLES - 1 ) begin
                eighth_note_counter <= 0;
                beats[3] <= ~beats[3];
            end else begin
                eighth_note_counter <= eighth_note_counter + 1;
            end

            if (sixteenth_note_counter == SIXTEENTH_NOTE_CYCLES - 1 ) begin
                sixteenth_note_counter <= 0;
                beats[4] <= ~beats[4];
            end else begin
                sixteenth_note_counter <= sixteenth_note_counter + 1;
            end           
         end
    end
endmodule
