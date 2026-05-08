---
name: taskfile
description: Execute Taskfile commands for the Summerhouse project. Use for terraform operations (init, plan, apply, destroy, output), backend/frontend development, testing, and linting. Terraform uses environments (dev, prod) in infrastructure/environments/.
---

# Taskfile Commands

This skill helps execute Taskfile.yaml commands for the Summerhouse booking platform.

## CRITICAL RULE

**NEVER run `terraform` or `terragrunt` commands directly. ALL infrastructure commands MUST use the Taskfile.**

## Terraform Commands

### Command Pattern

```
task tf:<action>:<env>
```

Where:
- `<action>` is: init, plan, apply, destroy, output
- `<env>` is a directory name in `infrastructure/environments/` (e.g., dev, prod)

### Available Terraform Commands

| Command | Description |
|---------|-------------|
| `tf:init:<env>` | Initialize Terraform with backend config |
| `tf:plan:<env>` | Preview changes |
| `tf:apply:<env>` | Apply changes |
| `tf:destroy:<env>` | Destroy all resources |
| `tf:output:<env>` | Show output values |
| `tf:fmt` | Format all Terraform files |
| `tf:validate` | Validate configuration syntax (run after init) |
| `tf:envs` | List available environments |

### Discovering Environments

```bash
# List all available environments
task tf:envs

# Or directly check the directory
ls infrastructure/environments/
```

Environments are defined by directories in `infrastructure/environments/<name>/`. Each has:
- `backend.hcl` - S3 backend configuration
- `terraform.tfvars.json` - Environment-specific variables

### Typical Terraform Workflow

```bash
# 1. List available environments
task tf:envs

# 2. Initialize Terraform
task tf:init:dev

# 3. Preview changes
task tf:plan:dev

# 4. Apply changes (after review)
task tf:apply:dev

# 5. View outputs
task tf:output:dev
```

## Backend Commands (Python/FastAPI)

| Command | Description |
|---------|-------------|
| `backend:install` | Install Python deps with uv |
| `backend:dev` | Run FastAPI dev server on :3001 |
| `backend:test` | Run pytest |
| `backend:test:coverage` | Run pytest with coverage |
| `backend:lint` | Run ruff linter |
| `backend:typecheck` | Run mypy type checker |

## Frontend Commands (Next.js)

| Command | Description |
|---------|-------------|
| `frontend:install` | Install deps with Yarn |
| `frontend:dev` | Run Next.js dev server on :3000 |
| `frontend:build` | Build static export |
| `frontend:test` | Run Vitest unit tests |
| `frontend:test:e2e` | Run Playwright E2E tests |
| `frontend:lint` | Run eslint |

## Combined Commands

| Command | Description |
|---------|-------------|
| `install` | Install all dependencies (backend + frontend) |
| `dev` | Run both dev servers |
| `test` | Run all tests |
| `lint` | Lint all code |

## Other Commands

| Command | Description |
|---------|-------------|
| `types:generate` | Generate TypeScript types from Pydantic models |
| `seed:<env>` | Seed database with test data |

## Instructions

When the user asks to run infrastructure or development operations:

1. **Terraform operations**: ALWAYS use `task tf:<action>:<env>` pattern
2. **Identify environment**: Ask which environment if not specified, or run `task tf:envs`
3. **Destructive operations**: For `apply` and `destroy`, show `plan` output first and confirm
4. **Never bypass**: If a task command fails, report the error - do NOT run raw terraform

## Examples

**User**: "Initialize terraform for dev"
**Action**: Run `task tf:init:dev`

**User**: "Plan changes for production"
**Action**: Run `task tf:plan:prod`

**User**: "Deploy to dev"
**Action**: Run `task tf:plan:dev`, show output, then `task tf:apply:dev` after confirmation

**User**: "What environments are available?"
**Action**: Run `task tf:envs`

**User**: "Run backend tests"
**Action**: Run `task backend:test`

**User**: "Start the dev servers"
**Action**: Run `task dev`

**User**: "Validate terraform syntax"
**Action**: Run `task tf:init:dev` first (if needed), then `task tf:validate`
