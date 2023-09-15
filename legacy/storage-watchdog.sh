#!/bin/bash

# Create headers for the table
printf "%-10s %-15s %-15s %-15s\n" "Device" "Size" "Available" "Used (%)"
printf "============================================\n"

# Function to log used percentage values higher than 50%
log_high_usage() {
    local device="$1"
    local used_percentage="$2"

    if (( $(bc <<< "$used_percentage > 50") )); then
        echo "High usage on $device: $used_percentage%" >> /root/mail/storage.log
    fi
}

# Loop through each device and gather information
df -P | while read -r line; do
    # Skip the header line
    if [[ "$line" == "Filesystem"* ]]; then
        continue
    fi

    # Extract device name, size, and available space
    device_name=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    avail=$(echo "$line" | awk '{print $4}')

    # Calculate used space
    used=$(echo "$size - $avail" | bc)

    # Calculate used percentage
    used_percentage=$(echo "scale=2; ($used / $size) * 100" | bc)

    # Check if device name exists and used percentage is not empty
    if [ -n "$device_name" ] && [ -n "$used_percentage" ]; then
        # Check if used percentage is >= 0
        if (( $(bc <<< "$used_percentage >= 0") )); then
            # Log used percentage values higher than 50%
            log_high_usage "$device_name" "$used_percentage"

            # Check if used percentage is >= 50 and print in red
            if (( $(bc <<< "$used_percentage > 50") )); then
                printf "\e[31m%-10s %-15s %-15s %-15s\e[0m\n" "$device_name" "$size" "$avail" "$used_percentage%"
            else
                printf "%-10s %-15s %-15s %-15s\n" "$device_name" "$size" "$avail" "$used_percentage%"
            fi
        fi
    fi
done