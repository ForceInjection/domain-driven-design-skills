---
name: reviewing-vitest-config
description: Review Vitest configuration for deprecated patterns and best practices. Use when reviewing test configuration or vitest setup.
review: true
allowed-tools: [Read, Grep, Glob]
---

# Reviewing Vitest Config

This review skill validates Vitest configurations for deprecated patterns and best practices specific to Vitest 4.x.

## Review Scope

This skill reviews:

1. Pool configuration options
2. Coverage configuration
3. Workspace/project setup
4. Browser mode configuration
5. Dependency configuration
6. Reporter configuration
7. Import paths in test files

## Quick Review Checklist

### Pool Configuration
- [ ] No `maxThreads` or `maxForks` (use `maxWorkers`)
- [ ] No `singleThread` or `singleFork` (use `maxWorkers: 1, isolate: false`)
- [ ] No nested `poolOptions` (flatten to top-level)

### Coverage Configuration
- [ ] Has explicit `coverage.include` patterns
- [ ] No `coverage.ignoreEmptyLines`
- [ ] No `coverage.all`
- [ ] No `coverage.extensions`

### Workspace/Projects
- [ ] No `defineWorkspace` (use `defineConfig` with `projects`)
- [ ] No `poolMatchGlobs` or `environmentMatchGlobs`

### Browser Mode
- [ ] Provider imported from package
- [ ] Provider is function call: `playwright()`
- [ ] Uses `instances` array, not `browser.name`
- [ ] Test files use `vitest/browser`, not `@vitest/browser/context`

### Dependencies
- [ ] Dependencies under `server.deps`, not top-level `deps`

### Other
- [ ] No `reporters: ['basic']` (use `default` + `summary: false`)
- [ ] No `VITE_NODE_DEPS_MODULE_DIRECTORIES` in env
- [ ] No `vitest/execute` imports

## Common Issues

### Issue: maxThreads/maxForks Used

**Finding:**
```typescript
test: {
  maxThreads: 4,
}
```

**Severity:** Critical

**Remediation:**
```typescript
test: {
  maxWorkers: 4,
}
```

### Issue: Missing coverage.include

**Finding:**
```typescript
coverage: {
  provider: 'v8',
}
```

**Severity:** Critical

**Remediation:**
```typescript
coverage: {
  provider: 'v8',
  include: ['src/**/*.{ts,tsx}'],
}
```

### Issue: defineWorkspace Used

**Finding:**
```typescript
import { defineWorkspace } from 'vitest/config';

export default defineWorkspace([...]);
```

**Severity:** Critical

**Remediation:**
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    projects: [...],
  },
});
```

### Issue: Wrong Browser Import

**Finding:**
```typescript
import { page } from '@vitest/browser/context';
```

**Severity:** Critical

**Remediation:**
```typescript
import { page } from 'vitest/browser';
```

### Issue: Browser Provider Not Function

**Finding:**
```typescript
browser: {
  provider: 'playwright',
  name: 'chromium',
}
```

**Severity:** Critical

**Remediation:**
```typescript
import { playwright } from '@vitest/browser-playwright';

browser: {
  provider: playwright(),
  instances: [{ browser: 'chromium' }],
}
```

### Issue: deps Not Under server

**Finding:**
```typescript
test: {
  deps: {
    inline: ['vue'],
  },
}
```

**Severity:** Deprecated

**Remediation:**
```typescript
test: {
  server: {
    deps: {
      inline: ['vue'],
    },
  },
}
```

## Review Workflow

### Step 1: Find Config Files

```bash
glob "vitest.config.{ts,js,mts,mjs}"
glob "vite.config.{ts,js,mts,mjs}"
```

### Step 2: Check Pool Options

Search for deprecated options:
```bash
grep -E "(maxThreads|maxForks|singleThread|poolOptions)" vitest.config.ts
```

### Step 3: Check Coverage

Verify `include` patterns:
```bash
grep -A 10 "coverage:" vitest.config.ts | grep "include:"
```

### Step 4: Check Workspace

Search for deprecated workspace:
```bash
grep "defineWorkspace" vitest.config.ts
```

### Step 5: Check Browser Mode

Verify provider and instances:
```bash
grep -A 5 "browser:" vitest.config.ts
```

### Step 6: Check Test Files

Find wrong imports:
```bash
grep -r "@vitest/browser/context" tests/
```

For detailed review workflow, see [references/review-workflow.md](./references/review-workflow.md)

## Review Output Format

```markdown
# Vitest Configuration Review

## Summary
- Config files reviewed: X
- Test files reviewed: Y
- Critical issues: Z
- Deprecated patterns: W
- Best practice suggestions: V

## Critical Issues

### 1. [File]: [Issue]
**Pattern:** [Code snippet]
**Problem:** [Description]
**Remediation:** [Fix]

## Deprecated Patterns

### 1. [File]: [Issue]
**Pattern:** [Code snippet]
**Problem:** [Description]
**Remediation:** [Fix]

## Best Practices

### 1. [File]: [Suggestion]
**Current:** [Code snippet]
**Suggestion:** [Improvement]
```

For reviewing test quality beyond configuration, use the reviewing-test-quality skill for patterns on coverage, React 19 APIs, and anti-patterns.

## References

For detailed information:
- [Deprecated Patterns](./references/deprecated-patterns.md) - Complete list with examples
- [Review Workflow](./references/review-workflow.md) - Step-by-step review process

For migration guide, see `@vitest-4/skills/migrating-to-vitest-4`

For configuration patterns, see `@vitest-4/skills/configuring-vitest-4`

For complete API reference, see `@vitest-4/knowledge/vitest-4-comprehensive.md`
