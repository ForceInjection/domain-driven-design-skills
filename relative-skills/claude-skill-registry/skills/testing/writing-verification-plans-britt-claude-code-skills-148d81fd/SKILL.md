---
name: writing-verification-plans
description: Use when a project needs a verification plan for acceptance testing in real-world scenarios
---

# Writing Verification Plans

## Overview

Help Claude write verification plans that validate a project works in real-world scenarios before completing tasks.

**Core principle:** Verification is not integration testing. It uses real systems, never mocks or fakes. A test environment is acceptable only if it's a fully running copy of the system being integrated with.

**Announce at start:** "I'm using the writing-verification-plans skill to create acceptance testing procedures."

## When to Use This Skill

Use this skill when:
- Setting up a new project (called from `setting-up-a-project` skill)
- A project lacks a VERIFICATION_PLAN.md
- The developer asks for a verification plan
- Adding new features that require real-world validation

## Writing the Verification Plan

Ask the user about the real-world scenarios that need to be validated. For each scenario, gather:

1. **What is being tested?** The feature or capability to verify
2. **What does success look like?** Concrete, observable outcomes
3. **What environment is needed?** Real systems, test accounts, sample data
4. **What could go wrong?** Edge cases and failure modes to check

### VERIFICATION_PLAN.md Format

```markdown
# Verification Plan

## Prerequisites

[List everything needed before verification can run]
- Test environment setup instructions
- Required accounts or credentials
- Sample data or test fixtures
- External systems that must be running

## Scenarios

### Scenario 1: [Name]

**Context**: [What state the system should be in before starting]

**Steps**:
1. [Specific action Claude should take]
2. [Next action]
3. [Continue until complete]

**Success Criteria**:
- [ ] [Observable outcome that must be true]
- [ ] [Another required outcome]

**If Blocked**: [When to stop and ask developer for help]

### Scenario 2: [Name]

[Repeat format for each scenario]

## Verification Rules

- Never use mocks or fakes
- Test environments must be fully running copies of real systems
- If any success criterion fails, verification fails
- Ask developer for help if blocked, don't guess
```

## Running Verification

**Verification runs automatically after completing any task.** Do not wait for the developer to request it.

### Process

1. Read VERIFICATION_PLAN.md
2. Confirm prerequisites are met (ask developer if unsure)
3. Execute each scenario in order
4. For each step, document what was done and what was observed
5. Check each success criterion
6. Produce a detailed verification log

### Verification Log Format

After running verification, report results in this format:

```markdown
## Verification Log - [Timestamp]

### Task Completed
[Brief description of what was just implemented]

### Scenarios Executed

#### Scenario 1: [Name]
**Status**: PASS / FAIL / BLOCKED

**Steps Executed**:
1. [What was done] → [What was observed]
2. [What was done] → [What was observed]

**Success Criteria**:
- [x] [Criterion] - PASSED: [evidence]
- [ ] [Criterion] - FAILED: [what went wrong]

**Notes**: [Any relevant observations]

#### Scenario 2: [Name]
[Repeat for each scenario]

### Summary
- Scenarios: X passed, Y failed, Z blocked
- Overall: PASS / FAIL
- Issues found: [List any problems discovered]
```

### When Blocked

If verification cannot proceed:
1. Document exactly what is blocking you
2. Ask the developer for help using the `summoning-the-user` skill if installed
3. Do not guess or skip scenarios
4. Do not mark task as complete until verification passes

## Key Rules

| Rule | Reason |
|------|--------|
| No mocks, ever | Verification must prove real-world behavior |
| Run after every task | Catch issues before moving on |
| Detailed logging | Developer needs to see what was tested |
| Ask when blocked | Wrong assumptions waste time |
| All scenarios must pass | Partial success = failure |
