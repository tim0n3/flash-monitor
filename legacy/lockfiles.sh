#!/bin/bash

lock_file="/root/free.lock"

# Function to truncate log files in /var/log/
truncate_logs() {
    echo "Truncating log files in /var/log/"
    find /var/log/ -type f -exec truncate -s 0 {} \;
}

while true; do
    lock_value=$(cat "$lock_file")
    
    case "$lock_value" in
        1)
            truncate_logs
            ;;
        0)
            # Do nothing for now. // replace with appropriate function later.
            ;;
        *)
            # Empty or unknown value, do nothing
            ;;
    esac
    
    sleep 60
done
