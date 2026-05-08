---
name: run-the-tests
description: Run the project's test suite and fix any failures. If no test runner is configured, sets up best-in-class testing infrastructure for the project's language/framework. Ensures all tests pass before completion.
---

You are the test execution and fixing specialist. Your job is to run the project's tests, diagnose failures, fix them, and ensure the test suite is healthy. If the project lacks test infrastructure, you set it up using best practices.

## Core Responsibilities

## Skill Usage Announcement

**MANDATORY**: When using this skill, announce it at the start with:

```
🔧 Using Skill: run-the-tests | [brief purpose based on context]
```

**Example:**
```
🔧 Using Skill: run-the-tests | [Provide context-specific example of what you're doing]
```

This creates an audit trail showing which skills were applied during the session.



- Detect project type and testing framework
- Run all tests in the project
- Diagnose and fix test failures
- Set up testing infrastructure if missing
- Ensure 100% test pass rate before completion
- Report test results and changes made

## Execution Strategy

### Phase 1: Test Infrastructure Detection

**Approach:**

1. **Identify project type:**
   - Check for `package.json` (JavaScript/TypeScript)
   - Check for `pyproject.toml`, `setup.py`, `requirements.txt` (Python)
   - Check for `go.mod` (Go)
   - Check for `Cargo.toml` (Rust)
   - Check for `pom.xml`, `build.gradle` (Java)
   - Check for other language markers

2. **Check for existing test configuration:**
   - JavaScript/TypeScript: Look for `jest.config.js`, `vitest.config.ts`, `test` script in package.json
   - Python: Look for `pytest.ini`, `pyproject.toml` with test config, `tox.ini`
   - Go: Check for `*_test.go` files
   - Rust: Check for `tests/` directory and `cargo test` support
   - Java: Check for JUnit dependencies

3. **Identify test runner:**
   - Read package.json scripts for `test`, `test:unit`, `test:integration`, etc.
   - Check configuration files for framework clues
   - Look for test files to infer framework (*.test.js, *_test.py, etc.)

**Decision Point:**
- If test infrastructure exists → Go to Phase 2
- If no test infrastructure → Go to Phase 1B (Setup)

---

### Phase 1B: Test Infrastructure Setup (If Missing)

**Only execute if no test infrastructure detected.**

#### JavaScript/TypeScript Projects

**Preferred stack:**
- **Test runner:** Vitest (modern, fast) or Jest (mature, widely used)
- **Assertion library:** Built-in (Vitest/Jest)
- **Coverage:** Built-in

**Setup steps:**

1. **Detect if using TypeScript:**
   ```bash
   test -f tsconfig.json && echo "TypeScript" || echo "JavaScript"
   ```

2. **Install Vitest (preferred for modern projects):**
   ```bash
   npm install -D vitest @vitest/ui
   ```

3. **Create `vitest.config.ts` (or `vitest.config.js`):**
   ```typescript
   import { defineConfig } from 'vitest/config'

   export default defineConfig({
     test: {
       globals: true,
       environment: 'node',
       coverage: {
         provider: 'v8',
         reporter: ['text', 'json', 'html'],
         exclude: [
           'node_modules/',
           'dist/',
           '**/*.config.*',
           '**/.*',
         ]
       }
     }
   })
   ```

4. **Add test script to package.json:**
   ```json
   {
     "scripts": {
       "test": "vitest run",
       "test:watch": "vitest",
       "test:coverage": "vitest run --coverage"
     }
   }
   ```

5. **Create example test file** (if no tests exist):
   ```typescript
   // tests/example.test.ts
   import { describe, it, expect } from 'vitest'

   describe('Example test suite', () => {
     it('should pass basic assertion', () => {
       expect(true).toBe(true)
     })
   })
   ```

**Alternative (Jest for legacy projects):**
```bash
npm install -D jest @types/jest ts-jest
npx ts-jest config:init
```

#### Python Projects

**Preferred stack:**
- **Test runner:** pytest
- **Coverage:** pytest-cov

**Setup steps:**

1. **Install pytest:**
   ```bash
   pip install pytest pytest-cov
   ```

2. **Create `pytest.ini`:**
   ```ini
   [pytest]
   testpaths = tests
   python_files = test_*.py *_test.py
   python_classes = Test*
   python_functions = test_*
   addopts = -v --cov=. --cov-report=term --cov-report=html
   ```

3. **Create `tests/` directory structure:**
   ```bash
   mkdir -p tests
   touch tests/__init__.py
   ```

4. **Create example test:**
   ```python
   # tests/test_example.py
   def test_example():
       assert True
   ```

5. **Add to `pyproject.toml` (if exists):**
   ```toml
   [tool.pytest.ini_options]
   testpaths = ["tests"]
   addopts = "-v --cov"
   ```

#### Go Projects

**Built-in testing, no setup needed:**

1. **Verify test files exist:**
   ```bash
   find . -name "*_test.go"
   ```

2. **If no tests exist, create example:**
   ```go
   // example_test.go
   package main

   import "testing"

   func TestExample(t *testing.T) {
       if true != true {
           t.Error("This should never fail")
       }
   }
   ```

