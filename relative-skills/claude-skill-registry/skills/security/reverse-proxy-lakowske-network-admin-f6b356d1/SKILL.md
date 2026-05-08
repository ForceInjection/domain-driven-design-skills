---
name: reverse-proxy
description: Manage incoming internet traffic and reverse proxy configuration on the home network gateway. Configure Caddy, OAuth2 authentication, fail2ban security, and traffic routing.
---

# Reverse Proxy & Traffic Management Skill

This skill enables management of incoming internet traffic and reverse proxy configuration on the home network, specifically focused on the Raspberry Pi gateway running Caddy, OAuth2-proxy, and fail2ban security.

## Overview

The reverse-proxy skill provides capabilities to manage the public-facing gateway server (raspberrypi.local) that handles:
- **HTTPS termination** with Let's Encrypt
- **OAuth2 authentication** for protected services
- **Security monitoring** with fail2ban
- **Reverse proxying** to internal services

This server is the **source of truth** for all incoming traffic configuration. Reference repository: `/home/seth/Software/dev/squelch`

## Gateway Server

### raspberrypi (Gateway/Proxy Server)
- **Host**: raspberrypi.local (192.168.0.76)
- **SSH**: `ssh pi` (port 2222)
- **Public Domain**: lab.sethlakowske.com
- **Role**: Internet gateway, reverse proxy, OAuth gateway, security enforcement
- **Key Services**:
  - Caddy (port 443 HTTPS, port 80 HTTP)
  - oauth2-proxy-google (port 4180)
  - oauth2-proxy-good-neighbor (port 4182)
  - oauth2-proxy-service-monitor (port 4183)
  - fail2ban (security)
  - service-monitor (port 8000)

### Configuration Repository
- **Location**: `/home/seth/Software/dev/squelch`
- **Structure**:
  - `oauth-caddy-package/` - OAuth2 authentication package
  - `squelch-package/` - fail2ban security package
  - `config-backup/` - Production configuration backups
  - `CLAUDE.md` - Complete architecture documentation

## Architecture

```
Internet (lab.sethlakowske.com)
    |
    v
[Caddy :443] ────── Let's Encrypt HTTPS
    |
    ├─> /oauth2/*           ──> [oauth2-proxy :4180] Google Auth
    ├─> /good-neighbor/*    ──> [oauth2-proxy :4182] ──> Backend :3000
    ├─> /service-monitor/*  ──> [oauth2-proxy :4183] ──> Backend :8000
    └─> /*                  ──> Backend :8080 (public)
    |
    v
[fail2ban] monitors /var/log/caddy/access.log
    |
    v
[iptables] blocks malicious IPs
```

## Common Operations

### 1. Check Gateway Status

```bash
# Check all critical services
ssh pi "systemctl status caddy oauth2-proxy-google oauth2-proxy-good-neighbor oauth2-proxy-service-monitor fail2ban"

# Quick status check
ssh pi "systemctl is-active caddy oauth2-proxy-google fail2ban"

# Check if services are listening on expected ports
ssh pi "sudo ss -tlnp | grep -E '(443|4180|4182|4183|8000)'"
```

### 2. Manage Caddy

```bash
# Check Caddy status
ssh pi "systemctl status caddy"

# View Caddy configuration
ssh pi "cat /etc/caddy/Caddyfile"

# Validate Caddy configuration
ssh pi "sudo caddy validate --config /etc/caddy/Caddyfile"

# Reload Caddy (graceful, no downtime)
ssh pi "sudo systemctl reload caddy"

# Restart Caddy (brief downtime)
ssh pi "sudo systemctl restart caddy"

# View Caddy logs
ssh pi "journalctl -u caddy -n 100 --no-pager"
ssh pi "journalctl -u caddy -f"  # Follow logs

# View access logs (JSON format)
ssh pi "tail -f /var/log/caddy/access.log"
ssh pi "tail -100 /var/log/caddy/access.log | jq ."
```

### 3. Manage OAuth2-Proxy Services

