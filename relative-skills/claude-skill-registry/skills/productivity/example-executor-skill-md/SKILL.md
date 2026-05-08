---
name: sprint-1-executor
description: Execute Sprint 1 tasks for FASA optimization and trade analytics. This skill should be used when the user requests execution of any Sprint 1 task (Tasks 1.1 through 3.2), including cap space parsing, Sleeper integration, FASA target marts, notebooks, valuation models, trade analysis, automation workflows, or documentation. Each task is atomic, standalone, and designed for independent execution with built-in validation.
---

# Sprint 1 Executor

Execute Sprint 1 tasks for the Fantasy Football Analytics FASA optimization and trade intelligence sprint. This skill provides structured, atomic task execution with validation and progress tracking.

## When to Use This Skill

Use this skill proactively when:

- User requests execution of any Sprint 1 task (e.g., "Execute Task 1.1", "Start Sprint 1 Task 2.1")
- User asks to work on FASA optimization, cap space, Sleeper integration, or trade analysis
- User references sprint_1 documentation or task files
- User wants to continue sprint work after a break

## Sprint Overview

**Sprint Goal:** Deliver actionable FASA bidding strategy for Wednesday 11:59 PM EST + trade analysis infrastructure

**Sprint Structure:**

- **Phase 1:** Critical path for Wednesday FASA deadline
  - Tasks 1.1-1.4: Cap space, Sleeper, FASA marts, strategy notebook
- **Phase 2:** Trade intelligence
  - Tasks 2.1-2.4: Valuation model, trade marts, analysis notebook, backfill
- **Phase 3:** Automation & production
  - Tasks 3.1-3.2: GitHub Actions workflows, documentation

## Task Execution Workflow

When user requests task execution:

1. **Identify the task** - Determine which task (1.1 through 3.2) from user request

2. **Load task file** - Read the corresponding task file from `references/`:
   - Task 1.1: `references/01_task_cap_space_foundation.md`
   - Task 1.2: `references/02_task_sleeper_production_integration.md`
   - Task 1.3: `references/03_task_fasa_target_mart.md`
   - Task 1.4: `references/04_task_fasa_strategy_notebook.md`
   - Task 2.1: `references/05_task_baseline_valuation_model.md`
   - Task 2.2: `references/06_task_trade_target_marts.md`
   - Task 2.3: `references/07_task_trade_analysis_notebook.md`
   - Task 2.4: `references/08_task_historical_backfill.md`
   - Task 3.1: `references/09_task_github_actions_workflows.md`
   - Task 3.2: `references/10_task_documentation_polish.md`

3. **Check dependencies** - Review the "Dependencies" section in the task file
   - Verify prerequisite tasks are complete
   - If blocked, inform user and suggest completing prerequisites first

4. **Implement the task** - Follow the task file's implementation steps:
   - Create/modify all files listed in "Files to Create/Modify" section
   - Use exact code templates and SQL from task file
   - Follow step-by-step implementation guide
   - For Tasks 1.3+ that reference `00_SPRINT_PLAN.md`: Load `references/00_SPRINT_PLAN.md` and extract the full SQL/code from the specified line ranges

5. **Validate the implementation** - Run all validation commands from task file:
   - Execute validation bash commands exactly as written
   - Verify all success criteria are met
   - Check code quality: `make lint`, `make typecheck`, `make sqlcheck`
   - Run dbt tests: `make dbt-test --select [models]`

6. **Report results** - Communicate clearly to user:
   - ✅ What was implemented
   - ✅ Validation results (pass/fail)
   - ⚠️ Any issues or warnings
   - ❌ Blockers (if any)
   - 📝 Next recommended task (if applicable)

7. **Commit changes** - Use the suggested commit message from task file:
   - Copy exact commit message from "Commit Message" section
   - Ensure conventional commit format (feat:/docs:/etc.)
   - Reference task number: "Resolves: Sprint 1 Task X.Y"

8. **Update progress tracking** - After successful commit:
   - Mark task complete in `references/README.md` (⬜ → ✅)
   - Update `references/00_SPRINT_PLAN.md` Progress Tracking section
   - Suggest next task if user wants to continue

## Task File Structure

Each task file contains these sections (use them in order):

1. **Objective** - What and why
2. **Context** - Current state, dependencies, why it matters
3. **Files to Create/Modify** - Complete code listings with templates
4. **Implementation Steps** - Step-by-step guide (follow exactly)
5. **Success Criteria** - Definition of done (validate against this)
6. **Validation Commands** - Exact bash commands to test
7. **Commit Message** - Suggested message (use exactly)
8. **Notes** - Gotchas, tips, future considerations

## Special Handling by Task Type

### Python Implementation Tasks (1.2, 2.1)

