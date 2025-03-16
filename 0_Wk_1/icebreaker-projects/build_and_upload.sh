#!/bin/bash
set -e  # Stop on errors

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Start execution timer
START_TIME=$(date +%s)

# Logging function
log() {
    echo -e "${CYAN}[$(date +"%T")]${NC} $1"
}

error() {
    echo -e "${RED}❌ ERROR:${NC} $1" >&2
}

success() {
    echo -e "${GREEN}✅ SUCCESS:${NC} $1"
}

# Ensure a Verilog file is provided
if [[ -z "$1" ]]; then
    error "Usage: $0 path/to/your_file.v"
    exit 1
fi

VERILOG_FILE="$1"

# Check if the Verilog file exists
if [[ ! -f "$VERILOG_FILE" ]]; then
    error "Verilog file '$VERILOG_FILE' not found!"
    exit 1
fi

# Extract directory and filename details
PROJECT_DIR=$(dirname "$VERILOG_FILE")
FILENAME=$(basename "$VERILOG_FILE")
BASENAME="${FILENAME%.*}"  # Remove .v extension to use as top module

# Find a .pcf file in the same directory as the Verilog file
PCF_FILE=$(ls "$PROJECT_DIR"/*.pcf 2>/dev/null | head -n 1)

# Exit if no PCF file is found
if [[ -z "$PCF_FILE" ]]; then
    error "No PCF file found in '$PROJECT_DIR'. Aborting."
    exit 1
fi

# Convert to absolute paths
PCF_FILE=$(realpath "$PCF_FILE")
VERILOG_FILE=$(realpath "$VERILOG_FILE")
PROJECT_DIR=$(realpath "$PROJECT_DIR")

# Create logs directory if it doesn't exist
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

# Move to the project directory
cd "$PROJECT_DIR"

log "🔍 Using Verilog file: $VERILOG_FILE"
log "📌 Top module: $BASENAME"
log "📄 Constraint file: $PCF_FILE"

# Step 1: Run Yosys (quiet mode)
log "🛠 Running Yosys synthesis..."
if yosys -q -p "synth_ice40 -top $BASENAME -json hardware.json" "$FILENAME" > "$LOG_DIR/yosys.log" 2>&1; then
    success "Yosys synthesis completed."
else
    error "Yosys failed! Check yosys.log for details."
    tail -n 20 "$LOG_DIR/yosys.log"  # Show last 20 lines of the log
    exit 1
fi

# Verify that hardware.json was created
if [[ ! -f "hardware.json" ]]; then
    error "Yosys did not generate hardware.json!"
    exit 1
fi

# Step 2: Place & route (quiet mode)
log "📌 Running nextpnr-ice40..."
if nextpnr-ice40 --hx8k --package cb132 --json hardware.json --asc hardware.asc --pcf "$PCF_FILE" > "$LOG_DIR/nextpnr.log" 2>&1; then
    success "nextpnr-ice40 completed."
else
    error "nextpnr-ice40 failed! Check nextpnr.log for details."
    tail -n 20 "$LOG_DIR/nextpnr.log"  # Show last 20 lines of the log
    exit 1
fi

# Verify that hardware.asc was created
if [[ ! -f "hardware.asc" ]]; then
    error "nextpnr-ice40 did not generate hardware.asc!"
    exit 1
fi

# Step 3: Generate bitstream (quiet mode)
log "📦 Packing bitstream..."
if icepack hardware.asc hardware.bin > "$LOG_DIR/icepack.log" 2>&1; then
    success "Bitstream packed successfully."
else
    error "icepack failed! Check icepack.log for details."
    tail -n 20 "$LOG_DIR/icepack.log"  # Show last 20 lines of the log
    exit 1
fi

# Verify that hardware.bin was created
if [[ ! -f "hardware.bin" ]]; then
    error "icepack did not generate hardware.bin!"
    exit 1
fi

# Step 4: Upload to FPGA
log "🚀 Uploading to FPGA..."
if iceprog -d i:0x0403:0x6010:0 hardware.bin > "$LOG_DIR/iceprog.log" 2>&1; then
    success "Bitstream uploaded to FPGA."
else
    error "Upload failed! Check iceprog.log for details."
    tail -n 20 "$LOG_DIR/iceprog.log"  # Show last 20 lines of the log
    exit 1
fi

# Print execution time
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
log "🏁 Total execution time: ${ELAPSED_TIME}s"

success "🎉 Build & upload complete!"

