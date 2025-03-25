module note_counter #(
    parameter N = 3,
    parameter MAX = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,       // Advance on pulse
    output reg [N-1:0] count
);

    // 1.	On every pulse tick → advance to the next note.
	// 2.	Wrap around to the beginning when the end of the sequence is reached.
	// 3.	Resettable – so you can start the sequence over from step 0.
	// 4.	Optional: add a pause/enable input so you can stop advancing without resetting.

    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
        end else begin
            if (enable) begin
                if (count == MAX - 1)
                    count <=0;      
                else 
                    count <= count + 1;
            end
        end

    end

endmodule