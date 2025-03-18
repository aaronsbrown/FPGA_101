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

# ✅ Auto-generate default top.v in /src/
SRC_DIR="$NEW_PROJECT_DIR/src"
mkdir -p "$SRC_DIR"
TOP_FILE="$SRC_DIR/top.v"
echo -e "module $PROJECT_NAME (\n    input clk,\n    input rst_n\n);\n\n// Add logic here\n\nendmodule" > "$TOP_FILE"
echo -e "${GREEN}Generated default Verilog file: src/top.v${NC}"

# ✅ Auto-add project to Git tracking if in a Git repo
if [[ -d "$TARGET_ABS/.git" ]]; then
    git add "$NEW_PROJECT_DIR"
    echo -e "${GREEN}Added '$PROJECT_NAME' to Git tracking.${NC}"
fi

echo -e "${GREEN}Project '$PROJECT_NAME' initialized successfully at '$NEW_PROJECT_DIR'!${NC}"