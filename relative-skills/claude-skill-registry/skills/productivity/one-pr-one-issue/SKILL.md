---
name: one-pr-one-issue
description: Enforce 1 PR = 1 Jira Issue workflow for clean project tracking
---

# One PR, One Issue Workflow

Maintain clean project tracking by ensuring each Pull Request maps to exactly one Jira issue.

## Why This Matters

- **Clear traceability**: Easy to track what work was done for each issue
- **Clean history**: Git history remains organized and searchable
- **Better reviews**: PRs are focused and easier to review
- **Accurate metrics**: Jira metrics reflect actual work done

## Core Rules

### Rule 1: One Issue = One Branch

Each Jira issue gets its own dedicated branch.

```bash
# Correct
feature/CP-1-add-authentication
feature/CP-2-fix-login-bug

# Incorrect
feature/CP-1-CP-2-mixed-work  # Multiple issues in one branch
```

### Rule 2: One Branch = One PR

Each branch produces exactly one Pull Request.

```bash
# Correct workflow
/jira:start CP-1      # Creates feature/CP-1-description
# ... work ...
/jira:done            # Creates PR for CP-1 only

# Incorrect
# Working on multiple issues before creating PR
```

### Rule 3: New Task = New Branch

If a new task comes up while working on an issue:

```bash
# Currently on feature/CP-1-add-auth
git stash                    # Save current work
/jira:start CP-2             # New branch: feature/CP-2-new-task
# ... complete CP-2 work ...
/jira:done                   # Create PR for CP-2
git checkout feature/CP-1-add-auth
git stash pop                # Resume CP-1 work
```

## Standard Workflow

### Starting Work

```bash
/jira:start CP-1
```

This:
- Creates branch: `feature/CP-1-description`
- Updates Jira status: To Do → In Progress
- Sets Start Date in Jira and Notion

### During Work

```bash
/git:commit
```

This:
- Creates commit with `[CP-1]` prefix
- Ensures commit is linked to the issue

### Completing Work

```bash
/jira:done
```

This:
- Creates PR linked to CP-1
- Updates Jira status: In Progress → In Review/Done
- Updates Notion TODO with PR link

## Handling Interruptions

### Scenario: Bug Found While Working on Feature

```bash
# Currently on feature/CP-1-add-dashboard
git stash                    # Save incomplete work

/jira:create                 # Create bug issue (CP-5)
/jira:start CP-5             # Switch to bugfix/CP-5-fix-crash
# ... fix bug ...
/git:commit                  # Commit fix
/jira:done                   # Create PR, update status

git checkout feature/CP-1-add-dashboard
git stash pop                # Resume dashboard work
```

### Scenario: Quick Fix Needed

For very small fixes (< 5 minutes), you can:
1. Complete current work first, OR
2. Create separate issue and branch

Never mix issues in commits.

## Commit Message Format

All commits should reference the current issue:

```bash
[CP-1] Add user authentication flow
[CP-1] Fix login button styling
[CP-1] Add unit tests for auth service
```

The `/git:commit` command handles this automatically when Jira is configured.

## Warning Signs

### Multiple Issue Keys in Branch

If you see commits like:
```bash
[CP-1] Add feature
[CP-2] Fix bug      # Wrong! Different issue
[CP-1] Continue feature
```

Solution: Create separate PR for CP-2 work.

### Long-Running Branches

Branches with 10+ commits or 3+ days of work may indicate:
- Scope creep
- Need to split into smaller issues
- Review the issue breakdown

## Detection

`/git:pr` will warn if multiple issue keys are detected in commits:

```
⚠️ Warning: Multiple issue keys detected!

Branch: CP-1
Commits reference: CP-1, CP-2, CP-3

Best practice: 1 PR = 1 Issue
Continue anyway? [Y/n]
```

## Benefits

| Metric | Before | After |
|--------|--------|-------|
| PR review time | Long, unfocused | Short, targeted |
| Issue tracking | Scattered | Clear |
| Rollback scope | Large, risky | Small, safe |
| Code review | Confusing | Straightforward |
