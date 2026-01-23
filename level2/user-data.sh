#!/bin/bash
yum update -y
yum install -y nginx git
systemctl enable nginx
systemctl start nginx

rm -rf /usr/share/nginx/html/*
git clone https://github.com/gabrielecirulli/2048.git /usr/share/nginx/html

chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html
systemctl restart nginx
