---
name: running-scripts
description: How to run scripts in this pnpm + turbo monorepo. Covers turbo task filtering, caching, package-local scripts, and common pitfalls.
---

# Running Scripts

## Key Principle

**Always run from root directory** unless you specifically need package-local behavior. Turbo handles dependencies automatically.

## Common Commands

### Building

```bash
# Build all packages (respects dependency order)
pnpm turbo build

# Build specific package
pnpm turbo build --filter=@kitz/core

# Build package and its dependencies
pnpm turbo build --filter=@kitz/assert...

# Force rebuild (bypass cache)
pnpm turbo build --filter=@kitz/core --force
```

### Type Checking

```bash
# Type check all packages
pnpm turbo check:types

# Type check specific package
pnpm turbo check:types --filter=@kitz/assert
```

### Linting

```bash
# Lint all packages
pnpm turbo check:lint

# Lint specific package
pnpm turbo check:lint --filter=@kitz/core
```

### Package Validation

```bash
# Validate package.json exports (publint + attw)
pnpm turbo check:package

# Validate specific package
pnpm turbo check:package --filter=@kitz/core
```

### Testing

```bash
# Run tests for specific file (use vitest directly)
pnpm vitest packages/core/src/arr/_.test.ts --run

# Run tests for a package directory
pnpm vitest packages/core/src/arr/ --run

# Run all tests via turbo
pnpm turbo test

# ALWAYS use --run to avoid watch mode
```

### Formatting

```bash
# Format all files
pnpm format

# Check formatting
pnpm format:check
```

### Development Mode

```bash
# Watch mode for a package (rebuilds on changes)
pnpm turbo dev --filter=@kitz/core
```

### Release

```bash
# Publish packages with changesets
pnpm release
```

## Turbo Cache

Turbo caches task outputs. If you change source files, it rebuilds. If nothing changed, it replays cached output.

**Cache hit** = "replaying logs" in output (task skipped)

To force fresh run:

```bash
pnpm turbo build --force
```

Or delete the build folder:

```bash
rm -rf packages/core/build && pnpm turbo build --filter=@kitz/core
```

## Package-Local Scripts

Some packages have scripts in `scripts/` directories that aren't npm scripts. Run with tsx:

```bash
# Assert package - regenerate builder code
tsx packages/assert/scripts/generate-builder.ts
```

## Common Pitfalls

| Problem                             | Solution                                       |
| ----------------------------------- | ---------------------------------------------- |
| Cache hit when you expected rebuild | Use `--force` or delete `build/` folder        |
| Tests stuck in watch mode           | Always use `--run` flag with vitest            |
| Build order wrong                   | Turbo handles this via `dependsOn: ["^build"]` |

## Notes

- Task dependencies and caching are configured in `turbo.json` at project root
