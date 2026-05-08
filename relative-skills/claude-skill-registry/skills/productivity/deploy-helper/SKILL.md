---
name: deploy-helper
description: Assist with deployment workflow to production. Run pre-deploy checks, verify migrations, and validate deployment readiness. Use when deploying, releasing, pushing to production, or preparing a release.
allowed-tools: Read, Grep, Glob, Bash
---

# Deploy Helper

Guides safe deployment to production.

## When to Use

- "Deploy to production"
- "Release this"
- "Push to main"
- "Is this ready to deploy?"
- "Pre-deploy checklist"

## Deployment Flow

```
1. PR merged to main
   ↓
2. deploy.yml runs
   ↓
3. Typecheck + Lint + Build
   ↓
4. Preflight check (DB connection)
   ↓
5. Apply migrations to production
   ↓
6. Trigger Vercel deploy hook
   ↓
7. Vercel builds and deploys
```

## Pre-Deploy Checklist

### Code Quality

- [ ] `pnpm typecheck` passes
- [ ] `pnpm lint` passes
- [ ] `pnpm -C apps/web build` succeeds
- [ ] No `console.log` statements in production code
- [ ] No hardcoded secrets

### Tests

- [ ] All integration tests pass: `pnpm test:integration`
- [ ] Mobile tests pass: `pnpm -C apps/mobile test`
- [ ] New features have test coverage

### Database

- [ ] Migration generated: `pnpm -C packages/db migrate:generate`
- [ ] Migration applied locally: `pnpm -C packages/db migrate:apply`
- [ ] No destructive migrations without data backup plan
- [ ] Migration reviewed for safety

### Environment

- [ ] All required env vars set in Vercel
- [ ] No new env vars without updating Vercel config
- [ ] Secrets rotated if needed

### Dependencies

- [ ] No security vulnerabilities: `pnpm audit`
- [ ] Dependencies up to date
- [ ] Lock file committed

## Procedure

### Step 1: Run Quality Checks

```bash
pnpm typecheck
pnpm lint
pnpm -C apps/web build
```

### Step 2: Run Tests

```bash
pnpm test:integration
pnpm -C apps/mobile test
```

### Step 3: Check Migrations

```bash
# List pending migrations
ls packages/db/drizzle/*.sql

# Apply locally to verify
pnpm -C packages/db migrate:apply
```

### Step 4: Review Changes

```bash
git log main..HEAD --oneline
git diff main...HEAD --stat
```

### Step 5: Verify Readiness

Generate deploy readiness report:

```markdown
## Deploy Readiness Report

### Quality Checks

- [ ] TypeScript: {PASS|FAIL}
- [ ] ESLint: {PASS|FAIL}
- [ ] Build: {PASS|FAIL}

### Tests

- [ ] Integration: {PASS|FAIL}
- [ ] Mobile: {PASS|FAIL}

### Migrations

- Pending: {count}
- Reviewed: {YES|NO}

### Changes

- Commits: {count}
- Files changed: {count}

### Risk Level

{LOW|MEDIUM|HIGH}

### Recommendation

{READY TO DEPLOY | NEEDS ATTENTION}
```

### Step 6: Deploy

If all checks pass:

```bash
git push origin main
```

Monitor deploy.yml workflow in GitHub Actions.

## Rollback Procedure

If deployment fails:

1. **Revert commit:**

   ```bash
   git revert HEAD
   git push origin main
   ```

2. **Check Vercel:**
   - Go to Vercel dashboard
   - Redeploy previous working version

3. **Database rollback (if needed):**
   - Migrations are forward-only
   - Manual intervention required for rollback
   - Contact database admin

## Guardrails

- NEVER force push to main
- NEVER skip migration review
- NEVER deploy with failing tests
- NEVER deploy on Friday afternoon
- Always monitor deployment after push
- Have rollback plan ready
