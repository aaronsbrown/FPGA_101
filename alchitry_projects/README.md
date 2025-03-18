# Alchitry Projects

Welcome to the Alchitry Projects repository! This repository contains FPGA projects, common modules, simulation tests, and build tools to help you learn and experiment with FPGA designs.

## Directory Structure

- **common/**  
  Contains reusable Verilog modules and shared constraint files.
  - `common/modules/`: Commonly-used Verilog modules (e.g., `clock_divider.v`, `counter_nb.v`).
  - `common/constraints/`: Shared pin constraints (e.g., `cu.pcf`).

- **docs/**  
  Documentation, design references, and guides.

- **projects/**  
  Contains individual FPGA projects. Each project is self-contained with its own source files, constraints, testbenches, and build scripts.
  - Example: `projects/0_4bit_counter/` for a 4-bit counter project.

- **simulation_tests/**  
  A sandbox for testing and simulating common modules. Use the provided simulation scripts to experiment with different configurations.

- **tools/**  
  Build scripts and simulation scripts that automate synthesis, simulation, and FPGA programming (e.g., `build.sh`, `simulate_common.sh`).

## Getting Started

### Building a Project

Navigate to a project folder (e.g., `projects/0_4bit_counter/`) and run the global build script:

```bash
../../tools/build.sh --verbose src/top.v --top fpga_counter_top
```

### Simulating Common Modules

Use the simulation script from the `tools` directory:

```bash
./tools/simulate_common.sh --verbose --tb fpga_counter_top_tb.v
```

This will compile the common modules along with the specified testbench and run the simulation. The generated waveform (e.g., `waveform.vcd`) will be stored in `simulation_tests/build/` and can be viewed using GTKWave.

For more details, check out the documentation in the `docs/` folder.

Happy coding and experimenting!
