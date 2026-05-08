---
name: integration-testing-http
description: Run and extend the end-to-end HTTP integration tests (SQLite in-memory) for mjr.wtf, covering auth, create/list/delete, redirects, and analytics. Use when changing handlers, middleware, or API contracts.
license: MIT
compatibility: Requires Go, make, and generated code.
metadata:
  repo: mjrwtf
  runner: github-copilot-cli
  version: 1.1
allowed-tools: Bash(git:*) Bash(make:*) Bash(go:*) Read
---

## Tooling assumptions

- Use a terminal runner with bash and git available.
- Prefer `make` targets when available; fall back to direct CLI commands when needed.

## Run

```bash
make test-integration
```

Targeted runs:

```bash
go test -v -run TestE2E ./internal/infrastructure/http/server/
go test -v -run TestAPI ./internal/infrastructure/http/server/
```

## What to update when adding/changing endpoints

- Add/adjust OpenAPI (`openapi.yaml`) and validate it.
- Update integration tests to assert:
  - status codes
  - auth requirements (missing/invalid token)
  - response JSON schema fields
  - redirect behavior and analytics side effects

## Reference

See `docs-site/src/content/docs/operations/integration-testing.md` for the current suite structure and scenarios.
