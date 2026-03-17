# 🏗️ AWS DevOps CI/CD Pipeline - Detailed Architecture

## Complete Pipeline Flow Diagram

```
                                    ┌────────────────────────────────────────┐
                                    │      GitHub Repository                 │
                                    │  (Source Code + buildspec.yml +        │
                                    │   appspec.yml)                         │
                                    └────────────┬─────────────────────────┘
                                                 │
                                                 ▼
                    ┌────────────────────────────────────────────────┐
                    │    AWS CodePipeline (Orchestrator)             │
                    │                                                │
                    │  ┌─────────────┐  ┌───────────┐  ┌─────────┐ │
                    │  │  Stage 1:   │  │ Stage 2:  │  │Stage 3: │ │
                    │  │  SOURCE     │─→│  BUILD    │─→│ DEPLOY  │ │
                    │  │             │  │           │  │         │ │
                    │  │ Triggers on │  │CodeBuild  │  │CodeDeploy
                    │  │code changes │  │           │  │         │ │
                    │  └─────────────┘  └──────┬────┘  └────┬────┘ │
                    │                           │            │      │
                    └────────────────────────────────────────────────┘
                                        │            │
                         ┌──────────────┼────────────┼──────────────┐
                         │              │            │              │
                         ▼              ▼            ▼              ▼
                    ┌─────────┐  ┌────────────┐ ┌─────────┐   ┌──────────┐
                    │ GitHub  │  │     S3     │ │ CodeBuild
                    │ Webhook │  │  Artifacts │ │ Logs    │   │  EC2     │
                    │         │  │  Storage   │ │(CloudW) │   │ Instance │
                    │(Pull)   │  │            │ │         │   │(Deploy)  │
                    └─────────┘  └────────────┘ └─────────┘   └──────────┘
                         ▲                                          ▲
                         │                                          │
                         └──────────────┬───────────────────────────┘
                                        │
                            Artifacts Flow & Deployment
```

---

## Detailed Stage Breakdown

### Stage 1: Source (GitHub)

```
GitHub Repository
├── main branch
│   ├── app.js                 ← Application code
│   ├── package.json          ← Dependencies
│   ├── buildspec.yml         ← Build instructions
│   └── appspec.yml           ← Deployment instructions
└── webhook (auto-trigger)    ← CodePipeline listens

When code is pushed:
  GitHub Webhook → CodePipeline (Detects change)
  CodePipeline → Pulls latest code → S3 temporary storage
```

### Stage 2: Build (CodeBuild)

```
                           CodeBuild Project
                                  │
                    ┌─────────────┴──────────────┐
                    │                            │
                    ▼                            ▼
            ┌──────────────────┐    ┌────────────────────┐
            │  Build Container │    │  Build Environment │
            │  (Docker image)  │    │  (Node.js runtime) │
            └────────┬─────────┘    └────────────────────┘
                     │
            Buildspec.yml instructions:
            ├── install: npm install
            ├── pre_build: (linting, tests)
            ├── build: npm run build
            ├── post_build: (package artifacts)
            └── artifacts: upload to S3
                     │
                     ▼
            ┌──────────────────────┐
            │   S3 Artifact Bucket │
            │                      │
            │ app-artifact.zip     │
            │ (Ready to deploy)    │
            └──────────────────────┘
                     │
                CloudWatch Logs
                ├── build progress
                └── error details
```

### Stage 3: Deploy (CodeDeploy)

```
                    CodeDeploy Agent (on EC2)
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
      ┌──────────────┐            ┌──────────────┐
      │ appspec.yml  │            │  Lifecycle   │
      │ (read from   │            │   Hooks      │
      │  S3 artifact)│            │              │
      └──────┬───────┘            └──────┬───────┘
             │                           │
     ┌───────┴───────┐                   │
     │               │                   │
     ▼               ▼                   ▼
  Retrieve       Move Files          Execute Scripts
  Artifact       to App Dir          │ BeforeInstall
  from S3        /opt/nodejs-app     │ AfterInstall
                                     │ ApplicationStart
                                     │ ValidateService
                                     │ ApplicationStop
                                     
              ┌─────────────────────────┐
              │   EC2 Instance Ready    │
              │   App running on port   │
              │   3000                  │
              └─────────────────────────┘
```

