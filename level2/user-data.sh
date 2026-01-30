#!/bin/bash
set -eux
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx
/*
rm-rf /usr/sharenginx/html/
git clone https://github.com/gabrielecirulli/2048.git /use/share/nginx/html
*/
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>EC2 Instance</title>
</head>
<body>
  <h1>Hello from instance $INSTANCE_ID</h1>
</body>
</html>
EOF
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html
systemctl restart nginx

