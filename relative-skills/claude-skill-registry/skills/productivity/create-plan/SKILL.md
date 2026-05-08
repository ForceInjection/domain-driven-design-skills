---
name: create-plan
description: Create detailed implementation plans from feature specs or bug reports with testable acceptance criteria. Use proactively when planning features, refactors, or fixes. Every task MUST have minimum 2 testable ACs and map to requirements.
degree-of-freedom: medium
allowed-tools: Bash(project-intel.mjs:*), Read, Write, Edit
---

@.claude/shared-imports/constitution.md
@.claude/shared-imports/CoD_Σ.md
@.claude/templates/plan.md

# Planning Skill

## Overview

This skill creates detailed implementation plans from feature specifications or bug reports, breaking requirements into implementable tasks with testable acceptance criteria.

**Core Workflow**: Load Spec → Task Breakdown → Dependencies → Validate Plan

**Article III Enforcement**: Every task MUST have minimum 2 testable acceptance criteria (Test-First Imperative).

**Announce at start:** "I'm using the create-plan skill to create an implementation plan with testable acceptance criteria."

**Note**: For the main SDD workflow, use **create-implementation-plan skill** instead, which provides constitutional pre/post-design gates, automatic research.md/data-model.md generation, and automatic generate-tasks invocation. This skill (create-plan) is for simpler planning or legacy compatibility.

---

## Quick Reference

| Phase | Key Activities | Output |
|-------|---------------|--------|
| **Phase 1** | Load spec, extract requirements, intel queries | Requirements, constraints, context |
| **Phase 2** | Break into tasks, define ≥2 ACs per task | Tasks with testable ACs |
| **Phase 3** | Identify file/task dependencies via intel | Dependency graph, critical path |
| **Phase 4** | Validate coverage, ACs, dependencies | plan.md file |

---

## Workflow Files

**Detailed Phase Instructions**:
- **@.claude/skills/create-plan/workflows/load-spec.md** - Phase 1: Load Input Spec (3 input types)
- **@.claude/skills/create-plan/workflows/task-breakdown.md** - Phase 2: Task breakdown with ≥2 ACs
- **@.claude/skills/create-plan/workflows/dependency-analysis.md** - Phase 3: File and task dependencies
- **@.claude/skills/create-plan/workflows/plan-validation.md** - Phase 4: Validate plan quality

**Planning Strategies**:
- **@.claude/skills/create-plan/references/planning-patterns.md** - Feature, Refactor, Migration patterns
- **@.claude/skills/create-plan/references/enforcement-rules.md** - Quality gates and anti-patterns

**Examples**:
- **@.claude/skills/create-plan/examples/feature-planning-example.md** - Complete OAuth planning walkthrough

---

## Phase 1: Load Input Spec

**See:** @.claude/skills/create-plan/workflows/load-spec.md

**Summary:**

**Input Options** (priority order):
1. **feature-spec.md** - For new features (Article IV: Specification-First)
2. **bug-report.md** - For bug fixes (from debug-issues skill)
3. **Natural language** - Create spec first with specify-feature skill

**Extract:**
- Requirements (REQ-001, REQ-002, etc.)
- Constraints (technical, timeline, scope)
- Success criteria

**Intelligence Queries** (Article I):
```bash
project-intel.mjs --search "auth|oauth" --type ts --json > /tmp/plan_patterns.json
project-intel.mjs --overview --json > /tmp/plan_overview.json
```

**Article IV Enforcement**: Specification (WHAT/WHY) MUST exist before planning (HOW).

---

## Phase 2: Task Breakdown with Acceptance Criteria

**See:** @.claude/skills/create-plan/workflows/task-breakdown.md

**Summary:**

**Task Sizing**: 2-8 hours per task

**CRITICAL Article III Requirement**: **Minimum 2 testable ACs per task**

**Task Format**:
```markdown
### Task N: <specific description>
- **ID:** TN
- **Owner:** executor-agent
- **Estimated:** 2-8 hours
- **Dependencies:** [Tasks that must complete first]

**Acceptance Criteria:**
- [ ] AC1: <testable condition with pass/fail clarity>
- [ ] AC2: <independent verification without implementation knowledge>
- [ ] AC3: <optional third AC for complex tasks>
```

**Testable AC Examples**:
- ✓ "users table has google_id VARCHAR(255) column"
- ✓ "OAuth redirect returns HTTP 302 with Google authorization URL"
- ❌ "OAuth works" (vague, unverifiable)
- ❌ "System is secure" (subjective)

