---
name: configuring-javascript-stack
description: JavaScript/TypeScript stack configuration - pnpm, prettier, eslint, vitest with 96% coverage threshold
---

# JavaScript/TypeScript Stack

## Standards Compliance

| Standard | Level | Status |
|----------|-------|--------|
| aug-just/justfile-interface | Baseline (Level 0) | ✓ Full |
| development-stack-standards | Level 2 | ✓ Complete |

**Dimensions:** 11/13 (Foundation + Quality Gates + Security)

## Toolchain

| Tool | Use |
|------|-----|
| **pnpm** | Package manager |
| **TypeScript** | Type-safe JavaScript |
| **prettier** | Code formatter |
| **eslint** | Linter (complexity check) |
| **vitest** | Testing framework |
| **tsx** | TypeScript execution |

## Stack Dimensions

| Dimension | Tool | Level |
|-----------|------|-------|
| Package manager | pnpm | 0 |
| Format | prettier | 0 |
| Lint | eslint | 0 |
| Typecheck | tsc | 0 |
| Test | vitest | 0 |
| Coverage | vitest (96%) | 1 |
| Complexity | eslint (≤10) | 1 |
| Test watch | vitest | 1 |
| LOC | cloc | 1 |
| Deps | pnpm outdated | 2 |
| Vulns | pnpm audit | 2 |
| License | license-checker | 2 |
| SBOM | @cyclonedx/cyclonedx-npm | 2 |

## Quick Reference

```bash
pnpm install
pnpm prettier --write .
pnpm eslint . --fix --max-complexity 10
pnpm tsc --noEmit
pnpm vitest run tests/unit --reporter=verbose
pnpm vitest run tests/unit --coverage --coverage.lines=96
```

## Docker Compatibility

Web services: Bind to `0.0.0.0` (not `127.0.0.1`)

```typescript
const host = process.env.HOST || '0.0.0.0'
const port = parseInt(process.env.PORT || '3000', 10)

app.listen(port, host)
```

## Standard Justfile Interface

**Implements:** aug-just/justfile-interface (Level 0 baseline)
**Requires:** aug-just plugin for justfile management

```just
set shell := ["bash", "-uc"]

# Show all available commands
default:
    @just --list

# Install dependencies and setup development environment
dev-install:
    pnpm install

# Format code (auto-fix)
format:
    pnpm prettier --write .

# Lint code (auto-fix, complexity threshold=10)
lint:
    pnpm eslint . --fix --max-complexity 10

# Type check code
typecheck:
    pnpm tsc --noEmit

# Run unit tests
test:
    pnpm vitest run tests/unit --reporter=verbose

# Run tests in watch mode
test-watch:
    pnpm vitest tests/unit

# Run unit tests with coverage threshold (96%)
coverage:
    pnpm vitest run tests/unit --coverage --coverage.lines=96

# Run integration tests with coverage report (no threshold)
integration-test:
    pnpm vitest run tests/integration --coverage

# Detailed complexity report for refactoring decisions
complexity:
    pnpm dlx @pnpm/complexity src

# Show N largest files by lines of code
loc N="20":
    @echo "📊 Top {{N}} largest files by LOC:"
    @pnpm cloc src/ --by-file --quiet | sort -rn | head -{{N}}

# Show outdated packages
deps:
    pnpm outdated

# Check for security vulnerabilities
vulns:
    pnpm audit

# Analyze licenses (flag GPL, etc.)
lic:
    pnpm dlx license-checker --summary

# Generate software bill of materials
sbom:
    pnpm dlx @cyclonedx/cyclonedx-npm --output-file sbom.json

# Build artifacts
build:
    pnpm tsc

# Run all quality checks (format, lint, typecheck, coverage - fastest first)
check-all: format lint typecheck coverage
    @echo "✅ All checks passed"

# Remove generated files and artifacts
clean:
    rm -rf node_modules dist coverage .vitest
```

## tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

## eslint.config.js

```javascript
import tseslint from '@typescript-eslint/eslint-plugin'
import tsparser from '@typescript-eslint/parser'

export default [
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: tsparser,
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'error',
      'complexity': ['error', 10],
    },
  },
]
```

## vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      thresholds: {
        lines: 96,
        functions: 96,
        branches: 96,
        statements: 96,
      },
    },
  },
})
```

## .prettierrc

```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
```

## Notes

- Organize tests: `tests/unit/` and `tests/integration/`
- Unit tests run in check-all with 96% threshold
- No `any` types (`no-explicit-any` enforced)
