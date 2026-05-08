---
name: test-compliance-validator
description: This skill should be used after creating or modifying test code to deeply analyze test structure, ensure enterprise-readiness, detect fake success patterns, and verify tests provide real value - validates against integration testing best practices to prevent tests that pass when implementation is broken
---

# Test Compliance Validator

## Overview

This skill provides comprehensive validation of test code to ensure it meets enterprise standards and actually tests real behavior rather than creating false confidence. It detects common anti-patterns like mocking application logic, log-based assertions, hardcoded responses, and tests that cannot fail.

**Core Principle:** A test that passes when the implementation is broken is worse than no test at all.

## When to Use

Trigger this skill when:

- An agent has finished writing test code and claims tests are complete
- Reviewing newly created integration, unit, or BDD tests
- Tests pass but their quality needs verification
- Validating test code before marking a task as complete
- Ensuring tests are enterprise-ready, not just passing

## Instructions

### Step 1: Identify Test Context

To begin validation, first understand what type of tests are being analyzed:

1. **Scan the context** for recently added or modified test files
2. **Identify test type**:
   - BDD/Gherkin features (`.feature` files with step definitions)
   - Unit tests (Go `_test.go`, PHP `Test*.php`, etc.)
   - Integration tests (tests with infrastructure setup)
   - Behat tests (PHP BDD framework)
3. **Note the testing framework** being used
4. **Identify external dependencies** (databases, APIs, message queues)

### Step 2: Execute Systematic Analysis

To analyze test quality, perform these checks in order:

#### 2.1 Real Integration Analysis (CRITICAL)

**Violation Level: CRITICAL**

To verify real integration:

- **Check for mocked application code**: Search for mocks of internal workflows, handlers, business logic
- **Verify external mocks only**: Ensure only external APIs (not owned by the team) are mocked
- **Validate infrastructure usage**: Confirm real databases, queues, caches are used (or proper test doubles like LocalStack)

**Red Flags:**

```go
// ❌ FORBIDDEN - Mocking own code
type mockWorkflow struct{}
func (m *mockWorkflow) Execute() error { return nil }

// ❌ FORBIDDEN - Mocking internal services
mockHandler := &MockMessageHandler{}
```

#### 2.2 Behavioral Verification Analysis (CRITICAL)

**Violation Level: CRITICAL**

To verify behavioral testing:

- **Identify assertions**: What is each test actually verifying?
- **Check for log assertions**: Flag any test that asserts on log messages as primary verification
- **Verify side effects**: Ensure tests check actual outcomes (API called, DB updated, message sent)

**Red Flags:**

```go
// ❌ Log-based assertion
assert.Contains(t, logs, "workflow executed successfully")

// ❌ No behavioral verification
workflow.Execute()
// No assertion on what Execute() actually did
```

#### 2.3 Failure Capability Analysis (CRITICAL)

**Violation Level: CRITICAL**

To verify tests can fail:

- **Look for hardcoded success**: Check for tests that always return success
- **Verify negative cases**: Ensure error scenarios are tested
- **Check assertion presence**: Every test must have meaningful assertions

**Red Flags:**

```go
// ❌ Always succeeds
func TestWorkflow(t *testing.T) {
    workflow := NewWorkflow()
    workflow.Execute() // No error checking
    assert.True(t, true) // Meaningless assertion
}
```

#### 2.4 Test Independence Analysis (HIGH)

**Violation Level: HIGH**

To verify test independence:

- **Check for shared state**: Tests should not depend on execution order
- **Verify cleanup**: Each test should clean up after itself
- **Look for test pollution**: One test's data affecting another

#### 2.5 Dead Code Analysis (MEDIUM)

**Violation Level: MEDIUM**

To identify dead code:

- **Unused test helpers**: Functions defined but never called
- **Redundant setup**: Repeated initialization that could be shared
- **Commented test code**: Old tests left commented out
- **Duplicate tests**: Multiple tests verifying the same behavior

#### 2.6 Code Quality Analysis (MEDIUM)

**Violation Level: MEDIUM**

To assess code quality:

- **Readability**: Is the test's purpose immediately clear?
- **Naming**: Do test names describe what they verify?
- **Comments**: Are there redundant or obvious comments?
- **Structure**: Is the Arrange-Act-Assert pattern clear?

### Step 3: Generate Compliance Report

To create the validation report, structure findings as follows:

````markdown
# Test Compliance Validation Report

## Summary

- **Total Violations Found**: [count]
- **Critical**: [count] | **High**: [count] | **Medium**: [count]
- **Verdict**: [FAIL if any CRITICAL, WARN if HIGH, PASS otherwise]

## Critical Violations

### 1. [Violation Type]

**File**: [filename:line]
**Issue**: [specific problem]
**Impact**: [why this breaks test validity]
**Fix**:

```[language]
// Current (incorrect)
[bad code]

// Suggested (correct)
[good code]
```
````

## High Priority Issues

[Similar format for HIGH violations]

## Medium Priority Issues

[Similar format for MEDIUM violations]

## Positive Findings

- ✅ [Things done correctly]

## Recommendations

1. [Specific action items in priority order]

```

### Step 4: Verify Against Universal Principles

To ensure universal applicability across languages and frameworks:

**Language-Agnostic Principles to Check:**

1. **Mock Boundary Rule**: Only mock what you don't own
2. **Assertion Reality Rule**: Assert on outcomes, not logs
3. **Failure Proof Rule**: Test must fail when code is broken
4. **Independence Rule**: Tests run in any order
5. **Clarity Rule**: Test intent is immediately obvious

### Step 5: Provide Actionable Fixes

To make the report actionable, for each violation provide:

1. **Specific code example** showing the issue
2. **Concrete fix** with actual code (not just description)
3. **Explanation** of why the fix addresses the issue
4. **Verification method** to confirm the fix works

## Quick Reference Checklists

### Pre-Validation Checklist
- [ ] Tests are present in context or recently added
- [ ] Test type identified (unit/integration/BDD)
- [ ] Framework identified
- [ ] External dependencies identified

### Critical Violation Checklist
- [ ] **No mocked application code** - Only external APIs mocked
- [ ] **No log assertions** - Tests verify actual behavior
- [ ] **Can fail** - Test fails when implementation broken
- [ ] **Real infrastructure** - Uses actual DB/queue/cache or proper test doubles
- [ ] **Has assertions** - Every test verifies something meaningful

### Code Quality Checklist
- [ ] **No dead code** - All helpers used, no commented tests
- [ ] **No duplication** - Tests don't repeat same verification
- [ ] **Clear naming** - Test names describe what they verify
- [ ] **No redundant comments** - Comments add value, not noise
- [ ] **Clean structure** - Arrange-Act-Assert pattern visible

### Anti-Pattern Checklist
- [ ] **No testing test infrastructure** - Not verifying test helpers work
- [ ] **No magic values** - Test data contracts are explicit
- [ ] **No hardcoded success** - Tests don't fake passing
- [ ] **No over-mocking** - In-process components use real instances
- [ ] **No implicit contracts** - Data relationships are clear

## References

Bundled reference documents provide detailed examples and patterns:
- `references/anti-patterns.md` - Common test anti-patterns with examples
- `references/good-patterns.md` - Correct testing patterns by language
- `references/severity-guide.md` - Detailed severity classification guide
```
