---
name: task-breakdown-phase
description: "Standard Operating Procedure for /tasks phase. Covers task sizing, acceptance criteria definition, and TDD-first task sequencing."
allowed-tools: Read, Write, Edit, Grep, Bash
---

# Task Breakdown Phase: Standard Operating Procedure

> **Training Guide**: Step-by-step procedures for executing the `/tasks` command with emphasis on right-sized tasks and clear acceptance criteria.

**Supporting references**:
- [reference.md](reference.md) - Task sizing guidelines, acceptance criteria templates, sequencing patterns
- [examples.md](examples.md) - Good tasks (0.5-1 day, clear AC) vs bad tasks (>2 days, vague AC)

---

## Phase Overview

**Purpose**: Transform implementation plan into concrete, test-driven tasks with clear acceptance criteria and proper sequencing.

**Inputs**:
- `specs/NNN-slug/plan.md` - Implementation plan
- `specs/NNN-slug/spec.md` - Feature specification
- Architecture and component definitions

**Outputs**:
- `specs/NNN-slug/tasks.md` - Detailed task breakdown (20-30 tasks)
- Updated `workflow-state.yaml`

**Expected duration**: 10-20 minutes

---

## Prerequisites

**Environment checks**:
- [ ] Planning phase completed (`plan.md` exists)
- [ ] Architecture components defined
- [ ] Reuse strategy documented
- [ ] Git working tree clean

**Knowledge requirements**:
- Task sizing guidelines (0.5-1 day per task)
- Acceptance criteria best practices
- TDD workflow (test-first development)
- Task sequencing (dependencies and parallel paths)

---

## Execution Steps

### Step 1: Analyze Plan and Architecture

**Actions**:
1. Read `plan.md` to extract:
   - Components to implement
   - Data model changes
   - API endpoints
   - UI components (if HAS_UI=true)
   - Testing requirements

2. Map dependencies:
   - Which components depend on others?
   - What must be implemented first?
   - What can be parallelized?

**Quality check**: Do you understand all components that need tasks?

---

### Step 2: Generate Foundation Tasks

**Actions**:
Create tasks for foundational work that other tasks depend on:

1. **Database tasks** (if needed):
   - Task: Create database migration for [tables]
   - Task: Add indexes for performance
   - Task: Create seed data for development/testing

2. **Model/Schema tasks**:
   - Task: Implement [ModelName] with base fields
   - Task: Add validation rules to [ModelName]
   - Task: Write unit tests for [ModelName]

3. **Configuration tasks** (if HAS_DEPLOYMENT_IMPACT):
   - Task: Add environment variables to .env.example
   - Task: Update deployment configuration
   - Task: Document new configuration in README

**Task template**:
```markdown
### Task N: Create Database Migration for Time Logs

**Complexity**: Low (2-4 hours)

**Description**: Create Alembic migration to add `time_logs` table with student_id, lesson_id, time_spent fields.

**Implementation steps**:
1. Generate migration file
2. Define table schema with foreign keys
3. Add indexes on (student_id, lesson_id)
4. Test migration up/down locally

**Acceptance criteria**:
- [ ] Migration runs successfully on clean database
- [ ] Foreign keys enforce referential integrity
- [ ] Rollback works without errors
- [ ] Migration documented in migrations/README.md

**Dependencies**: None
**Blocks**: Task 4 (StudentProgress model)
```

**Quality check**: Foundation tasks have no dependencies and are clearly testable.

---

### Step 3: Generate Business Logic Tasks (TDD-First)

**Actions**:
For each service/utility in the plan, create tasks using TDD workflow:

**TDD task structure** (3 tasks per component):
1. **Task N: Write tests for [Component]** ← RED phase
2. **Task N+1: Implement [Component]** ← GREEN phase
3. **Task N+2: Refactor [Component]** ← REFACTOR phase

