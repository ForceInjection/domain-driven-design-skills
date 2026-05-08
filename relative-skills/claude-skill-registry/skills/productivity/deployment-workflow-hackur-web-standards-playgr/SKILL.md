---
name: deployment-workflow
description: Use this before committing code or when preparing for deployment. Provides pre-deployment checks, version bumping strategy, releases.json update pattern, common build failures, and deployment best practices.
---

# Deployment Workflow for FOSSAPP

Essential pre-deployment checks and deployment procedures to ensure safe, reliable deployments to production.

---

## ⚠️ Pre-Deployment: MANDATORY Checks

### 1. Run Pre-Deployment Script (REQUIRED)

```bash
./scripts/deploy-check.sh
```

**What it does:**
- ✓ TypeScript type checking (`npm run type-check`)
- ✓ ESLint validation (`npm run lint`)
- ✓ Playwright smoke tests (7 critical path tests)
- ✓ Production build test (`npm run build`)

**⚠️ CRITICAL:** Production builds are stricter than dev mode:
- ESLint runs with `--strict` mode
- TypeScript type checking is enforced
- All warnings become errors
- Missing dependencies are caught

**If ANY check fails:** STOP and fix errors before proceeding.

### 2. Common Build Errors to Fix

```typescript
// ❌ Unused variables (will fail build)
const { theme, resolvedTheme } = useTheme()  // theme unused

// ✅ Fix: Remove unused
const { resolvedTheme } = useTheme()

// ❌ Missing TypeScript properties
supplier_logo_dark: data.supplier_logo_dark  // Not in interface

// ✅ Fix: Add to interface
interface ProductDetail {
  supplier_logo_dark?: string
}

// ❌ React hooks exhaustive deps
useEffect(() => {
  loadProducts()
}, [supplierFilter])  // Missing loadProducts dependency

// ✅ Fix: Add eslint-disable if intentional
useEffect(() => {
  loadProducts()
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, [supplierFilter])
```

---

## Version Bumping Strategy

### Semantic Versioning (MAJOR.MINOR.PATCH)

| Type | When to Use | Example |
|------|-------------|---------|
| **patch** | Bug fixes, small changes | 1.1.3 → 1.1.4 |
| **minor** | New features, backwards compatible | 1.1.4 → 1.2.0 |
| **major** | Breaking changes | 1.2.0 → 2.0.0 |

### Version Bump Commands

```bash
# Patch version (bug fixes)
npm version patch

# Minor version (new features)
npm version minor

# Major version (breaking changes)
npm version major
```

### ⚠️ CRITICAL: Tag After Build Succeeds

**NEVER tag until build succeeds!**

```bash
# ❌ WRONG ORDER (what caused v1.1.4 issues)
npm version patch           # Creates tag
git push origin main --tags
# Build fails! Now tag points to broken code

# ✅ CORRECT ORDER
./scripts/deploy-check.sh   # Verify all checks pass first!
git add -A
git commit -m "..."
git push origin main
npm version patch           # Only tag after build succeeds
git push origin main --tags
```

---

## Updating What's New Dialog (releases.json)

### When to Update

**Update when:**
- ✅ New features added
- ✅ Significant UX changes
- ✅ User-visible improvements

**Skip when:**
- ❌ Bug fixes only
- ❌ Internal refactoring
- ❌ Dependency updates

### Format

Add new release to **TOP** of `src/data/releases.json`:

```json
{
  "releases": [
    {
      "version": "X.Y.Z",
      "date": "YYYY-MM-DD",
      "title": "Short Title (3-5 words)",
      "description": "One sentence summary.",
      "features": [
        "Feature 1",
        "Feature 2",
        "Feature 3"
      ],
      "tagline": "Memorable closing phrase."
    },
    // ... existing releases
  ]
}
```

**Example:**
```json
{
  "version": "1.9.0",
  "date": "2025-12-15",
  "title": "Advanced Search Filters",
  "description": "Powerful new search system with dynamic filters and taxonomy navigation.",
  "features": [
    "Three-tier search: Guided Finder + Smart Text + Technical Filters",
    "Context-aware filters prevent '0 results' dead ends",
    "Sub-200ms query performance on 56K+ products"
  ],
  "tagline": "Finding the perfect lighting product just got easier."
}
```

---

## Complete Deployment Workflow

### Step 1: Development & Testing

```bash
# 1. Make changes locally
# 2. Test in dev mode
npm run dev

# 3. Run pre-deployment checks (CRITICAL!)
./scripts/deploy-check.sh

# 4. Fix any errors that appear
# 5. Repeat until all checks pass
```

### Step 2: Update What's New (if applicable)

```bash
# Edit src/data/releases.json
# Add new release entry at TOP of array
```

### Step 3: Commit & Push

```bash
# Stage all changes
git add -A

# Commit with descriptive message
git commit -m "feat: description of changes

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to GitHub
git push origin main
```

### Step 4: Version Bump

```bash
# Only after successful build!
npm version patch  # or minor/major

# Push version commit and tag
git push origin main --tags
```

### Step 5: Deploy to Production

**Recommended:** Use `production-deployer` agent in Claude Code.

**Manual:**
```bash
# Deploy to VPS
ssh -i ~/.ssh/platon.key sysadmin@platon.titancnc.eu \
  "cd /opt/fossapp && ./deploy.sh v1.9.0"

# Verify deployment
curl https://main.fossapp.online/api/health
```

---

## Common Deployment Failures & Fixes

### Issue 1: "Module not found" Error

