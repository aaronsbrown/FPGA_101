# FPGA 101 - Learning and Experimentation

Welcome to **FPGA 101**, a structured learning repository designed to guide you through FPGA development, from **early explorations** to **fully structured projects**. This repository contains hands-on experiments, structured FPGA projects, simulation environments, and documentation to help you progress from **basic digital logic** to **advanced FPGA-based generative music systems**.

---

## 📁 Repository Structure

```
FPGA_101/
├── README.md            # Top-level README explaining the structured learning plan
├── structured_fpga/     # New structured approach to FPGA projects
│   ├── README.md
│   ├── common/          # Shared Verilog modules + constraints
│   ├── docs/            # Documentation, setup guides
│   ├── projects/        # Individual structured FPGA projects
│   ├── simulation_tests/ # Sandbox for controlled FPGA simulations
│   └── tools/           # Build & simulation scripts
│
├── exploratory_fpga/    # Older explorations & initial FPGA experiments
│   ├── README.md
│   ├── icebreaker-projects/ # Initial FPGA experiments
│   ├── simulation_smoke_test/ # Early testbenches & logic simulations
│   └── tools/           # Older scripts that may still be useful
│
└── curriculum/          # Structured learning materials
    ├── README.md
    ├── week_01_intro.md
    ├── week_02_bus_edge_detection.md
    ├── week_03_clock_division.md
    └── (etc...)
```

---

## 🏗️ Learning Progression

This repository is structured into two phases:

1️⃣ **Exploratory FPGA Work (`exploratory_fpga/`)**  
   - Early experiments with Verilog and FPGA development.
   - Includes simple LED blinking, combinational logic, and basic simulations.
   - Contains raw test files, initial tools, and quick Verilog scripts.

2️⃣ **Structured FPGA Projects (`structured_fpga/`)**  
   - Organized weekly learning curriculum.
   - Contains fully built projects, modular Verilog components, and structured synthesis workflows.
   - Designed for **FPGA music generation, synthesis, and real-time control applications**.

### 📆 Weekly FPGA Curriculum

| Week | Topics Covered |
|------|--------------------------------------------------------|
| 1    | **FPGA Basics & Verilog Introduction**: Toolchain setup, LED blinking, combinational logic |
| 2    | **8-bit Bus & Edge Detection**: Connecting an FPGA to an 8-bit computer bus, level shifting |
| 3    | **Clock Division & Timing Control**: Generating pulse signals (8th notes, quarter notes) |
| 4    | **Interfacing with MCP4822 DAC (CV Output)**: Sending digital data to a DAC for synth control |
| 5    | **Generating Rhythms with FPGA Logic**: Implementing LFSRs, XOR techniques for rhythm patterns |
| 6    | **Adding MIDI Support via Teensy**: Sending FPGA triggers as USB-MIDI signals |
| 7    | **Building a Basic Sequencer**: FPGA-driven note patterns, duration, pitch, velocity control |
| 8    | **Scale Quantization for Melodies**: Converting raw CV/MIDI data into scale-constrained notes |
| 9    | **Syncing FPGA Rhythms with DAW via MIDI Clock**: Ensuring FPGA sequences match DAW BPM |
| 10+  | **Final Project - Hybrid FPGA-Teensy Generative Synth**: Bringing everything together! |

---

## 🚀 Getting Started

### 1️⃣ Install Required FPGA Tools
Ensure you have **Yosys, nextpnr, IceStorm, Icarus Verilog, GTKWave**, and **VSCode** installed.

```bash
# Verify installation
yosys -V
nextpnr-ice40 --version
iverilog -V
gtkwave --version
```

For full setup instructions, check the [FPGA Development Environment Guide](https://github.com/YOUR_GITHUB_USERNAME/FPGA_101/wiki/FPGA-Development-Environment).

### 2️⃣ Clone This Repository

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/FPGA_101.git
cd FPGA_101
```

### 3️⃣ Build & Simulate a Project

Navigate to a structured FPGA project folder and build:

```bash
cd structured_fpga/projects/0_4bit_counter
../../tools/build.sh --verbose src/top.v --top fpga_counter_top
```

Run a simulation for a **common module**:

```bash
./tools/simulate_common.sh --verbose --tb fpga_counter_top_tb.v
```

### 4️⃣ View Waveform Output

Open the resulting **waveform.vcd** file in GTKWave:

```bash
gtkwave structured_fpga/simulation_tests/build/waveform.vcd
```

---

## 💡 Contributing & Expanding

This repository is meant to grow as you progress! Feel free to:
- Add new **Verilog modules** or **FPGA experiments**.
- Improve **documentation** and share findings.
- Suggest **new generative music techniques** using FPGA logic.

For structured contributions, check the [Contributing Guide](./docs/contributing.md).

🚀 **Happy learning, building, and making music with FPGAs!** 🎵
""

