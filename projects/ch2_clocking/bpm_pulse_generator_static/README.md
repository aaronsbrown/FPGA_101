# BPM Pulse Generator 🎶⏱️

## Project Overview
This FPGA module generates rhythmic timing pulses based on musical BPM (beats per minute). It transforms the FPGA's high-frequency clock into pulses aligned to musical note durations (whole, half, quarter, eighth, and sixteenth notes). Ideal for generative music projects, synthesizers, drum machines, and synchronization tasks.

## Hardware Requirements
- FPGA Board: Alchitry Cu (100 MHz onboard clock)
- LEDs or external indicators for visual verification (onboard LEDs recommended)
- Optional: buttons or potentiometer for dynamic BPM adjustments

## Parameters & Configuration
- `BPM` parameter (default = 120 BPM) is adjustable at compile-time.
- Timing pulses generated:
  - Whole notes
  - Half notes
  - Quarter notes (primary BPM pulse)
  - Eighth notes
  - Sixteenth notes

## Usage
- Connect FPGA outputs (`beats` register bits) to LEDs or external devices to visualize or trigger rhythmic patterns.
- Adjust the `BPM` parameter to match desired musical tempo.

## Status
- [ ] Not Started
- [x] In Progress
- [ ] Completed

## Next Steps
- Implement dynamic BPM control (buttons or potentiometer input)
- Integration with Teensy for MIDI clock synchronization
- Expansion for rhythmic sequencing and generative pattern generation