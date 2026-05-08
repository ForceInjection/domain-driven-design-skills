---
name: Git Workflow
description: Git branch management, commits, pull requests, and IJACK Roadmap project board integration. Use when creating feature branches, committing code, creating pull requests, managing git workflows, or adding issues to the IJACK Roadmap project board.
allowed-tools: [Bash, Read]
---

# Git Workflow Skill

## Purpose
Manage Git workflows including feature branches, commits, pull requests, and GitHub issue tracking with IJACK Roadmap project board integration.

## When to Use This Skill
- Creating feature branches
- Committing code changes
- Creating pull requests
- Adding issues to project board
- Git workflow management
- Branch management
- Issue tracking

## Critical: IJACK Roadmap Project Board

### MANDATORY: All Issues Must Go to Project #12
**IJACK Roadmap (Project #12)** is the **default and only project board** for ALL issues:
- Features
- Bugs
- Epics
- User stories
- Service requests
- Ideas

**Project URL**: https://github.com/orgs/ijack-technologies/projects/12/views/

### Add Issue to Project Board
```bash
# ALWAYS add every issue to Project #12
gh project item-add 12 --owner ijack-technologies --url <ISSUE_URL>

# Examples
gh project item-add 12 --owner ijack-technologies --url https://github.com/ijack-technologies/rcom/issues/976
gh project item-add 12 --owner ijack-technologies --url https://github.com/ijack-technologies/planning/issues/45
```

## Feature Branch Workflow

### Create New Feature Branch
```bash
cd /project
bash scripts/new-feature-branch.sh
```

**Interactive prompts:**
1. Branch type (feature/bugfix/hotfix)
2. Brief description
3. Automatically creates formatted branch name

### Manual Branch Creation
```bash
# Create and switch to new branch
git checkout -b feature/user-authentication

# Push to remote with tracking
git push -u origin feature/user-authentication
```

### Branch Naming Convention
```
feature/<description>    # New features
bugfix/<description>     # Bug fixes
hotfix/<description>     # Urgent production fixes
refactor/<description>   # Code refactoring
docs/<description>       # Documentation updates
```

## Commit Workflow

### Standard Commit Process
```bash
# 1. Check status
git status

# 2. Review changes
git diff

# 3. Stage files
git add <files>

# 4. Commit with descriptive message
git commit -m "feat: Add user authentication system

Implements JWT-based authentication with role-based access control.
Includes login, logout, and session management.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Commit Message Format
```
<type>: <subject>

<body>

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation
- `test`: Tests
- `chore`: Maintenance
- `perf`: Performance improvements

### Using Heredoc for Commits
```bash
git commit -m "$(cat <<'EOF'
feat: Add user authentication system

Implements JWT-based authentication with role-based access control.
Includes login, logout, and session management.

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Pre-Commit Checklist

### Code Quality
```bash
# Python linting
cd /project
ruff check --fix .
ruff format .

# TypeScript checks
cd /project/flask_app/app/inertia/react
bun run build
bun run lint
```

### Testing
```bash
# Run comprehensive tests
cd /project
bash scripts/run_all_tests_comprehensive.sh --coverage
```

### Type Generation
```bash
# If FastAPI changes were made
cd /project/flask_app/app/inertia/react
bun run generate-types
```

## Pull Request Creation

### Using GitHub CLI
```bash
# Create PR with template
gh pr create --title "Add user authentication" --body "$(cat <<'EOF'
## Summary
- Implement JWT-based authentication
- Add role-based access control
- Create login/logout endpoints

## Test Plan
- [ ] Test user login flow
- [ ] Verify token generation
- [ ] Test role permissions
- [ ] Validate session management

🤖 Generated with Claude Code
EOF
)"
```

### PR Workflow
```bash
# 1. Ensure on feature branch
git branch --show-current

# 2. Push latest changes
git push

# 3. Create PR
gh pr create --title "Feature: User Authentication" --body "..."

# 4. Get PR URL
gh pr view --web
```

### PR Best Practices
1. **Clear title**: Describe what the PR does
2. **Summary section**: Bullet points of changes
3. **Test plan**: Checklist of testing steps
4. **Link issues**: Reference related issues
5. **Screenshots**: For UI changes
6. **Claude attribution**: Include Claude Code footer

## Issue Management

### Get Current User and Available Labels

**ALWAYS get the current authenticated user dynamically** instead of hardcoding usernames:

```bash
# Get current GitHub user
CURRENT_USER=$(gh api user --jq '.login')
echo "Current user: $CURRENT_USER"

# List available labels in current repository
gh label list --limit 100
```

### Available Labels in rcom Repository

Common labels you can use (run `gh label list --limit 100` to see all):

**Issue Types:**
- `🐛 Bug` - Something isn't working
- `enhancement` - Enhancement to existing feature
- `📍 Feature` - Deliverable functionality (1-4 sprints)
- `💡 Idea` - New ideas/suggestions
- `🙋 Service Request` - Adhoc work requests
- `🏌️ User Story` - Specific user workflow (one sprint)
- `⛳ Epic` - High-level objective (multiple releases)

**Priority:**
- `🔴 High Priority` - Urgent/important
- `performance` - Performance optimization
- `security` - Security related
- `technical-debt` - Refactoring needs

**Tools/Components:**
- `tools:work-orders` - Work Order tasks
- `tools:inventory` - Parts Management tasks
- `tools:build-and-price` - Warehouse Operations
- `tools:service-dashboard` - Service Dashboard
- `tools:sales-dashboard` - Sales Dashboard
- `tools:inventory-dashboard` - Inventory Dashboard
- `tools:health-dashboard` - Health Dashboard

**Infrastructure:**
- `infrastructure:database` - Database Management
- `infrastructure:servers` - Security tasks
- `infrastructure:devops` - DevOps tasks
- `documentation` - Documentation update

### Create Issue with Dynamic User

```bash
# Get current user first
CURRENT_USER=$(gh api user --jq '.login')

