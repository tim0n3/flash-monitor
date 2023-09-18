#!/bin/bash

output_file="/var/log/free-space-$(date +\%Y\%m\%d\%H\%M\%S).csv"

echo "Drive,Avail" > "$output_file"

# List physical storage devices
devices=$(lsblk -o NAME -d -n | grep -E '^sd[a-z]+$')

# Loop through the devices and append their free space to the CSV file
for device in $devices; do
    avail_space=$(df -h /dev/"$device" | awk 'NR==2 {print $4}')

    echo "/dev/$device,$avail_space" >> "$output_file"
done

echo "Storage information saved to $output_file"