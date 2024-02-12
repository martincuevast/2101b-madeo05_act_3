#!/bin/bash

# setup_nginx.sh

# Remove the default Nginx configuration file
sudo rm -f /etc/nginx/sites-enabled/default

# Create a new Nginx server block file
cat << EOF | sudo tee /etc/nginx/sites-available/nodejs_app
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable this Nginx server block by linking the file to the sites-enabled directory
sudo ln -s /etc/nginx/sites-available/nodejs_app /etc/nginx/sites-enabled/

# Test the Nginx configuration for syntax errors
sudo nginx -t

# Restart Nginx to make the changes take effect
sudo systemctl restart nginx
