#!/bin/bash

# Replace with your Mailgun API key and domain
MAILGUN_API_KEY="YOUR_API_KEY"
MAILGUN_DOMAIN="YOUR_DOMAIN"

# Log file to send via email
LOG_FILE="/root/mail/storage.log"

# Recipient email address
TO_EMAIL="recipient@example.com"

# Mailgun API endpoint
MAILGUN_API="https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages"

# Email subject and sender
SUBJECT="Log File from Server"
FROM_EMAIL="sender@example.com"

# Send the email
curl -s --user "api:$MAILGUN_API_KEY" \
     "$MAILGUN_API" \
     -F from="$FROM_EMAIL" \
     -F to="$TO_EMAIL" \
     -F subject="$SUBJECT" \
     -F text="Log file attached." \
     -F attachment=@"$LOG_FILE"

# Log the script execution (optional)
echo "Log email script executed at $(date)" >> /var/log/log_emailer.log

taken from Tim's 'template libs