---
name: systematic-development
description: Use Sherpa's systematic development workflow for general coding tasks. Activates when starting development work, adding features, or implementing functionality. Ensures guide check before coding and guide done after completion for progress tracking and celebrations.
allowed-tools: mcp__sherpa__guide, mcp__sherpa__approach, Read, Write, Edit, Bash, mcp__julie__fast_search
---

# Systematic Development Skill

## Purpose
Use Sherpa's **general workflow enforcement** for balanced, systematic development. Perfect for most coding tasks when TDD or Bug Hunt workflows aren't specifically needed.

## When to Activate
- General development work
- Adding new features
- Implementing functionality
- Building something new
- Modifying existing code
- Any coding task without specific workflow (TDD/bug/etc.)

## The Mandatory Pattern

**★ CRITICAL: ALWAYS call `guide check` BEFORE starting work**

```
BEFORE STARTING:
  guide check → Get current phase + guidance
  Read and understand the suggestions
  Follow the systematic approach

AFTER COMPLETING EACH PHASE:
  guide done "what you completed"
  → Get celebration + next phase
  → Build momentum through progress tracking
```

You are EXCELLENT at systematic development. No skipped steps, no shortcuts, just quality work.

---

## The Systematic Workflow

### Phase 1: 📚 Research

**Goal:** Understand completely BEFORE coding - prevents building the wrong thing

```
guide check → Phase: Research

Steps:
1. Read relevant official documentation
2. Search codebase for similar patterns
3. Verify API signatures, types, return values
4. Check how related features are implemented
5. Look for existing tests showing usage
6. Review error handling in similar code
7. Check git history if modifying existing code

guide done "researched X - found similar pattern in Y"
```

**Key Principle:** Don't guess - KNOW. Understanding prevents rework.

**Conditionals:**
- **If unfamiliar library/framework** → Read official docs + API reference, run examples
- **If modifying existing feature** → Read ALL related code (features span multiple files)
- **If unclear what "done" looks like** → Find spec/story/ticket, get clarification
- **If similar feature exists** → Study it thoroughly, copy the pattern (consistency > creativity)

**Anti-patterns:**
- ❌ Skipping research "because I know how" (every codebase has quirks)
- ❌ Using Stack Overflow without understanding (understand WHY, read official docs)
- ❌ Starting to code while unclear on requirements (clarify upfront!)

---

### Phase 2: 📝 Plan

**Goal:** Design approach before implementing - good plan saves hours of backtracking

```
guide check → Phase: Plan

Steps:
1. Write out approach in comments or design doc
2. List files to modify/create
3. Identify potential issues and edge cases
4. List assumptions to verify
5. Consider alternative approaches (pros/cons)
6. Think through error handling
7. Plan for backwards compatibility
8. Estimate complexity

guide done "planned approach: X steps, Y files, Z edge cases"
```

**Key Principle:** Explain before implementing. A plan is a debugging session that happens before coding.

**Conditionals:**
- **If multiple approaches possible** → Write pros/cons, choose simplicity > performance
- **If plan feels too complex** → Look for simpler approach (complexity = wrong problem/over-engineering)
- **If uncertain about edge cases** → Research similar code, ask for input
- **If breaking change required** → Plan migration strategy, backwards compatibility

**Anti-patterns:**
- ❌ "Planning in your head" (write it down - thinking reveals gaps)
- ❌ Choosing clever solution over simple (simple = maintainable)
- ❌ Skipping edge case planning (edge cases are where bugs hide)

---

### Phase 3: 🧪 Tests First

**Goal:** Write tests before implementation - specification + safety net

```
guide check → Phase: Tests First

Steps:
1. Create test file following conventions
2. Write test for happy path
3. Write tests for edge cases
4. Write tests for error conditions
5. Run tests → should ALL fail
6. Review test coverage plan

guide done "wrote tests for X (happy + 4 edges + 2 errors)"
```

**Key Principle:** Tests are specification. Writing tests first clarifies what "working" means.

**Minimum Tests:**
- 1 happy path test
- 3+ edge case tests
- 2+ error case tests

