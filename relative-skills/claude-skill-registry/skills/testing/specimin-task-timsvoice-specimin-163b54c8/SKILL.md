---
name: "specimin-task"
description: "Generate atomic implementation tasks from high-level plans, providing coding agents with clear, actionable work items. Only invoke when user explicitly requests to create tasks, break down tasks, generate implementation tasks, or create a task breakdown."
allowed-tools:
  - run_terminal_cmd
  - write
  - read_file
---

# Interactive Implementation Task Generator

Decompose technical plans into atomic, executable tasks following Test-Driven Development.

# Stage 1: Load Context

**Actions**:
1. Run `git rev-parse --abbrev-ref HEAD` to get current branch
2. Verify `.specimin/plans/{branch}/` exists. If not: `Error: Specimin not initialized. Run /init first.`
3. Read `.specimin/plans/{branch}/plan.md` (high-level plan)
4. Read `.specimin/plans/{branch}/spec.md` (feature specification)

**Context Extraction Goals**:
- Component/module names and boundaries
- Data structures and models
- Integration points with existing code
- Technical decisions (libraries, patterns, architectures)
- Key function responsibilities

**Error Handling**: If plan.md missing: `Error: No plan.md found for branch '{branch}'. Run /feature.plan first.`

# Stage 2: Analyze Plan Structure

Identify blocking ambiguities that prevent concrete task generation:
- **Dependencies**: Unclear integration points?
- **Technical choices**: Multiple valid approaches without clear direction?
- **Error handling**: Unaddressed edge cases or failure modes?
- **Data flow**: Unclear inputs/outputs between components?

**Identify 0-5 critical ambiguities only**. Do NOT ask about:
- Coding style, naming conventions, or trivial details
- Implementation details you can reasonably infer
- Non-blocking uncertainties

**Vague Plan Detection**: If plan lacks component structure, data flow, or function-level detail:
```
Warning: Plan too vague to generate atomic tasks.
Missing: Component breakdown, data structures, integration points, function responsibilities.
Add detail to plan.md, then rerun /cmd.implement.
```

**Checkpoint**: Verify you understand all technical decisions and component boundaries before proceeding.

# Stage 3: Clarify Ambiguities (If Needed)

If ambiguities found, ask focused questions (2 concrete options + "Custom"). Maximum 0-5 questions (prefer fewer). Focus on plan-level decisions, not code details. Wait for user response.

If no ambiguities, skip to Stage 4.

# Stage 4: Generate Atomic Tasks

Decompose plan into **function-level atomic tasks** following TDD.

## Atomicity Definition

**Atomic task = one file or one clear unit of work**, aligned with code structures:
- **Sequence**: One file/module (schema, controller, service, migration)
- **Branch**: Decision logic (validation, error handling, conditional flows)
- **Loop**: Iteration logic (batch processing, collection operations)

**Examples**:
- ✅ Good: "Create User schema in lib/app/accounts/user.ex"
- ❌ Too broad: "Implement authentication" → Split into specific files
- ❌ Too granular: "Add variable for user ID" → Implementation detail

## Task Format

```markdown
- [ ] T{XXX} [P?] {Verb + what + exact file path} (R{XX})
```

**Elements**:
- `- [ ]`: Checkbox for completion tracking
- `T001, T002...`: Sequential task ID across all phases
- `[P]`: Optional parallel marker (different files, no dependencies)
- `Verb`: Create, Write, Implement, Verify, Add, Update
- `(R01)`: Spec requirement mapping

## TDD Task Pattern (MANDATORY)

**Use for every feature/function**:
```markdown
- [ ] TXXX Write test for [capability] expecting [specific behavior] in test/[path]_test.exs (RXX)
- [ ] TXXX Run test and confirm RED (fails with expected error message)
- [ ] TXXX Implement [function] with minimal code to pass in lib/[path].ex (RXX)
- [ ] TXXX Run test and confirm GREEN (passes)
```

**Rules**:
1. Test task always precedes implementation task
2. Explicit verification tasks for RED and GREEN phases
3. No exceptions - this is a constitution mandate

## Complete TDD Examples

**Example 1: Simple CRUD Feature (User Creation)**
```markdown
## Phase 1: Foundation
- [ ] T001 Create migration for users table in priv/repo/migrations/20250106_create_users.exs (R01)
- [ ] T002 [P] Create User schema in lib/app/accounts/user.ex (R01)
- [ ] T003 Write test for user creation expecting {:ok, %User{}} in test/app/accounts_test.exs (R02)
- [ ] T004 Run test and confirm RED (Accounts.create_user/1 undefined)
- [ ] T005 Implement create_user/1 in lib/app/accounts.ex (R02)
- [ ] T006 Run test and confirm GREEN

## Phase 2: Validation
- [ ] T007 Write test for email validation expecting {:error, changeset} in test/app/accounts_test.exs (R03)
- [ ] T008 Run test and confirm RED (validation not enforced)
- [ ] T009 Add email validation to User changeset in lib/app/accounts/user.ex (R03)
- [ ] T010 Run test and confirm GREEN
```

**Example 2: Complex Integration (Payment Processing)**
```markdown
## Phase 1: External Service Setup
- [ ] T001 [P] Create Stripe client module in lib/app/payments/stripe_client.ex (R01)
- [ ] T002 [P] Add Stripe configuration to config/config.exs (R01)
- [ ] T003 Write test for charge creation expecting {:ok, %Charge{}} in test/app/payments_test.exs (R02)
- [ ] T004 Run test and confirm RED (Payments.create_charge/2 undefined)
- [ ] T005 Implement create_charge/2 with Stripe API call in lib/app/payments.ex (R02)
- [ ] T006 Run test and confirm GREEN

## Phase 2: Error Handling
- [ ] T007 Write test for network failure expecting {:error, :network_error} in test/app/payments_test.exs (R03)
- [ ] T008 Run test and confirm RED (error not caught)
- [ ] T009 Add retry logic with exponential backoff in lib/app/payments.ex (R03)
- [ ] T010 Run test and confirm GREEN
- [ ] T011 [P] Write test for invalid card expecting {:error, :invalid_card} (R04)
- [ ] T012 [P] Run test and confirm RED
- [ ] T013 [P] Add card validation to create_charge/2 (R04)
- [ ] T014 [P] Run test and confirm GREEN
```

