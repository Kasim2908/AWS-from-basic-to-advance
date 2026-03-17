# 📚 Day 7 Quick Reference & Index

## 🎯 Complete Project Overview

Welcome to **Day 7: AWS DevOps CI/CD Pipeline Project**!

This is a hands-on guide to building a complete CI/CD pipeline using AWS CodePipeline, CodeBuild, and CodeDeploy.

---

## 📖 Documentation Files

| File | Purpose | Duration |
|------|---------|----------|
| **README.md** | Main project overview, concepts, and timeline | Start here! |
| **ARCHITECTURE.md** | Detailed architectural diagrams and data flows | Reference |
| **task-1/SOURCE-PREP.md** | Prepare Node.js application for CI/CD | 10 min |
| **task-2/S3-SETUP.md** | Create S3 bucket for build artifacts | 5 min |
| **task-3/CODEBUILD-SETUP.md** | Set up CodeBuild project | 15 min |
| **task-4/CODEDEPLOY-SETUP.md** | Configure CodeDeploy and EC2 instance | 20 min |
| **task-5/PIPELINE-CREATION.md** | Create complete CodePipeline | 10 min |

---

## 🚀 Quick Start Guide (TL;DR)

### 1️⃣ Task 1: Prepare Source Code (10 min)
```bash
# Create GitHub repo with Node.js app
- app.js (Express server)
- package.json (dependencies)
- buildspec.yml (CodeBuild instructions)
- git push to GitHub
```
→ [Full Guide](./task-1/SOURCE-PREP.md)

### 2️⃣ Task 2: Create S3 Bucket (5 min)
```
- S3 bucket: aws-cicd-artifacts-123456789012
- Enable versioning
- Configure bucket policy
```
→ [Full Guide](./task-2/S3-SETUP.md)

### 3️⃣ Task 3: Create CodeBuild Project (15 min)
```
- Project: nodejs-devops-app-build
- Source: GitHub
- Build: buildspec.yml
- Artifacts: S3 bucket
- Test: Manual build
```
→ [Full Guide](./task-3/CODEBUILD-SETUP.md)

### 4️⃣ Task 4: Configure CodeDeploy (20 min)
```
- EC2 instance: nodejs-codedeploy-target
- CodeDeploy app: nodejs-devops-app
- Deployment group: nodejs-deployment-group
- File: appspec.yml + lifecycle hooks
- Test: Manual deployment
```
→ [Full Guide](./task-4/CODEDEPLOY-SETUP.md)

### 5️⃣ Task 5: Create CodePipeline (10 min)
```
- Pipeline: nodejs-devops-pipeline
- Stages: Source → Build → Deploy
- Auto-trigger on GitHub push
- Test: End-to-end pipeline
```
→ [Full Guide](./task-5/PIPELINE-CREATION.md)

---

## 🗂️ File Structure

```
day-07/
├── README.md                          ← Start here
├── ARCHITECTURE.md                    ← Detailed diagrams
├── INDEX.md                           ← This file
│
├── task-1/
│   ├── SOURCE-PREP.md
│   ├── node-app/
│   │   ├── app.js
│   │   ├── package.json
│   │   ├── buildspec.yml              ← Key file!
│   │   └── .gitignore
│
├── task-2/
│   └── S3-SETUP.md
│
├── task-3/
│   └── CODEBUILD-SETUP.md
│
├── task-4/
│   ├── CODEDEPLOY-SETUP.md
│   ├── appspec.yml                    ← Key file!
│   ├── ec2-setup.sh                   ← User data script
│   ├── hooks-before-install.sh
│   ├── hooks-after-install.sh
│   ├── hooks-app-start.sh
│   ├── hooks-app-stop.sh
│   └── hooks-validate-service.sh
│
└── task-5/
    └── PIPELINE-CREATION.md
```

---

## 🔑 Key Files & Their Purpose

### `buildspec.yml` (CodeBuild)
**Location:** GitHub repository root  
**Purpose:** Tells CodeBuild how to build your app

```yaml
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 18
  pre_build:
    commands:
      - npm install
  build:
    commands:
      - npm run build
  post_build:
    commands:
      - echo "Build complete"
artifacts:
  files:
    - app.js
    - package.json
    - node_modules/**/*
```

### `appspec.yml` (CodeDeploy)
**Location:** GitHub repository root  
**Purpose:** Tells CodeDeploy how to deploy your app

