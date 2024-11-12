#!/bin/zsh

# beepamac - Mac Locator Alert Script
# Copyright (c) 2024 Gale Fagan - gep.dev - gep at fagan dot io
# Licensed under the BSD 2-Clause License. See the LICENSE file in the root directory for details.
#
# This script sets the output volume to maximum and repeatedly plays an alert
# sound until a specified condition is met. Useful for locating a Mac,
# especially in remote scenarios.


# Set constants for log file, semaphore file, and alert sound path
LOG_FILE="/tmp/mac_beep_locator.log"
SEMAPHORE_FILE="/tmp/mac_beep_locator_stop.pid"
ALERT_SOUND="/System/Library/Sounds/Ping.aiff" # Path to alert sound (modify if needed)

# Debug and verbosity flags for controlled output
DEBUG=true
VERBOSE=true

# Default beep method (afplay recommended for headless environments)
BEEP_METHOD="${BEEP_METHOD:-afplay}"

# Current volume level placeholder, initialized later
CURRENT_VOLUME=50

# Ensure consistent and readable logging with level, timestamp, and guaranteed newline
function log() {
    local level="$1"
    shift
    local message="$*"
    [[ -z "$message" ]] && message="No message provided"

    # Format log entry and append newline
    local log_entry
    log_entry="$(printf '[%s] [%s] %s\n' "$(date)" "$level" "$message")"

    # Log to file and optionally to console if verbose
    printf "%s\n" "$log_entry" >> "$LOG_FILE"
    [[ "$VERBOSE" == true ]] && printf "%s\n" "$log_entry" >&2
}

# Function to retrieve current volume (warns if not retrievable in headless environments)
CURRENT_VOLUME=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
if [[ -z "$CURRENT_VOLUME" ]]; then
    log "WARN" "Failed to retrieve current volume using osascript. Defaulting to $CURRENT_VOLUME."
fi

# Function to set volume to maximum, retrying if needed
function set_max_volume() {
    log "INFO" "Setting volume to maximum."
    local retries=3
    for (( i=0; i < retries; i++ )); do
        if osascript -e "set volume output volume 100" 2>> "$LOG_FILE"; then
            log "INFO" "Volume set to maximum."
            return
        else
            log "WARN" "Failed to set volume (attempt $((i+1))). Retrying..."
            sleep 0.5
        fi
    done
    log "ERROR" "Failed to set volume to maximum after $retries attempts."
}

# Function to restore original volume level
function restore_volume() {
    log "INFO" "Restoring volume to original level ($CURRENT_VOLUME)."
    local retries=3
    for (( i=0; i < retries; i++ )); do
        if osascript -e "set volume output volume $CURRENT_VOLUME" 2>> "$LOG_FILE"; then
            log "INFO" "Volume restored."
            return
        else
            log "WARN" "Failed to restore volume (attempt $((i+1))). Retrying..."
            sleep 0.5
        fi
    done
    log "ERROR" "Failed to restore volume after $retries attempts."
}

# Function to play alert sound using afplay
function make_beep() {
    log "INFO" "Playing alert sound with $BEEP_METHOD."
    if [[ ! -f "$ALERT_SOUND" ]]; then
        log "ERROR" "Alert sound file '$ALERT_SOUND' not found. Exiting."
        exit 1
    fi
    afplay "$ALERT_SOUND" 2>> "$LOG_FILE"
    if [[ $? -ne 0 && "$CLEANED_UP" == false ]]; then
        log "ERROR" "Failed to play alert sound."
        exit 1
    fi
}

# Function to play alert sound with osascript as fallback method
function make_beep_osascript() {
    log "INFO" "Attempting to play alert sound with osascript."
    osascript -e 'beep' 2>> "$LOG_FILE"
    if [[ $? -ne 0 && "$CLEANED_UP" == false ]]; then
        log "ERROR" "Failed to play alert sound with osascript."
        exit 1
    fi
}

# Cleanup function for orderly shutdown
CLEANED_UP=false
function cleanup() {
    if [[ "$CLEANED_UP" == true ]]; then return; fi
    CLEANED_UP=true
    log "INFO" "Performing cleanup."

    # Terminate any child processes and clean up semaphore file
    pkill -P $$ || jobs -p | xargs kill 2>/dev/null
    [[ -f "$SEMAPHORE_FILE" ]] && rm -f "$SEMAPHORE_FILE"

    # Restore original volume and reset terminal state
    restore_volume
    log "INFO" "Script exited successfully."
    stty sane
    echo "Script terminated." >&2
    exit 0
}

# Trap signals for proper cleanup
trap 'cleanup' INT TERM HUP QUIT
trap '[[ "$CLEANED_UP" == false ]] && cleanup' EXIT

# Check for an existing instance (semaphore file handling)
if [[ -f "$SEMAPHORE_FILE" ]]; then
    other_pid=$(cat "$SEMAPHORE_FILE")
    if ps -p "$other_pid" > /dev/null 2>&1; then
        log "WARN" "Another instance (PID $other_pid) is running. Exiting."
        exit 1
    else
        log "WARN" "Stale semaphore file detected. Removing it."
        rm -f "$SEMAPHORE_FILE"
    fi
fi
log "INFO" "Starting script with PID $$"
echo $$ > "$SEMAPHORE_FILE"

# Set volume to max and begin alert loop
set_max_volume

# Main loop (runs until semaphore file is deleted)
while true; do
    if [[ ! -f "$SEMAPHORE_FILE" ]]; then
        log "INFO" "Semaphore file removed. Stopping script."
        exit 0
    fi

    # Play alert sound with selected method
    if [[ "$BEEP_METHOD" == "afplay" ]]; then
        make_beep
    elif [[ "$BEEP_METHOD" == "osascript" ]]; then
        make_beep_osascript
    else
        log "ERROR" "Invalid BEEP_METHOD: '$BEEP_METHOD'. Exiting."
        exit 1
    fi

    # Brief pause for responsiveness
    sleep 0.5
done

