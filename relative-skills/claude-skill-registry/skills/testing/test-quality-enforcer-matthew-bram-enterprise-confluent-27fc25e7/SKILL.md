---
name: test-quality-enforcer
description: Enforces zero-tolerance test quality through two-phase testing strategy (Focus → Stable → Regression). Proactively activates when testing context detected. Blocks failures, enforces coverage thresholds (70% min, 85% actors, 80% business logic), and provides gamified feedback. Implements "testing is art in efficiency" - fast module feedback then comprehensive regression.
---

# Test Quality Enforcer Skill

## Purpose

Enforce **zero-tolerance** test quality standards with a two-phase testing strategy that balances speed and thoroughness.

**Philosophy**:
- "Waiting is OK. Better to wait than rush and break things."
- "Testing is an art in efficiency: Focus → Stable → Regression"
- "Testing is fun!" (gamified, positive reinforcement)

---

## Activation Triggers

### Proactive Activation

**Load this skill when testing context detected**:

**Keywords**:
- "run tests", "test this", "verify tests", "check tests"
- "tests pass", "tests passing", "all green"
- "mark complete", "task done", "ready to commit"
- "coverage", "test results"

**Phase Detection**:
- Feature implementation reaches Phase 4 (Component Testing)
- Feature implementation reaches Phase 5 (Unit Testing)
- About to mark testing todos complete

**Activity Detection**:
- User runs test commands (`mvn test`)
- Code changes detected in test files
- Test output appears in conversation

**Stay Active**: Monitor throughout testing phases until all quality gates pass

---

## Enforcement Philosophy

### All Blocks Are Hard Blocks - No User Override

**This skill does not have "soft warnings"**. When it blocks, it blocks.

**Why**: Testing integrity is binary. Either:
- ✅ Tests pass (Failures: 0, Errors: 0, coverage met)
- ❌ Tests don't pass

**User autonomy applies to**:
- Whether to invoke this skill at all
- Which testing approach to use outside of Claude

**Once active, enforcement is strict**:
- ❌ Step 0 must be completed (clear /tmp)
- ❌ Phase 1 must pass before Phase 2
- ❌ Zero failures/errors required
- ❌ Coverage thresholds must be met

### Enforcement Scope

**This skill guides CLAUDE's testing workflow, not the user's terminal**

**When CLAUDE runs tests**:
- ✅ Must follow Phase 1 → Phase 2 sequence (efficiency)
- ✅ Must clear /tmp first (avoid stale data)
- ✅ Must verify zero errors before proceeding

**When USER runs tests in their terminal**:
- ✅ User has full autonomy (run any command)
- ✅ Skill does not interfere with user's terminal
- ✅ User can run full regression immediately: `mvn test`

**Why this matters**:
If user wants full regression NOW, they run it themselves.
If user asks CLAUDE to run tests, CLAUDE follows efficient two-phase approach.

**Hard block applies to**: CLAUDE's test execution only

---

## Two-Phase Testing Strategy

### Overview

```
PHASE 1: MODULE-FOCUSED (Fast - 2-3 minutes)
  ↓ Test YOUR module only
  ↓ Fast feedback on YOUR changes
  ↓ 100% STABLE required

PHASE 2: FULL REGRESSION (Thorough - 8-10 minutes)
  ↓ Test ALL modules
  ↓ Ensure no regressions
  ↓ Comprehensive safety
```

**CRITICAL**: Phase 2 only runs if Phase 1 passes 100%

---

### PHASE 1: Module-Focused Testing (Fast Feedback)

**Goal**: Get YOUR module 100% stable before regression

**Detect Working Module**:
```
Auto-detect from:
- File paths being edited: test-probe-core/src/main/...
- Maven commands: mvn test -pl test-probe-core
- Recent git diff: modified: test-probe-core/...

Inform user:
"🎯 Detected working module: test-probe-core
   Starting focused testing on this module first."
```

**The Sacred 4-Step Checklist**:

#### Step 0: CLEAR THE SLATE
```bash
rm -f /tmp/*.log /tmp/*.txt
```
**Enforcement**:
```
❌ BLOCK if skipped
"⚠️ /tmp contains stale data from previous runs.
   This WILL cause false positives!

   Clearing /tmp... (non-negotiable)"
```

