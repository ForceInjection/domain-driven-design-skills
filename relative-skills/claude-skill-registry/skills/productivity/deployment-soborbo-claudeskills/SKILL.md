---
name: deployment
description: Deployment workflow for Astro sites on Cloudflare Pages + GitHub. Staging → Production flow. Use before first deploy.
---

# Deployment Skill

## Purpose

Defines deployment workflow for Astro sites. Cloudflare Pages + GitHub only.

## Scope

| ✅ Supported | ❌ Out of Scope |
|-------------|----------------|
| Cloudflare Pages | Vercel, Netlify |
| GitHub repos | GitLab, Bitbucket |
| Single-site projects | Monorepos |
| Astro static/SSR | Other frameworks |

## Core Rules

1. **Never deploy directly to production** — Always staging first
2. **Environment variables in dashboard** — Never in code
3. **Staging is noindex** — Always blocked from search
4. **Production needs client approval** — No exceptions
5. **Rollback plan ready** — Before every deploy

## Blocking Conditions (STOP)

Deployment BLOCKED if any:

| Condition | Check |
|-----------|-------|
| Build fails | `npm run build` |
| TypeScript errors | `npx astro check` |
| Missing env var | Dashboard check |
| Lighthouse < 90 | All categories |
| Forms not working | Test submission |
| Staging indexable | robots.txt / noindex |
| No client approval | Written confirmation |

**If blocked → FIX first, do not deploy.**

## Environment Variables

**Set in Cloudflare Dashboard → Settings → Environment Variables**

| Variable | Required | Notes |
|----------|----------|-------|
| `PUBLIC_SITE_URL` | ✅ | Full URL with https |
| `TURNSTILE_SITE_KEY` | ✅ | Different for prod/preview |
| `TURNSTILE_SECRET_KEY` | ✅ | Secret |
| `RESEND_API_KEY` | ✅ | Email sending |
| `GTM_ID` | ✅ | Analytics |

**Missing required env var = deployment BLOCKED.**

Never:
- Commit `.env` to git
- Put secrets in `wrangler.toml`
- Use same keys for prod and preview

## Branch Configuration

| Branch | Environment | URL |
|--------|-------------|-----|
| `main` | Production | domain.com |
| `staging` | Preview | staging.domain.com |
| `feature/*` | Preview | [hash].pages.dev |

## DNS Setup (Cloudflare)

```
Type    Name    Content              Proxy
CNAME   @       [project].pages.dev  ✓
CNAME   www     [project].pages.dev  ✓
```

## Staging Protection

**Required:** Choose one:

| Method | When to Use |
|--------|-------------|
| Cloudflare Access | Client needs to review |
| robots.txt + noindex | Internal only |

```html
<!-- BaseLayout.astro - always include -->
{import.meta.env.MODE !== 'production' && (
  <meta name="robots" content="noindex, nofollow" />
)}
```

## Monitoring (Required)

| Type | Tool | Required |
|------|------|----------|
| Analytics | Cloudflare Analytics | ✅ |
| Uptime | Cloudflare or UptimeRobot | ✅ |
| Search | Google Search Console | ✅ |
| Errors | Console or Sentry | Recommended |

**Basic uptime monitoring is NOT optional.**

## Checklists

### Pre-Staging

- [ ] `npm run build` passes
- [ ] `npx astro check` clean
- [ ] No console.logs in code
- [ ] Env vars documented

### Pre-Production

- [ ] Lighthouse > 90 all categories
- [ ] Forms working + sending emails
- [ ] GTM firing correctly
- [ ] No broken links
- [ ] Mobile tested on real device
- [ ] 404 page exists
- [ ] Client approved staging
- [ ] Legal pages present
- [ ] Contact info correct

### Post-Deploy (Within 1 hour)

- [ ] Site loads on production URL
- [ ] Forms work
- [ ] Analytics receiving data
- [ ] Submit sitemap to Search Console

## Rollback

```bash
# Via Dashboard
Pages → Project → Deployments → [Previous] → "Rollback"

# Via CLI
npx wrangler pages deployment list --project-name=[name]
npx wrangler pages deployment rollback --project-name=[name] [id]
```

**Test rollback BEFORE you need it.**

## Forbidden

- ❌ Secrets in code or wrangler.toml
- ❌ Direct push to main without staging
- ❌ Deploy without client approval
- ❌ Indexable staging environment
- ❌ No uptime monitoring
- ❌ Deploy with blocking conditions

## References

- [cloudflare-setup.md](references/cloudflare-setup.md) — Detailed setup
- [troubleshooting.md](references/troubleshooting.md) — Common issues
- [wrangler-template.md](references/wrangler-template.md) — Config template

## Definition of Done

- [ ] Staging accessible and protected
- [ ] Production DNS configured
- [ ] SSL working (https://)
- [ ] All env vars set
- [ ] Uptime monitoring active
- [ ] Search Console configured
- [ ] Rollback tested
