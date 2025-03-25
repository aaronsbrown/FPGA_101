# 🧠 FPGA Project Ideas – Chapters 1 & 2

This document gathers creative and technical project ideas related to **Chapter 1: FPGA Basics** and **Chapter 2: Clock Division & Timing**. These are great entry points for mastering core Verilog structures and timing control while exploring musical and interactive applications.

---

## 📘 Chapter 1: FPGA Basics

Focus: **Fundamentals of Verilog, modules, and logic simulation**

### ✅ Foundational Ideas

- [x] Blink an LED using an `always` block
- [x] Simulate basic logic gates (`and`, `or`, `not`, etc.)
- [x] Create parameterized modules for logic functions

### 💡 Fun Project Ideas

1. **Morse Code Blinker**  
   Encode a string (like "HELLO") and blink it out in Morse code using Verilog timing logic.

2. **Binary Counter Display**  
   Use multiple onboard LEDs to show an incrementing binary value.

3. **Interactive Button Logic**  
   Use the Alchitry Io board’s buttons to implement AND/OR logic or toggle behavior with a latch.

4. **LED “Knight Rider” Effect**  
   A sweeping LED light using a simple FSM or shift register.

5. **Build Your Own Logic Gate**  
   Implement `nand`, `xor`, and `xnor` from basic gate primitives and test with waveform sim.

---

## ⏱ Chapter 2: Clock Division & Timing

Focus: **Timing control, clock dividers, rhythmic pulse generation**

### ✅ Core Concepts

- [x] Divide the 100 MHz FPGA clock to create slow pulses (e.g., 1 Hz)
- [x] Understand timing parameters using `localparam`
- [x] Use toggles and counters to build custom beat clocks

### 🎵 Musical/Temporal Project Ideas

1. **BPM-Based Pulse Generator**  
   Convert FPGA clock into 8th, quarter, or dotted note intervals at a fixed BPM. — Done via `bpm_clock` module

2. **Tap Tempo Button**  
   Measure time between button presses to dynamically set BPM.

3. **Multi-Division Clock Module**  
   Output 1/4 note, 1/8 note, 1/16 note simultaneously from one master clock. — `bpm_clock` outputs 1/4, 1/8, 1/16 simultaneously

4. **Visual Metronome**  
   Blink LEDs to match beat subdivisions—great with different color codes. — 7-segment BPM display + LED beat indicators

5. **Swing Timing with Toggle Logic**  
   Alternate between long and short pulses to simulate “groove” (see `notes_swing.md`).

6. **Rhythmic Gate Sequencer**  
   Trigger pulses in a pattern (like 10101000) synced to internal clock ticks.

7. **Polyrhythm Generator**  
   Generate two or more independent clocks (e.g., 4/4 and 3/4) for cross-rhythmic interplay.

---

✨ More advanced projects from these chapters may evolve into sequencers, groove engines, or timing cores used later in your music system.

For MIDI-related ideas, see: [🎹 MIDI Project Ideas](midi_project_ideas.md)
