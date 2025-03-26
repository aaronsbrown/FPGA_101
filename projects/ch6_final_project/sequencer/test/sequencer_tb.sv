`timescale 1ns/1ps

module sequencer_tb;
    // Testbench signals
    reg         clk;
    reg         rst;
    reg         btn_inc_bpm;
    reg         btn_dec_bpm;
    
    wire [23:0] leds;
    wire [6:0]  seg_display;
    wire [3:0]  seg_select;
    wire        tx;
    
    // Instantiate the DUT (Device Under Test)
    sequencer uut (
        .clk(clk),
        .rst(rst),
        .btn_inc_bpm(btn_inc_bpm),
        .btn_dec_bpm(btn_dec_bpm),
        .leds(leds),
        .seg_display(seg_display),
        .seg_select(seg_select),
        .tx(tx)
    );
    
    // Clock generation: 100 MHz (period = 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Dump waveforms for viewing in a waveform viewer
        $dumpfile("waveform.vcd");
        $dumpvars(0, sequencer_tb);
        
        // Initialize inputs
        rst = 1;
        btn_inc_bpm = 0;
        btn_dec_bpm = 0;
        
        // Hold reset for a few clock cycles
        #20;
        rst = 0;
        
        // Wait a few cycles then generate a pulse on btn_inc_bpm
        #50;
        btn_inc_bpm = 1;
        #10; // one clock cycle pulse
        btn_inc_bpm = 0;
        
        // Wait and then simulate a BPM decrease
        #100;
        btn_dec_bpm = 1;
        #10;
        btn_dec_bpm = 0;
        
        // Simulate additional BPM up pulses
        repeat (5) begin
            #100;
            btn_inc_bpm = 1;
            #10;
            btn_inc_bpm = 0;
        end
        
        // Allow some time for the sequencer to run
        #500;
        $display("Test complete at time %0t", $time);
        $finish;
    end
    
    // Monitor the internal MIDI note and velocity signals.
    // This uses hierarchical references to access uut.midi_note and uut.midi_velocity.
    initial begin
        $monitor("Time=%t | MIDI Note: %d, Velocity: %d, Step Index: %d", 
                 $time, uut.midi_note, uut.midi_velocity, uut.step_idx);
    end
endmodule