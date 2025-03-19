#!/bin/bash
set -e  # Exit on error

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
    echo "Usage: $0 [--verbose|-v] [--tb testbench_file.v]"
    exit 1
}

# --- Parse Arguments ---
VERBOSE=false
TB_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v)
            VERBOSE=true
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
            log_error "Unexpected argument: $1"
            usage
            ;;
    esac
done

# --- Determine Directories ---
# Get directory of this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Assume the project root is one level above tools.
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# Directory containing common modules.
COMMON_MODULES_DIR="$PROJECT_ROOT/common/modules"
# Directory containing simulation test benches.
SIM_TEST_DIR="$PROJECT_ROOT/simulation_tests"
# Build directory for simulation (we create a dedicated one here).
SIM_BUILD_DIR="$SIM_TEST_DIR/build"

mkdir -p "$SIM_BUILD_DIR"
log_debug "Project root: $PROJECT_ROOT"
log_debug "Common modules: $COMMON_MODULES_DIR"
log_debug "Simulation tests: $SIM_TEST_DIR"
log_debug "Simulation build directory: $SIM_BUILD_DIR"

# --- Determine Testbench File ---
if [ -n "$TB_FILE" ]; then
    # If a testbench filename is provided and it doesn't include a slash, prepend SIM_TEST_DIR.
    if [[ "$TB_FILE" != *"/"* ]]; then
        TB_FILE="$SIM_TEST_DIR/$TB_FILE"
    fi
    TESTBENCH_FILE="$(cd "$(dirname "$TB_FILE")" && pwd)/$(basename "$TB_FILE")"
    if [ ! -f "$TESTBENCH_FILE" ]; then
        log_error "Specified testbench file $TESTBENCH_FILE does not exist."
        exit 1
    fi
    log_info "Using specified testbench file: $TESTBENCH_FILE"
else
    # No testbench specified; search SIM_TEST_DIR for *_tb.v files.
    log_info "Searching for testbench files in $SIM_TEST_DIR..."
    TEST_FILES=($(find "$SIM_TEST_DIR" -maxdepth 1 -type f -name "*_tb.v" 2>/dev/null))
    if [ ${#TEST_FILES[@]} -eq 0 ]; then
        log_error "No testbench files found in $SIM_TEST_DIR. Please add a testbench file ending with _tb.v."
        exit 1
    elif [ ${#TEST_FILES[@]} -gt 1 ]; then
        log_error "Multiple testbench files found in $SIM_TEST_DIR. Use the --tb flag to specify one."
        exit 1
    else
        TESTBENCH_FILE="$(cd "$(dirname "${TEST_FILES[0]}")" && pwd)/$(basename "${TEST_FILES[0]}")"
        log_info "Using testbench file: $TESTBENCH_FILE"
    fi
fi

# --- Gather Common Module Files ---
COMMON_FILES=($(find "$COMMON_MODULES_DIR" -maxdepth 1 -type f -name "*.v" 2>/dev/null))
if [ ${#COMMON_FILES[@]} -eq 0 ]; then
    log_error "No common module files found in $COMMON_MODULES_DIR."
    exit 1
fi

# --- Build Simulation Source List ---
# We will compile all common modules and the selected testbench.
SIM_SRC_FILES=()
for file in "${COMMON_FILES[@]}"; do
    ABS_FILE="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
    SIM_SRC_FILES+=("$ABS_FILE")
    [ "$VERBOSE" = true ] && log_debug "Added common source: $ABS_FILE"
done
SIM_SRC_FILES+=("$TESTBENCH_FILE")
[ "$VERBOSE" = true ] && log_debug "Final simulation source list: ${SIM_SRC_FILES[*]}"

# --- Compile Simulation ---
SIM_VVP="$SIM_BUILD_DIR/sim_common.vvp"
IVERILOG_CMD=(iverilog -o "$SIM_VVP" "${SIM_SRC_FILES[@]}")
[ "$VERBOSE" = true ] && log_debug "Iverilog command: ${IVERILOG_CMD[*]}"
if "${IVERILOG_CMD[@]}" > "$SIM_BUILD_DIR/iverilog.log" 2>&1; then
    log_success "Iverilog compilation completed."
else
    log_error "Iverilog failed. Check $SIM_BUILD_DIR/iverilog.log."
    exit 1
fi

# --- Run Simulation ---
pushd "$SIM_BUILD_DIR" > /dev/null
log_info "Running simulation with vvp..."
if vvp "sim_common.vvp" > "$SIM_BUILD_DIR/vvp.log" 2>&1; then
    log_success "vvp simulation completed."
else
    log_error "vvp simulation failed. Check $SIM_BUILD_DIR/vvp.log."
    popd > /dev/null
    exit 1
fi
popd > /dev/null

# --- Open Waveform ---
WAVEFORM="$SIM_BUILD_DIR/waveform.vcd"
if [ -f "$WAVEFORM" ]; then
    log_info "Opening waveform in gtkwave..."
    gtkwave "$WAVEFORM" &
else
    log_error "Waveform file $WAVEFORM not found. Ensure your testbench generates a VCD file (e.g., via \$dumpfile)."
fi

exit 0