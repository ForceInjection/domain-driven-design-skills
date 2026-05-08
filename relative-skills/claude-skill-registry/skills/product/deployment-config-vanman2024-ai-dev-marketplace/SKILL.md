---
name: deployment-config
description: Vercel deployment configuration and optimization for Next.js applications including vercel.json setup, environment variables, build optimization, edge functions, and deployment troubleshooting. Use when deploying to Vercel, configuring deployment settings, optimizing build performance, setting up environment variables, configuring edge functions, or when user mentions Vercel deployment, production setup, build errors, or deployment optimization.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Deployment Configuration

**Purpose:** Configure and optimize Next.js deployments on Vercel with automated validation and best practices.

**Activation Triggers:**
- Deployment failures or errors
- Build performance optimization needed
- Environment variable configuration
- Edge function setup
- vercel.json configuration
- Production deployment preparation
- Custom domain configuration

**Key Resources:**
- `scripts/validate-deployment.sh` - Validate deployment configuration
- `scripts/optimize-build.sh` - Analyze and optimize build performance
- `scripts/setup-env-vars.sh` - Interactive environment variable setup
- `scripts/test-edge-functions.sh` - Test edge function configuration
- `templates/vercel.json` - Production-ready vercel.json templates
- `templates/env-template.md` - Environment variable documentation
- `examples/deployment-patterns.md` - Common deployment scenarios

## Deployment Workflow

### 1. Pre-Deployment Validation

Validate configuration before deploying:

```bash
# Full deployment validation
./scripts/validate-deployment.sh

# Checks performed:
# - vercel.json syntax and schema
# - Environment variables documented
# - Build command configuration
# - Output directory exists
# - Framework detection correct
# - No hardcoded secrets in code
```

### 2. Configure vercel.json

Choose appropriate template based on needs:

```bash
# Generate vercel.json from template
cp templates/vercel.json vercel.json

# Templates available:
# - basic.vercel.json         → Minimal configuration
# - optimized.vercel.json     → Performance optimized
# - edge-functions.vercel.json → With edge/middleware
# - monorepo.vercel.json      → Monorepo setup
```

**Key Configuration Options:**

**Build Settings:**
- `buildCommand` - Override build command (default: `next build`)
- `installCommand` - Custom install command or skip with `""`
- `outputDirectory` - Build output location (default: `.next`)
- `framework` - Force framework detection (usually auto-detected)

**Routing:**
- `cleanUrls` - Remove .html extensions (true/false)
- `trailingSlash` - Enforce trailing slash behavior
- `redirects` - 301/302/307/308 redirect rules
- `rewrites` - Internal URL rewrites
- `headers` - Custom response headers

**Functions:**
- `functions` - Configure memory, duration, runtime per function
- `regions` - Deployment regions (default: iad1)
- Edge runtime for specific routes

### 3. Environment Variables

```bash
# Interactive setup
./scripts/setup-env-vars.sh

# Guided process:
# 1. Identifies required variables from code
# 2. Categorizes by environment (dev/preview/prod)
# 3. Generates .env.local and .env.example
# 4. Provides Vercel CLI commands for upload
```

**Best Practices:**
- Never commit `.env.local` or `.env.production`
- Always commit `.env.example` (no values)
- Use different values per environment
- Prefix public variables with `NEXT_PUBLIC_`
- Document all variables in `templates/env-template.md`

**Upload to Vercel:**
```bash
# Production
vercel env add VARIABLE_NAME production

# Preview
vercel env add VARIABLE_NAME preview

# Development
vercel env add VARIABLE_NAME development

# Pull to local
vercel env pull .env.local
```

### 4. Build Optimization

```bash
# Analyze build performance
./scripts/optimize-build.sh

# Provides:
# - Bundle size analysis
# - Build time breakdown
# - Optimization recommendations
# - Tree-shaking opportunities
# - Code-splitting suggestions
```

**Common Optimizations:**

**Image Optimization:**
```json
{
  "images": {
    "domains": ["cdn.example.com"],
    "formats": ["image/avif", "image/webp"],
    "minimumCacheTTL": 60
  }
}
```

**Function Configuration:**
```json
{
  "functions": {
    "app/api/**/*.ts": {
      "memory": 1024,
      "maxDuration": 10
    }
  }
}
```

**Build Cache:**
- Ensure `node_modules/.cache` is in .gitignore
- Use Vercel's automatic caching
- Enable SWC for faster builds (default in Next.js 12+)