```yaml
version: 0.0
Files:
  - source: /
    destination: /opt/nodejs-app
Hooks:
  BeforeInstall:
    - location: hooks/before-install.sh
  AfterInstall:
    - location: hooks/after-install.sh
  ApplicationStart:
    - location: hooks/app-start.sh
  ValidateService:
    - location: hooks/validate-service.sh
```

### Lifecycle Hooks
**Location:** `hooks/` directory in repository

| Hook | Purpose | Example |
|------|---------|---------|
| `before-install.sh` | Stop old app, cleanup | `systemctl stop nodejs-app` |
| `after-install.sh` | Extract, install deps | `npm install --production` |
| `app-start.sh` | Start new app | `systemctl start nodejs-app` |
| `app-stop.sh` | Graceful shutdown | `systemctl stop nodejs-app` |
| `validate-service.sh` | Health check | `curl /health` |

---

## 📊 AWS Services Involved

```
┌─────────────────────────────────────────────────┐
│             AWS Services Used                   │
├─────────────────────────────────────────────────┤
│                                                 │
│  GitHub                                         │
│  └─ Source code repository                      │
│     └─ buildspec.yml                            │
│     └─ appspec.yml                              │
│                                                 │
│  CodePipeline                                   │
│  └─ Orchestrates: Source → Build → Deploy       │
│                                                 │
│  CodeBuild                                      │
│  └─ Builds app using buildspec.yml              │
│                                                 │
│  CodeDeploy                                     │
│  └─ Deploys app using appspec.yml               │
│                                                 │
│  S3                                             │
│  └─ Stores build artifacts                      │
│     └─ Versioning enabled                       │
│                                                 │
│  EC2                                            │
│  └─ Runs application                            │
│     └─ CodeDeploy agent installed               │
│                                                 │
│  IAM                                            │
│  └─ Service roles for permissions               │
│                                                 │
│  CloudWatch                                     │
│  └─ Logs for CodeBuild and deployments          │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ⏱️ Timeline & Expected Durations

| Task | Duration | Key Milestone |
|------|----------|--------------|
| Task 1: Source Code | 10 min | GitHub repo with buildspec.yml |
| Task 2: S3 Bucket | 5 min | Artifact storage ready |
| Task 3: CodeBuild | 15 min | First build succeeds |
| Task 4: CodeDeploy | 20 min | First deployment succeeds |
| Task 5: CodePipeline | 10 min | Full pipeline working |
| **Testing & Screenshots** | 10 min | Evidence collected |
| **LinkedIn Post** | 5 min | Shared with #7DaysOfAWSWithTWS |
| **TOTAL** | **~75 min** | Complete CI/CD system! |

---

## 🔄 CI/CD Pipeline Flow

```
Developer pushes code to GitHub
    │
    ▼
GitHub Webhook triggers CodePipeline
    │
    ├─→ Source Stage (10 sec)
    │   └─ CodePipeline fetches from GitHub
    │
    ├─→ Build Stage (50 sec)
    │   ├─ CodeBuild starts build container
    │   ├─ Runs buildspec.yml phases
    │   │   ├─ Install: Node.js 18
    │   │   ├─ Pre-build: npm install
    │   │   ├─ Build: npm run build
    │   │   └─ Post-build: logs
    │   └─ Artifact uploaded to S3
    │
    ├─→ Deploy Stage (30 sec)
    │   ├─ CodeDeploy agent on EC2 notified
    │   ├─ Lifecycle hooks execute
    │   │   ├─ before-install: cleanup
    │   │   ├─ after-install: npm install
    │   │   ├─ app-start: systemctl start
    │   │   ├─ validate-service: health check
    │   │   └─ app-stop: (on next deploy)
    │   └─ EC2 running new version
    │
    ▼
Application Live ✅
Total time: ~3 minutes
```

---

## 🧪 Testing Checklist

After each task, verify:

### Task 1 ✓
- [ ] GitHub repo created
- [ ] app.js runs locally: `npm start`
- [ ] Visit `http://localhost:3000` → JSON response
- [ ] buildspec.yml has valid YAML syntax

### Task 2 ✓
- [ ] S3 bucket created
- [ ] Versioning enabled
- [ ] Bucket policy configured
- [ ] Test file uploaded and retrieved

