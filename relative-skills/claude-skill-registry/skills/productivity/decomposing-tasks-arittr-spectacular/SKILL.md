---
name: decomposing-tasks
description: Use when you have a complete feature spec and need to plan implementation - analyzes task dependencies, groups into sequential/parallel phases, validates task quality (no XL tasks, explicit files), and calculates parallelization time savings
---

# Task Decomposition

Analyze a feature specification and decompose it into an execution-ready plan with automatic phase grouping based on file dependencies.

**When to use:** After completing a feature spec, before implementation.

**Announce:** "I'm using the Task Decomposition skill to create an execution plan."

## Overview

This skill transforms a feature specification into a structured implementation plan by:

1. Extracting tasks from spec
2. Analyzing file dependencies between tasks
3. Grouping into phases (sequential or parallel)
4. Validating task quality
5. Outputting executable plan.md

## PR-Sized Chunks Philosophy

**Tasks should be PR-sized, thematically coherent units** - not mechanical file-by-file splits.

**Think like a senior engineer:**

- ❌ "Add schema" + "Install dependency" + "Add routes" (3 tiny tasks)
- ✅ "Database Foundation" (schema + migration + dependencies as one unit)

**Task chunking principles:**

1. **Thematic Coherence** - Task represents a complete "thing"

   - Complete subsystem (agent system with tools + config + types)
   - Complete layer (all service methods for a feature)
   - Complete feature slice (UI flow from form to preview to confirm)

2. **Natural PR Size** - Reviewable in one sitting (4-7h)

   - M (3-5h): Sweet spot for most tasks
   - L (5-7h): Complex but coherent units (full UI layer, complete API surface)
   - S (1-2h): Rare - only for truly standalone work

3. **Logical Boundaries** - Clear separation points

   - Layer boundaries (Models, Services, Actions, UI)
   - Subsystem boundaries (Agent, Import Service, API)
   - Feature boundaries (Auth, Import, Dashboard)

4. **Stackable** - Dependencies flow cleanly
   - Database → Logic → API → UI
   - Foundation → Core → Integration

**Good chunking examples:**

```
✅ GOOD: PR-sized, thematic chunks
- Task 1: Database Foundation (M - 4h)
  - Schema changes + migration + dependency install
  - One coherent "foundation" PR

- Task 2: Agent System (L - 6h)
  - Agent config + tools + schemas + types
  - Complete agent subsystem as a unit

- Task 3: Import Service Layer (M - 4h)
  - All service methods + business logic
  - Clean layer boundary

- Task 4: API Surface (L - 6h)
  - Server actions + SSE route
  - Complete API interface

- Task 5: Import UI (L - 7h)
  - All components + page + integration
  - Complete user-facing feature

Total: 5 tasks, 27h
Each task is a reviewable PR that adds value
```

```
❌ BAD: Too granular, mechanical splits
- Task 1: Add schema fields (S - 2h)
- Task 2: Create migration (S - 1h)
- Task 3: Install dependency (S - 1h)
- Task 4: Create agent config (M - 3h)
- Task 5: Create fetch tool (S - 1h)
- Task 6: Create schemas (S - 2h)
- Task 7: Create service (M - 4h)
- Task 8: Create actions (M - 3h)
- Task 9: Create SSE route (M - 3h)
- Task 10: Create form component (S - 2h)
- Task 11: Create progress component (S - 2h)
- Task 12: Create preview component (M - 2h)
- Task 13: Add routes (S - 1h)
- Task 14: Integrate components (S - 1h)

Total: 14 tasks, 28h
Too many tiny PRs, no coherent units
```

**Bundling heuristics:**

If you're creating S tasks, ask:

- Can this bundle with a related M task?
- Does this complete a subsystem or layer?
- Would a senior engineer create a separate PR for this?

**Common bundling patterns:**

- Schema + migration + dependencies → "Database Foundation"
- Agent + tools + schemas → "Agent System"
- Service + helper functions → "Service Layer"
- Actions + API routes → "API Layer"
- All UI components for a flow → "UI Layer"

## The Process

### Step 1: Read Spec and Extract/Design Tasks

Read the spec file and extract tasks. The spec may provide tasks in two ways:

**Option A: Spec has "Implementation Plan" section** (structured task breakdown)
- Extract tasks directly from this section
- Each task should have: ID, description, files, complexity, acceptance criteria

**Option B: Spec has no "Implementation Plan"** (lean spec - requirements only)
- Analyze the requirements and design task breakdown yourself
- Look at: Functional Requirements, Architecture section, Files to Create/Modify
- Design PR-sized chunks following the chunking philosophy above
- Create tasks that implement all requirements

For each task (extracted or designed), capture:

- **Task ID** (from heading)
- **Description** (what to implement)
- **Files** (explicit paths from spec)
- **Complexity** (S/M/L/XL - estimated hours)
- **Acceptance Criteria** (checklist items)
- **Implementation Steps** (detailed steps)

**Example extraction:**

