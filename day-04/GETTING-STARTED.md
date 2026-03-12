# 🚀 Getting Started with Day 4

Welcome to Day 4 of the 7 Days of AWS Challenge! This guide will help you navigate through today's tasks.

---

## 📂 What's Inside

```
day-04/
├── README.md                    # Overview of Day 4
├── CHEATSHEET.md               # Quick reference commands
├── RESOURCES.md                # Learning resources
├── TROUBLESHOOTING.md          # Common issues & solutions
│
├── task-1/                     # Learn & Share
│   └── linkedin-post.md        # LinkedIn post template
│
├── task-2/                     # Database Migration to RDS
│   ├── rds-setup.md           # Step-by-step RDS setup
│   └── test-connection.py     # Python script to test RDS
│
├── task-3/                     # Scalable Web Application
│   ├── deployment-guide.md    # Deployment instructions
│   └── flask-app/
│       ├── app.py             # Flask application
│       ├── requirements.txt   # Python dependencies
│       └── user-data.sh       # EC2 bootstrap script
│
└── task-4/                     # EC2 Start/Stop Automation
    ├── lambda-start-stop.py   # Lambda function code
    └── eventbridge-setup.md   # EventBridge configuration
```

---

## 🎯 How to Approach Day 4

### 1️⃣ Start with Learning (Task 1)
- Read about RDS, DynamoDB, and Lambda
- Understand the core concepts
- Prepare your LinkedIn post
- Share your learning journey

### 2️⃣ Hands-On with RDS (Task 2)
- Set up your first RDS MySQL instance
- Configure security and networking
- Test database connectivity
- Perform CRUD operations

**Time estimate:** 30-45 minutes

### 3️⃣ Build Scalable App (Task 3)
- Deploy Flask application
- Connect to RDS backend
- Set up Auto Scaling and Load Balancer
- Test scalability

**Time estimate:** 1-2 hours

### 4️⃣ Automate with Lambda (Task 4)
- Create Lambda function
- Configure EventBridge schedules
- Tag EC2 instances
- Test automation

**Time estimate:** 30-45 minutes

---

## 🛠️ Prerequisites

### Required Tools
- AWS Account (Free Tier eligible)
- AWS CLI installed and configured
- Python 3.x installed
- Basic understanding of databases
- Text editor or IDE

### AWS Services Used
- Amazon RDS (MySQL)
- AWS Lambda
- Amazon EC2
- Auto Scaling Groups
- Elastic Load Balancer
- Amazon EventBridge
- Amazon DynamoDB (learning only)

### Estimated Costs
- RDS db.t3.micro: Free Tier eligible (750 hours/month)
- Lambda: Free Tier (1M requests/month)
- EC2 t2.micro: Free Tier eligible (750 hours/month)
- Data transfer: Minimal for testing

**Total estimated cost for Day 4: $0-5** (if staying within Free Tier)

---

## 📝 Before You Start

### 1. Set Up AWS CLI
```bash
aws configure
# Enter your Access Key ID
# Enter your Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### 2. Verify Configuration
```bash
aws sts get-caller-identity
```

### 3. Choose Your Region
Stick to one region throughout Day 4 (recommended: us-east-1)

### 4. Create a Working Directory
```bash
mkdir day-04-workspace
cd day-04-workspace
```

---

## 🎓 Learning Path

### Beginner Track
1. Complete Task 1 (Learn & Share)
2. Complete Task 2 (RDS setup and testing)
3. Try Task 4 (Lambda automation)
4. Skip Task 3 or follow along without implementing

### Intermediate Track
1. Complete all tasks in order
2. Customize the Flask application
3. Add monitoring and alerts
4. Implement additional Lambda functions

### Advanced Track
1. Complete all tasks
2. Add CI/CD pipeline
3. Implement multi-region deployment
4. Add advanced monitoring and logging
5. Optimize for cost and performance

---

## ✅ Success Criteria

By the end of Day 4, you should be able to:
- [ ] Explain RDS, DynamoDB, and Lambda
- [ ] Create and configure an RDS instance
- [ ] Connect applications to RDS
- [ ] Deploy a scalable web application
- [ ] Create Lambda functions
- [ ] Schedule automated tasks with EventBridge
- [ ] Understand cost optimization strategies

---

## 🎯 Quick Start Commands

### Test RDS Connection
```bash
cd task-2
python test-connection.py
```

### Deploy Flask App
```bash
cd task-3/flask-app
pip install -r requirements.txt
python app.py
```

### Test Lambda Function
```bash
cd task-4
zip function.zip lambda-start-stop.py
aws lambda create-function --function-name EC2Scheduler --runtime python3.11 --role <ROLE_ARN> --handler lambda-start-stop.lambda_handler --zip-file fileb://function.zip
```

---

## 💡 Pro Tips

1. **Use Tags Consistently:** Tag all resources with `Project=Day4` for easy cleanup
2. **Monitor Costs:** Check AWS Cost Explorer daily
3. **Save Endpoints:** Keep RDS endpoints and ARNs in a notes file
4. **Test Incrementally:** Don't wait until the end to test
5. **Clean Up:** Delete resources after completing tasks to avoid charges

---

## 🧹 Cleanup Checklist

After completing Day 4:
```bash
# Delete Lambda function
aws lambda delete-function --function-name EC2Scheduler

# Delete EventBridge rules
aws events delete-rule --name StartEC2Instances
aws events delete-rule --name StopEC2Instances

# Delete Auto Scaling Group
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name flask-app-asg --force-delete

# Delete Load Balancer
aws elbv2 delete-load-balancer --load-balancer-arn <ARN>

# Delete RDS instance
aws rds delete-db-instance --db-instance-identifier ecommerce-db --skip-final-snapshot

# Terminate EC2 instances
aws ec2 terminate-instances --instance-ids i-xxxxx
```

---

## 🆘 Need Help?

1. Check `TROUBLESHOOTING.md` for common issues
2. Review `CHEATSHEET.md` for quick commands
3. Consult `RESOURCES.md` for documentation links
4. Ask in Discord community
5. Post on LinkedIn with #7DaysOfAWS

---

## 🎉 Share Your Progress

Don't forget to:
- Post on LinkedIn with #7DaysOfAWS #AWSwithTWS
- Tag @TrainWithShubham
- Share screenshots of your deployments
- Engage with other learners
- Ask questions in the community

---

## 📅 What's Next?

After completing Day 4, you'll be ready for:
- Day 5: Monitoring, Logging & Security
- Advanced serverless architectures
- Event-driven applications
- Microservices on AWS

---

**Good luck with Day 4! 🚀**

Remember: The goal is to learn, not to be perfect. Take your time, experiment, and don't be afraid to make mistakes!
