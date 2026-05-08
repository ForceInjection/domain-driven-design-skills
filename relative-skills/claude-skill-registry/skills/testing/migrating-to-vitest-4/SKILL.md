---
name: migrating-to-vitest-4
description: Migrate from Vitest 2.x/3.x to 4.x with pool options, coverage config, workspace to projects, and browser mode updates. Use when upgrading Vitest versions or encountering deprecated patterns.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Migrating to Vitest 4

This skill guides migration from Vitest 2.x/3.x to 4.x, focusing on breaking changes and deprecated patterns.

## Migration Overview

Vitest 4.0 introduces breaking changes in:

1. **Pool Architecture**: Consolidated worker configuration
2. **Coverage**: Required explicit include patterns
3. **Workspace**: Replaced by projects array
4. **Browser Mode**: Separate provider packages
5. **Dependencies**: Moved to server namespace
6. **Module Runner**: New Vite-based implementation

## Quick Migration Guide

### Pool Configuration

**Before (Vitest 3.x):**
```typescript
export default defineConfig({
  test: {
    maxThreads: 4,
    singleThread: true,
  },
});
```

**After (Vitest 4.x):**
```typescript
export default defineConfig({
  test: {
    maxWorkers: 4,
    maxWorkers: 1,
    isolate: false,
  },
});
```

### Coverage Configuration

**Before (Vitest 3.x):**
```typescript
coverage: {
  provider: 'v8',
  all: true,
}
```

**After (Vitest 4.x):**
```typescript
coverage: {
  provider: 'v8',
  include: ['src/**/*.{ts,tsx}'],
}
```

### Workspace to Projects

**Before (Vitest 3.x):**
```typescript
import { defineWorkspace } from 'vitest/config';

export default defineWorkspace([
  { test: { name: 'unit' } },
]);
```

**After (Vitest 4.x):**
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    projects: [
      { test: { name: 'unit' } },
    ],
  },
});
```

### Browser Mode

**Before (Vitest 3.x):**
```typescript
browser: {
  enabled: true,
  name: 'chromium',
  provider: 'playwright',
}
```

**After (Vitest 4.x):**
```typescript
import { playwright } from '@vitest/browser-playwright';

browser: {
  enabled: true,
  provider: playwright(),
  instances: [{ browser: 'chromium' }],
}
```

**Import updates:**
```typescript
import { page } from 'vitest/browser';
```

### Dependencies

**Before (Vitest 3.x):**
```typescript
deps: {
  inline: ['vue'],
}
```

**After (Vitest 4.x):**
```typescript
server: {
  deps: {
    inline: ['vue'],
  },
}
```

For detailed migration tables covering all options, see [references/migration-tables.md](./references/migration-tables.md)

## Migration Workflow

### Step 1: Update Package

```bash
npm install -D vitest@latest
```

### Step 2: Update Config

1. Replace `maxThreads`/`maxForks` with `maxWorkers`
2. Add `coverage.include` patterns
3. Replace `defineWorkspace` with `projects`
4. Move `deps.*` to `server.deps.*`
5. Update browser provider imports

### Step 3: Update Test Files

```bash
grep -r "@vitest/browser/context" . --include="*.ts"
```

Replace with:
```typescript
import { page, userEvent } from 'vitest/browser';
```

### Step 4: Install Browser Providers

If using browser mode:

```bash
npm install -D @vitest/browser-playwright
```

### Step 5: Run Tests

```bash
vitest --run
```

Check for deprecation warnings.

### Step 6: Verify Coverage

```bash
vitest --coverage
```

For complete migration workflow with troubleshooting, see [references/migration-workflow.md](./references/migration-workflow.md)

## Migration Checklist

### Configuration
- [ ] Update `vitest` to 4.x
- [ ] Replace `maxThreads`/`maxForks` with `maxWorkers`
- [ ] Add explicit `coverage.include` patterns
- [ ] Replace `defineWorkspace` with `projects`
- [ ] Move `deps.*` to `server.deps.*`
- [ ] Update browser provider config

### Test Files
- [ ] Update imports from `@vitest/browser/context` to `vitest/browser`
- [ ] Remove `vitest/execute` imports

### Environment
- [ ] Replace `VITE_NODE_DEPS_MODULE_DIRECTORIES` with `VITEST_MODULE_DIRECTORIES`

### Verification
- [ ] Run tests and verify no deprecation warnings
- [ ] Verify coverage reports generate correctly

## Common Migration Issues

### Issue: "maxThreads is not a valid option"

**Solution:** Replace with `maxWorkers`

### Issue: Coverage Reports Empty

**Solution:** Add explicit `coverage.include` patterns

### Issue: Workspace Config Not Working

**Solution:** Replace `defineWorkspace` with `defineConfig` and `projects`

### Issue: Browser Tests Fail

**Solution:** Install provider package and update imports

### Issue: "deps.inline is not a valid option"

**Solution:** Move to `server.deps.inline`

For detailed troubleshooting, see [references/migration-workflow.md](./references/migration-workflow.md)

## Mock Implementation Changes

### Mock Names
Returns `vi.fn()` instead of `spy` in Vitest 4.x

### Invocation Order
Starts at `1` instead of `0` (matching Jest)

### Restore Mocks
No longer affects automocks

## Reporter Changes

**Before (Vitest 3.x):**
```typescript
reporters: ['basic']
```

**After (Vitest 4.x):**
```typescript
reporters: ['default'],
summary: false
```

## Environment Variables

**Before:**
```bash
VITE_NODE_DEPS_MODULE_DIRECTORIES=/path vitest
```

**After:**
```bash
VITEST_MODULE_DIRECTORIES=/path vitest
```

## Default Exclusions

**Vitest 3.x:** Excluded many directories by default

**Vitest 4.x:** Only excludes `node_modules` and `.git`

Add explicit excludes if needed:

```typescript
coverage: {
  include: ['src/**/*.ts'],
  exclude: [
    '**/node_modules/**',
    '**/dist/**',
    '**/*.test.ts',
  ],
}
```

## References

For detailed migration information:
- [Migration Tables](./references/migration-tables.md) - Complete before/after comparisons
- [Migration Workflow](./references/migration-workflow.md) - Step-by-step process with troubleshooting

For new configuration patterns, see `@vitest-4/skills/configuring-vitest-4`

For browser mode setup, see `@vitest-4/skills/using-browser-mode`

For complete API reference, see `@vitest-4/knowledge/vitest-4-comprehensive.md`
