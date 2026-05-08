---
name: github-workflow-best-practices
description: Master GitHub workflows including branching strategies, commit standards, PR processes, issue triage, sprint management, and git worktree usage. Activate when planning GitHub workflows, managing sprints, or establishing team conventions.
triggers:
  - "github workflow"
  - "PR best practices"
  - "github branching"
  - "sprint management"
  - "commit message"
  - "git worktree"
  - "github standards"
  - "issue triage"
  - "conventional commits"
---

# GitHub Workflow Best Practices

Master professional GitHub workflows that scale from solo projects to large teams. This skill covers branching strategies, commit conventions, PR processes, issue management, sprint execution, and advanced git worktree patterns.

## Branching Strategy

### Branch Naming Conventions

Follow a consistent naming pattern that communicates intent:

```
<type>/<issue-number>-<brief-description>

Examples:
feature/123-user-authentication
bugfix/456-login-redirect
hotfix/789-security-patch
chore/update-dependencies
docs/api-documentation
```

**Branch Types**:
- `feature/` - New functionality
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent production fixes
- `chore/` - Maintenance tasks (dependencies, config)
- `docs/` - Documentation updates
- `refactor/` - Code refactoring without behavior change
- `test/` - Test additions or updates

### Branch Lifecycle

**Main Branches**:
- `main` (or `master`) - Production-ready code
- `develop` - Integration branch for features (optional)

**Feature Branch Flow**:
```
1. Create branch from main
2. Develop and commit
3. Push to remote
4. Create PR
5. Code review
6. Merge to main
7. Delete branch
8. Clean up local/remote
```

**Protection Rules**:
- Require PR reviews before merge
- Require status checks to pass
- Require branches to be up to date
- Restrict force pushes
- Restrict deletions

See [Branching Strategy Details](references/branching-strategy.md) for advanced patterns.

## Commit Message Standards

### Conventional Commits Format

Use the conventional commits specification for clarity and automation:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Example**:
```
feat(auth): add OAuth2 integration

Implement OAuth2 authentication flow with Google and GitHub providers.
Includes token refresh logic and session management.

Closes #123
```

### Commit Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(api): add user search endpoint` |
| `fix` | Bug fix | `fix(login): resolve redirect loop` |
| `docs` | Documentation | `docs(readme): update setup instructions` |
| `style` | Formatting, no code change | `style(header): fix indentation` |
| `refactor` | Code restructure | `refactor(auth): extract validation logic` |
| `perf` | Performance improvement | `perf(query): optimize database indexes` |
| `test` | Test additions/updates | `test(user): add integration tests` |
| `chore` | Maintenance | `chore(deps): update dependencies` |
| `ci` | CI/CD changes | `ci(github): add test workflow` |
| `build` | Build system changes | `build(webpack): update config` |

### Commit Best Practices

**Good Commits**:
- ✅ Atomic (one logical change)
- ✅ Clear subject (< 50 chars)
- ✅ Imperative mood ("add feature" not "added feature")
- ✅ Detailed body when needed
- ✅ Reference issues/PRs

**Bad Commits**:
- ❌ "fix stuff"
- ❌ "WIP"
- ❌ Multiple unrelated changes
- ❌ Missing context

See [Commit Message Examples](examples/commit-messages.md) for good patterns.

## Pull Request Workflow

### PR Creation

**Before Creating PR**:
1. Ensure branch is up to date with main
2. Run tests locally
3. Run linter/formatter
4. Review your own changes
5. Write descriptive title and description

**PR Title Format**:
```
<type>(<scope>): <brief description>

Examples:
feat(auth): implement 2FA authentication
fix(api): resolve rate limiting issue
docs(contributing): add PR guidelines
```

