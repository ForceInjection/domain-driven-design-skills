---
name: visibility-pattern-guardian
description: Enforces visibility pattern for testability by detecting private methods that prevent unit testing (causes 20-40% coverage loss). References authoritative style guides rather than duplicating. Auto-refactors code to private[module] object pattern with user approval. Detects inline lambdas and suggests extraction to named functions ("laws"). Blocks during scala-ninja review (Phase 2) as peer review rejection point.
---

# Visibility Pattern Guardian Skill

## Purpose

Prevent **20-40% coverage loss** from using `private` methods by enforcing the visibility pattern documented in project style guides.

**Core Principle**: "The skill DETECTS and ENFORCES. The style guides are the single source of truth."

---

## Single Source of Truth

**Authoritative Documentation**:
- `.claude/styles/scala-conventions.md` (lines 111-160): Visibility Pattern for Testability
- `.claude/styles/testing-standards.md` (lines 81-154): Testability Pattern

**This Skill's Role**:
1. **DETECT** violations (private methods, inline lambdas)
2. **REFERENCE** style guides (point to exact line numbers)
3. **ENFORCE** by blocking during code review
4. **AUTO-REFACTOR** with user approval

**NO DUPLICATION**: All pattern guidance lives in style guides. This skill references them.

---

## Activation Strategy

### Layer 1: Light Warning During Writing (Real-time)

**Trigger**: User writes `private def` in Scala file

**Response**:
```
⚠️ "private def detected - may violate testability pattern.

📖 See authoritative guides:
   .claude/styles/scala-conventions.md (lines 111-160)
   .claude/styles/testing-standards.md (lines 81-154)

From the guide:
'This is a peer review rejection point - all new code must
follow this pattern unless specifically justified.'

(Full enforcement during code review phase)"
```

**Purpose**: Gentle education, point to where to learn

---

### Layer 2: BLOCK During scala-ninja Review (Phase 2)

**Trigger**: scala-ninja code review detects visibility violations

**Response**:
```
❌ PEER REVIEW REJECTION POINT

Visibility pattern violations detected in GuardianActor.scala

📖 Reference: .claude/styles/scala-conventions.md (lines 111-160)
"Visibility Pattern for Testability (REQUIRED)"

From the guide:
"Keep methods public, apply visibility restriction at class/object level"

Violations found:
  ❌ Line 45: private def receiveBehavior(...): Behavior[Command]
     Cannot unit test this method directly

  ❌ Line 78: private def handleInitialize(...): Behavior[Command]
     Cannot unit test this method directly

  ❌ Line 102: private def handleGetQueueActor(...): Behavior[Command]
     Cannot unit test this method directly

Impact:
- 8 methods untestable → ~180 lines of code without regression protection
- Estimated coverage loss: 30-40%
- This was proven in GuardianActor: 45% → 85% coverage after fix

Pattern from guide (line 119):
  ✅ Use private[core] on object
  ✅ Keep methods public (no private keyword)

Auto-refactoring to match style guide pattern...
```

**Purpose**: Hard enforcement at quality gate, comprehensive explanation

---

## Detection Patterns

### Pattern 1: Private Methods in Objects/Classes

**Detect**:
```scala
// VIOLATION
object GuardianActor {
  private def receiveBehavior(...): Behavior[Command] = { ... }
  private def handleInitialize(...): Behavior[Command] = { ... }
}
```

**Reference Guide**:
```
📖 .claude/styles/scala-conventions.md (line 119)

From the guide:
"CORRECT: Methods public, object scoped to module
private[core] object TestExecutionActor {
  def setupBehavior(...): Behavior[Command] = { ... }
}"
```

**Auto-Refactor**:
```scala
// REFACTORED TO MATCH GUIDE
private[core] object GuardianActor {
  def receiveBehavior(...): Behavior[Command] = { ... }
  def handleInitialize(...): Behavior[Command] = { ... }
}
```

---

### Pattern 2: Private Business Logic Methods

**Detect**:
```scala
// VIOLATION
class MyService {
  private def calculateDiscount(price: Double): Double = { ... }
}
```

**Reference Guide**:
```
📖 .claude/styles/testing-standards.md (lines 121-127)

From the guide:
"All helper methods should have direct unit tests.
Do NOT test helper methods only indirectly through integration tests."
```

**Auto-Refactor**:
```scala
// REFACTORED TO MATCH GUIDE
private[services] class MyService {
  def calculateDiscount(price: Double): Double = { ... }
}
```

---

### Pattern 3: Inline Lambdas with Business Logic

**Detect**:
```scala
// VIOLATION: Business logic buried in lambda
List("a", "b", "c").filter(v => v.equals(outerScopedString))
```

**Reference Guide**:
```
📖 .claude/styles/testing-standards.md (testability pattern)

From discussions:
"Extract business logic into named functions ('laws' - pure functions).
One can be tested, one cannot without testing the List operations."
```

