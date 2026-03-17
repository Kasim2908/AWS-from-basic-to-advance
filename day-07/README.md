# 🚀 Day 7 – AWS DevOps CI/CD Pipeline Project

## 🎯 Goal

Set up a complete **CI/CD Pipeline** for a sample Node.js application using **AWS CodePipeline**, **CodeBuild**, and **CodeDeploy**.

By the end of this project, you'll understand how AWS automates builds, tests, and deployments — exactly like real DevOps engineers! ⚙️

---

## 🧠 Core Concepts

### 🔄 AWS CodePipeline
A **fully managed continuous integration and continuous delivery (CI/CD)** service that automates your release processes.

**Key Features:**
- Source → Build → Deploy workflow
- Automatic triggers on code changes
- Multiple deployment targets
- Integrated with GitHub, GitLab, CodeCommit
- Visualization of pipeline stages

### 🔨 AWS CodeBuild
A **fully managed build service** that compiles source code, runs tests, and produces deployment-ready artifacts.

**Key Features:**
- Pre-configured Node.js, Python, Java, Go runtimes
- `buildspec.yml` for build instructions
- Runs in Docker containers
- Output artifacts to S3
- Build logs to CloudWatch

### 🎯 AWS CodeDeploy
A **deployment service** that automates application deployment to EC2 instances, on-premises servers, or Lambda.

**Key Features:**
- `appspec.yml` defines deployment steps
- Supports in-place and blue/green deployments
- Auto-rollback on failure
- Works with CodePipeline seamlessly

### 🏗️ High-Level Architecture

```
┌─────────┐      ┌──────────┐      ┌─────────┐      ┌──────────┐
│ GitHub  │─────→│ Pipeline │─────→│CodeBuild│─────→│CodeDeploy│
│ Repo    │      │          │      │         │      │          │
└─────────┘      └──────────┘      └────┬────┘      └─────┬────┘
                                         │                  │
                                         ▼                  ▼
                                    ┌─────────┐        ┌─────────┐
                                    │    S3   │        │   EC2   │
                                    │Artifacts│        │Instance │
                                    └─────────┘        └─────────┘
```

---

## 📋 Task Overview

| Task | Objective | Key Deliverables |
|------|-----------|------------------|
| **Task 1** | Prepare Node.js source code | `buildspec.yml`, `package.json`, `app.js` |
| **Task 2** | Create S3 bucket for artifacts | Versioning enabled, bucket policy configured |
| **Task 3** | Set up CodeBuild project | Build environment, artifact output configured |
| **Task 4** | Configure CodeDeploy | `appspec.yml`, EC2 with agent, IAM roles |
| **Task 5** | Create CodePipeline | Complete pipeline: Source → Build → Deploy |

### ✨ Bonus Tasks
- Add SNS notifications for pipeline events
- Implement CloudWatch monitoring
- Set up Slack notifications
- Implement manual approval before deployment

---

## 📁 Directory Structure

```
day-07/
├── README.md                       # Main overview
├── ARCHITECTURE.md                 # Detailed architecture diagrams
├── task-1/
│   ├── node-app/
│   │   ├── app.js                 # Node.js Express app
│   │   ├── package.json           # Dependencies
│   │   ├── buildspec.yml          # CodeBuild config
│   │   └── BUILD-GUIDE.md         # Step-by-step guide
│   └── SOURCE-PREP.md
├── task-2/
│   └── S3-SETUP.md               # S3 bucket configuration
├── task-3/
│   └── CODEBUILD-SETUP.md        # CodeBuild project creation
├── task-4/
│   ├── appspec.yml               # CodeDeploy config
│   ├── ec2-setup.sh              # EC2 bootstrapping
│   └── CODEDEPLOY-SETUP.md       # CodeDeploy configuration
└── task-5/
    └── PIPELINE-CREATION.md      # Complete pipeline setup
```

---

## ⚡ Quick Start Timeline

| Step | Duration | Description |
|------|----------|-------------|
| Task 1 | 10 min | Create Node.js app with buildspec.yml |
| Task 2 | 5 min | Create S3 bucket with versioning |
| Task 3 | 15 min | Configure CodeBuild project |
| Task 4 | 20 min | Launch EC2 + install CodeDeploy agent + configure appspec.yml |
| Task 5 | 10 min | Connect pipeline stages |
| **Testing** | 10 min | Run pipeline and verify deployment |
| **Total** | ~70 min | Complete CI/CD pipeline |

---

## 🔐 Required IAM Permissions

You'll need IAM roles and policies for:
- **CodePipeline execution role** — access to CodeBuild and CodeDeploy
- **CodeBuild service role** — read S3 source, write artifacts, CloudWatch logs
- **CodeDeploy service role** — interact with EC2 instances
- **EC2 instance role** — access S3 artifacts, CloudWatch logs

Detailed policies are provided in each task guide. ✅

---

## 📋 Tasks Detailed

### [Task 1: Prepare Source Code](./task-1/SOURCE-PREP.md)
- Create a simple Node.js Express HTTP server
- Add `buildspec.yml` for build automation
- Commit to GitHub repository

