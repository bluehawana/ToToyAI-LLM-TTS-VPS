#!/bin/bash

################################################################################
# Automatic 2FA Fix Script
#
# This script will automatically configure 2FA to actually work
#
# Usage: sudo bash fix_2fa_now.sh
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}Automatic 2FA Fix${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root: sudo bash $0${NC}"
    exit 1
fi

# Step 1: Configure PAM
echo -e "${BOLD}[1] Configuring PAM for 2FA...${NC}"

# Check if line already exists
if grep -q "^auth required pam_google_authenticator.so" /etc/pam.d/sshd; then
    echo -e "${GREEN}✓ PAM already configured${NC}"
else
    # Add at the top of the file
    sed -i '1s/^/auth required pam_google_authenticator.so nullok\n/' /etc/pam.d/sshd
    echo -e "${GREEN}✓ Added PAM configuration${NC}"
fi

# Comment out @include common-auth
if grep -q "^@include common-auth" /etc/pam.d/sshd; then
    sed -i 's/^@include common-auth/#@include common-auth/' /etc/pam.d/sshd
    echo -e "${GREEN}✓ Commented out @include common-auth${NC}"
else
    echo -e "${GREEN}✓ @include common-auth already commented or not present${NC}"
fi

echo ""

# Step 2: Configure SSH
echo -e "${BOLD}[2] Configuring SSH for 2FA...${NC}"

# Remove any existing AuthenticationMethods lines
sed -i '/^AuthenticationMethods/d' /etc/ssh/sshd_config
sed -i '/^ChallengeResponseAuthentication/d' /etc/ssh/sshd_config
sed -i '/^UsePAM/d' /etc/ssh/sshd_config

# Add new configuration at the end
cat >> /etc/ssh/sshd_config << 'EOF'

# Two-Factor Authentication Configuration
ChallengeResponseAuthentication yes
UsePAM yes
AuthenticationMethods password,keyboard-interactive
EOF

echo -e "${GREEN}✓ SSH configuration updated${NC}"
echo ""

# Step 3: Test SSH configuration
echo -e "${BOLD}[3] Testing SSH configuration...${NC}"
if sshd -t 2>&1; then
    echo -e "${GREEN}✓ SSH configuration is valid${NC}"
else
    echo -e "${RED}✗ SSH configuration has errors!${NC}"
    echo -e "${YELLOW}Reverting changes...${NC}"

    # Remove the lines we just added
    sed -i '/# Two-Factor Authentication Configuration/,+3d' /etc/ssh/sshd_config

    echo -e "${RED}Fix failed. SSH config has been reverted.${NC}"
    exit 1
fi
echo ""

# Step 4: Restart SSH
echo -e "${BOLD}[4] Restarting SSH service...${NC}"
systemctl restart sshd

if systemctl is-active --quiet sshd; then
    echo -e "${GREEN}✓ SSH service restarted successfully${NC}"
else
    echo -e "${RED}✗ SSH service failed to start!${NC}"
    exit 1
fi
echo ""

# Step 5: Verify configuration
echo -e "${BOLD}[5] Verifying configuration...${NC}"
echo ""

echo "PAM Configuration:"
grep "pam_google_authenticator" /etc/pam.d/sshd

echo ""
echo "SSH Configuration:"
grep -E "ChallengeResponseAuthentication|UsePAM|AuthenticationMethods" /etc/ssh/sshd_config | grep -v "^#"

echo ""

# Check which users have 2FA configured
echo -e "${BOLD}[6] Checking which users have 2FA configured:${NC}"
for user_home in /home/*; do
    username=$(basename "$user_home")
    if [ -f "$user_home/.google_authenticator" ]; then
        echo -e "${GREEN}✓ User '$username' has 2FA configured${NC}"
    else
        echo -e "${YELLOW}⚠ User '$username' does NOT have 2FA configured${NC}"
        echo -e "${YELLOW}  Run as $username: google-authenticator${NC}"
    fi
done

# Check root too
if [ -f "/root/.google_authenticator" ]; then
    echo -e "${GREEN}✓ User 'root' has 2FA configured${NC}"
else
    echo -e "${YELLOW}⚠ User 'root' does NOT have 2FA configured${NC}"
fi

echo ""
echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}2FA Configuration Complete!${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""

# Get SSH port
SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
if [ -z "$SSH_PORT" ]; then
    SSH_PORT=22
fi

echo -e "${YELLOW}${BOLD}IMPORTANT - TEST NOW:${NC}"
echo ""
echo -e "${BOLD}1. Open a NEW terminal (keep this one open!)${NC}"
echo ""
echo -e "${BOLD}2. Try to connect:${NC}"
echo -e "${CYAN}   ssh -p $SSH_PORT yourusername@your-vps-ip${NC}"
echo ""
echo -e "${BOLD}3. You should see:${NC}"
echo "   Password: [enter your password]"
echo "   Verification code: [enter 6-digit code from Google Authenticator app]"
echo ""
echo -e "${YELLOW}If any user doesn't have 2FA configured (shown above):${NC}"
echo -e "${CYAN}   su - username${NC}"
echo -e "${CYAN}   google-authenticator${NC}"
echo "   (Answer: y, y, n, y - and SAVE the emergency codes!)"
echo ""
echo -e "${GREEN}${BOLD}Your VPS now requires password + 2FA! 🔐${NC}"
echo ""
