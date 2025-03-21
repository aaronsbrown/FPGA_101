# 🕺 Swing Timing in Verilog

This note explores how to implement **swing timing** using a LUT-based approach and a toggle-controlled counter in Verilog.

---

## 1. 🎼 Precompute LUT Values (Compile-Time)

```verilog
localparam integer SWING_PERCENT = 60;  // 60% long, 40% short
localparam integer EIGHTH_NOTE_CYCLES = QUARTER_NOTE_CYCLES / 2;

localparam integer SWING_LONG_CYCLES  = (EIGHTH_NOTE_CYCLES * SWING_PERCENT) / 50;  // slightly longer
localparam integer SWING_SHORT_CYCLES = (EIGHTH_NOTE_CYCLES * (100 - SWING_PERCENT)) / 50; // slightly shorter
```

### 🧮 Example Numbers (if quarter note = 1000 cycles)

- Standard eighth note cycles = 500  
- Swing (60% / 40%):
  - Long cycle: `(500 * 60) / 50 = 600` cycles
  - Short cycle: `(500 * 40) / 50 = 400` cycles

---

## 2. 🔁 Single Counter + Swing Toggle

Use a single counter and alternate its max value between long and short cycles.

```verilog
reg swing_toggle;   // toggles between long and short cycles
reg [31:0] swing_counter;
reg swing_beat_pulse;  // your swing pulse output

always @(posedge clk or posedge reset) begin
    if(reset) begin
        swing_counter <= 0;
        swing_toggle <= 0;
        swing_beat_pulse <= 0;
    end else begin
        if(swing_counter == (swing_toggle ? SWING_SHORT_CYCLES : SWING_LONG_CYCLES) - 1) begin
            swing_counter <= 0;
            swing_toggle <= ~swing_toggle;        // Alternate cycle length each time
            swing_beat_pulse <= ~swing_beat_pulse;  // output pulse toggle
        end else begin
            swing_counter <= swing_counter + 1;
        end
    end
end
```

### 📝 Notes

- `swing_toggle` controls which LUT value to use:
  - `swing_toggle == 0`: use long cycle
  - `swing_toggle == 1`: use short cycle