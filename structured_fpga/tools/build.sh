#!/bin/bash
set -e  # Exit on any error

# --- Configuration & Logging ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

log_info()    { echo -e "${CYAN}[$(date +"%T")] INFO:${NC} $1"; }
log_debug()   { [ "$VERBOSE" = true ] && echo -e "${YELLOW}[$(date +"%T")] DEBUG:${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +"%T")] SUCCESS:${NC} $1"; }
log_error()   { echo -e "${RED}[$(date +"%T")] ERROR:${NC} $1" >&2; }

usage() {
    echo "Usage: $0 [--verbose|-v] path/to/verilog_file.v ... --top top_module_name [--simulate] [--tb testbench_file.v]"
    exit 1
}

# --- Parse Arguments ---
VERBOSE=false
SIMULATE=false
TB_FILE=""   # Testbench file (optional, for simulation only)
VERILOG_FILES=()
TOP_MODULE=""

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
        --simulate)
            SIMULATE=true
            shift
            ;;
        --tb)
            if [[ -z "$2" ]]; then
                log_error "--tb flag requires a testbench file."
                usage
            fi
            TB_FILE="$2"
            shift 2
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

# --- Helper Function: Resolve Absolute Paths ---
get_abs() {
    (cd "$(dirname "$1")" && echo "$(pwd)/$(basename "$1")")
}

# --- Convert Provided Verilog Files to Absolute Paths ---
ABS_VERILOG_FILES=()
for file in "${VERILOG_FILES[@]}"; do
    abs_file=$(get_abs "$file")
    ABS_VERILOG_FILES+=("$abs_file")
    [ "$VERBOSE" = true ] && log_debug "Resolved: $file -> $abs_file"
done

# --- Determine Project Directory ---
# We assume the provided verilog file is in the project's "src" directory.
# Therefore, the project directory is one level up from the src folder.
SRC_DIR=$(dirname "${ABS_VERILOG_FILES[0]}")
PROJECT_DIR=$(dirname "$SRC_DIR")
[ "$VERBOSE" = true ] && log_debug "Project directory determined as: $PROJECT_DIR"

# --- Setup Build and Log Directories ---
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$BUILD_DIR/logs"
mkdir -p "$LOG_DIR"

