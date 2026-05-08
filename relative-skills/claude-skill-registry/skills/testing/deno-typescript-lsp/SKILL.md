---
name: Deno TypeScript LSP
description: Use this skill when working with TypeScript/JavaScript files (.ts, .tsx, .js, .jsx, .mts, .cts, .mjs, .cjs) in Deno projects, or when the user asks about Deno-specific patterns, imports, configuration, testing, or tooling.
version: 1.0.0
---

# Deno TypeScript Development

Deno is the primary TypeScript/JavaScript runtime and language server. It replaces the entire Node.js toolchain: no tsc, eslint, prettier, jest, webpack needed.

## Core Philosophy

- **One tool** - Deno handles typecheck, lint, format, test, coverage, benchmark
- **Security first** - Explicit permissions, minimal external dependencies
- **Import maps** - All dependencies declared in `deno.json`, never direct imports
- **ESM only** - No CommonJS, always include `.ts` extensions in relative imports

## Configuration - deno.json

Single source of truth for all project configuration:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  },
  "imports": {
    "@/": "./src/",
    "@std/assert": "jsr:@std/assert@^1.0.14",
    "@std/fs": "jsr:@std/fs@^1.0.19",
    "zod": "npm:zod@^3.23.8"
  },
  "tasks": {
    "dev": "deno run --watch --allow-net --allow-read src/main.ts",
    "test": "deno test --allow-all --coverage=coverage",
    "check": "deno check src/**/*.ts",
    "lint": "deno lint",
    "fmt": "deno fmt"
  },
  "exclude": ["coverage/", "node_modules/"],
  "lock": true
}
```

## Import Strategy

**CRITICAL:** Never use direct JSR/npm imports in source files.

```typescript
// ✅ GOOD - Use import map aliases
import { assertEquals } from "@std/assert";
import { z } from "zod";
import { Agent } from "@/domain/agent.ts";
import { helper } from "./utils.ts";  // Extension required!

// ❌ BAD - Direct registry imports
import { z } from "npm:zod@^3.23.8";
import { assertEquals } from "jsr:@std/assert";
```

**Import Order:**
1. Standard library (`@std/*`)
2. Third-party (`zod`, etc.)
3. Internal absolute (`@/domain/...`)
4. Relative (`./utils.ts`)

**Version Pinning:** Always pin versions in `deno.json`. No floating `@latest`.

## Dependency Sources (Priority Order)

1. **`jsr:` registry** - First choice for TypeScript modules
2. **`npm:` specifier** - When JSR unavailable, prefer ESM-compatible
3. **URL imports** - Rarely needed with import maps

```json
{
  "imports": {
    "@std/assert": "jsr:@std/assert@^1.0.14",
    "zod": "npm:zod@^3.23.8"
  }
}
```

## Testing

**Co-locate unit tests with source:**

```
src/
└── domain/
    ├── agent.ts
    └── agent.test.ts    # Test file next to source
```

**Test file naming:** Always use `.test.ts` suffix.

**AAA Pattern (Arrange-Act-Assert):**

```typescript
import { assertEquals } from "@std/assert";

Deno.test("agent processes valid input", () => {
  // Arrange
  const agent = new Agent({ name: "Test" });

  // Act
  const result = agent.process("hello");

  // Assert
  assertEquals(result.status, "success");
});
```

**Coverage requirements:**
- Line coverage: 80%+ (non-negotiable)
- Branch coverage: 60-80% (non-negotiable)

**Use `@std/testing` for test utilities:**

```typescript
import { FakeTime } from "@std/testing/time";
import { stub, spy } from "@std/testing/mock";

Deno.test("timer behavior", () => {
  using time = new FakeTime();
  time.tick(1000);
  // Deterministic time control
});
```

## Permissions Model

Default to minimum required permissions:

```bash
# ❌ BAD
deno run --allow-all script.ts

# ✅ GOOD
deno run --allow-read=./data --allow-net=api.example.com script.ts
```

**Common flags:**
- `--allow-read[=<path>]` - File system read
- `--allow-write[=<path>]` - File system write
- `--allow-net[=<domain>]` - Network access
- `--allow-env[=<var>]` - Environment variables
- `--allow-run[=<program>]` - Subprocess execution

## Essential Commands

```bash
# Development
deno run --watch src/main.ts     # Watch mode
deno check src/**/*.ts           # Type-check
deno fmt                         # Format
deno lint                        # Lint

# Testing
deno test                        # Run tests
deno test --watch --fail-fast    # Watch mode
deno test --coverage=coverage    # With coverage
deno coverage coverage --html    # Generate report

# Dependencies
deno add jsr:@std/path           # Add dependency
deno cache --reload              # Update cache
deno cache --lock=deno.lock --lock-write  # Update lockfile

# Tasks
deno task dev                    # Run defined task
```

## Standard Library (@std/*)

Use JSR standard library for common utilities:

- `@std/assert` - Testing assertions
- `@std/fs` - File system utilities
- `@std/path` - Path manipulation
- `@std/http` - HTTP server/client
- `@std/async` - Async utilities (debounce, retry, etc.)
- `@std/testing` - Mock, spy, FakeTime
- `@std/ulid` - ULID generation

## Anti-Patterns to Avoid

```typescript
// ❌ Direct registry imports in source
import { z } from "npm:zod@^3.23.8";

// ❌ Missing file extension
import { helper } from "./utils";

// ❌ Node.js APIs
import * as fs from "node:fs";
const fs = require("fs");

// ❌ Unnecessary async wrapper
async function validate(input: string): Promise<boolean> {
  return input.length > 0;  // No await needed
}

// ❌ Test delays instead of FakeTime
await new Promise(r => setTimeout(r, 100));
```

## Lockfile Management

- **Always commit** `deno.lock` to version control
- Update lockfile: `deno cache --lock=deno.lock --lock-write`
- CI mode: `deno run --lock=deno.lock --lock-write=false`
