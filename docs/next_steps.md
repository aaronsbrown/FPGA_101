# Next Steps & Captured Ideas

This document collects key ideas and action items discussed during sequencer and system development sessions. These represent architectural decisions, build system upgrades, hardware exploration, and generative sequencing possibilities.

---

## ✅ Core Architectural Ideas

1. **`sequencer_core.v` system module**
   - Contains all functional logic
   - Cleanly separates from `top.v` hardware pinout
   - Easily testable and reusable

2. **`top.v` becomes just glue**
   - Instantiates `sequencer_core`
   - Handles only physical I/O (buttons, LEDs, UART, etc.)

3. **Use `u_` prefix for instance names**
   - Common industry convention (stands for “unit”)
   - Helps with readability and waveform debugging

---

## 📦 Build System Upgrades

4. **Adopt `files.f` (or `filelist.txt`)**
   - Central list of Verilog source files
   - Used by build script for synthesis or simulation
   - Reduces per-project boilerplate and manual path management

5. **Optionally autogenerate parts of `filelist.txt`**
   - e.g. always include `common/modules/*.v`

---

## 🧠 Memory Model Evolution

6. **Replace fixed `note_sequence.v` ROM with RAM**
   - Allows editable note patterns
   - Opens door to live recording, random mutation, UI interaction

7. **Later: Add pattern banks in RAM**
   - Switch patterns via button or time
   - Compose songs from pattern blocks

---

## 🎲 Randomness / Generative Tools

8. **`lfsr_rng.v` module**
   - Pseudo-random generator (seedable)
   - Useful for generative melodies, rhythms, gate skipping

9. **Hybrid entropy idea**
   - Use UART or Python to seed the LFSR
   - Later: Add analog noise source if desired (avalanche transistor or Teensy ADC)

---

## 🧬 Sequencer Engine Expansions

10. **Conway’s Game of Life as a sequencer engine**
    - Each live cell triggers a note
    - Row or column determines pitch / time
    - Potential for self-evolving patterns

11. **Neighbor-driven pitch mapping**
    - Map 0–8 neighbor count to a scale LUT
    - Or use 8-bit neighborhood pattern to drive chord selection

---

## 🧰 Other Future Expansions

12. **Gate length control**
    - Add note-off delay logic per track
    - Tied to BPM subdivisions

13. **Track mute/solo**
    - Buttons or switches gate each track's output

14. **Visual step feedback**
    - LEDs or 7-segment displays show step position
    - Optionally flash on trigger

15. **MIDI output bus or router**
    - Shared UART with per-track arbitration
    - Support for multiple MIDI channels
