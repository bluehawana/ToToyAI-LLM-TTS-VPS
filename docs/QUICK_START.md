# VPS Security Hardening - Quick Start Guide

## 🚀 Fast Track Setup (For Experienced Users)

**Total Time:** ~1.5 hours
**Difficulty:** Intermediate to Advanced

## Prerequisites

✅ Root or sudo access to VPS
✅ SSH key-based authentication already set up
✅ Google Authenticator app installed on phone
✅ VPS snapshot/backup created
✅ Console access to VPS via provider dashboard verified

## Step-by-Step

### 1. Upload and Run Security Script (5 minutes)

```bash
# Upload script to VPS
scp vps_security_hardening.sh your-user@your-vps:/tmp/

# SSH to VPS
ssh your-user@your-vps

# Run the script
sudo bash /tmp/vps_security_hardening.sh
```

**What it does:**
- Configures UFW firewall (allows SSH, HTTP, HTTPS)
- Hardens SSH configuration
- Sets up Fail2Ban
- Configures automatic security updates
- Creates Nginx security configurations

### 2. Create Non-Root User (5 minutes)

```bash
# Create user
sudo adduser yourusername
sudo usermod -aG sudo yourusername

# Copy SSH keys
sudo mkdir -p /home/yourusername/.ssh
sudo cp ~/.ssh/authorized_keys /home/yourusername/.ssh/
sudo chown -R yourusername:yourusername /home/yourusername/.ssh
sudo chmod 700 /home/yourusername/.ssh
sudo chmod 600 /home/yourusername/.ssh/authorized_keys
```

**Test in NEW terminal before continuing:**
```bash
ssh yourusername@your-vps
sudo ls  # Test sudo access
```

### 3. Set Up 2FA (10 minutes)

```bash
# Log in as your user
ssh yourusername@your-vps

# Run Google Authenticator
google-authenticator

# Answer: y, y, n, y
# SAVE EMERGENCY CODES!
# Scan QR code with phone
```

**Configure PAM:**
```bash
sudo nano /etc/pam.d/sshd
```
Add at top:
```
auth required pam_google_authenticator.so nullok
```
Comment out:
```
# @include common-auth
```

**Configure SSH:**
```bash
sudo nano /etc/ssh/sshd_config
```
Add:
```
ChallengeResponseAuthentication yes
UsePAM yes
AuthenticationMethods publickey,keyboard-interactive
```

**Restart SSH:**
```bash
sudo sshd -t  # Test config
sudo systemctl restart sshd
```

### 4. Test 2FA (5 minutes)

**⚠️ KEEP YOUR CURRENT SSH SESSION OPEN!**

In a **NEW** terminal:
```bash
ssh yourusername@your-vps
# Enter 6-digit code from Google Authenticator
```

**Tests:**
- ✅ Works with correct code?
- ✅ Fails with wrong code?
- ✅ Works with emergency code?

**Only proceed if all tests pass!**

### 5. Final Hardening (2 minutes)

```bash
# Disable password auth
sudo nano /etc/ssh/sshd_config.d/99-hardening.conf
# Uncomment: PasswordAuthentication no

# Remove nullok from PAM
sudo nano /etc/pam.d/sshd
# Change to: auth required pam_google_authenticator.so

# Restart
sudo systemctl restart sshd
```

**Test again in NEW terminal!**

### 6. SSL Setup (Optional, 30 minutes)

```bash
# Point your domain to VPS IP first!

# Generate DH params (takes 10-30 min)
sudo openssl dhparam -out /etc/nginx/dhparam.pem 4096 &

# Create site config
sudo nano /etc/nginx/sites-available/yourdomain.com
```

Minimal config:
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    root /var/www/yourdomain.com;
    index index.html;

    include snippets/security-headers.conf;
}
```

Enable and get certificate:
```bash
sudo mkdir -p /var/www/yourdomain.com
echo "Hello" | sudo tee /var/www/yourdomain.com/index.html
sudo ln -s /etc/nginx/sites-available/yourdomain.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

## Verification Commands

**Check everything is working:**
```bash
# Firewall
sudo ufw status verbose

# Fail2Ban
sudo fail2ban-client status

# SSH config
sudo sshd -t

# Nginx
sudo nginx -t

# Updates
sudo systemctl status unattended-upgrades

# All services
sudo systemctl status sshd fail2ban nginx
```

## What You've Accomplished

