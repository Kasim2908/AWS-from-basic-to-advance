# Task 4: Automate EC2 Start/Stop Using Lambda

## 🎯 Objective
Automatically start/stop EC2 instances during business hours to save costs.

---

## 📋 Setup Steps

### Step 1: Create IAM Role for Lambda

```bash
# Create trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

# Create role
aws iam create-role \
  --role-name LambdaEC2StartStop \
  --assume-role-policy-document file://trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name LambdaEC2StartStop \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Create custom policy for EC2 actions
cat > ec2-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeInstances",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ],
    "Resource": "*"
  }]
}
EOF

aws iam put-role-policy \
  --role-name LambdaEC2StartStop \
  --policy-name EC2StartStopPolicy \
  --policy-document file://ec2-policy.json
```

### Step 2: Create Lambda Function

```bash
# Zip the function
zip lambda-function.zip lambda-start-stop.py

# Create Lambda function
aws lambda create-function \
  --function-name EC2StartStopScheduler \
  --runtime python3.11 \
  --role arn:aws:iam::ACCOUNT_ID:role/LambdaEC2StartStop \
  --handler lambda-start-stop.lambda_handler \
  --zip-file fileb://lambda-function.zip \
  --timeout 60 \
  --environment Variables={AWS_REGION=us-east-1}
```

### Step 3: Tag EC2 Instances

Tag instances you want to auto-start/stop:

```bash
aws ec2 create-tags \
  --resources i-xxxxxxxxx \
  --tags Key=AutoStartStop,Value=true
```

### Step 4: Create EventBridge Rules

#### Stop instances at 6 PM (weekdays)
```bash
aws events put-rule \
  --name StopEC2Instances \
  --schedule-expression "cron(0 18 ? * MON-FRI *)" \
  --description "Stop EC2 instances at 6 PM weekdays"

aws events put-targets \
  --rule StopEC2Instances \
  --targets "Id"="1","Arn"="arn:aws:lambda:REGION:ACCOUNT_ID:function:EC2StartStopScheduler","Input"='{"action":"stop","tag_key":"AutoStartStop","tag_value":"true"}'

# Add Lambda permission
aws lambda add-permission \
  --function-name EC2StartStopScheduler \
  --statement-id StopEC2Rule \
  --action lambda:InvokeFunction \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:REGION:ACCOUNT_ID:rule/StopEC2Instances
```

#### Start instances at 8 AM (weekdays)
```bash
aws events put-rule \
  --name StartEC2Instances \
  --schedule-expression "cron(0 8 ? * MON-FRI *)" \
  --description "Start EC2 instances at 8 AM weekdays"

aws events put-targets \
  --rule StartEC2Instances \
  --targets "Id"="1","Arn"="arn:aws:lambda:REGION:ACCOUNT_ID:function:EC2StartStopScheduler","Input"='{"action":"start","tag_key":"AutoStartStop","tag_value":"true"}'

aws lambda add-permission \
  --function-name EC2StartStopScheduler \
  --statement-id StartEC2Rule \
  --action lambda:InvokeFunction \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:REGION:ACCOUNT_ID:rule/StartEC2Instances
```

---

## 🧪 Testing

Test the Lambda function manually:

```bash
# Test stop action
aws lambda invoke \
  --function-name EC2StartStopScheduler \
  --payload '{"action":"stop","tag_key":"AutoStartStop","tag_value":"true"}' \
  response.json

# Test start action
aws lambda invoke \
  --function-name EC2StartStopScheduler \
  --payload '{"action":"start","tag_key":"AutoStartStop","tag_value":"true"}' \
  response.json
```

---

## 📊 Monitoring

View Lambda logs:
```bash
aws logs tail /aws/lambda/EC2StartStopScheduler --follow
```

Check EventBridge rule status:
```bash
aws events describe-rule --name StopEC2Instances
aws events describe-rule --name StartEC2Instances
```

---

## 💰 Cost Savings

Example calculation:
- Instance: t3.medium ($0.0416/hour)
- Running 24/7: $30/month
- Running 8 AM - 6 PM (10 hours/day, 5 days/week): ~$9/month
- **Savings: ~70%**

---

## 🔧 Customization

### Different schedules per environment:
- Tag: `Environment=dev` → Stop at 6 PM
- Tag: `Environment=prod` → Always running

### Weekend shutdown:
```bash
# Stop Friday 6 PM
cron(0 18 ? * FRI *)

# Start Monday 8 AM
cron(0 8 ? * MON *)
```

---

## 📚 Cron Expression Reference

Format: `cron(Minutes Hours Day-of-month Month Day-of-week Year)`

Examples:
- `cron(0 8 ? * MON-FRI *)` - 8 AM weekdays
- `cron(0 18 ? * MON-FRI *)` - 6 PM weekdays
- `cron(0 0 ? * * *)` - Midnight every day
- `cron(0 */2 ? * * *)` - Every 2 hours

Note: Times are in UTC!