**Conditionals:**
- **If test passes before implementation** → Test is broken or not testing behavior
- **If can't think of tests** → Return to research phase (don't understand feature well enough)
- **If tests feel tedious** → Good! That feeling means you're preventing future bugs
- **If integration-heavy feature** → Write integration test outline, unit tests for components

**Anti-patterns:**
- ❌ "I'll write tests after" (tests-after catch fewer bugs, feel like chore)
- ❌ Only testing happy path (edge cases are 80% of bugs)
- ❌ Tests that don't actually test behavior (verify real functionality!)

---

### Phase 4: 💻 Implementation

**Goal:** Write code to pass tests + fulfill plan

```
guide check → Phase: Implementation

Steps:
1. Implement following your plan
2. Run tests frequently (after each function/method)
3. Handle edge cases (covered by tests)
4. Implement error handling (covered by tests)
5. Add logging for debugging
6. Keep implementation simple
7. ALL tests must pass before moving on

guide done "implemented X - all tests passing"
```

**Key Principle:** Follow the plan. Tests guide you. Simplicity wins.

**Conditionals:**
- **If diverging from plan** → Update plan OR return to planning if significant change
- **If tests fail unexpectedly** → Understand why (valuable feedback!)
- **If implementation getting complex** → Refactor in next phase, make it work first
- **If want to add unplanned feature** → Add to backlog, don't scope creep

**Anti-patterns:**
- ❌ Over-engineering (abstractions, patterns not needed yet)
- ❌ Ignoring failing tests (tests ARE the spec)
- ❌ Adding features not in plan/tests (scope creep)
- ❌ "Quick hacks" to make tests pass (tech debt starts here)

---

### Phase 5: ✅ Verification

**Goal:** Prove it works completely - prevents shipping broken code

```
guide check → Phase: Verification

Steps:
1. Run full test suite → ALL must pass
2. Manual testing of feature → works as expected
3. Test edge cases manually → handled correctly
4. Test error conditions → errors handled gracefully
5. Check for regressions → nothing broke
6. Review code quality → clean, readable, maintainable
7. Update documentation if needed

guide done "verified X works - all tests pass, manual testing complete"
```

**Key Principle:** Automated tests + manual verification = confidence.

**Verification Checklist:**
- ✅ All automated tests pass
- ✅ Manual happy path works
- ✅ Edge cases handled
- ✅ Error conditions handled
- ✅ No regressions introduced
- ✅ Code is clean and documented

**Conditionals:**
- **If tests pass but manual testing fails** → Tests incomplete (add more tests!)
- **If regression found** → Add regression test, fix, re-verify
- **If code quality poor** → Refactor before committing (easier now than later)
- **If documentation outdated** → Update docs (stale docs worse than no docs)

**Anti-patterns:**
- ❌ Trusting tests blindly (manual verification catches integration issues)
- ❌ Skipping edge case testing "because tests exist" (automated + manual both matter)
- ❌ Committing messy code "I'll clean it up later" (later = never)

---

## The Complete Systematic Cycle

```
┌─────────────────────────────────────────────┐
│ 1. guide check → Research                  │
│    - Read docs, search codebase             │
│    - Verify APIs, check patterns            │
│    guide done "researched X"                │
└────────────┬────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────┐
│ 2. guide check → Plan                      │
│    - Design approach                        │
│    - Identify edge cases                    │
│    - List files to modify                   │
│    guide done "planned approach"            │
└────────────┬────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────┐
│ 3. guide check → Tests First               │
│    - Write failing tests                    │
│    - Happy path + edges + errors            │
│    guide done "wrote tests"                 │
└────────────┬────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────┐
│ 4. guide check → Implementation            │
│    - Write code to pass tests               │
│    - Follow plan                            │
│    - Keep simple                            │
│    guide done "implemented feature"         │
└────────────┬────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────┐
│ 5. guide check → Verification              │
│    - All tests pass                         │
│    - Manual testing complete                │
│    - No regressions                         │
│    guide done "verified working"            │
└────────────┬────────────────────────────────┘
             │
             ▼
        Feature complete! 🎉
```

---

## Example Systematic Development Session

