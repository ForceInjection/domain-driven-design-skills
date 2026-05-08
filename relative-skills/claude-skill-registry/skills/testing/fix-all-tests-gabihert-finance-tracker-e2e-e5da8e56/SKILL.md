---
name: fix-all-tests
description: Systematically fixes all failing tests in a project by running test commands repeatedly until 100% pass with zero warnings. Use when tests are failing, validation is not passing, or when asked to fix test suites. Works with any testing framework (Jest, Pytest, Go test, etc.) and ensures complete test compliance without skipping or modifying tests.
---

# Fix All Tests

Ensure ALL tests pass by running test validation commands repeatedly until every single test passes successfully with ZERO warnings.

## Core Mission

Run test commands iteratively, fix all failures and warnings, and achieve 100% test success without modifying or skipping any tests.

## 🚫 Absolutely Forbidden Actions

**NEVER DO THESE:**
- **DO NOT SKIP ANY TESTS** - All tests must run
- **DO NOT IGNORE WARNINGS** - All warnings must be fixed
- **DO NOT DELETE ANY TESTS** - All tests must remain intact
- **DO NOT COMMENT OUT TESTS** - All tests must stay active
- **DO NOT MODIFY TEST EXPECTATIONS** - Fix the code, not the tests
- **DO NOT USE TEST SKIP FUNCTIONS** - No `test.skip()`, `describe.skip()`, `xit()`, `it.skip()`, `@pytest.mark.skip`, etc.

## ✅ Required Workflow

### Step 1: Identify Test Command

Determine the appropriate test command based on the project:

**Common Commands:**
- `npm run validate` - Full validation suite
- `npm test` - Node.js projects
- `pytest` - Python projects
- `go test ./...` - Go projects
- `mvn test` - Java Maven projects
- `gradle test` - Java Gradle projects
- `rspec` - Ruby projects
- `cargo test` - Rust projects

Look for test scripts in:
- `package.json` (scripts section)
- `Makefile`
- `tox.ini`
- `setup.cfg`
- Project documentation

### Step 2: Run Initial Test Suite

Execute the test command and capture:
- Total test count
- Passing tests
- Failing tests
- Warnings count
- Error messages
- Stack traces

### Step 3: Analyze Failures

For each failure:
1. **Read the error message carefully**
2. **Identify the error type** (assertion, type error, import error, etc.)
3. **Locate the failing code** (not the test)
4. **Understand what the test expects**
5. **Determine why the implementation fails**

For each warning:
1. **Identify warning type** (deprecation, linting, security)
2. **Locate the source of the warning**
3. **Determine the fix needed**

### Step 4: Fix Implementation Code

**Fix Priority Order:**
1. **Syntax errors** - Prevents all tests from running
2. **Import/Module errors** - Blocks test execution
3. **Type errors** - Clear failure points
4. **Assertion failures** - Logic errors
5. **Async/Promise errors** - Timing issues
6. **Warnings** - Clean up after tests pass

**How to Fix:**
- Modify source code, NOT test files
- Fix the root cause, not symptoms
- Handle edge cases properly
- Ensure type safety
- Add proper error handling

### Step 5: Re-run Tests

After each fix:
1. Run the test command again
2. Verify the fixed tests now pass
3. Check if new failures appeared
4. Count remaining failures and warnings

### Step 6: Iterate Until Success

Continue the cycle:
```
Run Tests → Analyze Failures → Fix Code → Re-run Tests
```

**Success Criteria:**
- ✅ All tests passing (100%)
- ✅ Zero failures
- ✅ Zero warnings
- ✅ Clean validation output

## Common Fix Patterns

### Assertion Failures
```javascript
// Test expects:
expect(add(2, 3)).toBe(5);

// If failing, fix the implementation:
function add(a, b) {
  return a + b; // Fix logic here
}
```

### Type Errors
```typescript
// Test expects string, getting number
// Fix: Ensure correct return type
function getName(): string {
  return String(value); // Convert to expected type
}
```

### Async Issues
```javascript
// Test timing out?
// Fix: Add proper async handling
async function fetchData() {
  return await api.getData(); // Don't forget await
}
```

### Missing Dependencies
```python
# ImportError?
# Fix: Install package or fix import path
pip install missing-package
# or fix: from correct.module import function
```

## Framework-Specific Tips

### JavaScript/TypeScript (Jest, Vitest, Mocha)
- Clear Jest cache if tests behave oddly: `jest --clearCache`
- Check for missing await keywords in async tests
- Verify mock implementations match expected interfaces
- Ensure test environment matches production

### Python (Pytest, Unittest)
- Use `-vv` for verbose output
- Check fixture scopes and dependencies
- Verify virtual environment has all packages
- Watch for indentation errors

### Go
- Run with `-v` flag for verbose output
- Check for race conditions with `-race`
- Ensure all goroutines complete
- Verify defer statements execute properly

## Debugging Strategies

1. **Isolate failures**: Run single test files to focus on specific issues
2. **Add logging**: Temporarily add console.log/print statements to understand flow
3. **Check recent changes**: Use git diff to see what changed
4. **Verify environment**: Ensure all dependencies are installed and configured
5. **Read test names**: Test names often describe expected behavior

## Reference Documentation

For detailed patterns and error messages, consult:
- [references/common-test-patterns.md](references/common-test-patterns.md) - Common test patterns and fixes
- [references/error-patterns.md](references/error-patterns.md) - Error message patterns and solutions

## Success Indicators

You've succeeded when you see output like:
```
✓ All tests passing (247/247)
✓ No warnings
✓ 100% validation success
```

Or:
```
Test Suites: 15 passed, 15 total
Tests: 247 passed, 247 total
Warnings: 0
```

## Important Reminders

- **Tests passing with warnings is NOT acceptable** - Fix all warnings
- **Never give up** - Keep iterating until 100% success
- **Fix the implementation, not the tests** - Tests define expected behavior
- **All tests must remain active** - No skipping or disabling
- **Success means ZERO failures and ZERO warnings**

The goal is complete test suite success with absolutely no compromises.
