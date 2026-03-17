# Task 5: Create CodePipeline 🚀

## Objective
Create the complete AWS CodePipeline that orchestrates the entire workflow: GitHub → CodeBuild → CodeDeploy → EC2

---

## What You'll Learn
✅ CodePipeline creation and configuration
✅ Pipeline stage orchestration
✅ Artifact flow between stages
✅ End-to-end CI/CD workflow
✅ Monitoring and troubleshooting pipelines
✅ Pipeline notifications and alerts

---

## Prerequisites

Before starting, ensure you have:
- ✅ GitHub repository with buildspec.yml ([Task 1](../task-1/SOURCE-PREP.md))
- ✅ S3 bucket for artifacts ([Task 2](../task-2/S3-SETUP.md))
- ✅ CodeBuild project created ([Task 3](../task-3/CODEBUILD-SETUP.md))
- ✅ CodeDeploy configured with EC2 instance ([Task 4](../task-4/CODEDEPLOY-SETUP.md))
- ✅ GitHub personal access token (from Task 3, or create new one)

---

## Step-by-Step Guide

### Step 1: Create CodePipeline Service Role

CodePipeline needs permissions to invoke CodeBuild and CodeDeploy.

1. **Open AWS Console** → IAM → Roles → **Create role**

2. **Select trusted entity:**
   - Trusted entity type: **AWS service**
   - Service: **CodePipeline**
   - Click **Next**

3. **Add permissions:**
   - Search for: `AWSCodePipelineFullAccess`
   - ✅ Check it
   - Click **Next**

4. **Add inline policy for S3 and other services:**
   - **Add inline policy** → **JSON** tab:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::aws-cicd-artifacts-123456789012/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:BatchGetBuildBatches"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetApplication",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:ListApplicationRevisions",
        "codedeploy:ListDeploymentConfigs",
        "codedeploy:ListDeploymentGroups"
      ],
      "Resource": "*"
    }
  ]
}
```

   - Click **Create policy**

5. **Role name:**
   - `CodePipeline-Service-Role`
   - Click **Create role**

### Step 2: Create CodePipeline

1. **Open AWS Console** → Developer Tools → [CodePipeline](https://console.aws.amazon.com/codepipeline)

2. **Click "Create pipeline"**

3. **Pipeline name:**
   - Name: `nodejs-devops-pipeline`
   - Service role: **CodePipeline-Service-Role** (created above)
   - Execution mode: **Queued** (safer for production)
   - Click **Next**

### Step 3: Configure Source Stage

1. **Source stage settings:**
   - Source provider: **GitHub (Version 2)**
   - Connection: 
     - If no connection exists:
       - Click "Connect to GitHub"
       - Authorize GitHub app
       - Select your repository: `aws-nodejs-devops`
     - If connection exists:
       - Select from dropdown
   - Repository: `aws-nodejs-devops`
   - Branch: `main`
   - Trigger: **Push to selected branch**
   - **Next**

### Step 4: Configure Build Stage

1. **Build stage settings:**
   - Build provider: **AWS CodeBuild**
   - Project name: `nodejs-devops-app-build` (the project created in Task 3)
   - Environment variables: (Optional)
     - Key: `NODE_ENV`
     - Value: `production`
   - Click **Next**

### Step 5: Configure Deploy Stage

1. **Deploy stage settings:**
   - Deploy provider: **CodeDeploy**
   - Application name: `nodejs-devops-app` (from Task 4)
   - Deployment group: `nodejs-deployment-group` (from Task 4)
   - **Next**

### Step 6: Review and Create

1. **Review pipeline configuration:**
   - Source: GitHub → aws-nodejs-devops → main
   - Build: CodeBuild → nodejs-devops-app-build
   - Deploy: CodeDeploy → nodejs-devops-app/nodejs-deployment-group

2. **Click "Create pipeline"**

3. **Wait for pipeline to initialize** (~30 seconds)

---

## Pipeline Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│           CodePipeline: nodejs-devops-pipeline              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐     ┌──────────────┐    ┌─────────────┐ │
│  │   SOURCE      │────→│    BUILD      │───→│   DEPLOY     │ │
│  │   (GitHub)    │     │  (CodeBuild)  │    │(CodeDeploy)│ │
│  └──────────────┘     └──────────────┘    └──────┬──────┘ │
│                                                   │        │
│  Repository:            Project:                 │        │
│  aws-nodejs-devops      nodejs-devops-            │        │
│  Branch: main           app-build                 │        │
│  Trigger: Push          Artifact: S3 bucket       │        │
│                                                   │        │
│                                                   ▼        │
│                                           EC2 Instance     │
│                                       (nodejs-codedeploy-  │
│                                            target)         │
└─────────────────────────────────────────────────────────────┘
```

