`timescale 1ns/1ps

module bpm_pulse_generator_tb;
    reg clk, reset;
    wire [4:0] beats;

    localparam CLOCK_FREQ = 400; // Simulation frequency
    // BPM = 120;
    // QUARTER_NOTE_CYCLES = (CLOCK_FREQ * 60) / BPM; ==> 200 cycles, safely nonzero
    bpm_pulse_generator #(
        .CLOCK_FREQ(CLOCK_FREQ)
    ) uut (
        .clk(clk),
        .reset(reset),
        .beats(beats)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    always #5 clk = ~clk;
    
    initial begin
        
        $dumpfile("waveform.vcd");
        $dumpvars(0, bpm_pulse_generator_tb);

        $monitor( "Time =%0t | clk=%b | reset=%b | beats=%b", $time, clk, reset, beats);

        clk = 0;      
        
        reset = 1;    
        @(posedge clk);
        reset = 0;   

        repeat(CLOCK_FREQ * 4) @(posedge clk);
        
        reset = 1;
        @(posedge clk);
        reset = 0;

        repeat(10) @(posedge clk);

        $display("Test complete at time %0t", $time);
        $finish;
        end

endmodule