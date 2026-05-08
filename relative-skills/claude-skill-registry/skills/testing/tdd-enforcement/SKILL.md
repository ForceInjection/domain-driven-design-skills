---
name: "tdd-enforcement"
description: "A workflow that enforces genuine test-driven development: tests first, behavior-focused, with strong edge-case coverage."
---

# Test-Driven Development Enforcement

## Purpose

This skill enforces real TDD, not “write tests later”:

- Design behavior and tests before implementation.
- Drive architecture from testability.
- Capture edge cases early.
- Keep tests readable and stable.

---

## When to Use

- New features or modules.
- Bug fixes where regressions would be expensive.
- Refactors of core flows.
- Any area where stability and clarity matter (auth, billing, infra).

---

## TDD Workflow

Follow this cycle strictly:

1. **Clarify behavior**

   - Define the behavior in plain language: inputs, outputs, side effects.
   - Identify key scenarios: happy path + important edge cases.
   - Agree on what “done and correct” means.

2. **Write tests first**

   - For each scenario, write a test that:
     - Uses domain language in test names.
     - Asserts observable behavior, not implementation details.
   - Start with the most central behavior. Add one edge case at a time.

3. **Run tests and see them fail**

   - Ensure each new test fails for the right reason.
   - If a test passes immediately without implementation, you likely wrote the wrong test.

4. **Write minimal implementation**

   - Implement just enough code to make the current tests pass.
   - Prefer simple, clear code over cleverness.

5. **Refactor**

   - Once tests are green, improve design:
     - Extract helpers.
     - Improve names.
     - Remove duplication.
   - Keep tests passing after refactor.

6. **Repeat**

   - Add more scenarios (error cases, boundaries, concurrency).
   - For regressions, first reproduce with a failing test, then fix.

---

## Architecture for TDD Success

TDD is easier when code is architected for testability. The Functional Core, Imperative Shell pattern enables effortless test-first development.

### The Problem: Mixed Concerns

When business logic is tangled with I/O, writing tests first becomes painful:

```python
# Hard to test-first: Logic mixed with database
def process_order(order_id):
    order = OrderRepository.find(order_id)  # How to test without DB?
    if order.customer.premium:  # Business logic
        discount = order.total * 0.2
    PaymentGateway.charge(...)  # How to test without payment gateway?
```

**Test-first is painful because you need database and payment gateway mocks before implementing logic.**

### The Solution: FCIS Pattern

**Separate logic (core) from I/O (shell):**

```python
# Core: Pure, easy to test-first
def calculate_discount(is_premium, total):
    return total * 0.2 if is_premium else 0

# Test-first is natural (no dependencies!)
def test_premium_customers_receive_20_percent_discount():
    discount = calculate_discount(is_premium=True, total=100)
    assert discount == 20
```

**Now TDD workflow is smooth:**
1. Write test for pure function (no mocks needed)
2. See it fail (red)
3. Implement pure logic (green)
4. Refactor (tests protect you)

**Google Testing Blog (October 2025):** "Mixing database calls, network requests, and other external interactions directly with your core logic can lead to code that's difficult to test."

**Recommendation:** When starting TDD on a new feature, explicitly identify core (logic) vs shell (I/O). Write core functions first with test-first workflow. Shell can be tested with lighter integration tests.

**See `writing-code` skill for complete guidance on separating decisions from effects (FCIS pattern).**

---

## Test Quality Checklist

When generating or reviewing tests, ensure:

- **Behavioral**: Tests describe what the system does, not how it does it.
- **Isolated**: Each test has a single clear purpose; setup is minimal but meaningful.
- **Readable**: Someone new to the code can understand behavior from the tests alone. Tests follow clear data flow (Arrange → Act → Assert). Lines ordered to match data dependencies (Google Testing Blog, January 2025).
- **Deterministic**: No reliance on real clocks, randomness, or external services without control.
- **Fast enough**: Core unit tests can run frequently during development.

---

## Common Patterns

Prefer:

- Given/When/Then structure in test names and bodies.
- Factored helpers for common setup, but avoid over-abstracting.
- Clear assertions with good failure messages.

Avoid:

- Testing private helpers directly instead of behavior.
- Large integration-style tests when a unit test would suffice.
- Over-mocking internals instead of modeling realistic collaborators.

---

## Examples of Good Prompts

- "Use the TDD workflow to design tests for this feature before writing any implementation."
- "Given this bug description, first write a failing test that reproduces it, then suggest a minimal fix."
- "Review this test suite using the TDD checklist; propose improvements to make tests more behavioral and readable."

---

## Integration with Other Skills

### software-testing-strategy (Strategic Framework)

For strategic test planning and comprehensive test design patterns, see the `software-testing-strategy` skill. This skill (tdd-enforcement) focuses on the tactical test-first workflow, while software-testing-strategy provides the strategic framework for choosing test types, recognizing anti-patterns, and designing effective test suites.

### writing-code (Architecture: Decisions vs Effects)

For architecting code that makes TDD effortless, see the `writing-code` skill. Separating decisions from effects (FCIS pattern) makes test-first development natural:

- Decision functions are trivially testable without mocks
- TDD cycle runs fast (no I/O in decisions)
- Tests are deterministic (pure decision logic)

**When struggling with TDD:** If writing tests first requires heavy mocking, your code likely mixes decisions and effects. Use the writing-code pattern to separate concerns, then TDD becomes straightforward.
