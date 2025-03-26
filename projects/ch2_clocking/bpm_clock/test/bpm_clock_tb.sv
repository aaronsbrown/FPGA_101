`timescale 1ns/1ps

module bpm_clock_tb;
    reg clk, reset;
    wire [4:0] beats;
    wire [4:0] beat_triggers;
    reg [7:0] bpm;

    // BPM = 120;
    // QUARTER_NOTE_CYCLES = (CLOCK_FREQ * 60) / BPM; ==> 200 cycles, safely nonzero
    
    localparam CLOCK_FREQ = 400; // Simulation frequency
    bpm_clock #(
        .CLOCK_FREQ(CLOCK_FREQ)
    ) uut (
        .clk(clk),
        .reset(reset),
        .beats(beats),
        .beat_triggers(beat_triggers),
        .o_bpm(bpm)
    );

    // Clock generation: 10 ns period (toggle every 5 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        
        $dumpfile("waveform.vcd");
        $dumpvars(0, bpm_clock_tb);

        $monitor( "Time =%0t | clk=%b | reset=%b | beats=%b | beat_triggers=%b", $time, clk, reset, beats, beat_triggers);

        reset = 1;    
        @(posedge clk);
        reset = 0;   

        repeat(CLOCK_FREQ * 4) @(posedge clk);

        $display("Test complete at time %0t", $time);
        $finish;
        end

endmodule
