---
name: property-based-test-generator
description: Generates property-based tests using Hypothesis (Python), fast-check (JavaScript/TypeScript), or QuickCheck (Haskell). Use when user asks to "generate property tests", "create hypothesis tests", "add property-based testing", or "generate fast-check tests".
allowed-tools: [Read, Write, Bash, Glob]
---

# Property-Based Test Generator

Generates property-based tests that validate invariants and find edge cases automatically through randomized testing.

## When to Use

- "Generate property-based tests"
- "Create hypothesis tests for my function"
- "Add property tests to my code"
- "Generate fast-check tests"
- "Test function properties"
- "Find edge cases automatically"

## Instructions

### 1. Detect Language and Testing Framework

Check the project's language and existing test setup:

```bash
# Check for Python
[ -f "pytest.ini" ] || [ -f "setup.py" ] && echo "Python"

# Check for JavaScript/TypeScript
[ -f "package.json" ] && echo "JavaScript/TypeScript"

# Check existing test framework
grep -E "(jest|vitest|mocha|pytest|hypothesis)" package.json pyproject.toml requirements.txt 2>/dev/null
```

### 2. Install Property-Based Testing Library

**Python (Hypothesis):**
```bash
pip install hypothesis pytest
```

**JavaScript/TypeScript (fast-check):**
```bash
npm install --save-dev fast-check @types/jest
# or
npm install --save-dev fast-check vitest
```

**Haskell (QuickCheck):**
```bash
cabal install QuickCheck
```

### 3. Identify Function Properties

Analyze the function to test and identify invariants:

**Common Properties:**
- **Idempotence**: `f(f(x)) === f(x)`
- **Inverse**: `decode(encode(x)) === x`
- **Commutativity**: `f(a, b) === f(b, a)`
- **Associativity**: `f(f(a, b), c) === f(a, f(b, c))`
- **Identity**: `f(x, identity) === x`
- **Range**: Output always within valid range
- **Type safety**: Output type matches expected
- **No exceptions**: Function never throws for valid input

### 4. Generate Property-Based Tests

## Python with Hypothesis

**Basic Example:**
```python
from hypothesis import given, strategies as st
import pytest

# Function to test
def sort_list(items):
    return sorted(items)

# Property: sorted list length equals original
@given(st.lists(st.integers()))
def test_sort_preserves_length(items):
    result = sort_list(items)
    assert len(result) == len(items)

# Property: sorted list is ordered
@given(st.lists(st.integers()))
def test_sort_creates_ordered_list(items):
    result = sort_list(items)
    for i in range(len(result) - 1):
        assert result[i] <= result[i + 1]

# Property: sorted list contains same elements
@given(st.lists(st.integers()))
def test_sort_preserves_elements(items):
    result = sort_list(items)
    assert sorted(items) == result
```

**Advanced Strategies:**
```python
from hypothesis import given, strategies as st, assume
from datetime import datetime, timedelta

# Custom data structures
@st.composite
def users(draw):
    return {
        'id': draw(st.integers(min_value=1, max_value=1000000)),
        'name': draw(st.text(min_size=1, max_size=50)),
        'email': draw(st.emails()),
        'age': draw(st.integers(min_value=18, max_value=120)),
        'created_at': draw(st.datetimes(
            min_value=datetime(2020, 1, 1),
            max_value=datetime.now()
        ))
    }

@given(users())
def test_user_validation(user):
    # Validate user properties
    assert user['age'] >= 18
    assert '@' in user['email']
    assert len(user['name']) > 0
    assert user['created_at'] <= datetime.now()
```

**Testing with Preconditions:**
```python
@given(st.integers(), st.integers())
def test_division(a, b):
    assume(b != 0)  # Precondition: no division by zero
    result = a / b
    assert result * b == a  # Property: inverse of multiplication
```

**Stateful Testing:**
```python
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant

class ShoppingCart(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self.items = []
        self.total = 0

    @rule(item=st.tuples(st.text(), st.floats(min_value=0, max_value=1000)))
    def add_item(self, item):
        name, price = item
        self.items.append(item)
        self.total += price

    @rule()
    def clear_cart(self):
        self.items = []
        self.total = 0

    @invariant()
    def total_matches_sum(self):
        assert abs(self.total - sum(p for _, p in self.items)) < 0.01

TestCart = ShoppingCart.TestCase
```

## JavaScript/TypeScript with fast-check

**Basic Example:**
```typescript
import fc from 'fast-check';

// Function to test
function reverseString(str: string): string {
  return str.split('').reverse().join('');
}

describe('reverseString', () => {
  it('double reverse returns original', () => {
    fc.assert(
      fc.property(fc.string(), (str) => {
        const reversed = reverseString(str);
        const doubleReversed = reverseString(reversed);
        return doubleReversed === str;
      })
    );
  });

  it('preserves string length', () => {
    fc.assert(
      fc.property(fc.string(), (str) => {
        return reverseString(str).length === str.length;
      })
    );
  });

  it('first char becomes last char', () => {
    fc.assert(
      fc.property(fc.string({ minLength: 1 }), (str) => {
        const reversed = reverseString(str);
        return str[0] === reversed[reversed.length - 1];
      })
    );
  });
});
```

