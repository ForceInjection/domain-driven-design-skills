---
name: Task Generation
description: Generate user-story-organized task lists from implementation plans. Use when plan exists and user is ready for implementation, mentions "create tasks", "break down work", or asks "what tasks are needed" to implement the feature.
degree-of-freedom: low
allowed-tools: Read, Write
---

@.claude/shared-imports/constitution.md
@.claude/templates/tasks.md

# Task Generation

**Purpose**: Transform implementation plans into executable, user-story-organized task breakdowns following Article VII (User-Story-Centric Organization).

**Constitutional Authority**: Article VII (User-Story-Centric Organization), Article III (Test-First Imperative), Article VIII (Parallelization Markers)

---

## Phase 1: Load Context

### Step 1.1: Validate Prerequisites

PreToolUse hook blocks tasks.md without plan.md, but verify:

```bash
FEATURE=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "${SPECIFY_FEATURE:-}")

if [[ ! -f "specs/$FEATURE/spec.md" ]]; then
    echo "ERROR: Missing specification (Article IV violation)"
    exit 1
fi

if [[ ! -f "specs/$FEATURE/plan.md" ]]; then
    echo "ERROR: Missing implementation plan (Article IV violation)"
    exit 1
fi
```

### Step 1.2: Load Specification (User Stories)

```bash
Read specs/$FEATURE/spec.md
```

**Extract**:
- User stories with priorities (P1, P2, P3...)
- Independent test criteria per story
- Functional requirements

### Step 1.3: Load Implementation Plan (Tech Details)

```bash
Read specs/$FEATURE/plan.md
```

**Extract**:
- Tech stack and frameworks
- Component breakdown
- Acceptance criteria (≥2 per story)
- File structure
- Integration points

### Step 1.4: Load Supporting Documents (If Available)

```bash
Read specs/$FEATURE/data-model.md  # Entity designs
Read specs/$FEATURE/contracts/*.md  # API specifications
Read specs/$FEATURE/quickstart.md  # Test scenarios
```

---

## Phase 2: Organize Tasks by User Story (Article VII)

**CRITICAL**: Tasks MUST be grouped by user story, NOT by technical layer.

### Phase Structure

**Required Phases**:
1. **Phase 1: Setup** - Project initialization, dependencies
2. **Phase 2: Foundational** - Blocking prerequisites for ALL stories
3. **Phase 3+: User Story Phases** - One phase per story (P1, P2, P3...)
4. **Final Phase: Polish & Cross-Cutting** - Documentation, cleanup

**Within Each Story Phase**:
```
Phase N: User Story PX - [Title]

Goal: [What user can do after this phase]
Independent Test: [How to validate this story works standalone]

Tasks:
1. Tests (if TDD required)
2. Models needed for this story
3. Services needed for this story
4. Endpoints/UI needed for this story
5. Integration for this story
6. Verification of this story
```

---

## Phase 3: Generate Tasks

### Step 3.1: Phase 1 - Setup Tasks

**Purpose**: Initialize project structure, install dependencies

**Task Format**:
```
- [ ] T001 Create project structure per implementation plan
- [ ] T002 [P] Install dependencies: <list from plan.md>
- [ ] T003 [P] Configure environment variables
- [ ] T004 [P] Set up development database
```

**Parallel Marker** `[P]`: Tasks that can run simultaneously (different files, no dependencies)

### Step 3.2: Phase 2 - Foundational Tasks

**Purpose**: Blocking prerequisites that ALL user stories depend on

**Examples**:
```
- [ ] T005 Create base database schema (users table)
- [ ] T006 Set up authentication middleware
- [ ] T007 Configure error handling and logging
```

**NOT user-story-specific**: These enable multiple stories.

### Step 3.3: Phase 3+ - User Story Tasks

**Article VII Mandate**: One phase per user story, organized by priority.

#### Step 3.3.1: Identify Story Components