```markdown
Spec has:

### Task 1: Database Schema

**Complexity**: M (2-4h)
**Files**:

- prisma/schema.prisma
- prisma/migrations/

**Description**: Add VerificationToken model for Auth.js...

**Acceptance**:

- [ ] Model matches Auth.js spec
- [ ] Migration runs cleanly

Extract to:
{
id: "task-1-database-schema",
description: "Add VerificationToken model",
files: ["prisma/schema.prisma", "prisma/migrations/"],
complexity: "M",
estimated_hours: 3,
acceptance_criteria: [...],
steps: [...]
}
```

### Step 2: Validate Task Quality & Chunking

For each task, check for quality issues:

**CRITICAL (must fix):**

- ❌ XL complexity (>8h) → Must split into M/L tasks
- ❌ No files specified → Must add explicit file paths
- ❌ No acceptance criteria → Must add 3-5 testable criteria
- ❌ Wildcard patterns (`src/**/*.ts`) → Must use explicit paths
- ❌ Too many S tasks (>30% of total) → Bundle into thematic M/L tasks

**HIGH (strongly recommend):**

- ⚠️ Standalone S task that could bundle with related work
- ⚠️ L complexity (5-8h) → Verify it's a coherent unit, not arbitrary split
- ⚠️ >10 files → Likely too large, consider splitting by subsystem
- ⚠️ <50 char description → Add more detail about what subsystem/layer this completes
- ⚠️ <3 acceptance criteria → Add more specific criteria

**Chunking validation:**

- If task is S (1-2h), verify it's truly standalone:

  - Can't be bundled with schema/migration/dependencies?
  - Can't be bundled with related service/action/component?
  - Would a senior engineer create a separate PR for this?

- If >50% of tasks are S, that's a red flag:
  - Likely too granular
  - Missing thematic coherence
  - Bundle related S tasks into M tasks

**If CRITICAL issues found:**

- STOP and report issues to user
- User must update spec or adjust chunking
- Re-run skill after fixes

**If only HIGH issues:**

- Report warnings
- Offer to continue or fix

### Step 3: Analyze File Dependencies

Build dependency graph by analyzing file overlaps:

**Algorithm:**

```
For each task T1:
  For each task T2 (where T2 appears after T1):
    shared_files = intersection(T1.files, T2.files)

    If shared_files is not empty:
      T2.dependencies.add(T1.id)
      T2.dependency_reason = "Shares files: {shared_files}"
```

**Example:**

```
Task 1: ["prisma/schema.prisma"]
Task 2: ["src/lib/models/auth.ts"]
Task 3: ["prisma/schema.prisma", "src/types/auth.ts"]

Analysis:
- Task 2: No dependencies (no shared files with Task 1)
- Task 3: Depends on Task 1 (shares prisma/schema.prisma)
```

**Architectural dependencies:**
Also add dependencies based on layer order:

- Models → Services → Actions → UI
- Database → Types → Logic → API → Components

### Step 4: Group into Phases

Group tasks into phases using dependency graph:

**Phase grouping algorithm:**

```
1. Start with tasks that have no dependencies (roots)
2. Group all independent roots into Phase 1
3. Remove roots from graph
4. Repeat until all tasks grouped

For each phase:
  - If all tasks independent: strategy = "parallel"
  - If any dependencies exist: strategy = "sequential"
```

**Example:**

```
Tasks:
- Task 1: [] (no deps)
- Task 2: [] (no deps)
- Task 3: [task-1, task-2]
- Task 4: [task-3]

Grouping:
Phase 1: [Task 1, Task 2] - parallel (independent)
Phase 2: [Task 3] - sequential (waits for Phase 1)
Phase 3: [Task 4] - sequential (waits for Phase 2)
```

### Step 5: Calculate Execution Estimates

For each phase, calculate:

- **Sequential time**: Sum of all task hours
- **Parallel time**: Max of all task hours (if parallel strategy)
- **Time savings**: Sequential - Parallel

**Example:**

```
Phase 2 (parallel):
- Task A: 3h
- Task B: 2h
- Task C: 4h

Sequential: 3 + 2 + 4 = 9h
Parallel: max(3, 2, 4) = 4h
Savings: 9 - 4 = 5h (56% faster)
```

### Step 6: Generate plan.md

Write plan to `{spec-directory}/plan.md`:

**Template:**

````markdown
# Feature: {Feature Name} - Implementation Plan

> **Generated by:** Task Decomposition skill
> **From spec:** {spec-path}
> **Created:** {date}

## Execution Summary

- **Total Tasks**: {count}
- **Total Phases**: {count}
- **Sequential Time**: {hours}h
- **Parallel Time**: {hours}h
- **Time Savings**: {hours}h ({percent}%)

**Parallel Opportunities:**

- Phase {id}: {task-count} tasks ({hours}h saved)

---

## Phase {N}: {Phase Name}

**Strategy**: {sequential|parallel}
**Reason**: {why this strategy}

### Task {ID}: {Name}

**Files**:

- {file-path-1}
- {file-path-2}

**Complexity**: {S|M|L} ({hours}h)

