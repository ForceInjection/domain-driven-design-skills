---
name: speckit-generator
description: >
  Project-focused specification and task management system. Run /speckit.init to install
  8 project-local commands: /plan, /tasks, /design, /analyze, /clarify, /implement, /revert, /lint.
  Each command MUST be invoked separately and requires user approval before proceeding.
  NEVER chain commands automatically - each produces output that requires user review.
  Use /plan when user wants to create plans from specs. Use /tasks only AFTER user has approved plans.
  Git checkpoints enable safe revert.
---

# SpecKit Generator

Project-focused specification management with 1 bootstrap command (/speckit.init) that installs 8 project-local commands to transform specifications into executed implementations with git checkpoint safety.

## Table of Contents
- [Critical Workflow Rules](#critical-workflow-rules)
- [Overview](#overview)
- [Commands](#commands)
- [Command: init](#command-init)
- [Command: plan](#command-plan)
- [Command: tasks](#command-tasks)
- [Command: analyze](#command-analyze)
- [Command: clarify](#command-clarify)
- [Command: implement](#command-implement)
- [Command: revert](#command-revert)
- [Memory File System](#memory-file-system)
- [Idempotency](#idempotency)

---

## Critical Workflow Rules

**MANDATORY: Commands must NOT be chained automatically.**

Each command produces artifacts that require user review and approval before proceeding to the next phase. This is not optional.

### Required Gates

| After Command | MUST DO | Before Proceeding To |
|---------------|---------|---------------------|
| `/speckit.init` | Present created structure, confirm memory files | Any other command |
| `/speckit.plan` | Present plan summary, wait for explicit approval | `/speckit.tasks` |
| `/speckit.tasks` | Present task summary, wait for explicit approval | `/speckit.implement` |

### Recommended Workflow

```
/speckit.init
    ↓ [User reviews structure]
/speckit.plan
    ↓ [User reviews plan]
/speckit.analyze ← Run BEFORE approving plan
    ↓ [Address any CRITICAL/HIGH findings]
/speckit.clarify ← Run if [TBD] items exist
    ↓ [User approves final plan]
/speckit.tasks
    ↓ [User reviews tasks]
/speckit.implement
```

### What NOT To Do

- ❌ Run `/speckit.plan` then immediately `/speckit.tasks` without user approval
- ❌ Generate all artifacts in one session without checkpoints
- ❌ Skip `/speckit.analyze` before plan approval
- ❌ Proceed past a GATE without explicit user confirmation

### Gate Response Format

After completing a command, present results in this format:

```
## [Command] Complete

[Summary of what was created/modified]

### Artifacts Created
- [list of files]

### Recommended Next Steps
1. Review the [artifacts] above
2. Run `/speckit.analyze` to check compliance (if applicable)
3. Run `/speckit.clarify` to resolve any [TBD] items (if applicable)

**Awaiting your approval before proceeding.**
```

---

## Overview

SpecKit provides a complete workflow for specification-driven development:

```
init → plan → tasks → implement
  ↑      ↑      ↑         ↑
  └──────┴──────┴─────────┘
         analyze/clarify (anytime)
```

### Core Principles

1. **Separation of Concerns**: Plans define WHAT, tasks define HOW
2. **Memory-Driven Compliance**: All execution references constitution.md and relevant memory files
3. **Idempotent Operations**: All commands safe to run repeatedly
4. **Deterministic Analysis**: analyze produces identical output for identical input

---

## Commands

### Plugin Command (Global)

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/speckit.init` | Establish .claude/ foundation with git, install project commands | New projects or incomplete setup |

### Project Commands (Installed by /speckit.init)

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/plan` | Create plans from specifications | After specs exist in speckit/ |
| `/tasks` | Generate tasks from plans | After plans are approved |
| `/design` | Generate detailed task designs | Before implementing complex tasks |
| `/analyze` | Audit project consistency | Anytime for health check |
| `/clarify` | Resolve ambiguities | When specs have open questions |
| `/implement` | Execute tasks with git checkpoint | When ready to implement |
| `/revert` | Revert to checkpoint with analysis | When implementation fails |
| `/lint` | Scan code for anti-patterns | Before code review or after implementation |

---

## Command: init

Establish the `.claude/` foundation with appropriate memory files for the project.

### Trigger
- Explicit: `/speckit.init`
- Automatic: Other commands detect missing setup

### Workflow

1. **Check existing state** - Detect if .claude/ exists
2. **Detect tech stack** - Analyze project for languages/frameworks
3. **Present detection** - Show detected stack and recommended memory files
4. **Create structure** - Build directory structure
5. **Copy memory files** - Select and copy based on tech stack
6. **Generate project context** - Create project-context.md

### Directory Structure Created

```
.claude/
├── commands/      # Custom project commands
├── memory/        # constitution.md + tech-specific files
│   └── MANIFEST.md
├── templates/     # Output templates
└── scripts/       # Project scripts

speckit/           # SpecKit artifacts (specs, plans, tasks, designs)
├── spec.md
├── plan.md
├── tasks.md
├── plans/         # Multi-domain plans (if complex)
└── designs/       # Design documents
```

### Memory File Selection

| Category | Files | Selection |
|----------|-------|-----------|
| Universal | constitution.md, documentation.md, git-cicd.md, security.md, testing.md | Always |
| TypeScript/JS | typescript.md | If TS/JS detected |
| React/Next.js | react-nextjs.md | If React/Next detected |
| Tailwind | tailwind-shadcn.md | If Tailwind detected |
| Python | python.md | If Python detected |
| Rust | rust.md | If Rust detected |

### Options

```
Options:
1. Accept recommended selection
2. Add additional memory files
3. Remove memory files from selection
4. Override detected stack manually
```

See `references/command-workflows/init-workflow.md` for detailed workflow.

---

## Command: plan

Create implementation plans from specification files. Hierarchical for complex/multi-domain specs.

### Trigger
- `/speckit.plan`
- `/speckit.plan spec.md`
- `/speckit.plan --all`

### Workflow

1. **Locate specs** - Find spec files in speckit/
2. **Assess complexity** - Single domain vs multi-domain
3. **Generate plans** - Create plan.md (and domain plans if complex)
4. **Validate** - Check plan completeness and consistency

### Output Structure

**Simple (single domain)**:
```
speckit/
├── spec.md
└── plan.md
```

**Complex (multi-domain)**:
```
speckit/
├── spec.md
├── plan.md              # Master plan with domain references
└── plans/
    ├── domain-a-plan.md
    ├── domain-b-plan.md
    └── domain-c-plan.md
```

### Plan Content

Plans contain:
- Requirements mapping (which spec sections covered)
- Architecture decisions
- Implementation approach (phases, NOT tasks)
- Verification strategy
- Notes for task generation

Plans do NOT contain:
- Individual tasks (that's /speckit.tasks)
- Implementation code
- Detailed how-to instructions

### Complexity Detection

| Indicator | Simple | Complex |
|-----------|--------|---------|
| Domains | Single | Multiple distinct |
| Page count | <10 pages | >10 pages |
| Stakeholder count | 1-2 | 3+ |

User can override detection.

See `references/command-workflows/plan-workflow.md` for detailed workflow.

---

## Command: tasks

Generate implementation tasks from plans + constitution + memory files.

### Trigger
- `/speckit.tasks`
- `/speckit.tasks plan.md`
- `/speckit.tasks --all`

### Workflow

1. **Load plan(s)** - Read plan files
2. **Load constitution** - Extract relevant sections
3. **Load memory files** - Get tech-specific guidelines
4. **Generate tasks** - Create *-tasks.md with phases
5. **Validate** - Check task completeness

### Output

```markdown
# [Domain] Tasks

## Phase 1: Foundation

### TASK-001: [Title]
**Status**: PENDING
**Priority**: P1
**Constitution Sections**: §4.1, §4.2
**Memory Files**: typescript.md, git-cicd.md
**Plan Reference**: PLAN-001
**Description**: ...
**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
```

### Task Statuses

| Status | Meaning |
|--------|---------|
| PENDING | Not started |
| IN_PROGRESS | Currently being worked |
| BLOCKED | Waiting on dependency |
| COMPLETED | Done and verified |
| SKIPPED | Intentionally not done |

See `references/command-workflows/tasks-workflow.md` for detailed workflow.

---

## Command: analyze

Deterministic, read-only audit of project artifacts for consistency and completeness.

### Trigger
- `/speckit.analyze`
- `/speckit.analyze --verbose`
- `/speckit.analyze --category gaps`

### Characteristics

- **Read-only**: Never modifies files
- **Deterministic**: Same inputs = same outputs
- **Stable IDs**: Finding IDs remain stable across runs
- **Quantified**: Metrics for coverage, completeness

### Analysis Categories

| Category | Description |
|----------|-------------|
| GAPS | Missing required elements |
| INCONSISTENCIES | Contradictions between artifacts |
| AMBIGUITIES | Unclear or undefined items |
| ORPHANS | Unreferenced elements |
| ASSUMPTIONS | Untracked/unvalidated assumptions |

### Severity Levels

| Level | Meaning |
|-------|---------|
| CRITICAL | Blocks progress, must fix |
| HIGH | Significant risk, should fix |
| MEDIUM | Notable issue, plan to fix |
| LOW | Minor concern |

### Output Format

```markdown
# Analysis Report

Generated: [timestamp]
Artifacts analyzed: [count]

## Summary
| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| GAPS     | 2        | 3    | 5      | 1   |
| ...      |          |      |        |     |

## Findings

### GAP-001 [CRITICAL]
**Location**: spec.md:45
**Description**: Missing error handling specification
**Recommendation**: Define error states for API failures
```

See `references/command-workflows/analyze-workflow.md` for detailed workflow.

---

## Command: clarify

Structured ambiguity resolution with immediate spec updates.

### Trigger
- `/speckit.clarify`
- `/speckit.clarify spec.md`

### Characteristics

- **One question at a time**: Focused, manageable
- **Multiple choice or short phrase**: Quick answers
- **5-question maximum per session**: Avoid fatigue
- **Immediate updates**: Specs updated after each answer
- **9-category taxonomy**: Structured classification

### Ambiguity Categories

| Category | Example Question |
|----------|-----------------|
| SCOPE | "Should X include Y functionality?" |
| BEHAVIOR | "What happens when user does X?" |
| DATA | "What format should X be stored in?" |
| ERROR | "How should X error be handled?" |
| SEQUENCE | "Does X happen before or after Y?" |
| CONSTRAINT | "What are the limits for X?" |
| INTERFACE | "How does X communicate with Y?" |
| AUTHORITY | "Who approves X?" |
| TEMPORAL | "How long should X take?" |

### Workflow

1. **Scan for ambiguity** - Find [TBD], [NEEDS CLARIFICATION], vague language
2. **Prioritize** - Rank by impact on implementation
3. **Present question** - One at a time with options
4. **Update spec** - Apply answer immediately
5. **Log session** - Record Q&A for traceability

### Question Format

```
CLARIFY-001 [BEHAVIOR]

The spec mentions "user authentication" but doesn't specify the method.

Which authentication method should be used?
1. OAuth 2.0 with Google/GitHub (Recommended)
2. Email/password with JWT
3. Magic link (passwordless)
4. Other (please specify)

Your choice:
```

See `references/command-workflows/clarify-workflow.md` for detailed workflow.

---

## Command: implement

Execute tasks from *-tasks.md with batch+gates execution model.

### Trigger
- `/speckit.implement TASK-001`
- `/speckit.implement TASK-001..TASK-005`
- `/speckit.implement "Phase 1"`
- `/speckit.implement @foundation`

### Task Selection

| Selector | Meaning |
|----------|---------|
| `TASK-001` | Single task |
| `TASK-001..TASK-005` | Range of tasks |
| `"Phase 1"` | All tasks in phase |
| `@foundation` | All tasks with @foundation group |

### Execution Model: Batch + Gates

```
Execute Phase 1 tasks
    ↓
GATE: "Phase 1 complete. Review outputs?"
    ↓
[User confirms]
    ↓
Execute Phase 2 tasks
    ↓
GATE: "Phase 2 complete. Review outputs?"
    ...
    ↓
MANDATORY: Post-Implementation Hooks
```

### Workflow

For each task:
1. **Load context** - Read referenced constitution sections + memory files
2. **Present context** - Show agent the relevant guidelines
3. **Execute** - Perform the task
4. **Update status** - PENDING → IN_PROGRESS → COMPLETED
5. **Verify** - Check acceptance criteria

### Gate Behavior

At phase/group boundaries:
```
Phase [N] complete.

Tasks completed: [count]
Tasks failed: [count]

Options:
1. Continue to Phase [N+1]
2. Review completed work
3. Re-run failed tasks
4. Stop execution
```

### Context Loading

```markdown
## Execution Context for TASK-001

### Constitution Requirements (§4.1, §4.2)
[Extracted sections from constitution.md]

### Memory File Guidelines
From typescript.md:
[Relevant sections]

From git-cicd.md:
[Relevant sections]

### Task Details
[Full task content]
```

### MANDATORY: Pre-Implementation Hooks

**CRITICAL**: These hooks MUST execute BEFORE any task work begins:

| Pre-Hook | Action | Purpose |
|----------|--------|---------|
| **Pre-Hook 1** | Read project-status.md | Understand current state and context |
| **Pre-Hook 2** | Validate argument | Show status if missing/invalid, stop until valid |
| **Pre-Hook 3** | Verify tasks actionable | Filter completed, check dependencies |
| **Pre-Hook 4** | Present execution plan | Get user confirmation before proceeding |
| **Pre-Hook 5** | Create git checkpoint | Tag current state for potential revert |

**If no argument or invalid argument**: Show current status and available selectors, then **STOP** until user provides valid selection.

### MANDATORY: Post-Implementation Hooks

**CRITICAL**: These hooks MUST execute after ANY `/speckit.implement` run:

| Post-Hook | Action | Updates |
|-----------|--------|---------|
| **Post-Hook 1** | Update tasks.md | Status → COMPLETED, verify each criterion with evidence |
| **Post-Hook 2** | Update project-status.md | Progress metrics, phase status, activity log |
| **Post-Hook 3** | Output summary to user | Completed tasks, criteria results, next steps |

The command is **NOT COMPLETE** until all hooks execute. See `references/command-workflows/implement-workflow.md` for detailed templates and verification methods.

---

## Command: revert

Revert to a previous git checkpoint with intelligent failure analysis and artifact recommendations.

### Trigger
- `/speckit.revert` - Most recent checkpoint
- `/speckit.revert [checkpoint-tag]` - Specific checkpoint
- `/speckit.revert --list` - List available checkpoints

### Workflow

1. **List checkpoints** - Show available speckit-checkpoint-* tags
2. **Preview revert** - Show files and tasks that will be affected
3. **Execute revert** - `git reset --hard [checkpoint]`
4. **Analyze failure** - Determine what went wrong
5. **Recommend fixes** - Suggest spec/plan/task updates

### Failure Analysis Categories

| Category | Indicators | Recommendation |
|----------|------------|----------------|
| SPEC_GAP | Requirements unclear | Run `/speckit.clarify` |
| APPROACH_WRONG | Architecture mismatch | Run `/speckit.plan --revise` |
| DEPENDENCY_ISSUE | External problems | Update dependencies, retry |
| TEST_MISMATCH | Tests don't match reality | Update test fixtures |
| SCOPE_CREEP | Too much at once | Decompose tasks |
| KNOWLEDGE_GAP | Unfamiliar technology | Research, then retry |

### Output

After revert, provides:
- Summary of what was reverted
- Root cause analysis
- Specific recommendations for next steps
- Updated project-status.md with revert logged
- Updated tasks.md with failure notes

See `commands/speckit.revert.md` for detailed workflow.

---

## Memory File System

Memory files provide persistent guidelines that inform all commands.

### Universal Files (Always Loaded)

| File | Purpose |
|------|---------|
| constitution.md | Core principles, mandatory constraints |
| documentation.md | Documentation standards |
| git-cicd.md | Git workflow, CI/CD practices |
| security.md | Security requirements |
| testing.md | Testing strategies |

### Tech-Specific Files (Loaded by Detection)

| File | Triggers |
|------|----------|
| typescript.md | TypeScript, JavaScript, Node.js |
| react-nextjs.md | React, Next.js |
| tailwind-shadcn.md | Tailwind CSS, shadcn/ui |
| python.md | Python, Django, Flask, FastAPI |
| rust.md | Rust |

### Constitution Section References

Tasks reference constitution sections by ID:
- `§1.0` - Chapter reference
- `§1.1` - Section reference
- `§1.1.a` - Subsection reference

Example task:
```markdown
**Constitution Sections**: §4.1 (Error Handling), §4.2 (Logging)
```

---

## Idempotency

All commands are designed to be safe when run repeatedly.

### Init Idempotency

- Skips existing directories
- Updates changed memory files only
- Preserves project customizations

### Plan Idempotency

- Detects existing plans
- Offers update or regenerate
- Preserves manual edits with warning

### Tasks Idempotency

- Preserves task statuses
- Adds new tasks for new plan items
- Never removes manually added tasks

### Analyze Idempotency

- Read-only, always safe
- Stable finding IDs across runs

### Clarify Idempotency

- Tracks answered questions
- Skips already-clarified items
- Session history preserved

### Implement Idempotency

- Skips COMPLETED tasks
- Resumes from last position
- Re-runnable for failed tasks

---

## Catching Up

When running on an existing project:

1. **Init detects state** - Finds what exists, what's missing
2. **Commands offer catch-up** - "Missing setup. Run init first?"
3. **Incremental updates** - Only process what's new
4. **Never destructive** - No deletions without explicit request

---

## Related Skills

These skills auto-activate based on context to provide supplementary guidance:

| Skill | Auto-Triggers When | Purpose |
|-------|-------------------|---------|
| `requirement-patterns` | Writing specs, requirements, user stories | Patterns for clear, testable requirements |
| `adr-authoring` | Creating ADRs, documenting decisions | MADR templates and best practices |

### When to Use

- **Before `/speckit.plan`**: Use `requirement-patterns` to write better specifications
- **During `/speckit.plan`**: Use `adr-authoring` for architecture decisions
- **With `/speckit.analyze`**: Skills provide context for interpreting findings
