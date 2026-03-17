#!/bin/bash
set -e

echo "[$(date)] Starting after-install hook..."

cd /opt/nodejs-app

# Install Node.js dependencies
echo "Installing npm dependencies..."
npm install --production

# Set proper permissions
echo "Setting file permissions..."
chown -R nodejs:nodejs /opt/nodejs-app
chmod -R 755 /opt/nodejs-app

echo "[$(date)] After-install hook completed successfully"
exit 0
