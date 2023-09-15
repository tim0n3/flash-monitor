#!/bin/bash


################################
################################
## Testing AIO script with    ##
## new storage monitor logic. ##
##                            ##
## Author: Tim Forbes         ##
## Copyright: 202309070713    ##
################################
################################

# Constants
LOG_DIR="/var/log"
STDOUT_LOG="$LOG_DIR/stdout-storage-monitor.log"
STDERR_LOG="$LOG_DIR/stderr-storage-monitor.log"
THRESHOLD_30M=1000000   # 1GB in KB
THRESHOLD_1H=3600000    # 1GB in KB
THRESHOLD_12H=36000000  # 3GB in KB
EMAIL_ADDRESS="your@email.com"

# Function to log to stdout and a log file
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$STDOUT_LOG"
}

# Function to log errors to stderr and a log file
log_error() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $message" | tee -a "$STDERR_LOG"
}

# Function to send an email
send_email() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$EMAIL_ADDRESS"
}

# Function to monitor storage space and send warnings
monitor_storage() {
    local device="$1"
    
    while true; do
        current_usage=$(df "$device" | awk 'NR==2 {print $3}')
        
        if [ "$current_usage" -gt "$THRESHOLD_30M" ]; then
            log "Warning: $device usage exceeded 1GB in 30 minutes"
            send_email "Storage Warning" "Storage on $device exceeded 1GB in 30 minutes."
        elif [ "$current_usage" -gt "$THRESHOLD_1H" ]; then
            log "Warning: $device usage exceeded 1GB in 1 hour"
            send_email "Storage Warning" "Storage on $device exceeded 1GB in 1 hour."
        elif [ "$current_usage" -gt "$THRESHOLD_12H" ]; then
            log "Warning: $device usage exceeded 3GB in 12 hours"
            send_email "Storage Warning" "Storage on $device exceeded 3GB in 12 hours."
        fi
        
        sleep 1800  # Sleep for 30 minutes
    done
}

# Function to reset threshold tracking
reset_thresholds() {
    log "Resetting threshold tracking"
}

# Function to monitor storage space and reset thresholds
monitor_storage_and_reset() {
    local device="$1"
    while true; do
        monitor_storage "$device"
        reset_thresholds
    done
}

# Main script

# Enable debug logging
exec > >(tee -a "$STDOUT_LOG")
exec 2> >(while read line; do log_error "$line"; done)

# Start monitoring storage on specific devices/partitions
monitor_storage_and_reset "/dev/sda1"
monitor_storage_and_reset "/dev/sdb1"

# Schedule daily storage stats email and queue notifications
while true; do
    if [ "$(date '+%H')" -lt 4 ]; then
        # Send an email with current storage stats
        df -h | send_email "Storage Stats" "$(cat -)"
    fi
    
    # Check storage space and queue notification
    storage_status=$(df -h)
    if [[ $storage_status == *"/dev/sda1"* || $storage_status == *"/dev/sdb1"* ]]; then
        log "Storage less than 50% available on /dev/sda1 or /dev/sdb1. Queuing notification."
        echo "Storage less than 50% available on /dev/sda1 or /dev/sdb1." >> "$STDOUT_LOG"
    fi
    
    sleep 14400  # Sleep for 4 hours
done