### [Task 2: Create S3 Bucket for Artifacts](./task-2/S3-SETUP.md)
- Create S3 bucket with a clear naming convention
- Enable versioning for safe artifact management
- Set appropriate bucket policies

### [Task 3: Create CodeBuild Project](./task-3/CODEBUILD-SETUP.md)
- Connect GitHub repository
- Configure Node.js build environment
- Test build artifacts generation

### [Task 4: Configure CodeDeploy](./task-4/CODEDEPLOY-SETUP.md)
- Launch EC2 instance (Amazon Linux 2)
- Install and configure CodeDeploy agent
- Create `appspec.yml` for deployment steps

### [Task 5: Create CodePipeline](./task-5/PIPELINE-CREATION.md)
- Connect GitHub source
- Add CodeBuild stage
- Add CodeDeploy stage
- Test end-to-end pipeline

---

## 🧪 Testing & Validation

After creating the pipeline, test it by:

1. **Trigger pipeline:** Push code to GitHub
2. **Monitor CodeBuild:** Check build logs in CloudWatch
3. **Verify deployment:** SSH into EC2 and confirm app is running
4. **Test application:** Visit the deployed Node.js app via EC2 public IP

**Expected Output:**
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Hello from deployed Node.js app!",
  "timestamp": "2026-03-17T10:30:00Z"
}
```

---

## 📊 Architecture Diagrams

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed visual explanations of:
- CodePipeline workflow
- CodeBuild artifact flow
- CodeDeploy deployment strategy
- Network architecture (VPC, Security Groups, IAM)

---

## 🐛 Troubleshooting Common Issues

### Pipeline fails at CodeBuild stage
- ✅ Check `buildspec.yml` syntax (YAML formatting)
- ✅ Verify Node.js version compatibility
- ✅ Check CloudWatch Logs for detailed errors

### CodeDeploy agent not communicating
- ✅ Verify EC2 instance has CodeDeploy service role attached
- ✅ Check Security Group allows outbound HTTPS (Port 443)
- ✅ Verify CodeDeploy agent is running: `sudo systemctl status codedeploy-agent`

### Application not starting after deployment
- ✅ Check `appspec.yml` hooks are executable
- ✅ SSH into EC2 and verify files deployed to `/opt/nodejs-app`
- ✅ Check application logs: `journalctl -u nodejs-app -n 50`

See troubleshooting guides in each task for more details.

---

## 📚 Learning Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Best Practices](https://docs.aws.amazon.com/codebuild/latest/userguide/)
- [AWS CodeDeploy Reference](https://docs.aws.amazon.com/codedeploy/)
- [Buildspec YAML Reference](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
- [AppSpec YAML Reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/application-specification-files.html)

---

## 📤 Submission Requirements

After completing all tasks, prepare screenshots of:

1. ✅ **CodePipeline Dashboard** — showing all stages (Source → Build → Deploy)
2. ✅ **Successful Build** — CodeBuild logs with "BUILD SUCCEEDED"
3. ✅ **Deployed Application** — browser showing the Node.js app running on EC2
4. ✅ **CodeDeploy Logs** — showing successful deployment

### LinkedIn/Twitter Post Template

```
Just completed Day 7 of #7DaysOfAWSWithTWS! 🚀

Built a complete CI/CD pipeline using:
✅ AWS CodePipeline
✅ AWS CodeBuild  
✅ AWS CodeDeploy
✅ GitHub integration

Automated the entire process: GitHub → Build → Deploy → EC2 🔄

Key learnings:
- How CI/CD accelerates development
- Infrastructure as Code with buildspec.yml & appspec.yml
- Automated deployments reduce manual errors

Next: Scaling this to Lambda & ECS! 

#AWS #DevOps #CI/CD #IaC
```

---

## ✅ Completion Checklist

Before declaring Day 7 complete:

- [ ] Task 1: Node.js app in GitHub with buildspec.yml
- [ ] Task 2: S3 bucket created with versioning
- [ ] Task 3: CodeBuild project building successfully
- [ ] Task 4: EC2 instance running CodeDeploy agent
- [ ] Task 5: Complete pipeline executing successfully
- [ ] Tested: Push code → Pipeline triggers → App deploys
- [ ] Screenshots collected for LinkedIn/Twitter
- [ ] Post shared on LinkedIn/Twitter

---

## 🎓 What You've Learned

By completing Day 7, you understand:

1. **CI/CD fundamentals** — why automation matters
2. **CodePipeline orchestration** — chaining multiple AWS services
3. **CodeBuild artifact management** — generating and storing build outputs
4. **CodeDeploy strategies** — deploying to EC2 instances
5. **Infrastructure as Code** — `buildspec.yml` and `appspec.yml`
6. **Monitoring and logging** — CloudWatch integration
7. **Real-world DevOps workflows** — how enterprises handle deployments

---

**Congratulations! You're now a DevOps engineer! 🎉**

Questions? Refer to individual task guides or AWS documentation.
