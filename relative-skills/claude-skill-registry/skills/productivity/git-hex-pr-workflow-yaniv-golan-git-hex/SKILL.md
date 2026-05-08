---
name: git-hex-pr-workflow
description: >
  Complete pull request workflow combining git-hex (local craft) with remote
  collaboration (GitHub plugin or CLI). This skill should be used when the user
  wants to prepare, submit, and iterate on a PR with clean commit history.
  Trigger phrases include: "prepare a PR", "open a pull request", "address review
  feedback", "update my PR", "clean up commits for PR".
---

# Git-hex PR Workflow

## When to use this Skill

This skill should be used when:
- The user wants to prepare a branch for PR submission with clean history
- The user is iterating on a PR after receiving review feedback
- The user asks about combining git-hex with GitHub/PR workflows

Trigger phrases include: "prepare a PR", "open a PR", "create a pull request",
"address PR feedback", "update the PR", "force-push after rebase".

## Workflow

1. **Local craft (git-hex)** - shape commits before pushing:
   - Use `git-hex-getRebasePlan` to inspect current history
   - Use `git-hex-createFixup` + `git-hex-rebaseWithPlan` to clean up
   - Use `git-hex-splitCommit` if commits need to be broken apart

2. **Push to remote**:
   - `git push --force-with-lease` (safe force push)

3. **Remote collaboration** - work with teammates:
   - **If the [GitHub Plugin](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/github) is installed**: use its tools to create/update PRs, add reviewers, respond to comments
   - **Otherwise**: use GitHub CLI (`gh`) commands:
     - `gh pr create` - create a pull request
     - `gh pr view` - view PR details
     - `gh pr edit` - update PR title/body/reviewers
     - `gh pr comment` - add comments

4. **After review feedback**:
   - Return to step 1 for more local craft
   - Use `git-hex-undoLast` if a cleanup went wrong

## Tools to prefer

- **Local craft**: all git-hex tools (see branch-cleanup skill)
- **Remote**: GitHub plugin tools if installed, otherwise `gh` CLI

## Key insight

git-hex handles the **local craft** of shaping commits.
Remote collaboration (via the [GitHub Plugin](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/github) from the [Official Claude Plugin Marketplace](https://github.com/anthropics/claude-plugins-official), or standard `gh` CLI) handles working with teammates.
Together, they cover the complete pull request lifecycle.
