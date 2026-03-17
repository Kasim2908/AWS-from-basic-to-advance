#!/bin/bash

echo "[$(date)] Starting application-stop hook..."

# Stop the Node.js application gracefully
if systemctl is-active --quiet nodejs-app; then
    echo "Stopping Node.js application..."
    systemctl stop nodejs-app
    sleep 1
fi

echo "[$(date)] Application-stop hook completed"
exit 0
