# Task 2: Create S3 Bucket for Artifacts 🪣

## Objective
Create and configure an S3 bucket to store build artifacts from CodeBuild and deployment packages for CodeDeploy.

---

## What You'll Learn
✅ S3 bucket creation and configuration
✅ Enable versioning for artifact management
✅ S3 bucket policies and permissions
✅ Artifact storage best practices
✅ Cost optimization with lifecycle policies

---

## Step-by-Step Guide

### Step 1: Create S3 Bucket

1. **Open AWS Console** → S3 → [Create bucket](https://s3.console.aws.amazon.com/s3/bucket/create)

2. **Bucket name configuration:**
   - Name: `aws-cicd-artifacts-<your-account-id>` 
   - Example: `aws-cicd-artifacts-123456789012`
   - → **Must be globally unique!**

3. **Region:** Select your region (e.g., `us-east-1`)

4. **Block Public Access Settings:**
   ```
   ☑ Block all public access
   ☑ Block public access (user)
   ☑ Block public access (bucket policies)
   ☑ Ignore public ACL
   ☑ Restrict public bucket policy
   ```
   → Keep all checked for security! 🔒

5. **Click "Create bucket"**

### Step 2: Enable Versioning

**Why versioning?**
- Recover previous artifact versions
- Rollback failed deployments
- Audit trail of all artifacts

**Steps:**

1. **Go to bucket** → Select your newly created bucket
2. **Properties tab** → Scroll to "Versioning"
3. **Edit Versioning** → Select "Enable" → **Save changes**

```
Versioning Status: Enabled ✅
MFA Delete: Not configured (Optional)
```

### Step 3: Enable Server-Side Encryption

For security, encrypt artifacts at rest:

1. **Properties tab** → "Default encryption"
2. **Edit Default encryption**
   - Encryption type: **Amazon S3-managed keys (SSE-S3)** ✅
   - Or: **AWS Key Management Service (KMS)** for more control
   - **Save changes**

### Step 4: Create Folder Structure

Organize artifacts:

1. **Objects tab** → **Create folder**

**Create these folders:**
```
aws-cicd-artifacts/
├── source/                    # Source code from GitHub
├── builds/                    # Build artifacts from CodeBuild
│   ├── app-artifact.zip
│   ├── logs/
│   └── ...
└── deploys/                   # Deployment records
    ├── deployment-archives/
    └── logs/
```

To create folders in S3:
1. Click **Create folder** button
2. Name: `source`
3. Click **Create folder** button again
4. Name: `builds`
5. Name: `deploys`

### Step 5: Configure IAM Permissions

Create a bucket policy for CodePipeline, CodeBuild, and CodeDeploy:

1. **Bucket policy tab** → **Edit**

2. **Copy this policy** (replace `YOUR-BUCKET-NAME`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodePipelineAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
    },
    {
      "Sid": "CodeBuildAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/builds/*"
    },
    {
      "Sid": "CodeDeployAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/builds/*"
    }
  ]
}
```

3. **Replace** `YOUR-BUCKET-NAME` with your actual bucket name
4. **Save changes**

### Step 6: Configure Lifecycle Policy (Optional but Recommended)

Automatically delete old artifacts to save costs:

1. **Management tab** → **Create lifecycle rule**

2. **Rule configuration:**
   - Rule name: `DeleteOldArtifacts`
   - Apply to: All objects in bucket

3. **Actions:**
   - Check: ✅ "Expire objects"
   - Expire after: **30 days** (adjustable to your needs)
   - Check: ✅ "Delete expired object delete markers"

4. **Create rule**

### Step 7: Enable Access Logging (Optional)

For audit trails:

1. **Properties tab** → "Server access logging"
2. **Edit** → Enable logging
3. Target bucket: Select same bucket
4. Target prefix: `logs/access-logs/`

---

## S3 Bucket Architecture

```
S3 Bucket: aws-cicd-artifacts-123456789012
│
├── 🔐 Encryption: SSE-S3
├── 📌 Versioning: Enabled
├── 🗑️ Lifecycle: 30-day expiration
├── 🔒 Public Access: Blocked
│
└── Folder Structure:
    ├── source/
    │   └── <timestamp>-repo-archive.zip
    │
    ├── builds/
    │   ├── 2026-03-17T10-30-00/
    │   │   ├── app-artifact.zip
    │   │   ├── buildspec.yml
    │   │   └── build-logs.txt
    │   │
    │   └── 2026-03-17T11-00-00/
    │       ├── app-artifact.zip
    │       └── ...
    │
    └── deploys/
        └── deployment-archives/
            └── <deployment-id>.zip
