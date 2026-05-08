---
name: push-code
description: Commit and push code with automatic task discovery. Finds completed tasks from the planning board since last commit and includes them in the commit message.
---

# Push Code Skill

Commit and push code changes with intelligent commit message generation that includes completed tasks from the planning board.

---

## When to Use

Use this skill when:
- Ready to commit and push changes
- User says "push", "commit", "push code", "ship it"
- Work session complete and changes need to be committed

---

## Workflow

### Phase 1: Gather State

Run these commands in parallel:

```bash
# Get last commit hash
git log -1 --format="%H" HEAD

# Get git status
git status --porcelain

# Get staged and unstaged changes
git diff --stat

# Find tasks moved to done/ since last commit
git diff --name-status HEAD -- ".task-board/done/"
```

### Phase 2: Identify Completed Tasks

Parse the git diff output for `.task-board/done/` folder:

**Look for**:
- `A .task-board/done/XXX-TYPE-name.md` - New task completed (added to done/)
- Files with pattern: `{number}-{TYPE}-{description}.md`

**Extract from each task file**:
- Task number (e.g., `185`)
- Task type (e.g., `FEATURE`, `REFACTOR`)
- Short description from filename

**Example**:
```
A .task-board/done/185-FEATURE-missing-storybook-stories.md
A .task-board/done/186-FEATURE-ci-security-audit.md
```

Becomes:
- `#185 FEATURE: missing-storybook-stories`
- `#186 FEATURE: ci-security-audit`

### Phase 3: Build Commit Message

**Format**:
```
{summary}

Tasks completed:
- #{number} {TYPE}: {description}
- #{number} {TYPE}: {description}

{Claude Code footer}
```

**Summary rules**:
- If 1 task: Use task description as summary
- If 2-3 tasks: Combine into short summary
- If 4+ tasks: Use "Multiple tasks completed" or group by type
- If no tasks: Summarize file changes

**Example commit messages**:

Single task:
```
Add missing Storybook stories

Tasks completed:
- #185 FEATURE: missing-storybook-stories

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Multiple tasks:
```
CI improvements and Storybook stories

Tasks completed:
- #185 FEATURE: missing-storybook-stories
- #186 FEATURE: ci-security-audit
- #187 FEATURE: ci-e2e-tests

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

No tasks (general changes):
```
refactor: code cleanup and improvements

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Phase 4: Commit and Push

1. **Stage all changes**:
   ```bash
   git add -A
   ```

2. **Commit with generated message**:
   ```bash
   git commit -m "$(cat <<'EOF'
   {commit message here}
   EOF
   )"
   ```

3. **Push to remote**:
   ```bash
   git push
   ```

4. **Verify**:
   ```bash
   git status
   git log -1 --oneline
   ```

---

## Edge Cases

### No changes to commit
```
Nothing to commit, working tree clean.
```

### Unpushed commits exist
Push existing commits before creating new one (or just push without committing).

### Task files modified but not moved to done/
Only include tasks that were ADDED to `done/` folder (status `A`), not modified (`M`).

### Tasks completed in previous commits
Only look at diff from last commit to working tree. Previously committed tasks are already in history.

---

## Example Session

```
User: push code

Claude: I'll commit and push your changes. Let me check the state first.

[Runs git status, git diff, checks done/ folder]

Claude: Found 3 completed tasks since last commit:
- #188 REFACTOR: fix-frontend-any-types
- #189 REFACTOR: consolidate-error-classes
- #190 REFACTOR: extract-verify-demo-token

Committing with message:
"Refactoring: error handling and type safety

Tasks completed:
- #188 REFACTOR: fix-frontend-any-types
- #189 REFACTOR: consolidate-error-classes
- #190 REFACTOR: extract-verify-demo-token"

[Commits and pushes]

Claude: Pushed to origin/main.
```

---

## Critical Rules

1. **Always check git status first** - Don't commit if nothing to commit
2. **Only include tasks ADDED to done/** - Status `A`, not `M` or `D`
3. **Use HEREDOC for commit messages** - Ensures proper multiline formatting
4. **Never skip hooks** - No `--no-verify` flag
5. **Never force push** - No `--force` flag unless explicitly requested
6. **Report final state** - Show git status and last commit after push

---

## Triggering This Skill

User can invoke with:
- "push code"
- "commit and push"
- "ship it"
- "push changes"
- "commit this"