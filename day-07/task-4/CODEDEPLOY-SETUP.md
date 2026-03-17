# Task 4: Configure CodeDeploy 🎯

## Objective
Set up AWS CodeDeploy to automatically deploy the Node.js application built by CodeBuild to an EC2 instance.

---

## What You'll Learn
✅ EC2 instance creation and IAM role configuration
✅ CodeDeploy agent installation and configuration
✅ appspec.yml file for deployment specifications
✅ Lifecycle hooks for deployment steps
✅ Deployment validation and health checks
✅ Monitoring deployments in CodeDeploy console

---

## Prerequisites

Before starting, ensure you have:
- ✅ CodeBuild project created ([Task 3](../task-3/CODEBUILD-SETUP.md))
- ✅ S3 bucket with artifacts ([Task 2](../task-2/S3-SETUP.md))
- ✅ AWS account with EC2 permissions
- ✅ Key pair for SSH access (optional but recommended)

---

## Part 1: Create EC2 Instance with CodeDeploy

### Step 1: Create IAM Role for EC2

EC2 needs permissions to pull artifacts from S3 and interact with CodeDeploy.

1. **Open AWS Console** → IAM → Roles → **Create role**

2. **Select trusted entity:**
   - Trusted entity type: **AWS service**
   - Service: **EC2**
   - Click **Next**

3. **Add permissions:**
   - Search for policy: `AmazonEC2CodeDeployRole`
   - ✅ Check it
   - Search for policy: `AmazonSSMManagedInstanceCore`
   - ✅ Check it (for Systems Manager access)
   - Click **Next**

