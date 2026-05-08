---
name: test-suite-setup
description: Set up test validation commands for any project type. Use when configuring test runners, setting up validation commands for a new project, or enabling closed-loop agent workflows.
allowed-tools: Read, Bash
---

# Test Suite Setup Skill

Help set up test validation for any project to enable closed-loop workflows.

## When to Use

- Setting up validation commands for a new project
- Discovering existing test infrastructure
- Creating a validation stack for CI/CD or agentic workflows
- Standardizing test commands across a codebase

## Setup Workflow

### Step 1: Detect Project Type

Look for configuration files to identify the stack:

| File | Project Type |
| --- | --- |
| `package.json` | Node.js / TypeScript |
| `pyproject.toml` | Python (modern) |
| `requirements.txt` | Python (pip) |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml` | Java (Maven) |
| `build.gradle` | Java (Gradle) |

### Step 2: Identify Existing Test Infrastructure

Check for test directories and configurations:

```bash
# Common test locations
ls -la tests/ test/ __tests__/ spec/

# Check for test config files
ls -la pytest.ini jest.config.* vitest.config.* .mocharc.*
```

### Step 3: Extract Available Commands

For Node.js projects:

```bash
# Show available npm scripts
cat package.json | grep -A 30 '"scripts"'
```

For Python projects:

```bash
# Check pyproject.toml for tools
cat pyproject.toml | grep -A 10 '\[tool\.'
```

### Step 4: Generate Validation Commands

Create a validation stack appropriate for the project:

**Template:**

```markdown
## Validation Commands

Execute every command to validate with 100% confidence

- `[lint command]` - Code style and syntax
- `[type check command]` - Type safety (if applicable)
- `[test command]` - Behavior correctness
- `[build command]` - Production readiness
```

## Quick Reference by Stack

### Python (uv + pytest)

```markdown
## Validation Commands

- `uv run ruff check .` - Linting
- `uv run mypy .` - Type checking
- `uv run pytest -v` - Tests
```

### Python (pip + pytest)

```markdown
## Validation Commands

- `flake8 .` or `ruff check .` - Linting
- `mypy .` - Type checking
- `pytest -v` - Tests
```

### TypeScript/JavaScript (npm)

```markdown
## Validation Commands

- `npm run lint` - ESLint
- `npx tsc --noEmit` - Type checking
- `npm test` - Tests
- `npm run build` - Build verification
```

### TypeScript (Bun)

```markdown
## Validation Commands

- `bun run lint` - Linting
- `bun tsc --noEmit` - Type checking
- `bun test` - Tests
- `bun run build` - Build verification
```

### Go

```markdown
## Validation Commands

- `go fmt ./...` - Formatting
- `go vet ./...` - Static analysis
- `go test ./... -v` - Tests
- `go build ./...` - Build verification
```

### Rust

```markdown
## Validation Commands

- `cargo fmt --check` - Formatting
- `cargo clippy` - Linting
- `cargo test` - Tests
- `cargo build --release` - Build verification
```

## Fallback: No Test Infrastructure

If no test infrastructure exists, recommend setup:

### Python

```bash
# Install pytest
uv add --dev pytest pytest-cov

# Create test directory
mkdir tests
touch tests/__init__.py
touch tests/test_example.py
```

### TypeScript

```bash
# Install vitest (modern, fast)
npm install -D vitest

# Or Jest
npm install -D jest @types/jest ts-jest

# Create test directory
mkdir __tests__
```

## Verification

After setup, verify the validation stack works:

```bash
# Run each command and confirm success
[lint command]    # Should exit 0
[type command]    # Should exit 0
[test command]    # Should exit 0
[build command]   # Should exit 0
```

## Memory References

- @validation-commands.md - Full validation patterns
- @test-leverage-point.md - Why tests matter
- @closed-loop-anatomy.md - Using tests in feedback loops

## Version History

- **v1.0.0** (2025-12-26): Initial release

---

## Last Updated

**Date:** 2025-12-26
**Model:** claude-opus-4-5-20251101
