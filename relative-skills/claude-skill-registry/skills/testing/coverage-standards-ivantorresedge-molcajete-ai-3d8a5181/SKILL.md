---
name: coverage-standards
description: Coverage thresholds and reporting. Use when analyzing and improving test coverage.
---

# Coverage Standards Skill

This skill covers test coverage standards and analysis.

## When to Use

Use this skill when:
- Setting coverage thresholds
- Analyzing coverage reports
- Improving test coverage
- Configuring CI coverage gates

## Core Principle

**COVERAGE IS A MINIMUM, NOT A GOAL** - 80% coverage is a floor, not a ceiling. Focus on testing critical paths.

## Coverage Thresholds

### Minimum Requirements

| Metric | Threshold |
|--------|-----------|
| Lines | 80% |
| Functions | 80% |
| Branches | 80% |
| Statements | 80% |

### Vitest Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
```

## Coverage Metrics Explained

### Lines Coverage

Percentage of executable lines that were run during tests.

```typescript
function example(x: number): number {
  if (x > 0) {         // Line 1
    return x * 2;      // Line 2 - only covered if x > 0
  }
  return 0;            // Line 3 - only covered if x <= 0
}
```

### Branch Coverage

Percentage of decision branches (if/else, switch, ternary) that were taken.

```typescript
function example(x: number): string {
  // Two branches: true and false
  if (x > 0) {
    return 'positive';  // Branch 1
  } else {
    return 'non-positive';  // Branch 2
  }
}

// Need both tests for 100% branch coverage
test('positive', () => expect(example(1)).toBe('positive'));
test('non-positive', () => expect(example(0)).toBe('non-positive'));
```

### Function Coverage

Percentage of functions that were called at least once.

### Statement Coverage

Percentage of statements that were executed.

## Coverage Exclusions

### Valid Exclusions

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      exclude: [
        'node_modules/',
        'dist/',
        '**/*.test.ts',
        '**/__tests__/**',
        '**/__mocks__/**',
        '**/*.d.ts',
        '**/types/**',
        '**/index.ts',  // Re-export files
        '**/generated/**',  // Generated code
      ],
    },
  },
});
```

### Inline Exclusions

```typescript
/* v8 ignore next */
function debugOnly(): void {
  console.log('debug');
}

/* v8 ignore start */
function untestableCode(): void {
  // Platform-specific code
}
/* v8 ignore stop */
```

## Coverage Reports

### Report Types

```typescript
export default defineConfig({
  test: {
    coverage: {
      reporter: [
        'text',      // Terminal output
        'html',      // HTML report
        'json',      // JSON for tools
        'lcov',      // For coverage services
        'cobertura', // For CI systems
      ],
      reportsDirectory: './coverage',
    },
  },
});
```

### Viewing Reports

```bash
# Generate coverage
npm run test:coverage

# View HTML report
open coverage/index.html
```

## Improving Coverage

### Identify Gaps

1. Run coverage report
2. Check HTML report for red (uncovered) lines
3. Prioritize critical paths
4. Add tests for uncovered branches

### Common Uncovered Patterns

#### Error Handling

```typescript
// Often uncovered
function fetchData(): Promise<Data> {
  try {
    return await api.get('/data');
  } catch (error) {
    // This branch often uncovered
    throw new ApiError('Failed to fetch');
  }
}

// Test the error path
it('should throw on API error', async () => {
  vi.mocked(api.get).mockRejectedValue(new Error('Network'));
  await expect(fetchData()).rejects.toThrow('Failed to fetch');
});
```

#### Edge Cases

```typescript
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero');  // Often uncovered
  }
  return a / b;
}

// Test edge case
it('should throw for division by zero', () => {
  expect(() => divide(1, 0)).toThrow('Division by zero');
});
```

#### Guard Clauses

```typescript
function processUser(user: User | null): string {
  if (!user) {
    return 'No user';  // Test this branch
  }
  return user.name;
}
```

## Coverage Anti-Patterns

### Testing Implementation Details

```typescript
// ❌ Bad - tests internal state
it('should set internal flag', () => {
  service.process();
  expect(service._internalFlag).toBe(true);
});

// ✅ Good - tests behavior
it('should produce expected output', () => {
  const result = service.process();
  expect(result).toEqual(expected);
});
```

### Coverage Without Assertions

```typescript
// ❌ Bad - covers code but doesn't verify
it('should run without errors', () => {
  const result = processData(input);
  // No assertions!
});

// ✅ Good - verifies behavior
it('should transform data correctly', () => {
  const result = processData(input);
  expect(result).toEqual(expectedOutput);
});
```

### Chasing 100% Coverage

```typescript
// Not everything needs testing
/* v8 ignore next */
if (process.env.DEBUG) {
  console.log('Debug info');
}
```

## CI Integration

### GitHub Actions

```yaml
- name: Run tests with coverage
  run: npm run test:coverage

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    files: ./coverage/lcov.info
    fail_ci_if_error: true
```

### Coverage Comments on PRs

```yaml
- name: Coverage Report
  uses: davelosert/vitest-coverage-report-action@v2
```

## Best Practices Summary

1. **80% is minimum** - Aim higher for critical code
2. **Test behavior** - Not just for coverage numbers
3. **Exclude generated code** - Don't inflate metrics
4. **Cover error paths** - Critical for reliability
5. **Review coverage drops** - Investigate regressions
6. **Don't chase 100%** - Focus on value
7. **Use coverage in CI** - Catch regressions early

## Code Review Checklist

- [ ] Coverage thresholds configured
- [ ] All coverage metrics meet 80%
- [ ] Error paths tested
- [ ] Edge cases covered
- [ ] No coverage-only tests
- [ ] Valid exclusions documented
- [ ] CI coverage gate enabled