---

## AWS Service Architecture Diagram

```
                        VPC (Virtual Private Cloud)
    ┌────────────────────────────────────────────────────────┐
    │                                                        │
    │   Public Subnet (CodeDeploy Agent)                    │
    │  ┌──────────────────────────────────────────────┐   │
    │  │                                              │   │
    │  │  ┌──────────────┐  ┌──────────────────┐    │   │
    │  │  │   EC2 Instance       Node.js App │    │   │
    │  │  │               │  │   (Port 3000)  │    │   │
    │  │  │ CodeDeploy │  │                  │    │   │
    │  │  │   Agent    │  │  Security Group: │    │   │
    │  │  │            │  │  - Inbound:      │    │   │
    │  │  │ IAM Role:  │  │    22 (SSH)      │    │   │
    │  │  │ ec2-role   │  │    3000 (App)    │    │   │
    │  │  │ (S3, SSM)  │  │  - Outbound:     │    │   │
    │  │  │            │  │    443 (HTTPS)   │    │   │
    │  │  └────┬───────┘  └────────┬─────────┘    │   │
    │  │       │                   │              │   │
    │  │       │ (pulls artifact)   │              │   │
    │  │       └────────┬──────────┬──────────────┼───┼─→ Internet Gateway
    │  │                │          │              │   │
    │  └────────────────┼──────────┼──────────────┘   │
    │                   │          │                  │
    │                   ▼          ▼                  │
    │          ┌──────────────┐   ┌──────────────┐    │
    │          │   NAT        │   │  Route Table │    │
    │          │   Gateway    │   │              │    │
    │          └──────────────┘   └──────────────┘    │
    │                                                  │
    └───────────────────────┬────────────────────────┘
                            │
          ┌─────────────────┼──────────────────┐
          │                 │                  │
          ▼                 ▼                  ▼
      ┌────────┐      ┌──────────┐     ┌──────────────┐
      │   S3   │      │CodeBuild │     │ CodePipeline │
      │        │      │ Service  │     │  Service     │
      │Artifacts      │(Logs→CW) │     │              │
      │Storage │      │          │     │ (Orchestrates)
      └────────┘      └──────────┘     └──────────────┘
                            ▲                  ▲
                            │                  │
        ┌───────────────────┴──────────────────┴──────────┐
        │                                                  │
        │   IAM (Identity & Access Management)            │
        │                                                  │
        │  CodePipeline Role:                             │
        │  - Access: CodeBuild, CodeDeploy               │
        │  - Access: S3 (artifacts)                      │
        │                                                  │
        │  CodeBuild Role:                                │
        │  - Access: S3 (source, artifacts)             │
        │  - Access: CloudWatch (logs)                  │
        │                                                  │
        │  CodeDeploy Role:                               │
        │  - Access: EC2 tags                            │
        │  - Access: S3 (artifacts)                      │
        │                                                  │
        │  EC2 Instance Role:                             │
        │  - Access: S3 (pull artifacts)                │
        │  - Access: SSM (parameters)                   │
        │  - Access: CloudWatch (logs)                  │
        │                                                  │
        └──────────────────────────────────────────────────┘
```

---

## Data Flow Across Pipeline Stages