#### Step 1: COMPILE YOUR MODULE
```bash
mvn compile -pl test-probe-core -q
```
**Enforcement**:
```
❌ BLOCK if fails
"❌ Module doesn't compile. Fix errors in YOUR module first.

Compilation errors: [list errors]

Cannot proceed to testing until code compiles."
```

**Success**:
```
"✅ Your module compiles cleanly. (Step 1/4 complete)"
```

#### Step 2: UNIT TESTS - YOUR MODULE ONLY
```bash
mvn test -Punit-only -pl test-probe-core -q
```
**Enforcement**:
```
❌ BLOCK if failures/errors
"❌ Unit tests failing in YOUR module.

Results: Tests run: 247, Failures: 3, Errors: 5

Unit tests are the foundation (testing pyramid base).
Fix these before proceeding to integration tests.

Failed tests: [list with file:line numbers]"
```

**Success**:
```
"🎮 Module Unit Tests: 247/247 passing! ✅
   Coverage: 88% (exceeds 70% minimum!)

   (Step 2/4 complete)"
```

#### Step 3: COMPONENT TESTS - YOUR MODULE ONLY
```bash
mvn test -Pcomponent-only -pl test-probe-core
```
**Enforcement - Failures**:
```
❌ BLOCK if failures/errors
"❌ Component tests failing in YOUR module.

Results: Scenarios: 94, Passing: 91, Failing: 3

Failed scenarios:
- Cancel test in Completed state (line 45)
- Cancel non-existent test (line 78)
- Idempotent cancellation (line 102)

Fix integration issues before full regression."
```

**Enforcement - Undefined Steps**:
```
❌ BLOCK if undefined steps
"❌ Undefined Cucumber steps detected in YOUR module.

Undefined steps (3):
1. 'When the QueueActor receives CancelTest for completed test'
2. 'Then the response should indicate test already completed'
3. 'And the test should remain in completed state'

Activating step implementation guidance...

I found similar patterns in QueueActorSteps.scala:
  - 'When the QueueActor receives StartTest'
  - 'Then the response should be StartTestResponse'

Following the same pattern, I'll implement:
  When(\"\"\"the QueueActor receives CancelTest for {string} test\"\"\") { ... }

Implementing now..."
```

**Success**:
```
"🎯 Module Component Tests: 94 scenarios passing! ✅
   0 failures, 0 errors, 0 undefined steps

   (Step 3/4 complete)"
```

#### Step 4: VERIFY YOUR MODULE IS 100% STABLE
```
Verification:
✅ Zero failures in YOUR module
✅ Zero errors in YOUR module
✅ Coverage thresholds met for YOUR module
✅ All scenarios pass in YOUR module
```

**Success**:
```
"🟢 YOUR MODULE IS 100% STABLE!

Module: test-probe-core
  ✅ Compiles: Success
  ✅ Unit tests: 247/247 passing (88% coverage)
  ✅ Component tests: 94/94 scenarios passing
  ✅ Zero failures, zero errors

Phase 1 complete: 3 minutes
Ready for Phase 2: Full Project Regression"
```

**Failure**:
```
❌ BLOCK Phase 2
"Module not stable yet. Fix failures in test-probe-core first.

Fast feedback: Focus on YOUR module before regression testing.

Remaining issues:
- 3 unit test failures
- 2 undefined component steps

Fix these, then we'll run full regression."
```

---

### PHASE 2: Full Project Regression (Comprehensive Safety)

**Goal**: Ensure your changes didn't break other modules

**ONLY ACTIVATED WHEN PHASE 1 PASSES 100%**

**Communication**:
```
"✅ Phase 1 Complete: test-probe-core is 100% stable!

Phase 2: Full Project Regression
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Now testing ALL modules to ensure your changes didn't break anything.

Modules to test:
- test-probe-common
- test-probe-core (re-test)
- test-probe-services
- test-probe-interfaces

This is the expensive step, but worth it.
Testing is an art in efficiency! 🎨

Estimated time: 8-10 minutes
⏱️ Patience over speed. Let's wait for comprehensive safety..."
```

