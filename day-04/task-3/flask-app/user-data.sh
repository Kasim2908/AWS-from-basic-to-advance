#!/bin/bash
yum update -y
yum install -y python3 python3-pip git

# Set environment variables
export RDS_HOST="your-rds-endpoint.rds.amazonaws.com"
export RDS_USER="admin"
export RDS_PASSWORD="your-password"
export RDS_DB="ecommerce"

# Clone or create app
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Install dependencies
pip3 install Flask pymysql

# Create app.py (inline for simplicity)
cat > app.py << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/')
def index():
    return jsonify({'message': 'Flask App Running'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Run Flask app
nohup python3 app.py > app.log 2>&1 &
