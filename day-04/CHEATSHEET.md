# 🚀 Day 4 Quick Reference Cheat Sheet

## RDS Commands

```bash
# Create RDS instance
aws rds create-db-instance --db-instance-identifier mydb --db-instance-class db.t3.micro --engine mysql --master-username admin --master-user-password <pass> --allocated-storage 20

# Describe instances
aws rds describe-db-instances --db-instance-identifier mydb

# Get endpoint
aws rds describe-db-instances --db-instance-identifier mydb --query 'DBInstances[0].Endpoint.Address' --output text

# Create snapshot
aws rds create-db-snapshot --db-instance-identifier mydb --db-snapshot-identifier mydb-snapshot

# Delete instance
aws rds delete-db-instance --db-instance-identifier mydb --skip-final-snapshot
```

## DynamoDB Commands

```bash
# Create table
aws dynamodb create-table --table-name Users --attribute-definitions AttributeName=userId,AttributeType=S --key-schema AttributeName=userId,KeyType=HASH --billing-mode PAY_PER_REQUEST

# Put item
aws dynamodb put-item --table-name Users --item '{"userId":{"S":"123"},"name":{"S":"John"}}'

# Get item
aws dynamodb get-item --table-name Users --key '{"userId":{"S":"123"}}'

# Scan table
aws dynamodb scan --table-name Users

# Delete table
aws dynamodb delete-table --table-name Users
```

## Lambda Commands

```bash
# Create function
aws lambda create-function --function-name myFunction --runtime python3.11 --role arn:aws:iam::ACCOUNT:role/lambda-role --handler lambda_function.lambda_handler --zip-file fileb://function.zip

# Invoke function
aws lambda invoke --function-name myFunction --payload '{"key":"value"}' response.json

# Update code
aws lambda update-function-code --function-name myFunction --zip-file fileb://function.zip

# View logs
aws logs tail /aws/lambda/myFunction --follow

# Delete function
aws lambda delete-function --function-name myFunction
```

## EventBridge Commands

```bash
# Create rule (cron)
aws events put-rule --name myRule --schedule-expression "cron(0 8 * * ? *)"

# Add target
aws events put-targets --rule myRule --targets "Id"="1","Arn"="arn:aws:lambda:region:account:function:myFunction"

# List rules
aws events list-rules

# Disable rule
aws events disable-rule --name myRule

# Delete rule
aws events delete-rule --name myRule
```

## EC2 Commands

```bash
# Start instances
aws ec2 start-instances --instance-ids i-xxxxx

# Stop instances
aws ec2 stop-instances --instance-ids i-xxxxx

# Describe instances with tags
aws ec2 describe-instances --filters "Name=tag:Name,Values=myInstance"

# Create tags
aws ec2 create-tags --resources i-xxxxx --tags Key=AutoStartStop,Value=true
```

## Python Boto3 Snippets

### RDS Connection
```python
import pymysql
conn = pymysql.connect(host='endpoint', user='admin', password='pass', database='db')
cursor = conn.cursor()
cursor.execute("SELECT * FROM table")
results = cursor.fetchall()
conn.close()
```

### DynamoDB
```python
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')
table.put_item(Item={'userId': '123', 'name': 'John'})
response = table.get_item(Key={'userId': '123'})
```

### Lambda EC2 Control
```python
import boto3
ec2 = boto3.client('ec2')
ec2.stop_instances(InstanceIds=['i-xxxxx'])
ec2.start_instances(InstanceIds=['i-xxxxx'])
```

## Cron Expressions (UTC)

```
cron(Minutes Hours Day Month DayOfWeek Year)

0 8 * * ? *        # 8 AM daily
0 18 ? * MON-FRI * # 6 PM weekdays
0 0 ? * SUN *      # Midnight Sunday
0 */2 * * ? *      # Every 2 hours
```

## Security Group Rules

```bash
# Allow MySQL from EC2 SG
aws ec2 authorize-security-group-ingress --group-id sg-rds --protocol tcp --port 3306 --source-group sg-ec2

# Allow HTTP from anywhere
aws ec2 authorize-security-group-ingress --group-id sg-web --protocol tcp --port 80 --cidr 0.0.0.0/0
```

## Environment Variables

```bash
export RDS_HOST="endpoint.rds.amazonaws.com"
export RDS_USER="admin"
export RDS_PASSWORD="password"
export RDS_DB="database"
export AWS_REGION="us-east-1"
```

## Common Ports

- MySQL: 3306
- PostgreSQL: 5432
- HTTP: 80
- HTTPS: 443
- Flask: 5000
- SSH: 22
