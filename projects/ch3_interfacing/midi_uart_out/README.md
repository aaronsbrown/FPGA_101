# 🎼 UART MIDI Transmitter (FPGA → Teensy)

This project implements a simple UART-based MIDI transmitter in Verilog. The goal is to send MIDI Note On messages from the FPGA to a Teensy, which then forwards the data as USB-MIDI to a DAW or MIDI Monitor on your computer.

---

## 📖 Overview

This is part of [Chapter 3: Interfacing](../README.md) and focuses on sending MIDI over UART using the FPGA.

- The FPGA transmits standard 31,250 baud MIDI messages using a UART-style bitstream.
- A Teensy 4.0 receives the data via its RX pin and forwards it over USB as a class-compliant MIDI device.

This is a good first project for getting MIDI out of an FPGA without requiring any analog gear.

---

## 🎹 MIDI Message Format

A basic MIDI message is 3 bytes:

- Status byte (e.g., `0x90` = Note On, channel 0)
- Note number (e.g., `0x3C` = Middle C)
- Velocity (e.g., `0x64` = velocity 100)

**Example:**
0x90 0x3C 0x64   →  Note On: Middle C, velocity 100

Each byte is sent over UART as:
[Start bit][8 data bits, LSB-first][Stop bit]

Total = 10 bits per byte.

---

## 🧠 UART Refresher

**UART** stands for *Universal Asynchronous Receiver/Transmitter*. It’s a simple protocol for sending data one bit at a time:

- **Baud rate:** 31,250 (for MIDI)
- **Framing:** 8 data bits, no parity, 1 stop bit (8N1)
- **Transmission:** LSB first, start bit = 0, stop bit = 1

No clock is shared; timing is handled by both sender and receiver agreeing on the baud rate.

---

## 🧰 Setup Requirements

- Alchitry Cu FPGA board  
- Alchitry Io board (for IO pin breakout)  
- Teensy 4.0 (connected via USB to your computer)  
- Breadboard + jumper wires  
- No soldering required if using snug-fit headers for the Teensy  

---

## 🚀 Next Steps

- Implement a UART transmitter module in Verilog  
- Transmit a fixed MIDI message repeatedly  
- Confirm that the Teensy receives the message and forwards it over USB  

For more ideas, see the [🎹 MIDI Project Ideas](../../../docs/midi_project_ideas.md) document.

---

Happy hacking! 🎛️
