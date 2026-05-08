---
name: save-session
description: Use this skill when the user wants to save session progress before running /clear, or when you notice significant progress has been made that should be saved to TASKS.md and committed to git (project)
---

# Save Session Progress - Automated Experimentation System

This skill helps you prepare for a `/clear` command by saving all session progress to TASKS.md and committing work to git. Optimized for the Survey Automation project with 10 PRPs across 4 phases.

## When to Use This Skill

- **User explicitly asks**: "save session", "save progress", "prepare for clear"
- **Before /clear**: Anytime the user is about to run /clear
- **Proactively**: When significant progress has been made (e.g., PRP completed, multiple commits made)
- **End of work session**: When wrapping up work for the day
- **After completing a PRP**: Save progress after each PRP passes all quality gates

## Instructions

### Step 1: Read Current TASKS.md Status

Check current state:
- Which PRP is currently being worked on or was just completed
- What phase we're in (Phase 1-4)
- Current phase progress (X/Y PRPs)
- Overall progress (X/10 PRPs)
- Session number (increment if new session)

### Step 2: Update TASKS.md CURRENT STATUS Section

Update the **CURRENT STATUS (Session X - YYYY-MM-DD)** section with:

```markdown
## CURRENT STATUS (Session X - YYYY-MM-DD)

### Recently Completed
- YYYY-MM-DD: [What was completed this session]
  - Key accomplishment 1
  - Key accomplishment 2
  - ([test count] tests passing, [coverage]% coverage if applicable)

### In Progress
- [Current task] or "None - Ready to begin Phase X"

### Next Steps
1. [Immediate next action]
2. [Second action]
3. [Third action]

### Blockers
[List blockers or "None currently"]
```

### Step 3: Update Individual PRP Status

For completed PRPs, update the PRP status in the PHASES AND PRPS section:
```markdown
#### PRP-XXX: [Name]
**Status**: COMPLETED ✓ (YYYY-MM-DD)
**Domain**: Backend/Fullstack/Infrastructure
**Dependencies**: [List]
**Description**: [Description]

**Completion Summary**:
- [test count] tests passing, [coverage]% coverage
- Key features: [feature 1], [feature 2]
- Quality gates: All passed ✓
```

### Step 4: Update SESSION HISTORY Section

Add new session entry or update current session:
```markdown
### Session X - YYYY-MM-DD
**Focus**: [What this session focused on]
**Completed**:
- [Accomplishment 1]
- [Accomplishment 2]
- [Accomplishment 3]
**Quality Metrics**: [X tests, Y% coverage, etc.]
**Next Session**: [What to work on next]
```

### Step 5: Check Git Status and Uncommitted Work

**IMPORTANT**: This project may not have git initialized yet. Check first:

```bash
# Check if git repo exists
ls -la .git 2>/dev/null && echo "Git repo exists" || echo "Git not initialized"

# If git exists, check status
git status 2>/dev/null || echo "No git repo"
```

**If git exists**:
- Check for uncommitted changes
- List modified files
- Note any untracked files that should be committed

**If git doesn't exist**:
- Skip git operations
- Only update TASKS.md
- Recommend initializing git in report

### Step 6: Commit Changes (Only if Git Exists)

**Only execute if git repo exists**:

```bash
git add TASKS.md
git status
git commit -m "chore: save session progress - [brief summary]

[Optional detailed summary if significant work done]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**If other files need committing** (code, configs, etc.):
```bash
git add -A
git status
git commit -m "feat/fix/chore: [appropriate message]