**Example**:
```markdown
### Task 8: Write Unit Tests for StudentProgressService

**Complexity**: Medium (4-6 hours)

**Description**: Write comprehensive unit tests for StudentProgressService before implementation.

**Test cases to implement**:
1. calculateProgress() with valid student (expects completion rate)
2. calculateProgress() with no lessons (expects 0%)
3. calculateProgress() with student not found (expects error)
4. getRecentActivity() returns last 10 activities
5. getRecentActivity() with no activity (expects empty array)

**Acceptance criteria**:
- [ ] 5 test cases implemented (all failing initially)
- [ ] Tests cover happy path + edge cases
- [ ] Mocks used for Student/Lesson/TimeLog models
- [ ] Test coverage ≥90% for service interface

**Dependencies**: Task 4 (models created)
**Blocks**: Task 9 (implementation)

---

### Task 9: Implement StudentProgressService

**Complexity**: Medium (6-8 hours)

**Description**: Implement StudentProgressService to make tests pass.

**Implementation steps**:
1. Create service class with calculateProgress() method
2. Query time_logs with student_id filter
3. Calculate completion rate = completed / total lessons
4. Implement getRecentActivity() with limit 10
5. Run tests until all pass

**Acceptance criteria**:
- [ ] All 5 unit tests from Task 8 pass
- [ ] No code duplication (reuses existing utilities)
- [ ] Follows existing service patterns (see BaseService)
- [ ] Type hints on all methods

**Dependencies**: Task 8 (tests written)
**Blocks**: Task 10 (refactor)
```

**Quality check**: Every business logic component has test → implement → refactor tasks.

---

### Step 4: Generate API Endpoint Tasks (TDD-First)

**Actions**:
For each API endpoint in plan, create test-first tasks:

```markdown
### Task 15: Write Integration Tests for Progress API Endpoint

**Complexity**: Medium (4-6 hours)

**Description**: Write integration tests for GET /api/v1/students/{id}/progress before implementation.

**Test scenarios**:
1. Valid student ID returns 200 with progress data
2. Invalid student ID returns 404
3. Unauthorized user returns 403
4. Invalid period parameter returns 400
5. Response schema validation

**Acceptance criteria**:
- [ ] 5 integration tests implemented (all failing initially)
- [ ] Tests use real database (test fixtures)
- [ ] Authentication tested (valid token, invalid token, missing token)
- [ ] Response matches OpenAPI schema

**Dependencies**: Task 9 (StudentProgressService implemented)
**Blocks**: Task 16 (endpoint implementation)

---

### Task 16: Implement GET /api/v1/students/{id}/progress

**Complexity**: Medium (4-6 hours)

**Description**: Implement API endpoint to make integration tests pass.

**Implementation steps**:
1. Create route in routes/students.py
2. Add authentication decorator
3. Validate path/query parameters
4. Call StudentProgressService.calculateProgress()
5. Format response per schema
6. Handle errors (404, 403, 400)

**Acceptance criteria**:
- [ ] All 5 integration tests from Task 15 pass
- [ ] Response time <500ms (95th percentile with 500 lessons)
- [ ] Follows API versioning convention (/api/v1/)
- [ ] Error responses include error codes + messages

**Dependencies**: Task 15 (tests written), Task 9 (service ready)
```

**Quality check**: All endpoints have test → implement task pairs.

---

### Step 5: Generate UI Component Tasks (if HAS_UI=true, TDD-First)

**Actions**:
For each UI component, create test-first tasks:

```markdown
### Task 22: Write Component Tests for ProgressDashboard

**Complexity**: Medium (4-6 hours)

**Description**: Write React Testing Library tests for ProgressDashboard before implementation.

**Test scenarios**:
1. Renders loading state while fetching data
2. Renders progress chart with valid data
3. Renders error message on API failure
4. Date filter updates chart data
5. Accessibility: keyboard navigation works

**Acceptance criteria**:
- [ ] 5 component tests implemented (all failing initially)
- [ ] Tests use MSW to mock API responses
- [ ] Tests check ARIA labels for accessibility
- [ ] Tests verify chart renders (mocked with jest.mock)

**Dependencies**: Task 16 (API endpoint ready)
**Blocks**: Task 23 (component implementation)

---

### Task 23: Implement ProgressDashboard Component

**Complexity**: Medium (6-8 hours)

**Description**: Implement ProgressDashboard React component to make tests pass.

**Implementation steps**:
1. Create component file src/pages/ProgressDashboard.tsx
2. Add useApiData hook for data fetching
3. Render ProgressChart component (reuse from library)
4. Add date filter dropdown
5. Handle loading/error states
6. Add ARIA labels for accessibility

**Acceptance criteria**:
- [ ] All 5 component tests from Task 22 pass
- [ ] Lighthouse accessibility score ≥95
- [ ] Reuses ProgressChart from shared components
- [ ] Date filter persists in URL query params

**Dependencies**: Task 22 (tests written)
```

**Quality check**: All UI components have test → implement task pairs.

---

### Step 6: Generate Integration and E2E Test Tasks

**Actions**:
Create tasks for higher-level testing:

```markdown
### Task 27: Write E2E Test for Progress Dashboard Flow

**Complexity**: Medium (4-6 hours)

**Description**: Write Playwright E2E test for complete user journey.

**Test flow**:
1. User logs in as teacher
2. Navigates to student list
3. Clicks "View Progress" for student
4. Sees progress dashboard load
5. Filters by 7-day period
6. Verifies chart updates

**Acceptance criteria**:
- [ ] E2E test runs in headless mode
- [ ] Test passes on local dev server
- [ ] Screenshots captured on failure
- [ ] Test completes in <30 seconds

**Dependencies**: All implementation tasks (18-26)
```

**Quality check**: E2E tests cover top 3 user journeys from spec.

---

### Step 7: Sequence Tasks by Dependencies

**Actions**:
1. Create dependency graph:
   - List tasks with dependencies
   - Identify parallel paths
   - Mark critical path (longest dependency chain)

2. Assign task numbers based on sequence:
   - Foundation tasks: 1-5
   - Data layer: 6-10
   - Business logic: 11-15
   - API layer: 16-20
   - UI layer: 21-26 (if HAS_UI)
   - Integration/E2E: 27-30

**Example dependency graph**:
```
Task 1 (Migration) → Task 4 (Models) → Task 8 (Service Tests) → Task 9 (Service) → Task 15 (API Tests) → Task 16 (API)
                                                                                                               ↓
                                                                                          Task 22 (UI Tests) → Task 23 (UI) → Task 27 (E2E)
```

**Quality check**: No circular dependencies, clear parallel paths identified.

---

### Step 8: Validate Task Sizes

**Actions**:
For each task, verify size is 0.5-1 day (4-8 hours):

**Too large (>1 day)**: Split into subtasks
```markdown
❌ Task: Implement entire progress dashboard feature (3 days)

✅ Split into:
- Task 22: Write component tests (4-6 hours)
- Task 23: Implement dashboard layout (6-8 hours)
- Task 24: Add chart integration (4-6 hours)
- Task 25: Add filter controls (4-6 hours)
```

**Too small (<2 hours)**: Combine with related tasks
```markdown
❌ Task: Add ARIA label to button (30 minutes)

✅ Combine into:
- Task 23: Implement dashboard component (includes accessibility)
```

**Quality check**: 90% of tasks are 0.5-1 day, no tasks >1.5 days.

---

### Step 9: Define Clear Acceptance Criteria

**Actions**:
For each task, add 2-4 testable acceptance criteria:

**Good acceptance criteria**:
- [ ] Specific and measurable
- [ ] Can be verified by tests
- [ ] Include success metrics where applicable
- [ ] Cover happy path + edge cases

