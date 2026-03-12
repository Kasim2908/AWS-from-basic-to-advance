# 📚 Day 4 Resources & References

## Official AWS Documentation

### Amazon RDS
- [RDS User Guide](https://docs.aws.amazon.com/rds/)
- [RDS MySQL Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html)
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [RDS Security](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.html)

### DynamoDB
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/dynamodb/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Python SDK](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)

### AWS Lambda
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [Lambda Python Runtime](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/)

### EventBridge
- [EventBridge User Guide](https://docs.aws.amazon.com/eventbridge/)
- [Schedule Expressions](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html)

### Boto3
- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [EC2 Client](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html)
- [RDS Client](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds.html)

---

## Tutorials & Guides

### RDS
- [Getting Started with RDS](https://aws.amazon.com/rds/getting-started/)
- [Migrating to RDS](https://aws.amazon.com/dms/)
- [RDS Performance Insights](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.html)

### Lambda
- [Lambda Getting Started](https://aws.amazon.com/lambda/getting-started/)
- [Building Lambda Functions](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html)
- [Lambda with EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-run-lambda-schedule.html)

### Auto Scaling
- [Auto Scaling Groups](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html)
- [Target Tracking Policies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html)

---

## Code Examples

### Python Libraries
```bash
pip install boto3 pymysql Flask
```

### AWS CLI Installation
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

## Community Resources

- [AWS re:Post](https://repost.aws/)
- [AWS Workshops](https://workshops.aws/)
- [AWS Samples GitHub](https://github.com/aws-samples)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)

---

## Cost Optimization

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

## Certification Prep

- [AWS Certified Solutions Architect](https://aws.amazon.com/certification/certified-solutions-architect-associate/)
- [AWS Certified Developer](https://aws.amazon.com/certification/certified-developer-associate/)

---

## Troubleshooting

### Common Issues

**RDS Connection Timeout:**
- Check security group rules
- Verify VPC and subnet configuration
- Ensure public accessibility if connecting from outside VPC

**Lambda Timeout:**
- Increase timeout setting (max 15 minutes)
- Optimize code performance
- Check CloudWatch logs

**Auto Scaling Not Working:**
- Verify health check configuration
- Check scaling policies and CloudWatch alarms
- Review IAM permissions

---

## Next Steps

After completing Day 4:
1. Explore Aurora Serverless
2. Learn about DynamoDB Streams
3. Build event-driven architectures
4. Implement CI/CD with Lambda
5. Study AWS Step Functions for orchestration
