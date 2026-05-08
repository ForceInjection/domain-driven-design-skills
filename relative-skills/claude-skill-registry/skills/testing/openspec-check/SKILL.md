---
name: openspec-check
description: >-
  Use BEFORE any implementation to check if specs exist for the capability.
  Run this first when starting any feature work. Reports: spec exists, no spec,
  or active change in progress.
---

# OpenSpec Check

Verify spec status before implementation.

> **Announce:** "I'm using openspec-check to verify spec status before proceeding."

## Iron Law

```
NO IMPLEMENTATION WITHOUT CHECKING SPECS FIRST
```

## Process

### Step 1: List Current Specs

```bash
openspec list --specs
```

Identify which capability this work relates to:
- `algorithm` - Game mechanics, scoring, ranking
- `database` - Schema, RLS, data model
- `frontend` - UI components, views, stores
- `game-core` - Core gameplay loop
- `edge-functions` - LLM, embeddings
- `operations` - CI/CD, deployment

### Step 2: Check Active Changes

```bash
openspec list
```

Look for:
- Is there already a change in progress for this capability?
- Would this work conflict with an active change?

### Step 3: Read Relevant Spec

If spec exists:
```bash
openspec show [capability] --type spec
```

Check:
- Does this work align with existing requirements?
- Would this work modify existing behavior?
- Are there scenarios that would be affected?

### Step 4: Report Status

Report ONE of these outcomes:

**A) Spec exists, work aligns:**
```
Spec `[capability]` exists. This work aligns with requirement: [name].
Proceeding with implementation following existing spec.
```
→ Load `test-tdd` skill and implement

**B) Spec exists, work would modify:**
```
Spec `[capability]` exists but this work would modify requirement: [name].
This needs an OpenSpec proposal before implementation.
```
→ Load `openspec-propose` skill

**C) No spec exists, new capability:**
```
No spec exists for this capability.
This is a new feature that needs an OpenSpec proposal.
```
→ Load `openspec-propose` skill

**D) Active change in progress:**
```
Active change `[change-id]` is in progress for this capability.
Status: [X/Y tasks complete]
Options:
1. Continue that change
2. Wait for it to complete
3. Create separate change (if unrelated)
```
→ ASK user how to proceed

**E) Trivial fix, no spec needed:**
```
This is a bug fix / typo / formatting change that restores intended behavior.
No spec change needed.
```
→ Load `test-tdd` skill and fix

## REQUIRED SUB-SKILL

Based on outcome:
- New feature or behavior change → Load `openspec-propose`
- Aligned with spec or trivial fix → Load `test-tdd`

## Red Flags - STOP

If you catch yourself:
- Starting implementation without running this check
- Assuming "this is too small to need a spec"
- Ignoring active changes that might conflict

STOP. Run `openspec list --specs` and `openspec list` first.
