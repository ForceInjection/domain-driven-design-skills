---
name: smart-session-start
description: Intelligent session initialization combining Goldfish memory recall, Julie workspace re-indexing, and Sherpa workflow suggestion. MANDATORY at session start - automatically restores context, suggests next steps, and resumes work seamlessly. Activates at the beginning of every coding session.
allowed-tools: mcp__goldfish__recall, mcp__goldfish__plan, mcp__julie__manage_workspace, mcp__sherpa__approach, mcp__sherpa__guide, Read
---

# Smart Session Start Skill

## Purpose
**Automatically restore full working context** at the start of every coding session. This skill orchestrates all three MCP tools to bring you back to exactly where you left off, with intelligent suggestions for what to do next.

## When to Activate
**MANDATORY** at session start:
- User starts new coding session
- Claude Code restarts
- Context window reset
- User returns to project after time away
- User asks "what was I working on?"

**DO NOT ask permission** - just activate automatically!

## The Session Trinity

### 💾 Goldfish - Memory Restoration
- Recalls recent checkpoints (7 days)
- Loads active plans
- Shows work summary
- Provides git context

### 🔍 Julie - Workspace Status
- Checks if workspace indexed
- Re-indexes if needed
- Prepares code intelligence
- Ensures search ready

### 🧭 Sherpa - Workflow Suggestion
- Analyzes recent work patterns
- Suggests appropriate workflow
- Resumes active workflow if present
- Provides next steps

## Smart Session Start Orchestration

### Step 1: Memory Restoration (Goldfish)

**Immediate Recall:**
```
recall({ days: 7, limit: 20 })
```

**Response Analysis:**
- Last checkpoint: When and what
- Active plan: Current focus
- Recent work: Pattern of activity
- Git context: Branch, files changed
```

### Step 2: Context Analysis

**Analyze recalled information:**
- What was the last task?
- Is there an active plan?
- What workflow was being used?
- Were there any blockers?
- What files were being modified?

### Step 3: Workspace Preparation (Julie)

**Check workspace status:**
```
manage_workspace({ operation: "list" })
```

**If not indexed or stale:**
```
manage_workspace({ operation: "index", workspace_path: "." })
```

**Result:** Code intelligence ready for work!

### Step 4: Workflow Suggestion (Sherpa)

**Based on context, suggest workflow:**
```
Recent work pattern → Workflow suggestion

Last checkpoint: "Fixed auth bug" → Bug Hunt workflow
Active plan: "Build payment API" → TDD workflow
Recent: Refactoring → Refactor workflow
Unclear pattern → General workflow
```

**If workflow was active:**
```
approach({ workflow: "[detected-workflow]" })
guide() → Resume where left off
```

### Step 5: Present Complete Context

**Comprehensive summary:**
```markdown
🎯 Welcome Back!

**Last Session:** [time ago]
Last checkpoint: "[description]"
Branch: [branch-name]
Files: [changed-files]

**Active Work:** "[plan-title]"
Progress: [summary from checkpoints]

**Workspace Status:**
✅ Code intelligence ready
✅ [N] files indexed
✅ Search available

**Suggested Workflow:** [workflow-name]
[One-sentence explanation why]

**Next Steps:**
1. [Specific next action based on context]
2. [Alternative action]
3. [Start something new]

Ready to continue? I've restored your full context.
```

## Example Session Starts

### Example 1: TDD in Progress

```markdown
User starts Claude Code

→ Goldfish: recall()

Results:
- Last checkpoint (2 hours ago): "Wrote 8 tests for PaymentService"
- Active plan: "Payment Processing Implementation"
- Branch: feature/payment-processing
- Workflow pattern: TDD (from checkpoints)

→ Julie: manage_workspace({ operation: "list" })
  Workspace indexed 3 hours ago → Re-index

→ Julie: manage_workspace({ operation: "index" })
  ✅ Indexed 247 files

→ Analysis:
  - Last phase: Writing tests (TDD Phase 2)
  - Next: Implementation (TDD Phase 3)
  - Workflow: TDD

→ Sherpa: approach({ workflow: "tdd" })
  TDD Workflow activated

→ Sherpa: guide()
  "Phase 2: Write Tests" (resume from Phase 2)

→ Present to user:

🎯 Welcome Back!

**Last Session:** 2 hours ago
Last checkpoint: "Wrote 8 tests for PaymentService covering charge, refund, and validation"
Branch: feature/payment-processing
Files: src/services/payment-service.ts, tests/payment.test.ts

**Active Plan:** "Payment Processing Implementation"
Progress: Interface designed ✅, Tests written ✅
Next: Implementation phase

**Workspace Status:**
✅ Code intelligence ready
✅ 247 files re-indexed
✅ Semantic search available

**Suggested Workflow:** TDD (Test-Driven Development)
You were in Phase 2 (Tests), ready to move to Phase 3 (Implementation)

**Next Steps:**
1. Run tests to verify they still fail (TDD discipline)
2. Implement PaymentService to make tests pass
3. Review test coverage before implementing

