# 🚀 FPGA 101: Structured Learning for FPGA Development

Welcome to **FPGA 101**, a structured learning curriculum designed to teach **FPGA programming and digital logic** through hands-on projects. This repository organizes projects into **thematic chapters**, covering everything from **basic digital circuits** to **generative music synthesis on an FPGA**.

---

## 📌 Project Structure

```
FPGA_101/
├── README.md                   # This file
├── common/                     # Shared Verilog modules & constraints
│   ├── constraints/            # Global pin constraint files
│   └── modules/                # Common reusable Verilog modules
├── docs/                       # Learning materials and guides
├── projects/                   # Hands-on FPGA projects (organized by chapter)
│   ├── ch1_basics/             # Digital logic fundamentals
│   ├── ch2_clocking/           # Clock division & timing
│   ├── ch3_interfacing/        # External device interfacing
│   ├── ch4_generative_music/   # Algorithmic rhythm & melody generation
│   ├── ch5_midi_sync/          # MIDI integration & DAW synchronization
│   ├── ch6_final_project/      # A fully functional FPGA-based music system
├── sim_tests/                  # General simulation tests for FPGA logic
└── tools/                      # Utility scripts for project automation
```

---

## 📖 FPGA Curriculum Overview

This curriculum is divided into **6 progressive chapters**, each covering essential FPGA topics through hands-on projects.

### **🔹 Chapter 1: Basics**
- **Combinational Logic** (AND, OR, XOR, Multiplexers)
- **Sequential Logic** (Flip-flops, Counters, Registers)
- **LED Control** (Blinking LEDs, Sequential Patterns)
- 📂 **Projects:** `combinational_logic/`, `flip_flops/`, `sequential_logic/`

### **🔹 Chapter 2: Clocking & Timing**
- **Clock Division & Frequency Scaling**
- **Counters & Timing Signals**
- **Generating BPM-based Pulses**
- 📂 **Projects:** `clock_divider/`, `bpm_pulse_generator_static/`, `counter_4bit/`

### **🔹 Chapter 3: Interfacing**
- **Reading Data from an 8-bit Bus**
- **Interfacing with DAC for Analog Output**
- **Processing MIDI Input on FPGA**
- 📂 **Projects:** `bus_edge_detection/`, `dac_interface/`, `midi_interface/`

### **🔹 Chapter 4: Generative Music**
- **Rhythm Generation Using LFSRs**
- **Step Sequencing & Note Generation**
- **Scale Quantization for Melodies**
- 📂 **Projects:** `lfsr_rhythm_gen/`, `sequencer_fpga/`, `quantizer/`

### **🔹 Chapter 5: MIDI Synchronization**
- **Reading External MIDI Clock**
- **Synchronizing FPGA Sequences with a DAW**
- 📂 **Projects:** `midi_clock_reader/`, `fpga_daw_sync/`

### **🔹 Chapter 6: Final Project**
- **Building a Hybrid FPGA-Teensy Synth**
- **Eurorack Integration & Performance Optimization**
- 📂 **Projects:** `hybrid_fpga_teensy_synth/`, `eurorack_integration/`

---

## 🛠 FPGA Project Tools

This repository contains automation scripts in the [`tools/`](tools/) folder:

| Script | Purpose |
|--------|---------|
| `init_project.sh` | Create a new project using a structured template |
| `build.sh` | Automates FPGA synthesis and flashing |
| `simulate_common.sh` | Runs testbenches for common FPGA modules |

To create a new project, use:
```sh
./tools/init_project.sh --name <project_name> --location <chapter_folder>
```

