# Task 2: CloudFront Distribution with EC2 Apache Origin

## Architecture
```
User → CloudFront Edge Location → EC2 (Apache) Origin
```

---

## Step 1: Launch EC2 with Apache

1. Go to **EC2 → Launch Instance**
2. AMI: Amazon Linux 2023
3. Instance type: `t2.micro`
4. Security Group — allow inbound:
   - Port 80 (HTTP) from `0.0.0.0/0`
   - Port 22 (SSH) from your IP
5. Under **Advanced Details → User data**, paste contents of `ec2-user-data.sh`
6. Launch and note the **Public IPv4 DNS** (e.g., `ec2-xx-xx-xx-xx.compute-1.amazonaws.com`)

---

## Step 2: Create CloudFront Distribution

1. Go to **CloudFront → Create Distribution**
2. **Origin domain**: paste the EC2 Public DNS (e.g., `ec2-xx-xx-xx-xx.compute-1.amazonaws.com`)
3. **Protocol**: HTTP only
4. **Default cache behavior**:
   - Viewer protocol policy: `Redirect HTTP to HTTPS`
   - Cache policy: `CachingOptimized`
5. Click **Create Distribution**
6. Wait ~5 minutes for deployment (Status: `Enabled`)

---

## Step 3: Test the Distribution

```bash
# Get your CloudFront domain from the console, then:
curl https://<CLOUDFRONT_DOMAIN>/

# Compare response time — CloudFront vs direct EC2
curl -o /dev/null -s -w "CloudFront time: %{time_total}s\n" https://<CLOUDFRONT_DOMAIN>/
curl -o /dev/null -s -w "EC2 direct time: %{time_total}s\n" http://<EC2_PUBLIC_DNS>/
```

---

## How Caching Works

| Request | What Happens |
|---------|-------------|
| First request | CloudFront fetches from EC2 (cache MISS), stores at edge |
| Subsequent requests | CloudFront serves from edge cache (cache HIT) — faster! |
| After TTL expires | CloudFront re-fetches from EC2 origin |

- Default TTL: **86400 seconds (24 hours)**
- Cache HIT reduces latency and EC2 load significantly

---

## Key Concepts

- **Edge Location**: AWS data center closest to the user that caches content
- **Origin**: Your EC2 instance — the source of truth
- **Cache-Control headers**: Set on EC2 responses to control TTL at edge
- **Invalidation**: Force CloudFront to clear cache — `aws cloudfront create-invalidation --distribution-id <ID> --paths "/*"`
