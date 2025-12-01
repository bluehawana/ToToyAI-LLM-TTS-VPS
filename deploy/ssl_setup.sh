#!/bin/bash
# SSL Setup Script for sagatoy.com
# This script will:
# 1. Secure the VPS
# 2. Install and configure Nginx
# 3. Set up SSL certificates with Let's Encrypt
# 4. Configure automatic renewal

set -e

echo "=== Starting SSL Setup for sagatoy.com ==="

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y nginx certbot python3-certbot-nginx ufw fail2ban

# Configure firewall
echo "Configuring firewall..."
sudo ufw --force enable
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw status

# Remove Apache if present (to avoid conflicts)
if systemctl is-active --quiet apache2; then
    echo "Stopping Apache to avoid conflicts..."
    sudo systemctl stop apache2
    sudo systemctl disable apache2
fi

# Configure Nginx
echo "Configuring Nginx for sagatoy.com..."
sudo tee /etc/nginx/sites-available/sagatoy.com > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name sagatoy.com www.sagatoy.com;

    root /var/www/sagatoy.com;
    index index.html index.htm index.nginx-debian.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Create web root directory
sudo mkdir -p /var/www/sagatoy.com
sudo chown -R www-data:www-data /var/www/sagatoy.com
sudo chmod -R 755 /var/www/sagatoy.com

# Create a simple index page
sudo tee /var/www/sagatoy.com/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to SagaToy</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Welcome to SagaToy.com</h1>
    <p>Your secure website is now online!</p>
</body>
</html>
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/sagatoy.com /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
echo "Starting Nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# Wait for DNS propagation note
echo ""
echo "=== IMPORTANT: DNS Configuration Required ==="
echo "Before obtaining SSL certificates, ensure that:"
echo "1. sagatoy.com A record points to 94.72.141.71"
echo "2. www.sagatoy.com A record points to 94.72.141.71"
echo "3. DNS records have propagated (may take up to 48 hours)"
echo ""
read -p "Press Enter once DNS is configured and propagated, or Ctrl+C to exit..."

# Obtain SSL certificate
echo "Obtaining SSL certificate from Let's Encrypt..."
sudo certbot --nginx -d sagatoy.com -d www.sagatoy.com --non-interactive --agree-tos --email admin@sagatoy.com --redirect

# Set up automatic renewal
echo "Setting up automatic SSL renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test automatic renewal
echo "Testing automatic renewal..."
sudo certbot renew --dry-run

# Configure fail2ban for additional security
echo "Configuring fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo ""
echo "=== SSL Setup Complete! ==="
echo "Your website is now accessible at:"
echo "- https://sagatoy.com"
echo "- https://www.sagatoy.com"
echo ""
echo "SSL certificate will auto-renew before expiration."
echo ""
echo "Next steps:"
echo "1. Change your VPS password: passwd"
echo "2. Set up SSH key authentication"
echo "3. Upload your website content to /var/www/sagatoy.com"
echo ""
