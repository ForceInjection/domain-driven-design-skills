---
name: go-local-health
description: Run local Go health checks (tests, coverage, lint) in Go repositories that contain go.mod/go.sum. Use when the user asks to run or interpret local Go test/coverage/lint workflows using tools like lazygotest, gocovsh, tparse, and golangci-lint. Do not use for Rust or non-Go projects.
---

# Go Local Health

## Overview

Provide a consistent, repeatable local workflow for Go test, coverage, and lint checks.
Use this to run fast snapshots, interactive test loops, and coverage inspection without re-deriving commands.

## Guardrails (language + tooling)

- Confirm `go.mod` exists in the repo root before running anything. If missing, stop and ask.
- Run commands from the repo root so module settings and tooling config are discovered.
- Respect the repo’s Go toolchain configuration (`go.mod` + `toolchain`).
- Prefer repo-pinned tool versions (e.g., `tools.go` or `go.mod` tool directives). If tools are missing and no pins exist, ask before installing or adding pins.
- Required tools vary by mode:
  - Quick Snapshot: `go`, `tparse`, `golangci-lint`
  - Interactive Test Loop: `lazygotest`
  - Coverage Explorer: `gocovsh`
  If any required tool is missing, ask to install rather than using substitutes.
- All automated runs must be non-interactive. Only launch TUIs when the user explicitly requests them.

## Workflow Decision Tree

- Use **Quick Snapshot** when you want a fast read on tests + coverage + lint.
- Use **Interactive Test Loop** when you are actively iterating on tests.
- Use **Coverage Explorer** when you need to inspect coverage hotspots in detail.
- If the repo is large, ask whether to scope to a package path before running full `./...`.

## Quick Snapshot (tests + coverage + lint)

Preferred (scripted, deterministic):

```
~/.codex/skills/go-local-health/scripts/go-local-health --scope ./...
```

Manual fallback:

1. Run tests with coverage and a one-screen summary:

```
go test -cover -json ./... | tparse
```

2. Run lint with the repo’s configuration:

```
golangci-lint run ./...
```

If a narrower scope is requested, replace `./...` with the specific package path.

## Interactive Test Loop (lazygotest)

- Launch from the repo root:

```
lazygotest
```

- Use the UI to filter packages and re-run tests while editing code.

## Coverage Explorer (gocovsh)

- Launch from the repo root:

```
gocovsh
```

- If a `cover.out` is required or preferred, generate it first:

```
go test -coverprofile=cover.out ./...
```

## Reporting Back to the User

- Summarize failing packages, error types, and coverage gaps.
- If lint fails, report the top categories (not every line) and ask whether to fix now.
- If coverage is low, identify the worst packages and suggest next steps only if asked.

## Non-Goals

- Do not run in non-Go repos.
- Do not swap in other tools or skip required checks.
- Do not change CI configuration or code unless the user asks.
