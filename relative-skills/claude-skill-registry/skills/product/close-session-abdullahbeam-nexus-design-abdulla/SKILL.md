---
name: close-session
description: Load when user says "done", "finish", "complete", "close", "wrap up", "end session", or any system skill/project completes
---

# Close Session

Save progress, update memory, regenerate navigation, and ensure system integrity.

## Purpose

The `close-session` skill is the most critical system skill. It ensures nothing is ever lost by:
- Reading and updating project progress from steps.md checkboxes
- Validating workspace-map.md accuracy (auto-detect mismatches)
- Updating memory with decisions and patterns
- Cleaning temporary files from root folder
- Creating historical session reports
- Displaying comprehensive summary

**CRITICAL**: This skill is AUTO-TRIGGERED by all other skills and projects (not user-dependent!).

---

## Execution Sequence

1. **Initialize TodoWrite** with all 10 steps (MANDATORY - prevents skipped steps)
2. Load [workflow.md](references/workflow.md)
3. Execute steps 1-10 sequentially
4. Mark each step complete in TodoWrite as you finish it

---

## Critical Rules

1. **TodoWrite is MANDATORY**: Initialize at start with all 10 steps - prevents forgetting critical steps
2. **PLANNING phase projects**: Skip task completion (Step 2/2.5)
3. **IN_PROGRESS phase projects**: Auto-complete if execution signals detected
4. **Session reports**: Create in 01-memory/session-reports/
5. **Summary display**: ≤5 lines per orchestrator.md rule

---

## Key Features

### Automatic & Interactive Task Completion
Smart task completion with automatic detection:
- **Automatic Bulk Complete**: If project work completed this session, auto-marks all tasks
- **Manual Bulk Option**: If auto-detect missed it, offers bulk-complete during review
- **Interactive Review**: Shows first 10 unchecked tasks for manual selection
- User selects by number ("1, 3, 5"), "all", "bulk complete", or "none"
- Updates tasks.md automatically (via Edit tool or bulk-complete script)
- Recalculates progress after any changes



### Temp File Cleanup
Interactive cleanup with user choices:
- Scans root folder for temp files
- Asks what to do with each: keep, delete, or skip
- Moves preserved files to project outputs/
- Reports cleanup summary

### Session Reporting
Creates historical record:
- Generates session report in 01-memory/session-reports/
- Includes work completed, progress, decisions, patterns
- Provides context for next session

### Progress Tracking
Auto-calculates from checkboxes:
- Counts total tasks (all `- [ ]` and `- [x]`)
- Counts completed tasks (only `- [x]`)
- Determines status (PLANNING/IN_PROGRESS/COMPLETE)
- Identifies next task

### Auto-Trigger Support
Called automatically by other skills:
- create-project
- validate-system
- Any skill completion

### Memory Preservation
THE critical persistence mechanism:
- Creates session reports
- Cleans temp files

**Without this skill, context does NOT persist across sessions!**

---

## Workflow Overview

Complete workflow with all 9 steps: See [workflow.md](references/workflow.md)

### Steps (from workflow.md):

1. Read project state (skip if no IN_PROGRESS projects)
2. Review task completion (skip if PLANNING phase)
3. Update maps
4. Get timestamp
5. Update memory
6. **Clean temp files** (delete .md files not in system folders)
7. Create session report
8. Display summary (≤5 lines)
9. Mark complete
10. Instruct fresh session

---

## Integration

### Auto-Trigger Format

When called by other skills:

```
Auto-triggering close-session skill...

[Full workflow executes]

Session saved! ✅
[Summary displays]
```

### User-Trigger Format

When user says "done for now":

```
Closing your session...

[Full workflow executes]

Session saved! ✅
[Summary displays]
```

### All Skills Must End With

Every skill and project workflow should conclude with:

```markdown
### Final Step: Close Session
Auto-trigger close-session skill to save progress
```

This ensures:
- Progress is saved
- Maps are updated
- Session is recorded
- Nothing is lost

---

## Error Handling

For complete error scenarios and solutions, see [error-handling.md](references/error-handling.md)

### Common Scenarios:

**No active project** → Skip project steps, continue with maps and cleanup

**Missing tasks.md** → Report in summary, suggest validate-system

**Corrupted memory** → Rebuild from scan, report issue

**Map generation fails** → Keep old maps, report error, suggest retry

**User doesn't respond** → Default to "skip" for temp files

---

## Critical Notes

### Memory Preservation

This skill is the **ONLY** way to:
- Create historical session reports
- Clean temporary files from workspace

### Context Persistence

**Without this skill running at session end:**
- Progress updates are lost
- Navigation maps become stale
- No historical record is created
- Temp files accumulate

**Never skip this skill** - it's the foundation of context preservation!

### Workflow Philosophy

This skill embodies the Nexus philosophy:
- **Memory preservation**: Nothing is ever lost
- **Context awareness**: Full system state captured
- **Progressive disclosure**: Load what you need, when you need it
- **User collaboration**: Interactive choices for important decisions

---

## Resources

### references/
- **workflow.md**: Complete 9-step workflow (with TOC)
- **error-handling.md**: All error scenarios and solutions

### Integration with bulk-complete Skill

This skill uses the **bulk-complete** system skill for efficient task completion:

**Step 2 & 2.5**: Auto-runs bulk-complete when project work is done
```bash
python 00-system/skills/bulk-complete/scripts/bulk-complete.py --project [ID] --all --no-confirm
```

See [bulk-complete/SKILL.md](../bulk-complete/SKILL.md) for standalone usage, all options, and test coverage details.

---

**Remember**: This is THE most important system skill. Every session MUST end with close-session to preserve context!
