---
name: validation-enforcer
description: Automatically runs project validation commands (linters, type checkers, tests) after file edits and blocks commits on any failure. Reads validation commands from CLAUDE.md or auto-detects from project type. Enforces strict quality gates to catch issues early. (project)
---

# Validation Enforcer Skill

## Purpose

Enforce strict quality gates by automatically running validation after changes. **Blocks commits on ANY failure** - no exceptions.

## When This Skill Activates

- After any file edit (automatic)
- Before suggesting a commit (automatic)
- When user runs validation commands manually

## STRICT ENFORCEMENT MODE

This skill operates in **strict mode**:
- ANY validation failure blocks the commit
- No "warning only" mode
- No skipping validations
- Must fix all issues before proceeding

## Validation Detection

### Priority 1: Read from CLAUDE.md

Look for a "Validation Commands" section in CLAUDE.md:

```markdown
## Validation Commands (Must Pass Before Committing)

```bash
uv run ruff check .
uv run ruff format --check .
uv run mypy packages/
uv run pytest
```
```

### Priority 2: Auto-Detect from Project Type

| Project Marker | Validators |
|----------------|------------|
| `pyproject.toml` | `ruff check .`, `ruff format --check .`, `mypy .` |
| `package.json` | `npm run lint`, `npm run typecheck`, `npm test` |
| `*.csproj` | `dotnet build`, `dotnet test` |
| `Cargo.toml` | `cargo check`, `cargo clippy`, `cargo test` |
| `go.mod` | `go vet`, `go test` |

### Priority 3: Common Fallbacks

If no specific config found, look for:
- `.ruff.toml` → run ruff
- `eslint.config.*` → run eslint
- `tsconfig.json` → run tsc
- `pytest.ini` / `pyproject.toml[tool.pytest]` → run pytest

## Validation Flow

```
1. File Edit Detected
   ↓
2. Determine Changed Files (git diff)
   ↓
3. Run Validators (from CLAUDE.md or auto-detect)
   ↓
4. Report Results
   ↓
5. If ANY failure → BLOCK and report
   ↓
6. If ALL pass → Allow proceed
```

## Output Format

### On Success
```
Validation passed:
- ruff check: OK
- ruff format: OK
- mypy: OK
```

### On Failure (BLOCKS)
```
Validation FAILED - commit blocked:

ruff check:
  src/app.py:23:5 - E501 line too long
  src/utils.py:45:1 - F401 unused import

Fix these issues before committing.
Auto-fix available: `ruff check --fix .`
```

## Auto-Fix Capability

When failures can be auto-fixed:

1. Report the failures
2. Offer auto-fix option:
   ```
   Auto-fix available for 3 issues:
   - ruff format: 2 files
   - eslint --fix: 1 file

   Run auto-fix? [Requires user confirmation]
   ```
3. After auto-fix, re-run validation to confirm

## Integration with Commits

When user requests a commit:

1. **Before staging**: Run validation on changed files
2. **If failures**: Block commit, show issues
3. **If passes**: Proceed with commit flow

```
User: "commit these changes"

[Validation runs...]

Response (if failures):
"Cannot commit - validation failed:
- mypy: 2 type errors in src/api.py
Fix these first, then retry commit."

Response (if passes):
"Validation passed. Creating commit..."
```

## Configuration (Optional)

Projects can customize in CLAUDE.md:

```markdown
## Validation Commands

```bash
# Required (must all pass)
uv run ruff check .
uv run mypy packages/

# Optional (run but don't block)
# uv run pytest -x  # commented = skip
```
```

## Error Reporting Format

Always report with file:line references:

```
validation-enforcer: FAILED

mypy (2 errors):
  packages/cli/main.py:45: error: Argument 1 has incompatible type "str"; expected "int"
  packages/core/utils.py:12: error: Missing return statement

ruff check (1 error):
  packages/cli/main.py:23: F401 'os' imported but unused

Action: Fix 3 issues before committing
```

## What This Skill Does NOT Do

- Does not run tests automatically (too slow for every edit)
- Does not modify files without confirmation
- Does not skip validations based on file type
- Does not allow "force commit" to bypass failures

## Success Metrics

- Zero commits with linting errors
- Zero commits with type errors
- Clear, actionable error messages
- Fast feedback loop (< 5 seconds for linting)

---

**Core Principle**: Quality is non-negotiable. Fix issues at the source, not in code review.
