// common/modules/music/note_sequence.v
module note_sequence #(
    parameter INDEX_WIDTH = 3'b011  // 3-bit index = 8 notes
)(
    input  wire         clk,
    input  wire [INDEX_WIDTH-1:0] index,
    output reg  [6:0]   note,
    output reg  [6:0]  velocity
);

    // Simple synchronous ROM
    always @(posedge clk) begin
        case (index)
            3'b000: begin
                note <= 7'd60; // C4
                velocity <= 8'd100;
            end
            3'b001:  begin
                note <= 7'd62; // D4
                velocity <= 7'd80;
            end
            3'b010:  begin
                note <= 7'd63; // Eb4
                velocity <= 7'd70;
                end
            3'b011:  begin
                note <= 7'd65; // F4
                velocity <= 7'd100;
            end
            3'b100:  begin
                note <= 7'd67; // G4
                velocity <= 7'd100;
            end
            3'b101:  begin
                note <= 7'd68; // Ab4
                velocity <= 7'd80;
            end
            3'b110:  begin
                note <= 7'd70; // Bb4
                velocity <= 7'd70;
            end
            3'b111:  begin
                note <= 7'd72; // C5
                velocity <= 7'd100;
            end
            default: begin
                note <= 7'd0;
                velocity <= 7'd100;
            end
        endcase
    end

endmodule