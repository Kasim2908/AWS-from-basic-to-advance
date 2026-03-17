#!/bin/bash
set -e

echo "[$(date)] Starting before-install hook..."

# Stop any existing application
if systemctl is-active --quiet nodejs-app; then
    echo "Stopping existing Node.js application..."
    systemctl stop nodejs-app || true
fi

# Clean deployment directory
echo "Cleaning deployment directory..."
rm -rf /opt/nodejs-app/*

echo "[$(date)] Before-install hook completed successfully"
exit 0
