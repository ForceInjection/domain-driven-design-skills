---
name: flow-navigator
description: Navigate Flow projects with dashboard-first pattern. Use when user asks about status, current work, what's next, or project progress. Read-only skill.
allowed-tools: Read, Grep, Glob
---

# Flow Navigator

Navigate Flow framework projects using the dashboard-first pattern. This Skill helps you understand project structure, locate current work, and guide users through their Flow workflow.

## When to Use This Skill

Activate when the user asks questions like:
- "Where am I in the project?"
- "What should I work on next?"
- "Show me the current status"
- "What's left to do?"
- "Where are we in the plan?"
- "What's the progress?"

## Dashboard-First Navigation Pattern

**Golden Rule**: Always start with DASHBOARD.md before diving into details.

### Step 1: Read DASHBOARD.md

Start here for every navigation request:

```
Read .flow/DASHBOARD.md
```

The dashboard contains:
- **Current Work** section → Shows active phase/task/iteration
- **Progress Overview** section → Shows all phases with status markers
- **Key Decisions** section → Important architectural choices
- **Success Criteria** section → What "done" looks like

### Step 2: Parse Current Work

Extract the active work location:

```markdown
## 📍 Current Work
- **Phase**: [Phase 2 - Implementation](phase-2/)
- **Task**: [Task 3 - API Integration](phase-2/task-3.md)
- **Iteration**: [Iteration 2 - Error Handling] 🚧 IMPLEMENTING
```

This tells you:
- Current phase number and name
- Current task number and file path
- Current iteration status

### Step 3: Read Task File (Only When Needed)

**When to read task files**:
- User asks for specific details about current task
- User wants to see action items or implementation notes
- User needs to understand iteration goals

**When to stay at dashboard level**:
- User only wants high-level status
- User asks "what's next" (dashboard shows this)
- Quick progress checks

**Pattern**:
```
Read .flow/phase-N/task-M.md
```

### Step 4: Use Status Markers

Understand progress through markers:
- ✅ **COMPLETE** - Work finished and verified
- 🚧 **IN PROGRESS** - Currently being worked on
- ⏳ **PENDING** - Not started yet
- 🎨 **READY** - Brainstorming complete, ready to implement
- ❌ **CANCELLED** - Decided not to do this
- 🔮 **FUTURE** - Deferred to later version

## Common Navigation Patterns

### Pattern 1: "What should I do next?"

1. Read DASHBOARD.md
2. Check "Current Work" section
3. If iteration is 🚧 IMPLEMENTING: "Continue working on [iteration name]"
4. If no active work: Check next ⏳ PENDING task/iteration

### Pattern 2: "Where are we in the plan?"

1. Read DASHBOARD.md
2. Count completed vs total tasks/iterations
3. Report: "Phase X in progress, Y/Z tasks complete"
4. Highlight current focus from "Current Work"

### Pattern 3: "Show me the current status"

1. Read DASHBOARD.md
2. Report from "Current Work" section
3. Show active iteration with status marker
4. List immediate next steps

### Pattern 4: "What's left to do?"

1. Read DASHBOARD.md "Progress Overview"
2. Count ⏳ PENDING items across all phases
3. Provide breakdown: "X tasks, Y iterations remaining"
4. Optionally list high-level task names

## Multi-File Architecture

Flow projects use this structure:

```
.flow/
├── DASHBOARD.md          # Start here - high-level view
├── PLAN.md               # Architecture, scope, decisions
├── phase-1/
│   ├── task-1.md         # Detailed task breakdown
│   ├── task-2.md
│   └── task-3.md
├── phase-2/
│   └── task-1.md
└── phase-3/
    └── task-1.md
```

**Navigation hierarchy**:
1. DASHBOARD.md → Overview, current work, progress
2. PLAN.md → Architecture decisions, scope boundaries
3. phase-N/task-M.md → Detailed iterations, action items, implementation notes

## Read-Only Philosophy

**This Skill is for navigation, not modification.**

✅ **DO**:
- Read files to understand structure
- Parse status markers
- Report progress to user
- Suggest next steps

❌ **DON'T**:
- Modify DASHBOARD.md or task files
- Update status markers
- Add/remove tasks
- Make architectural changes

**When user wants changes**: Guide them to appropriate actions:
- To start working on a task: Help them understand what task to begin
- To begin iteration implementation: Verify they're ready (brainstorming complete)
- To mark iteration done: Verify all work is complete first
- Read-only skill: Cannot modify files, only show status and suggest next steps

## Examples

### Example 1: Quick Status Check

```
User: "What's next?"

Response:
1. Read .flow/DASHBOARD.md
2. Parse "Current Work" section
3. Report: "You're on Phase 2, Task 3, Iteration 2 (Error Handling) 🚧 IN PROGRESS.

   Current focus: Implementing retry logic with exponential backoff.

   Next step: Complete this iteration, then move to Iteration 3 (Logging)."
```

### Example 2: Progress Overview

```
User: "Show me where we are in the plan"

Response:
1. Read .flow/DASHBOARD.md
2. Count completion:
   - Phase 1: ✅ COMPLETE (3/3 tasks)
   - Phase 2: 🚧 IN PROGRESS (1/4 tasks complete)
   - Phase 3: ⏳ PENDING

3. Report: "Phase 2 in progress. Completed 4 of 10 total iterations.

   Currently implementing: Task 3, Iteration 2 (Error Handling)

   Remaining work: 2 iterations in current task, then 3 more tasks in Phase 2, plus Phase 3."
```

### Example 3: Lost User

```
User: "I'm confused, where am I?"

Response:
1. Read .flow/DASHBOARD.md
2. Show clear location:
   "You're in the **Flow Framework Agent Skills** project.

   📍 Current Location:
   - Phase: Phase 2 - Core Skills Implementation
   - Task: Task 1 - flow-navigator Skill
   - Iteration: Iteration 1 - SKILL.md creation 🚧 IMPLEMENTING

   What you're doing: Creating the navigation Skill file with dashboard-first instructions.

   Files you're working in: framework/skills/flow-navigator/SKILL.md"
```

## Best Practices

1. **Always read DASHBOARD.md first** - Never skip straight to task files
2. **Respect status markers** - They're the source of truth for progress
3. **Stay high-level by default** - Only dive into details when asked
4. **Use exact marker symbols** - Don't paraphrase (✅ not "done", 🚧 not "working")
5. **Reference file paths** - Help user understand multi-file structure
6. **Suggest next actions** - Guide user on what to do next based on context

## References

- **Dashboard-first approach**: Read DASHBOARD.md to understand current position
- **Status markers**: DEVELOPMENT_FRAMEWORK.md lines 1872-1968
- **Multi-file architecture**: DEVELOPMENT_FRAMEWORK.md lines 105-179
- **Quick Reference Guide**: DEVELOPMENT_FRAMEWORK.md lines 1-353
