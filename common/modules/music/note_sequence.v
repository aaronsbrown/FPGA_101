// common/modules/music/note_sequence.v
module note_sequence #(
    parameter N = 3  // 3-bit index = 8 notes
)(
    input  wire         clk,
    input  wire [N-1:0] index,
    output reg  [7:0]   note,
    output reg  [7:0]  velocity
);

    // Simple synchronous ROM
    always @(posedge clk) begin
        case (index)
            3'd0: begin
                note <= 8'd60; // C4
                velocity <= 8'd100;
            end
            3'd1:  begin
                note <= 8'd62; // D4
                velocity <= 8'd80;
            end
            3'd2:  begin
                note <= 8'd63; // Eb4
                velocity <= 8'd70;
                end
            3'd3:  begin
                note <= 8'd65; // F4
                velocity <= 8'd100;
            end
            3'd4:  begin
                note <= 8'd67; // G4
                velocity <= 8'd100;
            end
            3'd5:  begin
                note <= 8'd68; // Ab4
                velocity <= 8'd80;
            end
            3'd6:  begin
                note <= 8'd70; // Bb4
                velocity <= 8'd70;
            end
            3'd7:  begin
                note <= 8'd72; // C5
                velocity <= 8'd100;
            end
            default: begin
                note <= 8'd0;
                velocity <= 8'd100;
            end
        endcase
    end

endmodule