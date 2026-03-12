# 🏗️ Day 4 Architecture Diagrams

## Task 2: RDS Migration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    VPC                                │  │
│  │                                                       │  │
│  │  ┌─────────────────┐         ┌──────────────────┐  │  │
│  │  │   EC2 Instance  │────────▶│   RDS MySQL      │  │  │
│  │  │   (Application) │         │   (Database)     │  │  │
│  │  │                 │         │                  │  │  │
│  │  │  Security Group │         │  Security Group  │  │  │
│  │  │  - Port 22 SSH  │         │  - Port 3306     │  │  │
│  │  │  - Port 80 HTTP │         │    from EC2 SG   │  │  │
│  │  └─────────────────┘         └──────────────────┘  │  │
│  │                                                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Task 3: Scalable Web Application Architecture

```
                          Internet
                             │
                             ▼
                    ┌────────────────┐
                    │  Route 53 DNS  │
                    └────────┬───────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────┐
│                        AWS Cloud                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                      VPC                             │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │    Application Load Balancer (ALB)           │  │  │
│  │  │    - Health Checks                            │  │  │
│  │  │    - SSL/TLS Termination                      │  │  │
│  │  └──────────────┬───────────────────────────────┘  │  │
│  │                 │                                   │  │
│  │                 ▼                                   │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │       Auto Scaling Group                     │  │  │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │  │  │
│  │  │  │ EC2      │  │ EC2      │  │ EC2      │  │  │  │
│  │  │  │ Flask    │  │ Flask    │  │ Flask    │  │  │  │
│  │  │  │ App      │  │ App      │  │ App      │  │  │  │
│  │  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  │  │  │
│  │  │       │             │             │         │  │  │
│  │  │       └─────────────┼─────────────┘         │  │  │
│  │  │                     │                       │  │  │
│  │  │    Min: 2  Desired: 2  Max: 5              │  │  │
│  │  └─────────────────────┼───────────────────────┘  │  │
│  │                        │                          │  │
│  │                        ▼                          │  │
│  │              ┌──────────────────┐                 │  │
│  │              │   RDS MySQL      │                 │  │
│  │              │   Multi-AZ       │                 │  │
│  │              │   - Primary      │                 │  │
│  │              │   - Standby      │                 │  │
│  │              └──────────────────┘                 │  │
│  │                                                    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │              CloudWatch Monitoring                  │  │
│  │  - CPU Utilization  - Request Count                │  │
│  │  - Network Traffic  - Database Connections         │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## Task 4: Lambda EC2 Automation Architecture

```
┌──────────────────────────────────────────────────────────┐
│                      AWS Cloud                            │
│                                                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │           Amazon EventBridge                        │  │
│  │                                                     │  │
│  │  ┌──────────────────┐    ┌──────────────────┐    │  │
│  │  │  Start Rule      │    │  Stop Rule       │    │  │
│  │  │  cron(0 8 ? *    │    │  cron(0 18 ? *   │    │  │
│  │  │  MON-FRI *)      │    │  MON-FRI *)      │    │  │
│  │  │  8 AM Weekdays   │    │  6 PM Weekdays   │    │  │
│  │  └────────┬─────────┘    └────────┬─────────┘    │  │
│  │           │                       │               │  │
│  └───────────┼───────────────────────┼───────────────┘  │
│              │                       │                  │
│              └───────────┬───────────┘                  │
│                          ▼                              │
│              ┌────────────────────────┐                 │
│              │   AWS Lambda Function  │                 │
│              │   EC2StartStopScheduler│                 │
│              │                        │                 │
│              │   - Python 3.11        │                 │
│              │   - Boto3 SDK          │                 │
│              │   - IAM Role           │                 │
│              └───────────┬────────────┘                 │
│                          │                              │
│                          ▼                              │
│              ┌────────────────────────┐                 │
│              │   Amazon EC2 Service   │                 │
│              │                        │                 │
│              │  ┌──────────────────┐ │                 │
│              │  │ EC2 Instance 1   │ │                 │
│              │  │ Tag: AutoStart   │ │                 │
│              │  │ Stop=true        │ │                 │
│              │  └──────────────────┘ │                 │
│              │                        │                 │
│              │  ┌──────────────────┐ │                 │
│              │  │ EC2 Instance 2   │ │                 │
│              │  │ Tag: AutoStart   │ │                 │
│              │  │ Stop=true        │ │                 │
│              │  └──────────────────┘ │                 │
│              │                        │                 │
│              │  ┌──────────────────┐ │                 │
│              │  │ EC2 Instance 3   │ │                 │
│              │  │ (No tag)         │ │                 │
│              │  │ Not affected     │ │                 │
│              │  └──────────────────┘ │                 │
│              └────────────────────────┘                 │
│                          │                              │
│                          ▼                              │
│              ┌────────────────────────┐                 │
│              │   CloudWatch Logs      │                 │
│              │   - Execution logs     │                 │
│              │   - Error tracking     │                 │
│              └────────────────────────┘                 │
│                                                          │
└──────────────────────────────────────────────────────────┘

