---
name: qa-test-management
description: Automatic QA test lifecycle management, naming conventions, and directory structure. Use when creating, organizing, or tracking QA tests to ensure proper naming, directory structure, and status transitions.
---

# QA Test Management Skill

Ensure consistent QA test organization, lifecycle management, and traceability.

## Automatic Behaviors

When working with QA tests, automatically:

1. **Apply naming conventions** for QA test files
2. **Maintain directory structure** for test organization
3. **Enforce status lifecycle** transitions
4. **Include required metadata** in all test files
5. **Link tests to PRD requirements** for traceability
6. **Track execution history** with dates and results

## Directory Structure

```
qa-tests/
├── draft/                    # Tests being written
│   └── QA-20250105-001-login.md
├── active/                   # Tests ready for execution
│   └── QA-20250104-002-checkout.md
├── executed/                 # Recently executed tests
│   └── QA-20250103-001-search.md
├── archived/                 # Historical tests
│   └── 2024/
│       └── QA-20241215-001-old-feature.md
└── screenshots/              # Test evidence
    ├── login-page.png
    └── checkout-success.png
```

## File Naming Convention

```
QA-YYYYMMDD-###-feature-name.md
```

- `QA` - Prefix for all QA test files
- `YYYYMMDD` - Creation date
- `###` - Sequential number for that day (001, 002, etc.)
- `feature-name` - Kebab-case feature description

**Examples:**
- `QA-20250105-001-user-login.md`
- `QA-20250105-002-password-reset.md`
- `QA-20250106-001-checkout-flow.md`

## Status Lifecycle

```
DRAFT → ACTIVE → EXECUTED → ARCHIVED
```

| Status | Description | Location |
|--------|-------------|----------|
| `DRAFT` | Being written, not ready for execution | `qa-tests/draft/` |
| `ACTIVE` | Ready to be executed by testers | `qa-tests/active/` |
| `EXECUTED` | Has been run, awaiting review/archival | `qa-tests/executed/` |
| `ARCHIVED` | Historical reference, no longer active | `qa-tests/archived/YYYY/` |

### Status Transitions

- **DRAFT → ACTIVE**: All test cases complete, metadata filled, reviewed
- **ACTIVE → EXECUTED**: Test has been run, execution log updated
- **EXECUTED → ARCHIVED**: Test cycle complete, moved to archive
- **Any → DRAFT**: Test needs rework (regression found, requirements changed)

## Required Metadata

Every QA test file MUST include:

```markdown
## Metadata
- **Test ID**: QA-YYYYMMDD-###
- **Feature**: [Feature name]
- **Application**: [App name]
- **URL**: [Test environment URL]
- **Created**: [YYYY-MM-DD]
- **Author**: [Name]
- **Status**: [DRAFT|ACTIVE|EXECUTED|ARCHIVED]
- **Priority**: [Critical|High|Medium|Low]
- **Estimated Time**: [X minutes]
- **PRD Reference**: [Link to PRD section if applicable]
```

## Priority Definitions

| Priority | Description | Execution Frequency |
|----------|-------------|---------------------|
| **Critical** | Core functionality, blocking issues | Every release |
| **High** | Important features, user-facing | Every sprint |
| **Medium** | Secondary features, edge cases | Monthly |
| **Low** | Nice-to-have, rare scenarios | Quarterly |

## PRD Traceability

Link QA tests to PRD requirements:

```markdown
## Requirement Traceability

| Requirement | PRD Section | Test Cases |
|-------------|-------------|------------|
| User can login with email/password | PRD 3.1.1 | TC-001, TC-002 |
| Password must be 8+ characters | PRD 3.1.2 | TC-003 |
| Failed login shows error message | PRD 3.1.3 | EC-001, EC-002 |
```

## Execution Log Format

Track test runs in each test file:

```markdown
## Test Execution Log

| Date | Tester | Environment | Build | Result | Issues |
|------|--------|-------------|-------|--------|--------|
| 2025-01-05 | Jane | staging | v1.2.3 | PASS | None |
| 2025-01-04 | John | staging | v1.2.2 | FAIL | #123 |
```

## Quality Checks Before Activation

Before moving a test from DRAFT to ACTIVE:

- [ ] All test cases have clear steps
- [ ] Expected results are specific and verifiable
- [ ] Prerequisites are documented
- [ ] Test data is specified (not "enter something")
- [ ] Screenshots placeholders identified
- [ ] Priority is assigned
- [ ] Estimated time is realistic
- [ ] PRD traceability added (if applicable)

## Archival Rules

Archive a test when:
- Feature has been deprecated
- Test has been superseded by new test
- Test hasn't been executed in 6+ months
- Feature requirements have fundamentally changed

Archival metadata to add:
```markdown
## Archive Information
- **Archived Date**: [YYYY-MM-DD]
- **Archived By**: [Name]
- **Archive Reason**: [Deprecated|Superseded|Stale|Requirements Changed]
- **Superseded By**: [New test ID, if applicable]
```

## Metrics to Track

When listing or reporting on QA tests:

1. **Coverage**: Tests per feature/PRD
2. **Execution Rate**: % of active tests executed this period
3. **Pass Rate**: % of executed tests that passed
4. **Age**: Days since last execution
5. **Flakiness**: Tests that flip between pass/fail
