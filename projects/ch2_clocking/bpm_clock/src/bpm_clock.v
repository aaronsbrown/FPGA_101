module bpm_clock #(
    parameter BPM = 120,
    parameter CLOCK_FREQ = 25_000_000 // parameterize for testing
) (
    input clk,
    input reset,
    input bpm_inc, 
    input bpm_dec,

    // beats[0] = quarter
    // beats[1] = eighth    
    // beats[2] = sixteenth 
    output reg [4:0] beats,
    output reg [4:0] beat_triggers,
    output reg [7:0] o_bpm
);

    localparam MIN_BPM = 40;
    localparam MAX_BPM = 200;
    localparam BPM_RANGE_SIZE = MAX_BPM - MIN_BPM + 1;

    localparam QN_WIDTH = $clog2( (CLOCK_FREQ * 60 ) / MIN_BPM );
    localparam EN_WIDTH = $clog2( ((CLOCK_FREQ * 60 ) / MIN_BPM ) / 2);
    localparam SN_WIDTH = $clog2( ((CLOCK_FREQ * 60 ) / MIN_BPM ) / 4);

    // bit-width for each cell / number of cells in array
    reg [QN_WIDTH - 1:0] quarter_cycles_LUT [0:BPM_RANGE_SIZE-1];
    reg [EN_WIDTH - 1:0] eighth_cycles_LUT [0:BPM_RANGE_SIZE-1];
    reg [SN_WIDTH - 1:0] sixteenth_cycles_LUT [0:BPM_RANGE_SIZE-1];


    reg [7:0] bpm_current;
    reg [QN_WIDTH - 1:0] qn_counter;
    reg [EN_WIDTH - 1:0] en_counter;
    reg [SN_WIDTH - 1:0] sn_counter;

    integer i;
    integer qn;
    initial begin
        for ( i = 0; i < BPM_RANGE_SIZE; i = i + 1 ) begin
            qn = (CLOCK_FREQ * 60) / (MIN_BPM + i);
            quarter_cycles_LUT[i] = qn;
            eighth_cycles_LUT[i] = qn / 2;
            sixteenth_cycles_LUT[i] = qn / 4;
        end
        bpm_current = BPM;
    end

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            qn_counter <= 0;
            en_counter <= 0;
            sn_counter <= 0;
            bpm_current <= BPM;
            o_bpm <= 0;
            beats <= 5'b00000;
            beat_triggers <= 5'b00000;
        end else begin

            if (qn_counter < quarter_cycles_LUT[bpm_current - MIN_BPM] - 1) begin
                qn_counter <= qn_counter + 1;
                beat_triggers[0] <= 0;
            end else begin
                qn_counter <= 0;
                beats[0] <= ~beats[0];  
                beat_triggers[0] <= 1;
            end 

            if(en_counter < eighth_cycles_LUT[ bpm_current - MIN_BPM ] - 1) begin
                en_counter <= en_counter + 1;
                beat_triggers[1] <= 0;
            end else begin
                en_counter <= 0;
                beats[1] <= ~beats[1];  
                beat_triggers[1] <= 1;
            end

            if(sn_counter < sixteenth_cycles_LUT[ bpm_current - MIN_BPM ] - 1) begin
                sn_counter <= sn_counter + 1;
                beat_triggers[2] <= 0;
            end else begin
                sn_counter <= 0;
                beats[2] <= ~beats[2];  
                beat_triggers[2] <= 1;
            end 

            // increase BPM after updating counter
            if ( bpm_inc  && bpm_current < MAX_BPM ) begin
                bpm_current <= bpm_current + 10;
            end else if( bpm_dec && bpm_current > MIN_BPM ) begin
                bpm_current <= bpm_current - 10;
            end  

            o_bpm <= bpm_current;  
        end
    end

endmodule