[Summary of changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 7: Report to User

Provide a clear summary:

```markdown
✅ Session Progress Saved!

**Updated TASKS.md**:
- Session: Session X - YYYY-MM-DD
- Phase: Phase X - [name] (X/Y PRPs)
- Completed This Session: [Brief summary]
- Next Steps: [What to do next]
- Total Progress: X/10 PRPs completed

**Git Status** (if applicable):
- ✅ TASKS.md committed
- [Other files committed if any]
- Commit: [commit hash] [commit message]

**OR** (if no git):
- ⚠️ Git not initialized (recommend: git init)
- TASKS.md updated locally

**Next Steps**:
1. Run: `/clear` to free up context
2. Run: `/recover-context` to reload (takes ~30 seconds)
3. Continue with: [Next action]

**Context Recovery**: Fast (~1000 tokens, 30 seconds)
```

## TASKS.md Update Pattern Reference

### CURRENT STATUS Section Format (Lines 21-51)

```markdown
## CURRENT STATUS (Session X - YYYY-MM-DD)

### Recently Completed
- YYYY-MM-DD: [Completed work description]
  - Key accomplishment 1
  - Key accomplishment 2
  - ([X] tests passing, [Y]% coverage)

### In Progress
- [Current task] or "None - Ready to begin Phase X"

### Next Steps
1. [First action to take]
2. [Second action]
3. [Third action]

### Blockers
[List blockers or "None currently"]
```

### Individual PRP Status Update Format (In PHASES AND PRPS Section)

When a PRP is completed:
```markdown
#### PRP-XXX: [Name]
**Status**: COMPLETED ✓ (YYYY-MM-DD)
**Domain**: Backend/Fullstack/Infrastructure
**Dependencies**: [Dependencies]
**Description**: [Description]

**Completion Summary**:
- [X] tests passing, [Y]% coverage
- Key features: [list key features]
- Quality gates: All passed ✓
- Cost: <$X.XX per operation (if applicable)

[Original acceptance criteria remain]
```

### SESSION HISTORY Format (Lines 387-398)

Update or add session entry:
```markdown
### Session X - YYYY-MM-DD
**Focus**: [Main focus of this session]
**Completed**:
- [Accomplishment 1]
- [Accomplishment 2]
- [Accomplishment 3]
**Quality Metrics**: [X tests, Y% coverage, Z commits]
**Next Session**: [What to work on next]
```

## Example Usage

### Example 1: User Explicitly Asks

**User**: "save session progress"

**Claude**:
1. Read TASKS.md to check current status
2. Update CURRENT STATUS section with latest timestamp and accomplishments
3. Update individual PRP status if completed
4. Update SESSION HISTORY with this session's work
5. Check if git exists, commit if applicable
6. Report back to user with summary

### Example 2: Proactive Save After PRP Completion

**Context**: Just finished PRP-003, all tests passing, all quality gates passed

**Claude**:
"I notice we've just completed PRP-003 (Configuration System) with all quality gates passing. Let me save this session progress."

[Executes save-session skill]

### Example 3: Before /clear

**User**: "I'm going to run /clear"

**Claude**:
"Let me save the session progress first to make context recovery faster."

[Executes save-session skill]

### Example 4: End of Work Session

**Context**: User has completed 2 PRPs today and is wrapping up

**Claude** (proactively):
"We've made great progress today completing PRP-001 and PRP-002. Let me save this session progress before you end your work session."

[Executes save-session skill]

## Critical Reminders

- **ALWAYS** check if git exists before attempting git operations
- **ALWAYS** update timestamp to current date (YYYY-MM-DD format)
- **ALWAYS** increment session number if starting a new session
- **ALWAYS** update all three sections: CURRENT STATUS, individual PRP status (if completed), SESSION HISTORY
- **ALWAYS** include quality metrics (tests, coverage) if applicable
- **NEVER** skip completed PRPs in the update
- **NEVER** create separate progress markdown files (use TASKS.md only)
- **NEVER** assume git is initialized (check first)

## Benefits of This Skill

1. **Fast Context Recovery**: Keeps TASKS.md current for `/recover-context` command
2. **Progress Tracking**: Clear record of what was accomplished each session
3. **Git Safety**: Ensures all work is committed before /clear (if git exists)
4. **Consistency**: Standardized format for TASKS.md updates
5. **Efficiency**: Saves time on context recovery after /clear
6. **Quality Tracking**: Records test coverage, quality gates, and performance metrics

## Notes

- This is a **project-level skill** specific to the Automated Experimentation System
- Works in conjunction with `/recover-context` slash command
- Optimizes for context efficiency
- Part of the PRP-based development workflow
- Handles projects with or without git initialization
- Updates 10 PRPs across 4 phases (Foundation, Data Collection, Analysis & Output, Integration & Frontend)

## Quality Gates Reference

When updating PRP completion summaries, verify these quality gates were passed:

1. **Code Quality**: Linting (pylint, black) and type checking (mypy) passed
2. **Testing**: >80% coverage, all tests passing
3. **Security**: No credentials committed, RLS policies enabled, OAuth2 secure
4. **Abstraction Layer**: Factory pattern works, provider switching via .env
5. **Performance & Cost**: LLM calls minimized, token usage optimized, workflow <30s

## Project-Specific Tracking

Track these metrics in completion summaries:

- **LLM Cost**: Token usage and estimated cost per operation
- **MBB Structure**: Slide validation passed (if applicable)
- **Temporal Analysis**: Query performance <100ms (if applicable)
- **API Rate Limits**: Telegram, Gmail, Slides API usage
- **Provider Switching**: Tested Azure OpenAI ↔ OpenAI ↔ Anthropic (if LLM PRP)

## Integration with /recover-context

This skill prepares TASKS.md for fast context recovery:
- CURRENT STATUS section shows immediate next steps
- SESSION HISTORY provides recent context
- Individual PRP status shows what's completed
- Blockers are highlighted for immediate attention

After saving, user can:
1. Run `/clear` to free context
2. Run `/recover-context` to reload in ~30 seconds
3. Continue work immediately from documented state
