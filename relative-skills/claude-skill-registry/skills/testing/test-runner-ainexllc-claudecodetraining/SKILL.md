---
name: test-runner
description: Run tests with Jest, Vitest, or Playwright, fix failing tests, and generate missing test coverage. Use when user says "run tests", "test this", "fix failing tests", "write tests", or when tests need to be executed or created.
allowed-tools: Bash, Read, Edit, Write, Glob
---

# Test Runner

## When to Use

Activate this skill when:
- User requests to "run tests" or "test this"
- User says "fix failing tests" or "debug test"
- User mentions "jest", "vitest", "playwright", or "testing"
- User asks to "write tests" or "add test coverage"
- User says "check tests" or "verify tests pass"
- CI/CD pipeline shows test failures
- User wants to "test a component" or "test a function"
- User requests "coverage report" or "test coverage"

## Instructions

### Step 1: Detect Test Framework

1. Check package.json for test frameworks:
```bash
cat package.json | grep -E '"(jest|vitest|playwright|mocha|jasmine|cypress)"'
```

2. Look for test configuration files:
```bash
ls -la jest.config.* vitest.config.* playwright.config.* 2>/dev/null
```

3. Check for test scripts:
```bash
cat package.json | grep -E '"(test|test:unit|test:e2e|test:watch)"'
```

### Step 2: Identify Test Type

Determine what kind of tests to run:

- **Unit Tests**: Test individual functions/components (Jest/Vitest)
- **Integration Tests**: Test component interactions (Jest/Vitest)
- **E2E Tests**: Test full user flows (Playwright/Cypress)
- **Component Tests**: Test React/Vue components (Testing Library)

### Step 3: Run Tests

#### Run All Tests
```bash
npm test
# or
npm run test
# or
npm run test:unit
```

#### Run Specific Test File
```bash
# Jest/Vitest
npm test -- path/to/test.spec.ts
npx jest path/to/test.spec.ts
npx vitest path/to/test.spec.ts

# Playwright
npx playwright test path/to/test.spec.ts
```

#### Run Tests in Watch Mode
```bash
npm test -- --watch
npx jest --watch
npx vitest --watch
```

#### Run Tests with Coverage
```bash
npm test -- --coverage
npx jest --coverage
npx vitest --coverage
```

### Step 4: Analyze Test Results

1. Review output for:
   - Passing tests (✓)
   - Failing tests (✗)
   - Error messages
   - Stack traces
   - Coverage percentages

2. Identify failure patterns:
   - Assertion failures
   - Timeout errors
   - Missing mocks
   - Import errors
   - Type errors

### Step 5: Fix Failing Tests

#### Common Fixes:

1. **Assertion Failures**:
   - Review expected vs. actual values
   - Update assertions if behavior changed intentionally
   - Fix implementation if test is correct

2. **Timeout Errors**:
   - Increase timeout for slow operations
   - Add proper async/await handling
   - Mock slow operations

3. **Missing Mocks**:
   - Mock external dependencies
   - Mock API calls
   - Mock database operations

4. **Import Errors**:
   - Fix import paths
   - Update moduleNameMapper in jest.config.js
   - Install missing dependencies

### Step 6: Write New Tests (if requested)

1. Identify what needs testing
2. Choose appropriate test type
3. Create test file following naming convention:
   - `*.test.ts` or `*.spec.ts` for unit tests
   - `*.test.tsx` or `*.spec.tsx` for component tests
   - `*.e2e.ts` for E2E tests

4. Write test using framework's syntax

### Step 7: Verify All Tests Pass

```bash
npm test
```

Ensure:
- All tests pass (✓)
- No console errors
- Coverage meets requirements (if applicable)

## Examples

### Example 1: Run All Unit Tests

```bash
# Step 1: Check test scripts
cat package.json | grep '"test"'

# Step 2: Run tests
npm test

# Step 3: Review output
# ✓ should add two numbers (2 ms)
# ✓ should handle negative numbers (1 ms)
# Test Suites: 1 passed, 1 total
# Tests: 2 passed, 2 total
```

