`timescale 1ns/1ps

module xor_gate_tb;
    reg a, b;
    wire y;

    xor_gate uut (
        .a(a),
        .b(b),
        .y(y)
    );

    task check_xor(input reg exp_y);
        begin
            #10;
            if (y !== exp_y)
                $display("❌ Test FAILED: a=%b, b=%b, expected y=%b, got y=%b", a, b, exp_y, y);
            else
                $display("Test PASSED: a=%b, b=%b, y=%b", a, b, y);
        end
    endtask

    initial begin
        $dumpfile("waveform_xor.vcd");
        $dumpvars(0, xor_gate_tb);

        // Test cases
        $display("Running XOR Gate Tests...");

        a = 0; b = 0; check_xor(0); 
        a = 0; b = 1; check_xor(1); 
        a = 1; b = 0; check_xor(1); 
        a = 1; b = 1; check_xor(0); 

        $display("Tests completed.");

        $finish;

    end
endmodule