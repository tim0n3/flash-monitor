#!/bin/bash

prev_avail_space=""

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
            echo "Writing '1' to /root/free.lock"
            echo "1" > /root/free.lock
        else
            echo "Writing '0' to /root/free.lock"
            echo "0" > /root/free.lock
        fi
    fi
    
    prev_avail_space="$latest_avail_space"
    
    sleep 300
done