```bash
# Check all OAuth proxy services
ssh pi "systemctl status oauth2-proxy-google"
ssh pi "systemctl status oauth2-proxy-good-neighbor"
ssh pi "systemctl status oauth2-proxy-service-monitor"

# Restart specific OAuth proxy
ssh pi "sudo systemctl restart oauth2-proxy-google"

# View OAuth proxy logs
ssh pi "journalctl -u oauth2-proxy-google -n 50 --no-pager"
ssh pi "journalctl -u oauth2-proxy-good-neighbor -f"

# Check OAuth proxy configuration
ssh pi "cat /etc/oauth2-proxy/google.cfg"
ssh pi "cat /etc/oauth2-proxy/good-neighbor.cfg"

# Test OAuth proxy health
ssh pi "curl -s http://localhost:4180/ping"
```

### 4. Manage fail2ban Security

```bash
# Check fail2ban status
ssh pi "sudo systemctl status fail2ban"

# View all active jails
ssh pi "sudo fail2ban-client status"

# View specific jail status
ssh pi "sudo fail2ban-client status sshd"
ssh pi "sudo fail2ban-client status squelch-caddy-auth"
ssh pi "sudo fail2ban-client status squelch-caddy-badbots"
ssh pi "sudo fail2ban-client status squelch-caddy-scan"

# List banned IPs
ssh pi "sudo squelch-ban list"
ssh pi "sudo squelch-ban list squelch-caddy-auth"

# Ban an IP manually
ssh pi "sudo squelch-ban ban 1.2.3.4 squelch-caddy-auth"

# Unban an IP
ssh pi "sudo squelch-ban unban 1.2.3.4"

# Check if IP is banned
ssh pi "sudo squelch-ban check 1.2.3.4"

# View fail2ban logs
ssh pi "sudo journalctl -u fail2ban -n 100 --no-pager"
ssh pi "sudo journalctl -u fail2ban | grep Ban"
```

### 5. Security Status Dashboard

```bash
# View comprehensive security status
ssh pi "sudo squelch-status"

# Real-time security monitoring
ssh pi "sudo squelch-monitor"

# Check recent authentication failures
ssh pi "sudo journalctl -u fail2ban --since '1 hour ago' | grep -E '(Ban|Found)'"

# View recent access patterns
ssh pi "tail -100 /var/log/caddy/access.log | jq -r '.request.remote_ip' | sort | uniq -c | sort -nr"
```

### 6. Add New Protected Route

To add a new service behind OAuth authentication:

1. **Verify backend service is running**:
   ```bash
   # Test backend health
   curl -s http://ubuntu-box.local:3001/health
   ```

2. **Create OAuth2-proxy configuration**:
   ```bash
   # SSH to gateway
   ssh pi

   # Create new OAuth config (based on template)
   sudo cp /etc/oauth2-proxy/good-neighbor.cfg.template /etc/oauth2-proxy/new-service.cfg

   # Edit configuration
   sudo nano /etc/oauth2-proxy/new-service.cfg
   # Update:
   # - http_address = "127.0.0.1:4184"  (new port)
   # - upstreams = ["http://ubuntu-box.local:3001/"]
   # - cookie_name = "_oauth2_proxy_new_service"
   # - redirect_url = "https://lab.sethlakowske.com/new-service/oauth2/callback"
   ```

3. **Create systemd service**:
   ```bash
   sudo cat > /etc/systemd/system/oauth2-proxy-new-service.service << 'EOF'
[Unit]
Description=OAuth2 Proxy for New Service
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/bin/oauth2-proxy --config=/etc/oauth2-proxy/new-service.cfg
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

   # Enable and start service
   sudo systemctl daemon-reload
   sudo systemctl enable oauth2-proxy-new-service
   sudo systemctl start oauth2-proxy-new-service
   sudo systemctl status oauth2-proxy-new-service
   ```

4. **Update Caddyfile**:
   ```bash
   sudo nano /etc/caddy/Caddyfile

   # Add route (before the catch-all /* route):
   # route /new-service* {
   #   reverse_proxy localhost:4184
   # }
   ```

5. **Apply Caddy changes**:
   ```bash
   # Validate configuration
   sudo caddy validate --config /etc/caddy/Caddyfile

   # Reload Caddy (graceful)
   sudo systemctl reload caddy
   ```

