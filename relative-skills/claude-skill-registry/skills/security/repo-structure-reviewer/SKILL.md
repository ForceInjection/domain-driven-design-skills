---
name: repo-structure-reviewer
description: Audit a repository's structure and propose a safe, approval-gated reorganization plan. Use when asked to review repo anatomy, propose folder changes, or apply an approved reorg with rollback.
---

# Repo Structure Reviewer

## Overview

Create a repo anatomy review and an optimized structure plan, then apply approved changes safely with a rollback plan. Default behavior is dry-run, with per-change approvals before any filesystem modifications.

## Quick Start

```bash
python3 skills/repo-structure-reviewer/scripts/repo_structure_review.py --root .
```

Apply mode (still per-change approval):

```bash
python3 skills/repo-structure-reviewer/scripts/repo_structure_review.py --root . --apply
```

Scope and safety controls:

```bash
python3 skills/repo-structure-reviewer/scripts/repo_structure_review.py --root . --scope top-level-only --max-changes 25
```

Full scan with file cap:

```bash
python3 skills/repo-structure-reviewer/scripts/repo_structure_review.py --root . --scope full-scan --max-files 20000
```

## Workflow

### Phase A: Review + Plan

1. Scan the repo structure and detect languages/frameworks/build systems.
2. Produce a "Repo Anatomy Review" report:
   - top-level tree summary + key subtrees
   - detected languages/frameworks/build systems
   - pain points and smells
   - archive candidates
   - stale/outdated/delete candidates
3. Produce an "Optimization Plan":
   - target structure outline
   - ordered list of proposed changes
   - per-change rationale, risk, and reversibility notes

### Phase B: Approval + Apply

If `--apply` is provided, start an interactive approval loop:

- Prompt one change at a time (or batched when explicitly supported) with:
  - Change ID
  - Operation type (MOVE/RENAME/CREATE)
  - Before/After paths
  - Rationale
  - Risk level
  - Show details / show diff options
- Print the full list of proposed files/changes for the selected phase before prompting for approvals.
- Require explicit approval for each change.
- Default to skip for delete candidates.
- Stop on error and report the last successful step and rollback guidance.

## Hard Safety Requirements

- Default is DRY RUN. No changes without explicit user approval.
- Prefer `git mv` when git is present and the file is tracked.
- Never delete by default.
  - Deletion proposals require explicit approval.
  - Default action is soft-delete into `.repo_reorg_backup/deletions/<timestamp>/...`.
  - Permanent delete requires explicit per-item approval.
- Generate a rollback plan for every applied change.
- Never edit lockfiles unless explicitly approved.
- If any step fails, stop and report how to roll back.

## Archive + Stale/Delete Review

The Repo Anatomy Review must include two additional sections:

### Archive Candidates (safe to keep, not active)

Flag items that likely belong in an archive area. For each item list:
- path
- why flagged (signals: last modified time, naming patterns, lack of references, superseded by newer file/folder)
- confidence (low/med/high)
- suggested destination (e.g., `archive/`, `docs/archive/`, `.archive/`)
- safe handling note: archive = move, not delete

### Stale / Outdated / Delete Candidates (needs review)

Flag items that might be removable or require updating. For each item list:
- path
- why flagged
- evidence (last modified, reference scan results, git tracked status, file size)
- recommendation: archive vs update vs delete
- confidence (low/med/high)
- risk notes

Heuristics must be conservative and always label results as candidates.

## Outputs / Artifacts

- `repo_anatomy_review.md`
- `repo_reorg_plan.json`
- `repo_reorg_actions_log.md`
- `rollback_plan.json`
- `ARCHIVE_INDEX.md` (when archive moves are approved)

## Implementation Layout

- `scripts/repo_structure_review.py` - CLI entrypoint
- `scripts/scanner.py` - repo scanning and metadata extraction
- `scripts/planner.py` - plan generation and candidate detection
- `scripts/approvals.py` - interactive approval loop
- `scripts/applier.py` - safe apply + reference updates
- `scripts/reporting.py` - report + artifact writers
- `scripts/models.py` - dataclasses shared across modules

## Tests

Use pytest to validate:
- dry-run makes zero modifications
- apply requires explicit approval
- rollback artifact is generated
- git move path uses `git mv` when git is present (with fallback)
- archive moves create/update `ARCHIVE_INDEX.md`
- delete candidates are not removed without explicit approval

Run:

```bash
python3 -m pytest skills/repo-structure-reviewer/tests
```
