# Task 2: Database Migration to RDS

## 🎯 Objective
Migrate a self-managed MySQL database to Amazon RDS for improved scalability and manageability.

---

## 📋 Step-by-Step Guide

### Step 1: Create RDS MySQL Instance

#### Using AWS Console:
1. Navigate to RDS → Create database
2. Choose **MySQL** engine
3. Select **Free tier** template (or Production for real workloads)
4. Configure:
   - DB instance identifier: `ecommerce-db`
   - Master username: `admin`
   - Master password: (create strong password)
   - DB instance class: `db.t3.micro`
   - Storage: 20 GB (enable autoscaling)
   - VPC: Default or custom
   - Public access: Yes (for testing) / No (for production)
   - Security group: Create new with MySQL port 3306

#### Using AWS CLI:
```bash
aws rds create-db-instance \
  --db-instance-identifier ecommerce-db \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-user-password YourStrongPassword123! \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxxxxxx \
  --publicly-accessible \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "mon:04:00-mon:05:00"
```

### Step 2: Configure Security Group

Allow EC2 instances to connect to RDS:

```bash
# Get your EC2 security group ID
EC2_SG_ID=sg-xxxxxxxxx

# Add inbound rule to RDS security group
aws ec2 authorize-security-group-ingress \
  --group-id <RDS_SECURITY_GROUP_ID> \
  --protocol tcp \
  --port 3306 \
  --source-group $EC2_SG_ID
```

### Step 3: Get RDS Endpoint

```bash
aws rds describe-db-instances \
  --db-instance-identifier ecommerce-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

### Step 4: Test Connection

See `test-connection.py` for connection testing script.

---

## 🔒 Security Best Practices

1. **Never expose RDS publicly in production**
2. Use **IAM database authentication** when possible
3. Enable **encryption at rest** and **in transit**
4. Regular **automated backups**
5. Use **parameter groups** for custom configurations
6. Enable **Enhanced Monitoring**

---

## 📊 Performance Optimization

- Choose appropriate instance class based on workload
- Enable Multi-AZ for high availability
- Use Read Replicas for read-heavy workloads
- Monitor with CloudWatch metrics
- Optimize queries and indexes

---

## 💰 Cost Optimization

- Use Reserved Instances for predictable workloads
- Right-size your instance
- Delete unused snapshots
- Use Aurora Serverless for variable workloads