6. **Verify setup**:
   ```bash
   # Test OAuth proxy
   curl -s http://localhost:4184/ping

   # Test public endpoint (should redirect to OAuth)
   curl -I https://lab.sethlakowske.com/new-service/
   ```

7. **Backup configuration**:
   ```bash
   # From local machine
   scp pi:/etc/caddy/Caddyfile ~/Software/dev/squelch/config-backup/caddy/
   scp pi:/etc/oauth2-proxy/new-service.cfg ~/Software/dev/squelch/config-backup/oauth2-proxy/
   ```

### 7. Add Public (Non-Authenticated) Route

For services that don't require OAuth:

1. **Update Caddyfile**:
   ```bash
   ssh pi "sudo nano /etc/caddy/Caddyfile"

   # Add route (order matters - more specific first):
   # route /public-api/* {
   #   reverse_proxy ubuntu-box.local:3002
   # }
   ```

2. **Reload Caddy**:
   ```bash
   ssh pi "sudo caddy validate --config /etc/caddy/Caddyfile && sudo systemctl reload caddy"
   ```

3. **Test**:
   ```bash
   curl -s https://lab.sethlakowske.com/public-api/health | jq .
   ```

### 8. Update Backend Port Mapping

To change where a route proxies to:

1. **For OAuth-protected routes**, update OAuth2-proxy config:
   ```bash
   ssh pi "sudo nano /etc/oauth2-proxy/good-neighbor.cfg"
   # Change: upstreams = ["http://ubuntu-box.local:NEW_PORT/"]

   ssh pi "sudo systemctl restart oauth2-proxy-good-neighbor"
   ```

2. **For public routes**, update Caddyfile:
   ```bash
   ssh pi "sudo nano /etc/caddy/Caddyfile"
   # Change reverse_proxy line

   ssh pi "sudo systemctl reload caddy"
   ```

### 9. View Current Route Configuration

```bash
# View Caddyfile routes
ssh pi "cat /etc/caddy/Caddyfile | grep -A 2 'route'"

# View all OAuth proxy upstreams
ssh pi "grep 'upstreams' /etc/oauth2-proxy/*.cfg"

# Show all listening services
ssh pi "sudo ss -tlnp | grep -E '(caddy|oauth2-proxy)'"
```

### 10. Analyze Traffic Patterns

```bash
# Top IPs accessing the server
ssh pi "tail -1000 /var/log/caddy/access.log | jq -r '.request.remote_ip' | sort | uniq -c | sort -nr | head -10"

# Most requested URIs
ssh pi "tail -1000 /var/log/caddy/access.log | jq -r '.request.uri' | sort | uniq -c | sort -nr | head -10"

# Failed authentication attempts (401/403)
ssh pi "tail -1000 /var/log/caddy/access.log | jq 'select(.status == 401 or .status == 403)'"

# Response time analysis
ssh pi "tail -1000 /var/log/caddy/access.log | jq -r '.duration' | awk '{sum+=\$1; count++} END {print \"Average:\", sum/count, \"seconds\"}'"

# Status code distribution
ssh pi "tail -1000 /var/log/caddy/access.log | jq -r '.status' | sort | uniq -c | sort -nr"
```

## Configuration Files Reference

### Critical Configuration Files

| File | Purpose | Service |
|------|---------|---------|
| `/etc/caddy/Caddyfile` | Main reverse proxy configuration | caddy |
| `/etc/oauth2-proxy/google.cfg` | Google OAuth for general use | oauth2-proxy-google |
| `/etc/oauth2-proxy/good-neighbor.cfg` | OAuth for good-neighbor service | oauth2-proxy-good-neighbor |
| `/etc/oauth2-proxy/service-monitor.cfg` | OAuth for service-monitor | oauth2-proxy-service-monitor |
| `/etc/fail2ban/jail.d/squelch.conf` | fail2ban jail configuration | fail2ban |
| `/etc/fail2ban/filter.d/squelch-*.conf` | fail2ban filters | fail2ban |
| `/var/log/caddy/access.log` | HTTP access logs (JSON) | caddy |

### Configuration Backup Location

