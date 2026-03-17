#!/bin/bash
# EC2 User Data Script for CodeDeploy Agent Setup
# This script runs on EC2 instance startup

set -e

echo "[$(date)] Starting EC2 initialization..."

# Update system
echo "[$(date)] Updating system packages..."
yum update -y

# Install required packages
echo "[$(date)] Installing required packages..."
yum install -y \
    ruby \
    wget \
    curl \
    git \
    nodejs \
    npm

# Create nodejs user and application directory
echo "[$(date)] Creating application user and directory..."
getent passwd nodejs > /dev/null || useradd -m -s /bin/bash nodejs
mkdir -p /opt/nodejs-app
chown -R nodejs:nodejs /opt/nodejs-app

# Download and install CodeDeploy agent
echo "[$(date)] Installing CodeDeploy agent..."
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
cd /home/ec2-user
wget https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install

chmod +x ./install
./install auto

# Start CodeDeploy agent
echo "[$(date)] Starting CodeDeploy agent..."
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Verify agent is running
systemctl status codedeploy-agent

# Create systemd service for Node.js application
echo "[$(date)] Creating systemd service for Node.js app..."
cat > /etc/systemd/system/nodejs-app.service << 'EOF'
[Unit]
Description=Node.js Application
After=network.target

[Service]
Type=simple
User=nodejs
WorkingDirectory=/opt/nodejs-app
ExecStart=/usr/bin/node /opt/nodejs-app/app.js
Restart=on-failure
RestartSec=10
Environment="NODE_ENV=production"
Environment="PORT=3000"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
systemctl daemon-reload

# Create a test index.html
echo "[$(date)] Creating test index.html..."
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS DevOps Pipeline - Node.js App</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 20px; }
        .success { color: green; font-size: 24px; }
        .info { color: #333; font-size: 16px; }
    </style>
</head>
<body>
    <div class="success">✅ EC2 Instance Ready!</div>
    <div class="info">
        <p>CodeDeploy agent installed and running</p>
        <p>Waiting for Node.js application to be deployed...</p>
    </div>
</body>
</html>
EOF

echo "[$(date)] EC2 initialization completed successfully!"
echo "[$(date)] CodeDeploy agent will now await deployment from CodeDeploy"
