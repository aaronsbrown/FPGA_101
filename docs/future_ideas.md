# Future Project Idea: Implementing Ben Eater's SAP-1 on FPGA

This would be a great follow-up to the generative music FPGA project. The SAP-1 (Simple-As-Possible) computer, originally built using discrete logic and EEPROMs, can be reimagined in Verilog for synthesis on the iCE40 HX8K.

## Feasibility

The SAP-1 is a very small system in terms of logic and memory. The iCE40 HX8K has more than enough resources:

- ~7,680 logic cells
- 16 x 4Kbit RAM blocks
- 206 I/O pins

It's perfectly suited for SAP-1 and even leaves room for additional debug or display features.

## Core Modules to Implement

- Registers (A, B, IR, PC)
- ALU (Adder/Subtractor)
- Tri-state Bus Logic or Mux-Based Bus
- RAM (16 bytes or more)
- Program Counter
- Instruction Register
- Control Logic (FSM or Microcoded)
- Output Register
- Clock Divider and/or Manual Stepper

## Control Logic: FSM vs. Microcode

The EEPROM-based microcode used in the original Ben Eater build is functionally a ROM-based Finite State Machine (FSM):

- Microinstruction address = current state
- Microinstruction data = control signals
- Address selection = linear timing step + opcode, with possible branching

### Option 1: FSM Approach

- Use named states like `FETCH1`, `DECODE`, `EXECUTE_ADD`, etc.
- Use a `case` block in Verilog to define transitions and outputs

### Option 2: Microcode ROM

- Define a packed ROM in Verilog (`reg [N:0] rom[0:M]`)
- Create a microcode address from `opcode` and timing step
- Load outputs from the ROM, just like Ben Eater's EEPROM method

## Learning Opportunities

- FSM and microcode design
- ALU and register logic
- Tri-state/multiplexed bus modeling in HDL
- Simulation and testbench development
- Clocking strategies (manual or divided)
- ROM/RAM initialization
- Full synthesis and flashing with open-source toolchain

## Possible Extensions

- Program loader (UART, SPI, or memory-mapped)
- Debug output via LEDs, 7-seg, or serial
- Expandable instruction set
- Modular microinstruction encoding

## 🎵 Why This Is Relevant for Music Too

You’ll run into these same design concepts again in your FPGA music sequencer, especially when working on:

- State-driven note playback and gate control
- Step sequencing with per-step logic
- Reading from memory to determine control behavior (e.g., pattern memory)

Understanding FSMs and microcode-style ROM control will help you build more flexible, musically responsive systems that can evolve over time, similar to how traditional sequencers or grooveboxes behave.
