#!/bin/bash
set -e  # Stop on errors

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default verbosity: off (can be enabled with --verbose or -v)
VERBOSE=false

# Logging functions
log_info() {
    echo -e "${CYAN}[$(date +"%T")] INFO:${NC} $1"
}

log_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}[$(date +"%T")] DEBUG:${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}[$(date +"%T")] SUCCESS:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +"%T")] ERROR:${NC} $1" >&2
}

# Usage message
usage() {
    echo "Usage: $0 [--verbose|-v] path/to/verilog_file.v [other_verilog_files.v ...] --top top_module_name [--pcf path/to/file.pcf] [--sdc path/to/file.sdc] [--simulate]"
    exit 1
}

# Helper function to compute absolute path (portable alternative to realpath)
get_abs() {
    (cd "$(dirname "$1")" && echo "$(pwd)/$(basename "$1")")
}

# Start execution timer
START_TIME=$(date +%s)

# Parse arguments
VERILOG_FILES=()
TOP_MODULE=""
PCF_FILE=""
SDC_FILE=""
SIMULATE=false

if [[ $# -eq 0 ]]; then
    usage
fi

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
        --pcf)
            if [[ -z "$2" ]]; then
                log_error "--pcf flag requires a file path."
                usage
            fi
            PCF_FILE="$2"
            shift 2
            ;;
        --sdc)
            if [[ -z "$2" ]]; then
                log_error "--sdc flag requires a file path."
                usage
            fi
            SDC_FILE="$2"
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

