---
name: software-quality
description: Analyze test coverage, identify gaps, suggest strategic test cases. Use when writing features, after bug fixes, or during test reviews. Ensures comprehensive coverage without over-testing.
---

# Software Quality

You ensure strategic test coverage.

## Testing Pyramid (60-30-10)

- **60% Unit**: Fast, isolated, numerous
- **30% Integration**: Component interactions
- **10% E2E**: Critical user paths only

Aim for strategic coverage, not 100%.

## Coverage Analysis

```
Current:
- Unit: [count] at [%]
- Integration: [count] at [%]
- E2E: [count] at [%]

Gaps:
- Untested functions: [list]
- Untested paths: [list]
- Missing edge cases: [list]
- Missing error scenarios: [list]
```

## Test Categories

### 1. Boundary Testing

- Empty inputs ([], "", None, 0)
- Single elements
- Maximum limits
- Off-by-one scenarios

### 2. Error Handling

- Invalid inputs
- Network failures
- Timeouts
- Permission denied
- Resource exhaustion

### 3. State Testing

- Initialization
- Concurrent access
- State transitions
- Cleanup verification

### 4. Integration Points

- API contracts
- Database operations
- External services
- Message queues

## Test Gap Analysis

For each function:
1. Happy path: Basic success
2. Edge cases: Boundary conditions
3. Error cases: Invalid inputs, failures
4. State variations: Different initial states

## Suggestion Format

```markdown
## Coverage: [Component]

### Current
Lines: [X]%
Branches: [Y]%
Functions: [Z]%

### Critical Gaps

#### High Priority (Security/Data)
1. **[Function]**
   - Missing: [Test type]
   - Risk: [What breaks]
   - Test: `test_[scenario]`

#### Medium Priority (Features)
[Same structure]

#### Low Priority (Edge Cases)
[Same structure]

### Suggested Tests

```python
def test_function_empty_input():
    """Test handling of empty input"""
    # Arrange
    # Act
    # Assert

def test_function_boundary():
    """Test maximum allowed value"""
    # Test implementation
```
```

## Test Quality Criteria

Good tests are:
- Fast (<100ms for unit)
- Isolated (no dependencies)
- Repeatable (same result always)
- Self-validating (clear pass/fail)
- Timely (written with code)

## Test Patterns

**Parametrized:**
```python
@pytest.mark.parametrize("input,expected", [
    ("", ValueError),
    (None, TypeError),
    ("valid", "processed"),
])
def test_validation(input, expected):
    # Single test, multiple cases
```

**Fixtures:**
```python
@pytest.fixture
def standard_setup():
    return configured_object
```

**Mocking:**
- Mock external dependencies only
- Prefer fakes over mocks
- Verify behavior, not implementation

## Test Documentation

```python
def test_function_scenario():
    """
    Test: [What is tested]
    Given: [Initial conditions]
    When: [Action taken]
    Then: [Expected outcome]
    """
```

## Priority Levels

**Quick Wins** (immediate):
- Uncovered error paths
- Boundary conditions
- Negative test cases

**Systematic** (this week):
- Increase branch coverage
- Add integration tests
- Test concurrent scenarios

**Long-term** (this month):
- Property-based testing
- Performance benchmarks

## Test Smells

Avoid:
- Testing the mock
- Overly complex setup
- Multiple assertions per test
- Time-dependent tests
- Order-dependent tests
- Tests that never fail
- Flaky tests

## Coverage Targets

Minimum thresholds:
- Unit coverage: 96%
- Integration: Key paths
- E2E: Critical flows only

Verify:
```bash
just coverage    # Check >= 96%
just test        # All pass
```

## Red Flags

- No error case tests
- Only happy path tested
- No boundary tests
- Missing integration tests
- Over-reliance on E2E
- Flaky tests

## Output

Focus on:
1. Critical gaps (security, data)
2. Strategic test additions
3. Priority order
4. Concrete examples

Not:
1. 100% coverage goals
2. Over-testing
3. Testing implementation details

## Philosophy

Testing pyramid: 60% unit, 30% integration, 10% e2e.

Strategic coverage beats comprehensive coverage.
