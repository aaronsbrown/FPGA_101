module note_counter #(
    parameter COUNT_IDX = 3'b011,
    parameter MAX = 4'b1000
)(
    input  wire clk,
    input  wire rst,
    input  wire enable,       // Advance on pulse
    output reg [COUNT_IDX-1:0] count
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