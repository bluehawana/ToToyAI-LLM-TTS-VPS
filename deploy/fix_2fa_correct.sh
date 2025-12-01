#!/bin/bash

################################################################################
# Fix 2FA - Corrected Version
#
# This fixes the keyboard-interactive disabled error
#
# Usage: sudo bash fix_2fa_correct.sh
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}Fix 2FA - Enable keyboard-interactive${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root: sudo bash $0${NC}"
    exit 1
fi

# Step 1: Fix the hardening config file
echo -e "${BOLD}[1] Fixing hardening configuration...${NC}"

HARDENING_CONF="/etc/ssh/sshd_config.d/99-hardening.conf"

if [ -f "$HARDENING_CONF" ]; then
    echo "Found hardening config at $HARDENING_CONF"

    # Change ChallengeResponseAuthentication no to yes
    if grep -q "^ChallengeResponseAuthentication no" "$HARDENING_CONF"; then
        sed -i 's/^ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' "$HARDENING_CONF"
        echo -e "${GREEN}✓ Changed ChallengeResponseAuthentication to yes${NC}"
    else
        echo -e "${YELLOW}⚠ ChallengeResponseAuthentication not set to 'no' or already yes${NC}"
    fi

    # Ensure UsePAM yes is set
    if ! grep -q "^UsePAM" "$HARDENING_CONF"; then
        echo "UsePAM yes" >> "$HARDENING_CONF"
        echo -e "${GREEN}✓ Added UsePAM yes${NC}"
    fi

    # Add AuthenticationMethods if not present
    if ! grep -q "^AuthenticationMethods" "$HARDENING_CONF"; then
        echo "AuthenticationMethods password,keyboard-interactive" >> "$HARDENING_CONF"
        echo -e "${GREEN}✓ Added AuthenticationMethods${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Hardening config not found, will modify main config${NC}"

    # Modify main sshd_config
    if grep -q "^ChallengeResponseAuthentication no" /etc/ssh/sshd_config; then
        sed -i 's/^ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
        echo -e "${GREEN}✓ Changed ChallengeResponseAuthentication to yes in main config${NC}"
    fi

    # Add settings to main config
    if ! grep -q "^AuthenticationMethods" /etc/ssh/sshd_config; then
        cat >> /etc/ssh/sshd_config << 'EOF'

# Two-Factor Authentication
ChallengeResponseAuthentication yes
UsePAM yes
AuthenticationMethods password,keyboard-interactive
EOF
        echo -e "${GREEN}✓ Added 2FA settings to main config${NC}"
    fi
fi

echo ""

# Step 2: Configure PAM
echo -e "${BOLD}[2] Configuring PAM...${NC}"

if ! grep -q "^auth required pam_google_authenticator.so" /etc/pam.d/sshd; then
    sed -i '1s/^/auth required pam_google_authenticator.so nullok\n/' /etc/pam.d/sshd
    echo -e "${GREEN}✓ Added PAM configuration${NC}"
else
    echo -e "${GREEN}✓ PAM already configured${NC}"
fi

# Comment out @include common-auth
if grep -q "^@include common-auth" /etc/pam.d/sshd; then
    sed -i 's/^@include common-auth/#@include common-auth/' /etc/pam.d/sshd
    echo -e "${GREEN}✓ Commented out @include common-auth${NC}"
else
    echo -e "${GREEN}✓ @include common-auth already disabled${NC}"
fi

echo ""

# Step 3: Show current configuration
echo -e "${BOLD}[3] Current configuration:${NC}"
echo ""
if [ -f "$HARDENING_CONF" ]; then
    echo "From $HARDENING_CONF:"
    grep -E "ChallengeResponseAuthentication|UsePAM|AuthenticationMethods" "$HARDENING_CONF"
else
    echo "From /etc/ssh/sshd_config:"
    grep -E "ChallengeResponseAuthentication|UsePAM|AuthenticationMethods" /etc/ssh/sshd_config | grep -v "^#"
fi

echo ""

# Step 4: Test SSH configuration
echo -e "${BOLD}[4] Testing SSH configuration...${NC}"
echo ""

if sshd -t 2>&1; then
    echo -e "${GREEN}✓ SSH configuration is valid!${NC}"
else
    echo -e "${RED}✗ SSH configuration still has errors:${NC}"
    sshd -t
    exit 1
fi

echo ""

# Step 5: Restart SSH
echo -e "${BOLD}[5] Restarting SSH service...${NC}"
systemctl restart sshd

if systemctl is-active --quiet sshd; then
    echo -e "${GREEN}✓ SSH service restarted successfully${NC}"
else
    echo -e "${RED}✗ SSH service failed to start!${NC}"
    exit 1
fi

echo ""

# Step 6: Check user 2FA status
echo -e "${BOLD}[6] Checking user 2FA configuration:${NC}"
echo ""

for user_home in /home/*; do
    username=$(basename "$user_home")
    if [ -f "$user_home/.google_authenticator" ]; then
        echo -e "${GREEN}✓ User '$username' has 2FA configured${NC}"
    else
        echo -e "${YELLOW}⚠ User '$username' does NOT have 2FA configured${NC}"
        echo -e "   Run as $username: ${CYAN}google-authenticator${NC}"
    fi
done

echo ""
echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}2FA Fix Complete!${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""

# Get SSH port
SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | grep -v "^#" | head -1 | awk '{print $2}')
if [ -z "$SSH_PORT" ]; then
    SSH_PORT=22
fi

echo -e "${GREEN}${BOLD}SUCCESS! 2FA is now active!${NC}"
echo ""
echo -e "${YELLOW}${BOLD}TEST IN A NEW WINDOW (keep this one open!):${NC}"
echo ""
echo -e "${CYAN}ssh -p $SSH_PORT yourusername@your-vps-ip${NC}"
echo ""
echo "You should now see:"
echo "  Password: [enter password]"
echo "  Verification code: [enter 6-digit code from Google Authenticator]"
echo ""
echo -e "${GREEN}Your VPS is now protected with 2FA! 🔐${NC}"
echo ""
