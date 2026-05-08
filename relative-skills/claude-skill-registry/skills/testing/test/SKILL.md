---
name: test
description: Run E2E tests for React, Vue, and Svelte frameworks. Use when testing components, verifying changes, or before committing.
---

# Test Runner

Runs Playwright Component Tests across all frameworks.

## When to Use

- After implementing or modifying components
- Before committing changes
- When verifying cross-framework compatibility
- When user asks to run tests
- When checking test coverage

## Quick Commands

| Command | Description |
|---------|-------------|
| `bun run test:ct` | Run all framework tests in parallel |
| `bun run test:ct:seq` | Run all framework tests sequentially |
| `bun run test:ct:react` | Run React tests only |
| `bun run test:ct:vue` | Run Vue tests only |
| `bun run test:ct:svelte` | Run Svelte tests only |

## Instructions

### 1. Determine Test Scope

Based on user request or changed files:

| Changed Path | Tests to Run |
|--------------|--------------|
| `packages/core/**` | All frameworks |
| `packages/react/**` | React only |
| `packages/vue/**` | Vue only |
| `packages/svelte/**` | Svelte only |
| `tests/ct/scenarios/**` | All frameworks |
| `tests/ct/react/**` | React only |
| `tests/ct/vue/**` | Vue only |
| `tests/ct/svelte/**` | Svelte only |

### 2. Run Tests

#### All Frameworks (Parallel)
```bash
bun run test:ct
```

> **Note**: Parallel execution may cause timeout errors when running with all browsers due to resource contention. Use `--project=chromium` for faster, more reliable parallel runs.

#### All Frameworks (Sequential)
```bash
bun run test:ct:seq
```

#### Single Framework
```bash
bun run test:ct:react
bun run test:ct:vue
bun run test:ct:svelte
```

#### Specific Browser
```bash
bun run test:ct:react --project=chromium
bun run test:ct:react --project=firefox
bun run test:ct:react --project=webkit
```

#### Specific Test File
```bash
bun run test:ct:react tests/ct/react/specs/Editor.spec.tsx
```

#### Debug Mode (Headed)
```bash
bun run test:ct:react --headed
```

### 3. Analyze Results

#### Success Output
```
Running X tests using Y workers

  ✓ ComponentName › test description (XXms)
  ...

  X passed (Y.Zs)
```

#### Failure Output
```
  ✗ ComponentName › test description (XXms)
    Error: expect(locator).toBeVisible()
    Locator: ...
    Expected: visible
    Received: hidden
```

### 4. Report Format

```markdown
## Test Results

### Summary
- **React**: ✅ X passed / ❌ Y failed
- **Vue**: ✅ X passed / ❌ Y failed
- **Svelte**: ✅ X passed / ❌ Y failed

### Failures (if any)
| Framework | Test | Error |
|-----------|------|-------|
| React | ComponentName › test | Error message |

### Next Steps
- [ ] Fix failing tests
- [ ] Run tests again
```

## Coverage Check

When user asks about test coverage, check if all components and hooks/composables/runes are covered by tests.

### 1. List Implementations

Run these commands to list all implementations:

```bash
# React
ls packages/react/src/components/*.tsx | xargs -I {} basename {} .tsx
ls packages/react/src/hooks/*.ts | xargs -I {} basename {} .ts

# Vue
ls packages/vue/src/components/*.vue | xargs -I {} basename {} .vue
ls packages/vue/src/composables/*.ts | xargs -I {} basename {} .ts

# Svelte
ls packages/svelte/src/components/*.svelte | xargs -I {} basename {} .svelte
ls packages/svelte/src/runes/*.ts | xargs -I {} basename {} .ts
```

### 2. List Test Specs

```bash
ls tests/ct/react/specs/*.tsx tests/ct/vue/specs/*.ts tests/ct/svelte/specs/*.ts | xargs -I {} basename {}
```

### 3. Check Coverage

For each implementation, determine coverage status:

| Status | Meaning |
|--------|---------|
| ✅ Direct | Has dedicated test spec |
| ✅ Indirect | Tested through parent component |
| ⚠️ Style-only | Pure styling, may not need test |
| ❌ Missing | Needs test |

### 4. Coverage Report Format

```markdown
## Test Coverage Report

### Components

| Component | React | Vue | Svelte | Status |
|-----------|:-----:|:---:|:------:|--------|
| EditorRoot | ✅ | ✅ | ✅ | Direct |
| BubbleMenu | ✅ | ✅ | ✅ | Direct |
| SlashMenu | ✅ | ✅ | ✅ | Direct |

### Hooks / Composables / Runes

| Function | React | Vue | Svelte | Status |
|----------|:-----:|:---:|:------:|--------|
| useVizelEditor | ✅ | ✅ | ✅ | Indirect |
| useEditorState | ❌ | ❌ | ❌ | Missing |

### Summary
- Components: X/Y covered (Z%)
- Hooks/Composables/Runes: X/Y covered (Z%)

### Recommendations
- [ ] Add tests for missing items
- [ ] Consider if style-only components need tests
```

## Troubleshooting

### Browser Not Installed
```bash
bunx playwright install chromium
# or install all browsers
bunx playwright install
```

### Test Timeout
Increase timeout in test:
```typescript
test("slow test", async ({ mount, page }) => {
  test.setTimeout(30000); // 30 seconds
  // ...
});
```

### Parallel Execution Timeout
When running all frameworks in parallel with all browsers, you may see timeout errors due to resource contention:
```
browserContext.newPage: Test timeout of 10000ms exceeded
```

**Solutions:**
1. Use single browser: `bun run test:ct --project=chromium`
2. Use sequential execution: `bun run test:ct:seq`
3. Reduce parallel workers in config (currently 50% CPU)

### Element Not Found
Check if element is rendered to `document.body` (portal):
```typescript
// Inside component
const element = component.locator(".selector");

// Portal/popup (rendered to body)
const popup = page.locator(".selector");
```

## Common Patterns

### Run Tests for Changed Files
```bash
# Get changed files
git diff --name-only HEAD~1

# Run relevant tests based on changes
bun run test:ct:react  # if React files changed
```

### Run Before Commit
```bash
# Quick parallel check with single browser (recommended)
bun run test:ct --project=chromium

# Or sequential check with single browser
bun run test:ct:seq --project=chromium
```

### Full CI-like Test
```bash
# All frameworks in parallel, all browsers
bun run test:ct

# All frameworks sequentially, all browsers (more stable)
bun run test:ct:seq
```
