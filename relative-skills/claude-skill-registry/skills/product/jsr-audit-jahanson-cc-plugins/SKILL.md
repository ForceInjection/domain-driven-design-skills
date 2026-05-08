---
name: jsr-audit
description: "This skill should be used when the user asks to 'audit for JSR', 'check JSR readiness', 'review JSR config', 'verify package for JSR', 'publish to JSR', 'prepare for JSR publishing', 'JSR compliance check', 'run JSR audit', or wants to ensure their Deno/TypeScript package meets JSR standards before publishing."
version: 1.0.0
---

# JSR Publishing Audit

Comprehensive audit guide for JSR (JavaScript Registry) compliance and scoring optimization.

---

## Understanding the JSR Score

JSR assigns packages a quality score from 0-100%, displayed with color coding:
- **Red**: Below 60%
- **Orange**: 60-90%
- **Green**: 90%+ (target this)

The score directly influences search ranking. View any package's breakdown at `jsr.io/@scope/package/score`.

### The 9 Scoring Factors

| Category | Factor | Impact |
|----------|--------|--------|
| **Documentation** | Has README or module doc | High |
| | Has examples in README/module doc | High |
| | Has module docs in all entrypoints | High |
| | Has docs for most symbols | High |
| **Best Practices** | No slow types | Medium |
| | Has provenance (SLSA attestation) | Medium |
| **Discoverability** | Has description (≤250 chars) | Low |
| **Compatibility** | At least one runtime marked compatible | Low |
| | At least two runtimes compatible | Low |

**Key insight**: Documentation carries the heaviest weight. Comprehensive JSDoc + README + `@module` tags will score higher than perfect types with minimal docs.

---

## Audit Checklist

| Check | Command/Location | What to Look For |
|-------|------------------|------------------|
| Required metadata | `deno.json` | `name`, `version`, `exports` fields |
| Scoped package name | `name` field | Format: `@scope/package-name` |
| Package description | `description` field | ≤250 characters for discoverability |
| Valid exports | `exports` field | Entry points exist and are correct |
| No slow types | `deno publish --dry-run` | No slow type warnings |
| Clean file list | `deno publish --dry-run` | Only intended files included |
| ESM only | Source files | No CommonJS (`module.exports`, `require()`) |
| Module documentation | Entry point files | `@module` JSDoc tag present |
| Symbol documentation | Exported symbols | JSDoc with `@param`, `@returns`, `@example` |

---

## Audit Process

### Step 1: Check Required Metadata

Read `deno.json` (or `jsr.json`) and verify:

```json
{
  "name": "@scope/package-name",
  "version": "1.0.0",
  "description": "Concise package description under 250 characters",
  "exports": "./mod.ts"
}
```

**Package name rules:**
- Must start with `@scope/`
- Lowercase letters, numbers, hyphens only
- 2-40 characters (excluding scope)

**Config file choice:**
- Deno projects: Use `deno.json`
- Node/Bun/other: Use `jsr.json`
- Never split config between both files

### Step 2: Verify Exports

Check all entry points exist:

```json
{
  "exports": {
    ".": "./mod.ts",
    "./utils": "./src/utils/mod.ts"
  }
}
```

For each entry point, confirm:
- File exists at specified path
- Exports are properly defined
- Type annotations are explicit (no slow types)
- Has `@module` JSDoc tag

### Step 3: Audit Documentation Quality

**Module-level documentation** (top of entry points):

```typescript
/**
 * A module providing string utilities for common transformations.
 *
 * @example
 * ```ts
 * import { camelCase } from "@scope/cases";
 * camelCase("hello world"); // "helloWorld"
 * ```
 *
 * @module
 */
```

**Symbol documentation**:

```typescript
/**
 * Converts a string to camelCase format.
 *
 * @param input - The string to convert
 * @returns The camelCase formatted string
 *
 * @example
 * ```ts
 * camelCase("hello world"); // "helloWorld"
 * camelCase("foo-bar-baz"); // "fooBarBaz"
 * ```
 */
export function camelCase(input: string): string {
  // ...
}
```

**JSDoc tags reference:**
- `@param name - description` - Document parameters
- `@returns description` - Document return value
- `@example` - Runnable code examples (use triple backticks)
- `@deprecated message` - Mark deprecated APIs
- `@see SymbolName` - Cross-reference related symbols
- `@throws ErrorType` - Document thrown errors
- `{@link SymbolName}` - Inline links
- `{@linkcode SymbolName}` - Inline links with monospace

### Step 4: Run Dry-Run Verification

```bash
deno publish --dry-run --allow-dirty
```

This reveals:
- **Slow types**: Exports without explicit type annotations
- **File list**: Everything that would be published
- **Metadata errors**: Invalid name, version, etc.

### Step 5: Audit the File List

Review dry-run output for files that should NOT be published:

**Common offenders:**
- `.claude/`, `.zed/`, `.vscode/` - IDE settings
- `.github/`, `.gitlab/` - CI/CD configs
- `.mise.toml`, `.tool-versions` - Local tooling
- `coverage/` - Test coverage data
- `docs/`, `*.md` (except LICENSE/README) - Documentation
- `deno.lock` - Lock files
- `*.test.ts`, `**/test_utils/**` - Test files
- `sonar-project.properties`, `*.config.js` - Build configs
- `.env`, `*.local.*` - Local configuration