- Create modules in `src/ingest/` or `src/ff_analytics_utils/`
- Create production scripts in `scripts/ingest/`
- Follow existing patterns from similar files
- Include type hints and docstrings
- Run `make lint` and `make typecheck`

### dbt Model Tasks (1.1, 1.3, 2.2)

- Create models in `dbt/ff_data_transform/models/staging/` or `dbt/ff_data_transform/models/core/` or `dbt/ff_data_transform/models/marts/`
- Always create both `.sql` and `.yml` files
- Include comprehensive tests in `.yml`
- Set `EXTERNAL_ROOT` environment variable before dbt commands
- Run `make sqlcheck` for SQL linting
- Validate with `make dbt-run --select` and `make dbt-test --select`

### Notebook Tasks (1.4, 2.3)

- Create in `notebooks/` directory
- Use DuckDB for data loading
- Include visualizations (matplotlib/seaborn)
- Test execution: `uv run jupyter nbconvert --execute --to notebook --inplace`
- Ensure reproducibility (no hardcoded paths)

### GitHub Actions Tasks (3.1)

- Create in `.github/workflows/`
- Use Discord webhooks (not Slack)
- Test locally with `make` targets first
- Use environment variables from secrets
- Include `workflow_dispatch` for manual triggering

### Documentation Tasks (3.2)

- Create in `docs/analytics/` or `docs/dev/`
- Include examples and code snippets
- Link from main README
- Follow markdown formatting standards

## Environment Setup

Before executing tasks, ensure:

```bash
# Set environment variables
export SLEEPER_LEAGUE_ID="1230330435511275520"
export EXTERNAL_ROOT="$PWD/data/raw"

# Verify project dependencies
uv sync

# Verify dbt is working
make dbt-run --select dim_player
```

## Common Validation Patterns

### For Python Code

```bash
uv run python [script] --help
make lint
make typecheck
```

### For dbt Models

```bash
export EXTERNAL_ROOT="$PWD/data/raw"
make dbt-run --select [model_name]
make dbt-test --select [model_name]
dbt show --select [model_name] --limit 10
make sqlcheck
```

### For Data Outputs

```bash
ls -lh data/raw/[source]/[dataset]/dt=*/
uv run python -c "
import polars as pl
df = pl.read_parquet('data/raw/[source]/[dataset]/dt=*/*.parquet')
print(df.head())
print(f'Rows: {len(df)}')
"
```

## Progress Reference

Check current sprint progress in `references/README.md` Task Index table.

Full sprint plan and technical specifications in `references/00_SPRINT_PLAN.md`.

## Key Success Factors

1. **Follow task files exactly** - They contain complete, tested specifications
2. **Validate thoroughly** - Run all validation commands, check all success criteria
3. **Check dependencies** - Don't skip prerequisite tasks
4. **Commit atomically** - One task = one commit with provided commit message
5. **Update tracking** - Mark tasks complete in README and sprint plan
6. **Report clearly** - Tell user what worked, what didn't, what's next

## Handling Issues

If validation fails:

1. Review error messages carefully
2. Check common gotchas (see `references/README.md`)
3. Re-read task file for missed details
4. Verify prerequisites completed
5. Report specific error to user with context

If blocked by dependencies:

1. Identify which prerequisite task is missing
2. Inform user: "Task X.Y requires Task A.B to be complete first"
3. Offer to execute prerequisite task or wait

## Task Dependencies Quick Reference

**Critical Path (must be sequential):**

- Task 1.1 → Task 1.2 → Task 1.3 → Task 1.4 (Wednesday FASA ready)

**Trade Analysis (sequential):**

- Task 2.1 → Task 2.2 → Task 2.3

**Independent:**

- Task 2.4 (can run in background)
- Task 3.1 → Task 3.2 (after other phases)

See `references/README.md` dependency diagram for full details.

## Output Format

When reporting task completion:

```text
✅ Sprint 1 Task X.Y Complete: [Task Name]

**Implemented:**
- [List of files created/modified]

**Validation Results:**
- ✅ All tests passing (X/X)
- ✅ Code quality checks passed
- ✅ Success criteria met

**Committed:**
- Commit message: [exact message from task file]
- Branch: [current branch]

**Next Steps:**
- Task X.Z: [Next task name] [priority level]
- [or] Sprint 1 Phase X complete! Ready for Phase Y
```

If issues encountered:

```text
⚠️ Sprint 1 Task X.Y: Partial Completion / Issues

**Completed:**
- [What worked]

**Issues:**
- ❌ [Specific error/failure]
- ⚠️ [Warnings or concerns]

**Validation Status:**
- ✅ [Passed checks]
- ❌ [Failed checks]

**Recommended Action:**
- [Specific next steps to resolve]
```