**Symptom:**
```
Module not found: Can't resolve '@radix-ui/react-icons'
```

**Cause:** Missing dependency when adding shadcn components

**Fix:**
```bash
npm install @radix-ui/react-icons
git add package.json package-lock.json
git commit -m "fix: add missing dependency"
git push origin main
```

### Issue 2: ESLint Errors in Production

**Symptom:**
```
Error: 'theme' is assigned a value but never used
```

**Cause:** Dev mode doesn't enforce ESLint strictly

**Fix:** Run `./scripts/deploy-check.sh` locally, fix all errors

### Issue 3: TypeScript Type Errors

**Symptom:**
```
Type error: Object literal may only specify known properties
```

**Cause:** Missing property in TypeScript interface

**Fix:** Update interface to match actual data structure

### Issue 4: Docker Build Failures

**Symptom:** Build succeeds locally but fails in Docker

**Cause:**
- Different Node.js version (local vs Docker)
- Missing environment variables
- Cached layers with old dependencies

**Fix:**
```bash
# On VPS: Clear Docker cache
ssh -i ~/.ssh/platon.key sysadmin@platon.titancnc.eu \
  "cd /opt/fossapp && docker system prune -a --volumes"

# Rebuild from scratch
./deploy.sh v1.9.0
```

---

## Pre-Deployment Checklist

Before running `npm version patch`:

- [ ] `./scripts/deploy-check.sh` passes all checks
  - [ ] TypeScript type-check passes
  - [ ] ESLint validation passes
  - [ ] Smoke tests pass (7 tests)
  - [ ] Production build succeeds
- [ ] All dependencies in package.json
- [ ] Changes committed and pushed to main
- [ ] Dev server tested (npm run dev)
- [ ] All features tested manually
- [ ] **What's New updated** (if user-facing changes)
  - Add new release to **top** of `src/data/releases.json`
- [ ] **Dashboard hints reviewed** (if new features added)
  - Review `src/data/hints.ts` for new feature hints

Before deploying to production:

- [ ] GitHub has latest code
- [ ] Version tag created and pushed
- [ ] Production environment variables set
- [ ] Database migrations applied (if any)
- [ ] Backup taken (if major changes)

After deployment:

- [ ] Health check passes: `curl https://main.fossapp.online/api/health`
- [ ] Manually test key features
- [ ] Check Docker logs for errors: `docker-compose logs -f`
- [ ] Monitor for first 5-10 minutes

---

## Git Best Practices

### Commit Message Convention

```bash
# Format: type: description

git commit -m "feat: Add product filtering"
git commit -m "fix: Resolve search bug"
git commit -m "docs: Update API documentation"
git commit -m "chore: Update dependencies"
```

**Types:**
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation
- `chore:` Maintenance
- `refactor:` Code restructuring
- `style:` Formatting
- `test:` Tests

---

## Environment Variables Sync

### Sync Script

```bash
# Sync local .env.production to server
./scripts/sync-env.sh

# Compare local vs production (shows key differences only)
./scripts/sync-env.sh --diff

# Pull production env to local (for backup or review)
./scripts/sync-env.sh --pull
```

### When to Sync

- After changing API keys (APS, Google, Supabase)
- After adding new environment variables
- Before major deployments with config changes

**Important:** Always restart container after syncing:
```bash
docker compose restart fossapp
```

---

## Production Server Details

| Item | Value |
|------|-------|
| **Server** | platon.titancnc.eu |
| **User** | sysadmin |
| **SSH Key** | ~/.ssh/platon.key |
| **Directory** | /opt/fossapp/ |
| **Domain** | https://main.fossapp.online |
| **Health Check** | https://main.fossapp.online/api/health |

---

## Rollback Procedure

If deployment fails:

```bash
# SSH to server
ssh -i ~/.ssh/platon.key sysadmin@platon.titancnc.eu

# Navigate to directory
cd /opt/fossapp

# Check current version
git log -1

# Rollback to previous tag
git checkout v1.8.0  # Replace with last known good version

# Rebuild and restart
docker-compose build
docker-compose up -d

# Verify
curl https://main.fossapp.online/api/health
```

---

## Quick Reference Commands

```bash
# Pre-deployment validation
./scripts/deploy-check.sh

# Version bumping
npm version patch
npm version minor
npm version major

# Push with tags
git push origin main --tags

# Deploy to production (via agent)
# "Deploy to production version 1.9.0"

# Health check
curl https://main.fossapp.online/api/health

# View production logs
ssh -i ~/.ssh/platon.key sysadmin@platon.titancnc.eu \
  "cd /opt/fossapp && docker-compose logs -f"
```

---

## Lessons Learned (v1.1.4 Deployment Issues)

**What went wrong:**
1. ❌ Tagged version before testing production build
2. ❌ Unused `theme` variable not caught in dev
3. ❌ Missing TypeScript interface properties
4. ❌ Had to delete and recreate tag 3 times

**What we learned:**
1. ✅ **ALWAYS** run `./scripts/deploy-check.sh` before committing
2. ✅ Never tag until build succeeds
3. ✅ Production builds are stricter than dev
4. ✅ Automated checks prevent deployment disasters

---

## See Also

- Full deployment checklist: [docs/deployment/checklist.md](../../docs/deployment/checklist.md)
- Docker guide: [docs/deployment/docker.md](../../docs/deployment/docker.md)
- VPS setup: [docs/deployment/vps.md](../../docs/deployment/vps.md)
- CLAUDE.md quick reference: [CLAUDE.md](../../CLAUDE.md)
