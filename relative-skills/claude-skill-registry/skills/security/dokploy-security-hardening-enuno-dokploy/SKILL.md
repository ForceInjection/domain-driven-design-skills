---
name: dokploy-security-hardening
description: "Security best practices for Dokploy templates: secrets management, network isolation, least privilege, image security, and hardening recommendations."
version: 1.0.0
author: Home Lab Infrastructure Team
---

# Dokploy Security Hardening

## When to Use This Skill

- When reviewing templates for security issues
- When adding security configurations to templates
- When user asks about "security" or "hardening"
- As final review step before template completion

## When NOT to Use This Skill

- For application-level security (auth, input validation)
- For host-level security (not managed by Dokploy)

## Prerequisites

- Completed docker-compose.yml
- Understanding of application security requirements

---

## Security Principles

1. **Least Privilege**: Services only have access they need
2. **Defense in Depth**: Multiple security layers
3. **Secrets Protection**: No hardcoded secrets
4. **Network Isolation**: Internal services not exposed
5. **Image Security**: Pinned versions, trusted sources

---

## Core Patterns

### Pattern 1: Secrets Management

**Never Hardcode Secrets:**
```yaml
# WRONG - Secret in compose file
environment:
  DATABASE_PASSWORD: supersecretpassword123

# CORRECT - Use variable with required syntax
environment:
  DATABASE_PASSWORD: ${DATABASE_PASSWORD:?Set database password}
```

**Use Proper Variable Generation in template.toml:**
```toml
[variables]
# Passwords - random alphanumeric
db_password = "${password:32}"

# Secrets - base64 encoded
secret_key = "${base64:64}"
jwt_secret = "${base64:48}"

# Internal tokens - high entropy
internal_token = "${password:48}"
```

**Mask Sensitive Output:**
```yaml
# In docker-compose, sensitive vars are hidden in Dokploy UI
environment:
  API_KEY: ${API_KEY:?Set API key}  # Treated as sensitive
```

### Pattern 2: Network Isolation

**Database/Cache Services (Internal Only):**
```yaml
services:
  postgres:
    image: postgres:16-alpine
    networks:
      - app-net  # Internal ONLY - no dokploy-network
    # NO labels - not exposed via Traefik

  redis:
    image: redis:7-alpine
    networks:
      - app-net  # Internal ONLY
```

**Web Services (External + Internal):**
```yaml
services:
  app:
    image: myapp:1.0.0
    networks:
      - app-net        # Internal (to reach database)
      - dokploy-network # External (for Traefik)
    labels:
      - "traefik.enable=true"
      # ... routing labels
```

**Network Definition:**
```yaml
networks:
  app-net:
    driver: bridge
    # Internal network, not externally accessible
  dokploy-network:
    external: true
    # Managed by Dokploy, shared with Traefik
```

### Pattern 3: Image Security

**Pin Image Versions:**
```yaml
# CORRECT - Specific versions
image: postgres:16-alpine
image: mongo:7
image: redis:7-alpine
image: wardpearce/paaster:3.1.7

# WRONG - Floating tags
image: postgres:latest
image: mongo
image: myapp  # Implies :latest
```

**Use Official/Trusted Images:**
```yaml
# Prefer official images
image: postgres:16-alpine          # Official
image: redis:7-alpine              # Official
image: mongo:7                     # Official

# For third-party, use verified sources
image: ghcr.io/paperless-ngx/paperless-ngx:2.13  # GitHub verified
image: codeberg.org/forgejo/forgejo:9             # Codeberg verified
```

**Alpine Images (Smaller Attack Surface):**
```yaml
# Prefer Alpine variants when available
image: postgres:16-alpine  # vs postgres:16
image: redis:7-alpine      # vs redis:7
image: node:20-alpine      # vs node:20
```

### Pattern 4: Container Security

**Read-Only Filesystem (Where Possible):**
```yaml
services:
  app:
    image: myapp:1.0.0
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
    volumes:
      - app-data:/app/data  # Only writable location
```

**Drop Capabilities:**
```yaml
services:
  app:
    image: myapp:1.0.0
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if needed for port < 1024
```

**No Privileged Mode:**
```yaml
# NEVER use privileged mode for application containers
services:
  app:
    image: myapp:1.0.0
    # privileged: true  # NEVER DO THIS
```

### Pattern 5: Resource Limits

**Memory and CPU Limits:**
```yaml
services:
  app:
    image: myapp:1.0.0
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "1.0"
        reservations:
          memory: 128M
          cpus: "0.25"
```

### Pattern 6: Health Check Security

**Don't Expose Sensitive Info:**
```yaml
healthcheck:
  # CORRECT - Simple endpoint
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]

  # WRONG - Exposes internal state
  test: ["CMD", "curl", "-f", "http://localhost:8080/debug/vars"]
```

### Pattern 7: Security Headers (Traefik Middleware)

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.app.rule=Host(`${DOMAIN}`)"
  - "traefik.http.routers.app.entrypoints=websecure"
  - "traefik.http.routers.app.tls.certresolver=letsencrypt"
  - "traefik.http.routers.app.middlewares=security-headers@docker"

  # Security headers middleware
  - "traefik.http.middlewares.security-headers.headers.stsSeconds=31536000"
  - "traefik.http.middlewares.security-headers.headers.stsIncludeSubdomains=true"
  - "traefik.http.middlewares.security-headers.headers.contentTypeNosniff=true"
  - "traefik.http.middlewares.security-headers.headers.frameDeny=true"
  - "traefik.http.middlewares.security-headers.headers.browserXssFilter=true"
  - "traefik.http.middlewares.security-headers.headers.referrerPolicy=strict-origin-when-cross-origin"

  - "traefik.http.services.app.loadbalancer.server.port=8080"
  - "traefik.docker.network=dokploy-network"
