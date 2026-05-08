---
name: FP Workflow
description: This skill should be used when the user asks to "start working on issue", "what should I work on", "pick up task", "continue work", "find next task", "hand off", or "end session". Provides agent work session patterns for the FP CLI including claiming work, logging progress, and VCS-based change tracking.
---

# FP Workflow Skill

**Agent work session patterns for the FP CLI**

## Core Workflow Concepts

### Issue Status Lifecycle

Issues have three states:
1. **todo** - Planned, not yet started (no VCS tracking)
2. **in-progress** - Actively being worked on (VCS base captured)
3. **done** - Completed (VCS tip captured)

### Issue Priority

Issues can have an optional priority: `low`, `medium`, `high`, or `critical`.
- Priority affects display order: within the same status, higher priority issues appear first
- Sort order: critical → high → medium → low → (no priority)
- Use `--priority` flag when creating or updating issues

### VCS-Based Change Tracking

FP automatically tracks changes using your version control system (git or jj):

- **When issue becomes `in-progress`**: Captures current VCS ref as the `base` commit
- **When issue becomes `done`**: Captures current VCS ref as the `tip` commit
- **Range (base..tip)**: Shows exactly what changed for this issue

This replaces manual snapshots - VCS handles all change tracking automatically.

### Work Session Flow

```
1. Session Start → Get your agent name
2. Find Work → Discover next actionable task (status: todo)
3. Claim Work → Mark issue as in-progress (captures base ref)
4. Do Work → Implement, test, iterate
5. COMMIT → Commit changes before logging (enforced by hooks)
6. Log Progress → Add comments after committing
7. Complete → Mark as done (captures tip ref)
8. Hand Off → Log final status before session ends
```

### Commit-First Rule

**You must commit before logging progress.** The plugin enforces this with PreToolUse hooks that block `fp comment` and `fp issue update` calls when uncommitted changes exist.

The workflow rhythm is: **code → commit → log → repeat**

This ensures:
- VCS history accurately reflects progress
- Comments reference committed work, not in-flight changes
- Context survives compaction (commits are durable)

## Essential Commands

### 1. Identify Yourself

**Check who you are:**
```bash
fp agent whoami
```

This tells you your agent name (e.g., "swift-falcon"). Your identity is set automatically when your session starts and stored in the `$FP_AGENT_NAME` environment variable.

**Note:** Use `$FP_AGENT_NAME` in commands. If the variable is not set (e.g., in subagents), get your name with:
```bash
FP_AGENT_NAME=$(fp agent whoami 2>&1 | grep "Name:" | awk '{print $2}')
```

### 2. Find Next Task

**See the full issue tree:**
```bash
fp tree
```

This shows all issues with their hierarchy, status, and dependencies.

**List tasks by status:**
```bash
fp issue list --status todo         # Available to pick up
fp issue list --status in-progress  # Currently being worked on
fp issue list --status done         # Completed work
fp issue list                       # All issues
```

**Analyze dependencies:**
When looking at the tree output, identify tasks that:
- Have no dependencies, OR
- Have all dependencies in "done" status
- Are not already being worked on (check recent activity)

### 3. Claim Work

**Start working on an issue:**
```bash
fp issue update --status in-progress FP-2
```

When you mark an issue as `in-progress`, the system automatically:
- Captures the current VCS ref as the base commit
- Sets this as your current issue in the workspace

**Log that you're starting:**
```bash
fp comment FP-2 "Starting work. First step: [describe what you'll do]"
```

### 4. View Changes

**See what's changed since you started:**
```bash
fp issue diff FP-2        # Full diff
fp issue diff FP-2 --stat # Just file stats
```

**List changed files:**
```bash
fp issue files FP-2
```

For parent issues with children, these commands automatically aggregate changes from all descendants.

### 5. Manually Assign Commits

If automatic VCS tracking missed commits (e.g., you forgot to mark the issue as in-progress before starting work), use `fp issue assign` to retroactively link commits:

```bash
fp issue assign FP-2              # Assign current HEAD to issue
fp issue assign FP-2 --rev abc123 # Assign specific commit
fp issue assign FP-2 --rev a1,b2  # Assign multiple commits
fp issue assign FP-2 --reset      # Clear all assigned revisions
```

