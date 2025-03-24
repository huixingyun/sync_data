#!/usr/bin/env bash

cd "$(dirname "$0")"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Verify required environment variables
if [ -z "$WEBHOOK_URL" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_USER" ] ||
    [ -z "$REMOTE_DIR" ] || [ -z "$LOCAL_DIR" ] || [ -z "$SSH_PORT" ]; then
    echo "Error: Required environment variables are not set in .env file"
    exit 1
fi

# Function to send webhook notification
send_notification() {
    local subject="$1"
    local message="$2"
    local hostname=$(hostname)

    response=$(
        curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d @- <<EOF
{
    "msg_type": "post",
    "content": {
        "post": {
            "zh_cn": {
                "title": "[${hostname}] ${subject}",
                "content": [
                    [{"tag": "text", "text": "${message}"}]
                ]
            }
        }
    }
}
EOF
    )

    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" = "200" ]; then
        echo "Webhook notification sent successfully"
    else
        echo "Failed to send webhook notification. Status code: $http_code"
    fi
}

# Create local directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

# Perform the sync using rclone
echo "Starting sync from $REMOTE_HOST:$REMOTE_DIR to $LOCAL_DIR"
RCLONE_SFTP_HOST="$REMOTE_HOST" \
RCLONE_SFTP_USER="$REMOTE_USER" \
RCLONE_SFTP_PORT="$SSH_PORT" \
RCLONE_SFTP_PASS="$RCLONE_SFTP_PASS" \
rclone sync ":sftp:$REMOTE_DIR" "$LOCAL_DIR" \
    --links \
    --transfers 8 \
    --checkers 16 \
    --buffer-size 32M \
    --sftp-set-modtime \
    --bwlimit 200M \
    --progress

# Check if sync was successful
if [ $? -eq 0 ]; then
    echo "Sync completed successfully"
    send_notification "Data sync completed successfully" "The directory $REMOTE_DIR has been synchronized to $LOCAL_DIR"
else
    echo "Sync failed"
    send_notification "Data sync failed" "Failed to synchronize directory $REMOTE_DIR to $LOCAL_DIR"
fi
