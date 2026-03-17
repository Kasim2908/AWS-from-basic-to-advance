# Task 3: Create CodeBuild Project 🔨

## Objective
Set up an AWS CodeBuild project that automatically builds your Node.js application using the buildspec.yml file.

---

## What You'll Learn
✅ CodeBuild project creation
✅ Build environment configuration
✅ Source repository integration (GitHub)
✅ Build artifact output configuration
✅ CloudWatch Logs integration
✅ Build execution and debugging

---

## Prerequisites

Before starting, ensure you have:
- ✅ GitHub repository with buildspec.yml ([Task 1](../task-1/SOURCE-PREP.md))
- ✅ S3 bucket for artifacts ([Task 2](../task-2/S3-SETUP.md))
- ✅ GitHub personal access token (PAT)

### Generate GitHub Personal Access Token

1. **Go to GitHub** → Settings → [Developer settings](https://github.com/settings/apps) → Personal access tokens → Tokens (classic)
2. **Generate new token**
   - Token name: `AWS-CodeBuild-Token`
   - Expiration: 90 days (or as needed)
   - Scopes:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `admin:repo_hook` (Full control of repository hooks)
3. **Generate token** and **copy it immediately** (you won't see it again!)

---

## Step-by-Step Guide

### Step 1: Create CodeBuild Service Role

CodeBuild needs IAM permissions to pull from GitHub, store artifacts, and write logs.

1. **Open AWS Console** → IAM → Roles → **Create role**

2. **Select trusted entity:**
   - Trusted entity type: **AWS service**
   - Service: **CodeBuild**
   - Click **Next**

3. **Add permissions:**
   - Search for: `AWSCodeBuildAdminAccess`
   - ✅ Check it
   - Click **Next**

4. **Role name:**
   - `CodeBuild-Service-Role`
   - Click **Create role**

5. **Add S3 permissions:**
   - Go back to the role
   - **Add inline policy**
   - Select **JSON** editor
   - Paste this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::aws-cicd-artifacts-123456789012/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
    }
  ]
}
```

   - Replace `aws-cicd-artifacts-123456789012` with your bucket name
   - Click **Create policy**

### Step 2: Create CodeBuild Project

1. **Open AWS Console** → Developer Tools → [CodeBuild](https://console.aws.amazon.com/codesuite/codebuild) → **Create build project**

2. **Project configuration:**
   - Project name: `nodejs-devops-app-build`
   - Description: `CodeBuild project for Node.js CI/CD pipeline`
   - Artifacts: Select existing artifacts and cache settings

3. **Source:**
   - Source provider: **GitHub**
   - Repository: **Repository in my GitHub account**
   - GitHub repository: Paste your repo URL
     ```
     https://github.com/YOUR-USERNAME/aws-nodejs-devops
     ```

4. **Primary source webhook events:**
   - ✅ Check: **Rebuild every time a code change is pushed to this repository**
   - Events: **PUSH**

5. **Environment:**
   - Managed image: **Amazon Linux 2**
   - Operating system: **Amazon Linux 2**
   - Runtime: **Standard**
   - Image: **aws/codebuild/amazonlinux2-x86_64-standard:5.0** (or latest)
   - Image version: **Always use the latest image for this runtime version**
   - Environment type: **Linux**
   - Privileged: ⚠️ Leave **unchecked** (unless you need Docker)

6. **Service role:**
   - Role ARN: Select **CodeBuild-Service-Role** (created in Step 1)

7. **Build specifications:**
   - Build specifications: **Use a buildspec file**
   - Buildspec name: **buildspec.yml** (default)

8. **Artifacts:**
   - Artifact type: **Amazon S3**
   - Bucket name: `aws-cicd-artifacts-123456789012`
   - Artifacts path: `builds/`
   - Name: `app-artifact`
   - Enable semantic versioning: **Check**

9. **Logs:**
   - CloudWatch logs:
     - ✅ Check: **CloudWatch logs**
     - Group name: `/aws/codebuild/nodejs-app`
     - Stream name prefix: `build-`

10. **Click "Create build project"**

---

## Configuration Summary

```
Project Configuration:
├── Name: nodejs-devops-app-build
├── Source:
│   ├── Provider: GitHub
│   ├── Repository: YOUR-GITHUB-REPO
│   └── Webhook: Enabled (auto-trigger on push)
│
├── Environment:
│   ├── Image: amazonlinux2-x86_64-standard:5.0
│   ├── Runtime: Standard
│   └── Service Role: CodeBuild-Service-Role
│
├── Build:
│   ├── Source: buildspec.yml
│   └── Phases: install, pre_build, build, post_build
│
├── Artifacts:
│   ├── S3 Bucket: aws-cicd-artifacts-123456789012
│   ├── Path: builds/
│   └── Name: app-artifact
│
└── Logs:
    ├── CloudWatch: Enabled
    └── Group: /aws/codebuild/nodejs-app