### Step 6: Configure Publish Filtering

Use `include` (whitelist) + `exclude` (filter):

```json
{
  "publish": {
    "include": [
      "LICENSE",
      "README.md",
      "deno.json",
      "mod.ts",
      "src/**/*.ts"
    ],
    "exclude": [
      "**/*.test.ts",
      "**/test_utils/**"
    ]
  }
}
```

**Why both?**
- `include` whitelists only intended files
- `exclude` filters test files from `src/**/*.ts` glob
- `exclude` takes precedence when both match

### Step 7: Verify Clean Output

Run dry-run again. Only these should appear:
- `LICENSE`
- `README.md`
- `deno.json`
- Entry point files (`mod.ts`, etc.)
- Source code (`src/**/*.ts` minus tests)

---

## Fixing Slow Types

Slow types are exports without explicit type annotations. They prevent JSR from generating `.d.ts` files efficiently and degrade npm compatibility by 1.5-2x slower type checking.

### Function Return Types

```typescript
// SLOW - inferred return type
export function greet(name: string) {
  return "Hello, " + name + "!";
}

// FIXED - explicit return type
export function greet(name: string): string {
  return "Hello, " + name + "!";
}
```

### Constants

```typescript
// SLOW - inferred type
export const GLOBAL_ID = crypto.randomUUID();

// FIXED - explicit annotation
export const GLOBAL_ID: string = crypto.randomUUID();
```

### Class Properties

```typescript
// SLOW - inferred property type
export class Config {
  timeout = 5000;
}

// FIXED - explicit property type
export class Config {
  timeout: number = 5000;
}
```

### Detection Commands

```bash
# Catch slow types before publishing
deno publish --dry-run

# Validate documentation generation
deno doc --lint
```

**Note**: TypeScript 5.5's `isolatedDeclarations` mode produces code that automatically satisfies JSR's no-slow-types requirement.

---

## Prohibited Patterns

JSR enforces ESM-only architecture:

| Prohibited | Alternative |
|------------|-------------|
| `require()` | `import` |
| `module.exports` | `export` |
| `declare global` | Module-scoped types |
| `declare module` | Module-scoped types |
| HTTP imports | `jsr:`, `npm:`, `node:` specifiers only |

---

## Multiple Entry Points

For packages with multiple exports:

```json
{
  "exports": {
    ".": "./mod.ts",
    "./providers": "./providers.ts",
    "./utils": "./src/utils/mod.ts"
  }
}
```

Users import as:
```typescript
import { main } from "@scope/pkg";
import { OpenAI } from "@scope/pkg/providers";
import { helper } from "@scope/pkg/utils";
```

Each entry point should have its own `@module` JSDoc tag.

---

## Dependencies

Declare in `imports`:

```json
{
  "imports": {
    "@std/assert": "jsr:@std/assert@^1.0.0",
    "zod": "npm:zod@^3.22.0"
  }
}
```

Supported specifiers:
- `jsr:@scope/pkg@version` - JSR packages
- `npm:package@version` - npm packages
- `node:module` - Node.js built-ins

---

## CI Publishing with Provenance

GitHub Actions OIDC enables tokenless publishing with automatic SLSA provenance:

```yaml
name: Publish to JSR
on:
  push:
    tags: ['v*']

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # Required for OIDC and provenance

    steps:
      - uses: actions/checkout@v5
      - uses: denoland/setup-deno@v2
        with:
          deno-version: v2.x
      - run: deno publish
```

**Requirements for provenance:**
1. Link package to GitHub repo in JSR settings
2. Include `id-token: write` permission
3. Provenance generated automatically

No API tokens needed - JSR uses GitHub OIDC authentication.

---

## Audit Report Template

After completing the audit:

```markdown
## JSR Publishing Audit Results

| Check | Status |
|-------|--------|
| Required metadata | ✓ / ✗ |
| Scoped package name | ✓ / ✗ |
| Package description | ✓ / ✗ |
| Valid exports | ✓ / ✗ |
| No slow types | ✓ / ✗ |
| Clean file list | ✓ / ✗ |
| ESM only | ✓ / ✗ |
| Module documentation | ✓ / ✗ |
| Symbol documentation | ✓ / ✗ |

### Estimated Score Impact
- Documentation: X/4 factors
- Best Practices: X/2 factors
- Discoverability: X/1 factors
- Compatibility: X/2 factors

### Files Published
[List from dry-run]

### Issues Found
[List any problems]

### Recommendations
[Suggested fixes prioritized by score impact]
```

---

## Quick Commands

```bash
# Full audit dry-run
deno publish --dry-run --allow-dirty

# Validate documentation
deno doc --lint

# Type check
deno check **/*.ts

# Lint
deno lint

# Format
deno fmt

# Publish (when ready)
deno publish
```

---

## Known Limitations (2024-2025)

- **Private packages**: Not yet available (most requested feature)
- **JSX publishing**: Not supported
- **HTTP imports**: Prohibited
- **Complex inference**: Libraries like Zod/ArkType may require `--allow-slow-types`
