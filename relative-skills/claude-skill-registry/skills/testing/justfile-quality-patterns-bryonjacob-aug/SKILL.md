---
name: justfile-quality-patterns
description: Level 1 patterns - test-watch, integration-test, complexity, loc, duplicates, slowtests
---

# Quality Patterns (Level 1)

Add when CI matters. Fast feedback, test separation, complexity analysis, duplicate detection, test performance.

## Commands

### test-watch

Continuous test execution on file changes.

```just
# Run tests in watch mode
test-watch:
    <continuous test execution on file changes>
```

**Python:**
```just
test-watch:
    uv run pytest-watch -v -m "not integration"
```

**JavaScript:**
```just
test-watch:
    pnpm vitest watch --project unit
```

### integration-test

Integration tests. No coverage threshold. Never blocks merge.

```just
# Run integration tests with coverage report (no threshold)
integration-test:
    <integration tests (marked/tagged), report only, never blocks>
```

**Python:**
```just
integration-test:
    uv run pytest -v -m "integration" --durations=10
```

**JavaScript:**
```just
integration-test:
    pnpm exec playwright test
```

**Java:**
```just
integration-test:
    mvn failsafe:integration-test
```

**Key:** Marked/tagged tests. Report coverage, no threshold. Never in check-all.

### complexity

Detailed complexity report. Informational, not blocking.

```just
# Detailed complexity report for refactoring decisions
complexity:
    <per-function/class complexity, informational, does not block>
```

**Python:**
```just
complexity:
    uv run radon cc . -a -nc
```

**JavaScript:**
```just
complexity:
    pnpm exec eslint . --ext .ts,.tsx --format complexity
```

**Java:**
```just
complexity:
    mvn pmd:pmd
    cat target/pmd.xml
```

### loc

Show N largest files by lines of code.

```just
# Show N largest files by lines of code
loc N="20":
    <show N largest files by LOC, sorted descending>
```

**Universal (works all stacks):**
```just
loc N="20":
    find . -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.java" | \
      xargs wc -l | sort -rn | head -n {{N}}
```

### duplicates

Find duplicate code blocks. Informational, not blocking.

```just
# Find duplicate code blocks
duplicates:
    <detect copy-paste code, threshold 30%, informational>
```

**Universal (requires jscpd):**
```just
duplicates:
    jscpd . --threshold 30 --min-lines 5 --reporters console
```

**Configuration:** `.jscpd.json`
```json
{
  "threshold": 30,
  "minLines": 5,
  "minTokens": 50,
  "ignore": [
    "node_modules/**",
    "dist/**",
    "build/**",
    "**/*.test.js",
    "**/*.test.ts",
    "**/*_test.py",
    "**/*Test.java"
  ],
  "reporters": ["console", "json"],
  "format": ["javascript", "typescript", "python", "java"]
}
```

**Install:**
- `npm install -g jscpd` (global)
- Or: `npx jscpd` (no install)

**Key:** Detects copy-paste opportunities. Used by `/refactor` analysis.

### slowtests

Show tests slower than threshold. Identifies optimization targets.

```just
# Show tests slower than N milliseconds
slowtests N="50":
    <run tests, filter by duration > N ms>
```

**Python:**
```just
slowtests N="50":
    pytest -v --durations=0 | python -c "import sys; [print(l) for l in sys.stdin if any(int(t.split('.')[0]) > int('{{N}}') for t in l.split() if t.endswith('s'))]"
```

**JavaScript:**
```just
slowtests N="50":
    vitest run --reporter=verbose --reporter=json --outputFile=.test-results.json && \
    jq -r '.testResults[].assertionResults[] | select(.duration > {{N}}) | "\(.title): \(.duration)ms"' .test-results.json
```

**Java:**
```just
slowtests N="50":
    mvn test | grep "Time elapsed:" | awk -v n={{N}} '{ split($4,a,"."); if(a[1]*1000+a[2] > n) print $0 }'
```

**Key:** Identifies slow tests for optimization. Target: unit tests <50ms.

### test-profile

Run tests with detailed timing information.

```just
# Profile all tests with detailed timing
test-profile:
    <run all tests with comprehensive timing data>
```

**Python:**
```just
test-profile:
    pytest -v --durations=0 --cov=. --cov-report=term-missing
```

**JavaScript:**
```just
test-profile:
    vitest run --reporter=verbose --coverage
```

**Java:**
```just
test-profile:
    mvn test -X
```

**Key:** Full diagnostic timing. Use to analyze test suite performance.

## Test Separation Philosophy

**Unit tests (unmarked):**
- Fast (< 5s total)
- No external dependencies
- 96% coverage threshold
- Block merge if fail
- Run in CI every commit
- Run in pre-commit hook

**Integration tests (marked/tagged):**
- Slower (> 10s, possibly minutes)
- Require external services
- Coverage reported, no threshold
- Never block merge
- Run in CI, don't fail build
- Optional in pre-commit

**Rationale:** Quality gates must be fast. Integration tests validate but shouldn't slow feedback loop.

## Markers/Tags

**Python (`pytest.ini`):**
```ini
[pytest]
markers =
    integration: Integration tests requiring external services
    unit: Fast unit tests (default, unmarked)
```

**JavaScript (file naming):**
```
src/lib/**/*.test.ts          # Unit tests
src/components/**/*.test.tsx  # Component tests
tests/integration/**/*.spec.ts # Integration tests (Playwright)
```

**Java (JUnit tags):**
```java
@Tag("integration")
@Test
void testDatabaseConnection() { }
```

## Coverage Thresholds

**Unit tests:** 96% (blocks merge)
**Integration tests:** Report only (no threshold)

**Why 96%?**
- 100% impractical (edge cases, defensive code)
- 90% too permissive
- 96% forces thinking, allows rare exceptions

## When to Add Level 1

Add when:
- Setting up CI/CD
- Multiple developers
- Need fast local feedback (test-watch)
- Integration tests exist (separate from unit)
- Identifying code quality issues (complexity, duplicates)
- Optimizing test suite performance (slowtests, test-profile)

Skip when:
- Solo project, no CI
- No integration tests yet
- Test suite already fast (<5s)
- Prefer simplicity over thoroughness