This adds an `Issue: FP-2` trailer to the commit message and updates the issue's revision tracking.

### 6. Log Progress

**Add comments as you make progress:**
```bash
fp comment FP-2 "Completed schema design. Added User, Session, Token models to src/models/"
```

### 7. Mark Completion

**When work is done:**
```bash
fp issue update --status done FP-2
fp comment FP-2 "Task completed. [Summary of what was done]"
```

This automatically captures the current VCS ref as the tip commit.

## Best Practices

### Starting a Session

1. **Check your identity:**
   ```bash
   fp agent whoami
   ```

2. **Review recent activity:**
   ```bash
   fp log --limit 10
   ```

3. **Check the current state:**
   ```bash
   fp tree
   ```

4. **Look for available work:**
   ```bash
   fp issue list --status todo         # Not started
   fp issue list --status in-progress  # In progress (maybe continue)
   ```

5. **If continuing work, load context:**
   ```bash
   fp context FP-2
   ```
   This shows the issue details.

### During Work

1. **Comment frequently** - At minimum:
   - When you start a task
   - When you complete a significant milestone
   - When you discover important information
   - When you encounter problems

2. **Check your progress:**
   ```bash
   fp issue diff FP-2 --stat  # Quick view of changed files
   fp issue files FP-2        # List of files changed
   ```

3. **Keep status current**:
   - `todo` when not yet started
   - `in-progress` when actively working
   - `done` when complete

### Ending a Session

1. **Log your progress:**
   ```bash
   fp comment FP-2 "End of session. Completed: [list]. Next steps: [list]"
   ```

2. **Update status appropriately:**
   - If done: `--status done`
   - If partially done: keep as `in-progress` with clear comment about state

3. **Don't leave issues in limbo** - Always leave a comment explaining state

## Common Patterns

### Pattern: Pick Up Where You Left Off

```bash
# 1. Check what's currently in progress
fp issue list --status in-progress

# 2. Load context for the issue
fp context FP-5

# 3. Review recent activity
fp log FP-5 --limit 5

# 4. See what's changed so far
fp issue diff FP-5 --stat

# 5. Continue work and log
fp comment FP-5 "Resuming work. Current focus: [what you're doing]"
```

### Pattern: Taking Over From Another Agent

```bash
# 1. Identify the issue
fp issue show FP-3

# 2. Review what was done
fp log FP-3

# 3. See the changes made so far
fp issue diff FP-3 --stat

# 4. Load full context
fp context FP-3

# 5. Log that you're taking over
fp comment FP-3 "Taking over. Will continue with: [next steps]"
```

### Pattern: Breaking Down Work

```bash
# While working on FP-4, you realize it's too big

# 1. Create sub-issues
fp issue create --title "Authentication middleware" --parent FP-4
fp issue create --title "Authorization checks" --parent FP-4
fp issue create --title "Token refresh logic" --parent FP-4

# 2. Document in parent
fp comment FP-4 "Broke down into sub-tasks: FP-10, FP-11, FP-12. Will work on these sequentially."

# 3. Work on sub-issues
fp issue update --status in-progress FP-10
```

### Pattern: Checking Parent Issue Progress

```bash
# For a parent issue, see aggregated changes from all children
fp issue diff FP-1 --stat   # Shows all changes across descendants
fp issue files FP-1         # Lists all files changed by descendants
```

### Pattern: Fixing Tracking After the Fact