```

---

## Security Checklist

### Secrets
- [ ] No hardcoded passwords in compose file
- [ ] All secrets use `${VAR:?message}` syntax
- [ ] Passwords generated with `${password:N}` in template.toml
- [ ] Encryption keys generated with `${base64:N}`
- [ ] API keys from external services left blank for user input

### Network
- [ ] Databases on internal network only
- [ ] Caches on internal network only
- [ ] Only web-facing services on dokploy-network
- [ ] No exposed debug/admin ports

### Images
- [ ] All images have pinned versions
- [ ] No `:latest` tags
- [ ] Using official or verified images
- [ ] Alpine variants where available

### Configuration
- [ ] Sensitive env vars not logged
- [ ] Health endpoints don't expose sensitive data
- [ ] Debug mode disabled by default
- [ ] Production-safe defaults

---

## Security Review Template

When reviewing a template, check each category:

```markdown
## Security Review: [Template Name]

### Secrets Management
- [ ] Secrets: All secrets use variable syntax
- [ ] Passwords: Generated in template.toml
- [ ] External APIs: Left blank for user input

### Network Isolation
- [ ] Databases: Internal network only
- [ ] Web services: dokploy-network attached
- [ ] No debug ports exposed

### Image Security
- [ ] Versions: All images pinned
- [ ] Sources: Official/verified images
- [ ] Alpine: Used where available

### Container Security
- [ ] Privileges: No privileged mode
- [ ] Resources: Limits defined (optional but recommended)
- [ ] Health: Secure health endpoints

### HTTPS/TLS
- [ ] TLS: Using letsencrypt certresolver
- [ ] Entrypoint: websecure (HTTPS)
- [ ] Headers: Security headers middleware (recommended)

### Findings
- [ ] Issue 1: [Description] - [Severity]
- [ ] Issue 2: [Description] - [Severity]

### Recommendations
1. [Recommendation]
2. [Recommendation]
```

---

## Complete Example: Secure Template

```yaml
services:
  app:
    image: myapp:1.2.3  # Pinned version
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      # Domain (required)
      APP_DOMAIN: ${DOMAIN:?Set your domain}
      APP_URL: https://${DOMAIN}

      # Database (secure connection)
      DATABASE_URL: postgresql://${DB_USER:-app}:${DB_PASS}@postgres:5432/${DB_NAME:-app}

      # Secrets (all use variables)
      SECRET_KEY: ${SECRET_KEY:?Set secret key}
      JWT_SECRET: ${JWT_SECRET:?Set JWT secret}

      # Security settings
      DEBUG: "false"  # Production default
      SECURE_COOKIES: "true"
    networks:
      - app-net
      - dokploy-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`${DOMAIN}`)"
      - "traefik.http.routers.app.entrypoints=websecure"  # HTTPS only
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
      - "traefik.http.routers.app.middlewares=security-headers@docker"
      # Security headers
      - "traefik.http.middlewares.security-headers.headers.stsSeconds=31536000"
      - "traefik.http.middlewares.security-headers.headers.stsIncludeSubdomains=true"
      - "traefik.http.middlewares.security-headers.headers.contentTypeNosniff=true"
      - "traefik.http.middlewares.security-headers.headers.frameDeny=true"
      - "traefik.http.services.app.loadbalancer.server.port=8080"
      - "traefik.docker.network=dokploy-network"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "1.0"

  postgres:
    image: postgres:16-alpine  # Alpine, pinned version
    restart: always
    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: ${DB_NAME:-app}
      POSTGRES_USER: ${DB_USER:-app}
      POSTGRES_PASSWORD: ${DB_PASS:?Set database password}
    networks:
      - app-net  # Internal ONLY
    # NO dokploy-network - not exposed
    # NO Traefik labels - not routed
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-app} -d ${DB_NAME:-app}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

volumes:
  postgres-data:
    driver: local

networks:
  app-net:
    driver: bridge
  dokploy-network:
    external: true
```

---

## Common Pitfalls

### Pitfall 1: Database on external network
**Issue**: Database accessible to other containers
**Solution**: Only connect to internal app-net

### Pitfall 2: Debug enabled in production
**Issue**: Exposes sensitive information
**Solution**: Default DEBUG to "false"

### Pitfall 3: Floating image tags
**Issue**: Unexpected updates, security regressions
**Solution**: Pin all image versions

### Pitfall 4: Hardcoded secrets in compose
**Issue**: Secrets in version control
**Solution**: Use `${VAR:?message}` syntax

---

## Integration

### Skills-First Approach (v2.0+)

This skill is part of the **skills-first architecture** - loaded during Validation phase (Phase 4) to perform security review of generated templates.

### Related Skills
- `dokploy-compose-structure`: Network setup
- `dokploy-environment-config`: Secret handling
- `dokploy-cloudflare-integration`: Zero Trust

### Invoked By
- `/dokploy-create` command: Phase 4 (Validation) - Step 1

### Order in Workflow (Progressive Loading)
1-3. Phase 3: Generation skills (all files created)
4. **This skill**: Security review and hardening (Phase 4, Step 1)
5. `dokploy-template-validation`: Convention compliance validation
6. `docker compose config`: Final syntax validation

See: `.claude/commands/dokploy-create.md` for full workflow
