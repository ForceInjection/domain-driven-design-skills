---
name: branching
description: Git branching strategies - create, switch, merge, rebase, and workflows
sasmp_version: "1.3.0"
bonded_agent: git-expert
bond_type: PRIMARY_BOND
category: development
version: "2.0.0"
triggers:
  - git branch
  - git merge
  - git rebase
  - branching strategy
---

# Branching Skill

> **Production-Grade Development Skill** | Version 2.0.0

**Effective branching and merging strategies for development workflows.**

## Skill Contract

### Input Schema
```yaml
input:
  type: object
  properties:
    operation:
      type: string
      enum: [create, switch, merge, rebase, delete, list, strategy]
      default: list
    branch_name:
      type: string
      pattern: "^[a-zA-Z0-9/_-]+$"
      maxLength: 100
    strategy:
      type: string
      enum: [gitflow, github-flow, trunk-based]
    options:
      type: object
      properties:
        force:
          type: boolean
          default: false
        dry_run:
          type: boolean
          default: false
```

### Output Schema
```yaml
output:
  type: object
  required: [result, success]
  properties:
    result:
      type: string
    success:
      type: boolean
    branches_affected:
      type: array
      items:
        type: string
    warnings:
      type: array
    rollback_command:
      type: string
```

## Error Handling

### Retry Logic
```yaml
retry_config:
  max_attempts: 2
  backoff_ms: [1000, 2000]
  retryable:
    - lock_file_exists
    - network_timeout
  non_retryable:
    - merge_conflict
    - branch_not_found
```

### Fallback Strategy
```yaml
fallback:
  - trigger: merge_conflict
    action: abort_and_guide_manual_resolution
    command: git merge --abort
  - trigger: rebase_conflict
    action: abort_and_suggest_merge
    command: git rebase --abort
```

---

## Branch Basics

```bash
# List branches
git branch              # Local branches
git branch -r           # Remote branches
git branch -a           # All branches

# Create branch
git branch feature-x    # Create only
git checkout -b feature-x  # Create and switch
git switch -c feature-x    # Modern syntax

# Switch branches
git checkout main
git switch main         # Modern syntax

# Delete branch
git branch -d feature-x     # Safe delete
git branch -D feature-x     # Force delete
git push origin --delete feature-x  # Delete remote
```

## Branching Strategies

### GitFlow
```
┌─────────────────────────────────────────────────────────────┐
│                       GITFLOW                               │
├─────────────────────────────────────────────────────────────┤
│ main    ●─────────────────●───────────────●──────────►     │
│          ↑                 ↑               ↑                │
│ release  ├─────●───────────┤               │                │
│          │     ↑           │               │                │
│ develop  ├──●──┴──●──●──●──┴──●──●──●──●──┴──●──●──────►   │
│          │  ↑     ↑     ↑     ↑     ↑                       │
│ feature  └──┴─────┴─────┴─────┴─────┘                       │
└─────────────────────────────────────────────────────────────┘
```

### GitHub Flow (Simpler)
```
┌─────────────────────────────────────────────────────────────┐
│                     GITHUB FLOW                             │
├─────────────────────────────────────────────────────────────┤
│ main     ●────────●────────●────────●────────●─────────►   │
│           \      ↑  \     ↑  \     ↑                        │
│ feature    \────●    \───●    \───●                         │
│            (PR)     (PR)     (PR)                           │
└─────────────────────────────────────────────────────────────┘
```

### Trunk-Based Development
```
┌─────────────────────────────────────────────────────────────┐
│                  TRUNK-BASED DEV                            │
├─────────────────────────────────────────────────────────────┤
│ main    ●──●──●──●──●──●──●──●──●──●──●──●──●─────────►    │
│            ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑  ↑                 │
│          (frequent small commits to main)                   │
└─────────────────────────────────────────────────────────────┘
```

## Merging Strategies

| Strategy | Command | Use Case |
|----------|---------|----------|
| Fast-Forward | `git merge feature` | Linear history |
| Three-Way | `git merge feature` | Diverged branches |
| Squash | `git merge --squash feature` | Clean history |

## Rebasing

### Rebase vs Merge

| Aspect | Merge | Rebase |
|--------|-------|--------|
| History | Preserves | Linear |
| Safety | Shared branches OK | Never on shared |
| Conflicts | Resolve once | May resolve multiple |

---

## Troubleshooting Guide

### Debug Checklist
```
□ 1. Current branch? → git branch
□ 2. Uncommitted changes? → git status
□ 3. Diverged? → git log --oneline main..HEAD
```

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| "already exists" | Branch name taken | Use different name |
| "not fully merged" | Unmerged commits | Use -D or merge first |
| "CONFLICT" | Divergent changes | Resolve manually |

---

## Observability

```yaml
logging:
  level: INFO
  events:
    - branch_created
    - merge_completed
    - conflict_detected

metrics:
  - branches_per_repo
  - merge_conflict_rate
```

---

## Best Practices

1. **Descriptive names**: `feature/user-auth`, `fix/login-bug`
2. **Short-lived branches**: Merge frequently
3. **Delete merged branches**: Avoid clutter

---

*"Branches are cheap in Git - use them liberally."*
