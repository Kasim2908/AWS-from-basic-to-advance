# Task 1: Deploy Two-Tier Flask App with ECS & ECR

## Architecture
```
User → ALB → ECS Fargate (Flask) → RDS MySQL
```

---

## Step 1: Create ECR Repository

```bash
aws ecr create-repository --repository-name flask-two-tier --region <REGION>
```

---

## Step 2: Build & Push Docker Image to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region <REGION> | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com

# Build image
docker build -t flask-two-tier ./flask-app

# Tag image
docker tag flask-two-tier:latest \
  <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/flask-two-tier:latest

# Push image
docker push <ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/flask-two-tier:latest
```

---

## Step 3: Create ECS Cluster

```bash
aws ecs create-cluster --cluster-name flask-cluster
```

---

## Step 4: Register Task Definition

1. Update `ecs-task-definition.json` — replace all `<PLACEHOLDERS>` with real values.
2. Register it:

```bash
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json
```

---

## Step 5: Create ECS Service

```bash
aws ecs create-service \
  --cluster flask-cluster \
  --service-name flask-service \
  --task-definition flask-two-tier \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[<SUBNET_ID_1>,<SUBNET_ID_2>],
    securityGroups=[<SG_ID>],
    assignPublicIp=ENABLED
  }"
```

---

## Step 6: Verify Deployment

```bash
# List running tasks
aws ecs list-tasks --cluster flask-cluster --service-name flask-service

# Describe service
aws ecs describe-services --cluster flask-cluster --services flask-service
```

---

## Prerequisites Checklist
- [ ] Docker installed locally
- [ ] AWS CLI configured (`aws configure`)
- [ ] IAM role `ecsTaskExecutionRole` exists with `AmazonECSTaskExecutionRolePolicy`
- [ ] RDS instance running (from Day 4)
- [ ] VPC, subnets, and security groups configured
- [ ] CloudWatch log group `/ecs/flask-two-tier` created
