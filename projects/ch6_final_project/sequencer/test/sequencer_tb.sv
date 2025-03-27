`timescale 1us/1us

module sequencer_tb;
    // Testbench signals
    reg         clk;
    reg         rst;
    reg         btn_inc_bpm;
    reg         btn_dec_bpm;
    
    wire [7:0]  leds;
    wire [6:0]  seg_display;
    wire [3:0]  seg_select;
    wire        tx;
    
    // Override BPM clock parameter (use the actual FPGA clock for internal calculations)
    defparam uut.u_bpm_clock.CLOCK_FREQ = 100_000_000;
    defparam uut.u_midi_note_sender.uart.BAUD_RATE = 115200;
    defparam uut.u_midi_note_sender.uart.CLK_FREQ = 100_000_000;
    
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
    
    // Instantiate the UART RX model to decode the 'tx' line
    wire [7:0] rx_data;
    wire       rx_valid;
    midi_uart_rx #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(115200)
    ) u_midi_rx (
        .clk(clk),
        .reset(rst),
        .rx(tx),
        .data_out(rx_data),
        .valid(rx_valid)
    );
    
    // Clock generation: 100 MHz (10 ns period)
    initial begin
        clk = 0;
        forever #0.005 clk = ~clk;  // 0.005 µs half-period in 1us timescale
    end
    
    // Test stimulus: run for a short period (e.g., 500,000 us = 0.5 s)
    initial begin
        $dumpfile("waveform.vcd");
        // Dump only top-level DUT signals to limit file size
        $dumpvars(1, uut);
        
        rst = 1;
        btn_inc_bpm = 0;
        btn_dec_bpm = 0;
        #10;   // hold reset for 10 µs
        rst = 0;
        
        // Let the sequencer run autonomously
        // For a BPM of 120, eighth notes occur every 250,000 us (0.25 s)
        // So run for 0.5 s to capture about 2 note events, then finish.
        #500_000;
        
        $display("Test complete at time %0t us", $time);
        $finish;
    end
    
    // Monitor internal MIDI signals for debugging
    initial begin
        $monitor("Time=%t us | MIDI Note=%0d, Velocity=%0d, Step Index=%0d", 
                 $time, uut.midi_note, uut.midi_velocity, uut.step_idx);
    end
    
    // Accumulate and print complete MIDI messages (3 bytes per message)
    reg [1:0] byte_count;
    reg [7:0] midi_msg [0:2];
    
    initial begin
        byte_count = 0;
    end
    
    always @(posedge clk) begin
        if (rx_valid) begin
            midi_msg[byte_count] <= rx_data;
            byte_count <= byte_count + 1;
            if (byte_count == 2) begin
                $display("Time=%t us: MIDI Message = Status: 0x%0h, Note: %0d, Velocity: %0d", 
                         $time, midi_msg[0], midi_msg[1], midi_msg[2]);
                byte_count <= 0;
            end
        end
    end
endmodule