**PR Description Template**:
```markdown
## Summary
Brief description of what this PR does.

## Changes
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
[Include screenshots for UI changes]

## Related Issues
Closes #123
Relates to #456

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### PR Review Process

**As Author**:
1. Respond to all comments
2. Make requested changes
3. Re-request review after updates
4. Resolve conversations when addressed
5. Keep PR updated with main

**As Reviewer**:
1. Review within 24 hours
2. Check code quality, security, performance
3. Ask questions for clarity
4. Suggest improvements
5. Approve when ready or request changes

**Review Levels**:
- 💬 **Comment**: Suggestion, not blocking
- 🔄 **Request Changes**: Must be addressed
- ✅ **Approve**: Ready to merge

See [PR Workflow Details](references/pr-workflow.md) for comprehensive process.

## Issue Triage Workflow

### Issue Labels

**Status Labels**:
- `status: new` - Needs triage
- `status: accepted` - Confirmed and prioritized
- `status: in-progress` - Being worked on
- `status: blocked` - Cannot proceed
- `status: on-hold` - Deferred

**Type Labels**:
- `type: bug` - Something broken
- `type: feature` - New functionality
- `type: enhancement` - Improvement to existing feature
- `type: documentation` - Docs update
- `type: question` - Support request

**Priority Labels**:
- `priority: critical` - Production down, security issue
- `priority: high` - Major functionality broken
- `priority: medium` - Normal priority
- `priority: low` - Nice to have

**Size Labels**:
- `size: XS` - < 1 hour
- `size: S` - 1-4 hours
- `size: M` - 1 day
- `size: L` - 2-3 days
- `size: XL` - 1+ week

### Triage Process

**Daily Triage** (5-10 minutes):
1. Review new issues
2. Validate bug reports
3. Add labels (type, priority, size)
4. Assign to milestone/sprint
5. Close duplicates
6. Convert questions to discussions

**Weekly Review** (30 minutes):
1. Review blocked/on-hold issues
2. Update stale issues
3. Close resolved issues
4. Reprioritize backlog

## Sprint Planning & Execution

### Sprint Planning

**Pre-Sprint Preparation**:
1. Groom backlog
2. Estimate issues (size labels)
3. Identify dependencies
4. Check team capacity

**Sprint Planning Meeting**:
1. Review sprint goal
2. Select high-priority issues
3. Break down large issues
4. Assign issues to team members
5. Confirm commitment

**Sprint Artifacts**:
- Sprint board (GitHub Projects)
- Sprint milestone
- Sprint goal documentation

### Sprint Execution

**Daily Standup Questions**:
1. What did I complete yesterday?
2. What will I work on today?
3. Any blockers?

**Sprint Board Columns**:
```
To Do → In Progress → In Review → Done
```

**Mid-Sprint Adjustments**:
- Add urgent issues (swap out equal size)
- Remove blocked issues
- Rebalance workload

**End-of-Sprint Activities**:
1. Demo completed work
2. Retrospective (what went well, what to improve)
3. Close sprint milestone
4. Archive sprint board
5. Plan next sprint

### Sprint Automation with GitHub CLI

**Fetch Sprint Issues**:
```bash
gh issue list --milestone "Sprint 23" --json number,title,labels
```

**Bulk Update**:
```bash
gh issue edit 123 --add-label "status: in-progress"
```

**Create Sprint Report**:
```bash
gh issue list --milestone "Sprint 23" --state closed --json number,title,closedAt
```

## Git Worktree Patterns

### When to Use Worktrees

**Use Worktrees For**:
- Working on multiple branches simultaneously
- Code review while preserving current work
- Parallel bug fix while developing feature
- Running different branches side-by-side

**Advantages**:
- No stashing required
- No branch switching
- Multiple dev servers running
- Compare branches easily

### Worktree Commands

**Create Worktree**:
```bash
# Create worktree for existing branch
git worktree add ../project-feature-123 feature/123-user-auth

# Create worktree with new branch
git worktree add -b feature/456-new-feature ../project-feature-456
```

**List Worktrees**:
```bash
git worktree list
```

**Remove Worktree**:
```bash
# Remove worktree directory
rm -rf ../project-feature-123

