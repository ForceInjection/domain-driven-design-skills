---
name: rpi-workflow
description: Apply a Research → Plan → Implement → Validate workflow with Copilot CLI, including context budgeting and persistent artifacts via /share.
license: MIT
compatibility: github-copilot-cli (interactive); uses /context, /clear, /share, @file mentions.
metadata:
  repo: mjrwtf
  runner: github-copilot-cli
  version: 1.0
---

# Research → Plan → Implement → Validate (RPI-V)

Use this workflow for any non-trivial change (features, bugfixes, refactors) to keep Copilot CLI’s context focused and your changes predictable.

## Core rules

- **Research first. No code changes during research.**
- **Keep context under ~60%.** Use `/context` frequently.
- **Clear between phases.** Use `/clear` after you’ve saved the output for the next phase.
- **Persist artifacts** to files so you can resume later (and so future work can reference them).
- **Implement one phase at a time**, then run checks.

## Recommended artifact locations

Create (locally) a `thoughts/` directory (optionally symlinked to a global shared folder) and keep:

- `thoughts/shared/research/NNN_<topic>.md` (or `YYYY-MM-DD_<topic>.md`)
- `thoughts/shared/plans/NNN_<topic>.md` (or `YYYY-MM-DD_<topic>.md`)
- `thoughts/shared/validation/NNN_<topic>.md` (or `YYYY-MM-DD_<topic>.md`)
- `thoughts/shared/sessions/NNN_<topic>.md` (or `YYYY-MM-DD_<topic>.md`) (checkpoints / handoffs)

Optional (HumanLayer-style): keep a `thoughts/searchable/` directory with hard links for fast searching.

This repo’s `.gitignore` excludes `thoughts/` by default (treat it as local working memory).

## How to run the workflow in Copilot CLI

### Phase 1 — Research

Goal: locate relevant code, patterns, tests, and constraints.

1. Ask focused questions and include only essential files with `@path/to/file`.
2. Prefer targeted searches over dumping lots of files into context.
3. Save the research notes:
   - `/share file thoughts/shared/research/<id>_<topic>.md`
4. Check context (`/context`) and then `/clear`.

Suggested prompt template: see `references/prompts.md`.

### Phase 2 — Plan

Goal: produce a phased plan with success criteria and commands.

1. Start from a clean context.
2. Provide the research artifact:
   - `@thoughts/shared/research/<id>_<topic>.md`
3. Iterate until the plan is executable and phase-based.
4. Save:
   - `/share file thoughts/shared/plans/<id>_<topic>.md`
5. `/context` then `/clear`.

### Phase 3 — Implement

Goal: execute the plan, one phase at a time.

1. Start from a clean context.
2. Provide the plan artifact and specify the phase:
   - `@thoughts/shared/plans/<id>_<topic>.md`
3. Implement **Phase 1 only**, then run checks.
4. If context approaches ~60%, save a checkpoint (session summary) to `thoughts/shared/sessions/` via `/share file thoughts/shared/sessions/<id>_<topic>.md`, then `/clear`.

### Phase 4 — Validate

Goal: prove the implementation matches the plan and repo conventions.

1. Start from a clean context.
2. Provide the plan artifact and what phases were implemented.
3. Run repo verification commands (typically `make test`, `go test ./...`, `make check` as applicable).
4. Record:
   - what matches the plan
   - deviations (intentional/unintentional)
   - remaining TODOs
5. Save:
   - `/share file thoughts/shared/validation/<id>_<topic>.md`

For team sharing, you can also `/share gist` and paste the resulting link into issues/PRs.

## Repo-specific verification defaults (mjr.wtf)

- If SQL/templ changed: `make generate`
- Tests: `make test`
- Build sanity: `go build ./...`

If lint fails but tests/build pass, follow repo guidance (known lint false positives).