**Complex Data Structures:**
```typescript
import fc from 'fast-check';

// Custom arbitraries
const userArbitrary = fc.record({
  id: fc.integer({ min: 1, max: 1000000 }),
  name: fc.string({ minLength: 1, maxLength: 50 }),
  email: fc.emailAddress(),
  age: fc.integer({ min: 18, max: 120 }),
  roles: fc.array(fc.constantFrom('admin', 'user', 'guest'), { minLength: 1 })
});

describe('User validation', () => {
  it('validates user structure', () => {
    fc.assert(
      fc.property(userArbitrary, (user) => {
        return (
          user.age >= 18 &&
          user.email.includes('@') &&
          user.roles.length > 0
        );
      })
    );
  });
});
```

**Array Properties:**
```typescript
describe('Array operations', () => {
  it('map preserves length', () => {
    fc.assert(
      fc.property(
        fc.array(fc.integer()),
        fc.func(fc.integer()),
        (arr, fn) => {
          return arr.map(fn).length === arr.length;
        }
      )
    );
  });

  it('filter result is subset', () => {
    fc.assert(
      fc.property(
        fc.array(fc.integer()),
        (arr) => {
          const filtered = arr.filter(x => x > 0);
          return filtered.every(x => arr.includes(x));
        }
      )
    );
  });

  it('concat is associative', () => {
    fc.assert(
      fc.property(
        fc.array(fc.integer()),
        fc.array(fc.integer()),
        fc.array(fc.integer()),
        (a, b, c) => {
          const left = a.concat(b).concat(c);
          const right = a.concat(b.concat(c));
          return JSON.stringify(left) === JSON.stringify(right);
        }
      )
    );
  });
});
```

**Shrinking Examples:**
```typescript
describe('Shrinking demonstration', () => {
  it('finds minimal failing case', () => {
    fc.assert(
      fc.property(fc.array(fc.integer()), (arr) => {
        // This will fail and shrink to smallest failing case
        return arr.length < 5 || arr.some(x => x > 100);
      }),
      { numRuns: 100 }
    );
  });
});
```

**Model-Based Testing:**
```typescript
import fc from 'fast-check';

class Stack<T> {
  private items: T[] = [];

  push(item: T): void {
    this.items.push(item);
  }

  pop(): T | undefined {
    return this.items.pop();
  }

  size(): number {
    return this.items.length;
  }
}

describe('Stack', () => {
  it('behaves like array', () => {
    fc.assert(
      fc.property(
        fc.array(fc.integer()),
        (operations) => {
          const stack = new Stack<number>();
          const model: number[] = [];

          for (const op of operations) {
            if (op >= 0) {
              stack.push(op);
              model.push(op);
            } else {
              const stackResult = stack.pop();
              const modelResult = model.pop();
              if (stackResult !== modelResult) return false;
            }
          }

          return stack.size() === model.length;
        }
      )
    );
  });
});
```

### 5. Common Property Patterns

**Encode/Decode (Roundtrip):**
```python
from hypothesis import given, strategies as st
import json

@given(st.dictionaries(st.text(), st.integers()))
def test_json_roundtrip(data):
    encoded = json.dumps(data)
    decoded = json.loads(encoded)
    assert decoded == data
```

```typescript
fc.assert(
  fc.property(fc.anything(), (data) => {
    const encoded = JSON.stringify(data);
    const decoded = JSON.parse(encoded);
    return JSON.stringify(decoded) === encoded;
  })
);
```

**Idempotence:**
```python
@given(st.lists(st.integers()))
def test_dedup_idempotent(items):
    result1 = list(set(items))
    result2 = list(set(result1))
    assert result1 == result2
```

**Commutativity:**
```python
@given(st.integers(), st.integers())
def test_addition_commutative(a, b):
    assert a + b == b + a
```

**Oracle (Compare with Known Implementation):**
```python
@given(st.lists(st.integers()))
def test_custom_sort_matches_builtin(items):
    assert custom_sort(items) == sorted(items)
```

**Invariants:**
```typescript
fc.assert(
  fc.property(fc.array(fc.integer()), (arr) => {
    const unique = [...new Set(arr)];
    return unique.length <= arr.length;
  })
);
```

### 6. Configuration Options

**Hypothesis:**
```python
from hypothesis import given, settings, strategies as st

@settings(
    max_examples=1000,  # Number of test cases
    deadline=None,      # No timeout
    verbosity=hypothesis.Verbosity.verbose
)
@given(st.integers())
def test_with_settings(x):
    assert x == x
```

**fast-check:**
```typescript
fc.assert(
  fc.property(fc.integer(), (x) => x === x),
  {
    numRuns: 1000,        // Number of test cases
    seed: 42,             // Reproducible tests
    verbose: true,        // Show details
    endOnFailure: false   // Run all tests
  }
);
```

### 7. Testing Strategies by Data Type

**Strings:**
```python
st.text()
st.text(min_size=1, max_size=100)
st.text(alphabet=st.characters(blacklist_categories=['Cs']))
st.from_regex(r'[a-z]{3,10}')
```