## Path Conventions

**Phoenix/Elixir**:
- Contexts: `lib/{app}/{context}.ex`
- Schemas: `lib/{app}/{context}/{schema}.ex`
- LiveViews: `lib/{app}_web/live/{feature}_live.ex`
- Controllers: `lib/{app}_web/controllers/{name}_controller.ex`
- Tests: `test/{app}/{context}_test.exs`
- Migrations: `priv/repo/migrations/{timestamp}_{desc}.exs`

**For other projects**: Use conventions from plan.md.

## Phase Organization

Group tasks into phases from plan.md. Standard phases:
1. **Foundation**: Migrations, schemas, contexts, core tests
2. **Integration**: External services, APIs, third-party libraries
3. **Interface**: LiveViews, controllers, user-facing components
4. **Polish**: Validation, edge cases, error handling

**Dependency rules**: migrations → schemas → contexts → interfaces

**Parallel opportunities**: Mark `[P]` when tasks touch different files and have no dependencies.

**Checkpoint**: Before generating output, verify:
- [ ] Every task has exact file path
- [ ] Every feature has TDD cycle (test → RED → implement → GREEN)
- [ ] Tasks are atomic (one file or clear unit)
- [ ] All spec requirements mapped to tasks

# Stage 5: Generate Output

Create implementation.md with this structure:

```markdown
# Implementation Tasks: {Feature Name}

**Overview**: {1-2 sentence summary}
**Total Tasks**: {N} | **Phases**: {M} | **Estimated Completion**: {Time estimate}

---

## Phase 1: {Name}
**Dependencies**: None
**Parallel Opportunities**: {Count of [P] tasks}

- [ ] T001 {Task description with file path} (R01)
[All phase 1 tasks following TDD pattern]

---

## Phase 2: {Name}
**Dependencies**: Phase 1 complete
**Parallel Opportunities**: {Count}

- [ ] T007 {Task description with file path} (R04)
[All phase 2 tasks]

---

## Spec Requirement Mapping
- R01: Tasks T001, T002
- R02: Tasks T003-T006
[Complete mapping]

---

## Critical Dependencies
{Sequential dependencies that block other work}

---

## Notes
{Integration points, assumptions, clarifications}
```

Present draft: `I've generated {N} tasks in {M} phases. Reply "Approved" to save, or provide feedback.`

Wait for approval. Support iteration. Never merge test and implementation tasks during revision.

# Stage 6: Save Tasks

Once approved:
1. Run `git rev-parse --abbrev-ref HEAD`
2. Save to `.specimin/plans/{branch}/implementation.md`
3. Confirm: `Implementation tasks saved to .specimin/plans/{branch}/implementation.md`
4. **Proceed immediately to Stage 7**

Only save after explicit approval.

# Stage 7: Generate Phase Files and Manifest

Automatically generate phase-specific files and JSON manifest.

## Step 1: Create Directory
```bash
mkdir -p .specimin/plans/{branch}/tasks/
```

## Step 2: Parse Implementation.md

1. Read `.specimin/plans/{branch}/implementation.md`
2. Identify phase boundaries: `## Phase N:` headers
3. Extract for each phase:
   - Phase number and name
   - Dependencies and parallel opportunities
   - All task lines (`- [ ] TXXX ...`)
4. For each task capture:
   - Task ID (T001, T002...)
   - Full description
   - Phase number
   - Parallel marker ([P] present?)

## Step 3: Generate Phase Files

For each phase, create `phase_N.md`:

**File**: `.specimin/plans/{branch}/tasks/phase_1.md`
**Content**:
```markdown
# Phase N: {Phase Name}

**Dependencies**: {From implementation.md}
**Parallel Opportunities**: {Count}

{All tasks for this phase, preserving checkboxes, IDs, [P] markers}
```

Use Write tool for each file.

## Step 4: Generate JSON Manifest

**Schema** (4 fields per task):
```json
[
  {
    "id": "T001",
    "description": "Create User schema in lib/app/accounts/user.ex (R01)",
    "phase": 1,
    "status": "pending"
  }
]
```

**Escaping**: `"` → `\"`, `\` → `\\`, `\n` → `\\n`, `\t` → `\\t`

Save to `.specimin/plans/{branch}/tasks/manifest.json`

## Step 5: Edge Cases

- **Single phase**: Still create `phase_1.md` (not `phase.md`)
- **Empty phases**: Skip file creation, note in confirmation
- **No phases**: Display error: `Error: Could not detect phases. Expected "## Phase 1: {Name}"`

## Step 6: Confirm

Display:
```
✓ Generated {N} phase files and manifest with {M} tasks
  - Phase files: .specimin/plans/{branch}/tasks/phase_1.md through phase_{N}.md
  - Manifest: .specimin/plans/{branch}/tasks/manifest.json
```

If phases skipped: `(skipped empty phase 3)`

---

**Note**: This prompt optimized using research-backed principles: structured reasoning (ADIHQ +64%), programming construct framing (SCoT +13.79%), TDD verification (Reflexion 91%), token efficiency (-39%), and explicit checkpoints for quality.