```
Timeline: Code Push → Build → Deploy → Live

T=0s    ┌─────────────────────────────────────────────────┐
        │  Developer Pushes Code to GitHub                │
        │  git push origin main                           │
        └────────────┬──────────────────────────────────┘
                     │
T=1s    ┌────────────▼──────────────────────────────────┐
        │  GitHub Webhook Triggers CodePipeline         │
        │  Pipeline retrieves latest source code        │
        │  Source stored in S3 (temp location)          │
        └────────────┬──────────────────────────────────┘
                     │
T=5s    ┌────────────▼──────────────────────────────────┐
        │  CodeBuild Stage Starts                       │
        │  - Pulls code from S3                         │
        │  - Runs buildspec.yml                         │
        │  - npm install, npm run build                 │
        │  - Creates app-artifact.zip                   │
        └────────────┬──────────────────────────────────┘
                     │
T=30s   ┌────────────▼──────────────────────────────────┐
        │  Build Complete, Artifact Uploaded to S3      │
        │  CloudWatch Logs show:                        │
        │  "BUILD SUCCEEDED"                             │
        └────────────┬──────────────────────────────────┘
                     │
T=35s   ┌────────────▼──────────────────────────────────┐
        │  CodeDeploy Stage Starts                      │
        │  - CodeDeploy agent on EC2 notices task       │
        │  - Pulls artifact from S3                     │
        │  - Extracts to /opt/nodejs-app               │
        └────────────┬──────────────────────────────────┘
                     │
T=40s   ┌────────────▼──────────────────────────────────┐
        │  Lifecycle Hooks Execute (appspec.yml)        │
        │  - BeforeInstall: stop previous app           │
        │  - AfterInstall: npm install dependencies    │
        │  - ApplicationStart: start Node.js app        │
        │  - ValidateService: health check              │
        └────────────┬──────────────────────────────────┘
                     │
T=45s   ┌────────────▼──────────────────────────────────┐
        │  Deployment Complete ✅                        │
        │  Application accessible at:                   │
        │  http://<EC2-PublicIP>:3000                  │
        └───────────────────────────────────────────────┘
```

---

## CodeBuild Buildspec.yml Execution Flow

```
buildspec.yml
      │
      ├─ version: 0.2
      │
      ├─ phases:
      │  │
      │  ├─ install:        ← Setup build environment
      │  │  └─ runtime-versions:
      │  │     └─ nodejs: 18     ← Install Node.js 18
      │  │
      │  ├─ pre_build:      ← Run before build
      │  │  ├─ npm install     ← Install dependencies
      │  │  └─ npm run test    ← Run tests
      │  │
      │  ├─ build:          ← Main build step
      │  │  └─ npm run build   ← Create deployable artifacts
      │  │
      │  └─ post_build:     ← Run after build (on success)
      │     └─ echo "Build Completed"
      │
      ├─ artifacts:        ← What to save
      │  ├─ files:
      │  │  ├─ app.js
      │  │  ├─ node_modules/**/*
      │  │  └─ package.json
      │  └─ name: app-artifact.zip
      │
      └─ cache:            ← Cache for speed
         └─ paths:
            └─ node_modules/**/*
```

---

## CodeDeploy appspec.yml Execution Flow

```
appspec.yml
      │
      ├─ version: 0.0
      │
      ├─ Resources:
      │  └─ ec2instances:
      │        └─ ["i-1234567890abcdef0"]  ← Target EC2
      │
      ├─ Files:              ← Where to extract
      │  └─ source: /
      │     destination: /opt/nodejs-app
      │
      └─ Hooks:              ← Execution sequence
         │
         ├─ BeforeInstall:   (phase 1)
         │  └─ run commands to cleanup
         │
         ├─ AfterInstall:    (phase 2)
         │  ├─ run npm install
         │  └─ set permissions
         │
         ├─ ApplicationStart: (phase 3)
         │  ├─ start systemd service
         │  └─ App starts listening on 3000
         │
         ├─ ApplicationStop:  (before update)
         │  └─ gracefully stop running app
         │
         └─ ValidateService: (final check)
            └─ curl http://localhost:3000
               verify app is responding
```

---

## IAM Permission Hierarchy