```typescript
fc.string()
fc.string({ minLength: 1, maxLength: 100 })
fc.hexaString()
fc.asciiString()
fc.unicodeString()
fc.stringOf(fc.char())
```

**Numbers:**
```python
st.integers()
st.integers(min_value=0, max_value=100)
st.floats(min_value=0.0, max_value=1.0)
st.decimals()
```

```typescript
fc.integer()
fc.integer({ min: 0, max: 100 })
fc.float()
fc.double()
fc.nat()
```

**Collections:**
```python
st.lists(st.integers())
st.lists(st.integers(), min_size=1, max_size=10)
st.sets(st.text())
st.dictionaries(st.text(), st.integers())
st.tuples(st.text(), st.integers())
```

```typescript
fc.array(fc.integer())
fc.array(fc.integer(), { minLength: 1, maxLength: 10 })
fc.set(fc.string())
fc.dictionary(fc.string(), fc.integer())
fc.tuple(fc.string(), fc.integer())
```

**Dates:**
```python
st.datetimes()
st.dates(min_value=date(2020, 1, 1))
st.times()
```

```typescript
fc.date()
fc.date({ min: new Date('2020-01-01') })
```

### 8. Best Practices

**DO:**
- Test invariants, not specific outputs
- Use meaningful property names
- Start with simple properties
- Let the library shrink failures
- Test edge cases (empty, single item, max size)
- Combine multiple properties
- Use preconditions (`assume` in Hypothesis, `fc.pre` in fast-check)

**DON'T:**
- Test implementation details
- Use too complex properties
- Ignore shrinking results
- Forget to test edge cases
- Make properties too similar to implementation
- Use property-based tests for everything (unit tests still valuable)

### 9. Common Patterns

**Metamorphic Testing:**
```python
@given(st.lists(st.integers()))
def test_sort_stability(items):
    # Adding an element and sorting should give same order for original elements
    with_extra = items + [max(items) + 1] if items else [0]
    sorted_original = sorted(items)
    sorted_with_extra = sorted(with_extra)

    # Original elements should appear in same relative order
    assert sorted_original == [x for x in sorted_with_extra if x in sorted_original]
```

**Differential Testing:**
```typescript
// Test two implementations against each other
fc.assert(
  fc.property(fc.array(fc.integer()), (arr) => {
    const result1 = optimizedSort(arr);
    const result2 = naiveSort(arr);
    return JSON.stringify(result1) === JSON.stringify(result2);
  })
);
```

### 10. Integration with CI/CD

**pytest.ini (Hypothesis):**
```ini
[pytest]
addopts =
    --hypothesis-show-statistics
    --hypothesis-seed=0

[hypothesis]
max_examples = 200
deadline = None
```

**package.json (fast-check):**
```json
{
  "scripts": {
    "test": "jest",
    "test:property": "jest --testNamePattern='property'",
    "test:verbose": "jest --verbose"
  }
}
```

**GitHub Actions:**
```yaml
name: Property Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm ci
      - name: Run property tests
        run: npm run test:property
```

### 11. Debugging Failed Properties

**Hypothesis:**
```python
from hypothesis import given, strategies as st, example

@given(st.integers())
@example(0)  # Add specific examples to always test
@example(-1)
@example(999999)
def test_with_examples(x):
    assert process(x) >= 0

# Run with verbose output
# pytest --hypothesis-verbosity=verbose test_file.py
```

**fast-check:**
```typescript
fc.assert(
  fc.property(fc.integer(), (x) => {
    // Use fc.pre for preconditions
    fc.pre(x !== 0);
    return 100 / x > 0;
  }),
  {
    seed: 1234567890,  // Reproduce exact failure
    path: "0:1:2",     // Replay specific path
    verbose: true
  }
);
```

### 12. Generate Test Report

Create a summary of property tests:

```markdown
# Property-Based Test Report

## Coverage
- Functions tested: 15
- Properties verified: 42
- Test cases generated: 50,000+
- Edge cases found: 8

## Properties Tested

### sort_list
- ✅ Preserves length
- ✅ Creates ordered output
- ✅ Preserves all elements
- ✅ Handles empty lists
- ✅ Handles duplicates

### encode_decode
- ✅ Roundtrip property (decode(encode(x)) === x)
- ✅ Handles special characters
- ✅ Preserves data types

### merge_sorted_arrays
- ✅ Output is sorted
- ✅ Contains all elements
- ✅ Length equals sum of inputs

## Bugs Found
1. Division by zero in calculation (fixed)
2. Off-by-one error in array indexing (fixed)
3. Unicode handling issue in string processing (fixed)

## Recommendations
- Add property tests for user authentication flow
- Test database query builder invariants
- Add metamorphic tests for caching layer
```

## Checklist

- [ ] Property-based testing library installed
- [ ] Function invariants identified
- [ ] Basic properties implemented
- [ ] Edge cases covered
- [ ] Shrinking verified
- [ ] CI/CD integration added
- [ ] Documentation updated
- [ ] Team trained on property-based testing
