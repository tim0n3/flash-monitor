#!/bin/bash

LOG_FILE="/root/burnLogs.log"

log_debug() {
    echo "$(date) - DEBUG: $1" >> "$LOG_FILE"
}

log_error() {
    echo "$(date) - ERROR: $1" >> "$LOG_FILE"
}

storage_maid_main() {
    log_debug "Script started."

    if [ ! -d "/var/log" ]; then
        log_error "/var/log directory not found."
        exit 1
    fi

    log_debug "Finding log files in /var/log..."
    for log_file in $(find /var/log -type f); do
        log_debug "Truncating $log_file..."
        if ! cat /dev/null > "$log_file"; then
            log_error "Error truncating $log_file."
        else
            log_debug "Cleared $log_file logs."
        fi
    done

    log_debug "Script completed."
}

storage_maid_main "$@"