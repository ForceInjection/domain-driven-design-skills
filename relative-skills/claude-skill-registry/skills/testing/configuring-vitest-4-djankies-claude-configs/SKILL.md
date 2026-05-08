---
name: configuring-vitest-4
description: Configure Vitest 4.x with correct pool architecture, coverage settings, and multi-project setup. Use when creating or modifying vitest.config files or setting up test infrastructure.
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Configuring Vitest 4

This skill teaches correct Vitest 4.x configuration patterns, focusing on the breaking changes introduced in version 4.0.

## Core Concepts

Vitest 4.0 introduced major configuration changes:

1. **Pool Architecture**: Consolidated pool configuration with `maxWorkers`
2. **Coverage**: Requires explicit `include` patterns
3. **Multi-Project**: Uses `projects` array instead of workspace
4. **Dependencies**: Moved under `server.deps` namespace

## Quick Reference

### Worker Configuration

```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    pool: 'forks',
    maxWorkers: 4,
    isolate: true,
    fileParallelism: true,
  },
});
```

**Key changes from Vitest 3.x:**
- `maxThreads` → `maxWorkers`
- `maxForks` → `maxWorkers`
- `singleThread: true` → `maxWorkers: 1, isolate: false`

For detailed pool configuration options, see [references/pool-configuration.md](./references/pool-configuration.md)

### Coverage Configuration

```typescript
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['src/**/*.{ts,tsx}'],
    },
  },
});
```

**Required:** Coverage now requires explicit `include` patterns.

For detailed coverage configuration, see [references/coverage-configuration.md](./references/coverage-configuration.md)

For testing Zod schema coverage, use the testing-zod-schemas skill for patterns on validation logic testing, ensuring 100% branch coverage.

### Multi-Project Setup

```typescript
export default defineConfig({
  test: {
    projects: [
      {
        test: {
          name: 'unit',
          include: ['tests/unit/**/*.test.ts'],
          environment: 'node',
        },
      },
      {
        test: {
          name: 'integration',
          include: ['tests/integration/**/*.test.ts'],
          testTimeout: 30000,
        },
      },
    ],
  },
});
```

**Key change:** `defineWorkspace` replaced by `projects` in `defineConfig`

For detailed multi-project configuration, see [references/multi-project-setup.md](./references/multi-project-setup.md)

For testing Next.js server actions with Vitest, use the securing-server-actions skill for patterns on authentication, validation, and security testing.

### Browser Mode

```typescript
import { playwright } from '@vitest/browser-playwright';

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      provider: playwright(),
      instances: [{ browser: 'chromium' }],
    },
  },
});
```

**Key changes:**
- Separate provider package required
- `browser.name` → `browser.instances` array
- Provider must be function call

For detailed browser mode configuration, see [references/browser-mode-config.md](./references/browser-mode-config.md)

### Dependency Configuration

```typescript
export default defineConfig({
  test: {
    server: {
      deps: {
        inline: ['vue', 'lodash-es'],
        external: ['aws-sdk'],
      },
    },
  },
});
```

**Key change:** `deps.*` moved to `server.deps.*`

## Environment Configuration

### Node Environment (Default)

```typescript
export default defineConfig({
  test: {
    environment: 'node',
  },
});
```

### DOM Environments

```typescript
export default defineConfig({
  test: {
    environment: 'jsdom',
  },
});
```

Or use happy-dom for better performance:

```typescript
export default defineConfig({
  test: {
    environment: 'happy-dom',
  },
});
```

For configuring Vitest to test React components, use the testing-components skill for setup patterns and testing @testing-library/react with React 19 components.

## Common Patterns

### Basic Unit Testing

```typescript
export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.ts'],
    },
  },
});
```

### React Component Testing

```typescript
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
  },
});
```

### Multi-Environment Testing

Use `projects` for different test types:

```typescript
export default defineConfig({
  test: {
    projects: [
      { test: { name: 'unit', environment: 'node' } },
      { test: { name: 'component', environment: 'jsdom' } },
      { test: { name: 'browser', browser: { enabled: true } } },
    ],
  },
});
```

For complete configuration examples, see [references/complete-examples.md](./references/complete-examples.md)

## Validation

After creating config, verify with:

```bash
vitest --run
```

Check for deprecation warnings in output. If warnings appear, consult migration guide.

## Deprecated Options Summary

**Never use these (removed in Vitest 4.0):**

### Pool Options
- `maxThreads` → Use `maxWorkers`
- `maxForks` → Use `maxWorkers`
- `singleThread` → Use `maxWorkers: 1, isolate: false`
- `poolOptions` → Flatten to top-level

### Coverage Options
- `coverage.ignoreEmptyLines` → No longer needed
- `coverage.all` → Use explicit `include`
- `coverage.extensions` → Use explicit `include`

### Workspace Options
- `defineWorkspace` → Use `defineConfig` with `projects`
- `poolMatchGlobs` → Use `projects` with `include`
- `environmentMatchGlobs` → Use `projects` with `environment`

### Dependency Options
- `deps.inline` → Use `server.deps.inline`
- `deps.external` → Use `server.deps.external`

### Browser Options
- `browser.name` → Use `browser.instances`
- `browser.testerScripts` → Use `browser.testerHtmlPath`

## Common Mistakes

1. **Missing coverage.include**: Coverage requires explicit include patterns in 4.x
2. **Using removed pool options**: `maxThreads`, `singleThread` no longer exist
3. **Using defineWorkspace**: Replaced by `projects` in `defineConfig`
4. **Wrong browser provider import**: Must import from provider package
5. **Nested poolOptions**: Flatten to top-level configuration

## Performance Optimization

### Fast Unit Tests

```typescript
export default defineConfig({
  test: {
    pool: 'threads',
    isolate: false,
    fileParallelism: true,
    maxWorkers: 4,
  },
});
```

### Fast Browser Tests

```typescript
export default defineConfig({
  test: {
    browser: {
      enabled: true,
      provider: playwright(),
      instances: [{ browser: 'chromium' }],
      headless: true,
      fileParallelism: true,
    },
  },
});
```

## References

For detailed configuration documentation:
- [Pool Configuration](./references/pool-configuration.md) - Worker management and pool options
- [Coverage Configuration](./references/coverage-configuration.md) - V8/Istanbul coverage setup
- [Multi-Project Setup](./references/multi-project-setup.md) - Projects array configuration
- [Browser Mode Config](./references/browser-mode-config.md) - Playwright/WebDriverIO setup
- [Complete Examples](./references/complete-examples.md) - Full configuration templates

For migration from Vitest 3.x, see `@vitest-4/skills/migrating-to-vitest-4`

For browser mode setup, see `@vitest-4/skills/using-browser-mode`

For complete API reference, see `@vitest-4/knowledge/vitest-4-comprehensive.md`
