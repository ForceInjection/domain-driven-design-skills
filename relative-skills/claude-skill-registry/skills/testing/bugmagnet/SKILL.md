---
name: bugmagnet
description: Discover edge cases and test coverage gaps through systematic analysis. Use when analysing test coverage, finding bugs, hunting for edge cases, or when code-reviewer identifies test gaps.
---

# BugMagnet

Systematic test coverage analysis and bug discovery workflow.

Based on [gojko/bugmagnet-ai-assistant](https://github.com/gojko/bugmagnet-ai-assistant).

## When to Use

- Analysing test coverage for a module
- Finding edge cases and potential bugs
- When code-reviewer identifies test gaps
- Before releasing critical functionality

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  🔍 ANALYSE  → Understand code and existing tests          │
│  📊 GAP      → Identify missing coverage                   │
│  ✍️  WRITE    → Implement tests iteratively                │
│  🔬 ADVANCED → Deep edge case exploration                  │
│  📋 SUMMARY  → Document findings and bugs                  │
└─────────────────────────────────────────────────────────────┘
```

**STOP and wait for user confirmation between phases.**

---

## Phase 1: Initial Analysis (🔍 ANALYSE)

1. **Detect language and testing conventions** from file extension and project structure
2. **Read implementation file** — understand public API, parameters, state, dependencies
3. **Locate test file** — if none exists, ask user about creating one
4. **Check coverage tools** — run baseline coverage if available
5. **Read existing tests** — understand current coverage and patterns
6. **Check project guidelines** — README, CONTRIBUTING for testing conventions
7. **Ask user** — "Are there additional files I should review?"

**STOP** — Wait for user input before proceeding.

---

## Phase 2: Gap Analysis (📊 GAP)

1. **Evaluate missing coverage** using [edge-cases.md](references/edge-cases.md) checklist:
   - Boundary conditions
   - Error paths
   - State transitions
   - Complex interactions
   - Domain-specific edge cases
   - Violated domain constraints

2. **Categorise by priority:**
   - **High:** Core functionality, error handling, boundaries
   - **Medium:** Complex interactions, state management
   - **Low:** Rare edge cases, performance

3. **Present analysis to user** with specific examples

**STOP** — Ask user which tests to implement.

4. **Clarify undecided behaviour** for any gaps with unclear expectations

---

## Phase 3: Iterative Test Implementation (✍️ WRITE)

For each test:

1. **Pick highest priority** from the list
2. **Write single test** (or 2-3 related tests)
3. **Name describes outcome:** "returns X when Y", "throws error when Z"
4. **Run immediately**

### Handling Failures

- **Test expectation wrong:** Update test
- **Bug discovered:** Create skipped test with documentation
- **Need more context:** Try 2 more variations

### When Bug Found

- Create minimal reproduction
- Explore surrounding territory (bugs cluster)
- Document in skipped test — **DO NOT FIX, only document**

### Bug Documentation Format

```
test.skip('feature returns wrong value - BUG', () => {
    /*
     * BUG: Brief description
     * ROOT CAUSE: Analysis
     * CODE LOCATION: file.js:42
     * CURRENT CODE: snippet
     * PROPOSED FIX: snippet
     * EXPECTED: value
     * ACTUAL: value
     */
    // Failing assertion here
});
```

**Maximum 3 attempts per test** — document and move on if stuck.

**STOP** — Ask user if they want advanced coverage (Phase 4).

---

## Phase 4: Advanced Coverage (🔬 ADVANCED)

Create separate test suite: "bugmagnet session <date>"

Use [edge-cases.md](references/edge-cases.md) for comprehensive coverage:

1. **Complex interactions** — multiple features, state across operations
2. **Error handling** — specific messages, context preservation
3. **Numeric edge cases** — zero, boundaries, special values
4. **Date/time edge cases** — leap years, DST, timezones
5. **String edge cases** — unicode, whitespace, length
6. **Collection edge cases** — empty, nested, duplicates
7. **State transitions** — order, repetition, invalid states
8. **Domain-specific** — names, emails, URLs, security

---

## Phase 5: Summary (📋 SUMMARY)

```markdown
## Test Coverage Summary

**Tests Added: X total**
- Category 1 (Y tests)
- Category 2 (Z tests)

**Final Count:**
- X passing tests
- Y skipped tests (bugs documented)

**Bugs Discovered:**
1. Bug name - file.js:line
   - Root cause: ...
   - Proposed fix: ...
```

---

## Test Writing Guidelines

### Naming

- **GOOD:** "returns chunks without error when text contains newlines"
- **BAD:** "handles newline characters"

### Assertions Must Match Title

- If testing "creates objects with different IDs" → verify IDs differ
- If testing "preserves order" → check actual order
- Avoid indirect checks (length when you should check values)

### Structure

- Arrange-Act-Assert pattern
- One assertion per concept
- Full expected values, not partial matches

### Bug Clusters

When you find one bug, look for similar bugs nearby:
- Try related edge cases
- Check similar properties
- Test related contexts

---

## Reference Files

- [Edge Case Checklist](references/edge-cases.md) — Comprehensive checklist by type
