---
name: conductor
description: |
  Context-driven development methodology for organized, spec-first coding. Use when:
  - Project has a `conductor/` directory
  - User mentions specs, plans, tracks, or context-driven development
  - Files like `conductor/tracks.md`, `conductor/product.md`, `conductor/workflow.md` exist
  - User asks about project status, implementation progress, or track management
  - User wants to organize development work with TDD practices
  - User invokes `/conductor-*` commands (setup, newtrack, implement, status, revert, validate, block, skip, revise, archive, export, refresh)
  - User mentions documentation is outdated or wants to sync context with codebase changes
  
  Interoperable with Gemini CLI extension and Claude Code commands.
  Integrates with Beads for persistent task memory across sessions.
---

# Conductor: Context-Driven Development

Measure twice, code once.

## Overview

Conductor enables context-driven development by:
1. Establishing project context (product vision, tech stack, workflow)
2. Organizing work into "tracks" (features, bugs, improvements)
3. Creating specs and phased implementation plans
4. Executing with TDD practices and progress tracking
5. **Parallel execution** of independent tasks using sub-agents

## Parallel Execution (New Feature)

Conductor now supports parallel task execution for eligible phases:

### How It Works
- During `/conductor-newtrack`, tasks are analyzed for parallelization potential
- Tasks with no file conflicts and no dependencies can run in parallel
- Parallel phases use `<!-- execution: parallel -->` annotation
- Each task has `<!-- files: ... -->` for exclusive file ownership
- Dependencies use `<!-- depends: ... -->` annotation

### Plan.md Format for Parallel Phases
```markdown
## Phase 1: Core Setup
<!-- execution: parallel -->

- [ ] Task 1: Create auth module
  <!-- files: src/auth/index.ts, src/auth/index.test.ts -->
  
- [ ] Task 2: Create config module
  <!-- files: src/config/index.ts -->
  
- [ ] Task 3: Create utilities
  <!-- files: src/utils/index.ts -->
  <!-- depends: task1 -->
```

### Execution Flow
1. **Coordinator** parses parallel annotations
2. Detects file conflicts (fails safe if found)
3. Spawns sub-agents via `Task()` for independent tasks
4. Monitors `parallel_state.json` for completion
5. Aggregates results and updates plan.md

### When to Use Parallel Execution
- ✅ Tasks modifying different files
- ✅ Independent components (auth, config, utils)
- ✅ Multiple test file creation
- ❌ Tasks with shared state
- ❌ Tasks with sequential dependencies

## Context Loading

When this skill activates, load these files to understand the project:
1. `conductor/product.md` - Product vision and goals
2. `conductor/tech-stack.md` - Technology constraints
3. `conductor/workflow.md` - Development methodology (TDD, commits)
4. `conductor/tracks.md` - Current work status

**Important**: Conductor commits locally but never pushes. Users decide when to push to remote.

For active tracks, also load:
- `conductor/tracks/<track_id>/spec.md`
- `conductor/tracks/<track_id>/plan.md`

## Beads Integration

Beads integration is **always attempted** for persistent task memory. If `bd` CLI is unavailable or fails, the user can choose to continue without it.

### Detection (MUST check before using bd commands)

Before using ANY `bd` command, you MUST verify:
1. `bd` CLI is installed: `which bd` returns a path
2. `conductor/beads.json` exists AND has `"enabled": true`

```bash
# Check availability - run this before any bd command
if which bd > /dev/null 2>&1 && [ -f conductor/beads.json ]; then
  BEADS_ENABLED=$(cat conductor/beads.json | grep -o '"enabled"[[:space:]]*:[[:space:]]*true' || echo "")
  if [ -n "$BEADS_ENABLED" ]; then
    # Beads is available and enabled - use bd commands
  fi
fi
```

### If Beads is NOT available:
- **DO NOT** run any `bd` commands
- Use only plan.md markers for task tracking
- All conductor commands work normally without Beads

### If Beads IS available:
- Tracks become Beads epics
- Tasks sync to Beads for persistent memory
- Use `bd ready` instead of manual task selection
- Notes survive context compaction

## Proactive Behaviors

1. **On new session**: Check for in-progress tracks, offer to resume
2. **On task completion**: Suggest next task or phase verification
3. **On blocked detection**: Alert user and suggest alternatives
4. **On all tasks complete**: Congratulate and offer archive/cleanup
5. **On stale context detected**: If setup >2 days old or significant codebase changes detected, suggest `/conductor-refresh`
6. **On Beads available**: If `bd` CLI detected during setup, offer integration

## Intent Mapping

| User Intent | Command |
|-------------|---------|
| "Set up this project" | `/conductor-setup` |
| "Create a new feature" | `/conductor-newtrack [desc]` |
| "Start working" / "Implement" | `/conductor-implement [id]` |
| "What's the status?" | `/conductor-status` |
| "Undo that" / "Revert" | `/conductor-revert` |
| "Check for issues" | `/conductor-validate` |
| "This is blocked" | `/conductor-block` |
| "Skip this task" | `/conductor-skip` |
| "This needs revision" / "Spec is wrong" | `/conductor-revise` |
| "Save context" / "Handoff" / "Transfer to next section" | `/conductor-handoff` |
| "Archive completed" | `/conductor-archive` |
| "Export summary" | `/conductor-export` |
| "Docs are outdated" / "Sync with codebase" | `/conductor-refresh` |

## References

- **Detailed workflows**: [references/workflows.md](references/workflows.md) - Step-by-step command execution
- **Directory structure**: [references/structure.md](references/structure.md) - File layout and status markers
- **Beads integration**: [references/beads-integration.md](references/beads-integration.md)