Your TDD workflow is ready to resume. Tests are written - time to make them green! 🚀
```

### Example 2: Bug Hunt in Progress

```markdown
User starts Claude Code

→ Goldfish: recall()

Results:
- Last checkpoint (yesterday): "Isolated race condition in session.destroy()"
- Active plan: "Fix Random Logout Bug"
- Branch: bugfix/session-logout
- Recent: Investigation discoveries

→ Julie: Workspace already indexed (fresh)
  ✅ Skip re-index

→ Analysis:
  - Bug isolated but not fixed yet
  - Phase: Bug Hunt Phase 1 complete
  - Next: Write test to capture bug

→ Sherpa: approach({ workflow: "bug-hunt" })
  Bug Hunt Workflow activated

→ Sherpa: guide()
  "Phase 2: Capture in Test"

→ Present to user:

🕵️ Welcome Back!

**Last Session:** 1 day ago
Last investigation: "Isolated race condition in session.destroy() - occurs when logout happens during auth check"
Branch: bugfix/session-logout
Files: src/session.ts, src/auth-middleware.ts

**Active Investigation:** "Fix Random Logout Bug"
Status: Root cause identified (race condition)
Next: Capture in test, then fix

**Workspace Status:**
✅ Code intelligence ready
✅ Index current (no re-index needed)
✅ Semantic search available

**Suggested Workflow:** Bug Hunt (Systematic Debugging)
You're in Phase 2: Capture in Test

**Next Steps:**
1. Write failing test that reproduces the race condition
2. Verify test fails consistently
3. Then move to fix with mutex/locking

Great detective work yesterday! You found the race condition. Now let's capture it in a test before fixing. 🕵️
```

### Example 3: New Session, No Recent Work

```markdown
User starts Claude Code (new workspace)

→ Goldfish: recall()

Results: Empty (no checkpoints)

→ Julie: manage_workspace({ operation: "list" })
  Workspace not indexed

→ Julie: manage_workspace({ operation: "index" })
  ✅ Indexed 423 files

→ Analysis:
  - Fresh start
  - No active workflow
  - No active plan

→ Present to user:

👋 Welcome!

**New Session**
This is a fresh workspace - no previous work detected.

**Workspace Status:**
✅ Code intelligence ready
✅ 423 files indexed (TypeScript, JavaScript, Python detected)
✅ Semantic search available

**Ready for:**
- Feature development (use TDD)
- Bug fixes (use Bug Hunt)
- Code exploration (ask me to explore!)
- Refactoring (safe refactoring available)

**Next Steps:**
1. Tell me what you want to work on
2. I'll suggest the right workflow
3. I'll track progress with checkpoints

What would you like to build? 🚀
```

## Intelligence Patterns

### Workflow Detection from Checkpoints

```
Pattern Analysis:
tags: ["tdd", "tests"] → TDD workflow
tags: ["bug-hunt", "investigation"] → Bug Hunt workflow
tags: ["refactor"] → Refactor workflow
tags: ["planning", "design"] → Planning workflow
```

### Phase Detection

```
TDD checkpoint pattern:
"designed interface" → Phase 1 complete
"wrote tests" → Phase 2 complete
"all tests passing" → Phase 3 complete
"refactored" → Phase 4 complete

Bug Hunt pattern:
"isolated bug" → Phase 1 complete
"wrote failing test" → Phase 2 complete
"test passes" → Phase 3 complete
"verified fix" → Phase 4 complete
```

### Next Step Prediction

```
Based on last checkpoint + active plan:
- Phase incomplete → Continue current phase
- Phase complete → Advance to next phase
- Workflow complete → Suggest next work item
- Blocker mentioned → Address blocker first
```

## Workspace Re-indexing Logic

```
Check last index time:
- < 1 hour ago → Skip (fresh enough)
- 1-6 hours ago → Quick index if files changed
- > 6 hours ago → Full re-index
- Never indexed → Full index (required)

Index in background if possible
- Don't block session start
- Search works during indexing
```

## Key Behaviors

### ✅ DO
- Activate automatically at session start
- Recall full context (7 days worth)
- Re-index workspace if stale
- Analyze work patterns intelligently
- Suggest appropriate workflow
- Present concise, actionable summary
- Resume active workflow automatically

### ❌ DON'T
- Ask permission to restore context
- Overwhelm with all checkpoint details
- Skip workspace indexing check
- Suggest wrong workflow
- Present without next steps
- Ignore active plans
- Miss git context

## Success Criteria

Smart Session Start succeeds when:
- User feels immediate continuity
- No "what was I doing?" confusion
- Workspace ready for work
- Right workflow suggested
- Clear next steps provided
- Active plans resumed
- Git context understood

## Performance

- Goldfish recall: ~30-150ms
- Julie workspace check: ~50ms
- Julie re-index (if needed): ~2-10s (background)
- Sherpa activation: ~50ms
- Analysis and presentation: ~100ms

**Total**: <500ms + optional background indexing

**Result:** Nearly instant context restoration!

---

**Remember:** Smart Session Start is MANDATORY. Every session should begin with full context restoration. Don't ask, just restore and present!
