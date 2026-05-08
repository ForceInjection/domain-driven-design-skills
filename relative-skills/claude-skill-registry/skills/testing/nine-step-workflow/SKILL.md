---
name: nine-step-workflow
description: Comprehensive 9-step development workflow ensuring quality through planning, implementation, review, testing, and documentation with worktree isolation. Includes agent assignments, quality gates, and AskUserQuestion usage. Use when orchestrating feature development or understanding the development process.
---

# 9-Step Development Workflow

## Overview

Standardized 9-step development workflow ensures all feature development goes through planning, review, implementation, testing, and documentation.

<!-- CUSTOMIZE: Adjust language based on project conventions -->

```
Step 1: Plan → Step 2: Review → Step 2.5: User Approval ⭐
    ↓ (worktree creation)
Step 3: Code → Step 4: Review → Step 5: Docs → Step 6: Review
    ↓
Step 7: Test → Step 8: Review → Step 9: Commit
```

**Core Principle**: Steps 3-9 all execute **within the same worktree**.

## Core Instructions

### Agent Assignments

| Step | Agent | Model | Location |
|------|-------|-------|----------|
| 1 | project-planner | Sonnet | Main |
| 2 | plan-reviewer | Sonnet | Main |
| 2.5 | User + git-worktree-manager | - / Haiku | Main |
| 3 | backend/frontend-developer | Dynamic | **Worktree** |
| 4 | code-reviewer | Sonnet | **Worktree** |
| 5 | documentation-manager | Haiku | **Worktree** |
| 6 | documentation-reviewer | Haiku | **Worktree** |
| 7 | feature-tester | Haiku | **Worktree** |
| 8 | test-reviewer | Dynamic | **Worktree** |
| 9 | git-worktree-manager | Haiku | **Worktree** |

### Critical Rules

1. **No Skipping Steps**: Every feature goes through all 9 steps
2. **User Approval Required** (Step 2.5): No code without user confirming plan ⭐
3. **Worktree Isolation**: All Steps 3-9 work in dedicated worktree
4. **Worktree Context**: Always provide worktree path to Step 3-9 agents
5. **Quality Gates**: Explicit approval before proceeding to next step
6. **Phase-by-Phase**: Complete one phase fully before starting next

### Special Constraints by Agent

<!-- CUSTOMIZE: Adjust constraints based on project needs -->

| Agent | Constraint |
|-------|------------|
| documentation-manager | **{{MAX_DOC_LINES}} line response limit** - Batch work required |
| feature-tester | **{{TEMP_TEST_DIR}}/ cleanup required** - Remove temp files after testing |
| test-reviewer | **{{PERM_TEST_DIR}}/ immutability guardian** - Approve {{PERM_TEST_DIR}}/ modifications extremely strictly |
| git-worktree-manager | **4-step cleanup sequence** - plan→services→worktree→branch |

### AskUserQuestion Usage

**Required Usage Scenarios**:
- **Step 1**: Ambiguous requirements, multiple approaches exist, tech stack selection
- **Step 2**: Architecture concerns, code bloat (30%+), security risks
- **Step 3**: Undefined behavior, performance trade-offs, incomplete API spec (frontend)
- **Conflicts**: Logic/architecture conflicts, multiple resolution methods

**Standard Question Format**: 3-5 options, pros/cons + estimated effort, recommended option

## Quick Reference

### Worktree Context Format (Step 3-9)

<!-- CUSTOMIZE: Adjust language -->

```
📍 Working Context
- Worktree Path: .worktree/{{feature-name}}/
- Branch: feature/{{feature-name}}
- Current Phase: Phase X - {{Phase description}}
- Current Step: Step Y ({{Step name}})
- Work Scope: {{Specific files/directories list}}
```

### Quality Gates

- **After Step 2**: Approved/Approved with Changes → Step 2.5
- **After Step 2.5**: User approves → Create worktree → Step 3
- **After Step 4**: Approved/Approved with Minor Issues → Step 5
- **After Step 6**: Approved/Approved with Minor Corrections → Step 7
- **After Step 8**: Testing Valid/Valid with Caveats → Step 9

## Integration

**Other Skills Used**:
- `@worktree-path-policy` - Steps 3-9 working directory policy
- `@phase-decomposition` - Phase breakdown strategy (1-3h units)
- `@code-minimization` - Code addition justification criteria
- `@git-workflow-policy` - Git commit, merge, cleanup policy
- `@interactive-questions` - When user decision needed
- `@test-file-management` - {{PERM_TEST_DIR}}/ vs {{TEMP_TEST_DIR}}/ management

**Model Selection**:
- `@agent-model-selection` - Sonnet vs Haiku selection criteria

## Detailed Step Breakdown

### Step 1: Planning (project-planner)

**Responsibilities:**
- Analyze requirements
- Break down into 3-8 phases
- Identify dependencies
- Assess risks
- Define success criteria

