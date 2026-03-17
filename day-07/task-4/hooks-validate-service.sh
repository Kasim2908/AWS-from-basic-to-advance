#!/bin/bash
set -e

echo "[$(date)] Starting validate-service hook..."

# Give the application a moment to fully start
sleep 2

# Check if service is running
if ! systemctl is-active --quiet nodejs-app; then
    echo "[$(date)] ERROR: Service is not running"
    exit 1
fi

# Try to reach the health endpoint
echo "Checking application health endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health || echo "000")

if [ "$response" = "200" ]; then
    echo "[$(date)] Application health check passed (HTTP $response)"
    exit 0
else
    echo "[$(date)] ERROR: Application health check failed (HTTP $response)"
    exit 1
fi
