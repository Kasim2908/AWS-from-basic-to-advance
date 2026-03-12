# Task 3: Deploy Scalable Web Application

## 🏗️ Architecture Overview

```
Internet → ELB → Auto Scaling Group (EC2 Instances) → RDS MySQL
```

---

## 📋 Deployment Steps

### Step 1: Set Up RDS MySQL Database

Follow Task 2 instructions to create RDS instance.

### Step 2: Launch EC2 Instance (Template)

```bash
# Create EC2 instance with user data
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro \
  --key-name your-key \
  --security-group-ids sg-xxxxxxxxx \
  --user-data file://user-data.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=flask-app}]'
```

### Step 3: Create Launch Template

```bash
aws ec2 create-launch-template \
  --launch-template-name flask-app-template \
  --version-description "Flask app v1" \
  --launch-template-data '{
    "ImageId": "ami-0c55b159cbfafe1f0",
    "InstanceType": "t2.micro",
    "KeyName": "your-key",
    "SecurityGroupIds": ["sg-xxxxxxxxx"],
    "UserData": "IyEvYmluL2Jhc2g..."
  }'
```

### Step 4: Create Target Group

```bash
aws elbv2 create-target-group \
  --name flask-app-tg \
  --protocol HTTP \
  --port 5000 \
  --vpc-id vpc-xxxxxxxxx \
  --health-check-path /health \
  --health-check-interval-seconds 30
```

### Step 5: Create Application Load Balancer

```bash
aws elbv2 create-load-balancer \
  --name flask-app-alb \
  --subnets subnet-xxxxxx subnet-yyyyyy \
  --security-groups sg-xxxxxxxxx \
  --scheme internet-facing \
  --type application
```

### Step 6: Create Listener

```bash
aws elbv2 create-listener \
  --load-balancer-arn <ALB_ARN> \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=<TG_ARN>
```

### Step 7: Create Auto Scaling Group

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name flask-app-asg \
  --launch-template LaunchTemplateName=flask-app-template \
  --min-size 2 \
  --max-size 5 \
  --desired-capacity 2 \
  --target-group-arns <TG_ARN> \
  --vpc-zone-identifier "subnet-xxxxxx,subnet-yyyyyy" \
  --health-check-type ELB \
  --health-check-grace-period 300
```

### Step 8: Configure Scaling Policies

```bash
# Scale up policy
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name flask-app-asg \
  --policy-name scale-up \
  --scaling-adjustment 1 \
  --adjustment-type ChangeInCapacity \
  --cooldown 300

# Scale down policy
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name flask-app-asg \
  --policy-name scale-down \
  --scaling-adjustment -1 \
  --adjustment-type ChangeInCapacity \
  --cooldown 300
```

---

## 📁 Application Files

See `flask-app/` directory for:
- `app.py` - Flask application
- `requirements.txt` - Python dependencies
- `user-data.sh` - EC2 bootstrap script

---

## 🧪 Testing

1. Get ALB DNS name:
```bash
aws elbv2 describe-load-balancers \
  --names flask-app-alb \
  --query 'LoadBalancers[0].DNSName' \
  --output text
```

2. Test the application:
```bash
curl http://<ALB_DNS_NAME>/
```

---

## 📊 Monitoring

- CloudWatch metrics for EC2, ALB, and RDS
- ALB access logs
- RDS Enhanced Monitoring
- Auto Scaling activity logs

---

## 💰 Cost Considerations

- Use t3.micro for testing (Free Tier eligible)
- Set appropriate min/max for Auto Scaling
- Use Spot Instances for non-critical workloads
- Monitor with AWS Cost Explorer