### 5. Edge Functions Setup

```bash
# Test edge function configuration
./scripts/test-edge-functions.sh

# Validates:
# - Edge runtime compatibility
# - No Node.js-specific APIs
# - Size limits (1MB compressed)
# - Cold start performance
```

**Edge Configuration in next.config.js:**
```javascript
export const runtime = 'edge'
export const preferredRegion = 'iad1'
```

**Common Edge Use Cases:**
- A/B testing and feature flags
- Authentication/authorization
- Geo-based content
- Rate limiting
- Request/response transformation

## Deployment Methods

### Git Integration (Recommended)

```bash
# Connect Git repository via Vercel Dashboard
# Automatic deployments on:
# - main/master → Production
# - other branches → Preview

# Manual trigger via commit
git push origin main
```

### Vercel CLI

```bash
# Install CLI
npm i -g vercel

# Preview deployment
vercel

# Production deployment
vercel --prod

# With environment
vercel --prod --env NEXT_PUBLIC_API_URL=https://api.example.com
```

### Deploy Hooks

Custom deployment triggers without Git push:

```bash
# Create hook in Vercel Dashboard → Settings → Git → Deploy Hooks
# Then trigger via HTTP:
curl -X POST https://api.vercel.com/v1/integrations/deploy/[hook-id]
```

## Troubleshooting

### Build Failures

**Module not found:**
```bash
# Verify all dependencies in package.json
npm install --frozen-lockfile

# Check for case-sensitive import issues
# Vercel is case-sensitive, local dev may not be
```

**Out of memory:**
```json
{
  "builds": [{
    "src": "package.json",
    "use": "@vercel/next",
    "config": {
      "maxLambdaSize": "50mb"
    }
  }]
}
```

**Build timeout:**
- Default: 15 minutes (Hobby), 45 minutes (Pro)
- Optimize build with code-splitting
- Use incremental static regeneration
- Remove unnecessary dependencies

### Environment Variable Issues

```bash
# Verify variables are set
vercel env ls

# Check variable is available
vercel env pull .env.local
cat .env.local

# Common mistakes:
# - Forgot NEXT_PUBLIC_ prefix for client-side
# - Set in wrong environment (dev/preview/prod)
# - Contains quotes or spaces incorrectly
```

### Function Errors

**Function size exceeded:**
- Individual function limit: 50MB
- Check dependencies with `vercel build`
- Use dynamic imports to reduce bundle size
- Split large functions into smaller ones

**Function timeout:**
- Hobby: 10s, Pro: 60s, Enterprise: 900s
- Optimize database queries
- Use edge functions for faster response
- Implement proper caching

### Deployment URL Issues

**Custom domain not working:**
```bash
# Verify DNS settings
dig yourdomain.com

# Should show:
# A record → 76.76.21.21
# or CNAME → cname.vercel-dns.com
```

**Preview URLs:**
- Format: `project-git-branch-team.vercel.app`
- Always HTTPS
- Unique per commit
- Expires based on plan limits

## Configuration Examples

### Basic Production Setup

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "buildCommand": "next build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        }
      ]
    }
  ]
}
```

### Monorepo Configuration

```json
{
  "buildCommand": "cd ../.. && npm run build --filter=web",
  "installCommand": "npm install --prefix=../.. --frozen-lockfile",
  "outputDirectory": ".next"
}
```

### Advanced Rewrites

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://api.example.com/:path*"
    },
    {
      "source": "/blog/:slug",
      "destination": "/news/:slug"
    }
  ]
}
```

## Resources

**Scripts:** All scripts in `scripts/` are executable and include:
- `validate-deployment.sh` - Pre-deployment validation
- `optimize-build.sh` - Build performance analysis
- `setup-env-vars.sh` - Environment variable configuration
- `test-edge-functions.sh` - Edge function testing
- `check-bundle-size.sh` - Bundle analysis

**Templates:** `templates/` contains:
- Multiple vercel.json presets
- Environment variable documentation template
- Security headers configuration
- CORS configuration examples

**Examples:** `examples/deployment-patterns.md` includes:
- Multi-environment setup
- Monorepo deployment
- Custom domain configuration
- Edge function patterns
- Deployment automation workflows

---

**Platform:** Vercel
**Framework:** Next.js 13+ (App Router and Pages Router)
**CLI Version:** Latest Vercel CLI
**Version:** 1.0.0