# Create issue with current user as assignee
gh issue create \
  --title "Fix login timeout issue" \
  --assignee "$CURRENT_USER" \
  --label "🐛 Bug,🔴 High Priority" \
  --body "Bug description here"

# IMMEDIATELY add to Project #12 (REQUIRED)
ISSUE_URL=$(gh issue list --limit 1 --json url --jq '.[0].url')
gh project item-add 12 --owner ijack-technologies --url "$ISSUE_URL"
```

### Create Issue WITHOUT Assignee or Labels

If you're unsure about the username or labels, it's better to create without them:

```bash
# Create issue without assignee or labels
gh issue create \
  --title "Issue Title" \
  --body "Issue description here"

# IMMEDIATELY add to Project #12 (REQUIRED)
gh project item-add 12 --owner ijack-technologies --url <ISSUE_URL>
```

You can always add assignees and labels later through the GitHub UI.

### Available Issue Templates
Located in `.github/ISSUE_TEMPLATE/`:
- 🐛 Bug Reports
- 📍 Features
- 💡 Ideas
- 🙋 Service Requests
- 🏌️ User Stories
- ⛳ Epics

### Standard Workflow for ALL Issues
```bash
# 1. Get current user (optional)
CURRENT_USER=$(gh api user --jq '.login')

# 2. Create issue with appropriate template
gh issue create --title "Issue Title" --body "..."

# 3. IMMEDIATELY add to IJACK Roadmap project (REQUIRED)
gh project item-add 12 --owner ijack-technologies --url <ISSUE_URL>

# 4. Move to appropriate status via project board UI
```

## Common Git Operations

### Update from Main
```bash
# Update main branch
git checkout main
git pull origin main

# Merge into feature branch
git checkout feature/my-feature
git merge main

# Or rebase
git checkout feature/my-feature
git rebase main
```

### Stash Changes
```bash
# Stash current changes
git stash save "WIP: description"

# List stashes
git stash list

# Apply stash
git stash apply

# Pop stash (apply and remove)
git stash pop
```

### Amend Commit
```bash
# Amend last commit (ONLY if not pushed!)
git add <files>
git commit --amend

# Amend without changing message
git commit --amend --no-edit
```

### Reset Changes
```bash
# Unstage file
git reset HEAD <file>

# Discard changes in working directory
git checkout -- <file>

# Reset to last commit (DANGER!)
git reset --hard HEAD
```

## Branch Management

### List Branches
```bash
# Local branches
git branch

# Remote branches
git branch -r

# All branches
git branch -a
```

### Delete Branch
```bash
# Delete local branch (merged)
git branch -d feature/completed

# Force delete (unmerged)
git branch -D feature/abandoned

# Delete remote branch
git push origin --delete feature/completed
```

### Rename Branch
```bash
# Rename current branch
git branch -m new-name

# Rename other branch
git branch -m old-name new-name
```

## Git Configuration

### Check Configuration
```bash
git config --list
git config user.name
git config user.email
```

### View Remotes
```bash
git remote -v
```

## Merge AWS Secrets

### Merge Secrets Script
```bash
cd /project
bash scripts/merge-aws-secrets.sh
```

**Purpose:**
- Fetches secrets from AWS Secrets Manager
- Merges with local environment files
- Updates configuration safely

## Git History and Logs

### View Commit History
```bash
# Recent commits
git log --oneline -10

# Detailed log
git log

# Graph view
git log --graph --oneline --all
```

### View Specific File History
```bash
git log --follow <file>
```

### Diff Comparisons
```bash
# Unstaged changes
git diff

# Staged changes
git diff --staged

# Compare branches
git diff main..feature/branch
```

## Troubleshooting

### Merge Conflicts
```bash
# Show conflicts
git status

# Edit conflicting files
# Look for <<<<<<, ======, >>>>>> markers

# Mark as resolved
git add <resolved-files>

# Complete merge
git commit
```

### Undo Last Commit (Not Pushed)
```bash
# Keep changes in working directory
git reset --soft HEAD~1

# Discard changes
git reset --hard HEAD~1
```

### Recover Lost Commits
```bash
# Show reference log
git reflog

# Checkout lost commit
git checkout <commit-hash>

# Create branch from lost commit
git branch recovery <commit-hash>
```

## Best Practices

1. **Commit often**: Small, focused commits
2. **Write clear messages**: Describe why, not what
3. **Test before commit**: Run tests and linters
4. **Review changes**: Use `git diff` before committing
5. **Pull before push**: Keep branch updated
6. **Use feature branches**: Never commit directly to main
7. **Add issues to Project #12**: ALWAYS add all issues to IJACK Roadmap
8. **Delete merged branches**: Clean up after PR merge
9. **Protect main branch**: Use PRs for all changes
10. **Document PRs**: Include test plans and summaries

## Integration
This skill automatically activates when:
- Creating feature branches
- Committing code changes
- Creating pull requests
- Managing git workflows
- Adding issues to project board
- Branch management tasks
- Issue tracking
- Git troubleshooting