---

## Step 7: Verify Pipeline Creation

1. **Check pipeline status:**
   - CodePipeline → Pipelines → Select `nodejs-devops-pipeline`
   - Status should show: **Execution in progress** or **Success**

2. **Expected first run:**
   - Source stage: Gets code from GitHub
   - Build stage: Builds application (takes ~50 seconds)
   - Deploy stage: Deploys to EC2 (takes ~30 seconds)
   - Total time: ~3 minutes

3. **Monitor stage details:**
   ```
   Source Stage
   ├─ Status: ✅ Succeeded
   ├─ Duration: ~10 seconds
   └─ Output: Source artifact (repo code)
   
   Build Stage
   ├─ Status: ✅ Succeeded
   ├─ Duration: ~50 seconds
   ├─ Output: Build artifact (app-artifact.zip)
   └─ Logs: View in CloudWatch
   
   Deploy Stage
   ├─ Status: ✅ Succeeded
   ├─ Duration: ~30 seconds
   ├─ Output: Deployed files in EC2
   └─ Logs: View in CodeDeploy
   ```

---

## Step 8: Test End-to-End Pipeline

### Automatic Trigger Test (Push Code)

1. **Make a code change:**
   ```bash
   cd aws-nodejs-devops
   
   # Modify app.js
   # Change message to: "Hello v2.0"
   
   git add app.js
   git commit -m "feat: Update version to 2.0 - test pipeline trigger"
   git push origin main
   ```

2. **Watch pipeline auto-trigger:**
   - Go to CodePipeline → `nodejs-devops-pipeline`
   - New execution should start automatically
   - Watch as it progresses through all stages

3. **Verify in AWS Console:**
   - **CodeBuild:** Check build logs
   - **CodeDeploy:** Check deployment logs
   - **EC2:** SSH in and verify app is updated

### Manual Pipeline Execution

If webhook doesn't work:

1. **CodePipeline console** → `nodejs-devops-pipeline`
2. **Click "Release change"** button
3. Pipeline will re-run through all stages

---

## Testing the Deployed Application

### SSH into EC2 and Verify

```bash
# SSH to instance
ssh -i nodejs-devops-key.pem ec2-user@EC2-PUBLIC-IP

# Check application is running
curl http://localhost:3000/

# Expected response:
{
  "message": "Hello from deployed Node.js app! 🚀",
  "timestamp": "2026-03-17T10:30:00.000Z",
  "version": "1.0.0"
}

# Check health endpoint
curl http://localhost:3000/health

# Check service status
sudo systemctl status nodejs-app

# View application logs
sudo journalctl -u nodejs-app -n 20 -f
```

### Test via Public IP

```bash
# From your local machine
curl http://EC2-PUBLIC-IP:3000/

# Or open in browser:
# http://54.123.45.67:3000
```

---

## Pipeline Monitoring & Logs

### CodePipeline Console

```
Pipeline Status Dashboard
├─ Execution history (latest first)
├─ Stage execution times
├─ Artifact locations
└─ Failed stage details
```

### CloudWatch Logs for CodeBuild

```bash
# View CodeBuild build logs
aws logs tail /aws/codebuild/nodejs-app --follow

# Or via console:
CloudWatch → Log groups → /aws/codebuild/nodejs-app
                         → build-xyz...
```

