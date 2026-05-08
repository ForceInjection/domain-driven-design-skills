---
name: bun
description: Bun runtime and toolkit for JavaScript/TypeScript. Use for package management, running scripts, testing, and bundling. Replaces npm, yarn, pnpm, and node.
---

# Bun - JavaScript/TypeScript Runtime & Toolkit

Bun is the ONLY approved JavaScript/TypeScript toolkit. Never use npm, yarn, pnpm, or node directly.

## Core Principle

**ALWAYS use Bun. NEVER use npm, yarn, pnpm, or node.**

## Command Reference

### Package Management

```bash
# Install all dependencies
bun install

# Add dependencies
bun add <package>              # Production dependency
bun add -d <package>           # Dev dependency
bun add -g <package>           # Global package

# Remove dependencies
bun remove <package>

# Update dependencies
bun update                     # Update all
bun update <package>           # Update specific package
```

### Running Code

```bash
# Run TypeScript/JavaScript directly (no build step!)
bun run script.ts
bun run script.tsx
bun run script.js

# Run package.json scripts
bun run dev
bun run build
bun run start

# Hot reloading
bun --hot run server.ts        # Hot module replacement
bun --watch run server.ts      # Restart on changes
```

### Execute Packages (bunx instead of npx)

```bash
bunx <package>                 # Execute without installing
bunx playwright test
bunx tsc --noEmit
bunx create-react-app my-app
```

### Testing

```bash
# Run tests (Jest-compatible)
bun test
bun test --watch
bun test <file>
bun test --coverage
```

### Bundling

```bash
# Bundle for browsers
bun build ./src/index.ts --outdir ./dist --target browser

# Bundle for Node.js
bun build ./src/index.ts --outdir ./dist --target node

# Minify
bun build ./src/index.ts --outdir ./dist --minify

# Generate single executable
bun build ./src/cli.ts --compile --outfile myapp
```

## Lock Files

- **Approved**: `bun.lockb` (binary) or `bun.lock` (text)
- **Delete on sight**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`

## Configuration (bunfig.toml)

```toml
[install]
frozen = true                  # CI: fail if lockfile outdated

[test]
coverage = true
coverageReporter = ["text", "lcov"]

[run]
bun = true                     # Prefer bun APIs
```

## Environment Variables

```bash
# Load specific env file
bun --env-file=.env.local run dev

# Built-in .env support (automatic)
# .env, .env.local, .env.development, .env.production
```

## Workspaces (Monorepos)

```json
// package.json
{
  "workspaces": ["apps/*", "packages/*"]
}
```

```bash
bun install                    # Install all workspace deps
bun --filter <name> <cmd>      # Run in specific workspace
bun --filter ./apps/web dev    # Run by path
```

## Docker

```dockerfile
# Production Dockerfile
FROM oven/bun:1-alpine AS base
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile --production

# Build
FROM base AS build
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun run build

# Production
FROM base AS runner
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
CMD ["bun", "run", "start"]
```

## CI/CD (GitHub Actions)

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v1
        with:
          bun-version: latest
      - run: bun install
      - run: bun test
      - run: bun run build
```

## Migration from npm/yarn/pnpm

1. Delete old lock files:
   ```bash
   rm -f package-lock.json yarn.lock pnpm-lock.yaml
   ```

2. Install with Bun:
   ```bash
   bun install
   ```

3. Update scripts (already compatible, just use `bun run`)

4. Replace commands:
   - `npm run` → `bun run`
   - `npx` → `bunx`
   - `node` → `bun`

## Bun-Specific APIs

```typescript
// Fast file operations
const file = Bun.file("./data.json");
const content = await file.text();
await Bun.write("./output.json", JSON.stringify(data));

// HTTP server
Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello!");
  },
});

// SQLite (built-in)
import { Database } from "bun:sqlite";
const db = new Database("mydb.sqlite");

// Password hashing (built-in)
const hash = await Bun.password.hash("password");
const valid = await Bun.password.verify("password", hash);

// Shell commands
import { $ } from "bun";
await $`echo Hello World`;
const result = await $`ls -la`.text();
```

## Common Issues

### "command not found: bun"
```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc  # or ~/.zshrc
```

### Incompatible native modules
Some Node.js native modules may need rebuilding:
```bash
bun install --force
```

### TypeScript errors
Bun includes TypeScript types. If IDE issues:
```bash
bun add -d bun-types
```

Then in tsconfig.json:
```json
{
  "compilerOptions": {
    "types": ["bun-types"]
  }
}
```
