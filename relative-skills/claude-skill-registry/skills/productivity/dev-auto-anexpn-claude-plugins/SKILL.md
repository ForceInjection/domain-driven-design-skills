---
name: dev-auto
description: Autonomous development workflow. Generate detailed specs, plans, and tasks for autonomous agent execution with session memory tracking.
---

# Autonomous Development Workflow

## Overview

Generate comprehensive documentation that enables autonomous agents to implement features, fixes, or changes without constant human supervision. All work is tracked in session docs (spec, plan, tasks) that serve as long-term memory across implementation sessions.

## When to Use This Skill

Use this skill when:
- Working on well-defined features or fixes
- Work can be fully specified upfront
- Implementation can proceed autonomously with minimal supervision
- Long-term session memory is desired for tracking progress

**Do NOT use for:**
- Exploratory work requiring human decisions at each step (use dev-guided instead)
- Trivial changes that don't require planning
- Quick iterations where formal documentation is overhead

## Workflow Phases

This workflow consists of 5 phases. Some run interactively in the main conversation (requiring user input), while others can run as autonomous subagents.

### Phase 1: Specification (Interactive)

Generate a comprehensive design specification through iterative questioning.

**Process:**
1. Examine the project to understand current state
2. Ask ONE question at a time (preferring multiple choice)
3. Refine understanding through Q&A until certain
4. Present specification in 200-300 word sections
5. Get approval for each section before proceeding
6. Write final spec to `docs/development/NNN-<name>/spec.md`

**Reference:** See `references/phase-spec.md` for detailed guidance

**User involvement:** Answer questions, approve spec sections

### Phase 2: Planning (Interactive or Subagent)

Create detailed implementation plan assuming implementer has minimal context.

**Approach:**
1. **Tech stack selection** (when needed) - Research and document library/framework choices
2. **File/module mapping** - Exact paths for new/modified code
3. **Dependency order** - Build sequence so later pieces have foundations
4. **Integration points** - How new code connects to existing code
5. **Risk flags** - Potentially tricky parts
6. **Testing guidance** - What to test, where tests go

**CRITICAL:** No code in the plan. Describe what needs to be built, not how to code it.

**Reference:** See `references/phase-plan.md` for detailed requirements

**For subagent implementation:** See `references/templates/subagent-plan.md` for prompt template

**Output:** `docs/development/NNN-<name>/plan.md`

**User involvement:** Review and approve the plan

### Phase 3: Task Extraction (Interactive or Subagent)

Break down the plan into trackable tasks.

**Task format:**
```markdown
- [ ] Task description (Plan lines: XX-YY)
```

**Task granularity:** Each task should deliver coherent, testable functionality. NOT file operations or single-line changes.

**Reference:** See `references/phase-tasks.md` for extraction rules

**For subagent implementation:** See `references/templates/subagent-tasks.md` for prompt template

**Output:** `docs/development/NNN-<name>/tasks.md`

**User involvement:** Review task list

### Phase 4: Implementation (Autonomous - Subagent or External Agent)

Implement tasks one at a time in isolated sessions.

**Implementation Options:**

**Option A: Claude Subagent**
- Spawn fresh subagent for each task
- Embed full context in prompt (spec sections, plan section, project context)
- Subagent implements according to plan (NO deviation)
- Follows TDD/DRY/YAGNI
- Reports completion but does NOT mark complete or commit yet

**Reference:** See `references/phase-impl.md` for implementation constraints

**For subagent implementation:** See `references/templates/subagent-impl.md` for prompt template

**Option B: External Coding Agent**
- Provide agent with task list, spec, plan file paths
- Provide agent with `references/phase-impl.md` instructions
- Agent implements next uncompleted task
- Agent reports completion (does NOT mark complete or commit)

**Option C: Human Implementation**
- Read next task from tasks.md
- Read corresponding spec and plan sections
- Implement according to plan
- Report completion for review

**User involvement:** Choose implementation method, trigger each task

### Phase 5: Review (Interactive)

Review completed work before marking complete.

**Process:**
1. Read the spec, plan section, and implementation
2. Check against requirements, code quality, tests
3. Provide specific feedback OR sign-off
4. Route feedback to implementer if issues found
5. After sign-off, authorize task completion and commit

**Reference:** See `references/phase-review.md` for review checklist

**User involvement:**
- Trigger review after implementation completes
- Authorize task completion and commit after sign-off

## Session Memory

All artifacts in `docs/development/NNN-<name>/` serve as long-term memory:

```
docs/development/NNN-<name>/
├── spec.md       # What we're building (design specification)
├── plan.md       # How we're building it (implementation plan)
└── tasks.md      # Implementation checklist with progress tracking
```

These files enable:
- Resuming work after interruption (check tasks.md for progress)
- Context for autonomous agents (read spec + plan + task)
- Historical record of implementation decisions
- Progress tracking across multiple sessions

## Using This Skill

### Full Workflow

Invoke this skill and say:
> "I want to implement [feature/fix description]"

The skill will guide through all 5 phases.

### Individual Phases

Invoke specific phases when needed:
- **"Start spec phase"** - Begin specification
- **"Generate plan from spec"** - Create plan (provide spec path)
- **"Extract tasks from plan"** - Create task list (provide plan path)
- **"Implement next task"** - Implement next uncompleted task (provide task list path)
- **"Review implementation"** - Review completed work (provide task number)

### Resuming After Interruption

If interrupted mid-workflow:
1. Read `docs/development/NNN-<name>/tasks.md` to see completed tasks
2. Continue with next uncompleted task
3. The autonomous agent will pick up from current progress

### Modifying the Plan

If plan needs adjustment during implementation:
1. Edit `docs/development/NNN-<name>/plan.md`
2. Update affected tasks in `tasks.md`
3. Continue implementation with updated plan

## For Autonomous Agents

When implementing tasks autonomously (subagents or external agents), follow this critical principle:

**Subagents start with NO context.** They cannot discover information on their own. For reliable results, embed all necessary content directly in the prompt:

1. Full content of relevant reference files (not just paths)
2. Full content of spec sections (not just the file path)
3. Specific plan sections extracted by line number
4. Project context (test commands, file locations, patterns)

**Templates:** Use the prompt templates in `references/templates/` which show exactly what content to embed for each phase.

## Key Principles

1. **Separation of concerns** - Design, implementation, and review are distinct phases
2. **Plan adherence** - Autonomous implementers follow the plan strictly
3. **Rich context for agents** - Embed content in prompts, not just file paths
4. **Incremental commits** - Each task gets its own commit after review sign-off
5. **Session memory** - All artifacts persist for long-term tracking
6. **Quality gates** - Nothing marked complete without review sign-off

## Resources

Detailed phase instructions in `references/`:
- `phase-spec.md` - Specification generation guidance
- `phase-plan.md` - Planning requirements and format
- `phase-tasks.md` - Task extraction rules
- `phase-impl.md` - Implementation constraints
- `phase-review.md` - Review checklist

Subagent prompt templates in `references/templates/`:
- `subagent-plan.md` - Planning subagent template
- `subagent-tasks.md` - Task extraction subagent template
- `subagent-impl.md` - Implementation subagent template