### CodeDeploy Deployment Logs

```bash
# Via SSH on EC2
tail -f /var/log/codedeploy-agent/deployment.log

# Or view in CodeDeploy console:
CodeDeploy → Deployments → Select deployment
           → View deployment logs for each instance
```

---

## Pipeline Artifact Flow

```
GitHub Repository (main branch)
        │
        │ CodePipeline Source Stage
        ▼
   S3 Artifact Store
   └─ source-artifact/
      └─ repo.zip
        │
        │ CodePipeline passes to CodeBuild
        ▼
   CodeBuild
   ├─ Extracts source artifact
   ├─ Runs buildspec.yml phases
   ├─ Creates app-artifact.zip
   └─ Uploads to S3
        │
        │ app-artifact.zip
        ▼
   S3 Artifact Store
   └─ builds/
      └─ app-artifact.zip
        │
        │ CodePipeline passes to CodeDeploy
        ▼
   CodeDeploy
   ├─ Gets artifact from S3
   ├─ Transfers to EC2
   ├─ Extracts to /opt/nodejs-app
   └─ Runs lifecycle hooks
        │
        │ Application Started
        ▼
   EC2 Instance Running App ✅
```

---

## All-in-One Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                     CI/CD Pipeline Complete                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ GitHub (Source Code)                                        │
│     ↓ (webhook trigger)                                     │
│ CodePipeline (Orchestration)                               │
│     ├─→ Source Stage: Pull from GitHub                      │
│     │   ↓ (artifact: source.zip)                            │
│     ├─→ Build Stage:  CodeBuild                             │
│     │   ├─ Install Node.js runtime                          │
│     │   ├─ npm install                                      │
│     │   ├─ npm run build                                    │
│     │   └─ Create app-artifact.zip                          │
│     │   ↓ (artifact: app-artifact.zip)                      │
│     │   S3 Storage (aws-cicd-artifacts-xxx)                │
│     │   ↓                                                    │
│     ├─→ Deploy Stage: CodeDeploy                            │
│     │   ├─ BeforeInstall: Stop old app                      │
│     │   ├─ AfterInstall: Extract files, npm install        │
│     │   ├─ ApplicationStart: systemctl start nodejs-app     │
│     │   ├─ ApplicationStop: (on next deployment)            │
│     │   └─ ValidateService: Health check                    │
│     │       ↓                                                │
│     └─→ EC2 Instance (Running Node.js App) ✅              │
│         Port 3000 open for requests                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Troubleshooting

### Issue: Pipeline stuck at Source stage

**Cause:** GitHub webhook not connected  
**Solution:**
1. CodePipeline → Pipeline → Settings
2. Edit Connections
3. Authorize GitHub app

### Issue: Build stage failing

**Cause:** buildspec.yml syntax or missing files  
**Solution:**
1. Check CodeBuild project configuration
2. View CloudWatch logs: `/aws/codebuild/nodejs-app`
3. Verify buildspec.yml in repo root
4. Check buildspec.yml YAML syntax

### Issue: Deploy stage failing

**Cause:** CodeDeploy agent not running or appspec.yml issues  
**Solution:**
1. SSH into EC2
2. Check agent: `sudo systemctl status codedeploy-agent`
3. View logs: `sudo tail -n 50 /var/log/codedeploy-agent/deployment.log`
4. Verify appspec.yml in repo root
5. Ensure hook scripts are executable

### Issue: Application not accessible after deployment

**Cause:** Port 3000 not open or app not starting  
**Solution:**
1. Check security group: Allow TCP 3000
2. SSH into EC2 and test: `curl localhost:3000`
3. Check app logs: `journalctl -u nodejs-app`
4. Verify hooks are executable: `chmod +x hooks/*.sh`

---

## Validation Checklist ✅

Before declaring Day 7 complete:

- [ ] CodePipeline-Service-Role created with correct permissions
- [ ] CodePipeline `nodejs-devops-pipeline` created successfully
- [ ] Source stage configured with GitHub webhook
- [ ] Build stage added with CodeBuild project
- [ ] Deploy stage added with CodeDeploy application
- [ ] First pipeline run executed successfully
- [ ] All three stages show "Succeeded"
- [ ] Artifacts appear in S3 bucket
- [ ] Application deployed to EC2 and running
- [ ] Application accessible via public IP on port 3000
- [ ] Health endpoint returns HTTP 200
- [ ] Tested: Push to GitHub → Pipeline auto-triggers
- [ ] Deployment logs show all lifecycle events succeeded

**Pipeline Details to Save:**
```
Pipeline Name: nodejs-devops-pipeline
Service Role: CodePipeline-Service-Role
GitHub Repo: YOUR-USERNAME/aws-nodejs-devops
CodeBuild Project: nodejs-devops-app-build
CodeDeploy App: nodejs-devops-app
Deployment Group: nodejs-deployment-group
EC2 Instance IP: 54.123.45.67
App URL: http://54.123.45.67:3000
```

---

## 🎉 Bonus Tasks

### Add SNS Notifications

Notify yourself when pipeline succeeds/fails:

1. **SNS Console** → Create Topic
2. **Topic name:** `codepipeline-notifications`
3. **Create AWS Lambda** to send Slack/Email
4. **EventBridge Rule** to trigger on pipeline events
5. **Test:** Push code and receive notification!

### Add Manual Approval Step

Require human approval before deployment:

1. **CodePipeline** → Edit → Add stage
2. **Stage name:** `ManualApproval`
3. **Action provider:** Manual approval
4. **Position:** Before Deploy stage
5. **Approve/Reject** deployments manually

### Enable Automatic Rollbacks

Automatically rollback if deployment fails:

1. **CodeDeploy** → Application
2. **Deployment configuration:** Auto Rollback on Failure
3. **Failed deployments** will automatically revert

---

## 📸 Screenshots for LinkedIn

Capture these for your LinkedIn post:

1. ✅ CodePipeline showing all stages succeeded
2. ✅ CodeBuild logs showing "BUILD SUCCEEDED"
3. ✅ CodeDeploy logs showing "Deployment succeeded"
4. ✅ Browser showing deployed App with "Hello from deployed Node.js app!"
5. ✅ Curl response showing JSON response from API

---

## LinkedIn Post Template

```
🚀 Day 7 Complete: Full AWS CI/CD Pipeline!

Just built an end-to-end CI/CD pipeline with:
✅ CodePipeline - Orchestration
✅ CodeBuild - Automated builds
✅ CodeDeploy - Automated deployments
✅ GitHub - Source control
✅ S3 - Artifact storage
✅ EC2 - Application hosting

The Flow:
GitHub Push → CodePipeline → CodeBuild (npm install/build) 
→ S3 Artifact → CodeDeploy → EC2 (running Node.js app)

This is how enterprise teams automate deployments! 🎯

Total deployment time: ~3 minutes from push to live
Zero manual steps required ✨

#7DaysOfAWSWithTWS #AWS #DevOps #CI/CD #IaC
```

---

## 🎓 What You've Accomplished

Congratulations! You've successfully built a production-grade CI/CD pipeline:

1. **Automated Build Process** - CodeBuild compiles code automatically
2. **Artifact Management** - S3 stores deployable packages
3. **Automated Deployment** - CodeDeploy pushes to EC2 without manual intervention
4. **Health Validation** - Automatic health checks ensure app is running
5. **Complete Visibility** - CloudWatch logs track every step
6. **Triggered by Git** - Push code, pipeline runs automatically
7. **Scalable** - Same pipeline works for multiple deployments

You're now a **DevOps Engineer**! 🎉

---

**Questions?** Refer back to task guides or AWS documentation.

**Ready for more?** Try:
- Scaling to Auto Scaling Groups
- Deploying to Lambda
- Adding blue/green deployments
- Setting up disaster recovery
