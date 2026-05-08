---
name: tasks-planning
description: Use during Phase 4 of spec creation to break specification into organized task groups with dependencies - analyzes requirements to determine natural groupings, presents structure for validation, and creates detailed actionable tasks
---

# Tasks Planning

## What It Does

1. Analyzes spec and requirements
2. Determines natural task groupings by layer/skill
3. Presents structure for validation
4. Creates detailed tasks.md with dependencies
5. Notes reusability and visual references

**Tasks are specific, verifiable, and ordered by dependencies.**

## The Process

### Step 1: Load Specification

```bash
SPEC="[provided by workflow]"

cat "$SPEC/spec.md"
cat "$SPEC/planning/requirements.md"
ls -la "$SPEC/planning/visuals/"
```

**Analyze:**
- Requirements and dependencies
- Technical layers (database, API, frontend)
- Existing code to leverage
- Visual designs to implement

### Step 2: Determine Task Groups

Identify natural groupings:

**Common patterns:**
- Database Layer (models, migrations)
- API Layer (controllers, routes, auth)
- Frontend Components (UI, forms, pages)
- Integration & Testing (end-to-end verification)

**Consider dependencies:**
- Database before API (API needs models)
- API before Frontend (Frontend needs endpoints)
- Implementation before Testing

**Present structure:**
```
Based on spec, I'm organizing tasks into:

1. **Database Layer**
   - Models, migrations, associations
   - Dependencies: None (foundation)

2. **API Layer**
   - Controllers, endpoints, auth
   - Dependencies: Database Layer

3. **Frontend Components**
   - UI, forms, pages
   - Dependencies: API Layer

4. **Integration & Testing**
   - End-to-end verification
   - Dependencies: All implementation

This follows dependency order: foundation → API → interface → verification

Does this grouping make sense, or organize differently?
```

**WAIT for confirmation.**

### Step 3: Present Task Breakdown

After grouping approved:

```
Detailed task breakdown:

## Task Group 1: Database Layer
**Dependencies:** None

- [ ] 1.0 Complete database layer
  - [ ] 1.1 Create [Model] with validations
    - Fields: [list]
    - Validations: [list]
    - Reuse pattern from: [existing if applicable]
  - [ ] 1.2 Create migration for [table]
    - Add indexes for: [fields]
    - Foreign keys: [relationships]
  - [ ] 1.3 Set up associations
    - [Model] has_many [related]
    - [Model] belongs_to [parent]

**Acceptance Criteria:**
- Models pass validation tests
- Migrations run successfully
- Associations work correctly

---

## Task Group 2: API Layer
**Dependencies:** Task Group 1

[Similar structure]

---

[Continue for all groups]

Does this breakdown capture all requirements?
```

**WAIT for confirmation.**

### Step 4: Create tasks.md

After breakdown approved:

```bash
cat > "$SPEC/tasks.md" <<'EOF'
# Task Breakdown: [Feature Name]

## Overview
Total Task Groups: [count]
Total Tasks: [count including sub-tasks]

## Task List

### Task Group 1: [Name]

#### Dependencies: [None or previous groups]

- [ ] 1.0 Complete [layer]
  - [ ] 1.1 [Implementation task]
    - [Specific details]
    - [Reuse pattern from: [existing code] if applicable]
  - [ ] 1.2 [Implementation task]
    - [Specific details]
  - [ ] 1.3 [Implementation task]
  - [ ] 1.4 [Implementation task]

**Acceptance Criteria:**
- [Functional criteria]
- [Technical criteria]
- [Quality criteria]

---

### Task Group 2: [Name]

#### Dependencies: Task Group 1

[Similar structure for each group]

---

## Execution Order

Recommended sequence:
1. Task Group 1: [Name] (Foundation)
2. Task Group 2: [Name] (Builds on 1)
3. Task Group 3: [Name] (Builds on 2)
4. Task Group 4: [Name] (Verification)

## Notes

- Tasks reference specific files/components from spec.md
- Reusability opportunities noted where applicable
- Visual assets referenced in frontend tasks
- Follow TDD: write tests for each component/behavior
EOF
```

### Step 5: Report Completion

```
✅ Task breakdown complete!

Created: tasks.md

Summary:
- [X] task groups by dependencies
- [Y] total tasks
- Execution order defined
- Acceptance criteria for each group

Structure:
- Specific and verifiable tasks
- Dependencies clearly marked
- Reusability notes included
- Visual references added (if applicable)

Ready for Phase 5: Verification
```

**Return to workflow.**

## Task Breakdown Principles

### Grouping Logic

**Group by layer AND skill:**
- Database tasks together (backend skills)
- API tasks together (backend + API design)
- Frontend tasks together (UI/UX + frontend)
- Testing together (integration + QA)

**Respect dependencies:**
- Foundation layers first
- Build progressively
- Verification last

### Task Granularity

**Good task size:** Completable in 1-4 hours

**Too granular:**
- ❌ "Add import statement"
- ❌ "Define variable"

**Too broad:**
- ❌ "Build authentication system"
- ❌ "Create all components"

**Just right:**
- ✅ "Create User model with validations"
- ✅ "Implement login API endpoint"
- ✅ "Build registration form component"

### Testing Approach

**Follow TDD naturally:**
- Write test for behavior
- Implement to pass test
- Refactor while green
- Repeat for next behavior

**Don't specify test counts** - write tests for each:
- Model method
- API endpoint
- UI component behavior
- Integration flow

Subagents following TDD will write appropriate tests.

## Adapting Structure

**API-heavy feature:**
```
1. Database Layer
2. API Endpoints
3. Authentication/Authorization
4. Frontend Integration
5. Integration Testing
```

**UI-heavy feature:**
```
1. Data Layer (if needed)
2. Component Library
3. Page Layouts
4. Interaction Flows
5. Integration Testing
```

**Background job:**
```
1. Data Models
2. Job Logic
3. Queue Configuration
4. Monitoring/Logging
5. Integration Testing
```

**Adapt to feature, but always:**
- Respect dependencies
- Include verification group
- Note reusability

## Red Flags

**Never:**
- Create vague tasks without specifics
- Omit dependencies
- Skip reusability notes when identified
- Forget visual references (if visuals exist)

**Always:**
- Make tasks specific and verifiable
- Note dependencies between groups
- Include reusability references
- Reference visual files in frontend tasks
- Define acceptance criteria per group

## Integration

**Called by:**
- `spec-creation-workflow` (Phase 4)

**Returns to:**
- `spec-creation-workflow`

**Creates:**
- `[spec]/tasks.md`

**Uses:**
- `spec.md` - Requirements and structure
- `planning/requirements.md` - Original requirements
- `planning/visuals/*` - Design assets

**Next phase uses:**
- `tasks.md` for verification