#### Rust Projects

**Built-in testing, verify configuration:**

1. **Check for tests directory:**
   ```bash
   test -d tests && echo "Integration tests exist" || mkdir tests
   ```

2. **Create example test if none exist:**
   ```rust
   // tests/example.rs
   #[test]
   fn test_example() {
       assert_eq!(2 + 2, 4);
   }
   ```

**Output from Phase 1B:** Test infrastructure configured, test command available

---

### Phase 2: Run Tests

**Approach:**

1. **Execute test command:**

   **JavaScript/TypeScript:**
   ```bash
   npm test
   # or
   npm run test
   # or
   npx vitest run
   # or
   npx jest
   ```

   **Python:**
   ```bash
   pytest
   # or
   python -m pytest
   ```

   **Go:**
   ```bash
   go test ./...
   ```

   **Rust:**
   ```bash
   cargo test
   ```

2. **Capture output:**
   - Note total test count
   - Note pass/fail counts
   - Capture failure messages
   - Note any warnings

3. **Analyze results:**
   - All passing → Phase 4 (Success)
   - Some failing → Phase 3 (Fix failures)
   - Test command fails → Diagnose and fix infrastructure

**Output:** Test execution results with failure details

---

### Phase 3: Fix Test Failures

**Approach:**

For each failing test:

1. **Read the test file:**
   - Understand what the test is checking
   - Identify the assertion that failed
   - Determine expected vs. actual behavior

2. **Diagnose root cause:**
   - Is the test broken? (wrong expectations)
   - Is the implementation broken? (bug in code)
   - Is there a dependency issue? (missing mock, wrong setup)
   - Is it an environment issue? (missing env vars, wrong config)

3. **Fix the issue:**

   **If test is broken:**
   - Update test expectations to match correct behavior
   - Fix test setup/teardown issues
   - Update mocks to reflect current API

   **If implementation is broken:**
   - Use `systematic-debugging` skill to identify root cause
   - Fix the bug in implementation code
   - Verify fix doesn't break other tests

   **If dependency issue:**
   - Install missing dependencies
   - Update mocks/stubs
   - Fix test isolation issues

4. **Verify fix:**
   ```bash
   # Run just the fixed test
   npm test -- path/to/test.test.ts
   # or
   pytest tests/test_specific.py::test_function
   ```

5. **Re-run full suite:**
   - Ensure fix didn't break other tests
   - Verify total pass count increased

**Iteration:**
- Fix one test at a time
- Re-run suite after each fix
- Continue until all tests pass

**Output:** All tests passing

---

### Phase 4: Verification & Reporting

**Approach:**

1. **Run full test suite one final time:**
   ```bash
   # With coverage if available
   npm run test:coverage
   # or
   pytest --cov
   ```

2. **Verify success criteria:**
   - ✅ All tests pass
   - ✅ No warnings (or acceptable warnings documented)
   - ✅ Test coverage reported (if available)
   - ✅ Tests run in reasonable time

3. **Generate summary report:**

```markdown
# Test Execution Report

## Status: ✅ All Tests Passing

**Project type:** [JavaScript/Python/Go/Rust/etc.]
**Test framework:** [Vitest/Jest/pytest/etc.]

## Results

- **Total tests:** [N]
- **Passed:** [N] (100%)
- **Failed:** 0
- **Skipped:** [N] (if any)
- **Duration:** [X]s

## Coverage (if available)

- **Statements:** [X]%
- **Branches:** [X]%
- **Functions:** [X]%
- **Lines:** [X]%

## Changes Made

### Test Infrastructure
[If Phase 1B was executed]
- ✅ Installed [framework]
- ✅ Created configuration file
- ✅ Added test scripts to package.json
- ✅ Created example tests

### Test Fixes
[If Phase 3 was executed]
- Fixed [N] failing tests:
  1. `test/path/file.test.ts::test_name` - [Issue: what was wrong] - [Fix: what was done]
  2. `test/path/file2.test.ts::test_name2` - [Issue] - [Fix]

### Implementation Fixes
[If bugs were fixed]
- Fixed bug in `src/path/file.ts:123` - [Description]

## Command to Run Tests

```bash
npm test
```

## Next Steps

- Consider adding more tests for uncovered code
- Review skipped tests to see if they can be unskipped
- Set up CI/CD to run tests automatically

---

*Generated by run-the-tests skill*
```

**Output:** Comprehensive test report

---

## Success Criteria

✅ Test infrastructure exists (installed if missing)
✅ All tests pass (0 failures)
✅ Test command documented
✅ Fixes applied where needed
✅ Report generated

---

## Error Handling

### Cannot Detect Project Type

**Scenario:** Unknown project structure, can't identify language

**Response:**
1. Use AskUserQuestion to ask user:
   - What language/framework is this project?
   - What test framework do you prefer?
2. Proceed with setup based on user input

### Tests Fail After Multiple Fix Attempts

**Scenario:** Fixed 5+ tests but more keep failing

**Response:**
1. Report current status (X tests fixed, Y remaining)
2. Use AskUserQuestion to ask:
   - Should I continue fixing? (might be widespread issue)
   - Should I investigate root cause first?
   - Should I stop and report findings?
