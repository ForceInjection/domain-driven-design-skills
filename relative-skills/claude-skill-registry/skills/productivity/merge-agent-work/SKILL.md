---
name: merge-agent-work
description: Merge agent work from agent branch to task branch with validation
allowed-tools: Bash, Read
---

# Merge Agent Work Skill

**Purpose**: Safely merge agent work from agent branch to task branch with proper validation and state tracking.

**Performance**: Reduces merge errors, ensures work properly integrated

## When to Use This Skill

### ✅ Use merge-agent-work When:

- Agent has completed work (status.json shows "completed")
- Need to merge agent branch to task branch
- Want validation that merge succeeded
- Coordinating multiple agent merges

### ❌ Do NOT Use When:

- Agent still working (status.json shows "in_progress")
- Agent encountered errors (status.json shows "failed")
- Conflicts expected (need manual resolution)
- Merging to main (use git-merge-linear skill instead)

## What This Skill Does

### 1. Verifies Agent Completion

```bash
# Check agent status
STATUS=$(jq -r '.status' /workspace/tasks/{task}/agents/{agent}/status.json)
if [ "$STATUS" != "completed" ]; then
  echo "Agent not completed: $STATUS"
  exit 1
fi
```

### 2. Switches to Task Worktree

```bash
# Must merge in task worktree
cd /workspace/tasks/{task-name}/code
```

### 3. Merges Agent Branch

```bash
# Merge agent branch to task branch
git merge {task-name}-{agent} --no-ff --no-edit
```

### 4. Validates Merge

```bash
# Verify merge succeeded
- No conflicts
- Files added/modified as expected
- Build still succeeds (optional)
- Commit created
```

### 5. Updates State Tracking

```bash
# Update task.json
jq '.agents.{agent}.merged = true | .agents.{agent}.merge_time = "timestamp"' \
  task.json > tmp.json
mv tmp.json task.json
```

## Usage

### Basic Agent Merge

```bash
# After architect agent completes
TASK_NAME="implement-formatter-api"
AGENT="architect"

/workspace/main/.claude/scripts/merge-agent-work.sh \
  --task "$TASK_NAME" \
  --agent "$AGENT"
```

### With Build Validation

```bash
# Merge and validate build succeeds
TASK_NAME="implement-formatter-api"
AGENT="tester"

/workspace/main/.claude/scripts/merge-agent-work.sh \
  --task "$TASK_NAME" \
  --agent "$AGENT" \
  --validate-build true \
  --build-command "mvn test"
```

### Merge Multiple Agents

```bash
# Merge all completed agents
TASK_NAME="implement-formatter-api"

for agent in architect tester formatter; do
  STATUS=$(jq -r '.status' /workspace/tasks/$TASK_NAME/agents/$agent/status.json)
  if [ "$STATUS" = "completed" ]; then
    /workspace/main/.claude/scripts/merge-agent-work.sh \
      --task "$TASK_NAME" \
      --agent "$agent"
  fi
done
```

## Safety Features

### Precondition Validation

- ✅ Verifies task exists
- ✅ Confirms agent completed successfully
- ✅ Checks we're in correct worktree
- ✅ Validates no uncommitted changes

### Merge Validation

- ✅ Detects merge conflicts
- ✅ Confirms merge commit created
- ✅ Validates file changes reasonable
- ✅ Optional build/test validation

### Error Handling

On any error:
- Aborts merge if conflicts
- Reports which validation failed
- Returns JSON with error details
- Leaves repository in consistent state

**Recovery**: Can retry after fixing issues

## Workflow Integration

### Multi-Agent Coordination

```markdown
IMPLEMENTATION state: All agents working in parallel
  ↓
Agent 1 completes (status: completed)
  ↓
[merge-agent-work: Agent 1 → task branch]
  ↓
Agent 2 completes (status: completed)
  ↓
[merge-agent-work: Agent 2 → task branch]
  ↓
Agent 3 completes (status: completed)
  ↓
[merge-agent-work: Agent 3 → task branch]
  ↓
All agents merged, transition to VALIDATION
```

### Iterative Agent Work

```markdown
Agent implements feature (round 1)
  ↓
[merge-agent-work: Agent → task]
  ↓
Validation finds issues
  ↓
Re-invoke agent for fixes (round 2)
  ↓
[merge-agent-work: Agent → task]
  ↓
Validation passes
```

## Output Format

Script returns JSON:

```json
{
  "status": "success",
  "message": "Agent work merged successfully",
  "task_name": "implement-formatter-api",
  "agent_name": "architect",
  "agent_branch": "implement-formatter-api-architect",
  "task_branch": "implement-formatter-api",
  "merge_commit": "abc123def456",
  "files_changed": 15,
  "insertions": 450,
  "deletions": 23,
  "build_validation": "passed",
  "timestamp": "2025-11-11T12:34:56-05:00"
}
```

## Merge Strategies

### No Fast-Forward (Default)

```bash
# Creates merge commit (preserves agent work history)
git merge {agent-branch} --no-ff

# Benefit: Clear history of agent contributions
# Result: Merge commit shows what agent did
```

### Fast-Forward (Optional)

```bash
# Linear history (no merge commit)
git merge {agent-branch} --ff-only

# Benefit: Cleaner history
# Risk: Loses agent contribution visibility
```

### Squash (NOT Recommended)

```bash
# Squashes all agent commits into one
git merge {agent-branch} --squash

# Problem: Loses agent work history
# Use case: Only if agent made many tiny commits
```

## Conflict Resolution

### Automatic Resolution

```bash
# For simple conflicts, skill can auto-resolve:
- Both added same file → Use agent's version
- Both modified same file → Use agent's version (if main agent made no changes)
```

### Manual Resolution Required

```bash
# Skill reports conflict, main agent must resolve:
- Both modified same lines
- Complex merge conflicts
- Semantic conflicts (code compiles but behavior conflicts)
```

## Validation Levels

### Minimal (Default)

```bash
# Quick validation:
- Merge completed
- No conflicts
- Commit created
```

### Standard

```bash
# More thorough:
- Minimal validation
- File count reasonable (not empty merge)
- Diff size reasonable (not huge merge)
```

### Full

```bash
# Complete validation:
- Standard validation
- Build succeeds
- Tests pass
- No Checkstyle/PMD violations
```

## Related Skills

- **gather-requirements**: Invokes agents before merge needed
- **task-cleanup**: Cleans up agent branches after merge
- **git-merge-linear**: Merges task to main (different from agent to task)

## Troubleshooting

### Error: "Agent not completed"

```bash
# Check agent status
jq -r '.status' /workspace/tasks/{task}/agents/{agent}/status.json

# Possible statuses:
# - "in_progress" → Wait for completion
# - "failed" → Investigate agent error
# - "not_started" → Agent never invoked

# Wait for completion or re-invoke agent
```

### Error: "Merge conflicts detected"

```bash
# View conflicts
cd /workspace/tasks/{task-name}/code
git status

# Resolve manually:
# 1. Edit conflicted files
# 2. Stage resolved files: git add <file>
# 3. Complete merge: git commit
# 4. Update state tracking
```

### Error: "Build fails after merge"

```bash
# Merge succeeded but build broken

# Options:
# 1. Revert merge: git reset --hard HEAD~1
# 2. Re-invoke agent with fix requirements
# 3. Main agent fixes in VALIDATION state (if compilation error)

# After fix, retry merge
```

### Error: "Wrong worktree"

```bash
# Must be in task worktree, not agent worktree

# Verify current directory
pwd
# Should be: /workspace/tasks/{task-name}/code
# NOT: /workspace/tasks/{task-name}/agents/{agent}/code

# Switch to task worktree
cd /workspace/tasks/{task-name}/code
```

## Common Patterns

### Pattern 1: Serial Merges

```bash
# Merge agents one at a time, validate each
merge architect → validate → merge tester → validate → merge formatter
```

### Pattern 2: Batch Merge

```bash
# Merge all completed agents, then validate once
merge architect → merge tester → merge formatter → validate all
```

### Pattern 3: Incremental Integration

```bash
# Merge agent, test, fix if needed, repeat
merge agent → test → if fail: fix → merge again
```

## Implementation Notes

The merge-agent-work script performs:

1. **Validation Phase**
   - Check task exists
   - Verify agent completed
   - Confirm correct worktree
   - Validate no uncommitted changes

2. **Merge Preparation Phase**
   - Switch to task worktree
   - Verify task branch checked out
   - Update working directory to latest

3. **Merge Execution Phase**
   - Execute git merge command
   - Capture merge output
   - Detect conflicts

4. **Merge Validation Phase**
   - Verify merge commit created
   - Check file changes reasonable
   - Optional: run build/tests
   - Optional: check style compliance

5. **State Update Phase**
   - Update task.json (agent merged)
   - Record merge commit SHA
   - Update merge timestamp

6. **Reporting Phase**
   - Return status (success/failure)
   - List files changed
   - Provide merge statistics
   - Report validation results