Flow:
1. EventBridge triggers Lambda at scheduled times
2. Lambda queries EC2 for instances with specific tags
3. Lambda starts/stops matching instances
4. CloudWatch logs all activities
```

---

## Complete Day 4 Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS Account                                 │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Management & Monitoring                  │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │    │
│  │  │ CloudWatch   │  │ CloudTrail   │  │ Cost Explorer│    │    │
│  │  │ Metrics/Logs │  │ Audit Logs   │  │ Billing      │    │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Compute Layer                            │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │    │
│  │  │ EC2 Instances│  │ Auto Scaling │  │ Lambda       │    │    │
│  │  │ Flask Apps   │  │ Groups       │  │ Functions    │    │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Network Layer                            │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │    │
│  │  │ VPC          │  │ Load Balancer│  │ Security     │    │    │
│  │  │ Subnets      │  │ (ALB)        │  │ Groups       │    │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Database Layer                           │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │    │
│  │  │ RDS MySQL    │  │ DynamoDB     │  │ Backups      │    │    │
│  │  │ Multi-AZ     │  │ (Optional)   │  │ Snapshots    │    │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Automation Layer                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │    │
│  │  │ EventBridge  │  │ Lambda       │  │ IAM Roles    │    │    │
│  │  │ Schedules    │  │ Automation   │  │ Policies     │    │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow: User Request to Database

```
1. User Request
   │
   ▼
2. Route 53 (DNS Resolution)
   │
   ▼
3. Application Load Balancer
   │
   ├─▶ Health Check
   │
   ▼
4. Auto Scaling Group
   │
   ├─▶ EC2 Instance 1 (Flask App)
   ├─▶ EC2 Instance 2 (Flask App)
   └─▶ EC2 Instance 3 (Flask App)
       │
       ▼
5. RDS MySQL Database
   │
   ├─▶ Primary Instance (Read/Write)
   └─▶ Standby Instance (Failover)
       │
       ▼
6. Response back to user
```

---

## Lambda Automation Flow

```
Time: 8:00 AM (Monday-Friday)
   │
   ▼
EventBridge Rule: StartEC2Instances
   │
   ▼
Lambda Function: EC2StartStopScheduler
   │
   ├─▶ Query EC2 instances with tag "AutoStartStop=true"
   │
   ├─▶ Filter instances in "stopped" state
   │
   ├─▶ Call ec2.start_instances()
   │
   └─▶ Log results to CloudWatch
       │
       ▼
   EC2 Instances Started
   
───────────────────────────────────────────

Time: 6:00 PM (Monday-Friday)
   │
   ▼
EventBridge Rule: StopEC2Instances
   │
   ▼
Lambda Function: EC2StartStopScheduler
   │
   ├─▶ Query EC2 instances with tag "AutoStartStop=true"
   │
   ├─▶ Filter instances in "running" state
   │
   ├─▶ Call ec2.stop_instances()
   │
   └─▶ Log results to CloudWatch
       │
       ▼
   EC2 Instances Stopped
```

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Security Layers                       │
│                                                          │
│  Layer 1: Network Security                              │
│  ┌────────────────────────────────────────────────┐    │
│  │ • VPC Isolation                                 │    │
│  │ • Security Groups (Stateful Firewall)          │    │
│  │ • Network ACLs (Stateless Firewall)            │    │
│  │ • Private Subnets for RDS                      │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Layer 2: Identity & Access                             │
│  ┌────────────────────────────────────────────────┐    │
│  │ • IAM Roles for EC2 and Lambda                 │    │
│  │ • Least Privilege Policies                     │    │
│  │ • MFA for Console Access                       │    │
│  │ • Access Keys Rotation                         │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Layer 3: Data Protection                               │
│  ┌────────────────────────────────────────────────┐    │
│  │ • RDS Encryption at Rest (KMS)                 │    │
│  │ • SSL/TLS for Data in Transit                  │    │
│  │ • Automated Backups                            │    │
│  │ • Snapshot Encryption                          │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Layer 4: Monitoring & Compliance                       │
│  ┌────────────────────────────────────────────────┐    │
│  │ • CloudWatch Logs                              │    │
│  │ • CloudTrail Audit Logs                        │    │
│  │ • AWS Config Rules                             │    │
│  │ • Security Hub                                 │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

These diagrams provide a visual understanding of how all Day 4 components work together!
