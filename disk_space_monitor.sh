#!/bin/bash

output_file="/var/log/free-space-$(date +\%Y\%m\%d\%H\%M\%S).csv"
lock_file="/root/free.lock"
prev_avail_space=""

# Function to truncate log files in /var/log/
truncate_logs() {
    echo "Truncating log files in /var/log/"
    find /var/log/ -type f -exec truncate -s 0 {} \;
}

# Function to monitor storage and update the lock file
monitor_storage() {
    while true; do
        latest_file=$(ls -t /var/log/free-space-*.csv | head -1)
        latest_avail_space=$(tail -n 1 "$latest_file" | awk -F ',' '{print $2}' | sed 's/[^0-9.]//g')

        # Check if the previous value exists and is numeric
        if [[ -n $prev_avail_space ]] && [[ $prev_avail_space =~ ^[0-9.]+$ ]]; then
            # Calculate the percentage change
            change=$(echo "scale=2; ($prev_avail_space - $latest_avail_space) / $prev_avail_space * 100" | bc)

            echo "Change in free space: $change%"

            # Check if the change is greater than 5%
            if (( $(echo "$change > 5" | bc -l) )); then
                echo "Writing '1' to $lock_file"
                echo "1" > "$lock_file"
            else
                echo "Writing '0' to $lock_file"
                echo "0" > "$lock_file"
            fi
        fi

        prev_avail_space="$latest_avail_space"

        sleep 30
    done
}

# Main script
echo "Drive,Avail" > "$output_file"

# List physical storage devices
devices=$(lsblk -o NAME -d -n | grep -E '^sd[a-z]+$')

echo "Listing physical storage devices:"
for device in $devices; do
    avail_space=$(df -h /dev/"$device" | awk 'NR==2 {print $4}')
    echo "/dev/$device,$avail_space" >> "$output_file"
    echo "Added /dev/$device to $output_file"
done

echo "Storage information saved to $output_file"

# Start monitoring storage in the background
monitor_storage &

# Continuously check the lock file and truncate logs
while true; do
    lock_value=$(cat "$lock_file")

    case "$lock_value" in
        1)
            echo "Lock value is '1'. Truncating logs..."
            truncate_logs
            echo "Logs truncated."
            ;;
        0)
            echo "Lock value is '0'. Doing nothing for now."
            # Do nothing for now. // replace with appropriate function later.
            ;;
        *)
            echo "Lock value is unknown or empty. Doing nothing."
            # Empty or unknown value, do nothing
            ;;
    esac

    sleep 60
done
