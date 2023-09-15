#!/bin/bash

# Function to install or update a systemd service
install_or_update_service() {
    local SERVICE_NAME="storage-watchdog"
    local SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
    local TIMER_FILE="/etc/systemd/system/$SERVICE_NAME.timer"
    local NEW_SERVICE_FILE="./services/storage-watchdog.service"
    local NEW_TIMER_FILE="./services/storage-watchdog.timer"
    local NEW_SERVICE_FILE_PATH=$(realpath "$NEW_SERVICE_FILE")
    local NEW_TIMER_FILE_PATH=$(realpath "$NEW_TIMER_FILE")

    # Debug logging function
    log_debug() {
        if [ "$DEBUG" = true ]; then
            echo "DEBUG: $1"
        fi
    }

    log_debug "Checking for existing service and timer files..."

    if [ -f "$SERVICE_FILE" ] || [ -f "$TIMER_FILE" ]; then
        log_debug "Stopping existing services (if active)..."
        sudo systemctl stop "$SERVICE_NAME.service" || true
        sudo systemctl stop "$SERVICE_NAME.timer" || true

        log_debug "Removing existing service and timer files..."
        sudo rm -f "$SERVICE_FILE"
        sudo rm -f "$TIMER_FILE"
    else
        log_debug "No existing service or timer files found."
    fi

    log_debug "Copying new service and timer files..."
    sudo cp "$NEW_SERVICE_FILE_PATH" "$SERVICE_FILE"
    sudo cp "$NEW_TIMER_FILE_PATH" "$TIMER_FILE"

    log_debug "Reloading systemd to apply changes..."
    sudo systemctl daemon-reload

    log_debug "Enabling and starting the timer..."
    sudo systemctl enable "$SERVICE_NAME.timer"
    sudo systemctl start "$SERVICE_NAME.timer"

    echo "Setup complete. The service is now installed and running."
}