# --- Automatically Include Common Modules ---
# From the project directory, common modules are located at ../../common/modules.
COMMON_MODULES_DIR="$(cd "$PROJECT_DIR/../../common/modules" && pwd)"
if [ -d "$COMMON_MODULES_DIR" ]; then
    log_info "Searching for common modules in $COMMON_MODULES_DIR..."
    COMMON_MODULE_FILES=($(find "$COMMON_MODULES_DIR" -maxdepth 1 -type f -name "*.v" 2>/dev/null))
    if [ ${#COMMON_MODULE_FILES[@]} -gt 0 ]; then
        for file in "${COMMON_MODULE_FILES[@]}"; do
            abs_file="$(get_abs "$file")"
            ABS_VERILOG_FILES+=("$abs_file")
            [ "$VERBOSE" = true ] && log_debug "Added common module: $abs_file"
        done
    else
        log_info "No common module files found in $COMMON_MODULES_DIR."
    fi
else
    log_error "Common modules directory $COMMON_MODULES_DIR does not exist."
fi

# --- Merge Constraint Files ---
# Project-specific constraints are in PROJECT_DIR/constraints.
# Common constraints are located at ../../common/constraints relative to the project directory.
PROJECT_CONSTRAINT_DIR="$PROJECT_DIR/constraints"
COMMON_CONSTRAINT_DIR="$(cd "$PROJECT_DIR/../../common/constraints" && pwd)"
MERGED_PCF="$BUILD_DIR/merged_constraints.pcf"

COMMON_PCF_FILES=( $(find "$COMMON_CONSTRAINT_DIR" -maxdepth 1 -type f -name "*.pcf" 2>/dev/null) )
PROJECT_PCF_FILES=( $(find "$PROJECT_CONSTRAINT_DIR" -maxdepth 1 -type f -name "*.pcf" 2>/dev/null) )

if [[ ${#COMMON_PCF_FILES[@]} -eq 0 && ${#PROJECT_PCF_FILES[@]} -eq 0 ]]; then
    log_error "No constraint files found in either common or project directories."
    exit 1
fi

log_info "Merging constraint files..."
> "$MERGED_PCF"  # Create or empty the merged file
# Append common constraints first.
for file in "${COMMON_PCF_FILES[@]}"; do
    cat "$file" >> "$MERGED_PCF"
    echo "" >> "$MERGED_PCF"
done
# Append project-specific constraints.
for file in "${PROJECT_PCF_FILES[@]}"; do
    cat "$file" >> "$MERGED_PCF"
    echo "" >> "$MERGED_PCF"
done
log_info "Merged constraints saved to: $MERGED_PCF"

# --- Simulation Flow (if --simulate flag is provided) ---
if [ "$SIMULATE" = true ]; then
    log_info "Running simulation flow..."
    SIM_VVP="$BUILD_DIR/sim.vvp"

    # Determine the testbench file to include.
    if [ -n "$TB_FILE" ]; then
        # If a testbench file is provided via --tb, prepend the test directory if no "/" is found.
        if [[ "$TB_FILE" != *"/"* ]]; then
            TB_FILE="$PROJECT_DIR/test/$TB_FILE"
        fi
        TESTBENCH_FILE=$(get_abs "$TB_FILE")
        if [ ! -f "$TESTBENCH_FILE" ]; then
            log_error "Specified testbench file $TESTBENCH_FILE does not exist."
            exit 1
        fi
        log_info "Using specified testbench file: $TESTBENCH_FILE"
        ABS_VERILOG_FILES+=("$TESTBENCH_FILE")
    else
        # No testbench provided, so search the test directory.
        TEST_DIR="$PROJECT_DIR/test"
        if [ -d "$TEST_DIR" ]; then
            log_info "Searching for testbench files in $TEST_DIR..."
            TEST_FILES=($(find "$TEST_DIR" -maxdepth 1 -type f -name "*_tb.v" 2>/dev/null))
            if [ ${#TEST_FILES[@]} -eq 0 ]; then
                log_error "No testbench files found in $TEST_DIR. Please add a testbench file ending with _tb.v."
                exit 1
            elif [ ${#TEST_FILES[@]} -gt 1 ]; then
                log_error "Multiple testbench files found in $TEST_DIR. Use the --tb flag to specify one."
                exit 1
            else
                TESTBENCH_FILE=$(get_abs "${TEST_FILES[0]}")
                log_info "Using testbench file: $TESTBENCH_FILE"
                ABS_VERILOG_FILES+=("$TESTBENCH_FILE")
            fi
        else
            log_error "Test directory $TEST_DIR not found."
            exit 1
        fi
    fi

    # Compile simulation sources with iverilog.
    IVERILOG_CMD=(iverilog -o "$SIM_VVP" "${ABS_VERILOG_FILES[@]}")
    [ "$VERBOSE" = true ] && log_debug "Iverilog command: ${IVERILOG_CMD[*]}"
    if "${IVERILOG_CMD[@]}" > "$LOG_DIR/iverilog.log" 2>&1; then
        log_success "Iverilog compilation completed."
    else
        log_error "Iverilog failed. Check $LOG_DIR/iverilog.log."
        exit 1
    fi

    # Run simulation using vvp from within the build directory so the waveform file is generated there.
    pushd "$BUILD_DIR" > /dev/null
    log_info "Running simulation with vvp..."
    if vvp "sim.vvp" > "$LOG_DIR/vvp.log" 2>&1; then
        log_success "vvp simulation completed."
    else
        log_error "vvp simulation failed. Check $LOG_DIR/vvp.log."
        popd > /dev/null
        exit 1
    fi
    popd > /dev/null

    # Attempt to open the generated waveform (assumed to be at BUILD_DIR/waveform.vcd).
    WAVEFORM="$BUILD_DIR/waveform.vcd"
    if [ -f "$WAVEFORM" ]; then
        log_info "Opening waveform in gtkwave..."
        gtkwave "$WAVEFORM" &
    else
        log_error "Waveform file $WAVEFORM not found. Ensure your testbench generates a VCD file."
    fi

    exit 0
fi

# --- FPGA Build Flow ---
# Define Output Files
YOSYS_JSON="$BUILD_DIR/hardware.json"
NEXTPNR_ASC="$BUILD_DIR/hardware.asc"
ICEPACK_BIN="$BUILD_DIR/hardware.bin"

# --- Step 1: Synthesis with Yosys ---
log_info "Running Yosys synthesis..."
YOSYS_CMD=(yosys -q -p "synth_ice40 -top $TOP_MODULE -json $YOSYS_JSON" "${ABS_VERILOG_FILES[@]}")
[ "$VERBOSE" = true ] && log_debug "Yosys command: ${YOSYS_CMD[*]}"
if "${YOSYS_CMD[@]}" > "$LOG_DIR/yosys.log" 2>&1; then
    log_success "Yosys synthesis completed."
else
    log_error "Yosys synthesis failed. Check $LOG_DIR/yosys.log for details."
    exit 1
fi

# --- Step 2: Place & Route with nextpnr-ice40 ---
log_info "Running nextpnr-ice40..."
NEXTPNR_CMD=(nextpnr-ice40 --hx8k --package cb132 --json "$YOSYS_JSON" --asc "$NEXTPNR_ASC" --pcf "$MERGED_PCF")
[ "$VERBOSE" = true ] && log_debug "nextpnr-ice40 command: ${NEXTPNR_CMD[*]}"
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