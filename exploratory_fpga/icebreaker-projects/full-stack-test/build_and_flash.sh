#!/bin/bash

# Exit immediately if a command fails
set -e

# Check if a Verilog file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <verilog_file.v>"
    exit 1
fi

# Extract base name (without extension)
VERILOG_FILE="$1"
BASE_NAME="${VERILOG_FILE%.v}"

# Define filenames
JSON_FILE="${BASE_NAME}.json"
ASC_FILE="${BASE_NAME}.asc"
BIN_FILE="${BASE_NAME}.bin"
PCF_FILE="cu.pcf"  # Adjust this if you have different constraint files

echo "Building $VERILOG_FILE..."

# Run Yosys synthesis
echo "Running Yosys synthesis..."
yosys -p "synth_ice40 -json $JSON_FILE" $VERILOG_FILE

# Run NextPNR for placement and routing
echo "Running NextPNR..."
nextpnr-ice40 --hx8k --package cb132 --json $JSON_FILE --pcf $PCF_FILE --asc $ASC_FILE

# Convert ASC file to BIN for flashing
echo "Packing binary file..."
icepack $ASC_FILE $BIN_FILE

# Flash the binary file
echo "Flashing FPGA..."
iceprog $BIN_FILE

echo "Build and flashing complete! 🚀"