```

---

## Step 3: Test the CodeBuild Project

### Method 1: Manual Build (Recommended for Testing)

1. **Go to CodeBuild** → CodeBuild projects → `nodejs-devops-app-build`

2. **Click "Start build"**

3. **Build configuration:**
   - Source version: **main** (or your default branch)
   - Click **Start build**

4. **Monitor the build:**
   - Watch the **Build log** tab
   - Expected output:
     ```
     [INFO] Installing dependencies...
     [INFO] Running tests...
     added 51 packages in 15s
     [INFO] Building application...
     [INFO] Build started at Tue Mar 17 10:30:00 UTC 2026
     [INFO] Build complete
     [INFO] Build completed at Tue Mar 17 10:30:15 UTC 2026
     [INFO] Preparing artifacts for deployment...
     [INFO] Application version: 1.0.0
     BUILD SUCCEEDED
     ```

5. **Verify artifacts:**
   - Go to S3 bucket → `builds/` folder
   - Should see `app-artifact.zip` (with timestamp)

### Method 2: Automatic Build (via GitHub Push)

1. **Make a change to your repository:**
   ```bash
   cd aws-nodejs-devops
   echo "# Updated version" >> README.md
   git add .
   git commit -m "test: Trigger CodeBuild pipeline"
   git push origin main
   ```

2. **CodeBuild auto-triggers:**
   - Go to CodeBuild → nodejs-devops-app-build
   - Build history should show a new build

3. **Monitor build progress** in Build log

---

## Build Phases Explanation

```
Phase 1: INSTALL (CodeBuild environment setup)
├─ Download Node.js runtime (v18)
├─ Update npm to latest version
└─ Time: ~10 seconds

Phase 2: PRE_BUILD (Before main build)
├─ npm install (download dependencies)
├─ Run tests (if configured)
└─ Time: ~15 seconds

Phase 3: BUILD (Main build)
├─ npm run build
├─ Compile/package application
└─ Time: ~10 seconds

Phase 4: POST_BUILD (After successful build)
├─ Final commands
├─ Log application version
└─ Time: ~5 seconds

Phase 5: ARTIFACT (Automatic)
├─ Collect files from artifacts section
├─ Create app-artifact.zip
├─ Upload to S3 (builds/)
└─ Time: ~5-10 seconds

Total Build Time: ~45-55 seconds
```

---

## Monitoring CodeBuild

### CloudWatch Logs

```bash
# View logs from terminal
aws logs tail /aws/codebuild/nodejs-app --follow

# Or view in AWS Console
CloudWatch → Logs groups → /aws/codebuild/nodejs-app
                          → build-...
```

### Build History Dashboard

```
CodeBuild → Build project → nodejs-devops-app-build
            ↓
            Build history
            ├─ 2026-03-17 11:00:00 - SUCCEEDED (45s) ✅
            ├─ 2026-03-17 10:30:00 - SUCCEEDED (48s) ✅
            └─ 2026-03-17 10:15:00 - FAILED (25s) ❌
```

---

## Troubleshooting

### Issue: Build fails with "npm ERR! 404"

**Cause:** Package not found in npm registry  
**Solution:**
1. Check package name in package.json
2. Verify internet connection in buildspec.yml
3. Add npm cache clear: `npm cache clean --force`

### Issue: "buildspec.yml not found"

**Cause:** Buildspec.yml not in repository root  
**Solution:**
1. Ensure buildspec.yml is in GitHub repo root
2. Push to GitHub: `git push origin main`
3. Rebuild CodeBuild project

### Issue: S3 "Access Denied" when storing artifacts

**Cause:** IAM role doesn't have S3 permissions  
**Solution:**
1. Check role: CodeBuild-Service-Role
2. Verify S3 policy is attached
3. Verify bucket name matches in policy

### Issue: Build succeeds but artifacts are empty

**Cause:** Artifacts section in buildspec.yml might be wrong  
**Solution:**
1. Check file paths in artifacts:
   ```yaml
   artifacts:
     files:
       - app.js        # ✅ Correct
       - node_modules/**/*
   ```
2. Verify files exist after build

### Issue: Build takes too long

**Cause:** npm install downloads large packages each time  
**Solution:**
1. Enable caching in buildspec.yml:
   ```yaml
   cache:
     paths:
       - 'node_modules/**/*'
   ```
2. CodeBuild will cache between builds

---

## Build Cost Estimation

**CodeBuild pricing** (as of March 2026):

| Metric | Rate | Example |
|--------|------|---------|
| Build minutes | $0.005/minute | 50 builds × 50 min = $12.50/month |
| S3 storage | $0.023/GB | 100 artifacts × 50MB = $0.12/month |
| **Total** | | **~$12.62/month** |

→ Very affordable for development!

---

## Validation Checklist ✅

Before moving to Task 4:

- [ ] CodeBuild-Service-Role created with S3 permissions
- [ ] CodeBuild project `nodejs-devops-app-build` created
- [ ] Source: GitHub repository connected
- [ ] Webhook: Enabled for auto-trigger
- [ ] Environment: Amazon Linux 2 with Node.js selected
- [ ] Service role: CodeBuild-Service-Role assigned
- [ ] Build specifications: buildspec.yml
- [ ] Artifacts: S3 bucket and path configured
- [ ] CloudWatch Logs: Enabled and group created
- [ ] Manual build test: Completed successfully
- [ ] Artifacts: Visible in S3 bucket (builds/)
- [ ] Build succeeded message visible in logs

**Save these details:**
```
Project Name: nodejs-devops-app-build
ARN: arn:aws:codebuild:us-east-1:123456789012:project/nodejs-devops-app-build
S3 Artifacts: s3://aws-cicd-artifacts-123456789012/builds/
CloudWatch Logs: /aws/codebuild/nodejs-app
```

---

## 🎯 What's Next?

Proceed to [Task 4: Configure CodeDeploy](../task-4/CODEDEPLOY-SETUP.md) →

In Task 4, we'll:
1. Launch an EC2 instance
2. Install CodeDeploy agent
3. Create appspec.yml for deployment steps
4. Configure EC2 to receive deployments
