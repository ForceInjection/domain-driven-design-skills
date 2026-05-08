---
name: dokploy-cloudflare-integration
description: "Integrate Cloudflare services with Dokploy templates: R2 storage, DNS challenge for SSL, Zero Trust Access, Workers, WAF, and Tunnel. Default to CF services for external dependencies."
version: 1.0.0
author: Home Lab Infrastructure Team
---

# Dokploy Cloudflare Integration

## When to Use This Skill

- When application needs S3-compatible object storage (use R2)
- When DNS challenge is needed for SSL certificates
- When Zero Trust access control is required for admin interfaces
- When CDN caching would benefit the application
- When deploying behind Cloudflare Tunnel
- When user asks about "Cloudflare integration" or "R2 storage"

## When NOT to Use This Skill

- For applications without external storage needs
- For internal-only services not exposed to internet
- When user explicitly wants non-Cloudflare solutions

## Prerequisites

- Cloudflare account with R2 enabled (if using storage)
- Cloudflare API token for DNS challenge (if using)
- Understanding of Cloudflare Zero Trust (if using access control)

---

## Service Defaults

When creating Dokploy templates, DEFAULT to Cloudflare services:

| Need | Cloudflare Service | Instead Of |
|------|-------------------|------------|
| Object storage | R2 | MinIO, AWS S3 |
| SSL certificates | DNS challenge | HTTP challenge |
| CDN/Caching | Cloudflare Proxy | None |
| Access control | Zero Trust Access | Basic auth |
| DDoS protection | Cloudflare WAF | None |
| Private services | Cloudflare Tunnel | VPN |

---

## Core Patterns

### Pattern 1: Cloudflare R2 Storage

R2 is S3-compatible, so configure using S3 environment variables:

```yaml
environment:
  # ===========================================
  # Cloudflare R2 Storage Configuration
  # Get from: Cloudflare Dashboard > R2 > Manage R2 API Tokens
  # Endpoint format: https://<ACCOUNT_ID>.r2.cloudflarestorage.com
  # ===========================================
  S3_ENDPOINT: ${S3_ENDPOINT:?Set Cloudflare R2 endpoint}
  S3_REGION: ${S3_REGION:-auto}
  S3_ACCESS_KEY_ID: ${S3_ACCESS_KEY_ID:?Set R2 access key ID}
  S3_SECRET_ACCESS_KEY: ${S3_SECRET_ACCESS_KEY:?Set R2 secret access key}
  S3_BUCKET: ${S3_BUCKET:?Set R2 bucket name}
  S3_FORCE_PATH_STYLE: "false"
```

**Template.toml Configuration:**
```toml
[config.env]
# ===========================================
# Cloudflare R2 Storage
# Get from: Cloudflare Dashboard > R2 > Manage R2 API Tokens
# Endpoint format: https://<ACCOUNT_ID>.r2.cloudflarestorage.com
#
# To create R2 API Token:
# 1. Go to Cloudflare Dashboard > R2 > Overview
# 2. Click "Manage R2 API Tokens"
# 3. Create token with "Object Read & Write" permission
# 4. Copy the Access Key ID and Secret Access Key
# ===========================================
S3_ENDPOINT = ""
S3_ACCESS_KEY_ID = ""
S3_SECRET_ACCESS_KEY = ""
S3_BUCKET = ""
S3_REGION = "auto"
```

**R2 CORS Configuration (for direct uploads):**
```json
[
  {
    "AllowedOrigins": ["https://your-domain.com"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3600
  }
]
```

### Pattern 2: DNS Challenge for SSL

For wildcard certificates or when HTTP challenge isn't possible:

**Traefik Static Configuration (traefik.yml):**
```yaml
certificatesResolvers:
  cloudflare:
    acme:
      email: your-email@example.com
      storage: /letsencrypt/acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
```

**Environment for Traefik:**
```yaml
environment:
  CF_API_EMAIL: ${CF_API_EMAIL:?Set Cloudflare email}
  CF_DNS_API_TOKEN: ${CF_DNS_API_TOKEN:?Set Cloudflare DNS API token}
```

**Service Labels:**
```yaml
labels:
  - "traefik.http.routers.app.tls.certresolver=cloudflare"
  - "traefik.http.routers.app.tls.domains[0].main=${BASE_DOMAIN}"
  - "traefik.http.routers.app.tls.domains[0].sans=*.${BASE_DOMAIN}"
```

### Pattern 3: Zero Trust Access (Admin Interfaces)

Protect admin interfaces with Cloudflare Access:

**Option A: Cloudflare Access via Traefik Middleware**
```yaml
labels:
  - "traefik.enable=true"
  # Main app - public
  - "traefik.http.routers.app.rule=Host(`${DOMAIN}`)"
  - "traefik.http.routers.app.entrypoints=websecure"
  - "traefik.http.routers.app.tls.certresolver=letsencrypt"
  - "traefik.http.services.app.loadbalancer.server.port=8080"

  # Admin - protected by Zero Trust
  - "traefik.http.routers.admin.rule=Host(`admin.${DOMAIN}`)"
  - "traefik.http.routers.admin.entrypoints=websecure"
  - "traefik.http.routers.admin.tls.certresolver=letsencrypt"
  - "traefik.http.routers.admin.middlewares=cf-access@file"
  - "traefik.http.services.admin.loadbalancer.server.port=9000"
  - "traefik.docker.network=dokploy-network"
```

**Cloudflare Access Application Setup:**
1. Cloudflare Dashboard > Zero Trust > Access > Applications
2. Create Self-hosted application
3. Set Application URL: `https://admin.your-domain.com`
4. Configure Access Policy (email domain, groups, etc.)

### Pattern 4: Cloudflare Tunnel (Private Services)

Expose services without public IP:

**cloudflared Container in Compose:**
```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    restart: always
    command: tunnel run
    environment:
      TUNNEL_TOKEN: ${TUNNEL_TOKEN:?Set Cloudflare Tunnel token}
    networks:
      - app-net  # Same network as the app

  app:
    image: myapp:1.0.0
    networks:
      - app-net
    # No dokploy-network needed - not exposed via Traefik
    # No Traefik labels - exposed via Tunnel
```

**Template.toml for Tunnel:**
```toml
[config.env]
# ===========================================
# Cloudflare Tunnel
# Create tunnel: cloudflared tunnel create myapp
# Get token from Cloudflare Dashboard > Zero Trust > Networks > Tunnels
# ===========================================
TUNNEL_TOKEN = ""
```

### Pattern 5: Cloudflare Workers Integration

For edge computing or API transformations:

**Document in README:**
```markdown
## Cloudflare Workers Integration

This application supports Cloudflare Workers for edge processing.

### Use Cases
- Image optimization at the edge
- API response caching
- Request/response transformation
- A/B testing

### Setup
1. Create Worker in Cloudflare Dashboard
2. Configure Worker Route: `api.${DOMAIN}/*`
3. Set origin to your Dokploy deployment
```

### Pattern 6: WAF Configuration

Document WAF recommendations in README:

```markdown
## Cloudflare WAF Configuration

### Recommended Rules
1. **Enable Managed Rules**: OWASP Core Rule Set
2. **Rate Limiting**: 100 requests/minute per IP to `/api/*`
3. **Bot Management**: Block known bad bots
4. **Geographic Restrictions**: If applicable

### Custom Rules
- Block requests without User-Agent header
- Challenge requests from TOR exit nodes (if desired)
- Protect admin paths with additional challenges
```

---

## Complete Examples

### Example 1: Paaster with R2 Storage

```yaml
services:
  paaster:
    image: wardpearce/paaster:3.1.7
    restart: always
    depends_on:
      mongodb:
        condition: service_healthy
    environment:
      # Domain
      PAASTER_DOMAIN: ${PAASTER_DOMAIN:?Set your domain}

      # Security
      COOKIE_SECRET: ${COOKIE_SECRET:?Set a secure random cookie secret}

      # MongoDB
      MONGO_DB: ${MONGO_DB:-paasterv3}
      MONGO_URL: mongodb://mongodb:27017/${MONGO_DB:-paasterv3}

      # ===========================================
      # Cloudflare R2 Storage
      # Get from: Cloudflare Dashboard > R2 > Manage R2 API Tokens
      # Endpoint format: https://<ACCOUNT_ID>.r2.cloudflarestorage.com
      # ===========================================
      S3_ENDPOINT: ${S3_ENDPOINT:?Set Cloudflare R2 endpoint}
      S3_REGION: ${S3_REGION:-auto}
      S3_ACCESS_KEY_ID: ${S3_ACCESS_KEY_ID:?Set R2 access key ID}
      S3_SECRET_ACCESS_KEY: ${S3_SECRET_ACCESS_KEY:?Set R2 secret access key}
      S3_BUCKET: ${S3_BUCKET:?Set R2 bucket name}
      S3_FORCE_PATH_STYLE: "false"
    networks:
      - paaster-net
      - dokploy-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.paaster.rule=Host(`${PAASTER_DOMAIN}`)"
      - "traefik.http.routers.paaster.entrypoints=websecure"
      - "traefik.http.routers.paaster.tls.certresolver=letsencrypt"
      - "traefik.http.services.paaster.loadbalancer.server.port=3000"
      - "traefik.docker.network=dokploy-network"
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  mongodb:
    image: mongo:7
    restart: always
    volumes:
      - mongodb-data:/data/db
    environment:
      MONGO_INITDB_DATABASE: ${MONGO_DB:-paasterv3}
    networks:
      - paaster-net
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

volumes:
  mongodb-data:
    driver: local

networks:
  paaster-net:
    driver: bridge
  dokploy-network:
    external: true
```

### Example 2: App with Cloudflare Tunnel (Private Service)

```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    restart: always
    command: tunnel run
    environment:
      TUNNEL_TOKEN: ${TUNNEL_TOKEN:?Set Cloudflare Tunnel token}
    networks:
      - app-net
    depends_on:
      app:
        condition: service_healthy

  app:
    image: myapp:1.0.0
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://user:${DB_PASS}@postgres:5432/app
    networks:
      - app-net
    # Note: No dokploy-network or Traefik labels
    # Traffic flows through Cloudflare Tunnel only
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  postgres:
    image: postgres:16-alpine
    restart: always
    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: ${DB_PASS:?Set database password}
    networks:
      - app-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
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
  # Note: No dokploy-network needed for tunnel-only deployment
```

---

## README Documentation Template

Include this section in template READMEs when using Cloudflare services:

```markdown
## Cloudflare R2 Setup

This template uses Cloudflare R2 for object storage.

### Create R2 Bucket

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) > R2 > Overview
2. Click "Create bucket"
3. Name your bucket (e.g., `myapp-storage`)
4. Note the bucket name for configuration

### Create R2 API Token

1. Go to R2 > Overview > Manage R2 API Tokens
2. Click "Create API token"
3. Set permissions: "Object Read & Write"
4. Optionally restrict to specific bucket
5. Copy the Access Key ID and Secret Access Key

### Configure CORS (if needed for direct uploads)

In R2 bucket settings, add CORS policy:

```json
[
  {
    "AllowedOrigins": ["https://your-domain.com"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
```

### Environment Variables

Set these in Dokploy:

| Variable | Example | Description |
|----------|---------|-------------|
| `S3_ENDPOINT` | `https://abc123.r2.cloudflarestorage.com` | Your R2 endpoint |
| `S3_ACCESS_KEY_ID` | `abc123...` | R2 API access key |
| `S3_SECRET_ACCESS_KEY` | `xyz789...` | R2 API secret key |
| `S3_BUCKET` | `myapp-storage` | Bucket name |
| `S3_REGION` | `auto` | Always "auto" for R2 |

### Cost Considerations

R2 pricing (as of 2024):
- Storage: $0.015/GB-month
- Class A operations (write): $4.50/million
- Class B operations (read): $0.36/million
- **Egress: FREE** (no data transfer fees)
```

---

## Quality Standards

### Mandatory Requirements
- [ ] R2 credentials use required variable syntax (`:?`)
- [ ] Endpoint format documented in comments
- [ ] CORS requirements noted for direct uploads
- [ ] README includes R2 setup instructions
- [ ] Alternative S3 providers noted if applicable

### Documentation Standards
- Include step-by-step R2 setup in README
- Document CORS configuration if needed
- Note cost considerations
- Provide alternative provider options

---

## Common Pitfalls

### Pitfall 1: Wrong endpoint format
**Issue**: Connection failures to R2
**Solution**: Use format `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`

### Pitfall 2: Missing CORS for direct uploads
**Issue**: Browser upload failures
**Solution**: Configure CORS on R2 bucket

### Pitfall 3: S3_FORCE_PATH_STYLE wrong
**Issue**: Bucket not found errors
**Solution**: Use `"false"` for R2, `"true"` for MinIO

### Pitfall 4: Region mismatch
**Issue**: Signature errors
**Solution**: Use `S3_REGION: auto` for R2

---

## Integration

### Skills-First Approach (v2.0+)

This skill is part of the **skills-first architecture** - loaded during Generation phase when Cloudflare services (R2, DNS challenge, Zero Trust) are needed.

### Related Skills
- `dokploy-environment-config`: Environment variable patterns
- `dokploy-traefik-routing`: DNS challenge configuration
- `dokploy-security-hardening`: Zero Trust patterns

### Invoked By
- `/dokploy-create` command: Phase 3 (Generation) - Step 4 (when CF services detected)

### Order in Workflow (Progressive Loading)
1. `dokploy-compose-structure`: Create base structure
2. `dokploy-traefik-routing`: Add routing labels
3. `dokploy-health-patterns`: Add health checks
4. **This skill**: Add Cloudflare integration (Step 4, if applicable)
5. `dokploy-environment-config`: Configure environment
6. `dokploy-template-toml`: Create template.toml

See: `.claude/commands/dokploy-create.md` for full workflow