**Dependencies**: {[task-ids] or "None"}

**Description**:
{What to implement and why}

**Implementation Steps**:

1. {step-1}
2. {step-2}
3. {step-3}

**Acceptance Criteria**:

- [ ] {criterion-1}
- [ ] {criterion-2}
- [ ] {criterion-3}

**Mandatory Patterns**:

> **Constitution**: All code must follow @docs/constitutions/current/

See architecture.md for layer boundaries and patterns.md for required patterns.

**TDD**: Follow `test-driven-development` skill (write test first, watch fail, minimal code, watch pass)

**Quality Gates**:

```bash
pnpm biome check --write .
pnpm test {test-files}
```
````

---

{Repeat for all tasks in all phases}

````

### Step 7: Report to User

After generating plan:

```markdown
✅ Task Decomposition Complete

**Plan Location**: specs/{run-id}-{feature-slug}/plan.md

## Breakdown
- Phases: {count}
- Tasks: {count}
- Complexity: {XL}: {n}, {L}: {n}, {M}: {n}, {S}: {n}

## Execution Strategy
- Sequential Phases: {count} ({tasks} tasks)
- Parallel Phases: {count} ({tasks} tasks)

## Time Estimates
- Sequential Execution: {hours}h
- With Parallelization: {hours}h
- **Time Savings: {hours}h ({percent}% faster)**

## Next Steps

Review plan:
```bash
cat specs/{run-id}-{feature-slug}/plan.md
````

Execute plan:

```bash
/spectacular:execute @specs/{run-id}-{feature-slug}/plan.md
```

```

## Quality Rules

**Task Sizing (PR-focused):**
- ⚠️ S (1-2h): Rare - only truly standalone work (e.g., config-only changes)
  - Most S tasks should bundle into M
  - Ask: "Would a senior engineer PR this alone?"
- ✅ M (3-5h): Sweet spot - most tasks should be this size
  - Complete subsystem, layer, or feature slice
  - Reviewable in one sitting
  - Thematically coherent unit
- ✅ L (5-7h): Complex coherent units (use for major subsystems)
  - Full UI layer with all components
  - Complete API surface (actions + routes)
  - Major feature integration
- ❌ XL (>8h): NEVER - always split into M/L tasks

**Chunking Standards:**
- ❌ <30% S tasks is a red flag (too granular)
- ✅ Most tasks should be M (60-80%)
- ✅ Some L tasks for major units (10-30%)
- ✅ Rare S tasks for truly standalone work (<10%)

**File Specificity:**
- ✅ `src/lib/models/auth.ts`
- ✅ `src/components/auth/LoginForm.tsx`
- ❌ `src/**/*.ts` (too vague)
- ❌ `src/lib/models/` (specify exact files)

**Acceptance Criteria:**
- ✅ 3-5 specific, testable criteria
- ✅ Quantifiable (tests pass, build succeeds, API returns 200)
- ❌ Vague ("works well", "is good")
- ❌ Too many (>7 - task is too large)

**Dependencies:**
- ✅ Minimal (only true blockers)
- ✅ Explicit reasons (shares file X)
- ❌ Circular dependencies
- ❌ Over-constrained (everything depends on everything)

## Error Handling

### Spec Has Insufficient Information

If spec has neither "Implementation Plan" nor enough detail to design tasks:

```

❌ Cannot decompose - spec lacks implementation details

The spec must have either:
- An "Implementation Plan" section with tasks, OR
- Sufficient requirements and architecture details to design tasks

Current spec has:
- Functional Requirements: [YES/NO]
- Architecture section: [YES/NO]
- Files to create/modify: [YES/NO]

Add more implementation details to the spec, then re-run:
/spectacular:plan @specs/{run-id}-{feature-slug}/spec.md

```

### Critical Quality Issues

If tasks have critical issues:

```

❌ Task Quality Issues - Cannot Generate Plan

Critical Issues Found:

- Task 3: XL complexity (12h) - must split
- Task 5: No files specified
- Task 7: No acceptance criteria

Fix these issues in the spec, then re-run:
/spectacular:plan @specs/{run-id}-{feature-slug}/spec.md

```

### Circular Dependencies

If dependency graph has cycles:

```

❌ Circular Dependencies Detected

Task A depends on Task B
Task B depends on Task C
Task C depends on Task A

This is impossible to execute. Review task organization.

````

## Integration with Other Skills

**Before:** Use `brainstorming` and `spec-feature` to create complete spec

**After:** Use `/execute` command to run plan with `subagent-driven-development`

**Pairs with:**
- `subagent-driven-development` - Executes individual tasks
- `finishing-a-development-branch` - Completes implementation

## Project-Specific Configuration

For projects with a constitution, reference it in every task:

> **Constitution**: All tasks MUST follow @docs/constitutions/current/

Every task must include:
- Reference to constitution for architecture (layer boundaries, dependencies)
- Reference to constitution for patterns (validation, state management, etc.)
- Quality gates (linting, testing, building)

**Quality gates:**
```bash
pnpm biome check --write .
pnpm test
````
