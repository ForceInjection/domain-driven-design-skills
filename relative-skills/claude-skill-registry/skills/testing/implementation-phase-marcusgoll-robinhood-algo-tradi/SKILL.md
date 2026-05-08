---
name: implementation-phase
description: "Standard Operating Procedure for /implement phase. TDD workflow, anti-duplication checks, task execution, and continuous testing."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Implementation Phase: Quick Reference

> **Purpose**: Execute tasks from tasks.md using Test-Driven Development, preventing code duplication, and maintaining high quality.

## Phase Overview

**Inputs**:
- `specs/NNN-slug/tasks.md` - Task breakdown (20-30 tasks)
- `specs/NNN-slug/plan.md` - Implementation plan with reuse strategy

**Outputs**:
- Implemented code (models, services, APIs, UI components)
- Test suites (unit, integration, E2E)
- Updated `tasks.md` and `workflow-state.yaml`

**Expected duration**: 2-10 days (varies by complexity)

---

## Quick Start Checklist

**Before you begin**:
- [ ] Tasks phase completed (`tasks.md` exists with 20-30 tasks)
- [ ] Plan phase completed (`plan.md` exists)
- [ ] Development environment set up
- [ ] Test framework configured
- [ ] Git working tree clean

**Core workflow**:
1. ✅ [Load Tech Stack Constraints](resources/tech-stack-validation.md) - Prevent hallucinated tech choices
2. ✅ [Review Task Dependencies](resources/task-batching.md) - Identify parallel work opportunities
3. ✅ [Execute Tasks Using TDD](resources/tdd-workflow.md) - RED → GREEN → REFACTOR
4. ✅ [Update Task Status](resources/task-tracking.md) - Keep NOTES.md current
5. ✅ [Run Anti-Duplication Checks](resources/anti-duplication-checks.md) - Search before writing
6. ✅ [Continuous Testing](resources/continuous-testing.md) - Test after each task triplet
7. ✅ [Commit Implementation](resources/commit-strategy.md) - Small, frequent commits

---

## Detailed Resources

### 🎯 Core Workflow
- **[TDD Workflow](resources/tdd-workflow.md)** - RED → GREEN → REFACTOR cycle, test-first discipline
- **[Task Batching](resources/task-batching.md)** - Parallel execution strategy, dependency analysis
- **[Task Tracking](resources/task-tracking.md)** - NOTES.md updates, velocity tracking

### 🛡️ Quality Gates
- **[Tech Stack Validation](resources/tech-stack-validation.md)** - Load constraints from tech-stack.md
- **[Anti-Duplication Checks](resources/anti-duplication-checks.md)** - Search patterns, DRY enforcement
- **[Continuous Testing](resources/continuous-testing.md)** - Test cadence, coverage requirements

### 🚧 Advanced Topics
- **[Handling Blocked Tasks](resources/handling-blocked-tasks.md)** - Escalation strategies, workarounds
- **[Integration Testing](resources/integration-testing.md)** - Multi-component tests
- **[UI Component Testing](resources/ui-component-testing.md)** - React Testing Library, accessibility
- **[E2E Testing](resources/e2e-testing.md)** - Playwright/Cypress patterns

### 📋 Reference
- **[Common Mistakes](resources/common-mistakes.md)** - Anti-patterns to avoid
- **[Best Practices](resources/best-practices.md)** - Proven patterns from production
- **[Code Review Checklist](resources/code-review-checklist.md)** - Pre-commit validation
- **[Troubleshooting Guide](resources/troubleshooting.md)** - Common blockers and fixes

---

## Completion Criteria

**Required**:
- [ ] All tasks completed (or blocked tasks documented)
- [ ] Test coverage ≥80% (unit + integration)
- [ ] All tests passing (CI green)
- [ ] No code duplication (DRY violations <3)
- [ ] Code review checklist passed
- [ ] Git commits made with descriptive messages

**Optional** (if applicable):
- [ ] UI components have accessibility tests (WCAG 2.1 AA)
- [ ] E2E tests cover critical user flows
- [ ] Performance benchmarks met (API <200ms, page load <2s)

---

## Next Phase

After implementation complete:
→ `/optimize` - Code review, performance validation, production readiness

---

**See also**:
- [reference.md](reference.md) - Comprehensive implementation guide (full text)
- [examples.md](examples.md) - Good vs bad implementation examples
- [scripts/batch-validator.sh](scripts/batch-validator.sh) - Batch task validation
