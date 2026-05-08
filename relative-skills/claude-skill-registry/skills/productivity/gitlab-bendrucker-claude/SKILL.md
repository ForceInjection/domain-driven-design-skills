---
name: GitLab
description: GitLab workflow best practices and glab CLI usage. Use when working with GitLab repositories, merge requests, issues, pipelines, or GitLab API interactions.
---
# GitLab

GitLab workflows use `glab`, the official GitLab CLI. This skill helps adapt GitHub (`gh`) patterns to GitLab (`glab`).

## Terminology

- **Pull Request → Merge Request (MR)**: Use `glab mr` instead of `gh pr`
- **Repository → Project**: GitLab calls repositories "projects"
- **Actions → CI/CD**: Use `glab ci` for pipelines and jobs

## Quick Start

```bash
# Authenticate
glab auth login

# Create merge request (push branch first!)
git push -u origin feature-branch
glab mr create --fill

# List merge requests
glab mr list
```

## Reference Files

- **merge-requests.md**: Working with merge requests (`glab mr`)
- **ci.md**: CI/CD pipelines and jobs (`glab ci`)
- **api.md**: REST and GraphQL API access (`glab api`)

## Key Rules

- **Always** use `glab` for GitLab (never `gh`)
- **Always** push branch before creating MR
- **Always** use `--fill` to auto-populate from commits
- Use `glab ci lint` to validate `.gitlab-ci.yml`

## Common Mistakes

Don't use `gh` commands, call MRs "pull requests", or forget to push before creating MRs.
