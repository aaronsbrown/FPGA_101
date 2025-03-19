module mux2to1 (

    input i_sel,
    input [1:0] i_data,
    output o_selected

);

    assign o_selected = i_sel ? i_data[1] : i_data[0];

    always @(*) begin
        if (i_sel === 1'bX)
        $display("Warning: i_sel is undefined (X). Output may be unknown."); 
    end

endmodule