### Example 2: Fix Failing Test

```bash
# Step 1: Run tests and see failure
npm test

# Output:
# ✗ should return user data
#   Expected: { name: 'John', age: 30 }
#   Received: { name: 'John' }

# Step 2: Read test file
cat src/user.test.ts

# Step 3: Read implementation
cat src/user.ts

# Step 4: Fix implementation (missing age field)
# Use Edit tool to add age field to user object

# Step 5: Re-run tests
npm test

# Output:
# ✓ should return user data (3 ms)
```

### Example 3: Write New Component Test

```bash
# Step 1: Create test file
# File: src/components/Button.test.tsx

# Step 2: Write test
```

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('should render button text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('should call onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByText('Click me')).toBeDisabled();
  });
});
```

```bash
# Step 3: Run tests
npm test -- Button.test.tsx
```

### Example 4: Run E2E Tests with Playwright

```bash
# Step 1: Run all E2E tests
npx playwright test

# Step 2: Run specific test file
npx playwright test tests/login.spec.ts

# Step 3: Run in headed mode (see browser)
npx playwright test --headed

# Step 4: Debug specific test
npx playwright test --debug tests/login.spec.ts

# Step 5: View test report
npx playwright show-report
```

### Example 5: Generate Coverage Report

```bash
# Step 1: Run tests with coverage
npm test -- --coverage

# Output:
# -------------------|---------|----------|---------|---------|
# File               | % Stmts | % Branch | % Funcs | % Lines |
# -------------------|---------|----------|---------|---------|
# All files          |   85.71 |    66.67 |   83.33 |   85.71 |
#  user.ts           |   85.71 |    66.67 |   83.33 |   85.71 |
# -------------------|---------|----------|---------|---------|

# Step 2: Identify untested code
# Step 3: Write tests for uncovered lines
# Step 4: Re-run coverage
npm test -- --coverage
```

## Best Practices

### ✅ DO:
- Run tests before committing changes
- Write tests for new features immediately
- Fix failing tests before adding new ones
- Use descriptive test names (should/it statements)
- Test edge cases and error conditions
- Mock external dependencies (APIs, databases)
- Use setup/teardown (beforeEach/afterEach) for common code
- Keep tests focused and isolated
- Aim for high coverage on critical code
- Run full test suite before pushing

### ❌ DON'T:
- Don't skip failing tests (use .skip sparingly)
- Don't write flaky tests (tests that randomly fail)
- Don't test implementation details
- Don't make tests dependent on each other
- Don't hardcode dates/times without mocking
- Don't forget to clean up after tests
- Don't test third-party library code
- Don't write overly complex tests
- Don't ignore console warnings in tests

### Test Structure (AAA Pattern):

```typescript
test('should do something', () => {
  // Arrange: Set up test data
  const input = 'test';
  const expected = 'TEST';

  // Act: Execute the code being tested
  const result = toUpperCase(input);

  // Assert: Verify the result
  expect(result).toBe(expected);
});
```

### Common Jest/Vitest Matchers:

```typescript
// Equality
expect(value).toBe(expected);
expect(value).toEqual(expected);
expect(value).not.toBe(expected);

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeGreaterThanOrEqual(3.5);
expect(value).toBeLessThan(5);
expect(value).toBeLessThanOrEqual(4.5);
expect(value).toBeCloseTo(0.3); // For floating point

// Strings
expect(value).toMatch(/pattern/);
expect(value).toContain('substring');

// Arrays/Objects
expect(array).toContain(item);
expect(array).toHaveLength(3);
expect(obj).toHaveProperty('key');
expect(obj).toMatchObject({ key: 'value' });

