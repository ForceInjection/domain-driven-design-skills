---
name: propose-feature-test-plan
description: Create a test plan mapping EARS requirements and Critical Constraints to specific tests
---

# Propose Feature Test Plan Skill

## Purpose

Create a test plan that systematically maps requirements and constraints to concrete tests. This ensures every requirement has verification and guides test implementation.

## When to Use

- Design document with Critical Constraints exists
- Ready to plan testing approach before implementation
- Need to document what tests will verify each requirement

## Prerequisites

- Feature concept exists in `./docs/features/NNNN-feature-name/concept.md`
- Requirements exist in `./docs/features/NNNN-feature-name/requirements.md`
- Design exists in `./docs/features/NNNN-feature-name/design.md` (contains Critical Constraints)

## Procedure

### 1. Verify Prerequisites Exist

```bash
ls ./docs/features/NNNN-feature-name/concept.md
ls ./docs/features/NNNN-feature-name/requirements.md
ls ./docs/features/NNNN-feature-name/design.md
```

If any don't exist, complete those steps first.

### 2. Extract Requirements and Constraints

Review requirements.md for all REQ-* identifiers.
Review design.md for all CC-* Critical Constraints.

### 3. Create Test Plan File

Create `./docs/features/NNNN-feature-name/test-plan.md` with this structure:

```markdown
# Test Plan: Feature Name

## Overview

Brief description of testing approach.

## Test Types

- **Unit**: Test internal logic in isolation, mocks allowed
- **Integration**: Touch real external resources (filesystem, network), NO mocks
- **Not testable**: Cannot be verified by automated test (explain why)
- **Out of scope**: Requires external authentication - document but do not implement

## Requirements Coverage

| Req ID | Test Type | Test Name | Description |
|--------|-----------|-----------|-------------|
| REQ-1  | unit      | test_xxx  | What it verifies |
| REQ-2  | integration | test_yyy | What it verifies |
| REQ-3  | not-testable | - | Why not testable |
| REQ-4  | out-of-scope | - | Why out of scope |

## Critical Constraints Verification

| CC ID | Verification Approach | Test Name(s) |
|-------|----------------------|--------------|
| CC-1  | How constraint is verified | test_xxx |

## Integration Test Requirements

For CLI programs, integration tests MUST:
- Exercise the actual CLI binary/commands users run
- NOT test internal APIs directly
- Do what the user/customer will actually do

## Test Implementation Notes

Any specific guidance for implementing these tests.
```

### 4. Map Each Requirement

For each REQ-* in requirements.md:

1. Determine test type:
   - **Unit**: Internal logic, algorithms, data transformations
   - **Integration**: File I/O, network calls, CLI commands, external processes
   - **Not testable**: Cannot be automated (e.g., subjective quality, requires human judgment, infeasible to set up)
   - **Out of scope**: Requires authentication with external systems (cloud APIs, registries with auth)

2. Name the test descriptively (e.g., `test_parses_valid_config`)

3. Write brief description of what it verifies

### 5. Map Each Critical Constraint

For each CC-* in design.md:

1. Describe how the constraint will be verified
2. Link to specific test name(s) that enforce it
3. Note if constraint requires code review rather than automated test

### 6. Document CLI Testing Approach

If the feature includes CLI commands:

- Integration tests run the actual binary
- Capture stdout/stderr for verification
- Test real user workflows end-to-end
- Do NOT mock the CLI layer

### 7. Mark Out-of-Scope Tests

For tests requiring external authentication:

1. Document what WOULD be tested
2. Explain why it's out of scope
3. Note any manual verification steps

## Validation

```bash
# Check file exists
ls ./docs/features/NNNN-feature-name/test-plan.md

# Verify all requirements are covered
grep -c "REQ-" ./docs/features/NNNN-feature-name/test-plan.md
grep -c "REQ-" ./docs/features/NNNN-feature-name/requirements.md
# Counts should be comparable

# Verify all constraints are covered
grep -c "CC-" ./docs/features/NNNN-feature-name/test-plan.md
grep -c "CC-" ./docs/features/NNNN-feature-name/design.md
# Counts should be comparable
```

## Common Issues

**Missing coverage**: Every REQ-* and CC-* must appear in the test plan. Use the validation grep commands to check.

**Wrong test type**: Unit tests should not touch filesystem/network. Integration tests should not use mocks.

**Testing internals instead of behavior**: For CLI tools, test the CLI commands users run, not internal functions.

**Vague descriptions**: Test descriptions should state what specific behavior is verified.

## Next Steps

After creating the test plan:
1. Review coverage with stakeholders
2. Proceed to `propose-implementation-plan` skill to plan implementation
3. Implementation plan should reference test-plan.md for test requirements
