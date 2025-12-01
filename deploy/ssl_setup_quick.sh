#!/bin/bash

################################################################################
# Quick SSL Setup for SagaToy.com
#
# This script sets up SSL/TLS certificates for sagatoy.com
#
# Prerequisites:
# - DNS configured (sagatoy.com → your-vps-ip)
# - Nginx installed
# - Certbot installed
#
# Usage: sudo bash ssl_setup_quick.sh
#
################################################################################

set -e  # Exit on error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}========================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root: sudo bash $0"
    exit 1
fi

clear
print_header "SSL Certificate Setup for SagaToy.com"

DOMAIN="sagatoy.com"
WWW_DOMAIN="www.sagatoy.com"

################################################################################
# 1. CHECK DNS
################################################################################

print_header "Phase 1: Check DNS Configuration"

print_info "Your VPS IP address:"
VPS_IP=$(curl -s ifconfig.me)
echo "  $VPS_IP"
echo ""

print_info "Checking DNS for $DOMAIN..."
DOMAIN_IP=$(dig +short $DOMAIN | head -1)
if [ "$DOMAIN_IP" = "$VPS_IP" ]; then
    print_success "$DOMAIN points to $VPS_IP"
else
    print_error "$DOMAIN points to: $DOMAIN_IP (should be $VPS_IP)"
    echo ""
    echo "Please configure DNS first:"
    echo "  A Record: $DOMAIN → $VPS_IP"
    echo "  A Record: $WWW_DOMAIN → $VPS_IP"
    echo ""
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

################################################################################
# 2. INSTALL CERTBOT (if not installed)
################################################################################

print_header "Phase 2: Install Certbot"

if command -v certbot &> /dev/null; then
    print_success "Certbot already installed"
    certbot --version
else
    print_info "Installing Certbot..."
    apt update
    apt install -y certbot python3-certbot-nginx
    print_success "Certbot installed"
fi

################################################################################
# 3. CHECK NGINX
################################################################################

print_header "Phase 3: Check Nginx"

if systemctl is-active --quiet nginx; then
    print_success "Nginx is running"
else
    print_warning "Nginx is not running. Starting..."
    systemctl start nginx
fi

# Check if port 80 is open in firewall
print_info "Checking firewall..."
if ufw status | grep -q "80.*ALLOW"; then
    print_success "Port 80 is open in firewall"
else
    print_warning "Opening port 80 in firewall..."
    ufw allow 80/tcp
    ufw reload
fi

if ufw status | grep -q "443.*ALLOW"; then
    print_success "Port 443 is open in firewall"
else
    print_warning "Opening port 443 in firewall..."
    ufw allow 443/tcp
    ufw reload
fi

################################################################################
# 4. CREATE BASIC NGINX CONFIG (if not exists)
################################################################################

print_header "Phase 4: Nginx Configuration"

NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

if [ -f "$NGINX_CONF" ]; then
    print_success "Nginx config already exists: $NGINX_CONF"
else
    print_info "Creating basic Nginx configuration..."

    cat > "$NGINX_CONF" << EOF
# Basic HTTP server for SSL certificate acquisition
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN $WWW_DOMAIN;

    # Root directory
    root /var/www/html;
    index index.html;

    # Allow Certbot validation
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 200 'SagaToy VPS - Ready for SSL!';
        add_header Content-Type text/plain;
    }
}
EOF

    # Enable site
    ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/

    # Test nginx config
    if nginx -t; then
        print_success "Nginx configuration created"
        systemctl reload nginx
    else
        print_error "Nginx configuration has errors!"
        exit 1
    fi
fi

################################################################################
# 5. GET SSL CERTIFICATE
################################################################################

print_header "Phase 5: Get SSL Certificate"

print_info "Running Certbot to obtain SSL certificate..."
echo ""
print_warning "You will be asked for:"
echo "  1. Email address (for renewal notifications)"
echo "  2. Agree to terms of service"
echo "  3. Share email with EFF (optional)"
echo ""

if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    print_warning "SSL certificate already exists for $DOMAIN"
    print_info "Certificate details:"
    certbot certificates -d $DOMAIN
    echo ""
    read -p "Renew certificate? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        certbot renew --force-renewal
    fi
else
    # Get certificate
    certbot --nginx -d $DOMAIN -d $WWW_DOMAIN
fi

################################################################################
# 6. TEST AUTO-RENEWAL
################################################################################

print_header "Phase 6: Test Auto-Renewal"

print_info "Testing automatic renewal..."
if certbot renew --dry-run; then
    print_success "Auto-renewal test passed"
else
    print_warning "Auto-renewal test had issues"
fi

################################################################################
# 7. VERIFY SSL
################################################################################

print_header "Phase 7: Verify SSL Certificate"

if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    print_success "SSL certificate installed!"
    echo ""
    certbot certificates
    echo ""

    print_info "Testing HTTPS connection..."
    sleep 2

    if curl -s -I "https://$DOMAIN" | grep -q "200 OK"; then
        print_success "HTTPS is working!"
    else
        print_warning "HTTPS test inconclusive, but certificate is installed"
    fi
fi

################################################################################
# COMPLETION
################################################################################

print_header "SSL Setup Complete!"

echo -e "${GREEN}${BOLD}✓ SSL/TLS certificate installed for $DOMAIN!${NC}"
echo ""
echo -e "${BOLD}Certificate information:${NC}"
certbot certificates -d $DOMAIN
echo ""
echo -e "${BOLD}Your website is now secure:${NC}"
echo "  🔒 https://$DOMAIN"
echo "  🔒 https://$WWW_DOMAIN"
echo ""
echo -e "${BOLD}Certificate will auto-renew:${NC}"
echo "  ✓ Certbot runs twice daily"
echo "  ✓ Renews when <30 days remaining"
echo "  ✓ Test renewal: ${CYAN}sudo certbot renew --dry-run${NC}"
echo ""
echo -e "${BOLD}Check SSL grade:${NC}"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo ""
echo -e "${BOLD}Nginx configuration:${NC}"
echo "  Config file: ${CYAN}$NGINX_CONF${NC}"
echo "  Test config: ${CYAN}sudo nginx -t${NC}"
echo "  Reload:      ${CYAN}sudo systemctl reload nginx${NC}"
echo ""
echo -e "${GREEN}Your VPS is now secured with HTTPS! 🔒${NC}"
echo ""
