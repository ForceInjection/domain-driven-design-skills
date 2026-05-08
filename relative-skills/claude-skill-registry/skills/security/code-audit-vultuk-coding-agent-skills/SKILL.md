---
name: code-audit
description: Perform comprehensive code audits on repositories or directories. Use when asked to audit code, review a codebase, analyze code quality, find bugs, check for security issues, review architecture, check SOLID/DRY compliance, or generate a code audit report. Produces well-formatted markdown reports with prioritized recommendations.
---

# Code Audit

Perform comprehensive code audits and generate structured markdown reports.

## Workflow

1. **Scope**: Determine target (full repo, specific path, or focused concern)
2. **Discovery**: List and categorize source files
3. **Analysis**: Evaluate each category systematically
4. **Report**: Generate markdown report using template format
5. **GitHub Issues**: Create issues using `scripts/create_issue.sh`:
   - First: Create individual issues for each actionable recommendation
   - Then: Create the full audit report with subtasks linking to each issue

## Analysis Categories

| Category | What to Look For |
|----------|------------------|
| Architecture | Separation of concerns, component structure, dependencies |
| Bugs | Race conditions, null checks, resource leaks, edge cases |
| SOLID Violations | SRP (god classes), OCP, LSP, ISP, DIP issues |
| DRY Violations | Duplicated logic, repeated patterns, copy-paste code |
| Best Practices | Magic numbers, missing docs, broad exceptions |
| Security | Input validation, credential handling, injection risks |
| Performance | O(n) issues, unnecessary copies, inefficient algorithms |
| Good Practices | Highlight what the code does well |

## Severity Levels

| Level | Criteria |
|-------|----------|
| P0/Critical | Race conditions, security vulnerabilities, data loss risks |
| P1/High | Major bugs, architectural issues, memory leaks |
| P2/Medium | Code quality issues, moderate violations |
| P3/Low | Minor improvements, nice-to-have refactors |

## Scoring

Rate each applicable category out of 10:

- Architecture, Thread Safety, Error Handling
- DRY Compliance, SOLID Compliance
- Security, Performance, Testability

Overall score: weighted average (bugs and security weighted higher).

## Report Format

See [references/report-template.md](references/report-template.md) for the exact output structure.

Key formatting rules:

- Two-column tables for issue metadata (severity, location, impact, recommendation)
- Code blocks with language hints for all code examples
- Horizontal rules between major sections
- ASCII diagrams in code blocks for architecture
- Summary statistics table at the end
- Prioritized recommendations (P0/P1/P2/P3)
- Never use em-dashes

## Output

### Step 1: Create Individual Recommendation Issues

For each actionable recommendation, create a separate issue using the format in [references/issue-template.md](references/issue-template.md). Capture the returned issue URL for each.

```bash
bash scripts/create_issue.sh \
  --project "[Project Name]" \
  --title "[Brief issue title]" \
  --label "code-audit,priority:[level],[category]" \
  --body "$ISSUE_BODY"
```

Priority labels:
- P0/Critical → `priority:critical`
- P1/High → `priority:high`
- P2/Medium → `priority:medium`
- P3/Low → `priority:low`

Category labels (use as appropriate):
- `security`, `performance`, `bug`, `technical-debt`
- `architecture`, `observability`, `testing`, `documentation`

### Step 2: Create Full Audit Report with Subtasks

Append a "Related Issues" section to the full report with subtasks linking to each individual issue:

```markdown
## Related Issues

- [ ] #123 - Fix race condition in data index map
- [ ] #124 - Add thread safety to RedisClient
- [ ] #125 - Extract side validation utility
- [ ] #126 - Add metrics and observability
```

Then create the main audit issue:

```bash
bash scripts/create_issue.sh \
  --project "[Project Name]" \
  --title "Code Audit Report - [Project] - [Date]" \
  --label "code-audit" \
  --body "$FULL_REPORT_WITH_SUBTASKS"
```

With a specific repository, add `--repo "owner/repo"`.

Confirm all issue URLs with the user after creation.