**Deliverable:** `.plan/{{feature_name}}_plan.md`

**Skills Used:**
- @phase-decomposition
- @risk-assessment
- @code-minimization
- @tag-based-search
- @interactive-questions (if requirements unclear)

---

### Step 2: Plan Review (plan-reviewer)

**Responsibilities:**
- Verify phase breakdown
- Check architecture compliance
- Assess code bloat risk
- Evaluate security concerns

**Deliverable:** Approval status (4-tier: APPROVED, APPROVED_WITH_CONDITIONS, NEEDS_REVISION, REJECTED)

**Skills Used:**
- @architecture-principles
- @code-minimization
- @risk-assessment
- @quality-gates
- @interactive-questions (if major concerns)

---

### Step 2.5: User Approval ⭐

**Responsibilities:**
- User reviews plan
- User approves/requests changes
- git-worktree-manager creates worktree (on approval)

**Deliverable:** `.worktree/{{feature-name}}/` directory, `feature/{{feature-name}}` branch

**Critical:** No Step 3 without this approval

---

### Step 3: Code Implementation (backend/frontend-developer)

**Responsibilities:**
- Implement code according to plan
- Follow architecture principles
- Apply YAGNI principle
- Add code tags

**Deliverable:** Working code for current phase

**Skills Used:**
- @architecture-principles
- @code-minimization
- @security-checklist
- @tag-based-search
- @worktree-path-policy ⭐

---

### Step 4: Code Review (code-reviewer)

**Responsibilities:**
- Verify plan compliance
- Check architecture principles
- Security validation
- Performance assessment

**Deliverable:** Approval status with detailed feedback

**Skills Used:**
- @architecture-principles
- @security-checklist
- @trust-principles
- @quality-gates
- @worktree-path-policy ⭐

---

### Step 5: Documentation (documentation-manager)

**Responsibilities:**
- Add code comments
- Write feature documentation
- Update feature catalog
- Maintain tag consistency

**Deliverable:** Complete documentation (< {{MAX_DOC_LINES}} lines)

**Skills Used:**
- @tag-based-search
- @documentation-draft (if using TDD approach)
- @worktree-path-policy ⭐

**Constraint:** {{MAX_DOC_LINES}}-line response limit - batch large docs

---

### Step 6: Documentation Review (documentation-reviewer)

**Responsibilities:**
- Verify < {{MAX_DOC_LINES}} lines
- Check clarity and conciseness
- Ensure code consistency
- Validate tag system

**Deliverable:** Approval status

**Skills Used:**
- @quality-gates
- @worktree-path-policy ⭐

---

### Step 7: Testing (feature-tester)

**Responsibilities:**
- Execute test scenarios
- Write test code ({{TEMP_TEST_DIR}}/ preferred)
- Clean up temporary files

**Deliverable:** Test results report

**Skills Used:**
- @test-file-management
- @worktree-path-policy ⭐

**Constraint:** Must clean {{TEMP_TEST_DIR}}/ after completion

---

### Step 8: Test Review (test-reviewer)

**Responsibilities:**
- Validate test coverage
- Verify test strategy
- Guard {{PERM_TEST_DIR}}/ immutability
- Approve performance criteria

**Deliverable:** Approval status

**Skills Used:**
- @test-file-management
- @quality-gates
- @worktree-path-policy ⭐

**Critical:** {{PERM_TEST_DIR}}/ modifications approved extremely strictly

---

### Step 9: Commit (git-worktree-manager)

**Responsibilities:**
- Create phase commit
- Update plan document
- Push to feature branch

**Deliverable:** Git commit for current phase

**Skills Used:**
- @git-workflow-policy
- @worktree-path-policy ⭐

**Note:** Commit message includes rationale and scope

---

## Phase vs Step Clarification

**Phase** = Feature/component implementation unit (Phase 1, Phase 2, ...)
**Step** = Workflow stage within each phase (Step 1-9)

**Structure:**
```
Phase 1: {{Component Name}}
  Step 1-9 (Complete 9-step workflow)

Phase 2: {{Component Name}}
  Step 1-9 (Repeat 9-step workflow)

Phase 3: {{Component Name}}
  Step 1-9 (Repeat 9-step workflow)
```

**Execution:**
- Each Phase goes through all 9 Steps
- Phase X Step 9 complete → Phase X+1 Step 1 begins
- All Phases complete → Merge to main

---

## Merge and Cleanup

**After all Phases complete:**

1. User approves merge
2. git-worktree-manager merges to main
3. 4-step cleanup:
   ```bash
   rm .plan/{{feature_name}}_plan.md
   cd .worktree/{{feature-name}} && {{cleanup_command}}
   git worktree remove .worktree/{{feature-name}}
   git branch -d feature/{{feature-name}}
   ```

---

**For detailed step-by-step guide, see [reference.md](reference.md)**
**For practical examples, see [examples.md](examples.md)**