// Functions
expect(fn).toThrow();
expect(fn).toThrow('error message');
expect(fn).toHaveBeenCalled();
expect(fn).toHaveBeenCalledWith(arg1, arg2);
expect(fn).toHaveBeenCalledTimes(2);
```

### Async Testing:

```typescript
// Using async/await
test('should fetch user data', async () => {
  const user = await fetchUser(1);
  expect(user.name).toBe('John');
});

// Using promises
test('should fetch user data', () => {
  return fetchUser(1).then(user => {
    expect(user.name).toBe('John');
  });
});

// Testing rejected promises
test('should handle error', async () => {
  await expect(fetchUser(-1)).rejects.toThrow('Invalid ID');
});
```

### Mocking:

```typescript
// Mock function
const mockFn = jest.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue('async value');

// Mock module
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ name: 'John' })
}));

// Spy on method
const spy = jest.spyOn(object, 'method');
```

## Test Checklist

Before running tests:
- [ ] All dependencies installed (npm install)
- [ ] Test framework configured
- [ ] Test files follow naming convention
- [ ] Mocks set up for external dependencies

When writing tests:
- [ ] Test file created with .test.ts or .spec.ts extension
- [ ] Tests are independent and isolated
- [ ] Edge cases covered
- [ ] Error cases tested
- [ ] Mocks used for external dependencies
- [ ] Async code properly awaited
- [ ] Clear test descriptions

After running tests:
- [ ] All tests pass (✓)
- [ ] No console errors or warnings
- [ ] Coverage meets requirements
- [ ] No flaky tests (run multiple times to verify)
- [ ] Test output is clear and informative

## Troubleshooting

**Issue**: Tests timeout
**Solution**: Increase timeout with `jest.setTimeout(10000)` or add `--testTimeout=10000` flag. Check for missing awaits.

**Issue**: "Cannot find module" error
**Solution**: Check import paths, install missing dependencies, or update `moduleNameMapper` in jest.config.js.

**Issue**: Mock not working
**Solution**: Ensure mock is defined before import. Use `jest.mock()` at top of file. Clear mocks between tests with `jest.clearAllMocks()`.

**Issue**: Tests pass locally but fail in CI
**Solution**: Check for environment-specific issues (timezone, file paths, env variables). Ensure same Node version.

**Issue**: Flaky tests (random failures)
**Solution**: Look for race conditions, missing awaits, or tests depending on execution order. Add proper waits.

**Issue**: Low coverage
**Solution**: Identify uncovered lines with `--coverage`. Write tests for critical paths first. Use coverage thresholds.

**Issue**: Tests too slow
**Solution**: Use `--maxWorkers=50%` to limit parallel workers. Mock expensive operations. Split into unit vs integration tests.

## Framework-Specific Commands

### Jest
```bash
# Run all tests
npm test

# Run specific file
npx jest path/to/test.spec.ts

# Run tests matching pattern
npx jest --testNamePattern="should fetch user"

# Watch mode
npx jest --watch

# Coverage
npx jest --coverage

# Update snapshots
npx jest --updateSnapshot

# Clear cache
npx jest --clearCache
```

### Vitest
```bash
# Run all tests
npx vitest

# Run specific file
npx vitest path/to/test.spec.ts

# Watch mode (default)
npx vitest

# Run once
npx vitest run

# Coverage
npx vitest --coverage

# UI mode
npx vitest --ui
```

### Playwright
```bash
# Run all tests
npx playwright test

# Run specific file
npx playwright test tests/login.spec.ts

# Headed mode
npx playwright test --headed

# Debug mode
npx playwright test --debug

# Specific browser
npx playwright test --project=chromium

# Generate tests
npx playwright codegen

# Show report
npx playwright show-report

# Install browsers
npx playwright install
```

## CI/CD Integration

```yaml
# GitHub Actions example
- name: Run tests
  run: npm test

- name: Run tests with coverage
  run: npm test -- --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/coverage-final.json
```

## Coverage Thresholds

`jest.config.js`:
```javascript
module.exports = {
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```