**Requirement Coverage Check**: Every requirement maps to at least one task (100% coverage required).

---

## Phase 3: Identify Dependencies

**See:** @.claude/skills/create-plan/workflows/dependency-analysis.md

**Summary:**

**Intelligence Queries**:
```bash
# Find target files
project-intel.mjs --search "<feature-keyword>" --json

# Check file dependencies
project-intel.mjs --dependencies src/file.ts --direction upstream --json
project-intel.mjs --dependencies src/file.ts --direction downstream --json

# Analyze symbols
project-intel.mjs --symbols src/file.ts --json
```

**Dependency Graph**:
```
T1 (DB)
 ├→ T2 (Backend) ─→ T3 (UI) ─→ T6 (E2E test)
 └→ T4 (Service) ─→ T5 (Endpoint) ─┘
```

**Identify**:
- Critical path (longest sequence)
- Parallel opportunities (mark with [P] per Article VIII)
- Circular dependencies (break if found)

**Token Efficiency**: Intel queries (~500 tokens) + targeted reads (~800 tokens) = ~1,300 tokens vs 15,000+ full file reads (91% savings).

---

## Phase 4: Validate Plan

**See:** @.claude/skills/create-plan/workflows/plan-validation.md

**Summary:**

**Validation Checklist**:
```markdown
### Requirement Coverage
- [ ] REQ-001 → T1, T2, T3 ✓
- [ ] REQ-002 → T4, T5 ✓
- [ ] Coverage: 100% ✓

### Task Quality (Article III)
- [ ] All tasks have ≥2 ACs ✓
- [ ] All ACs testable ✓

### Dependencies
- [ ] All dependencies identified ✓
- [ ] No circular dependencies ✓
- [ ] Critical path documented ✓
```

**File Naming**: `YYYYMMDD-HHMM-plan-<id>.md` OR `specs/<feature>/plan.md`

**Template**: @.claude/templates/plan.md

**Constitutional Compliance**:
- Article I: Intelligence queries executed, evidence saved to /tmp/
- Article II: CoD^Σ traces with file:line references
- Article III: ≥2 testable ACs per task
- Article IV: Derived from spec.md, not invented
- Article V: Follows plan.md template
- Article VII: User-story organization (if applicable)
- Article VIII: Parallel work marked [P]

---

## Planning Patterns

**See:** @.claude/skills/create-plan/references/planning-patterns.md

**Summary:**

**Pattern 1: Feature Planning** - Multiple requirements, cross-cutting changes
- Strategy: Start with DB schema → backend → frontend → E2E tests
- Organization: By user story priority (P1, P2, P3), not layer

**Pattern 2: Refactor Planning** - Improve existing code, maintain behavior
- Strategy: Understand current → tests FIRST → incremental refactors → verify

**Pattern 3: Migration Planning** - Large-scale change, gradual rollout
- Strategy: Run old and new in parallel → incremental migration → feature flags → deprecate old

**Pattern 4: Bug Fix Planning** - Fix broken behavior with regression tests
- Strategy: Reproduce with test → minimal fix → regression prevention

**Selection Guide**: Feature (new functionality), Refactor (quality), Migration (system change), Bug Fix (broken behavior).

---

## Enforcement Rules

**See:** @.claude/skills/create-plan/references/enforcement-rules.md

**Summary:**

**Rule 1: Minimum 2 ACs Per Task** (Article III)
- Single AC often just tests "it compiles"
- Multiple ACs verify behavior from multiple angles

**Rule 2: All Requirements → Tasks**
- 100% coverage required
- Matrix format: REQ-001 → T1, T2 (coverage check)

**Rule 3: No Vague Tasks**
- ❌ "Fix the auth system" → ✓ "Add missing setState dependency to useEffect"
- ❌ "Improve performance" → ✓ "Replace N+1 query with single JOIN"

**Common Pitfalls**:
- Tasks too large (>8h) → Break into smaller chunks
- Missing dependencies → Use project-intel.mjs
- Layer-first organization → Use user-story-first (Article VII)
- No parallel work identified → Mark independent tasks [P]

---

## Example: Feature Planning

**See:** @.claude/skills/create-plan/examples/feature-planning-example.md

**Summary:**

**Input**: feature-spec-oauth.md (3 requirements: OAuth login, session persistence, logout)

**Process**:
1. Load spec → REQ-001, REQ-002, REQ-003
2. Intel queries → found src/auth/session.ts:23 (JWT management, reusable)
3. Task breakdown → 6 tasks (T1-T6), each with 2-3 ACs
4. Dependencies → T1 → (T2, T4) → (T3, T5) → T6
5. Validate → 100% coverage, all tasks ≥2 ACs

