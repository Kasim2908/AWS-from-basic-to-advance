# 🗄️ Day 4 – Databases, Lambda & Automation

## 🧠 Core Concepts

### 💾 Amazon RDS
Managed relational database service supporting MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server. AWS handles backups, patching, and monitoring.

### ⚡ DynamoDB
Fully managed NoSQL database with millisecond performance at any scale. Ideal for high-availability applications with flexible schemas.

### 🌀 AWS Lambda
Serverless compute service that runs code in response to triggers (S3 events, CloudWatch schedules, API calls) without managing servers.

---

## 📋 Tasks Overview

### Task 1: Learn & Share
- Study RDS, DynamoDB, and Lambda
- Create LinkedIn post with examples
- Use hashtags: #7DaysOfAWS #AWswithTWS

### Task 2: Database Migration to RDS
- Set up MySQL RDS instance
- Configure security and networking
- Test CRUD operations

### Task 3: Deploy Scalable Web Application
- Build two-tier Flask app
- Use RDS for MySQL backend
- Deploy on EC2 with Auto Scaling and Load Balancer

### Task 4: Automate EC2 Start/Stop
- Create Lambda function for cost optimization
- Use Boto3 and EventBridge
- Schedule based on business hours

---

## 📁 Directory Structure

```
day-04/
├── README.md
├── task-1/
│   └── linkedin-post.md
├── task-2/
│   ├── rds-setup.md
│   └── test-connection.py
├── task-3/
│   ├── flask-app/
│   └── deployment-guide.md
└── task-4/
    ├── lambda-start-stop.py
    └── eventbridge-setup.md
```

---

## 🚀 Getting Started

Navigate to each task folder for detailed instructions and code samples.

## 📚 Resources
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
