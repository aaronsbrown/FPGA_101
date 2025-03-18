`timescale 1ns/1ps
// `include "../simulation_smoke_test/d_ff.v"


module register_nb_tb;
    parameter N = 8;
    reg clk, reset;
    reg [N-1:0] d;
    wire [N-1:0] q;

    register_nb #(.N(N)) uut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    always forever #5 clk = ~clk;
    
    // LOG
    integer i;
    always @(posedge clk) begin
        $write( "Time =%0t | clk=%b | reset=%b | d=", $time, clk, reset);
        for (i = N-1; i >= 0; i = i - 1) begin
            $write("%b", d[i]);
        end
        $write(" | q=");
        for (i = N-1; i >= 0; i = i - 1) begin
            $write("%b", q[i]);
        end
        $write("\n");
    end

    initial begin
        
        $dumpfile("waveform_register_nbit.vcd");
        $dumpvars(0, register_nb_tb);
        
        // Initial conditions: start with reset asserted
        clk = 0;      // clock initial value (redundant because always block drives it)
        reset = 1;    // hold reset initially
        d = 8'h00;        // initial d value

        // Wait for one clock cycle to ensure proper reset duration
        @(posedge clk);
        reset = 0;    // de-assert reset after one rising clock edge

        // Apply stimulus aligned with clock edges:
        @(posedge clk);
        d = 8'h01;         

        // Test reasserting reset mid-operation:
        repeat(2) @(posedge clk);
        reset = 1;    // assert reset again to test asynchronous behavior
        @(posedge clk);
        reset = 0;    // de-assert reset
        
        // Apply stimulus aligned with clock edges:
        @(posedge clk);
        d = 8'h11;        
        @(posedge clk);
       
        repeat(5) @(posedge clk);
        $finish;

        end

endmodule