**Suggest Refactor**:
```scala
// REFACTORED: Business logic extracted to testable law
val matchesOuterString: String => Boolean =
  v => v.equals(outerScopedString)

List("a", "b", "c").filter(matchesOuterString)
```

**Explanation**:
```
💡 "Testability Pattern: Laws vs Unit Tests

BEFORE (untestable):
  List("a", "b").filter(v => v.equals(outerScopedString))
  - Business logic (equals check) is inline
  - Can only test by testing entire List operation
  - Logic is not discoverable or named

AFTER (testable law):
  val matchesOuterString: String => Boolean = v => v.equals(outerScopedString)
  List("a", "b").filter(matchesOuterString)
  - matchesOuterString is a 'law' (pure function)
  - Can be unit tested independently
  - Business logic is discoverable and named
  - Filter operation uses the law

From style guide philosophy:
'Make code discoverable. Extract business logic into named functions.'"
```

---

## Auto-Refactoring Protocol

### Request Approval

**Template**:
```
❌ Visibility violations detected in GuardianActor.scala

I can automatically refactor to match the pattern from:
📖 .claude/styles/scala-conventions.md (lines 111-160)

BEFORE (violates guide):
  object GuardianActor {
    private def receiveBehavior(...): Behavior[Command] = { ... }
    private def handleInitialize(...): Behavior[Command] = { ... }
    private def handleGetQueueActor(...): Behavior[Command] = { ... }
  }

AFTER (matches guide):
  private[core] object GuardianActor {
    def receiveBehavior(...): Behavior[Command] = { ... }
    def handleInitialize(...): Behavior[Command] = { ... }
    def handleGetQueueActor(...): Behavior[Command] = { ... }
  }

Changes:
  - Add private[core] to object (line 119 of guide)
  - Remove private from 8 methods (lines 120-131 of guide)
  - Makes all methods unit testable

Benefits (from guide):
  ✅ Comprehensive unit testing: All helper methods directly testable
  ✅ Module encapsulation: private[core] prevents external access
  ✅ Test coverage: Enables 85%+ coverage without hacky workarounds
  ✅ Refactoring safety: Helper methods have regression protection

Approve auto-refactor? (yes/no)
```

### Apply Refactor

**If user approves ("yes")**:
```
"✅ Applying visibility pattern from style guide...

Changes made:
  ✓ GuardianActor.scala: Added private[core] to object
  ✓ GuardianActor.scala: Removed private from 8 methods

Recompiling to verify...

  mvn compile -pl test-probe-core -q

✅ Code compiles successfully after refactoring

Pattern applied matches:
  .claude/styles/scala-conventions.md (line 119)

Violations resolved. Ready to proceed to testing phase."
```

**If user defers ("later", "not now")**:
```
✅ Noted. Continuing for now.

⚠️ WARNING: This WILL block at Phase 2 (scala-ninja code review)

From the style guide:
"This is a peer review rejection point - all new code must
follow this pattern unless specifically justified."

scala-ninja will require this fix before proceeding to Phase 3.
```

**If user rejects ("no")**:
```
⚠️ Visibility pattern violation remains.

This WILL block at Phase 2 (scala-ninja code review).

From the style guide (line 116):
"This is a peer review rejection point - all new code must
follow this pattern unless specifically justified."

Do you have a justification for the exception?
Valid exceptions:
1. Internal state that genuinely must be hidden
2. Temporary/intermediate methods during refactoring
3. Security-sensitive operations

If yes, I'll document the exception for peer review.
If no, this will block during code review.
```

---

## Scope Guidelines (From Style Guide)

**Reference**: `.claude/styles/scala-conventions.md` (lines 150-154)

```
Scope selection:
- private[core]       → core module actors/services
- private[common]     → common module utilities
- private[services]   → services module implementations
- private[glue]       → Cucumber step definitions
- private[actors]     → limit to actors subpackage only
```

**Auto-detect correct scope**:
```
File: test-probe-core/src/main/scala/.../GuardianActor.scala
Module: test-probe-core
Suggested scope: private[core]

File: test-probe-common/src/main/scala/.../Utils.scala
Module: test-probe-common
Suggested scope: private[common]
```

---

## Integration with scala-ninja

**Phase 2: Code Review Coordination**

```
scala-ninja review:
  "Reviewing code against project standards...

  References:
  - .claude/styles/scala-conventions.md
  - .claude/styles/testing-standards.md
  - .claude/styles/akka-patterns.md

  Checking visibility pattern (scala-conventions.md lines 111-160)...

  ❌ Violations found: GuardianActor.scala (8 private methods)

  Triggering visibility-pattern-guardian for enforcement..."

visibility-pattern-guardian activates:
  [Blocks with detailed violation report]
  [References style guide sections]
  [Offers auto-refactoring]

User approves refactor:
  [Applies changes]
  [Recompiles]
  [Marks violations resolved]

scala-ninja continues:
  "✅ Visibility pattern violations resolved.
   Continuing review..."
```

