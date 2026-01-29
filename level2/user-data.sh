set -eux
yum update -y
amazon-linux-extras install -y nginx1
systemctl enable nginx
systemctl start nginx
/*
rm -rf /usr/share/nginx/html/*
git clone https://github.com/gabrielecirulli/2048.git /usr/share/nginx/html
*/

cat <<EOF > /usr/share/nginx/html/index.html "Hello from instance ${INSTANCE_ID}"
Private IP: ${PRIVATE_IP}
EOF
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html
systemctl restart nginx