All production configs should be backed up to:
```
~/Software/dev/squelch/config-backup/
  ├── caddy/
  │   ├── Caddyfile
  │   └── Caddyfile.template
  └── oauth2-proxy/
      ├── google.cfg
      ├── good-neighbor.cfg
      ├── service-monitor.cfg
      └── *.cfg.template
```

### Backup Workflow

```bash
# Backup current production configs
ssh pi "cat /etc/caddy/Caddyfile" > ~/Software/dev/squelch/config-backup/caddy/Caddyfile
ssh pi "cat /etc/oauth2-proxy/google.cfg" > ~/Software/dev/squelch/config-backup/oauth2-proxy/google.cfg

# Or use scp
scp pi:/etc/caddy/Caddyfile ~/Software/dev/squelch/config-backup/caddy/
scp pi:/etc/oauth2-proxy/*.cfg ~/Software/dev/squelch/config-backup/oauth2-proxy/

# Commit to git
cd ~/Software/dev/squelch
git add config-backup/
git commit -m "Backup production proxy configs"
git push
```

## Routing Patterns

### Current Routes (lab.sethlakowske.com)

Based on the production Caddyfile:

| Route | Auth | Backend | Port | Description |
|-------|------|---------|------|-------------|
| `/oauth2/*` | No | oauth2-proxy | 4180 | OAuth callback handler |
| `/good-neighbor*` | Yes (Google) | good-neighbor | 3000 | Protected service |
| `/service-monitor*` | Yes (Google) | service-monitor | 8000 | Protected monitoring |
| `/*` | No | default backend | 8080 | Public routes |

### Caddy Route Ordering

**IMPORTANT**: Caddy processes routes in order. More specific routes must come BEFORE catch-all routes:

```caddyfile
lab.sethlakowske.com {
    log {
        output file /var/log/caddy/access.log
    }

    # OAuth callback (most specific)
    route /oauth2/* {
        reverse_proxy localhost:4180
    }

    # Protected service routes
    route /good-neighbor* {
        reverse_proxy localhost:4182
    }

    route /service-monitor* {
        reverse_proxy localhost:4183
    }

    # Catch-all public routes (LAST)
    route /* {
        reverse_proxy localhost:8080
    }
}
```

## Security Monitoring

### fail2ban Jails

| Jail Name | Purpose | Trigger | Max Retry | Ban Time |
|-----------|---------|---------|-----------|----------|
| `sshd` | SSH brute force | Failed SSH login | 2 | 24h |
| `squelch-caddy-auth` | Auth failures | 401/403 responses | 5 | 1h+ |
| `squelch-caddy-badbots` | Bad bots/scanners | Attack paths | 2 | 1h+ |
| `squelch-caddy-scan` | Directory scanning | Multiple 404s | 3 | 1h+ |

### Ban Escalation

fail2ban uses progressive ban times:
- 1st offense: 1 hour
- 2nd offense: 2 hours
- 3rd offense: 4 hours
- Continues doubling up to max 168h (7 days)

### Monitoring Commands

```bash
# Real-time ban events
ssh pi "sudo journalctl -u fail2ban -f | grep Ban"

# Recently banned IPs
ssh pi "sudo journalctl -u fail2ban --since '1 hour ago' | grep 'Ban '"

# Ban statistics
ssh pi "sudo fail2ban-client status | grep 'Currently banned:'"

# Analyze attack patterns
ssh pi "tail -1000 /var/log/caddy/access.log | jq 'select(.status >= 400) | {ip: .request.remote_ip, status: .status, uri: .request.uri}'"
```

## Troubleshooting

### Problem: Service Not Accessible from Internet

1. **Check Caddy is running and listening**:
   ```bash
   ssh pi "systemctl status caddy"
   ssh pi "sudo ss -tlnp | grep :443"
   ```

2. **Check route configuration**:
   ```bash
   ssh pi "cat /etc/caddy/Caddyfile | grep -A 3 'route /your-service'"
   ```

3. **Test from gateway server**:
   ```bash
   ssh pi "curl -I http://localhost:4180/ping"  # OAuth proxy
   ssh pi "curl -I https://localhost/your-service/"  # Through Caddy
   ```

