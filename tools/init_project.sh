#!/bin/bash

# Exit on error
set -e

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default template path (modify if needed)
SCRIPT_DIR="$(dirname "$0")"
TEMPLATE_DIR="$SCRIPT_DIR/[template]_proj_dir"

# Usage function
usage() {
    echo -e "${YELLOW}Usage:${NC} $0 --name <project_name> --location <target_path>"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Error: --name flag requires a project name.${NC}"
                usage
            fi
            PROJECT_NAME="$2"
            shift 2
            ;;
        --location)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Error: --location flag requires a target path.${NC}"
                usage
            fi
            TARGET_PATH="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
    esac
done

# Ensure required arguments are provided
if [[ -z "$PROJECT_NAME" || -z "$TARGET_PATH" ]]; then
    echo -e "${RED}Error: Both --name and --location are required.${NC}"
    usage
fi

# Resolve absolute paths
TEMPLATE_ABS=$(realpath "$TEMPLATE_DIR")
TARGET_ABS=$(realpath "$TARGET_PATH")

# Final project directory
NEW_PROJECT_DIR="$TARGET_ABS/$PROJECT_NAME"

# Check if the target project already exists
if [[ -d "$NEW_PROJECT_DIR" ]]; then
    echo -e "${RED}Error: Project '$PROJECT_NAME' already exists in '$TARGET_PATH'.${NC}"
    exit 1
fi

# Copy the template directory contents into the new project folder
echo -e "${GREEN}Creating project '$PROJECT_NAME' at '$TARGET_PATH'...${NC}"
mkdir -p "$NEW_PROJECT_DIR"
cp -r "$TEMPLATE_ABS/" "$NEW_PROJECT_DIR"

# ✅ Auto-generate README.md with project metadata
README_FILE="$NEW_PROJECT_DIR/README.md"
echo -e "# $PROJECT_NAME\n\n" > "$README_FILE"
echo -e "## Project Overview\nDescribe the purpose of this FPGA project.\n" >> "$README_FILE"
echo -e "## Hardware Requirements\n- FPGA Board: Alchitry Cu / IceBreaker\n- Any additional components needed\n" >> "$README_FILE"
echo -e "## Status\n- [ ] Not Started\n- [ ] In Progress\n- [ ] Completed\n" >> "$README_FILE"
echo -e "${GREEN}README.md created with project metadata.${NC}"

# Set source and test directories
SRC_DIR="$NEW_PROJECT_DIR/src"
TEST_DIR="$NEW_PROJECT_DIR/test"
mkdir -p "$SRC_DIR"
mkdir -p "$TEST_DIR"

# --- Create board-specific top file for Alchitry CU ---
# Overwrite the previously generated top.v with board-specific interface
cat <<EOF > "$SRC_DIR/top.v"
module top (
    input clk,
    input rst_n,
    input usb_rx,
    output usb_tx,
    output [7:0] led
);
    // Add your board-specific logic here
endmodule
EOF

# --- Create a project file named <project_name>.v in src/ ---
PROJECT_FILE="$SRC_DIR/${PROJECT_NAME}.v"
cat <<EOF > "$PROJECT_FILE"
module ${PROJECT_NAME} (
    // Define your module interface here
);
    // Your module implementation goes here
endmodule
EOF

# --- Create a testbench file in test/ named <project_name>_tb.sv ---
TB_FILE="$TEST_DIR/${PROJECT_NAME}_tb.sv"
cat <<EOF > "$TB_FILE"
\`timescale 1ns / 1ps

module ${PROJECT_NAME}_tb;
    // Declare testbench signals

    // Instantiate the DUT
    ${PROJECT_NAME} uut (
        // Port mappings
    );

    initial begin
        \$dumpfile("waveform.vcd");
        \$dumpvars(0, ${PROJECT_NAME}_tb);
        
        // Add testbench stimulus
        clk = 0;
        reset = 1;

        @(posedge clk);
        reset = 0;
        
        \$display("Test complete at time %0t", \$time);
        \$finish;
    end

endmodule
EOF

echo -e "${GREEN}Project '$PROJECT_NAME' initialized successfully at '$NEW_PROJECT_DIR'!${NC}"