```
Root Account
│
├─ CodePipeline Execution Role
│  ├─ codepipeline:GetPipeline
│  ├─ codebuild:BatchGetBuilds
│  ├─ codedeploy:CreateDeployment
│  └─ s3:GetObject, PutObject
│
├─ CodeBuild Service Role
│  ├─ logs:CreateLogGroup
│  ├─ logs:CreateLogStream
│  ├─ logs:PutLogEvents
│  ├─ s3:GetObject
│  └─ s3:PutObject
│
├─ CodeDeploy Service Role
│  ├─ ec2:DescribeInstances
│  ├─ ec2:DescribeInstanceStatus
│  ├─ autoscaling:*
│  └─ tag:GetResources
│
└─ EC2 Instance Profile
   └─ EC2 Instance Role
      ├─ s3:GetObject (read artifacts)
      ├─ ssm:GetParameter (secrets)
      ├─ logs:PutLogEvents (send logs)
      └─ ec2:DescribeInstances
```

---

## Artifact Journey Through Pipeline

```
Source Code (GitHub)
        │
        │ CodePipeline copies
        ▼
   S3 Artifact Store (Source Location)
        │
        │ CodeBuild reads
        ├──────────────────────┐
        │                      │
        │ build & package      │
        │                      │
        │ creates new artifact │
        ▼                      │
   S3 Artifact Store (Build Location)
        │
        │ CodeDeploy reads
        ├──────────────────────┐
        │                      │
        │ extracts files       │
        │ /opt/nodejs-app      │
        │                      │
        │ runs lifecycle hooks │
        ▼                      │
   EC2 Instance Running App
        │
        │ Users access
        ▼
   Live Application ✅
```

---

## Security & Best Practices Architecture

```
┌──────────────────────────────────────────────────────────┐
│              Security Layers                             │
└──────────────────────────────────────────────────────────┘

Layer 1: Source Control
├─ GitHub protected branches
├─ Require code reviews (PRs)
└─ Enforce branch policies

Layer 2: Build Security
├─ CodeBuild runs in isolated Docker containers
├─ Secrets NOT stored in buildspec.yml
├─ Use AWS Secrets Manager or Parameter Store
└─ Build artifacts signed

Layer 3: Artifact Storage
├─ S3 bucket versioning enabled
├─ S3 bucket encryption (KMS)
├─ Private bucket (Block All Public Access)
└─ MFA Delete protection

Layer 4: Deployment Security
├─ CodeDeploy validates artifacts before deploying
├─ EC2 in private subnet with NAT gateway
├─ Security groups restrict traffic
└─ IAM roles follow least privilege

Layer 5: Application Security
├─ Application logs sent to CloudWatch
├─ Failed deployments trigger rollback
├─ Health checks validate app status
└─ Monitoring alerts on failures
```

---

## Monitoring & Observability Architecture

```
Pipeline Events
      │
      ├── CodePipeline State Changes
      │   └─ SUCCESS / FAILED
      │
      ├── CodeBuild Logs
      │   └─ CloudWatch Logs Group: /aws/codebuild/your-project
      │      ├─ Build progress
      │      ├─ Error messages
      │      └─ Artifact upload status
      │
      ├── CodeDeploy Logs
      │   └─ CodeDeploy Console or CloudWatch
      │      ├─ Agent activity
      │      ├─ Lifecycle hook output
      │      └─ Deployment status
      │
      └── EC2 Application Logs
          └─ CloudWatch Logs (application sends)
             ├─ HTTP requests
             ├─ Errors
             └─ Performance metrics
               
                     │
                     ▼
              CloudWatch Dashboard
              ├─ Pipeline success rate
              ├─ Build times
              ├─ Deployment frequency
              └─ Application health

                     │
                     ▼
              SNS / Slack Notifications
              ├─ Pipeline failed → Alert
              ├─ Build succeeded → Notification
              └─ Deployment complete → Confirmation
```

---

This architecture ensures:
✅ **Automated**: Code push triggers entire pipeline
✅ **Reliable**: Multiple safety checks and validations
✅ **Secure**: Least privilege IAM, encrypted artifacts
✅ **Observable**: Comprehensive logging and monitoring  
✅ **Fast**: Parallel builds, efficient deployments