For each user story from spec.md:

**Map to Components** (from plan.md):
- Which models does this story need?
- Which services does this story need?
- Which endpoints/UI does this story need?
- Which tests validate this story?

**Example**: User Story P1 - Email/Password Registration

Components needed:
- Model: User (enhance existing)
- Service: AuthService (new)
- API: POST /register (new)
- UI: RegisterForm (new)
- Tests: Registration flow tests

#### Step 3.3.2: Generate Tasks with Article III Compliance

**Test-First Mandate** (Article III): Tests MUST come before implementation.

**Task Sequence**:
```
## Phase 3: User Story P1 - Email/Password Registration

**Story Goal**: Users can create accounts with email and password

**Independent Test**: Can register new user, receive session token, login with credentials

**Dependencies**: Phase 2 (foundational) complete

### Tests (Article III: Test-First)
- [ ] T008 [P] [US1] Write test for AC-P1-001 (valid registration) in tests/auth/register.test.ts
- [ ] T009 [P] [US1] Write test for AC-P1-002 (weak password rejection) in tests/auth/register.test.ts

### Implementation
- [ ] T010 [US1] Enhance User model with password_hash field in models/user.ts
- [ ] T011 [US1] Create AuthService.register() method in services/auth-service.ts
- [ ] T012 [US1] Implement POST /api/auth/register endpoint in api/auth/register.ts
- [ ] T013 [US1] Create RegisterForm component in components/auth/RegisterForm.tsx
- [ ] T014 [US1] Integrate RegisterForm with /register route in pages/register.tsx

### Verification
- [ ] T015 [US1] Run AC tests (must pass 100%)
- [ ] T016 [US1] Test registration flow end-to-end with quickstart scenario
- [ ] T017 [US1] Verify story works independently (no other stories required)
```

