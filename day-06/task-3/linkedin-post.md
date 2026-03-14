# Task 3: Route 53 – LinkedIn Blog Post

---

## LinkedIn Post

🌍 **How Does the Internet Know Where to Find Your Website? Meet Amazon Route 53!**

Ever wondered what happens when you type `www.example.com` in your browser?
It doesn't magically find your server — there's a whole system behind it. That system is **DNS**, and AWS's implementation is **Amazon Route 53**. 🚀

---

### 🔍 How DNS Resolution Works (Step by Step)

```
User types www.example.com
        │
        ▼
  [ISP DNS Resolver]  ← checks its cache first
        │
        ▼
  [Root Name Server]  ← knows who handles .com
        │
        ▼
  [TLD Name Server]   ← knows who handles example.com
        │
        ▼
  [Route 53]          ← returns the IP address (e.g., 54.23.11.5)
        │
        ▼
  [Your Server]       ← EC2 / ALB / CloudFront / S3
        │
        ▼
  Browser loads the page ✅
```

---

### 🧩 What Makes Route 53 Special?

**1. Routing Policies** — Route 53 isn't just a DNS lookup table. It's intelligent:

| Policy | Use Case |
|--------|----------|
| Simple | Single resource (one EC2, one S3) |
| Weighted | A/B testing — send 80% to v1, 20% to v2 |
| Latency | Route users to the nearest AWS region |
| Failover | Primary/secondary — auto-switch on failure |
| Geolocation | Serve different content by country |

**2. Health Checks** — Route 53 monitors your endpoints. If your EC2 goes down, it automatically routes traffic to a healthy backup. No manual intervention needed.

**3. Alias Records** — Unlike standard DNS, Route 53 Alias records let you point a domain directly to AWS resources (ALB, CloudFront, S3) — even at the zone apex (`example.com`, not just `www.example.com`).

---

### 🏗️ Real-World Example

Imagine you run an e-commerce site:
- `example.com` → CloudFront (CDN for static assets)
- `api.example.com` → Application Load Balancer → ECS containers
- `db.example.com` → RDS (internal, private hosted zone)

Route 53 manages all of this under one roof, with health checks ensuring zero-downtime failover.

---

### 💡 Key Takeaway

Route 53 = DNS + Health Checks + Intelligent Routing + AWS Integration

It's the glue that connects your domain name to your entire AWS infrastructure — reliably, at global scale.

---

🔗 Day 6 of my **#7DaysOfAWS** journey with **#AWSwithTWS**!
Today I explored ECS, ECR, CloudFront, and Route 53 — the full stack of containerization + networking on AWS.

Tag: @TrainWithShubham

#7DaysOfAWS #AWSwithTWS #AWS #CloudComputing #Route53 #DevOps #CloudFront #ECS #ECR #DNS
