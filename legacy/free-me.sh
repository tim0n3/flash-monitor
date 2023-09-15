#!/bin/bash

# Configuration variables
drives=("sda1" "sdb1")           # List of drives to monitor (e.g., /dev/sda1)
smtp_server="smtp.mailgun.org"       # SMTP server address
sender_email="sender@example.com"    # Sender's email address
recipient_email="recipient@example.com"  # Recipient's email address
threshold_percent=25                # Threshold for low disk space (25%)

# Function to send an email notification
send_email_notification() {
    local drive_name="$1"
    local total_space="$2"
    local available_space="$3"

    subject="[ALERT] Low Disk Space on $drive_name"
    body="Drive Name: $drive_name
Total Space: $total_space
Available Space: $available_space

WARNING: Available space has dropped below $threshold_percent%."

    echo -e "Subject:$subject\n$body" | \
    /usr/sbin/sendmail -f "$sender_email" -t "$recipient_email"
}

# Main script
for drive in "${drives[@]}"; do
    drive_info=$(df -h "$drive" 2>/dev/null | tail -n 1)

    if [ -n "$drive_info" ]; then
        # Extract drive information
        drive_name=$(echo "$drive_info" | awk '{print $1}')
        total_space=$(echo "$drive_info" | awk '{print $2}')
        available_space=$(echo "$drive_info" | awk '{print $4}')
        
        # Remove '%' from available space and compare with the threshold
        available_space=${available_space%\%}
        
        if [ "$available_space" -lt "$threshold_percent" ]; then
            # Send email notification
            send_email_notification "$drive_name" "$total_space" "$available_space"
        fi
    else
        echo "Error: Unable to access drive information for $drive."
    fi
done