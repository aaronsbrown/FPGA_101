#!/bin/bash
set -e  # Exit on any error

# --- Configuration & Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${CYAN}[$(date +"%T")] INFO:${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +"%T")] SUCCESS:${NC} $1"; }
log_error()   { echo -e "${RED}[$(date +"%T")] ERROR:${NC} $1" >&2; }

usage() {
    echo "Usage: $0 [--verbose|-v] path/to/verilog_file.v ... --top top_module_name [--simulate]"
    exit 1
}

# --- Parse Arguments ---
VERBOSE=false
SIMULATE=false
VERILOG_FILES=()
TOP_MODULE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --top)
            if [[ -z "$2" ]]; then
                log_error "--top flag requires a module name."
                usage
            fi
            TOP_MODULE="$2"
            shift 2
            ;;
        --simulate)
            SIMULATE=true
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            VERILOG_FILES+=("$1")
            shift
            ;;
    esac
done

if [[ ${#VERILOG_FILES[@]} -eq 0 ]]; then
    log_error "No Verilog files provided."
    usage
fi

if [[ -z "$TOP_MODULE" ]]; then
    log_error "Top module not specified. Use --top <module_name>"
    usage
fi

# --- Resolve Absolute Paths ---
get_abs() {
    (cd "$(dirname "$1")" && echo "$(pwd)/$(basename "$1")")
}

ABS_VERILOG_FILES=()
for file in "${VERILOG_FILES[@]}"; do
    abs_file=$(get_abs "$file")
    ABS_VERILOG_FILES+=("$abs_file")
    [[ "$VERBOSE" == true ]] && log_info "Resolved: $file -> $abs_file"
done

# --- Determine Project Directory & Log Directory ---
PROJECT_DIR=$(dirname "${ABS_VERILOG_FILES[0]}")
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$BUILD_DIR/logs"
mkdir -p "$LOG_DIR"

# --- Merge Constraint Files ---
# Assume project-specific constraints are in PROJECT_DIR/constraints/
# and common constraints are in ../../common/constraints relative to the project folder.
PROJECT_CONSTRAINT_DIR="$PROJECT_DIR/constraints"
COMMON_CONSTRAINT_DIR="$PROJECT_DIR/../../common/constraints"
MERGED_PCF="$BUILD_DIR/merged_constraints.pcf"

COMMON_PCF_FILES=( $(find "$COMMON_CONSTRAINT_DIR" -maxdepth 1 -type f -name "*.pcf" 2>/dev/null) )
PROJECT_PCF_FILES=( $(find "$PROJECT_CONSTRAINT_DIR" -maxdepth 1 -type f -name "*.pcf" 2>/dev/null) )

if [[ ${#COMMON_PCF_FILES[@]} -eq 0 && ${#PROJECT_PCF_FILES[@]} -eq 0 ]]; then
    log_error "No constraint files found in either common or project directories."
    exit 1
fi

log_info "Merging constraints..."
# Create/empty the merged file
> "$MERGED_PCF"
# Append common constraints first
for file in "${COMMON_PCF_FILES[@]}"; do
    cat "$file" >> "$MERGED_PCF"
    echo "" >> "$MERGED_PCF"
done
# Append project-specific constraints
for file in "${PROJECT_PCF_FILES[@]}"; do
    cat "$file" >> "$MERGED_PCF"
    echo "" >> "$MERGED_PCF"
done
log_info "Merged constraints saved to: $MERGED_PCF"

# --- Define Output Files ---
YOSYS_JSON="$BUILD_DIR/hardware.json"
NEXTPNR_ASC="$BUILD_DIR/hardware.asc"
ICEPACK_BIN="$BUILD_DIR/hardware.bin"

# --- Step 1: Synthesis with Yosys ---
log_info "Running Yosys synthesis..."
YOSYS_CMD=(yosys -q -p "synth_ice40 -top $TOP_MODULE -json $YOSYS_JSON" "${ABS_VERILOG_FILES[@]}")
[[ "$VERBOSE" == true ]] && log_info "Yosys command: ${YOSYS_CMD[*]}"
if "${YOSYS_CMD[@]}" > "$LOG_DIR/yosys.log" 2>&1; then
    log_success "Yosys synthesis completed."
else
    log_error "Yosys synthesis failed. Check $LOG_DIR/yosys.log for details."
    exit 1
fi

# --- Step 2: Place & Route with nextpnr-ice40 ---
log_info "Running nextpnr-ice40..."
NEXTPNR_CMD=(nextpnr-ice40 --hx8k --package cb132 --json "$YOSYS_JSON" --asc "$NEXTPNR_ASC" --pcf "$MERGED_PCF")
[[ "$VERBOSE" == true ]] && log_info "nextpnr-ice40 command: ${NEXTPNR_CMD[*]}"
if "${NEXTPNR_CMD[@]}" > "$LOG_DIR/nextpnr.log" 2>&1; then
    log_success "nextpnr-ice40 completed."
else
    log_error "nextpnr-ice40 failed. Check $LOG_DIR/nextpnr.log for details."
    exit 1
fi

# --- Step 3: Bitstream Packing ---
log_info "Packing bitstream with icepack..."
if icepack "$NEXTPNR_ASC" "$ICEPACK_BIN" > "$LOG_DIR/icepack.log" 2>&1; then
    log_success "Bitstream packed successfully."
else
    log_error "icepack failed. Check $LOG_DIR/icepack.log for details."
    exit 1
fi

# --- Step 4: Upload to FPGA ---
log_info "Uploading bitstream to FPGA with iceprog..."
if iceprog "$ICEPACK_BIN" > "$LOG_DIR/iceprog.log" 2>&1; then
    log_success "Bitstream uploaded successfully."
else
    log_error "iceprog failed. Check $LOG_DIR/iceprog.log for details."
    exit 1
fi

log_success "Build & upload complete!"
