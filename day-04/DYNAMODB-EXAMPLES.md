# 🔥 Bonus: DynamoDB Examples

## 📚 What is DynamoDB?

Amazon DynamoDB is a fully managed NoSQL database that provides:
- Single-digit millisecond performance
- Automatic scaling
- Built-in security and backup
- Global tables for multi-region deployment

---

## 🎯 When to Use DynamoDB vs RDS

### Use DynamoDB when:
- Need high-speed, predictable performance
- Schema flexibility is important
- Building serverless applications
- Need automatic scaling
- Working with key-value or document data

### Use RDS when:
- Need complex queries and joins
- Require ACID transactions
- Using existing SQL applications
- Need relational data model

---

## 🚀 Quick Start with AWS CLI

### Create Table
```bash
aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions \
    AttributeName=userId,AttributeType=S \
  --key-schema \
    AttributeName=userId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Put Item
```bash
aws dynamodb put-item \
  --table-name Users \
  --item '{
    "userId": {"S": "user123"},
    "name": {"S": "John Doe"},
    "email": {"S": "john@example.com"},
    "age": {"N": "30"}
  }'
```

### Get Item
```bash
aws dynamodb get-item \
  --table-name Users \
  --key '{"userId": {"S": "user123"}}'
```

### Query Items
```bash
aws dynamodb query \
  --table-name Users \
  --key-condition-expression "userId = :uid" \
  --expression-attribute-values '{":uid": {"S": "user123"}}'
```

### Scan Table
```bash
aws dynamodb scan --table-name Users
```

### Delete Item
```bash
aws dynamodb delete-item \
  --table-name Users \
  --key '{"userId": {"S": "user123"}}'
```

---

## 🐍 Python Boto3 Examples

### Basic Operations
```python
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')

# Put item
table.put_item(
    Item={
        'userId': 'user123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 30,
        'active': True
    }
)

# Get item
response = table.get_item(Key={'userId': 'user123'})
item = response.get('Item')
print(item)

# Update item
table.update_item(
    Key={'userId': 'user123'},
    UpdateExpression='SET age = :val',
    ExpressionAttributeValues={':val': 31}
)

# Query
response = table.query(
    KeyConditionExpression=Key('userId').eq('user123')
)
items = response['Items']

# Scan with filter
response = table.scan(
    FilterExpression=Key('age').gt(25)
)
items = response['Items']

# Delete item
table.delete_item(Key={'userId': 'user123'})
```

### Batch Operations
```python
# Batch write
with table.batch_writer() as batch:
    for i in range(100):
        batch.put_item(
            Item={
                'userId': f'user{i}',
                'name': f'User {i}',
                'email': f'user{i}@example.com'
            }
        )

# Batch get
response = dynamodb.batch_get_item(
    RequestItems={
        'Users': {
            'Keys': [
                {'userId': 'user1'},
                {'userId': 'user2'},
                {'userId': 'user3'}
            ]
        }
    }
)
```

---

## 🏗️ Real-World Example: Session Store

```python
import boto3
import json
from datetime import datetime, timedelta
import uuid

class SessionStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('Sessions')
    
    def create_session(self, user_id, data):
        session_id = str(uuid.uuid4())
        ttl = int((datetime.now() + timedelta(hours=24)).timestamp())
        
        self.table.put_item(
            Item={
                'sessionId': session_id,
                'userId': user_id,
                'data': json.dumps(data),
                'createdAt': datetime.now().isoformat(),
                'ttl': ttl
            }
        )
        return session_id
    
    def get_session(self, session_id):
        response = self.table.get_item(Key={'sessionId': session_id})
        return response.get('Item')
    
    def delete_session(self, session_id):
        self.table.delete_item(Key={'sessionId': session_id})

# Usage
store = SessionStore()
session_id = store.create_session('user123', {'cart': ['item1', 'item2']})
session = store.get_session(session_id)
print(session)
```

---

## 🔍 Advanced Features

### Global Secondary Index (GSI)
```bash
aws dynamodb update-table \
  --table-name Users \
  --attribute-definitions \
    AttributeName=email,AttributeType=S \
  --global-secondary-index-updates '[{
    "Create": {
      "IndexName": "EmailIndex",
      "KeySchema": [{"AttributeName": "email", "KeyType": "HASH"}],
      "Projection": {"ProjectionType": "ALL"},
      "ProvisionedThroughput": {
        "ReadCapacityUnits": 5,
        "WriteCapacityUnits": 5
      }
    }
  }]'
```

### Query with GSI
```python
response = table.query(
    IndexName='EmailIndex',
    KeyConditionExpression=Key('email').eq('john@example.com')
)
```

### Conditional Writes
```python
# Only update if age is less than 50
table.update_item(
    Key={'userId': 'user123'},
    UpdateExpression='SET age = :new_age',
    ConditionExpression='age < :max_age',
    ExpressionAttributeValues={
        ':new_age': 31,
        ':max_age': 50
    }
)
```

### Transactions
```python
client = boto3.client('dynamodb')

response = client.transact_write_items(
    TransactItems=[
        {
            'Put': {
                'TableName': 'Users',
                'Item': {'userId': {'S': 'user123'}, 'name': {'S': 'John'}}
            }
        },
        {
            'Update': {
                'TableName': 'Accounts',
                'Key': {'accountId': {'S': 'acc123'}},
                'UpdateExpression': 'SET balance = balance - :amount',
                'ExpressionAttributeValues': {':amount': {'N': '100'}}
            }
        }
    ]
)
```

---

## 💰 Cost Optimization

### On-Demand vs Provisioned
```bash
# Switch to on-demand
aws dynamodb update-table \
  --table-name Users \
  --billing-mode PAY_PER_REQUEST

# Switch to provisioned
aws dynamodb update-table \
  --table-name Users \
  --billing-mode PROVISIONED \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Enable Auto Scaling
```bash
aws application-autoscaling register-scalable-target \
  --service-namespace dynamodb \
  --resource-id "table/Users" \
  --scalable-dimension "dynamodb:table:ReadCapacityUnits" \
  --min-capacity 5 \
  --max-capacity 100
```

---

## 🔒 Security Best Practices

### IAM Policy Example
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:region:account:table/Users"
    }
  ]
}
```

### Enable Encryption
```bash
aws dynamodb update-table \
  --table-name Users \
  --sse-specification Enabled=true,SSEType=KMS
```

---

## 📊 Monitoring

### CloudWatch Metrics
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=Users \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

---

## 🎯 Practice Exercise

Create a simple TODO application using DynamoDB:

```python
import boto3
from datetime import datetime

class TodoApp:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('Todos')
    
    def add_todo(self, user_id, task):
        self.table.put_item(
            Item={
                'userId': user_id,
                'timestamp': datetime.now().isoformat(),
                'task': task,
                'completed': False
            }
        )
    
    def get_todos(self, user_id):
        response = self.table.query(
            KeyConditionExpression=Key('userId').eq(user_id)
        )
        return response['Items']
    
    def complete_todo(self, user_id, timestamp):
        self.table.update_item(
            Key={'userId': user_id, 'timestamp': timestamp},
            UpdateExpression='SET completed = :val',
            ExpressionAttributeValues={':val': True}
        )

# Usage
app = TodoApp()
app.add_todo('user123', 'Learn DynamoDB')
todos = app.get_todos('user123')
print(todos)
```

---

## 📚 Additional Resources

- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Data Modeling](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/data-modeling.html)
- [Boto3 DynamoDB Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)

---

**Pro Tip:** DynamoDB is perfect for serverless applications with Lambda. Try combining them for a fully managed, scalable solution!
