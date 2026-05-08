---
name: tdd-workflow-guide
description: |
  Automatically guides users through RED-to-GREEN TDD workflow when implementing features in kiro projects
---

# TDD Workflow Guide Skill

## What This Skill Does

This skill enables Claude to automatically recognize when a user is about to implement a feature in a kiro project and guide them through proper Test-Driven Development (RED-to-GREEN) workflow.

## When It Activates

Claude autonomously activates this skill when:

**Direct triggers:**
- User says "I need to implement [feature]" in a kiro project
- "How do I add [functionality]?" in existing code
- "Let's write the code for [task]"
- User is in a scoped implementation directory

**Implicit triggers:**
- User mentions starting work on a task from tasks.md
- Describes functionality to implement
- Asks about implementation approach
- Has failing tests or wants to write tests

**Context clues:**
- assertions.md file present in current directory
- Inside a scoped implementation area (has .kiro/ subdirectory)
- Project has TDD structure from kiro scaffold
- User previously used kiro commands

## How It Works

### Phase 1: Recognition & Assertion Check

Claude identifies implementation intent and checks for assertions:

```
I see you're ready to implement [feature]. Let's follow the TDD workflow!

First, let me check if we have test assertions defined...

[Checks for assertions.md in scope]

✓ Found assertions.md with test specifications
or
⚠ No assertions.md found. I'll help you create one first.
```

### Phase 2: Assertion Creation (if needed)

If assertions don't exist, invokes TDD Coach to create them:

```
Before implementing, let's define what we're testing. I'll create assertions.md with:

1. Happy path scenarios
2. Edge cases  
3. Error conditions
4. Performance expectations

[Generates comprehensive assertions]

Review these - do they cover your requirements?
```

### Phase 3: RED - Write Failing Test

Guides writing the first failing test:

```
Now let's write a failing test based on assertion #1:

[Shows test code]

This test should FAIL because [reason].
Let's run it to confirm: [provides test command]

Expected: [specific error/failure]
```

Confirms:
```
Did the test fail as expected? (y/n)
```

### Phase 4: GREEN - Minimal Implementation

Guides minimal implementation:

```
Great! The test is RED. Now implement JUST ENOUGH to make it pass.

Don't worry about:
- Perfect code structure
- All edge cases
- Optimization

Just focus on making THIS test pass.

[Provides implementation guidance or skeleton]
```

After implementation:
```
Run the test again. It should PASS (GREEN).

If it still fails:
- Check implementation logic
- Verify test expectations
- Debug step by step

If it passes, we're ready to refactor!
```

### Phase 5: REFACTOR - Improve Code

After test passes:

```
Excellent! Test is GREEN. Now we can refactor safely.

Improvements to consider:
1. [specific improvement]
2. [another improvement]
3. [etc.]

IMPORTANT: Run tests after each change!
If tests fail, undo the change.
```

### Phase 6: Repeat Cycle

After successful RED-GREEN-REFACTOR:

```
✓ Test #1 complete and green!

Next: [describes next test from assertions.md]

Ready to write the next failing test?
```

## Workflow Enforcement

This skill enforces TDD discipline:

**Blocks premature implementation:**
```
User: [pastes implementation code]

Claude: Hold on! Let's write the test first. This is a TDD workflow - we need to:
1. Write failing test (RED)
2. Minimal implementation (GREEN)  
3. Refactor

Which assertion are you implementing? Let me help you write the test.
```

**Prevents skipping tests:**
```
User: Can we skip tests for this small function?

Claude: In a kiro TDD project, every function gets tests! Tests are your:
- Documentation
- Safety net for refactoring
- Verification of requirements

This function is small, so the test will be quick. Let me help you write it.
```

**Ensures test quality:**
```
User: [Shows trivial test that doesn't really test anything]

Claude: This test always passes - it's not testing the behavior! Let's improve it:

[Shows better test with actual assertions]

Good tests verify:
- Correct output for given input
- Error handling
- Edge cases
```

## Integration with Kiro Structure

This skill leverages:
- **assertions.md**: Source of test specifications
- **CLAUDE.md**: Project-specific testing guidance  
- **nickel contracts**: Expected types and behaviors
- **.kiro/spec/**: Requirements to validate against
- **tasks.md**: Context of what's being implemented

## Context Awareness

The skill adapts to:
- **Language**: Adjusts test syntax (Python, JavaScript, Rust, etc.)
- **Framework**: Uses project's testing framework
- **Scope**: Understands if unit, integration, or e2e test
- **Experience**: Adjusts explanation depth
- **Project phase**: MVP vs production standards

## Example Interactions

### Example 1: Starting Implementation
```
User: I need to implement the login function

Claude: [Activates skill] Perfect! Let's implement login using TDD. 

I found assertions.md with test specs for login. Let's start with the happy path:

Test #1: Valid credentials should return JWT token

Here's the failing test we'll write:
[shows test code]

Ready to write this?
```

### Example 2: User Tries to Skip Tests
```
User: Let me just write the code first, I'll add tests later

Claude: [Enforces workflow] In kiro TDD projects, we always test-first! Here's why this matters:

1. Tests clarify what to build
2. You write only necessary code
3. Refactoring is safe
4. Requirements are verified

Let's write the test together - it'll be faster than you think!

[Guides to first test]
```

### Example 3: Debugging Failing Test
```
User: My test keeps failing but I think my code is right

Claude: [Helps debug] Let's troubleshoot systematically:

1. What error message do you see?
2. Is the test expectation correct?
3. Does the implementation handle this case?

[Walks through debugging]

Actually, I see the issue - your test expects a dict but implementation returns a tuple. Let's fix...
```

## Quality Checks

This skill ensures:
- Tests are written before implementation
- Tests fail for the right reason (RED)
- Implementation makes tests pass (GREEN)
- Refactoring maintains green tests
- Coverage increases incrementally
- Tests are meaningful, not just present

## Success Indicators

The skill successfully guides TDD when:
- User follows RED-GREEN-REFACTOR cycle
- All assertions from assertions.md have tests
- Tests are comprehensive and meaningful
- User understands TDD benefits
- Code quality improves through refactoring
- Test suite is reliable and fast

## Teaching Moments

This skill uses TDD as teaching opportunities:
- Explains why test-first is better
- Shows how tests guide design
- Demonstrates refactoring safety
- Builds testing confidence
- Reinforces good practices

## Integration with Agents

This skill can invoke:
- **TDD Coach Agent**: For complex testing scenarios
- **Kiro Evaluator Agent**: To check test quality
- **Refactorer Agent**: For guided refactoring

## Best Practices Encoded

- **Test behavior, not implementation**: Tests survive refactoring
- **One test at a time**: Focus and clarity
- **Descriptive test names**: Tests as documentation
- **Arrange-Act-Assert**: Clear test structure
- **Fast tests**: Unit tests run in milliseconds
- **Independent tests**: No test dependencies
- **Clear assertions**: Obvious what's being verified

## See Also

- TDD Coach Agent - For implementation guidance
- Kiro Architect Agent - For testable design
- Kiro Evaluator Agent - For test quality assessment
