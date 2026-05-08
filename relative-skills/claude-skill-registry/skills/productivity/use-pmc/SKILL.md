---
name: use-pmc
description: Use PMC (Project Manager Claude) CLI for workflow orchestration. Use this skill when running workflows, creating new projects, syncing docs with implementation, or managing project planning.
---

# Use PMC

PMC is a workflow orchestration CLI for Claude Code. It manages project planning, ticket implementation, and documentation sync.

## Reference Documentation

| Reference | When to Read |
|-----------|--------------|
| `references/how-to-use-pmc.md` | Running workflows, CLI commands, available workflows |
| `references/how-to-create-workflow.md` | Creating custom workflow definitions |

## Prerequisites

PMC must be available from the repository root:

```bash
cd <repo-root>  # Parent directory of .claude/
uv sync
```

## Quick Reference

### List Available Workflows

```bash
pmc list
```

### Run a Workflow

```bash
# By registry name (working_dir defaults to current directory)
pmc run <workflow-name>

# Explicit working_dir (if running from different location)
pmc run <workflow-name> -i working_dir=/path/to/project

# With verbose output
pmc run <workflow-name> -v

# Dry run (preview without executing)
pmc run <workflow-name> --dry-run
```

**Note:** `working_dir` defaults to `.` (current directory) when not specified.

### Common Workflows

| Workflow | Purpose | Command |
|----------|---------|---------|
| `pm.init-project` | Initialize planning from PRD | `pmc run pm.init-project` |
| `pm.analyze-gaps` | Compare codebase vs PRD | `pmc run pm.analyze-gaps` |
| `pm.sync-prd` | Update PRD from implementation | `pmc run pm.sync-prd` |
| `pm.sync-planning` | Create tickets for unbuilt features | `pmc run pm.sync-planning` |
| `scaffold.workflow` | Bootstrap new projects | `pmc run scaffold.workflow -i project_name=... -i target_dir=...` |

## Typical Workflows

### Initialize New Project

```bash
# 1. Create project structure
pmc new my-project --stack python-uv

# 2. Add PRD documents to docs/1-prd/

# 3. Initialize planning from PRD
pmc run pm.init-project -i working_dir=./my-project
```

### Sync Documentation with Implementation

```bash
# 1. Analyze gaps between code and PRD
pmc run pm.analyze-gaps

# 2. Review docs/1-prd/99-discrepancies.md

# 3. Update PRD for implemented features (optional)
pmc run pm.sync-prd

# 4. Create tickets for unbuilt features (optional)
pmc run pm.sync-planning
```

### Project Management

```bash
pmc projects list              # List registered projects
pmc projects info my-project   # Show project details
pmc projects switch my-project # Print cd command
pmc projects stacks            # List available tech stacks
```

### Check Status

```bash
pmc status                     # Current execution status
pmc status --ticket T00001     # Status for specific ticket
pmc tasks                      # List running agents
```

## Workflow Validation

Before running a new or modified workflow:

```bash
pmc validate <workflow-name>
pmc validate <workflow-name> --check-deps  # Check sub-workflow dependencies
```

## CLI Options

| Option | Description |
|--------|-------------|
| `-i, --input KEY=VALUE` | Pass input variables |
| `--dry-run` | Preview without executing |
| `-v, --verbose` | Show detailed output |
| `-q, --quiet` | Minimal output |
| `--log-file PATH` | Write logs to file |
| `--workflows-dir PATH` | Override workflows directory |

## When to Use PMC

Use PMC workflows when:
- **Initializing a project** - `pm.init-project` sets up docs structure from PRD
- **Documentation drift** - `pm.analyze-gaps` finds discrepancies
- **Updating docs** - `pm.sync-prd` and `pm.sync-planning` fix documentation
- **Creating new projects** - `pmc new` scaffolds with templates
- **Orchestrating ticket work** - Supervisor/ticket workflows automate implementation

## Troubleshooting

### Workflow Not Found

```bash
pmc list                              # Check available workflows
pmc validate path/to/workflow.json    # Verify specific file
```

### Missing Inputs

If running from a different directory, specify `working_dir`:

```bash
pmc run pm.init-project -i working_dir=/path/to/project
```

### Dependency Errors

Check sub-workflow dependencies exist:

```bash
pmc validate my.workflow --check-deps
```

### View Detailed Logs

```bash
pmc run my.workflow -v --log-file ./pmc.log
```

## Critical Rules

1. **Run from repo root** - PMC defaults `working_dir` to current directory
2. **Check PRD first** - Ensure `docs/1-prd/` has requirements before `pm.init-project`
3. **Validate before running** - Use `pmc validate` for custom workflows
4. **Review discrepancies** - Check `99-discrepancies.md` after `pm.analyze-gaps`
5. **Specify working_dir explicitly** - Only needed when running from a different location