### Task 3 ✓
- [ ] CodeBuild project created
- [ ] Manual build triggered and succeeded
- [ ] Build logs show "BUILD SUCCEEDED"
- [ ] Artifact in S3: `builds/app-artifact.zip`

### Task 4 ✓
- [ ] EC2 instance running
- [ ] CodeDeploy agent running: `sudo systemctl status codedeploy-agent`
- [ ] Manual deployment succeeded
- [ ] App accessible: `curl http://EC2-IP:3000/`
- [ ] Health check passes: `curl http://EC2-IP:3000/health`

### Task 5 ✓
- [ ] CodePipeline created
- [ ] First pipeline run succeeded (all stages)
- [ ] Push to GitHub auto-triggers pipeline
- [ ] Latest version deployed to EC2

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| buildspec.yml syntax error | Use [yamllint.com](https://yamllint.com) to validate |
| CodeBuild artifact empty | Check artifact files path in buildspec.yml |
| CodeDeploy agent not running | SSH to EC2: `sudo systemctl restart codedeploy-agent` |
| appspec.yml not found | Ensure it's in GitHub repo root, not in subdirectory |
| Hook scripts fail | Make executable: `chmod +x hooks/*.sh` |
| Health check fails | Verify port 3000 is open, app is running |
| Pipeline stuck at Source | GitHub webhook: CodePipeline Settings → Connections |

---

## 📚 Referenced AWS Documentation

- [CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline)
- [CodeBuild User Guide](https://docs.aws.amazon.com/codebuild)
- [CodeDeploy User Guide](https://docs.aws.amazon.com/codedeploy)
- [Buildspec YAML Reference](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
- [AppSpec YAML Reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/application-specification-files.html)

---

## 💡 Real-World Applications

This CI/CD pipeline system is used by:
- 🏢 Fortune 500 companies
- 🚀 Startups deploying microservices
- 🌍 Global platforms with millions of users
- 🏥 Healthcare systems with compliance requirements

The concepts you learn today are:**enterprise-grade production infrastructure**.

---

## 🎓 Next Steps After Day 7

**Intermediate:**
- Scale to Auto Scaling Groups
- Add blue/green deployments
- Implement canary deployments

**Advanced:**
- Migrate to ECS/Fargate (containerized)
- Deploy to Lambda (serverless)
- Add disaster recovery
- Implement GitOps workflow

**DevOps Specialization:**
- Infrastructure as Code (CloudFormation/Terraform)
- Container orchestration (Kubernetes)
- Monitoring & observability (DataDog, Prometheus)
- Incident response automation

---

## FAQ

**Q: Can I reuse this for my production app?**  
A: Yes! The patterns are production-ready. Add SSL/TLS, DMS backup, and monitoring for production.

**Q: How much will this cost?**  
A: ~$15-20/month (EC2 t2.micro, CodeBuild, S3 storage). Much cheaper than per-developer costs!

**Q: What if deployment fails?**  
A: CodeDeploy auto-rolls back. The previous working version stays live.

**Q: Can I deploy to multiple EC2 instances?**  
A: Yes! Use deployment group with multiple instances (or Auto Scaling Group).

**Q: How do I add manual approval before deploying?**  
A: Add Manual Approval stage in CodePipeline before Deploy stage.

---

## 📸 Submission Checklist

**Screenshots Required:**
- [ ] CodePipeline dashboard showing all stages succeeded
- [ ] CodeBuild logs showing "BUILD SUCCEEDED"
- [ ] CodeDeploy deployment logs showing success
- [ ] Browser/curl showing deployed app running
- [ ] Application responding to health check

**LinkedIn/Twitter Post:**
- [ ] Include project overview
- [ ] Share key learnings
- [ ] Link to GitHub repo
- [ ] Use hashtags: #7DaysOfAWSWithTWS #AWS #DevOps #CI/CD

---

## 🎉 Congratulations!

You've completed **Day 7: AWS DevOps CI/CD Pipeline**!

You now understand:
- ✅ How enterprises automate deployments
- ✅ The complete CI/CD workflow
- ✅ Infrastructure automation
- ✅ Monitoring and validation
- ✅ Best practices for reliable deployments

**You're now a DevOps practitioner!** 🚀

---

**Questions or stuck?** Refer to specific task guides above or check the troubleshooting section.

**Ready to share?** Post your LinkedIn/Twitter screenshot with **#7DaysOfAWSWithTWS**!

Hard work pays off. Keep learning! 💪
