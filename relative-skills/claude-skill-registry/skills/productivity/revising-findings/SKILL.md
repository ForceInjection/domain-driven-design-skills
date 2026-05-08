---
name: revising-findings
description: Implement findings from verification reports with scope-based parallel workflow
when_to_use: after /verify completes, when implementing common or exclusive issues from collation reports
version: 1.0.0
---

# Revising Findings

## Overview

Systematic implementation of verification findings. Separates what to fix (verify) from how to fix it (revise). Enables parallel workflow where common issues can be implemented while cross-check validates exclusive issues.

**Announce at start:** "I'm using the revising-findings skill to implement [scope] issues from verification."

## Quick Reference

| Scope | What's Implemented | When Available |
|-------|-------------------|----------------|
| `common` | Issues both reviewers found (VERY HIGH confidence) | Immediately after collation |
| `exclusive` | VALIDATED exclusive issues only | After cross-check completes |
| `all` | Common + VALIDATED exclusive | After cross-check completes |

**Exclusive issue states:**
- **VALIDATED:** Implement
- **INVALIDATED:** Skip automatically
- **UNCERTAIN:** Prompt user

## Prerequisites

Before revising:
1. Collation report must exist (from `/verify`)
2. For `exclusive` or `all` scope: cross-check must be complete

## Step-by-Step Workflow

### 1. Locate Collation Report

**Find most recent collation:**
```bash
ls -la .work/*-collated*.md | tail -1
```

**If no collation found:**
```
Error: No collation report found. Run `/verify` first.
```

### 2. Parse Scope

**Determine what to implement:**

| User Request | Scope | Requirements |
|--------------|-------|--------------|
| `/revise` | all | Cross-check complete |
| `/revise common` | common | None (immediate) |
| `/revise exclusive` | exclusive | Cross-check complete |
| `/revise all` | all | Cross-check complete |

### 3. Check Cross-check Status (if needed)

**For `exclusive` or `all` scope:**

Read collation report metadata:
- `Cross-check Status: PENDING` → Warn user, suggest `/revise common`
- `Cross-check Status: COMPLETE` → Continue

**Warning message:**
```
Cross-check still running. Options:
1. `/revise common` - Start with high-confidence issues now
2. Wait for cross-check to complete
```

### 4. Build Implementation List

**For `common` scope:**
- All issues in "Common Issues" section
- BLOCKING first, then NON-BLOCKING

**For `exclusive` scope:**
- Only issues with `Cross-check: VALIDATED`
- Skip `Cross-check: INVALIDATED` automatically
- Prompt for `Cross-check: UNCERTAIN`

**For `all` scope:**
- Common issues (all)
- Exclusive issues (VALIDATED only)
- Prompt for UNCERTAIN

### 5. Handle UNCERTAIN Issues

For each UNCERTAIN exclusive issue:

```
UNCERTAIN: "[Issue description]"
- Source: Reviewer #[1/2]
- Cross-check: [findings]

Implement? [Y/n/skip all]
```

### 6. Dispatch Implementation Agents

**Agent selection:**

| Issue Type | Agent | Focus |
|------------|-------|-------|
| Code fixes | cipherpowers:code-agent | Apply code changes |
| Documentation | cipherpowers:technical-writer | Update docs |
| Test coverage | cipherpowers:code-agent | Add tests |
| Security fixes | cipherpowers:code-agent | Security patches |

**Dispatch pattern:**
```
Task tool:
  subagent_type: [agent from table]
  description: "Implement [issue summary]"
  prompt: "Implement this fix from verification:
    Issue: [description]
    Location: [file/location]
    Action: [what to do]

    Make minimal, focused changes."
```

**Parallel dispatch:** Independent issues can be dispatched in parallel.

### 7. Verify Implementation

After all implementations:
1. Run project tests/checks if applicable
2. Report completion status

**Completion message:**
```
Revise complete.

Implemented:
- Common issues: X/Y
- Exclusive (VALIDATED): X/Y
- Exclusive (UNCERTAIN): X/Y (user approved)
- Skipped (INVALIDATED): X

Run `/verify` again to confirm fixes?
```

## Edge Cases

### All Issues Already Fixed

```
All issues from collation have been addressed.
Run `/verify` to confirm, or continue with other work.
```

### No Issues in Scope

```
No [common/exclusive] issues to implement.
[For common: All issues were exclusive - wait for cross-check]
[For exclusive: All exclusive issues were INVALIDATED]
```

### Cross-check Never Completes

If user wants to proceed without cross-check:
```
/revise all --force

Warning: Implementing exclusive issues without validation.
INVALIDATED issues may be included. Proceed? [y/N]
```

## Parallel Workflow Pattern

```
/verify docs
  ↓
Collation complete
  ↓
/revise common ← Starts immediately
  ↓                    ↓
[Implementing]    [Cross-check runs]
  ↓                    ↓
Done              Cross-check complete
                       ↓
                  /revise exclusive
                       ↓
                  All done
```

## What NOT to Skip

- Checking cross-check status before `exclusive`/`all` scope
- Prompting user for UNCERTAIN issues
- Skipping INVALIDATED issues (they don't apply)
- Running tests after implementation

## Related

- `/cipherpowers:verify` - Produces collation reports
- `dual-verification` skill - The verification workflow
- `/cipherpowers:execute` - Uses revise for fix implementation

## Remember

- `common` scope works immediately (no waiting)
- `exclusive` requires cross-check complete
- INVALIDATED = auto-skip (cross-check proved it doesn't apply)
- UNCERTAIN = user decides
- Parallel workflow reduces total time