---

## Communication Templates

### Detection (Layer 1 - Light Warning)
```
⚠️ Testability pattern suggestion

Detected: private def in actor code

📖 Pattern reference:
   .claude/styles/scala-conventions.md (lines 111-160)
   "Visibility Pattern for Testability (REQUIRED)"

From the guide:
"Keep methods public, apply visibility restriction at class/object level"

Quick example (from guide, line 119):
  ✅ private[core] object MyActor {
       def myMethod() = { ... }  // Public method, testable
     }

This will be enforced during code review phase (Phase 2).
```

### Enforcement (Layer 2 - BLOCK)
```
❌ PEER REVIEW REJECTION POINT

File: GuardianActor.scala
Issue: 8 private methods violate testability pattern

📖 Authoritative source:
   .claude/styles/scala-conventions.md (lines 111-160)

From the guide (line 116):
"This is a peer review rejection point - all new code must
follow this pattern unless specifically justified."

Coverage impact (from guide):
  ❌ GuardianActor with private methods: 45% coverage (methods untestable)
  ✅ GuardianActor with visibility pattern: 85%+ coverage (all testable)

Impact: -40% coverage from this one violation

Pattern required (from guide):
  private[core] object GuardianActor {
    def receiveBehavior(...) = { ... }  // ✅ Testable
    def handleInitialize(...) = { ... } // ✅ Testable
  }

Auto-refactoring to match guide pattern...
```

### Lambda Extraction Guidance
```
💡 Testability Pattern: Extract Business Logic to Named Functions

Detected:
  users.filter(u => u.age > 18 && u.isActive && !u.isBlocked)

Issue:
  Business logic (eligibility rules) is inline and untestable

📖 Principle (from discussions + testing-standards.md):
"Extract business logic into named functions ('laws').
One can be tested, one cannot without testing List operations."

Suggested refactor:
  val isEligibleUser: User => Boolean =
    u => u.age > 18 && u.isActive && !u.isBlocked

  users.filter(isEligibleUser)

Benefits:
  ✅ isEligibleUser is a 'law' (pure function)
  ✅ Can be unit tested independently:
     isEligibleUser(User(age=17, ...)) shouldBe false
  ✅ Business logic is discoverable and named
  ✅ Reusable across codebase

Shall I refactor this? (yes/no)
```

---

## Exceptions (Require Justification)

**From guide** (`.claude/styles/scala-conventions.md` line 156):

```
Exceptions requiring justification in PR:
- Internal state that genuinely must be hidden
- Temporary/intermediate methods during refactoring
- Security-sensitive operations
```

**If user claims exception**:
```
"⚠️ Exception to visibility pattern requested

You indicated this private method is an exception.

From the style guide (line 156), valid exceptions are:
1. Internal state that genuinely must be hidden
2. Temporary/intermediate methods during refactoring
3. Security-sensitive operations

Which exception applies to this case?

Please note: This exception will need justification in code review/PR.
The default is to follow the pattern unless there's a compelling reason."
```

---

## Key Insights

### Laws vs Unit Tests

**Law** (Pure function - testable independently):
```scala
val isEligible: User => Boolean = u => u.age > 18
// Can test: isEligible(User(age=17)) shouldBe false
```

**Unit Test** (Testing implementation detail):
```scala
users.filter(u => u.age > 18)
// Must test entire List operation to verify filter logic
```

**Principle**: Extract business logic into laws (named functions) that can be tested independently.

---

### Why This Matters (From Guide)

**Coverage Impact**:
```
GuardianActor with private methods: 45% coverage
GuardianActor with visibility pattern: 85%+ coverage

Difference: 40% more regression protection
```

**Proven**: This pattern was implemented in actual project actors (GuardianActor, TestExecutionActor) with measurable results.

---

## Exit Criteria

**Violations Resolved When**:
```
✅ All private methods refactored to public with module scoping
✅ All objects/classes have appropriate private[module] scope
✅ Complex inline lambdas extracted to named functions
✅ Code recompiles successfully
✅ Pattern matches examples from style guides
```

**Only Then**: Proceed to Phase 3 (Specifications)

---

## Success Indicators

**Skill is working when**:
- ✅ No private method violations ship
- ✅ Coverage consistently achieves 85%+ for actors
- ✅ Developers learn to read style guides (education)
- ✅ "Laws" pattern adopted for business logic
- ✅ Peer review rejections eliminated

---

## Style Guide References

**Quick Links**:
- Visibility Pattern: `.claude/styles/scala-conventions.md` (lines 111-160)
- Testability Pattern: `.claude/styles/testing-standards.md` (lines 81-154)
- Helper Method Testing: `.claude/styles/testing-standards.md` (lines 137-154)

**Always reference these** - they are the single source of truth.

---

**Version**: 1.0
**Last Updated**: 2025-10-21
**Based on**: `working/skills-suite/visibility-pattern-guardian-design.md`