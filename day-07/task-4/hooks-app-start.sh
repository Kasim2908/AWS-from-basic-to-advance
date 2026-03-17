#!/bin/bash
set -e

echo "[$(date)] Starting application-start hook..."

# Start the Node.js application
echo "Starting Node.js application..."
systemctl start nodejs-app

# Wait for service to be ready
echo "Waiting for service to be ready..."
sleep 2

# Verify service is running
if systemctl is-active --quiet nodejs-app; then
    echo "[$(date)] Node.js application started successfully"
    exit 0
else
    echo "[$(date)] ERROR: Failed to start Node.js application"
    exit 1
fi
