---
name: testing-workflows
description: Run, debug, and structure tests for this Go project (unit + integration), including generation prerequisites. Use when changing domain logic, repositories, HTTP handlers, or migrations.
license: MIT
compatibility: Requires bash, git, Go, and make.
metadata:
  repo: mjrwtf
  runner: github-copilot-cli
  version: 1.3
allowed-tools: Bash(git:*) Bash(make:*) Bash(go:*) Read
---

## Tooling assumptions

- Use a terminal runner with bash and git available.
- Prefer `make` targets when available; fall back to direct CLI commands when needed.

## Fast paths

- All tests (runs generation first):

```bash
make test
```

- Unit tests only:

```bash
make test-unit
```

- Integration tests only (HTTP server suite):

```bash
make test-integration
```

## Debugging failures

1. If you see compile errors for generated packages, run:

```bash
make generate
```

2. Re-run the failing package with verbose output:

```bash
go test -v ./path/to/pkg
```

3. If the failure is DB-related, confirm `DATABASE_URL` is correct and migrations are applied (for integration setups).

## What to cover when adding features

- Domain validation (table-driven tests).
- Repository behavior (in-memory SQLite tests).
- HTTP behavior (status codes + auth + schemas).
