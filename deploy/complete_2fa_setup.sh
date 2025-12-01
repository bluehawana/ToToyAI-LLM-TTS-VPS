#!/bin/bash

################################################################################
# Complete 2FA Setup - Run this AFTER secure_vps.sh
#
# This script completes the 2FA configuration that was prepared by secure_vps.sh
#
# Usage:
#   1. Run as your regular user (not root): bash complete_2fa_setup.sh
#   2. Scan QR code with Google Authenticator app
#   3. Save emergency codes
#   4. Test in new terminal
#
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}Complete 2FA Setup${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}DO NOT run this as root!${NC}"
    echo -e "${YELLOW}Run as your regular user:${NC}"
    echo -e "${CYAN}su - yourusername${NC}"
    echo -e "${CYAN}bash complete_2fa_setup.sh${NC}"
    exit 1
fi

CURRENT_USER=$(whoami)

echo -e "${BOLD}This script will:${NC}"
echo "  1. Run google-authenticator for user: $CURRENT_USER"
echo "  2. Generate YOUR unique QR code and emergency codes"
echo "  3. Configure PAM and SSH for 2FA"
echo "  4. Test the configuration"
echo ""
echo -e "${YELLOW}IMPORTANT: Keep your current SSH session open!${NC}"
echo ""
read -p "Press Enter to continue..."

echo ""
echo -e "${CYAN}${BOLD}Step 1: Running Google Authenticator${NC}"
echo ""
echo -e "${YELLOW}Answer the prompts as follows:${NC}"
echo "  - Time-based tokens? ${GREEN}y${NC}"
echo "  - ${RED}SAVE THE EMERGENCY CODES NOW!${NC}"
echo "  - Update .google_authenticator? ${GREEN}y${NC}"
echo "  - Disallow reuse? ${GREEN}y${NC}"
echo "  - Increase time window? ${GREEN}n${NC}"
echo "  - Enable rate-limiting? ${GREEN}y${NC}"
echo ""
read -p "Press Enter to start google-authenticator..."

# Run google-authenticator
google-authenticator

if [ $? -ne 0 ]; then
    echo -e "${RED}Google Authenticator setup failed or was cancelled.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Google Authenticator configured for $CURRENT_USER${NC}"
echo ""
echo -e "${YELLOW}Did you:${NC}"
echo "  1. Scan the QR code with your phone? (Google Authenticator app)"
echo "  2. Save the emergency codes in a password manager?"
echo ""
read -p "Type 'yes' to confirm: " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Please complete the steps above before continuing.${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}${BOLD}Step 2: Configuring PAM and SSH for 2FA${NC}"
echo -e "${YELLOW}This requires sudo access. You may be asked for your password.${NC}"
echo ""

# Check if helper script exists
if [ -f "/root/setup_2fa_step2.sh" ]; then
    echo "Running helper script..."
    sudo /root/setup_2fa_step2.sh
else
    echo -e "${YELLOW}Helper script not found. Configuring manually...${NC}"

    # Configure PAM
    echo "Configuring PAM..."
    if ! sudo grep -q "pam_google_authenticator.so" /etc/pam.d/sshd; then
        sudo sed -i '1s/^/auth required pam_google_authenticator.so nullok\n/' /etc/pam.d/sshd
        sudo sed -i 's/^@include common-auth/#@include common-auth/' /etc/pam.d/sshd
        echo -e "${GREEN}✓ PAM configured${NC}"
    else
        echo -e "${GREEN}✓ PAM already configured${NC}"
    fi

    # Configure SSH
    echo "Configuring SSH..."
    if ! sudo grep -q "AuthenticationMethods publickey,keyboard-interactive" /etc/ssh/sshd_config; then
        echo "" | sudo tee -a /etc/ssh/sshd_config
        echo "# 2FA Configuration" | sudo tee -a /etc/ssh/sshd_config
        echo "ChallengeResponseAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
        echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config
        echo "AuthenticationMethods publickey,keyboard-interactive" | sudo tee -a /etc/ssh/sshd_config
        echo -e "${GREEN}✓ SSH configured for 2FA${NC}"
    else
        echo -e "${GREEN}✓ SSH already configured for 2FA${NC}"
    fi

    # Test and restart SSH
    echo "Testing SSH configuration..."
    if sudo sshd -t; then
        echo -e "${GREEN}✓ SSH configuration is valid${NC}"
        echo "Restarting SSH..."
        sudo systemctl restart sshd
        echo -e "${GREEN}✓ SSH restarted${NC}"
    else
        echo -e "${RED}✗ SSH configuration has errors!${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}2FA is Now Active!${NC}"
echo -e "${GREEN}${BOLD}========================================${NC}"
echo ""
echo -e "${RED}${BOLD}CRITICAL: TEST BEFORE CLOSING THIS SESSION!${NC}"
echo ""
echo -e "${BOLD}In a NEW terminal, try to connect:${NC}"

# Get SSH port
SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
if [ -z "$SSH_PORT" ]; then
    SSH_PORT=22
fi

# Get IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo -e "${CYAN}ssh -p $SSH_PORT $CURRENT_USER@$IP_ADDRESS${NC}"
echo ""
echo -e "${YELLOW}You will be prompted for:${NC}"
echo "  1. SSH key passphrase (if you have one)"
echo "  2. ${BOLD}Verification code${NC} from Google Authenticator app on your phone"
echo ""
echo -e "${YELLOW}Test these:${NC}"
echo "  ✓ Correct 2FA code works"
echo "  ✓ Wrong 2FA code fails"
echo "  ✓ Emergency scratch code works (test one)"
echo ""
echo -e "${BOLD}After testing succeeds, you can optionally disable password authentication:${NC}"
echo -e "${CYAN}sudo nano /etc/ssh/sshd_config.d/99-hardening.conf${NC}"
echo "Uncomment the line:"
echo -e "${GREEN}PasswordAuthentication no${NC}"
echo "Then:"
echo -e "${CYAN}sudo systemctl restart sshd${NC}"
echo ""
echo -e "${GREEN}Your VPS is now protected with 2FA! 🛡️${NC}"
echo ""
