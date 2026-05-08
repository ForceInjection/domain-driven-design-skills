---
name: cursor-debate
description: Run a research-first, multi-perspective debate to explore complex technical decisions (trade-offs, architecture choices, integration strategies) using concrete codebase evidence. Use when the user asks to "debate" approaches, compare options, or needs a structured exploration before deciding.
---

# Cursor Debate

## Overview

Structure an evidence-based “debate round” to surface ideas and trade-offs; the debate does not decide, it informs the human decision-maker.

## Workflow

### 1) Define the question
- Write the precise decision question (1 sentence).

### 2) Choose candidates
- Include 3–6 perspectives total.
  - Human personas (pragmatist, architect, researcher, integrator, tool builder)
  - Optional “code entity” personas (actual modules/symbols), backed by real file evidence

### 3) Research first (required)
- For each candidate, list questions they need answered.
- Run concrete repo inspection (examples):
  - `rg -n "..."`, `git grep`, `git log -p -- <path>`, `go test ./...`, etc.
- Record commands + key outputs in “Pre-Debate Research”.

### 4) Debate round
- Opening statements (Round 1)
- Rebuttals (Round 2)
- Moderator summary (tensions, trade-offs, open questions)

## Output template
Use the canonical outline in `references/debate.md`.
