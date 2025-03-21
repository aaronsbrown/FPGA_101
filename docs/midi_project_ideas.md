# 🎹 FPGA MIDI Project Ideas

This document gathers all MIDI-related project ideas for the FPGA Music Curriculum. It focuses on how FPGAs can interact with MIDI data via UART and USB, especially in combination with microcontrollers like the Teensy.

## ✅ Foundational Concepts

- [x] Understand MIDI message structure (status + data bytes)
- [x] Learn what UART is and how it relates to MIDI transmission
- [x] Understand baud rate and its implications on MIDI bandwidth

## 🛠️ Hands-On FPGA / Teensy Implementation Ideas

1. **Implement a UART Transmitter in Verilog**  
   Bit-bang a MIDI Note On message (e.g., `0x90 0x3C 0x64`) with correct timing for 31,250 baud.

2. **Build a Simple MIDI Note Generator Module**  
   Send fixed notes in a pattern (e.g., test arpeggiator).

3. **Connect FPGA TX to Teensy RX**  
   Teensy receives MIDI bytes via UART and sends them as USB MIDI to a computer.

4. **Configure Teensy as a USB-MIDI Device**  
   Use Teensyduino to forward incoming serial data as proper USB MIDI messages.

5. **Use MIDI Monitor or DAW to Visualize Output**  
   Confirm proper messages are reaching the host computer.

## 🎚️ Advanced / Optional Projects

6. **Simulate a MIDI Message Bitstream in Verilog**  
   Visualize waveform timing and transitions in GTKWave.

7. **Implement a Verilog MIDI Clock Generator**  
   Send 24 pulses per quarter note over MIDI for DAW sync.

8. **Design a MIDI Throttler or Bandwidth Visualizer**  
   Log or limit MIDI messages per second to avoid overflow.

9. **Create a Simple FSM to Encode MIDI Sequences**  
   Build a finite state machine that steps through a melody.

10. **Add Support for Control Change (CC) Messages**  
    e.g., Mod Wheel (CC 1), Expression (CC 11), Filter Cutoff (CC 74).

11. **Build a MIDI Router/Filter in Verilog or Teensy**  
    Allow/block messages based on channel or type.

---

_This list will evolve as the project progresses. Feel free to PR your own ideas or forks!_