4. **Check DNS**:
   ```bash
   dig lab.sethlakowske.com
   ```

5. **Check firewall**:
   ```bash
   ssh pi "sudo iptables -L -n | grep -E '(443|80)'"
   ```

### Problem: OAuth Loop/Redirect Issues

1. **Check OAuth proxy is running**:
   ```bash
   ssh pi "systemctl status oauth2-proxy-google"
   ```

2. **Verify OAuth config**:
   ```bash
   ssh pi "grep redirect_url /etc/oauth2-proxy/google.cfg"
   # Should match: https://lab.sethlakowske.com/oauth2/callback
   ```

3. **Check cookie settings**:
   ```bash
   ssh pi "grep -E '(cookie_secure|cookie_domain)' /etc/oauth2-proxy/google.cfg"
   ```

4. **View OAuth logs**:
   ```bash
   ssh pi "journalctl -u oauth2-proxy-google -n 50 --no-pager"
   ```

### Problem: fail2ban Banning Legitimate IPs

1. **Check which jail banned the IP**:
   ```bash
   ssh pi "sudo squelch-ban check 192.168.1.100"
   ```

2. **Review why IP was banned**:
   ```bash
   ssh pi "sudo journalctl -u fail2ban | grep '192.168.1.100'"
   ```

3. **Unban the IP**:
   ```bash
   ssh pi "sudo squelch-ban unban 192.168.1.100"
   ```

4. **Add to ignore list** (if trusted):
   ```bash
   ssh pi "sudo nano /etc/fail2ban/jail.d/squelch.conf"
   # Add to ignoreip: 192.168.1.100
   ssh pi "sudo systemctl restart fail2ban"
   ```

### Problem: Backend Service Not Receiving Traffic

1. **Check backend is running**:
   ```bash
   curl -s http://ubuntu-box.local:3000/health
   ```

2. **Verify OAuth proxy upstream**:
   ```bash
   ssh pi "grep upstreams /etc/oauth2-proxy/good-neighbor.cfg"
   ```

3. **Test OAuth proxy directly**:
   ```bash
   ssh pi "curl -I http://localhost:4182/"
   ```

4. **Check Caddy route**:
   ```bash
   ssh pi "cat /etc/caddy/Caddyfile | grep -A 2 'good-neighbor'"
   ```

### Problem: SSL Certificate Issues

1. **Check certificate status**:
   ```bash
   ssh pi "journalctl -u caddy | grep -i certificate"
   ```

2. **Verify DNS is correct**:
   ```bash
   dig lab.sethlakowske.com
   # Should point to public IP
   ```

