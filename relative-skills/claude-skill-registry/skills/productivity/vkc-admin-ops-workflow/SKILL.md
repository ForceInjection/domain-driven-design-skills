---
name: vkc-admin-ops-workflow
description: Standardize admin operations workflow (Draft -> Review -> Scheduled publish -> Published) using DB states + admin API routes + scheduled visibility. Use when implementing admin-controlled publishing systems.
metadata:
  short-description: Admin ops workflow standard
---

# VKC Admin Ops Workflow

## When to use

- Adding any “admin-controlled publishing” feature (content drafts, policy updates, regulation updates, templates/rulesets activation)

## Canonical implementation in this repo

- Scheduled visibility model (start/end): `news` table in `src/lib/db/schema.ts`
- Admin CRUD: `src/app/api/admin/news/route.ts`
- Public read with schedule filtering: `src/app/api/news/route.ts`

## Standard workflow

- Draft → Review → Scheduled (optional) → Published
- The “published view” is derived from:
  - `isActive`
  - `startAt`/`endAt` (optional schedule window)

## What to standardize each time

- DB states and timestamps (`createdAt`, `updatedAt`, optional `startAt`, `endAt`)
- Admin endpoints (`/api/admin/**`) for CRUD + activation
- Public endpoints with schedule filtering + caching headers when appropriate

## Reference

- `.codex/skills/vkc-admin-ops-workflow/references/workflow-spec.md`