✅ **Firewall:** UFW blocking all except SSH, HTTP, HTTPS
✅ **SSH:** Hardened config, key + 2FA required
✅ **Fail2Ban:** Auto-banning brute force attempts
✅ **Updates:** Automatic security updates enabled
✅ **Nginx:** Security headers configured
✅ **SSL:** HTTPS with A+ rating (if completed)
✅ **2FA:** Only you can access the server

## Critical Information to Save

**Save in password manager NOW:**
- [ ] Emergency scratch codes from Google Authenticator setup
- [ ] VPS provider console access URL
- [ ] SSH username and port
- [ ] Server IP address

## Testing Checklist

Run through this to verify everything:

```bash
# 1. Can log in with SSH key + 2FA
ssh yourusername@your-vps
# ✓ Prompted for 2FA code

# 2. Cannot log in with wrong 2FA code
# Try with incorrect code - should fail

# 3. Emergency codes work
# Use one emergency code to log in

# 4. Services are running
sudo systemctl status sshd fail2ban nginx
# All should show "active (running)"

# 5. Firewall is active
sudo ufw status
# Should show "Status: active"

# 6. Failed login attempts are logged
sudo journalctl -u sshd | grep Failed

# 7. Fail2Ban is protecting SSH
sudo fail2ban-client status sshd
# Should show jail is running

# 8. Nginx security headers
curl -I http://yourdomain.com
# Should show X-Frame-Options, X-Content-Type-Options, etc.
```

## Common Issues

**"Verification code is incorrect"**
→ Server time might be wrong: `sudo ntpdate -s time.nist.gov`

**Locked out after enabling 2FA**
→ Use provider console access, see `emergency_recovery.md`

**SSH test times out**
→ UFW might have blocked SSH port, use console to fix

**Can't sudo as new user**
→ Verify user is in sudo group: `groups yourusername`

## Next Steps

1. **Set up monitoring** (optional)
   - Consider installing: `fail2ban-monitor`, `logwatch`, `netdata`

2. **Set up backups** (recommended)
   - Automated daily backups via VPS provider
   - Or set up `rsnapshot` / `borg backup`

3. **Configure your application**
   - Set up your web app behind Nginx
   - Use Nginx as reverse proxy if needed

4. **IP whitelisting** (optional, if you have static IP)
   ```bash
   sudo ufw delete allow 22/tcp
   sudo ufw allow from YOUR_STATIC_IP to any port 22
   ```

## Maintenance

**Weekly:**
```bash
# Check for failed login attempts
sudo journalctl -u sshd --since "1 week ago" | grep Failed

# Check Fail2Ban bans
sudo fail2ban-client status sshd
```

**Monthly:**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Generate new 2FA emergency codes
google-authenticator  # Follow prompts
```

**Quarterly:**
```bash
# Test emergency recovery procedure
# Review and rotate credentials
# Check SSL certificate expiration (should auto-renew)
```

## Emergency Recovery

**If locked out:**
1. Access VPS via provider's web console
2. Disable 2FA temporarily:
   ```bash
   sudo sed -i 's/^auth required pam_google_authenticator/#&/' /etc/pam.d/sshd
   sudo systemctl restart sshd
   ```
3. Fix issue, re-enable 2FA

**Full recovery guide:** See `emergency_recovery.md`

## Files Created

- `vps_security_hardening.sh` - Main security script
- `2fa_setup_guide.md` - Detailed 2FA setup instructions
- `emergency_recovery.md` - Lockout recovery procedures
- `SECURITY_DEPLOYMENT_CHECKLIST.md` - Complete deployment checklist

## Security Ratings

After this setup, you should have:
- **SSH:** ⭐⭐⭐⭐⭐ Excellent (key + 2FA, hardened config)
- **Firewall:** ⭐⭐⭐⭐⭐ Excellent (strict rules, minimal exposure)
- **Web Server:** ⭐⭐⭐⭐⭐ Excellent (security headers, SSL)
- **Intrusion Prevention:** ⭐⭐⭐⭐⭐ Excellent (Fail2Ban active)
- **Updates:** ⭐⭐⭐⭐⭐ Excellent (automatic security updates)

## Questions?

- **Full guides:** See the detailed `.md` files in this directory
- **Issues?** Check `emergency_recovery.md`
- **Best practices?** Check `SECURITY_DEPLOYMENT_CHECKLIST.md`

---

**🎉 Congratulations! Your VPS is now highly secured with military-grade authentication and protection!**

**Remember:** The only way in is now:
1. Your SSH private key ✅
2. Your 2FA code from your phone ✅
3. From an allowed IP (if you set up IP whitelisting) ✅

This is **significantly more secure** than 99% of servers on the internet!
