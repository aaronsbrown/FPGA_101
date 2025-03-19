# 🔀 Multiplexers & Demultiplexers (Mux/Demux)

## 📌 Overview
This project explores **Multiplexers (MUX) and Demultiplexers (DEMUX)**, fundamental combinational circuits used in digital systems.

### **What You'll Learn**
✔️ How multiplexers select data from multiple inputs  
✔️ How demultiplexers distribute a single input to multiple outputs  
✔️ Applications of MUX/DEMUX in FPGA-based systems  

---

## 📁 Project Structure

```
mux_demux/
├── README.md           # Project documentation
├── src/                # Verilog source files
│   ├── mux_2to1.v      # 2-to-1 multiplexer
│   ├── mux_4to1.v      # 4-to-1 multiplexer
│   ├── demux_1to2.v    # 1-to-2 demultiplexer
│   ├── demux_1to4.v    # 1-to-4 demultiplexer
│   ├── top.v           # Integration of all MUX/DEMUX modules
├── test/               # Testbenches for simulation
│   ├── mux_2to1_tb.v   # Testbench for 2-to-1 multiplexer
│   ├── mux_4to1_tb.v   # Testbench for 4-to-1 multiplexer
│   ├── demux_1to2_tb.v # Testbench for 1-to-2 demultiplexer
│   ├── demux_1to4_tb.v # Testbench for 1-to-4 demultiplexer
└── constraints/        # FPGA constraint files (if needed)
```

---

## 📜 Verilog Modules

### **Multiplexers (MUX)**
- **`mux_2to1.v`**: A basic **2-to-1 multiplexer**, selecting between two inputs.
- **`mux_4to1.v`**: A **4-to-1 multiplexer**, selecting one of four inputs.

### **Demultiplexers (DEMUX)**
- **`demux_1to2.v`**: A **1-to-2 demultiplexer**, routing input to one of two outputs.
- **`demux_1to4.v`**: A **1-to-4 demultiplexer**, routing input to one of four outputs.

### **`top.v` (Integration Module)**
- Connects the different **MUX and DEMUX circuits** to demonstrate their usage together.

---

## 🛠 Running Simulations

To verify the design using **Icarus Verilog**, run:
```sh
# Compile and run 2-to-1 MUX testbench
iverilog -o build/mux_2to1_sim test/mux_2to1_tb.v src/mux_2to1.v
vvp build/mux_2to1_sim

# Compile and run 4-to-1 MUX testbench
iverilog -o build/mux_4to1_sim test/mux_4to1_tb.v src/mux_4to1.v
vvp build/mux_4to1_sim

# Repeat for Demux testbenches as needed...
```

To **view waveforms** in GTKWave:
```sh
gtkwave waveform_mux.vcd
```

---

## 🚀 Next Steps
- Implement **larger MUX (8-to-1, 16-to-1) and DEMUX (1-to-8, 1-to-16)**.
- Integrate with a **simple FSM** to dynamically control selection inputs.
- Implement a **MUX-based ALU** for arithmetic operations.

📌 **Once comfortable, move to `ch2_clocking/` to explore clock division!** 🚀
