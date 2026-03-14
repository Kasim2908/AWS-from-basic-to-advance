# Day 6 – ECS, ECR, Route 53 & CloudFront

## Tasks

| Task | Description | Files |
|------|-------------|-------|
| Task 1 | Deploy Two-Tier Flask App with ECS & ECR | `task-1/` |
| Task 2 | CloudFront Distribution with EC2 Apache | `task-2/` |
| Task 3 | Route 53 Blog Post | `task-3/` |

---

## Task 1: ECS + ECR

**Architecture**: `User → ALB → ECS Fargate (Flask) → RDS MySQL`

Reuses the Flask app from Day 4, containerized with Docker and deployed via ECS Fargate.

Key files:
- `task-1/flask-app/Dockerfile` — container definition
- `task-1/ecs-task-definition.json` — Fargate task config
- `task-1/deployment-guide.md` — full step-by-step guide

---

## Task 2: CloudFront + EC2

**Architecture**: `User → CloudFront Edge → EC2 Apache Origin`

Demonstrates CDN caching — first request hits EC2, subsequent requests are served from the nearest edge location.

Key files:
- `task-2/ec2-user-data.sh` — bootstraps Apache on EC2
- `task-2/cloudfront-setup.md` — setup guide + caching explanation

---

## Task 3: Route 53 Blog

Covers DNS resolution flow, Route 53 routing policies (Simple, Weighted, Latency, Failover, Geolocation), health checks, and Alias records.

- `task-3/linkedin-post.md` — ready-to-publish LinkedIn post with ASCII diagram
