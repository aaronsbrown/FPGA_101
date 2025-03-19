module mux_4to1 (

    input [1:0] i_sel,
    input [3:0] i_data,
    output reg o_selected

);
    always @(*) begin
        case (i_sel)
            2'b00: o_selected = i_data[0];
            2'b01: o_selected = i_data[1];
            2'b10: o_selected = i_data[2];
            2'b11: o_selected = i_data[3];
            default: o_selected = 1'bX;
        endcase
    end

    always @(*) begin
        if (i_sel[0] === 1'bX) 
            $display("Warning: i_sel[0] is undefined (X). Output may be unknown."); 
        if (i_sel[1] === 1'bX)
           $display("Warning: i_sel[1] is undefined (X). Output may be unknown.");  
    end

endmodule