**Task ID Format**: T### (sequential numbering)
**Story Label Format**: [US#] where # is story number (US1, US2, US3...)
**Parallel Marker**: [P] for parallelizable tasks

#### Step 3.3.3: Repeat for All User Stories

Generate phases for:
- Phase 4: User Story P2
- Phase 5: User Story P3
- ...

Each phase:
- Independent test criteria
- Tests before implementation
- Story-specific tasks only
- Verification step

### Step 3.4: Final Phase - Polish

**Purpose**: Cross-cutting concerns, documentation, cleanup

**Examples**:
```
## Phase N: Polish & Cross-Cutting Concerns

- [ ] T### [P] Update API documentation
- [ ] T### [P] Run full test suite
- [ ] T### [P] Perform security audit
- [ ] T### Run linter and fix issues
- [ ] T### Build and verify production bundle
- [ ] T### Update changelog
```

---

## Phase 4: Mark Parallelization (Article VIII)

### Criteria for [P] Marker

Task is parallelizable if:
1. **Different files**: No file conflicts with other parallel tasks
2. **No dependencies**: Doesn't depend on incomplete tasks
3. **Independent**: Can run without coordination

**Example**:
```
✓ [P] - [ ] T008 [P] [US1] Write test in tests/auth/register.test.ts
✓ [P] - [ ] T009 [P] [US1] Write test in tests/auth/login.test.ts
          (Different files, no dependencies)

✗ NO [P] - [ ] T010 [US1] Enhance User model
✗ NO [P] - [ ] T011 [US1] Create AuthService using User model
          (T011 depends on T010, must be sequential)
```

---

## Phase 5: Validate Task Completeness

### Step 5.1: Check User Story Coverage

**For EACH user story**, verify:
- ✓ Has ≥2 tests (one per AC minimum)
- ✓ All components identified in plan.md have tasks
- ✓ Has verification task
- ✓ Has independent test criteria

### Step 5.2: Check Acceptance Criteria Coverage

**For EACH AC** (from plan.md), verify:
- ✓ Has corresponding test task
- ✓ Test task comes before implementation tasks
- ✓ AC is verifiable in verification task

**Example**:
```
AC-P1-001: User can register with valid credentials
→ T008: Write test for AC-P1-001
→ T010-T014: Implementation
→ T015: Verify AC-P1-001 passes
```

### Step 5.3: Check Dependencies

**Verify**:
- Phase 1 (Setup) has no dependencies
- Phase 2 (Foundational) depends only on Phase 1
- Each User Story phase depends only on Foundational
- Final Phase depends on all User Story phases

**Create dependency graph**:
```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational)
    ↓
Phase 3 (US P1) ←┐
Phase 4 (US P2) ←┼→ Independent (can be done in any order)
Phase 5 (US P3) ←┘
    ↓
Phase 6 (Polish)
```

---

## Phase 5: Quality Gate Enforcement (Article V)

**Constitutional Mandate**: Template-Driven Quality requires automatic validation before implementation.

### Step 5.1: Invoke /audit Command Automatically

After tasks.md is successfully created, **automatically** trigger the quality gate.

**DO NOT ask user to run /audit manually** - this is automatic enforcement.

**Instruct Claude**:

"Now that tasks.md is complete, run the **quality gate validation** to verify cross-artifact consistency:

`/audit $FEATURE_ID`

This command will:
1. Validate Article IV compliance (spec → plan → tasks sequence)
2. Verify Article VII compliance (user-story-centric organization)
3. Check Article III compliance (≥2 ACs per user story)
4. Detect constitution violations (CRITICAL priority)
5. Identify missing requirement coverage
6. Find ambiguities and underspecification

**If audit finds CRITICAL issues**:
- Implementation is BLOCKED until issues resolved
- Report violations to user
- Provide remediation guidance

**If audit passes all checks**:
- Report 'Ready for implementation'
- User can proceed with `/implement plan.md`

The audit report will be saved as: `YYYYMMDD-HHMM-audit-$FEATURE_ID.md`"

### Step 5.2: Handle Audit Results

**On CRITICAL failures**:
```
⚠ Quality Gate FAILED - Implementation BLOCKED

Critical Issues Found:
- [List of CRITICAL findings from audit]

Next Actions:
1. Fix CRITICAL issues in spec.md, plan.md, or tasks.md
2. Re-run /tasks to regenerate tasks.md
3. Audit will re-validate automatically

Implementation cannot proceed until audit passes.
```

**On successful audit**:
```
✓ Quality Gate PASSED - Ready for Implementation

All validation checks passed:
- Constitution compliance: ✓
- Requirements coverage: 100%
- User story organization: ✓
- Acceptance criteria: ≥2 per story ✓

Next Step: Run /implement plan.md to begin implementation
```

### Step 5.3: Record Audit Invocation

Log in tasks.md that audit was run:

```markdown
## Quality Gate

**Status**: Audit ran automatically on task generation
**Report**: YYYYMMDD-HHMM-audit-$FEATURE_ID.md
**Result**: [PASS/FAIL]
**Date**: [YYYY-MM-DD HH:MM]
```

---

## Phase 6: Generate tasks.md

### Step 6.1: Write Using Template

Use `@.claude/templates/tasks.md` structure:

```yaml
---
feature: <number>-<name>
created: <YYYY-MM-DD>
plan: specs/<number>-<name>/plan.md
status: Ready for Implementation
total_tasks: <count>
---
```

**Include**:
1. **Summary**: Total tasks, story breakdown
2. **Dependencies**: Graph showing story order
3. **Parallel Opportunities**: Count of [P] tasks per phase
4. **All Phases**: Setup → Foundational → User Stories → Polish
5. **Verification Checklist**: How to mark each task complete

**Save**: `specs/$FEATURE/tasks.md`

### Step 6.2: Report Completion

**Output**:
```
✓ Task breakdown created: specs/<number>-<name>/tasks.md

Task Summary:
- Total tasks: 45
- Phase 1 (Setup): 4 tasks
- Phase 2 (Foundational): 3 tasks
- Phase 3 (US P1): 10 tasks (2 tests, 5 impl, 3 verify)
- Phase 4 (US P2): 12 tasks (3 tests, 6 impl, 3 verify)
- Phase 5 (US P3): 8 tasks (2 tests, 4 impl, 2 verify)
- Phase 6 (Polish): 8 tasks

Parallel Opportunities:
- Setup: 3 of 4 tasks can run in parallel
- User Story P1: 2 test tasks can run in parallel
- User Story P2: 3 test tasks can run in parallel

Acceptance Criteria Coverage:
- Total ACs: 8
- Tests mapped: 8 (100% coverage)
- Each AC has ≥1 test task

Story Independence:
- ✓ Each story has independent test criteria
- ✓ Stories can be implemented in priority order (P1 → P2 → P3)
- ✓ Each story is demonstrable standalone

Constitutional Compliance:
- ✓ Article III: Tests before implementation (TDD)
- ✓ Article VII: Tasks organized by user story (not layer)
- ✓ Article VIII: Parallel tasks marked [P]

**Automatic Quality Gate**:
Running /audit command now for validation...

[Audit results will appear here]

If audit passes: Next Step: Run /implement plan.md
If audit fails: Fix CRITICAL issues first, then re-run /tasks
```

---

## Anti-Patterns to Avoid

**DO NOT**:
- Organize by layer ("All models", "All services", "All UI")
- Create tasks without [US#] story labels
- Skip test tasks (Article III violation)
- Mix multiple stories in one phase
- Create tasks that span stories (violates independence)
- Forget to mark parallelizable tasks with [P]
- Create < 2 tests per user story (Article III violation)

**DO**:
- Organize by user story (Phase per story)
- Label tasks with [US#] for traceability
- Tests before implementation (TDD)
- Independent test criteria per story
- Mark parallel tasks with [P]
- Map every AC to ≥1 test task
- Verify 100% AC coverage

---

## Example Task Breakdown

**Input**: Plan with 2 user stories (P1: Register, P2: Login)

**Output**: tasks.md with 6 phases

```markdown
## Phase 1: Setup
- [ ] T001 Create project structure
- [ ] T002 [P] Install dependencies
- [ ] T003 [P] Configure environment

## Phase 2: Foundational
- [ ] T004 Create users table schema
- [ ] T005 Set up Supabase client

## Phase 3: User Story P1 - Registration
Independent Test: Can register and login

### Tests
- [ ] T006 [P] [US1] Test AC-P1-001 (valid registration)
- [ ] T007 [P] [US1] Test AC-P1-002 (weak password rejection)

### Implementation
- [ ] T008 [US1] Enhance User model with password_hash
- [ ] T009 [US1] Create AuthService.register()
- [ ] T010 [US1] Implement POST /api/auth/register
- [ ] T011 [US1] Create RegisterForm component

### Verification
- [ ] T012 [US1] Run all US1 tests (must pass)
- [ ] T013 [US1] Test US1 independently

## Phase 4: User Story P2 - Login
Independent Test: Can login with registered credentials

### Tests
- [ ] T014 [P] [US2] Test AC-P2-001 (valid login)
- [ ] T015 [P] [US2] Test AC-P2-002 (invalid credentials)

### Implementation
- [ ] T016 [US2] Create AuthService.login()
- [ ] T017 [US2] Implement POST /api/auth/login
- [ ] T018 [US2] Create LoginForm component

### Verification
- [ ] T019 [US2] Run all US2 tests (must pass)
- [ ] T020 [US2] Test US2 independently

## Phase 5: Polish
- [ ] T021 [P] Update API docs
- [ ] T022 [P] Run full test suite
- [ ] T023 Build production bundle
```

**Result**: 23 tasks, organized by story, tests-first, parallelization marked.

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-19