```

---

## Connection Diagram

```
GitHub Repository
        │
        ▼
   CodePipeline
        │
        ├──────────────────┬──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
    source/            builds/            deploys/
    repo.zip        app-artifact.zip    deployment.zip
        │                  │                  │
        ├─ CodeBuild ──────┤                  │
        │                  ▼                  │
        │            CodeDeploy ─────────────┘
        │                  │
        └──────────────────┼──────────────────┐
                           │                  │
                         EC2                  │
                         App             CloudWatch
                                          Logs
```

---

## Testing the S3 Bucket

### Test 1: Verify Bucket Access

```bash
# List bucket contents
aws s3 ls s3://aws-cicd-artifacts-123456789012/

# Upload a test file
echo "Test artifact" > test-artifact.txt
aws s3 cp test-artifact.txt s3://aws-cicd-artifacts-123456789012/test-artifact.txt

# Verify upload
aws s3 ls s3://aws-cicd-artifacts-123456789012/test-artifact.txt

# Check versioning (list all versions)
aws s3api list-object-versions \
  --bucket aws-cicd-artifacts-123456789012
```

### Test 2: Verify Encryption

```bash
# Check default encryption
aws s3api get-bucket-encryption \
  --bucket aws-cicd-artifacts-123456789012

# Output should show SSE-S3
```

### Test 3: Verify Versioning

```bash
# Check versioning status
aws s3api get-bucket-versioning \
  --bucket aws-cicd-artifacts-123456789012

# Output should show: "Status": "Enabled"
```

---

## Cost Estimation

**S3 Pricing** (as of March 2026):

| Operation | Cost | Estimate |
|-----------|------|----------|
| Storage (per GB/month) | $0.023 | 100 artifacts × 50MB × $0.023 = ~$0.12/month |
| PUT requests (per 1000) | $0.005 | 100 uploads × $0.005 = $0.50/month |
| GET requests (per 1000) | $0.0004 | 100 downloads × $0.0004 = $0.04/month |
| **Total** | | **~$0.66/month** |

→ Very cheap! Versioning adds minimal cost.

---

## Security Best Practices ✅

- [x] Block all public access
- [x] Enable versioning for rollback
- [x] Enable encryption (SSE-S3)
- [x] Restrict IAM permissions to minimum needed
- [x] Enable access logging for audit
- [x] Use lifecycle policies to delete old artifacts
- [x] Enable MFA delete for critical buckets (optional)

---

## Troubleshooting

### Issue: "Bucket name already taken"
**Solution:** S3 bucket names are globally unique. Add account ID to name:
```
aws-cicd-artifacts-123456789012-v2
```

### Issue: "Access Denied" when uploading
**Solution:** Check bucket policy. Ensure your IAM user/role is in the policy.

### Issue: Version history not showing
**Solution:** Versioning might not be enabled. Re-check:
```bash
aws s3api get-bucket-versioning --bucket YOUR-BUCKET-NAME
```

---

## Validation Checklist ✅

Before moving to Task 3:

- [ ] S3 bucket created with naming convention
- [ ] Versioning enabled
- [ ] Server-side encryption enabled (SSE-S3)
- [ ] Public access blocked
- [ ] Bucket policy configured (replaced YOUR-BUCKET-NAME)
- [ ] Folder structure created (source/, builds/, deploys/)
- [ ] Lifecycle policy configured (optional)
- [ ] Test file uploaded successfully
- [ ] Bucket name and region noted for next tasks

**Save these details:**
```
Bucket Name: aws-cicd-artifacts-123456789012
Region: us-east-1
ARN: arn:aws:s3:::aws-cicd-artifacts-123456789012
```

---

## 🎯 What's Next?

Proceed to [Task 3: Create CodeBuild Project](../task-3/CODEBUILD-SETUP.md) →

In Task 3, we'll create a CodeBuild project that:
1. Retrieves source from GitHub
2. Builds using the buildspec.yml
3. Stores artifacts in this S3 bucket
