#!/bin/bash

# Output file with datestamp
output_file="/var/log/drive/free-space-$(date +\%Y\%m\%d\%H\%M\%S).csv"

# Header in the CSV file
echo "Drive,Avail" > "$output_file"

# List physical storage devices
devices=$(lsblk -o NAME -d -n | grep -E '^sd[a-z]+$')

# Loop through the devices and append their free space to the CSV file
for device in $devices; do
    # Get available free space in GB
    avail_space=$(df -h /dev/"$device" | awk 'NR==2 {print $4}')
    
    # Append device name and available free space to the CSV file
    echo "/dev/$device,$avail_space" >> "$output_file"
done

# Print a message with the CSV file location
echo "Storage information saved to $output_file"
