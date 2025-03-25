# FPGA Step Sequencer: Development Roadmap

This document outlines a step-by-step plan to build a multitrack generative step sequencer using Verilog on the Alchitry Cu FPGA. The design is modular, scalable, and syncs to a user-controlled BPM clock. The goal is to create a flexible system capable of sequencing multiple melodies or rhythmic patterns, with real-time control and future expandability.

---

## ✅ Foundation (Completed)

### 1. BPM Clock

- Created a `bpm_clock` module that:
  - Accepts user-controlled BPM via buttons.
  - Outputs synchronized beat pulses (quarter, eighth, sixteenth, etc.).
  - Drives other modules with timing signals.
- Display current BPM using 7-segment LEDs.

### 2. Single Track Sequencer Prototype

- Built `step_sequencer` to advance a step index on incoming pulses.
- Built `note_sequence` ROM to map step index to MIDI notes.
- Created `midi_note_sender` to emit MIDI notes via UART on each trigger.
- Connected `step_sequencer` to `note_sequence` to produce a simple melody.

---

## 🧱 Modular Expansion Plan

### 3. Parameterized Track Module

- Combine `step_sequencer`, `note_sequence`, and `midi_note_sender` into a reusable `track` module:
  - Inputs: `clk`, `rst`, `step_pulse`
  - Outputs: MIDI trigger signal (`tx`), busy signal (optional)
  - Add parameters or ports for `channel`, `velocity`, and `note table`.

### 4. Multi-Track Support

- Instantiate multiple `track` modules in `top.v`:
  - Example: 2–8 tracks running in parallel.
  - Each receives a different `step_pulse` (eighth notes, sixteenths, etc.).
  - Each sends MIDI notes on a unique channel.

### 5. Step Pulse Routing

- Create a `step_select` mux to choose which BPM subdivision drives each track.
  - Controlled by DIP switches, constants, or a control bus.
  - Optional: Build a patchable routing matrix to support live reconfiguration.

---

## 🎛️ Advanced Features

### 6. Gate Timing

- Add logic to define gate length (note-off timing).
- Can use another BPM subdivision as a "note-off" pulse.

### 7. Track Mute / Solo

- Per-track mute button gates the `step_pulse` input or MIDI trigger.
- Solo logic can mute all other tracks when one is soloed.

### 8. LED Step Visualization

- Display current step index per track using LED arrays or 7-segment displays.
- Optional: Blink LEDs in sync with note triggers.

---

## 🎹 Future Possibilities

- Use RAM for editable patterns instead of hardcoded ROM.
- Add CV/Gate output using MCP4822 DAC for analog synth integration.
- Build a shared `midi_router` to handle multiple tracks over one UART.
- Implement a probabilistic sequencer mode (e.g. random note skips).
- Add pattern memory slots, variation, or song mode sequencing.

---

This roadmap builds from a functional one-track sequencer to a powerful multitrack system. Each step is modular, allowing for easy testing and expansion.