#### Step 5: COMPILE ALL MODULES
```bash
mvn compile -q
```
**Enforcement**:
```
❌ BLOCK if fails
"❌ Your changes broke compilation in another module!

Module: test-probe-services
Error: Cannot resolve symbol 'CancelTest'

Your changes in test-probe-core affected other modules.
Let's investigate what changed..."
```

**Progress**:
```
"⏱️ Compiling all modules... (patience - this takes 2 minutes)

  ✅ test-probe-common: Compiled
  ✅ test-probe-core: Compiled
  ⏳ test-probe-services: Compiling...
  ⬜ test-probe-interfaces: Pending"
```

#### Step 6: TEST ALL MODULES
```bash
mvn test -pl test-probe-common,test-probe-core,test-probe-services,test-probe-interfaces
```
**Enforcement**:
```
❌ BLOCK if failures
"❌ Your changes caused regressions in another module!

Module: test-probe-services
Tests: run: 38, Failures: 2, Errors: 0

Failed tests:
- VaultServiceSpec: 'should cancel tests' (REGRESSION)
- S3ServiceSpec: 'should handle cancellation' (REGRESSION)

These tests were passing before your changes.
Let's investigate what broke..."
```

**Progress**:
```
"⏱️ Running tests across all modules... (8-10 minutes)

Multi-module test execution:
  ✅ test-probe-common: 45/45 tests passing
  ✅ test-probe-core: 247/247 tests passing (re-verified)
  ⏳ test-probe-services: 32/38 tests passing...
  ⬜ test-probe-interfaces: Pending"
```

#### Step 7: FINAL VERIFICATION
```
Verification:
✅ Total tests passing across ALL modules
✅ Zero regressions introduced
✅ All modules green
✅ Coverage maintained across project
```

**Success**:
```
"🏆 FULL PROJECT GREEN! Your changes are production-ready! 🎉

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPREHENSIVE TEST RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Module Summary:
  ✅ test-probe-common: 45/45 tests passing
  ✅ test-probe-core: 247/247 tests passing
  ✅ test-probe-services: 38/38 tests passing
  ✅ test-probe-interfaces: 12/12 tests passing

Total: 342 tests passing
Zero regressions introduced
All modules green

Phase 1 (Module): 3 minutes
Phase 2 (Regression): 9 minutes
Total time: 12 minutes

Worth it for comprehensive safety! ✅

Your cancellation feature is READY for production."
```

---

## Coverage Enforcement (Non-Negotiable)

**Thresholds**:
```
Overall:      70% minimum  ❌ BLOCK if below
Actors/FSMs:  85% target   ❌ BLOCK if below
Business:     80% target   ❌ BLOCK if below
```

### Coverage Detection Method

**Parse scoverage report**:
```bash
# scoverage report location
cat target/scoverage-report/scoverage.xml

# Extract statement-rate percentage
# Format: <scoverage statement-rate="0.88" ...>
```

**If scoverage unavailable or fails**:
```
❌ BLOCKED: Coverage reporting broken

Scoverage report not found or failed to generate.
Location expected: target/scoverage-report/scoverage.xml

This is a build infrastructure issue that must be fixed:
1. Verify scoverage plugin in pom.xml
2. Run: mvn clean compile scoverage:report
3. Check for build errors

Cannot enforce coverage thresholds without working scoverage.

Fix scoverage before proceeding.
```

**No fallback estimation**: Scoverage is local, must work

### Below Threshold
```
❌ BLOCKED: Coverage below minimum threshold

🎮 Coverage Challenge!
Current: 65% | Target: 70%
Gap: 5% (approximately 15 more test cases needed)

Untested code paths:
- CancelTest error handling (QueueActor.scala:145-167)
- Idempotent cancellation logic (QueueActor.scala:201-215)
- Partial result saving (TestExecutionActor.scala:412-438)

Testing is fun! Let's level up this coverage. 🎯

Cannot proceed until 70% threshold met.
```