If you made commits before marking an issue as in-progress (so the base ref wasn't captured), use `fp issue assign` to manually link commits:

```bash
# 1. Find the commits you made for this issue
jj log   # or: git log --oneline

# 2. Assign them to the issue
fp issue assign FP-5 --rev abc123,def456

# 3. Verify the issue now tracks those commits
fp issue diff FP-5 --stat
```

## Anti-Patterns (Avoid These)

### ❌ Logging before committing
```bash
# BAD: Log progress with uncommitted changes (will be blocked by hooks)
# ... make changes ...
fp comment FP-2 "Added auth middleware"  # BLOCKED - uncommitted changes

# GOOD: Commit first, then log
# ... make changes ...
jj describe -m "Add auth middleware" && jj new  # or: git commit -am "..."
fp comment FP-2 "Committed: Added auth middleware"  # ALLOWED
```

### ❌ Silent progress (no comments)
```bash
# BAD: Work on issue for 2 hours without any comments
# Context is lost if session compacts

# GOOD: Commit and comment at key milestones
jj describe -m "Create base models" && jj new
fp comment FP-2 "Committed: Created base models"
# ... work ...
jj describe -m "Add validation logic" && jj new
fp comment FP-2 "Committed: Added validation logic"
```

### ❌ Leaving work in ambiguous state
```bash
# BAD: End session without final comment
fp issue update --status in-progress FP-2  # Still in progress, but what's the state?

# GOOD: Clear handoff
fp comment FP-2 "End of session. Completed auth middleware. TODO: Add rate limiting. File: src/middleware/auth.ts is 80% done."
```

### ❌ Not using VCS tracking
```bash
# BAD: Manually tracking what files changed

# GOOD: Let fp handle it
fp issue diff FP-2 --stat   # See exactly what changed
fp issue files FP-2         # Get the file list
```

## Integration with Context Commands

### Loading Context for Work

Use `fp context` to get issue details:

```bash
# Load context for specific issue
fp context FP-2

# Load with child issues
fp context FP-2 --include-children

# Machine-readable format (for processing)
fp context FP-2 --format json
```

### Session Start Context

When your session starts, the SessionStart hook automatically runs:
```bash
fp context --session-start --session-id <id>
```

This provides:
- Your agent identity
- Current open issues
- Recent activity summary

### Pre-Compact Context

Before context compaction, the PreCompact hook runs:
```bash
fp context --current --format compact
```

This preserves critical information about what you were working on.

## Querying Activity

### View Recent Activity
```bash
# Last 20 activities (default)
fp log

# Last 50 activities
fp log --limit 50

# Activity for specific issue
fp log FP-2

# Activity by specific agent
fp log --author swift-falcon

# Your own activity
fp log --author $FP_AGENT_NAME
```

### Understanding Activity Log

The activity log shows:
- Timestamp
- Author (agent or user)
- Issue ID
- Action type and details

Use this to:
- Understand what happened while you were away
- See who worked on what
- Track status transitions
- Find recent comments

## Quick Reference

### Start Session Checklist
- [ ] `fp agent whoami` - Know who you are
- [ ] `fp tree` - See the full picture
- [ ] `fp log --limit 10` - Check recent activity
- [ ] `fp issue list --status todo` - See available work
- [ ] `fp issue list --status in-progress` - See current work

### During Work Checklist
- [ ] Mark issue as `in-progress` to start tracking
- [ ] **Commit before logging** (hooks enforce this)
- [ ] Comment after each commit to document progress
- [ ] Use `fp issue diff/files` to see progress
- [ ] Keep status current (todo → in-progress → done)

### End Session Checklist
- [ ] Add final comment with progress and next steps
- [ ] Update status appropriately
- [ ] Ensure all changes are logged
- [ ] Don't leave work in ambiguous state

## Troubleshooting

### "I don't know what to work on"
```bash
fp tree                           # See full picture
fp issue list --status todo       # See available work
fp issue list --status in-progress  # See active work
# Pick tasks with no dependencies or all dependencies done
```

### "Lost context after compaction"
```bash
fp context FP-X              # Reload issue details
fp log FP-X --limit 10       # Read recent activity
fp issue diff FP-X --stat    # See what's changed
fp tree                      # Understand issue hierarchy
```

### "What changed in this issue?"
```bash
fp issue diff FP-X           # Full diff
fp issue diff FP-X --stat    # File stats only
fp issue files FP-X          # List of changed files
```

## Summary

The FP workflow is designed for seamless agent collaboration:

1. **Always identify yourself** with `fp agent whoami`
2. **Find actionable work** using `fp tree` and `fp issue list --status todo`
3. **Claim with status in-progress** to start VCS tracking
4. **Code → Commit → Log** (commit-first is enforced by hooks)
5. **View changes** with `fp issue diff` and `fp issue files`
6. **Mark done** when complete (captures final commit ref)
7. **Hand off cleanly** with clear final comments

The commit-first rule ensures VCS history accurately reflects progress and comments reference durable, committed work.
