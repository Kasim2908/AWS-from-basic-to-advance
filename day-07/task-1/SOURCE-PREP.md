# Task 1: Prepare Source Code 📝

## Objective
Create a Node.js Express application with `buildspec.yml` for AWS CodeBuild integration.

---

## What You'll Learn
✅ Structure of a Node.js application for CI/CD
✅ How to write `buildspec.yml` for CodeBuild
✅ GitHub repository setup for pipeline triggers
✅ Best practices for build configurations

---

## Step-by-Step Guide

### Step 1: Create GitHub Repository

1. **Go to GitHub** → [github.com/new](https://github.com/new)

2. **Repository Details:**
   - Repository name: `aws-nodejs-devops`
   - Description: `Node.js app for AWS CI/CD Pipeline (Day 7 - 7 Days of AWS)`
   - Visibility: **Public** (if you want to showcase on LinkedIn)
   - Initialize with README.md: ✅ Check

3. **Create Repository** button

4. **Clone to your local machine:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/aws-nodejs-devops.git
   cd aws-nodejs-devops
   ```

### Step 2: Add Application Files

Copy these files into your repository:

**File 1: `app.js`**
```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from deployed Node.js app! 🚀',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production',
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    service: 'nodejs-app',
    status: 'running',
    server: `http://localhost:${PORT}`,
    memory: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB'
  });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path
  });
});

app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📍 Visit http://localhost:${PORT}`);
});

module.exports = app;
```

**File 2: `package.json`**
```json
{
  "name": "nodejs-devops-app",
  "version": "1.0.0",
  "description": "Simple Node.js Express app for AWS CI/CD Pipeline demonstration",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"No tests configured yet\"",
    "build": "echo \"Build complete\""
  },
  "keywords": ["nodejs", "express", "aws", "cicd"],
  "author": "DevOps Engineer",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

**File 3: `buildspec.yml`** (Most Important! 🔑)
```yaml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - echo "Installing dependencies..."
      - npm update -g npm

  pre_build:
    commands:
      - echo "Running tests..."
      - npm install

  build:
    commands:
      - echo "Building application..."
      - echo "Build started at $(date)"
      - npm run build
      - echo "Build completed at $(date)"

  post_build:
    commands:
      - echo "Preparing artifacts for deployment..."
      - echo "Application version:" $(node -e "console.log(require('./package.json').version)")

artifacts:
  files:
    - app.js
    - package.json
    - package-lock.json
    - node_modules/**/*
  name: app-artifact

cache:
  paths:
    - 'node_modules/**/*'

logs:
  cloudwatch:
    group-name: '/aws/codebuild/nodejs-app'
    stream-name: 'nodejs-app-build-logs'
```

**File 4: `.gitignore`**
```
node_modules/
package-lock.json
*.log
.DS_Store
dist/
build/
```

### Step 3: Test Locally (Optional but Recommended)

Before pushing to GitHub, test the app locally:

```bash
# Install dependencies
npm install

# Start the application
npm start

# Expected Output:
# ✅ Server running on port 3000
# 📍 Visit http://localhost:3000
```

Visit `http://localhost:3000` in your browser:
```json
{
  "message": "Hello from deployed Node.js app! 🚀",
  "timestamp": "2026-03-17T10:30:00.000Z",
  "environment": "production",
  "version": "1.0.0"
}
```

### Step 4: Commit and Push to GitHub

```bash
# Add all files
git add .

# Commit with message
git commit -m "feat: Initial Node.js app with buildspec for AWS CI/CD

- Express server with health check endpoints
- buildspec.yml configured for CodeBuild
- Package.json with proper dependencies
- Ready for AWS CodePipeline integration

Resolves Day 7 Task 1"

# Push to main branch
git push origin main
```

### Step 5: Enable GitHub Webhook for CodePipeline

We'll do this in Task 5 when creating the CodePipeline, but here's the overview:

1. Go to your GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: (will be provided by CodePipeline)
4. Content type: `application/json`
5. Events: Push events
6. Active: ✅ Check

---

## Buildspec.yml Explanation 🔍

### What is buildspec.yml?
It's a **build specification file** that tells CodeBuild exactly how to build your application.

### YAML Structure:

```yaml
version: 0.2
# ^ CodeBuild version (always 0.2)

phases:
  # Four phases of a build

  install:
    # Phase 1: Setup environment
    # Install runtimes, tools, dependencies
    runtime-versions:
      nodejs: 18
    # ^ Request Node.js 18 in the build environment

  pre_build:
    # Phase 2: Before main build
    # Run tests, security checks, etc.
    commands:
      - npm install
      # ^ Install npm packages

  build:
    # Phase 3: Main build
    # Compile, package, etc.
    commands:
      - npm run build
      # ^ Run build script from package.json

  post_build:
    # Phase 4: After build (if successful)
    # Final cleanup, notifications, etc.
    commands:
      - echo "Build finished"

artifacts:
  # What files CodeBuild should keep after build
  files:
    - app.js
    - package.json
    - node_modules/**/*
  # ^ Include all these in deployment package

  name: app-artifact
  # ^ Artifact name (will be zipped as app-artifact.zip)

cache:
  # Speed up builds by caching
  paths:
    - node_modules/**/*
  # ^ Cache node_modules so npm install is faster next time
```

### Build Phase Flow Diagram:

```
install phase (~10s)
    ↓
[Download Node.js runtime]
    ↓
pre_build phase (~5s)
    ↓
[npm install - download packages]
    ↓
build phase (~10s)
    ↓
[Run build commands]
    ↓
post_build phase (~2s)
    ↓
[Final commands if build succeeded]
    ↓
Artifact creation (~3s)
    ↓
[Zip files, upload to S3]
    ↓
COMPLETE ✅
```

---

## Troubleshooting

### Issue: `npm install` fails in CodeBuild

**Solution:** Ensure `package.json` is valid
```bash
npm install --dry-run  # Test locally first
```

### Issue: Buildspec YAML syntax error

**Solution:** Validate YAML syntax
- Use [yamllint.com](https://yamllint.com) online
- Check indentation (2 spaces, not tabs)
- No quotes needed for simple strings

### Issue: Large node_modules causing slow builds

**Solution:** Use caching in buildspec.yml
```yaml
cache:
  paths:
    - node_modules/**/*
```

### Issue: Build succeeds but artifacts are empty

**Solution:** Ensure files path is correct
```yaml
artifacts:
  files:
    - app.js            # ✅ Correct
    # NOT /app.js       # ❌ Wrong (not absolute path)
```

---

## Validation Checklist ✅

Before moving to Task 2:

- [ ] GitHub repository created and public
- [ ] `app.js` file added with Express server
- [ ] `package.json` added with dependencies
- [ ] `buildspec.yml` added with proper YAML syntax
- [ ] `.gitignore` created to exclude node_modules
- [ ] All files committed and pushed to GitHub
- [ ] Tested locally with `npm install && npm start`
- [ ] Application responds to `GET /health` endpoint
- [ ] GitHub repository URL is ready for CodePipeline

---

## 🎯 What's Next?

Once this is complete, proceed to [Task 2: Create S3 Bucket for Artifacts](../task-2/S3-SETUP.md) →

In Task 2, we'll create the S3 bucket where CodeBuild will store build artifacts for CodeDeploy to retrieve and deploy.