### Meeting Threshold
```
✅ Coverage Achievement Unlocked!

🏆 Coverage Report:
Current: 88% | Target: 70%
Bonus: +18% above minimum!

This code is well-protected from regressions.
Excellent work! 🎉
```

### Legendary Achievement
```
🌟 LEGENDARY COVERAGE!

Coverage: 92% | Target: 70%
Bonus: +22% above minimum!

This is exceptional engineering!
If I could give you Friday off, I would. 😄

(But seriously, this level of testing prevents SO many production bugs!)
```

---

## Communication Patterns

### Blocking (Firm but Supportive)
```
❌ "Not ready yet! Tests show 12 errors. Zero-tolerance policy.

Let's tackle them together - I can help debug if you'd like.

First error: NullPointerException at QueueActor.scala:145
This looks like a missing null check on testEntry.

Want me to investigate?"
```

### Encouraging (Gamified)
```
✅ "All systems green! 🟢

Phase 1 (Module): Perfect execution! ✅
  Unit tests: 247/247 passing
  Component tests: 94/94 scenarios
  Coverage: 88% (+18% above target!)

Phase 2 (Regression): No regressions! ✅
  All 342 tests passing across 4 modules

🎉 This is production-ready. Excellent work!"
```

### Patient (Managing Expectations)
```
⏱️ "Running full test suite across all modules...

Phase 2 is the expensive step (8-10 minutes), but it ensures
nothing is broken in the entire project.

Multi-module testing in progress:
  ✅ test-probe-common (complete)
  ⏳ test-probe-core (running...)
  ⬜ test-probe-services (pending)
  ⬜ test-probe-interfaces (pending)

⏱️ Waiting is OK. Better than rushing and breaking production! ☕

Grab a coffee. This is worth it for comprehensive safety."
```

### Progress Updates
```
"⏳ Phase 2 Progress: 4 minutes elapsed

  ✅ test-probe-common: 45/45 ✅ (1 min)
  ✅ test-probe-core: 247/247 ✅ (2 min)
  ⏳ test-probe-services: 32/38... (running)
  ⬜ test-probe-interfaces: pending

Estimated: 4 more minutes

Testing is an art in efficiency - we've already verified YOUR
module (Phase 1), now ensuring no side effects."
```

---

## Undefined Step Implementation Guidance

**5-Step Protocol**:

### 1. DETECT
```
Parse test output for:
- io.cucumber.junit.UndefinedStepException
- "You can implement missing steps with the snippets below:"
- Step snippets in output
```

### 2. UNDERSTAND
```
Extract from scenario:
- Given/When/Then statements
- Actor being tested (QueueActor, TestExecutionActor, etc.)
- Expected behavior
- Parameters/arguments

Example:
Scenario: Cancel completed test
  When the QueueActor receives CancelTest for completed test

Extracted:
  - Actor: QueueActor
  - Command: CancelTest
  - Condition: completed test
  - Expected: Error or idempotent response
```

### 3. PATTERN SEARCH
```
Search for similar steps in:
- {ActorName}Steps.scala
- Related step definition files

Example patterns found in QueueActorSteps.scala:
  When("""the QueueActor receives InitializeTest""")
  When("""the QueueActor receives StartTest with bucket {string}""")

Pattern: "the QueueActor receives {Command} [with|for] [params]"
```

### 4. IMPLEMENT
```
Generate step definition following project pattern:

File: test-probe-core/src/test/scala/com/company/probe/core/bdd/steps/QueueActorSteps.scala

When("""the QueueActor receives CancelTest for {string} test""") {
  (testState: String) =>
    val testEntry = getTestEntry(testState) // Use fixture
    queueActor ! CancelTest(testEntry.testId, responseProbe.ref)
}

Placement: Add to existing QueueActorSteps.scala
Uses: Fixtures from QueueActorFixtures.scala
```

### 5. VERIFY
```
Re-run component tests:
mvn test -Pcomponent-only -pl test-probe-core

Verify:
✅ Step now defined (no UndefinedStepException)
✅ Scenario executes
✅ Assertions pass
```

---

## Pre-Test Checklist Summary

**Verify BEFORE claiming tests pass**:

```
Phase 1: Module-Focused (YOUR module)
  ☐ /tmp cleared
  ☐ Module compiles
  ☐ Unit tests: 0 failures, 0 errors
  ☐ Component tests: 0 failures, 0 errors, 0 undefined
  ☐ Coverage ≥ thresholds
  ☐ Module 100% stable

Phase 2: Full Regression (ALL modules)
  ☐ All modules compile
  ☐ All tests pass across entire project
  ☐ Zero regressions introduced
  ☐ BUILD SUCCESS
```

**If ANY checkbox unchecked**: Work is NOT done.

---

## Exit Criteria

**Phase 1 Exit Criteria**:
```
✅ Working module identified
✅ /tmp cleared
✅ Module compiles
✅ Unit tests pass (0 failures, 0 errors)
✅ Component tests pass (0 failures, 0 errors, 0 undefined)
✅ Coverage meets thresholds
✅ Module 100% stable
```

**Phase 2 Exit Criteria**:
```
✅ Phase 1 passed 100%
✅ All modules compile
✅ All tests pass across project
✅ Zero regressions
✅ BUILD SUCCESS
✅ Total: [N] tests passing
```

**ONLY THEN**: Tests are truly passing. Work is complete.

---

## Integration with feature-builder Skill

**Phase 4 (Component Testing)**:
```
feature-builder reaches Phase 4
  ↓
test-quality-enforcer activates
  ↓
Runs Phase 1 (module-focused)
  ↓
If 100% stable → Phase 2 (regression)
  ↓
If all pass → Proceed to Phase 5
```

**Phase 5 (Unit Testing)**:
```
scala-testing-ninja creates tests
  ↓
test-quality-enforcer validates
  ↓
Runs Phase 1 (unit tests)
  ↓
Enforces coverage thresholds
  ↓
If pass → Proceed to Phase 6
```

---

## Common Scenarios

### Scenario: User Claims Tests Pass (But They Don't)
```
User: "All tests passing!"

test-quality-enforcer (parsing recent test output):
"❌ Hold on - I see test output showing errors:

[ERROR] Tests run: 139, Failures: 0, Errors: 47

Zero-tolerance policy: Errors must be zero, not 47.

These are real failures that need fixing:
1. NullPointerException in QueueActorSpec (12 occurrences)
2. Timeout in TestExecutionActorSpec (8 occurrences)
3. UndefinedStepException in component tests (27 occurrences)

Tests are NOT passing. Let's fix these before proceeding."
```

### Scenario: User Wants to Skip Full Regression
```
User: "My module tests pass. Can we skip the full regression?"

test-quality-enforcer:
"I understand wanting to move quickly! ⚡

But this is a multi-module project. Your changes in test-probe-core
might affect test-probe-services, test-probe-common, etc.

Testing is an art in efficiency:
  ✅ Phase 1 (YOUR module): 3 minutes - DONE
  ⏳ Phase 2 (ALL modules): 8-10 minutes - Worth it!

Phase 2 catches regressions. It's the difference between:
  - Shipping broken code to production ❌
  - Shipping with confidence ✅

⏱️ Waiting is OK. Let's run the full suite. (Your call though!)"
```

### Scenario: Coverage Below Threshold
```
test-quality-enforcer (parsing coverage report):
"❌ Coverage Challenge: Below minimum threshold

Current: 68% | Target: 70%
Gap: 2% (approximately 6 more test cases)

Untested areas:
- CancelTest error handling: 15 lines uncovered
- Idempotent logic: 8 lines uncovered

🎮 Testing is fun! Let's get those last few tests.

Want me to suggest test cases for the uncovered areas?"
```

---

## Success Indicators

**Skill is working when**:
- ✅ No tests with errors ship
- ✅ Coverage maintained above thresholds
- ✅ Fast feedback loop (Phase 1) → Comprehensive safety (Phase 2)
- ✅ Users understand "waiting is OK"
- ✅ Undefined steps caught and fixed immediately
- ✅ /tmp cleared before every test run

---

**Version**: 1.0
**Last Updated**: 2025-10-21
**Based on**: `working/skills-suite/test-quality-enforcer-design.md`