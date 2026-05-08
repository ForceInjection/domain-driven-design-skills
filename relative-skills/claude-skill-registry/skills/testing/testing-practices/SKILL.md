---
name: testing-practices
description: Testing best practices for modern Python development. Activated when working with tests, pytest, Hypothesis property-based testing, Atheris fuzz testing, test coverage, test organization, or mutation testing.
---

# Testing practices

## Purpose

Comprehensive guide for testing within Python projects. Covers property-based testing with Hypothesis, fuzz testing with Atheris, test organization, coverage requirements, and mutation testing strategies.

## When to use

This skill activates when:

- Writing unit tests
- Implementing property-based tests
- Creating fuzz tests
- Analyzing test coverage
- Debugging test failures
- Organizing test files
- Setting up mutation testing

## Core principles

### Coverage requirements

**MANDATORY: Maintain >95% test coverage for all code**

```bash
# Run tests with coverage
uv run pytest --cov src --cov-report html --cov-report term-missing --cov-branch
```

**Coverage is a floor, not a ceiling:**

- 95% is minimum acceptable
- Aim for 100% on critical paths
- Branch coverage required (not just line coverage)
- Missing coverage must be justified

### Domain-centric test organization

**MANDATORY: Organize tests by domain/feature, NOT by testing task**

```text
tests/
├── unit/
│   ├── validation/
│   │   ├── test_input_validation.py
│   │   └── test_type_validation.py
│   └── processing/
│       ├── test_data_processing.py
│       └── test_transformations.py
├── properties/
│   └── test_invariants.py
├── fuzz/
│   └── test_fuzzing.py
├── integration/
│   └── test_end_to_end.py
└── benchmarks/
    └── test_performance.py
```

**NEVER create:**

- `test_edge_cases.py` - organize by feature instead
- `test_coverage.py` - tests belong in domain files
- `test_final_push.py` - tests belong in domain files

### Test naming conventions

```python
# Pattern: test_<scenario>_<expected_result>

def test_validation_with_valid_input_succeeds():
    pass

def test_validation_with_invalid_input_raises_error():
    pass
```

**Requirements:**

- Test function names MUST be self-explanatory
- Test functions MUST NOT have docstrings (name is documentation)
- Test classes MUST NOT have docstrings

## Property-based testing with Hypothesis

### Basic property tests

```python
from hypothesis import given, assume
from hypothesis.strategies import lists, text, integers

@given(lists(text()))
def test_processing_never_crashes_on_any_input(data):
    # Processing should handle any input without crashing
    try:
        process(data)
    except ValidationError:
        pass  # Expected errors are OK
    # Should never raise TypeError, AttributeError, etc.

@given(integers(min_value=0, max_value=100))
def test_bounded_values_stay_in_range(n):
    # Values in range stay in range after processing
    result = process_bounded(n)
    assert 0 <= result <= 100
```

### Custom strategies

```python
from hypothesis.strategies import composite, sampled_from

@composite
def valid_identifiers(draw):
    # Generate valid identifier strings
    first = draw(sampled_from('abcdefghijklmnopqrstuvwxyz'))
    rest = draw(text(alphabet='abcdefghijklmnopqrstuvwxyz_0123456789', max_size=20))
    return first + rest
```

### Property test invariants

```python
@given(lists(text()))
def test_processing_is_deterministic(data):
    # Processing same input twice gives same result
    result1 = process(data.copy())
    result2 = process(data.copy())
    assert result1 == result2

@given(lists(text()))
def test_processing_never_mutates_input(data):
    # Processor never modifies input
    original = data.copy()
    try:
        process(data)
    except ValidationError:
        pass
    assert data == original
```

## Fuzz testing with Atheris

### Basic fuzz test

```python
import atheris
import sys

def test_fuzz():
    # Fuzz test with Atheris
    @atheris.instrument_func
    def fuzz_processor(data):
        fdp = atheris.FuzzedDataProvider(data)
        num_items = fdp.ConsumeIntInRange(0, 20)
        items = [fdp.ConsumeUnicodeNoSurrogates(20) for _ in range(num_items)]

        try:
            process(items)
        except ValidationError:
            pass  # Expected errors

    atheris.Setup(sys.argv, fuzz_processor)
    atheris.Fuzz()
```

## Test fixtures

```python
import pytest

@pytest.fixture
def simple_config():
    """Basic configuration for testing."""
    return Config(
        option_a=True,
        option_b="value"
    )

@pytest.fixture
def mock_service(mocker):
    """Mock external service."""
    return mocker.patch('yourpackage.service.Service')
```

## Mutation testing

```bash
# Run mutation testing with mutmut
uv run mutmut run

# Show results
uv run mutmut results

# Show specific mutant
uv run mutmut show 1
```

**Mutation testing workflow:**

1. Run `mutmut run` to generate and test mutations
2. Check mutation score (aim for >80%)
3. For surviving mutants:
   - Add tests to kill the mutant
   - OR justify why mutant is equivalent
4. Re-run to verify new tests kill mutants

## Running tests

```bash
# All tests
uv run pytest

# Specific test file
uv run pytest tests/unit/test_validation.py

# With coverage
uv run pytest --cov src --cov-report html --cov-report term-missing --cov-branch

# Property-based tests with statistics
uv run pytest tests/properties/ --hypothesis-show-statistics
```

---

**Additional resources:**

- [pytest documentation](https://docs.pytest.org/)
- [Hypothesis documentation](https://hypothesis.readthedocs.io/)
- [Atheris documentation](https://github.com/google/atheris)
- [mutmut documentation](https://mutmut.readthedocs.io/)
