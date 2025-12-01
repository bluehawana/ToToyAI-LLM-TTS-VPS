#!/bin/bash

################################################################################
# Diagnose 2FA Issues - Why isn't 2FA being enforced?
#
# Run this on your VPS to check 2FA configuration
#
# Usage: sudo bash diagnose_2fa.sh
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}2FA Diagnostic Check${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""

# Check 1: PAM configuration
echo -e "${BOLD}[1] Checking PAM configuration (/etc/pam.d/sshd)${NC}"
echo "Looking for: auth required pam_google_authenticator.so"
echo ""
if grep -q "^auth required pam_google_authenticator.so" /etc/pam.d/sshd; then
    echo -e "${GREEN}✓ PAM is configured for 2FA${NC}"
    grep "pam_google_authenticator" /etc/pam.d/sshd
elif grep -q "^#.*pam_google_authenticator.so" /etc/pam.d/sshd; then
    echo -e "${RED}✗ PAM line is COMMENTED OUT!${NC}"
    grep "pam_google_authenticator" /etc/pam.d/sshd
    echo -e "${YELLOW}FIX: Uncomment the line${NC}"
else
    echo -e "${RED}✗ PAM is NOT configured for 2FA${NC}"
    echo -e "${YELLOW}FIX: Add this line to /etc/pam.d/sshd:${NC}"
    echo "auth required pam_google_authenticator.so nullok"
fi
echo ""

# Check 2: SSH ChallengeResponseAuthentication
echo -e "${BOLD}[2] Checking ChallengeResponseAuthentication${NC}"
echo "Looking for: ChallengeResponseAuthentication yes"
echo ""
CHALLENGE_RESP=$(grep -i "^ChallengeResponseAuthentication" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | grep -v "^#")
if echo "$CHALLENGE_RESP" | grep -q "yes"; then
    echo -e "${GREEN}✓ ChallengeResponseAuthentication is enabled${NC}"
    echo "$CHALLENGE_RESP"
else
    echo -e "${RED}✗ ChallengeResponseAuthentication is NOT enabled or set to 'no'${NC}"
    echo "$CHALLENGE_RESP"
    echo -e "${YELLOW}FIX: Set 'ChallengeResponseAuthentication yes' in /etc/ssh/sshd_config${NC}"
fi
echo ""

# Check 3: UsePAM
echo -e "${BOLD}[3] Checking UsePAM${NC}"
echo "Looking for: UsePAM yes"
echo ""
USE_PAM=$(grep -i "^UsePAM" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | grep -v "^#")
if echo "$USE_PAM" | grep -q "yes"; then
    echo -e "${GREEN}✓ UsePAM is enabled${NC}"
    echo "$USE_PAM"
else
    echo -e "${RED}✗ UsePAM is NOT enabled${NC}"
    echo "$USE_PAM"
    echo -e "${YELLOW}FIX: Set 'UsePAM yes' in /etc/ssh/sshd_config${NC}"
fi
echo ""

# Check 4: AuthenticationMethods
echo -e "${BOLD}[4] Checking AuthenticationMethods${NC}"
echo "Looking for: AuthenticationMethods publickey,keyboard-interactive"
echo ""
AUTH_METHODS=$(grep -i "^AuthenticationMethods" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | grep -v "^#")
if [ ! -z "$AUTH_METHODS" ]; then
    if echo "$AUTH_METHODS" | grep -q "keyboard-interactive"; then
        echo -e "${GREEN}✓ AuthenticationMethods includes keyboard-interactive${NC}"
        echo "$AUTH_METHODS"
    else
        echo -e "${YELLOW}⚠ AuthenticationMethods is set but doesn't include keyboard-interactive${NC}"
        echo "$AUTH_METHODS"
        echo -e "${YELLOW}FIX: Set 'AuthenticationMethods publickey,keyboard-interactive'${NC}"
    fi
else
    echo -e "${RED}✗ AuthenticationMethods is NOT set${NC}"
    echo -e "${YELLOW}FIX: Add 'AuthenticationMethods publickey,keyboard-interactive' to SSH config${NC}"
fi
echo ""

# Check 5: User has .google_authenticator file
echo -e "${BOLD}[5] Checking which users have 2FA configured${NC}"
echo ""
for user_home in /home/*; do
    username=$(basename "$user_home")
    if [ -f "$user_home/.google_authenticator" ]; then
        echo -e "${GREEN}✓ User '$username' has 2FA configured${NC}"
    else
        echo -e "${YELLOW}⚠ User '$username' does NOT have 2FA configured${NC}"
    fi
done
echo ""

# Check 6: Check if common-auth is commented out
echo -e "${BOLD}[6] Checking if @include common-auth is commented out${NC}"
echo ""
if grep -q "^#.*@include common-auth" /etc/pam.d/sshd; then
    echo -e "${GREEN}✓ @include common-auth is commented out (correct)${NC}"
elif grep -q "^@include common-auth" /etc/pam.d/sshd; then
    echo -e "${RED}✗ @include common-auth is NOT commented out${NC}"
    echo -e "${YELLOW}This may allow password-only authentication to bypass 2FA!${NC}"
    echo -e "${YELLOW}FIX: Comment it out: #@include common-auth${NC}"
else
    echo -e "${YELLOW}⚠ @include common-auth line not found${NC}"
fi
echo ""

# Check 7: Password Authentication status
echo -e "${BOLD}[7] Checking PasswordAuthentication${NC}"
echo ""
PASS_AUTH=$(grep -i "^PasswordAuthentication" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | grep -v "^#")
if echo "$PASS_AUTH" | grep -q "no"; then
    echo -e "${GREEN}✓ PasswordAuthentication is disabled (most secure)${NC}"
    echo "$PASS_AUTH"
elif echo "$PASS_AUTH" | grep -q "yes"; then
    echo -e "${YELLOW}⚠ PasswordAuthentication is still enabled${NC}"
    echo "$PASS_AUTH"
    echo -e "${YELLOW}You can disable it after 2FA is working${NC}"
else
    echo -e "${YELLOW}⚠ PasswordAuthentication setting not found${NC}"
fi
echo ""

# Summary
echo -e "${CYAN}${BOLD}========================================${NC}"
echo -e "${CYAN}${BOLD}Summary & Recommendations${NC}"
echo -e "${CYAN}${BOLD}========================================${NC}"
echo ""
echo -e "${BOLD}For 2FA to work, ALL of these must be true:${NC}"
echo ""
echo "1. PAM configured with: auth required pam_google_authenticator.so"
echo "2. ChallengeResponseAuthentication yes"
echo "3. UsePAM yes"
echo "4. AuthenticationMethods publickey,keyboard-interactive"
echo "5. User has run 'google-authenticator' and has ~/.google_authenticator file"
echo "6. @include common-auth is commented out in /etc/pam.d/sshd"
echo ""
echo -e "${YELLOW}After making changes, test SSH config and restart:${NC}"
echo -e "${CYAN}sudo sshd -t${NC}"
echo -e "${CYAN}sudo systemctl restart sshd${NC}"
echo ""

# Show current auth.log to see what's happening
echo -e "${BOLD}[8] Recent SSH authentication attempts:${NC}"
echo ""
tail -20 /var/log/auth.log | grep -i "sshd\|pam" || echo "No recent auth logs found"
echo ""
