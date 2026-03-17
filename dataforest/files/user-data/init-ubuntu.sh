#!/bin/bash
apt update -y
apt install nginx -y

rm /etc/nginx/sites-enabled/default
# Disable access log
sed -i -e "s/access_log.*/access_log off;/g" /etc/nginx/nginx.conf

cat<<EOF > /etc/nginx/sites-enabled/virtual.conf
  server {
    listen 8080;
    server_name "";
    access_log off;

    location / {
      root /usr/share/nginx/html/;
    }

    location /healthz {
      return 200 "Healthy";
    }

    location / {
      root /var/www/static/;
    }
  }
EOF

mkdir -p /var/www/static/
chown www-data:www-data /etc/nginx/sites-enabled /var/www/static/

systemctl enable nginx
systemctl reload-or-restart nginx

# Install AWS Session Manager Agent
sudo snap install amazon-ssm-agent --classic
sudo snap start --enable amazon-ssm-agent
