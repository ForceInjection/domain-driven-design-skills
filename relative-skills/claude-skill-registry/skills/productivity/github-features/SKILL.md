---
name: github-features
description: GitHub platform features - PRs, issues, actions, projects, and automation
sasmp_version: "1.3.0"
bonded_agent: github-specialist
bond_type: PRIMARY_BOND
category: development
version: "2.0.0"
triggers:
  - github features
  - pull request
  - github actions
  - github issues
---

# GitHub Features Skill

> **Production-Grade Platform Skill** | Version 2.0.0

**Leveraging GitHub platform capabilities.**

## Skill Contract

### Input Schema
```yaml
input:
  type: object
  properties:
    feature:
      type: string
      enum: [pr, issue, actions, projects, releases]
    operation:
      type: string
      enum: [create, list, view, update, close, merge]
    target:
      type: object
      properties:
        owner:
          type: string
        repo:
          type: string
        number:
          type: integer
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
    url:
      type: string
      format: uri
    rate_limit:
      type: object
      properties:
        remaining: integer
```

## Error Handling

### Retry Logic
```yaml
retry_config:
  max_attempts: 4
  backoff_type: exponential
  initial_delay_ms: 2000
  max_delay_ms: 16000
  jitter: true
  retryable:
    - 502_bad_gateway
    - 503_service_unavailable
    - 429_rate_limited
  non_retryable:
    - 401_unauthorized
    - 404_not_found
```

### Rate Limit Strategy
```yaml
rate_limit:
  check_before_request: true
  buffer_percentage: 10
  on_limit_reached:
    - wait_for_reset
    - batch_remaining_operations
```

---

## GitHub CLI (`gh`)

```bash
# Auth
gh auth login
gh auth status

# PRs
gh pr create --title "Title" --body "Body"
gh pr list
gh pr merge 123 --squash

# Issues
gh issue create --title "Bug" --body "Description"
gh issue list --state open

# Actions
gh run list
gh run view 123
```

## GitHub Actions

### Basic CI Workflow
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test
```

## Branch Protection

```yaml
protection_rules:
  - require_pull_request_reviews:
      required_approving_review_count: 2
  - require_status_checks:
      strict: true
      contexts: [ci, lint, test]
  - allow_force_pushes: false
```

---

## Troubleshooting Guide

### Debug Checklist
```
□ 1. Auth status: gh auth status
□ 2. Rate limits: gh api rate_limit
□ 3. CLI version: gh --version
```

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| "401 Unauthorized" | Invalid token | `gh auth refresh` |
| "403 Forbidden" | No permission | Check token scopes |
| "rate limit exceeded" | Too many calls | Wait for reset |

---

## Features Matrix

| Feature | CLI Command | Use Case |
|---------|-------------|----------|
| PRs | `gh pr` | Code review |
| Issues | `gh issue` | Bug tracking |
| Actions | `gh run` | CI/CD |
| Releases | `gh release` | Distribution |

---

## Observability

```yaml
logging:
  events:
    - api_call_completed
    - rate_limit_warning

metrics:
  - api_calls_per_session
  - rate_limit_usage
```

---

*"GitHub is not just hosting - it's a complete development platform."*