**Output**: plan.md with 6 tasks, dependency graph, 24h estimate (19h with parallelization)

**Success Metrics**:
- Requirements coverage: 3/3 = 100% ✓
- Tasks with ≥2 ACs: 6/6 = 100% ✓
- No circular dependencies ✓

---

## Prerequisites

Before using this skill:
- ✅ spec.md OR bug report exists (input requirement)
- ✅ project-intel.mjs exists and is executable
- ✅ PROJECT_INDEX.json exists (run `/index` if missing)
- ⚠️ Optional: Feature directory structure `specs/<feature>/`
- ⚠️ Optional: MCP tools configured (Ref for library docs)

---

## Dependencies

**Depends On**:
- **specify-feature skill** - Provides spec.md (for feature planning)
- **debug-issues skill** - Provides bug diagnosis (for bug fix planning)
- project-intel.mjs - Codebase intelligence queries

**Integrates With**:
- **generate-tasks skill** - Uses plan.md to create tasks.md
- **implement-and-verify skill** - Uses plan.md for implementation
- **/audit command** - Validates plan against spec

**Modern Alternative**:
- **create-implementation-plan skill** - Preferred for SDD workflow (more comprehensive)

**Tool Dependencies**:
- project-intel.mjs (codebase intelligence)
- Read tool (load spec.md or bug-report.md)
- Write tool (create plan.md)

---

## Next Steps

After plan creation:

**Simple Workflow** (using this skill):
```
create-plan (creates plan.md)
    ↓ (manual)
/tasks plan.md
    ↓ (automatic)
/audit
    ↓ (if PASS)
/implement plan.md
```

**Recommended SDD Workflow** (using create-implementation-plan):
```
specify-feature (creates spec.md)
    ↓ (auto-invokes /plan)
create-implementation-plan (creates plan.md, research.md, data-model.md)
    ↓ (auto-invokes generate-tasks)
generate-tasks (creates tasks.md)
    ↓ (auto-invokes /audit)
/audit
    ↓ (if PASS)
/implement plan.md
```

**User Action Required**:
- Review plan.md for completeness
- Run `/tasks plan.md` (if using simple workflow)
- Resolve [NEEDS CLARIFICATION] markers

**Commands**:
- **/tasks plan.md** - Generate user-story-organized tasks
- **/implement plan.md** - Begin implementation after tasks and audit
- **/audit [feature-id]** - Validate cross-artifact consistency

---

## Failure Modes

**See:** @.claude/skills/create-plan/references/enforcement-rules.md for complete list.

**Top Failures**:

1. **No input specification** → Create spec.md with specify-feature skill first
2. **<2 ACs per task** (Article III violation) → Add more ACs or reject plan
3. **No intelligence queries** (Article I violation) → Query project-intel.mjs before assumptions
4. **Missing CoD^Σ traces** → Add file:line evidence with saved intel outputs
5. **Layer-first organization** (Article VII violation) → Restructure by user story priority
6. **Plan doesn't map to spec** → Ensure every requirement has corresponding tasks

---

## Related Skills & Commands

**Direct Integration**:
- **specify-feature skill** - Creates spec.md (feature planning input)
- **debug-issues skill** - Creates bug diagnosis (bug fix planning input)
- **generate-tasks skill** - Uses plan.md to create tasks.md
- **/plan command** - Invokes create-implementation-plan (NOT this skill)

**Modern Replacement**:
- **create-implementation-plan skill** - Enhanced SDD version with constitutional gates

**Workflow Context**:
- Position: Phase 2 of SDD workflow (after specification, before tasks)
- Triggers: User mentions "plan" or "how to implement"
- Output: plan.md with implementation strategy and ACs

**Quality Gates**:
- Article III: ≥2 testable ACs per task
- Article IV: Specification must exist before plan
- Article V: Must follow plan.md template

**Workflow Comparison**:
```
Legacy/Simple:
specify-feature → create-plan → manual /tasks → /implement

Current SDD:
specify-feature → create-implementation-plan → generate-tasks (auto) → /audit (auto) → /implement
```

**Recommendation**: For new development, prefer create-implementation-plan skill for comprehensive planning with automatic workflow progression.

---

**Skill Version**: 1.1.0
**Last Updated**: 2025-10-23
**Change Log**:
- v1.1.0 (2025-10-23): Refactored to progressive disclosure pattern (<500 lines)
- v1.0.0 (2025-10-22): Initial version
