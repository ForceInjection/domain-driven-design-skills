---
name: vitest-targeted-testing
description: Use this when adding/fixing UI or smoke tests; prefer targeted Vitest runs first, then widen.
---

## Frontend (UI) tests

- Full run:
  - `npm run test:ui`

- Target by test name:
  - `npm run test:ui -- -t "<substring>"`

- Target a single file:
  - `npm run test:ui -- view/<path>/<file>.test.ts`

## Smoke suite (Vitest + Playwright harness)

- Full smoke (builds first):
  - `npm run smoke`

- Quick smoke (no rebuild):
  - `npm run test:smoke:quick`

- Target by test name:
  - `npm run test:smoke:quick -- -t "<substring>"`

- Debug a single test in-process:
  - `npx vitest watch --config smoke/vitest.config.ts --runInBand`

## Lint/typecheck

- Frontend typecheck: `npm run lint:frontend`

## Strategy

- Start as narrow as possible (one test/file).
- If failures look environment-related, pivot to the smoke debugging runbook.
