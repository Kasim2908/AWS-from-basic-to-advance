#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Day 6 – CloudFront Demo</title></head>
<body>
  <h1>Hello from EC2 via CloudFront!</h1>
  <p>Origin: EC2 Apache Web Server</p>
</body>
</html>
EOF
