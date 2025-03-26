`timescale 1ns/1ps

module seq_player_tb;
    reg clk;
    reg rst;
    reg pulse_choose_note;
    reg busy;
    wire pulse_send_note;
    wire [7:0] midi_note;
    
    // Instantiate the seq_core module
    seq_player uut (
        .clk(clk),
        .rst(rst),
        .pulse_choose_note(pulse_choose_note),
        .busy(busy),
        .pulse_send_note(pulse_send_note),
        .midi_note(midi_note)
    );
    
    // Clock generation: 10ns period (100MHz)
    initial begin
       clk = 0;
       forever #5 clk = ~clk;
    end
    
    // Stimulus
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, seq_player_tb);
        
       // Initialize inputs
       rst = 1;
       pulse_choose_note = 0;
       busy = 0;
       
       // Hold reset for a few clock cycles
       #20;
       rst = 0;
       
       // Generate a pulse_choose_note pulse once every 100 ns (10 clock cycles)
       repeat (10) begin
            // Generate a one-clock-cycle pulse
            pulse_choose_note = 1;
            #10;
            pulse_choose_note = 0;
            #90; // Wait until next pulse
       end
       
       #200;
       $finish;
    end
    
    // Optionally, monitor outputs
    initial begin
       $monitor("Time=%0t | pulse_choose_note=%b, pulse_send_note=%b, midi_note=%d, busy=%b", 
                $time, pulse_choose_note, pulse_send_note, midi_note, busy);
    end
endmodule
