---
name: julien-infra-hostinger-security
description: Security management for Hostinger VPS srv759970 - Fail2ban, WordPress security audits (25+ checks, 0-100% scoring), infrastructure audit. Use for security hardening, IP bans, or security assessments.
license: Apache-2.0
triggers:
  - fail2ban
  - ban ip
  - unban ip
  - wordpress security
  - security audit
  - audit vps
  - brute force
---

# Hostinger Security Management

Security infrastructure for srv759970.hstgr.cloud.

## Server Info

| Property | Value |
|----------|-------|
| **Host** | automation@69.62.108.82 |
| **Fail2ban** | Ubuntu 24.04 default |
| **Logs** | /var/log/nginx/*-access.log |

---

## 1. Fail2ban Management

### WordPress Jails

| Jail | Purpose | Max Retry | Ban Time |
|------|---------|-----------|----------|
| wordpress-auth | Login brute-force | 5 | 1 hour |
| wordpress-hard | Recon attacks | 3 | 2 hours |
| wordpress-xmlrpc | XML-RPC abuse | 2 | 1 hour |

### Status Check

```bash
ssh srv759970 'sudo fail2ban-client status'
ssh srv759970 'sudo fail2ban-client status wordpress-auth'
ssh srv759970 'sudo fail2ban-client status wordpress-auth | grep "Banned IP"'
```

### Ban/Unban IP

```bash
# Ban
ssh srv759970 'sudo fail2ban-client set wordpress-auth banip 1.2.3.4'

# Unban
ssh srv759970 'sudo fail2ban-client set wordpress-auth unbanip 1.2.3.4'

# Unban from all jails
ssh srv759970 'sudo fail2ban-client unban 1.2.3.4'
```

### View Recent Attacks

```bash
ssh srv759970 'sudo grep "Ban" /var/log/fail2ban.log | tail -20'
```

---

## 2. WordPress Security Audit

### Scoring System

| Score | Level | Action |
|-------|-------|--------|
| 90-100% | EXCELLENT | Maintain |
| 75-89% | GOOD | Minor fixes |
| 50-74% | WARNING | Hardening needed |
| < 50% | CRITICAL | Immediate action |

### 7 Audit Categories (30 checks)

1. **Nginx Security** (8 checks, 25%)
2. **File Permissions** (6 checks, 15%)
3. **WordPress Config** (5 checks, 20%)
4. **Users & Auth** (4 checks, 15%)
5. **Plugins & Themes** (3 checks, 10%)
6. **Database** (2 checks, 10%)
7. **Fail2ban** (2 checks, 5%)

### Quick Security Checks

```bash
# Nginx security headers
ssh srv759970 'curl -sI https://site.srv759970.hstgr.cloud | grep -iE "x-frame|x-content|strict-transport"'

# Server info exposure
ssh srv759970 'curl -sI https://site.srv759970.hstgr.cloud | grep -iE "server:|x-powered"'

# wp-config.php permissions
ssh srv759970 'ls -la /opt/wordpress-site/wp-config.php'

# Admin users
ssh srv759970 'docker exec wp-cli-site wp user list --role=administrator'

# Plugin updates
ssh srv759970 'docker exec wp-cli-site wp plugin list --update=available'
```

---

## 3. Infrastructure Audit

### What It Discovers

- Docker containers and images
- Scripts (150+ locations)
- Cron jobs
- Systemd services
- PM2 processes
- Orphan resources

### Quick Audit Commands

```bash
# All containers
ssh srv759970 'docker ps -a --format "table {{.Names}}\t{{.Status}}"'

# Docker disk usage
ssh srv759970 'docker system df'

# Orphan volumes
ssh srv759970 'docker volume ls -f dangling=true'

# Orphan images
ssh srv759970 'docker images -f dangling=true'

# Cron jobs
ssh srv759970 'crontab -l && sudo crontab -l'

# PM2 processes
ssh srv759970 'pm2 list'
```

---

## 4. Security Hardening

### Nginx Security Headers

Add to server block:
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### Hide Server Info

```nginx
# In /etc/nginx/nginx.conf
server_tokens off;
```

### WordPress Hardening

```bash
# Disable file editing
ssh srv759970 'docker exec wp-cli-site wp config set DISALLOW_FILE_EDIT true'

# Set secure permissions
ssh srv759970 'docker exec -u root wordpress-site chmod 640 /var/www/html/wp-config.php'
```

---

## 5. Emergency Response

### Under Attack

```bash
# Check who's attacking
ssh srv759970 'sudo grep "Ban" /var/log/fail2ban.log | tail -50'
ssh srv759970 'sudo tail -f /var/log/nginx/access.log | grep -E "wp-login|xmlrpc"'

# Ban attacker
ssh srv759970 'sudo fail2ban-client set wordpress-hard banip ATTACKER_IP'

# Check banned IPs
ssh srv759970 'sudo fail2ban-client status wordpress-auth'
```

### Suspected Breach

```bash
# Check admin users
ssh srv759970 'docker exec wp-cli-site wp user list --role=administrator'

# Check recent logins
ssh srv759970 'docker exec wp-cli-site wp user list --field=user_login,user_registered'

# Check modified files
ssh srv759970 'find /opt/wordpress-site -mtime -1 -type f | head -50'
```

---

## Quick Reference

```bash
# Fail2ban status
ssh srv759970 'sudo fail2ban-client status'

# Ban IP
ssh srv759970 'sudo fail2ban-client set wordpress-auth banip X.X.X.X'

# Unban IP
ssh srv759970 'sudo fail2ban-client set wordpress-auth unbanip X.X.X.X'

# Security headers check
ssh srv759970 'curl -sI https://site.com | grep -iE "x-frame|x-content|strict"'

# WordPress admin users
ssh srv759970 'docker exec wp-cli-site wp user list --role=administrator'

# Orphan volumes
ssh srv759970 'docker volume ls -f dangling=true'

# Recent attacks
ssh srv759970 'sudo grep "Ban" /var/log/fail2ban.log | tail -20'
```