4. **Add custom inline policy for S3:**
   - **Add inline policy** → **JSON** tab
   - Paste this:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::aws-cicd-artifacts-123456789012/*",
        "arn:aws:s3:::aws-cicd-artifacts-123456789012"
      ]
    }
  ]
}
```

   - Replace bucket name with yours
   - Click **Create policy**

5. **Role name:**
   - `EC2-CodeDeploy-Role`
   - Click **Create role**

### Step 2: Create EC2 Instance

1. **Open AWS Console** → EC2 → **Launch instances**

2. **Basic configuration:**
   - Name: `nodejs-codedeploy-target`
   - AMI: **Amazon Linux 2 AMI** (Free tier eligible)
   - Instance type: **t2.micro** (Free tier)

3. **Key pair:**
   - Create or select existing key pair
   - Name: `nodejs-devops-key` (if creating new)
   - ⚠️ Download and save the `.pem` file safely!

4. **Network configuration:**
   - VPC: Default VPC
   - Subnet: Default subnet
   - Auto-assign public IP: **Enable**
   - Security group: **Create new security group**
     - Name: `nodejs-codedeploy-sg`
     - Inbound rules:
       | Type | Protocol | Port | Source |
       |------|----------|------|--------|
       | SSH | TCP | 22 | 0.0.0.0/0 (⚠️ or restrict to your IP) |
       | HTTP | TCP | 80 | 0.0.0.0/0 |
       | Custom TCP | TCP | 3000 | 0.0.0.0/0 |

5. **Advanced details:**
   - IAM instance profile: Select **EC2-CodeDeploy-Role**
   - User data - Copy the following startup script content and paste it below:

```bash
#!/bin/bash

# Update system
yum update -y

# Install required packages
yum install -y ruby wget curl git nodejs npm

# Create nodejs user
useradd -m -s /bin/bash nodejs
mkdir -p /opt/nodejs-app
chown -R nodejs:nodejs /opt/nodejs-app

# Download and install CodeDeploy agent
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
cd /home/ec2-user
wget https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Start CodeDeploy agent
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Create systemd service for Node.js app
cat > /etc/systemd/system/nodejs-app.service << 'SERVICEOF'
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
SERVICEOF

systemctl daemon-reload
systemctl enable nodejs-app
```

6. **Review and Launch**
   - Review all settings
   - Click **Launch instance**

7. **Wait for instance to start**
   - Go to EC2 → Instances
   - Wait until status shows "Running" and status checks pass (2/2)
   - This takes ~2 minutes

### Step 3: Verify CodeDeploy Agent Installation

Once EC2 is ready:

1. **SSH into EC2:**
   ```bash
   # Save key file with proper permissions
   chmod 400 nodejs-devops-key.pem
   
   # SSH to instance (replace with your public IP)
   ssh -i nodejs-devops-key.pem ec2-user@EC2-PUBLIC-IP
   ```

2. **Verify CodeDeploy agent is running:**
   ```bash
   sudo systemctl status codedeploy-agent
   
   # Expected output:
   # ● codedeploy-agent.service - CodeDeploy Agent
   #    Loaded: loaded (/etc/systemd/system/codedeploy-agent.service)
   #    Active: active (running)
   ```

3. **Check agent logs:**
   ```bash
   sudo tail -n 20 /var/log/codedeploy-agent/deployment.log
   ```

---

## Part 2: Prepare Deployment Configuration

### Step 1: Add appspec.yml to Your Repository

The appspec.yml file was provided in this task directory. You need to:

1. **Copy appspec.yml to your GitHub repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/aws-nodejs-devops
   cd aws-nodejs-devops
   
   # Copy appspec.yml
   cp appspec.yml /path/to/your/repo/
   
   # Create hooks directory
   mkdir -p hooks
   ```

2. **Create lifecycle hooks** in your `hooks/` directory:

   **hooks/before-install.sh:**
   ```bash
   #!/bin/bash
   set -e
   echo "[$(date)] Starting before-install hook..."
   if systemctl is-active --quiet nodejs-app; then
       systemctl stop nodejs-app || true
   fi
   rm -rf /opt/nodejs-app/*
   echo "[$(date)] Before-install hook completed"
   exit 0
   ```

   **hooks/after-install.sh:**
   ```bash
   #!/bin/bash
   set -e
   echo "[$(date)] Starting after-install hook..."
   cd /opt/nodejs-app
   npm install --production
   chown -R nodejs:nodejs /opt/nodejs-app
   echo "[$(date)] After-install hook completed"
   exit 0
   ```

   **hooks/app-start.sh:**
   ```bash
   #!/bin/bash
   set -e
   echo "[$(date)] Starting application..."
   systemctl start nodejs-app
   sleep 2
   if systemctl is-active --quiet nodejs-app; then
       echo "[$(date)] Application started successfully"
       exit 0
   else
       echo "[$(date)] ERROR: Failed to start"
       exit 1
   fi
   ```

   **hooks/app-stop.sh:**
   ```bash
   #!/bin/bash
   echo "[$(date)] Stopping application..."
   if systemctl is-active --quiet nodejs-app; then
       systemctl stop nodejs-app
   fi
   exit 0
   ```

   **hooks/validate-service.sh:**
   ```bash
   #!/bin/bash
   set -e
   echo "[$(date)] Validating service..."
   sleep 2
   if ! systemctl is-active --quiet nodejs-app; then
       echo "[$(date)] ERROR: Service not running"
       exit 1
   fi
   response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health || echo "000")
   if [ "$response" = "200" ]; then
       echo "[$(date)] Health check passed"
       exit 0
   else
       echo "[$(date)] Health check failed (HTTP $response)"
       exit 1
   fi
   ```

3. **Make scripts executable:**
   ```bash
   chmod +x hooks/*.sh
   ```

4. **Commit and push to GitHub:**
   ```bash
   git add appspec.yml hooks/
   git commit -m "feat: Add CodeDeploy configuration

   - appspec.yml for deployment specification
   - Lifecycle hooks for before-install, after-install, app-start, app-stop, validate-service
   - Supports Node.js app deployment and validation"
   
   git push origin main
   ```

---

## Part 3: Create CodeDeploy Application and Deployment Group

### Step 1: Create CodeDeploy Application

1. **Open AWS Console** → Developer Tools → [CodeDeploy](https://console.aws.amazon.com/codedeploy)

2. **Click "Create application"**
   - Application name: `nodejs-devops-app`
   - Compute platform: **EC2/On-premises**
   - Click **Create application**

### Step 2: Create Deployment Group

1. **Click "Create deployment group"**

2. **Configuration:**
   - Deployment group name: `nodejs-deployment-group`
   - Service role: **Create or select CodeDeploy service role**

   **If creating new role:**
   - Trust entity: CodeDeploy
   - Permissions: `AWSCodeDeployRoleForEC2` (managed policy)

3. **Deployment configuration:**
   - Deployment type: **In-place**
   - Deployment option: **Without traffic control** (for testing)

4. **Environment configuration:**
   - Select instances by: **Tags**
   - Tag key: `Name`
   - Tag value: `nodejs-codedeploy-target` (your EC2 instance name)
   - Click **Add**

5. **Auto Rollback Configuration:**
   - ✅ Check: **Enable automatic rollbacks**
   - Rollback on: Deployment failure

6. **Load balancer:**
   - ✅ Uncheck "Enable load balancing" (not needed for single instance)

7. **Click "Create deployment group"**

---

## Part 4: Test CodeDeploy Deployment

### Step 1: Manual Deployment Test

1. **Create new deployment:**
   - CodeDeploy → Applications → `nodejs-devops-app`
   - Deployment groups → `nodejs-deployment-group`
   - **Click "Create deployment"**

2. **Deployment configuration:**
   - Revision location:
     - Revision type: **Amazon S3**
     - S3 location: `s3://aws-cicd-artifacts-123456789012/builds/app-artifact.zip`
   - Description: "Manual test deployment"
   - Overwrite: ✅ **Enabled**

3. **Click "Create deployment"**

4. **Monitor deployment:**
   - Watch the deployment status
   - Expected flow:
     ```
     Created → InProgress → BeforeInstall → AfterInstall → 
     ApplicationStart → ApplicationStop → ValidateService → Succeeded
     ```

5. **Check logs:**
   - CodeDeploy → Deployments → Select deployment
   - View logs for each lifecycle event

### Step 2: Verify Application is Running

```bash
# SSH into EC2
ssh -i nodejs-devops-key.pem ec2-user@EC2-PUBLIC-IP

# Check if app is running
curl http://localhost:3000/

# Expected response:
# {"message":"Hello from deployed Node.js app!","timestamp":"...","version":"1.0.0"}

# Check systemd service
sudo systemctl status nodejs-app

# View application logs
sudo journalctl -u nodejs-app -n 20
```

---

## Appspec.yml Reference

```yaml
version: 0.0
# Version (always 0.0 for EC2/On-premises)

Resources:
  # Target instances (can be empty for instance tags)

Files:
  - source: /                    # Copy from root of artifact
    destination: /opt/nodejs-app # Copy to this directory

Permissions:
  # Set file permissions

Hooks:
  # Lifecycle events (in order)
  BeforeInstall:      # Phase 1: Cleanup
  AfterInstall:       # Phase 2: Setup
  ApplicationStart:    # Phase 3: Start app
  ApplicationStop:     # Phase 4: Stop (during next deployment)
  ValidateService:     # Phase 5: Health check
```

---

## Troubleshooting

### Issue: "CodeDeploy agent does not exist"

**Cause:** Instance doesn't have CodeDeploy agent installed  
**Solution:**
1. SSH into EC2
2. Install manually:
   ```bash
   sudo yum install ruby wget
   cd /home/ec2-user
   wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   sudo systemctl start codedeploy-agent
   ```

### Issue: "Deployment failed - AppSpec validation failed"

**Cause:** appspec.yml has YAML syntax errors  
**Solution:**
1. Validate YAML: [yamllint.com](https://yamllint.com)
2. Check hook script paths: `hooks/before-install.sh` (not `/hooks/...`)
3. Ensure hooks are executable: `chmod +x hooks/*.sh`

### Issue: "Health check failed"

**Cause:** Application not responding to `/health` endpoint  
**Solution:**
1. Verify app is running: `curl http://localhost:3000/health`
2. Check port 3000 is listening: `netstat -tuln | grep 3000`
3. Check app logs: `journalctl -u nodejs-app`

### Issue: "Access Denied" pulling from S3

**Cause:** EC2 IAM role doesn't have S3 permissions  
**Solution:**
1. Check role: EC2-CodeDeploy-Role
2. Verify inline policy allows S3 GetObject
3. Reattach role to instance if needed

---

## Validation Checklist ✅

Before moving to Task 5:

- [ ] EC2-CodeDeploy-Role created with correct permissions
- [ ] EC2 instance `nodejs-codedeploy-target` launched and running
- [ ] EC2 instance has public IP assigned
- [ ] Security group allows SSH (port 22), HTTP (port 80), and TCP 3000
- [ ] CodeDeploy agent installed on EC2 (verified with systemctl status)
- [ ] appspec.yml added to GitHub repository
- [ ] Lifecycle hooks created in `hooks/` directory
- [ ] All hook scripts made executable (chmod +x)
- [ ] CodeDeploy application `nodejs-devops-app` created
- [ ] Deployment group `nodejs-deployment-group` created with tag matching
- [ ] Manual deployment test completed successfully
- [ ] Application responds to health endpoint on EC2
- [ ] Deployment logs show all lifecycle events succeeded

**Save these details:**
```
EC2 Instance ID: i-1234567890abcdef0
EC2 Public IP: 54.123.45.67
EC2 Role: EC2-CodeDeploy-Role
CodeDeploy App: nodejs-devops-app
Deployment Group: nodejs-deployment-group
Application URL: http://54.123.45.67:3000
Health Endpoint: http://54.123.45.67:3000/health
```

---

## 🎯 What's Next?

Proceed to [Task 5: Create CodePipeline](../task-5/PIPELINE-CREATION.md) →

In Task 5, we'll complete the CI/CD pipeline by:
1. Connecting CodePipeline to GitHub
2. Adding CodeBuild stage
3. Adding CodeDeploy stage
4. Triggering end-to-end pipeline