# Prune reference
git worktree prune
```

### Worktree Organization

**Directory Structure**:
```
~/projects/
  myapp/              # Main worktree
  myapp-feature-123/  # Feature branch worktree
  myapp-bugfix-456/   # Bugfix branch worktree
  myapp-review-789/   # Review worktree
```

**Naming Convention**:
```
<project>-<branch-type>-<issue-number>

Examples:
myapp-feature-123
myapp-bugfix-456
myapp-hotfix-789
```

### Worktree Workflows

**Parallel Development**:
```bash
# Main feature development
cd ~/projects/myapp-feature-123
npm run dev

# Switch to review PR
cd ~/projects/myapp-review-456
git pull origin feature/456-other-feature
npm run dev -- --port 3001
```

**Quick Bug Fix During Feature Work**:
```bash
# Continue feature work in main worktree
# Create worktree for urgent bug fix
git worktree add ../myapp-hotfix-789 -b hotfix/789-critical-bug

cd ../myapp-hotfix-789
# Fix bug, commit, push, create PR
# Return to feature work without disruption
```

### Agency Plugin Integration

**Create Worktree for Issue**:
```bash
/gh-worktree-issue 123
```

This command:
1. Creates worktree directory
2. Creates/checks out branch
3. Sets up tracking
4. Opens in new window (optional)

## GitHub CLI Integration

### Essential gh Commands

**Issues**:
```bash
# List issues
gh issue list --assignee @me --state open

# View issue
gh issue view 123

# Create issue
gh issue create --title "Bug: Login fails" --body "Description"

# Update issue
gh issue edit 123 --add-label "priority: high"
```

**Pull Requests**:
```bash
# Create PR
gh pr create --title "feat: add feature" --body "Description"

# List PRs
gh pr list --author @me

# View PR
gh pr view 456

# Review PR
gh pr review 456 --approve

# Merge PR
gh pr merge 456 --squash
```

**Workflows**:
```bash
# List workflows
gh workflow list

# View workflow runs
gh run list --workflow=test.yml

# View run logs
gh run view 123456
```

### Automation Scripts

**Daily Issue Check**:
```bash
#!/bin/bash
echo "🎯 Your assigned issues:"
gh issue list --assignee @me --state open

echo "\n📝 PRs awaiting your review:"
gh pr list --search "review-requested:@me"
```

**Sprint Progress**:
```bash
#!/bin/bash
MILESTONE="Sprint 23"
TOTAL=$(gh issue list --milestone "$MILESTONE" --json number | jq length)
DONE=$(gh issue list --milestone "$MILESTONE" --state closed --json number | jq length)
echo "Sprint Progress: $DONE / $TOTAL completed"
```

## Best Practices Summary

**Branching**:
1. Use descriptive branch names with issue numbers
2. Keep branches short-lived (< 1 week)
3. Delete merged branches
4. Protect main branch

**Commits**:
1. Follow conventional commits format
2. Write clear, atomic commits
3. Reference issues in commit messages
4. Use imperative mood

**Pull Requests**:
1. Keep PRs small and focused
2. Write descriptive titles and descriptions
3. Respond to reviews promptly
4. Keep PRs up to date with main

**Issues**:
1. Triage daily
2. Use consistent labels
3. Keep issues updated
4. Close resolved issues

**Sprints**:
1. Plan thoroughly
2. Track progress daily
3. Adjust as needed
4. Retrospect and improve

**Worktrees**:
1. Use for parallel work
2. Organize with naming convention
3. Clean up after merging
4. Leverage for reviews

## Quick Reference

**Branch**: `<type>/<number>-<description>`
**Commit**: `<type>(<scope>): <subject>`
**PR Title**: Same as commit format
**Issue Labels**: `type:`, `priority:`, `status:`, `size:`
**Worktree**: `git worktree add <path> <branch>`

## Related Skills

- `agency-workflow-patterns` - Orchestrator and multi-agent workflows
- `code-review-standards` - What to look for in reviews
- `testing-strategy` - Test requirements and standards

---

**Remember**: Consistency in workflows reduces cognitive load and enables automation. Choose conventions that work for your team and stick to them.
