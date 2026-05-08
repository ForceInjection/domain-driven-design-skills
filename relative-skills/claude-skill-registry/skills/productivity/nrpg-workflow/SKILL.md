---
name: nrpg-workflow
description: Use when working on NRPG Platform tasks to follow repo conventions (NextAuth cookie sessions, tenant safety, and contractor privacy) and to run the correct checks.
metadata:
  short-description: NRPG workflow guardrails
---

Follow these rules when implementing changes in this repository:

## Auth (critical)

- Use NextAuth cookie sessions for web UI flows.
- Do not use `localStorage` tokens for auth in the UI.
- In API routes, prefer `getServerSession(authOptions)` and server-side role checks.
- Only allow `Authorization: Bearer ...` when explicitly required for non-browser clients.

## Multi-tenancy & privacy (critical)

- Never expose contractor identities to clients.
- Clients must not be able to browse/search contractors or contact them directly.
- Enforce role-based access for any contractor profile endpoints/pages.

## Implementation workflow

1. Scan for auth-token usage (`localStorage`, `Authorization: Bearer`) and remove/limit as required.
2. Verify server-side auth checks in any modified `app/api/**/route.ts`.
3. Run targeted checks for the area changed:
   - `npm run lint`
   - `npm test`
   - `npm run build`
4. Fix failures only if they are related to the change being made.