**Example**:
```markdown
**Acceptance criteria**:
- [ ] API returns 200 with valid student ID (tested)
- [ ] Response time <500ms for 500 lessons (measured)
- [ ] Returns 404 for invalid student ID (tested)
- [ ] Follows API schema from plan.md (validated)
```

**Bad acceptance criteria to avoid**:
```markdown
❌ [ ] Code works correctly
❌ [ ] API is implemented
❌ [ ] Tests pass
```

**Quality check**: Every task has 2-4 checkboxes, all are testable.

---

### Step 10: Add Implementation Notes

**Actions**:
For complex tasks, add implementation hints:

```markdown
**Implementation notes**:
- Reuse BaseService pattern (see api/app/services/base.py)
- Follow TDD: Write test first, implement minimal code, refactor
- Use existing time_spent calculation utility
- Refer to plan.md section "StudentProgressService" for details
```

**Quality check**: Complex tasks have helpful hints without over-specifying.

---

### Step 11: Generate tasks.md

**Actions**:
1. Render `tasks.md` from template with:
   - Overview (total tasks, estimated duration)
   - Task list (numbered, sequenced by dependencies)
   - Each task includes: Complexity, Description, Steps, AC, Dependencies

2. Add summary section:
   ```markdown
   ## Task Summary

   **Total tasks**: 28
   **Estimated duration**: 4-5 days
   **Critical path**: Tasks 1 → 4 → 8 → 9 → 15 → 16 → 22 → 23 → 27 (15 hours)
   **Parallel paths**: UI tasks (21-26) can run parallel to API tasks (16-20)

   **Task distribution**:
   - Foundation: 3 tasks
   - Data layer: 4 tasks
   - Business logic: 6 tasks (TDD: test + implement + refactor)
   - API layer: 6 tasks (TDD: test + implement)
   - UI layer: 6 tasks (TDD: test + implement)
   - Testing: 3 tasks (integration + E2E)
   ```

**Quality check**: tasks.md is complete and ready for /implement phase.

---

### Step 12: Validate and Commit

**Actions**:
1. Run validation checks:
   - [ ] 20-30 tasks total (appropriate for feature complexity)
   - [ ] All tasks ≤1.5 days (most 0.5-1 day)
   - [ ] All tasks have 2-4 acceptance criteria
   - [ ] TDD workflow followed (test-first tasks)
   - [ ] Dependencies clearly documented
   - [ ] No circular dependencies

2. Commit tasks:
   ```bash
   git add specs/NNN-slug/tasks.md
   git commit -m "feat: add task breakdown for <feature-name>

   Generated 28 tasks with TDD workflow:
   - Foundation: 3 tasks
   - Data layer: 4 tasks
   - Business logic: 6 tasks
   - API layer: 6 tasks
   - UI layer: 6 tasks
   - Testing: 3 tasks

   Estimated duration: 4-5 days
   ```

**Quality check**: Tasks committed, workflow-state.yaml updated to tasks phase completed.

---

## Common Mistakes to Avoid

### 🚫 Tasks Too Large (>1 Day)

**Impact**: Blocks progress, unclear completion, hard to estimate

**Scenario**:
```
Task: Implement entire student progress dashboard
Complexity: Very High (3 days)
Result: Unclear when 50% complete, hard to test incrementally
```

**Prevention**:
- **Target**: 0.5-1 day per task (4-8 hours)
- **If task >1 day**: Decompose into subtasks
- **Use TDD**: Separate test/implement/refactor into distinct tasks

**If encountered**: Split into smaller tasks (e.g., test task + implement task)

---

### 🚫 Missing or Vague Acceptance Criteria

**Impact**: Unclear when done, rework risk, merge conflicts

**Bad examples**:
```markdown
❌ [ ] Code works correctly
❌ [ ] Feature is implemented
❌ [ ] Tests pass
```

**Good examples**:
```markdown
✅ [ ] API returns 200 with completion_rate field (tested)
✅ [ ] Response time <500ms with 500 lessons (measured)
✅ [ ] Returns 404 for invalid student ID (tested)
```