# Validate that we got at least one Verilog file and a top module name.
if [[ ${#VERILOG_FILES[@]} -eq 0 ]]; then
    log_error "No Verilog files provided."
    usage
fi

if [[ -z "$TOP_MODULE" ]]; then
    log_error "Top module not specified. Use --top <module_name>"
    usage
fi

# Convert all Verilog file paths to absolute paths
ABS_VERILOG_FILES=()
for file in "${VERILOG_FILES[@]}"; do
    abs_path="$(get_abs "$file")"
    ABS_VERILOG_FILES+=( "$abs_path" )
    log_debug "Resolved Verilog file '$file' to '$abs_path'"
done

# Determine project directory from the first Verilog file
PROJECT_DIR=$(dirname "${ABS_VERILOG_FILES[0]}")
LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"

# If PCF file is not provided, try to find one in the project directory
if [[ -z "$PCF_FILE" ]]; then
    PCF_FILES=()
    while IFS= read -r line; do
        PCF_FILES+=("$line")
    done < <(find "$PROJECT_DIR" -maxdepth 1 -type f -name "*.pcf")
    
    if [[ ${#PCF_FILES[@]} -eq 1 ]]; then
        PCF_FILE="${PCF_FILES[0]}"
        PCF_FILE=$(get_abs "$PCF_FILE")
        log_info "Found PCF file: $PCF_FILE"
    elif [[ ${#PCF_FILES[@]} -gt 1 ]]; then
        log_error "Multiple PCF files found in '$PROJECT_DIR'. Please specify one with --pcf."
        exit 1
    else
        log_error "No PCF file found in '$PROJECT_DIR'. Aborting."
        exit 1
    fi
else
    PCF_FILE=$(get_abs "$PCF_FILE")
fi

# If SDC file is not provided, try to find one in the project directory
if [[ -z "$SDC_FILE" ]]; then
    SDC_FILES=()
    while IFS= read -r line; do
        SDC_FILES+=("$line")
    done < <(find "$PROJECT_DIR" -maxdepth 1 -type f -name "*.sdc")
    
    if [[ ${#SDC_FILES[@]} -ge 1 ]]; then
        SDC_FILE=$(get_abs "${SDC_FILES[0]}")
        log_info "Found SDC file: $SDC_FILE"
    else
        log_info "No SDC file found, continuing without it."
        SDC_FILE=""
    fi
else
    SDC_FILE=$(get_abs "$SDC_FILE")
fi

log_info "Using Verilog files: ${ABS_VERILOG_FILES[*]}"
log_info "Top module: $TOP_MODULE"
log_info "Constraint file (PCF): $PCF_FILE"
if [[ -n "$SDC_FILE" ]]; then
    log_info "Timing file (SDC): $SDC_FILE"
fi

# Define output file paths
YOSYS_JSON="$PROJECT_DIR/hardware.json"
NEXTPNR_ASC="$PROJECT_DIR/hardware.asc"
ICEPACK_BIN="$PROJECT_DIR/hardware.bin"

# Step 1: Run Yosys Synthesis
log_info "Running Yosys synthesis..."
YOSYS_CMD=(yosys -q -p "synth_ice40 -top $(basename "$TOP_MODULE" .v) -json $YOSYS_JSON" "${ABS_VERILOG_FILES[@]}")
if [ "$VERBOSE" = true ]; then
    log_debug "Yosys command: ${YOSYS_CMD[*]}"
fi
if "${YOSYS_CMD[@]}" > "$LOG_DIR/yosys.log" 2>&1; then
    log_success "Yosys synthesis completed."
else
    log_error "Yosys failed! Check yosys.log for details."
    cat "$LOG_DIR/yosys.log"
    exit 1
fi

if [[ ! -f "$YOSYS_JSON" ]]; then
    log_error "Yosys did not generate $YOSYS_JSON!"
    exit 1
fi

# Step 2: Run nextpnr-ice40
log_info "Running nextpnr-ice40..."
NEXTPNR_CMD=(nextpnr-ice40 --hx8k --package cb132 --json "$YOSYS_JSON" --asc "$NEXTPNR_ASC" --pcf "$PCF_FILE")
[[ -n "$SDC_FILE" ]] && NEXTPNR_CMD+=(--sdc "$SDC_FILE")
if [ "$VERBOSE" = true ]; then
    log_debug "nextpnr-ice40 command: ${NEXTPNR_CMD[*]}"
fi
if "${NEXTPNR_CMD[@]}" > "$LOG_DIR/nextpnr.log" 2>&1; then
    log_success "nextpnr-ice40 completed."
else
    log_error "nextpnr-ice40 failed! Check nextpnr.log for details."
    cat "$LOG_DIR/nextpnr.log"
    exit 1
fi

if [[ ! -f "$NEXTPNR_ASC" ]]; then
    log_error "nextpnr-ice40 did not generate $NEXTPNR_ASC!"
    exit 1
fi

# Step 3: Generate Bitstream
log_info "Packing bitstream..."
if [ "$VERBOSE" = true ]; then
    log_debug "icepack command: icepack $NEXTPNR_ASC $ICEPACK_BIN"
fi
if icepack "$NEXTPNR_ASC" "$ICEPACK_BIN" > "$LOG_DIR/icepack.log" 2>&1; then
    log_success "Bitstream packed successfully."
else
    log_error "icepack failed! Check icepack.log for details."
    cat "$LOG_DIR/icepack.log"
    exit 1
fi

if [[ ! -f "$ICEPACK_BIN" ]]; then
    log_error "icepack did not generate $ICEPACK_BIN!"
    exit 1
fi

# Step 4: Upload to FPGA
log_info "Uploading to FPGA..."
if [ "$VERBOSE" = true ]; then
    log_debug "iceprog command: iceprog -d i:0x0403:0x6010:0 $ICEPACK_BIN"
fi
if iceprog -d i:0x0403:0x6010:0 "$ICEPACK_BIN" > "$LOG_DIR/iceprog.log" 2>&1; then
    log_success "Bitstream uploaded to FPGA."
else
    log_error "Upload failed! Check iceprog.log for details."
    cat "$LOG_DIR/iceprog.log"
    exit 1
fi

# Print execution time
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
log_info "Total execution time: ${ELAPSED_TIME}s"

log_success "Build & upload complete!"
