// common/modules/music/note_sequence.v
module note_sequence #(
    parameter N = 3  // 3-bit index = 8 notes
)(
    input  wire        clk,
    input  wire [N-1:0] index,
    output reg  [7:0]  note
);

    // Simple synchronous ROM
    always @(posedge clk) begin
        case (index)
            3'd0: note <= 8'd60; // C4
            3'd1: note <= 8'd62; // D4
            3'd2: note <= 8'd63; // Eb4
            3'd3: note <= 8'd65; // F4
            3'd4: note <= 8'd67; // G4
            3'd5: note <= 8'd68; // Ab4
            3'd6: note <= 8'd70; // Bb4
            3'd7: note <= 8'd72; // C5
            default: note <= 8'd0;
        endcase
    end

endmodule