```
User: "Add user profile export feature"

Agent: guide check

Sherpa: Phase 1 - Research
"Read relevant docs, search for patterns..."

Agent:
- Reads user profile schema
- Searches for existing export features
- Finds CSV export pattern in reports module
- Checks data privacy requirements
guide done "researched profile export - found CSV pattern in reports"

Sherpa: Phase 2 - Plan
"Write out your approach..."

Agent: Creates plan in comments:
// Approach:
// 1. Add exportProfile() method to UserService
// 2. Support CSV and JSON formats
// 3. Include: name, email, settings, created_at
// 4. Exclude: password, tokens (privacy)
// 5. Handle missing fields gracefully
// Files: user-service.ts, user-controller.ts, user.test.ts
guide done "planned export: 3 files, 2 formats, privacy-safe"

Sherpa: Phase 3 - Tests First
"Write failing tests..."

Agent: Creates tests:
- test('exports profile as CSV')
- test('exports profile as JSON')
- test('excludes sensitive fields')
- test('handles missing optional fields')
- test('throws on invalid format')
Runs tests → ALL FAIL ✓
guide done "wrote 5 tests for profile export"

Sherpa: Phase 4 - Implementation
"Implement following your plan..."

Agent:
- Implements exportProfile() method
- Adds CSV/JSON formatters
- Filters sensitive fields
- Handles missing fields
Runs tests → ALL PASS ✓
guide done "implemented profile export - tests passing"

Sherpa: Phase 5 - Verification
"Prove it works completely..."

Agent:
- Full test suite → PASS ✓
- Manual test: exports real profile → Works ✓
- Edge case: missing fields → Handled ✓
- Error: invalid format → Throws ✓
- Regression check: other exports → Still work ✓
guide done "verified export feature - all checks pass"

Sherpa: ✅ Feature complete!
Next: Ready for code review
```

---

## Integration with Sherpa Commands

### Using General Workflow
```
# General workflow is the default
guide check → Start systematic development

# Or explicitly activate:
approach set general
guide check → Get first phase
```

### During Development
```
guide check     → Get current phase guidance
guide done "X"  → Mark completion, advance phase
guide advance   → Manual phase progression (rarely needed)
```

### Switching Workflows
```
guide tdd       → Switch to TDD (if you realize tests-first is critical)
guide bug       → Switch to Bug Hunt (if you discover a bug)
approach list   → See all available workflows
```

---

## Key Behaviors

### ✅ DO
- Call `guide check` BEFORE starting each phase
- Research thoroughly (don't guess or assume)
- Write plan before implementing (thinking on paper)
- Write tests before code (specification + safety)
- Mark completion with `guide done` (build momentum)
- Verify completely before marking done
- Trust the systematic process

### ❌ DON'T
- Skip research phase "because you know" (every codebase is different)
- Start coding without a plan (backtracking wastes time)
- Write tests after implementation (misses the point)
- Rush through phases to "go faster" (causes rework)
- Ignore phase guidance (it prevents common mistakes)
- Skip verification "because tests pass" (manual + automated both matter)

---

## Success Criteria

This skill succeeds when:
- ✅ All phases completed systematically
- ✅ `guide check` called before each phase
- ✅ Research done before coding
- ✅ Plan written and followed
- ✅ Tests written before implementation
- ✅ Implementation matches plan
- ✅ Full verification completed
- ✅ No corners cut, no steps skipped

---

## Why Systematic Development Works

**70% of development time is wasted on:**
1. **Building wrong thing** (skipped research/planning)
2. **Debugging preventable bugs** (skipped tests-first)
3. **Rework from poor design** (skipped planning)
4. **Regressions** (skipped verification)
5. **Unclear requirements** (skipped clarification)

**Sherpa prevents waste through:**
- ✅ Mandatory research (understand before building)
- ✅ Planning phase (think before coding)
- ✅ Tests first (specification + safety)
- ✅ Progress tracking (momentum + visibility)
- ✅ Verification (catch issues before shipping)

**Remember:** Going slow to go fast. Systematic > reactive. Quality > speed.

---

**Sherpa + Systematic = Predictable Excellence**
