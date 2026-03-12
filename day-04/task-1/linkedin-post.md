# Task 1: Learn & Share - LinkedIn Post

## 📝 Sample LinkedIn Post

---

🚀 Day 4 of my 7 Days of AWS Challenge with @TrainWithShubham!

Today I explored Databases, Lambda & Automation — making AWS do the heavy lifting! 💪

### 💾 Amazon RDS
Managed relational database that handles all the boring stuff (backups, patches, scaling) so I can focus on building.

**Example:** Launch a MySQL database in minutes:
```
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-user-password <password> \
  --allocated-storage 20
```

### ⚡ DynamoDB
NoSQL database with lightning-fast performance. No schema headaches, just pure speed!

**Example:** Store user data with flexible attributes:
```python
import boto3
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')
table.put_item(Item={'userId': '123', 'name': 'John', 'email': 'john@example.com'})
```

### 🌀 AWS Lambda
Write code, upload it, and let AWS run it automatically. No servers, no stress!

**Example:** Auto-resize images when uploaded to S3:
```python
def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    # Resize image logic here
    return {'statusCode': 200, 'body': 'Image processed'}
```

Today I learned how AWS services work together to build scalable, cost-effective solutions! 🎯

#7DaysOfAWS #AWSwithTWS #CloudComputing #AWS #ServerlessArchitecture

---

## 📌 Posting Checklist
- [ ] Include personal learning experience
- [ ] Add code examples
- [ ] Use hashtags: #7DaysOfAWS #AWSwithTWS
- [ ] Tag @TrainWithShubham
- [ ] Engage with 2 other learners' posts