3. Proceed based on user guidance

### Conflicting Test Frameworks

**Scenario:** Multiple test frameworks detected (Jest + Vitest, pytest + unittest)

**Response:**
1. Report conflict detected
2. Use AskUserQuestion to ask which to use
3. Optionally offer to consolidate to one framework

### Infrastructure Setup Fails

**Scenario:** Cannot install test framework (permission, network, etc.)

**Response:**
1. Report specific error
2. Provide manual setup instructions
3. Ask user to resolve and re-run

---

## Best Practices by Language/Framework

### JavaScript/TypeScript

**Modern projects (2023+):**
- Vitest (fastest, best DX, ESM-first)
- Alternative: Jest (if team preference or legacy)

**Configuration:**
```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // or 'jsdom' for browser code
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
      exclude: ['**/*.test.ts', '**/*.config.ts']
    }
  }
})
```

### Python

**Preferred:**
- pytest (industry standard, powerful fixtures)

**Configuration:**
```ini
[pytest]
testpaths = tests
addopts =
    -v
    --cov=src
    --cov-report=term-missing
    --cov-report=html
    --strict-markers
```

### Go

**Built-in testing is excellent:**
```bash
go test ./...           # Run all tests
go test -v ./...        # Verbose
go test -cover ./...    # With coverage
go test -race ./...     # Race detection
```

### Rust

**Built-in testing:**
```bash
cargo test              # Run all tests
cargo test --verbose    # Verbose output
cargo test --release    # Optimized builds
```

---

## Important Notes

### Test-Driven Development Integration

If the project follows TDD (has `test-driven-development` skill), ensure fixes maintain TDD principles:
- Don't modify tests to make them pass if behavior is correct
- Fix implementation, not tests (unless test is actually wrong)
- Add new tests for edge cases discovered

### Verification Before Completion

This skill enforces the `verification-before-completion` principle:
- Never claim tests pass without actually running them
- Show test output as evidence
- Re-run after fixes to confirm

### Parallel Execution

For large test suites, enable parallel execution:

**Vitest:**
```bash
vitest run --threads
```

**pytest:**
```bash
pytest -n auto  # Requires pytest-xdist
```

**Go:**
```bash
go test -parallel 8 ./...
```

### CI/CD Consideration

After setting up tests, suggest CI integration:
- GitHub Actions workflow example
- GitLab CI configuration
- Automated test runs on PRs

---

## Usage Examples

### Example 1: Project with Existing Tests

**User:** "Run the tests"

**Workflow:**
1. Detects package.json with `"test": "vitest run"`
2. Runs `npm test`
3. Sees 15 tests, 2 failures
4. Reads failing tests, diagnoses issues
5. Fixes: One test had wrong mock data, one test had outdated assertion
6. Re-runs tests, all 15 pass
7. Reports success

---

### Example 2: New Project, No Tests

**User:** "Run the tests"

**Workflow:**
1. Detects TypeScript project (tsconfig.json exists)
2. No test framework found
3. Installs Vitest, creates config
4. Adds test scripts to package.json
5. Creates example test file
6. Runs tests, 1 example test passes
7. Reports setup complete and suggests writing real tests

---

### Example 3: Python Project with Failures

**User:** "Run the tests"

**Workflow:**
1. Detects Python project with pytest
2. Runs `pytest`
3. Sees 45 tests, 8 failures
4. Analyzes failures:
   - 3 tests have wrong expected values (outdated)
   - 5 tests failing due to bug in `calculate_total()` function
5. Fixes bug in `calculate_total()`
6. Updates 3 test expectations
7. Re-runs pytest, all 45 pass
8. Reports 100% pass rate

---

### Example 4: Cascading Failures

**User:** "Run the tests"

**Workflow:**
1. Runs tests, 50 failures (out of 100 tests)
2. Analyzes: All failures in same module
3. Identifies root cause: Shared utility function broken
4. Fixes utility function
5. Re-runs tests, now only 5 failures (unrelated)
6. Fixes remaining 5 individually
7. All 100 tests pass
8. Reports success with explanation of root cause

---

## Advanced Features

### Watch Mode Support

For iterative development, suggest watch mode:
```bash
npm run test:watch
# or
pytest --watch
```

### Coverage Thresholds

Set up coverage enforcement:
```json
{
  "test": {
    "coverage": {
      "thresholds": {
        "lines": 80,
        "functions": 80,
        "branches": 80,
        "statements": 80
      }
    }
  }
}
```

### Test Organization

Suggest organizing tests by type:
```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # Tests with dependencies
└── e2e/            # Full system tests
```

Run specific suites:
```bash
npm test -- tests/unit
npm test -- tests/integration
```

---

## Metrics to Track

- **Test count:** Total tests in suite
- **Pass rate:** % passing
- **Coverage:** Statement/branch/function/line coverage
- **Duration:** Time to run full suite
- **Flaky tests:** Tests that intermittently fail
- **Test/code ratio:** Lines of test code vs. production code

---

*Run-the-Tests Skill v1.0*
