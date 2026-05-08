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

## Observability

**First**: At the start of execution, display:
```
🔧 Skill "julien-infra-hostinger-security" activated
```

| Property | Value |
|----------|-------|
| **Host** | automation@69.62.108.82 |
| **Fail2ban** | Ubuntu 24.04 default |
| **Logs** | /var/log/nginx/*-access.log |

---

## 1. Fail2ban Management

### Tous les Jails Actifs

| Jail | Filter | Ports | Max Retry | Ban Time | Purpose |
|------|--------|-------|-----------|----------|---------|
| sshd | sshd | 22 | 5 | 10min | SSH brute-force |
| nginx-http-auth | nginx-401 | 80,443 | 5 | 1h | Nginx basic auth failures |
| **opcode-auth** | nginx-401 | 80,443 | 5 | 1h | 401 responses (API/sites protégés) |
| wordpress-auth | wordpress-auth | 80,443 | 5 | 1h | WP login brute-force |
| wordpress-hard | wordpress-hard | 80,443 | 3 | 2h | WP recon attacks |
| wordpress-xmlrpc | wordpress-xmlrpc | 80,443 | 2 | 1h | XML-RPC abuse |

> **ATTENTION**: Le jail `opcode-auth` bannit les IPs qui recoivent trop de 401. Si tu accèdes à un site protégé sans credentials, tu peux te faire bannir !

### Status Check

```bash
ssh srv759970 'sudo fail2ban-client status'
ssh srv759970 'sudo fail2ban-client status wordpress-auth'
ssh srv759970 'sudo fail2ban-client status opcode-auth'
```

### Ban/Unban IP (via fail2ban)

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

## 2. nftables (Mécanisme de ban réel)

> **IMPORTANT**: Fail2ban utilise **nftables** (pas iptables). Les bans sont stockés dans nftables !

### Voir toutes les IPs bannies

```bash
# Voir la structure complète
ssh srv759970 'nft list ruleset | head -40'

# Voir les IPs bannies par jail spécifique
ssh srv759970 'nft list set inet f2b-table addr-set-opcode-auth'
ssh srv759970 'nft list set inet f2b-table addr-set-sshd'
```

### Débannir une IP manuellement (nftables)

```bash
# Débannir de opcode-auth
ssh srv759970 'nft delete element inet f2b-table addr-set-opcode-auth { 1.2.3.4 }'

# Débannir de sshd
ssh srv759970 'nft delete element inet f2b-table addr-set-sshd { 1.2.3.4 }'
```

---

## 3. Whitelist (ignoreip)

### Voir la whitelist actuelle

```bash
ssh srv759970 'grep ignoreip /etc/fail2ban/jail.local'
```

### Ajouter une IP à la whitelist

```bash
# 1. Éditer le fichier
ssh srv759970 'sudo nano /etc/fail2ban/jail.local'
# Modifier la ligne ignoreip = ... en ajoutant l'IP

# 2. Recharger fail2ban
ssh srv759970 'sudo fail2ban-client reload'
```

---

## 4. Troubleshooting: Port 443 bloqué intermittent

**Symptômes**: Le site fonctionne quelques minutes puis devient inaccessible (timeout).

**Cause probable**: Ton IP est bannie par fail2ban (trop de 401).

### Diagnostic rapide

```bash
# 1. Test port local vs externe
ssh srv759970 'curl -sk https://localhost -o /dev/null -w "%{http_code}"'  # Doit retourner 200/401
curl -sk https://69.62.108.82 -o /dev/null -w "%{http_code}"               # Si timeout = banni

# 2. Vérifier si ton IP est dans nftables
ssh srv759970 'nft list ruleset | grep -E "91\.164|TON_IP"'

# 3. Si trouvée, débannir
ssh srv759970 'nft delete element inet f2b-table addr-set-opcode-auth { TON_IP }'

# 4. Ajouter à whitelist (permanent)
# Éditer /etc/fail2ban/jail.local, ajouter IP à ignoreip
ssh srv759970 'sudo fail2ban-client reload'
```

### Checklist diagnostic complet

```bash
# UFW status (devrait être inactif ou autoriser 443)
ssh srv759970 'ufw status'

# Nginx écoute sur 443 ?
ssh srv759970 'ss -tulpn | grep :443'

# Règles nftables (chercher DROP/REJECT)
ssh srv759970 'nft list ruleset | grep -E "reject|drop"'

# Fail2ban jails actifs
ssh srv759970 'fail2ban-client status'
```

---

## 5. WordPress Security Audit

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

## 6. Infrastructure Audit

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

## 7. Security Hardening

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

## 8. Emergency Response

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
# === FAIL2BAN ===
ssh srv759970 'sudo fail2ban-client status'                    # Status tous jails
ssh srv759970 'sudo fail2ban-client status opcode-auth'        # Status jail spécifique
ssh srv759970 'sudo fail2ban-client set wordpress-auth banip X.X.X.X'   # Ban IP
ssh srv759970 'sudo fail2ban-client unban X.X.X.X'             # Unban de tous les jails

# === NFTABLES (bans réels) ===
ssh srv759970 'nft list set inet f2b-table addr-set-opcode-auth'  # Voir IPs bannies
ssh srv759970 'nft delete element inet f2b-table addr-set-opcode-auth { X.X.X.X }'  # Débannir

# === WHITELIST ===
ssh srv759970 'grep ignoreip /etc/fail2ban/jail.local'         # Voir whitelist
# Pour ajouter: éditer jail.local puis fail2ban-client reload

# === DIAGNOSTIC PORT 443 ===
ssh srv759970 'curl -sk https://localhost -w "%{http_code}"'   # Test local (doit marcher)
curl -sk https://69.62.108.82 -w "%{http_code}"                # Test externe (si timeout = banni)
ssh srv759970 'nft list ruleset | grep -E "91\.164|TON_IP"'    # Chercher ton IP dans bans

# === AUTRES ===
ssh srv759970 'curl -sI https://site.com | grep -iE "x-frame|x-content|strict"'  # Headers
ssh srv759970 'sudo grep "Ban" /var/log/fail2ban.log | tail -20'                 # Attaques récentes
```