3. **Check port 80 is accessible** (needed for Let's Encrypt):
   ```bash
   ssh pi "sudo ss -tlnp | grep :80"
   ```

4. **Force certificate renewal**:
   ```bash
   ssh pi "sudo systemctl restart caddy"
   ```

## Reference Documentation

Complete architecture documentation available at:
```
~/Software/dev/squelch/CLAUDE.md
```

This includes:
- Detailed component interactions
- Security architecture (defense-in-depth)
- Attack scenario walkthroughs
- Configuration patterns
- Best practices
- Maintenance procedures

## Integration with Other Skills

### network-admin Skill
- Use network-admin for general server management commands
- reverse-proxy focuses specifically on traffic/proxy configuration
- Coordinate for service deployments requiring both skills

### service-monitor Skill
- service-monitor itself is protected by OAuth via this gateway
- Access at: https://lab.sethlakowske.com/service-monitor/
- Use service-monitor skill for monitoring operations
- Use reverse-proxy skill for routing configuration

## Usage Guidelines

### When to Use reverse-proxy

Use this skill for:
- Configuring new public-facing routes
- Managing OAuth authentication for services
- Analyzing traffic patterns and security events
- Troubleshooting access issues from internet
- Managing fail2ban security
- Updating SSL/TLS configuration
- Monitoring gateway health

### When to Delegate to Remote Claude

For complex gateway changes:
```bash
ssh pi -t "cd ~/Software/dev/squelch && lfg"
# Claude on gateway has direct access to all configs and logs
```

### Best Practices

1. **Always backup configs before changes**:
   ```bash
   scp pi:/etc/caddy/Caddyfile ~/Software/dev/squelch/config-backup/caddy/
   ```

2. **Validate Caddy config before reload**:
   ```bash
   ssh pi "sudo caddy validate --config /etc/caddy/Caddyfile"
   ```

3. **Use reload instead of restart** (when possible):
   ```bash
   ssh pi "sudo systemctl reload caddy"  # Graceful, no downtime
   ```

4. **Monitor logs after changes**:
   ```bash
   ssh pi "journalctl -u caddy -f"
   ```

5. **Document route changes** in git commits

6. **Test from multiple locations**:
   - From gateway: `ssh pi "curl http://localhost:PORT"`
   - From LAN: `curl http://raspberrypi.local:PORT`
   - From internet: `curl https://lab.sethlakowske.com/route`

## Common Workflows

### Workflow 1: Deploy New Protected Service

1. Service is running on ubuntu-box:3001
2. Create OAuth proxy config on gateway
3. Create systemd service for OAuth proxy
4. Update Caddyfile with new route
5. Reload Caddy
6. Test from internet
7. Backup configs to git

### Workflow 2: Investigate Security Event

1. Check fail2ban status: `ssh pi "sudo squelch-status"`
2. Review banned IPs: `ssh pi "sudo squelch-ban list"`
3. Analyze access logs: `ssh pi "tail -1000 /var/log/caddy/access.log | jq 'select(.status >= 400)'"`
4. Review fail2ban logs: `ssh pi "sudo journalctl -u fail2ban --since '1 hour ago'"`
5. Determine if legitimate or attack
6. Take action (unban or leave banned)

### Workflow 3: Update Backend Port

1. Verify new backend works: `curl http://ubuntu-box.local:NEW_PORT/health`
2. Update OAuth proxy config: edit `/etc/oauth2-proxy/SERVICE.cfg`
3. Restart OAuth proxy: `sudo systemctl restart oauth2-proxy-SERVICE`
4. Test: `curl https://lab.sethlakowske.com/service/`
5. Backup config

### Workflow 4: Add Temporary Public Route

1. Edit Caddyfile: `ssh pi "sudo nano /etc/caddy/Caddyfile"`
2. Add route BEFORE catch-all
3. Validate: `ssh pi "sudo caddy validate --config /etc/caddy/Caddyfile"`
4. Reload: `ssh pi "sudo systemctl reload caddy"`
5. Test: `curl https://lab.sethlakowske.com/new-route/`

## Examples

### Example 1: Check Gateway Health

```bash
# One-liner health check
ssh pi "systemctl is-active caddy oauth2-proxy-google fail2ban && echo 'Gateway healthy'"

# Detailed status
ssh pi "sudo squelch-status"
```

### Example 2: Analyze Failed Auth Attempts

```bash
# Recent 401/403 responses
ssh pi "tail -500 /var/log/caddy/access.log | jq 'select(.status == 401 or .status == 403) | {time: .ts, ip: .request.remote_ip, uri: .request.uri, status: .status}'"

# IPs with most auth failures
ssh pi "tail -1000 /var/log/caddy/access.log | jq -r 'select(.status == 401) | .request.remote_ip' | sort | uniq -c | sort -nr"
```

### Example 3: Emergency IP Ban

```bash
# Ban IP immediately in all relevant jails
ssh pi "sudo squelch-ban ban 1.2.3.4 squelch-caddy-auth"
ssh pi "sudo squelch-ban ban 1.2.3.4 squelch-caddy-badbots"
ssh pi "sudo squelch-ban ban 1.2.3.4 squelch-caddy-scan"

# Verify ban
ssh pi "sudo squelch-ban check 1.2.3.4"
```

### Example 4: View Current Configuration

```bash
# Show all routes and their backends
ssh pi "cat /etc/caddy/Caddyfile | grep -E '(route|reverse_proxy)'"

# Show all OAuth proxy ports and upstreams
ssh pi "grep -E '(http_address|upstreams)' /etc/oauth2-proxy/*.cfg"

# Show all active services
ssh pi "systemctl list-units --type=service --state=running | grep -E '(caddy|oauth2-proxy|fail2ban)'"
```
