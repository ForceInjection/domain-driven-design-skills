---
name: automated-testing
description: Write automated tests following a pragmatic, integration-focused philosophy. Use when writing tests for new features, writing tests for bug fixes, adding test coverage, or deciding what/how to test. Emphasizes confidence over coverage, real objects over mocks, integration over isolation, and simplicity over dogma.
---

# Automated Testing

## Core Philosophy

**Comprehensive coverage.** Almost all code should be covered by tests. However, you aren't striving for 100% coverage or testing every edge case—your goal is to ensure solid, practical coverage that validates the code works as expected.

**Test enough to be confident, then stop.** Tests have maintenance costs. Write enough tests to be very confident the implementation works correctly, but not more. Additional tests beyond that point are a liability.

## Principles

### Necessary and Sufficient

Every test must be both necessary and sufficient:

- **Necessary**: Test only situations needed to fully exercise the code's behavior
- **Sufficient**: If you delete implementation code, a test should fail. If no test fails, either tests are insufficient or the code is unnecessary.

### Test Behavior, Not Implementation

Test external behavior: return values and side effects. Avoid testing internal implementation details. This means:

- Refactoring should rarely break tests
- Tests remain valuable as code evolves
- Less brittle, more maintainable tests

### Prefer Integration Over Isolation

Aim for the highest level of integration while maintaining reasonable speed:

- Use real objects, not mocks
- Test the actual system behavior users will experience
- Only mock when something negatively impacts tests (slow external services, etc.). This applies to 3rd party code.
- Make tests as realistic as possible. For example, use request specs not controller specs.

### Keep Tests Simple and Readable

Tests don't have tests. You must be able to look at a test and easily understand what it's doing. If a test is hard to reason about, it's not providing confidence.

### Multiple Assertions Are Fine

Have as many assertions as needed to feel confident about one aspect of behavior. If multiple assertions simplify test code and reduce setup duplication, use them. Stay focused on testing one piece of functionality per test.

### Listen to Test Pain

If tests are hard to write, the problem is usually the implementation, not the tests. Mountains of setup or mocking often indicate a method is doing too much or is overly coupled. High-quality code is easy to test. When writing tests feels painful, step back and reconsider the design.

## What NOT To Do

- Don't test every possible edge case and scenario
- Don't create elaborate mocks when real objects work fine
- Don't sacrifice code design for testability
- Don't follow the test pyramid dogmatically
- Don't write tests so complex they need their own tests
