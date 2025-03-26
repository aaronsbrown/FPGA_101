`timescale 1ns / 1ps

module midi_note_sender_tb;
    // Declare testbench signals

    reg clk, reset, trigger;
    wire tx, busy;

    reg [3:0] channel;
    reg [6:0] note, velocity;

    // Instantiate the DUT
    midi_note_sender uut (
       .clk(clk),
       .reset(reset),
       .trigger(trigger),
       .channel(channel),
       .note(note),
       .velocity(velocity),
       .tx(tx),
       .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, midi_note_sender_tb);

        // Add testbench stimulus
        clk = 0;
        reset = 1;

        @(posedge clk);
        reset = 0;

        channel = 4'd1;
        note = 7'd60;
        velocity = 7'd100;

        @(posedge clk);
        trigger = 1;
        @(posedge clk);
        trigger = 0;

        repeat(200) @(posedge clk);

        channel = 4'd15;
        note = 7'd70;
        velocity = 7'd50;

        @(posedge clk);
        trigger = 1;
        @(posedge clk);
        trigger = 0;

        repeat(100) @(posedge clk);
        $finish;
    end

endmodule
