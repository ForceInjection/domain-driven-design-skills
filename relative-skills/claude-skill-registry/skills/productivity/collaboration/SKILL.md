---
name: collaboration
description: Team collaboration - remote, fetch, pull, push, clone, and team workflows
sasmp_version: "1.3.0"
bonded_agent: git-expert
bond_type: PRIMARY_BOND
category: development
version: "2.0.0"
triggers:
  - git remote
  - git push
  - git pull
  - team git
---

# Collaboration Skill

> **Production-Grade Development Skill** | Version 2.0.0

**Working with remote repositories and teams.**

## Skill Contract

### Input Schema
```yaml
input:
  type: object
  properties:
    operation:
      type: string
      enum: [clone, fetch, pull, push, remote, sync-fork]
      default: remote
    remote_url:
      type: string
      format: uri
    options:
      type: object
      properties:
        force:
          type: boolean
          default: false
        force_with_lease:
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
    remote_status:
      type: object
      properties:
        ahead: integer
        behind: integer
```

## Error Handling

### Retry Logic
```yaml
retry_config:
  max_attempts: 4
  backoff_type: exponential
  initial_delay_ms: 2000
  max_delay_ms: 16000
  retryable:
    - network_timeout
    - connection_refused
  non_retryable:
    - authentication_failed
    - non_fast_forward
```

### Fallback Strategy
```yaml
fallback:
  - trigger: push_rejected_non_ff
    action: suggest_pull_rebase
  - trigger: authentication_failed
    action: guide_credential_setup
```

---

## Remote Repository Basics

```bash
# List remotes
git remote -v

# Add remote
git remote add origin https://github.com/user/repo.git
git remote add upstream https://github.com/original/repo.git

# Change remote URL
git remote set-url origin https://github.com/user/new-repo.git
```

## Getting & Sharing Changes

### Fetch vs Pull
```
┌─────────────────────────────────────────────────────────────┐
│  FETCH: Remote ──► origin/main (safe, no merge)            │
│  PULL:  Remote ──► origin/main ──► main (fetch + merge)    │
└─────────────────────────────────────────────────────────────┘
```

### Push Safety Matrix

| Method | Risk | Use Case |
|--------|------|----------|
| `git push` | LOW | Normal push |
| `git push --force-with-lease` | MEDIUM | After rebase |
| `git push --force` | CRITICAL | Never on shared |

## Team Workflows

### Fork + Pull Request
```bash
git clone https://github.com/YOU/repo.git
git remote add upstream https://github.com/ORIGINAL/repo.git
git checkout -b feature-x
# ... work and commit ...
git push -u origin feature-x
# Create PR on GitHub
```

### Sync Fork
```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

---

## Troubleshooting Guide

### Debug Checklist
```
□ 1. Remote configured? → git remote -v
□ 2. Authenticated? → git fetch (test)
□ 3. Branch tracking? → git branch -vv
```

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| "rejected non-fast-forward" | Remote ahead | Pull first |
| "authentication failed" | Bad credentials | Re-authenticate |

---

## Observability

```yaml
logging:
  events:
    - push_completed
    - push_rejected
    - authentication_error

metrics:
  - push_success_rate
  - conflict_rate
```

---

*"Great software is built by teams, and Git makes collaboration possible."*
