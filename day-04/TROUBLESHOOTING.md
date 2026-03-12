# 🔧 Day 4 Troubleshooting Guide

## RDS Issues

### ❌ Cannot Connect to RDS Instance

**Symptoms:** Connection timeout or refused

**Solutions:**
1. Check security group inbound rules allow port 3306 from your IP/EC2 SG
2. Verify RDS is publicly accessible (if connecting from outside VPC)
3. Ensure VPC and subnet configuration is correct
4. Check network ACLs
5. Verify endpoint address is correct

```bash
# Test connection
telnet your-rds-endpoint.rds.amazonaws.com 3306

# Check security group
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

### ❌ Authentication Failed

**Solutions:**
1. Verify username and password
2. Check if user has proper permissions
3. Ensure database exists

```sql
-- Grant permissions
GRANT ALL PRIVILEGES ON database.* TO 'user'@'%';
FLUSH PRIVILEGES;
```

### ❌ RDS Instance Creation Failed

**Solutions:**
1. Check if you have sufficient permissions
2. Verify subnet group has subnets in multiple AZs
3. Ensure parameter group is compatible with engine version
4. Check service quotas

---

## Lambda Issues

### ❌ Lambda Function Timeout

**Symptoms:** Task timed out after X seconds

**Solutions:**
1. Increase timeout (max 15 minutes)
2. Optimize code performance
3. Check if external API calls are slow
4. Review CloudWatch logs for bottlenecks

```bash
# Update timeout
aws lambda update-function-configuration --function-name myFunction --timeout 300
```

### ❌ Permission Denied

**Symptoms:** AccessDeniedException

**Solutions:**
1. Check IAM role has necessary permissions
2. Verify trust relationship allows Lambda service
3. Add required policies

```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:DescribeInstances",
    "ec2:StartInstances",
    "ec2:StopInstances"
  ],
  "Resource": "*"
}
```

### ❌ Lambda Not Triggered by EventBridge

**Solutions:**
1. Verify EventBridge rule is enabled
2. Check Lambda has permission for EventBridge to invoke
3. Verify cron expression is correct (use UTC)
4. Check CloudWatch logs for errors

```bash
# Add permission
aws lambda add-permission --function-name myFunction --statement-id EventBridgeInvoke --action lambda:InvokeFunction --principal events.amazonaws.com --source-arn arn:aws:events:region:account:rule/myRule
```

### ❌ Module Import Error

**Symptoms:** Unable to import module 'lambda_function'

**Solutions:**
1. Ensure handler is correctly specified (filename.function_name)
2. Check file is at root of ZIP
3. Verify all dependencies are included
4. Use Lambda layers for large dependencies

---

## EC2 Auto Scaling Issues

### ❌ Instances Not Launching

**Solutions:**
1. Check launch template/configuration is valid
2. Verify AMI exists and is accessible
3. Ensure sufficient EC2 capacity in region
4. Check service quotas
5. Review IAM role permissions

```bash
# Describe Auto Scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name myASG --max-records 10
```

### ❌ Health Checks Failing

**Solutions:**
1. Verify application is running on correct port
2. Check security group allows health check traffic
3. Ensure health check path exists (/health)
4. Increase health check grace period

```bash
# Update health check grace period
aws autoscaling update-auto-scaling-group --auto-scaling-group-name myASG --health-check-grace-period 300
```

### ❌ Scaling Policies Not Working

**Solutions:**
1. Check CloudWatch alarms are in ALARM state
2. Verify metrics are being published
3. Ensure cooldown period has passed
4. Review scaling policy configuration

---

## Load Balancer Issues

### ❌ Targets Unhealthy

**Solutions:**
1. Check application is running
2. Verify security group allows traffic from ALB
3. Ensure health check path returns 200
4. Review health check settings (interval, timeout, threshold)

```bash
# Describe target health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...
```

### ❌ 502 Bad Gateway

**Solutions:**
1. Check backend instances are healthy
2. Verify application is listening on correct port
3. Review application logs for errors
4. Ensure security groups allow ALB → instance traffic

---

## Flask Application Issues

### ❌ Application Not Starting

**Solutions:**
1. Check Python version compatibility
2. Verify all dependencies are installed
3. Review application logs
4. Ensure environment variables are set

```bash
# Check logs
tail -f /var/log/flask-app.log

# Test locally
python3 app.py
```

### ❌ Database Connection Error

**Solutions:**
1. Verify RDS endpoint is correct
2. Check environment variables
3. Ensure security group allows connection
4. Test connection with mysql client

```bash
# Test MySQL connection
mysql -h endpoint.rds.amazonaws.com -u admin -p
```

---

## DynamoDB Issues

### ❌ ProvisionedThroughputExceededException

**Solutions:**
1. Switch to on-demand billing mode
2. Increase provisioned capacity
3. Implement exponential backoff
4. Use batch operations

### ❌ ValidationException

**Solutions:**
1. Verify attribute types match schema
2. Check key schema is correct
3. Ensure required attributes are provided

---

## General Debugging Tips

### Enable Detailed Logging

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Check CloudWatch Logs

```bash
# Lambda logs
aws logs tail /aws/lambda/myFunction --follow

# RDS logs
aws rds describe-db-log-files --db-instance-identifier mydb
```

### Test IAM Permissions

```bash
# Simulate policy
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::account:role/myRole --action-names ec2:StartInstances
```

### Monitor with CloudWatch

```bash
# Get metrics
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=i-xxxxx --start-time 2024-01-01T00:00:00Z --end-time 2024-01-01T23:59:59Z --period 3600 --statistics Average
```

---

## Getting Help

1. Check AWS Service Health Dashboard
2. Review AWS documentation
3. Search AWS re:Post
4. Join Discord community
5. Contact AWS Support (if you have a support plan)

---

## Useful Commands for Debugging

```bash
# Check AWS CLI configuration
aws configure list

# Verify credentials
aws sts get-caller-identity

# List all resources
aws resourcegroupstaggingapi get-resources

# Check service quotas
aws service-quotas list-service-quotas --service-code ec2
```
