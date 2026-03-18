# AWS from Basic to Advance Level

Hands-on AWS learning repository that walks through foundational to intermediate cloud concepts across a 7-day challenge format.

## Overview

This repository is organized day-by-day to help you learn by doing. Each day focuses on specific AWS services and includes practical notes, setup steps, scripts, or mini projects.

Topics include:

- Cloud fundamentals and AWS pricing models
- IAM, S3, and AWS CLI
- AWS WAF and web application security
- RDS, DynamoDB, Lambda, and automation
- VPC networking, Transit Gateway, and CloudWatch
- ECS, ECR, Route 53, and CloudFront

## Learning Path

| Day | Focus Area | What You Will Practice |
| --- | --- | --- |
| Day 1 | Cloud + AWS Basics | Cloud models, AWS service models, pricing concepts |
| Day 2 | AWS WAF | Protecting web apps with managed and custom WAF rules |
| Day 3 | IAM, S3, AWS CLI | Bucket security, least-privilege IAM, CLI workflows |
| Day 4 | Databases + Serverless | RDS setup, DynamoDB concepts, Lambda automation |
| Day 5 | Networking + Monitoring | VPC design, Transit Gateway, CloudWatch monitoring |
| Day 6 | Containers + Edge + DNS | ECS Fargate deployment, CloudFront caching, Route 53 |

## Repository Structure

```text
AWS-from-basic-to-advance/
├── README.md
├── day-01/
│   └── Introduction to Cloud & AWS Basics.md
├── day-02/
│   └── AWS WAF
├── day-03/
│   └── AWS
├── day-04/
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── CHEATSHEET.md
│   ├── DYNAMODB-EXAMPLES.md
│   ├── GETTING-STARTED.md
│   ├── INDEX.md
│   ├── RESOURCES.md
│   ├── SUMMARY.md
│   ├── TROUBLESHOOTING.md
│   ├── task-1/
│   │   └── linkedin-post.md
│   ├── task-2/
│   │   ├── rds-setup.md
│   │   └── test-connection.py
│   ├── task-3/
│   │   ├── deployment-guide.md
│   │   └── flask-app/
│   │       ├── app.py
│   │       ├── requirements.txt
│   │       └── user-data.sh
│   └── task-4/
│       ├── eventbridge-setup.md
│       └── lambda-start-stop.py
├── 🌐 Day 5 – AWS VPC, Transit Gateway & CloudWatch
└── day-06/
	├── README.md
	├── task-1/
	│   ├── deployment-guide.md
	│   ├── ecs-task-definition.json
	│   └── flask-app/
	│       ├── app.py
	│       ├── Dockerfile
	│       └── requirements.txt
	├── task-2/
	│   ├── cloudfront-setup.md
	│   └── ec2-user-data.sh
	└── task-3/
		└── linkedin-post.md
```

## Day-wise Quick Links

- Day 1 notes: [day-01/Introduction to Cloud & AWS Basics.md](day-01/Introduction%20to%20Cloud%20%26%20AWS%20Basics.md)
- Day 2 notes: [day-02/AWS WAF](day-02/AWS%20WAF)
- Day 3 notes: [day-03/AWS](day-03/AWS)
- Day 4 guide index: [day-04/README.md](day-04/README.md)
- Day 5 networking lab: [🌐 Day 5 – AWS VPC, Transit Gateway & CloudWatch](%F0%9F%8C%90%20Day%205%20%E2%80%93%20AWS%20VPC%2C%20Transit%20Gateway%20%26%20CloudWatch)
- Day 6 container + CDN + DNS: [day-06/README.md](day-06/README.md)

## Prerequisites

Before running the practical tasks, make sure you have:

- An active AWS account
- AWS CLI installed and configured (`aws configure`)
- Basic Linux command-line familiarity
- Docker installed (for Day 6 ECS/ECR task)
- Python 3 installed (for Day 4 scripts)

## How to Use This Repository

1. Start from Day 1 and move forward sequentially.
2. Read each day document to understand the concept first.
3. Follow task files and deployment guides to implement hands-on labs.
4. Validate each setup using AWS Console/CLI outputs.
5. Keep your own notes and architecture diagrams for revision.

## Key Hands-on Projects

- Secure and test a web workload with AWS WAF.
- Configure private S3 access and IAM least-privilege policies.
- Build and connect a Flask app with Amazon RDS.
- Automate EC2 schedules using Lambda + EventBridge.
- Deploy a containerized Flask app on ECS Fargate via ECR.
- Set up CloudFront distribution with an EC2 origin.

## Safety and Cost Notes

- Use AWS Free Tier resources when possible.
- Stop or delete unused EC2, RDS, and ECS services to avoid charges.
- Do not commit secrets such as access keys, database passwords, or `.pem` files.

## Suggested Next Improvements

- Add Terraform or CloudFormation templates for repeatable provisioning.
- Add architecture diagrams for each day in a dedicated `diagrams/` folder.
- Add screenshots for important console steps.
- Add a small CI check (lint/tests) for Python and Docker assets.

## Acknowledgment

Built as part of a 7 Days of AWS challenge-style learning journey focused on practical cloud engineering skills.
Happy Learning...!!!!