**Prevention**:
- Each task has 2-4 testable acceptance criteria
- Use "Given-When-Then" format for clarity
- Include success metrics where applicable (response time, coverage %)

---

### 🚫 Not Following TDD Workflow

**Impact**: Tests written after code, poor test coverage, missed edge cases

**Bad task order**:
```markdown
Task 8: Implement StudentProgressService
Task 9: Write tests for StudentProgressService
```

**Good task order** (TDD):
```markdown
Task 8: Write unit tests for StudentProgressService (RED)
Task 9: Implement StudentProgressService to pass tests (GREEN)
Task 10: Refactor StudentProgressService (REFACTOR)
```

**Prevention**: Always create test task before implementation task

---

### 🚫 Unclear Dependencies

**Impact**: Tasks blocked, parallel work impossible, critical path unclear

**Bad example**:
```markdown
Task 15: Implement API endpoint
Dependencies: Other tasks
```

**Good example**:
```markdown
Task 15: Implement GET /api/v1/students/{id}/progress
Dependencies: Task 9 (StudentProgressService), Task 14 (API tests)
Blocks: Task 22 (UI component)
```

**Prevention**: Explicitly list task numbers for dependencies and blocked tasks

---

### 🚫 Mixing Implementation Details in Acceptance Criteria

**Impact**: Couples task to specific implementation, reduces flexibility

**Bad example**:
```markdown
❌ [ ] Uses Redis for caching
❌ [ ] Implements with React hooks
❌ [ ] Uses PostgreSQL indexes
```

**Good example** (outcome-focused):
```markdown
✅ [ ] Cache hit rate >80% for repeat requests
✅ [ ] Component re-renders <3 times on filter change
✅ [ ] Query executes in <100ms with 10k records
```

**Prevention**: Focus on outcomes, not implementation mechanisms

---

### 🚫 No Task Sequencing

**Impact**: Developers unsure what to start with, dependencies unclear

**Prevention**:
- Number tasks in dependency order
- Mark critical path
- Identify parallel work opportunities
- Document dependencies explicitly

---

## Best Practices

### ✅ Right-Sized Task Example

**Good task structure**:
```markdown
### Task 15: Implement GET /api/v1/students/{id}/progress

**Complexity**: Medium (6-8 hours)

**Description**: Implement API endpoint to make integration tests from Task 14 pass.

**Implementation steps**:
1. Create route in routes/students.py
2. Add authentication decorator (@require_teacher)
3. Validate student_id and period parameters
4. Call StudentProgressService.calculateProgress()
5. Format response per OpenAPI schema
6. Handle errors (404, 403, 400)

**Acceptance criteria**:
- [ ] All 5 integration tests from Task 14 pass
- [ ] Response time <500ms (95th percentile, 500 lessons)
- [ ] Follows API versioning (/api/v1/)
- [ ] Error responses include error codes

**Dependencies**: Task 14 (API tests), Task 9 (StudentProgressService)
**Blocks**: Task 22 (UI component)
**Files**: api/app/routes/students.py
```

**Why it's good**:
- Clear scope (single endpoint)
- Sized appropriately (6-8 hours)
- Test-driven (depends on test task 14)
- Measurable AC (4 checkboxes, all testable)
- Dependencies explicit

---

### ✅ TDD Task Triplet Pattern

**For every component, create 3 tasks**:

1. **RED**: Write failing tests
2. **GREEN**: Implement to pass tests
3. **REFACTOR**: Clean up while keeping tests green

**Example**:
```markdown
Task 8: Write unit tests for StudentProgressService
→ Task 9: Implement StudentProgressService
→ Task 10: Refactor StudentProgressService
```

**Result**: Enforces TDD discipline, ensures test coverage, encourages refactoring

---

### ✅ Acceptance Criteria Templates

**Use consistent format**:

**API endpoint AC**:
```markdown
- [ ] Returns {status_code} with {field} in response (tested)
- [ ] Response time <{threshold}ms (measured)
- [ ] Returns {error_code} for {error_condition} (tested)
- [ ] Follows {schema} from plan.md (validated)
```

**UI component AC**:
```markdown
- [ ] Renders {element} with {prop} (tested)
- [ ] {interaction} updates {state} (tested)
- [ ] Lighthouse accessibility score ≥{threshold}
- [ ] Reuses {component} from shared library
```

**Database migration AC**:
```markdown
- [ ] Migration runs successfully on clean database
- [ ] Rollback works without errors
- [ ] Indexes improve query performance (measured)
- [ ] Foreign keys enforce referential integrity
```

---

## Phase Checklist

**Pre-phase checks**:
- [ ] Planning phase completed (`plan.md` exists)
- [ ] Architecture components defined
- [ ] Reuse strategy documented
- [ ] Git working tree clean

**During phase**:
- [ ] Foundation tasks created (database, models, config)
- [ ] Business logic tasks follow TDD (test → implement → refactor)
- [ ] API tasks follow TDD (test → implement)
- [ ] UI tasks follow TDD (test → implement) - if HAS_UI
- [ ] Integration/E2E tasks created
- [ ] Task sizes validated (90% are 0.5-1 day)
- [ ] Acceptance criteria clear (2-4 per task, all testable)
- [ ] Dependencies documented
- [ ] Tasks sequenced by dependencies

**Post-phase validation**:
- [ ] `tasks.md` created with 20-30 tasks
- [ ] Task summary includes totals and critical path
- [ ] All tasks ≤1.5 days
- [ ] All tasks have clear AC
- [ ] TDD workflow followed
- [ ] Tasks committed to git
- [ ] workflow-state.yaml updated

---

## Quality Standards

**Task breakdown quality targets**:
- Total tasks: 20-30 (adjust for feature complexity)
- Avg task size: 0.5-1 day (4-8 hours)
- Tasks with clear AC: 100%
- Tasks following TDD: 100% for business logic + API + UI
- Task rework rate: <5%

**What makes a good task breakdown**:
- Right-sized tasks (0.5-1 day each)
- Clear, testable acceptance criteria (2-4 per task)
- TDD workflow (test tasks before implementation tasks)
- Explicit dependencies (task numbers listed)
- Helpful implementation notes (without over-specifying)

**What makes a bad task breakdown**:
- Tasks >1.5 days (too large, hard to estimate)
- Vague AC ("code works", "feature done")
- No TDD workflow (tests after implementation)
- Unclear dependencies ("depends on other tasks")
- Missing implementation hints for complex tasks

---

## Completion Criteria

**Phase is complete when**:
- [ ] All pre-phase checks passed
- [ ] All execution steps completed
- [ ] All post-phase validations passed
- [ ] Tasks committed to git
- [ ] workflow-state.yaml shows `currentPhase: tasks` and `status: completed`

**Ready to proceed to next phase** (`/implement`):
- [ ] 20-30 concrete tasks defined
- [ ] All tasks have clear AC
- [ ] Dependencies mapped
- [ ] TDD workflow established

---

## Troubleshooting

**Issue**: Tasks too large (>1.5 days)
**Solution**: Split into subtasks using TDD triplet (test + implement + refactor)

**Issue**: Acceptance criteria vague
**Solution**: Use AC templates from best practices, ensure all are testable

**Issue**: Dependencies unclear
**Solution**: Create dependency graph, list task numbers explicitly

**Issue**: Not enough tasks for complexity
**Solution**: Review plan.md components, ensure each has test + implement tasks

**Issue**: Too many tasks (>40)
**Solution**: Review for granularity, combine trivial tasks, verify feature scope

---

_This SOP guides the task breakdown phase. Refer to reference.md for sizing guidelines and examples.md for task patterns._
