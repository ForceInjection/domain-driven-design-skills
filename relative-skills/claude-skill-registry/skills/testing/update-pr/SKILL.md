---
name: update-pr
description: Creates comprehensive PR descriptions by systematically reviewing ALL changes - features, bug fixes, tests, docs, and infrastructure. Use when user wants to update PR description, prepare PR for review, or document branch changes. Requires gh CLI.
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
# Note: Glob/Grep are useful for finding files by pattern (e.g., *Test*.cs)
# and searching code content when categorizing changes.
---

# Comprehensive PR Description Creator

Create thorough PR descriptions that document EVERY meaningful change, not just the headline feature.

## Critical Rule: Complete Coverage

**NEVER assume you know what's in the PR based on branch name or first glance.**

PRs often contain:
- Main feature work
- Bug fixes discovered during development
- Performance optimizations
- Test infrastructure improvements
- Documentation updates
- Dependency changes
- Configuration adjustments

You MUST systematically review ALL changes and include them in the summary.

## Phase 1: Complete Change Inventory

First, determine the base branch for comparison. Run these commands separately:

**Step 1: Try to get base branch from PR:**
```bash
gh pr view --json baseRefName -q '.baseRefName' 2>/dev/null
```

**Step 2: If no PR exists (empty output above), get the default branch:**
```bash
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's#origin/##' || echo 'main'
```

Use the result as `BASE_BRANCH` for the commands below.

Then gather context. These commands are independent and can be run as separate tool calls:

**PR and working tree status:**
```bash
gh pr status
```

```bash
git status --short
```

**Changed files:**
```bash
git diff origin/$BASE_BRANCH...HEAD --stat
git diff origin/$BASE_BRANCH...HEAD --name-status
```

**Commit history:**
```bash
git log origin/$BASE_BRANCH..HEAD --oneline --no-merges
```

**Note**: Using the PR's actual base branch ensures accurate diffs for release backports or PRs targeting non-default branches.

## Phase 2: Systematic File Analysis

Using the `--name-status` output, create a categorized inventory of EVERY changed file:

### 2.1 Core Application Changes
- Check files matching your framework patterns (e.g., `*Service*`, `*Controller*`, `*Component*`)
- Look for: new methods, refactoring, bug fixes, performance improvements
- Read key diffs to understand WHAT changed and WHY

### 2.2 Bug Fixes & Corrections
- Scan commit messages for: "fix", "bug", "correct", "resolve"
- Read diffs for files mentioned in fix commits
- Document: what was broken, what was fixed, impact

### 2.3 Infrastructure & Framework
- Check: interceptors, middleware, base classes, test fixtures
- Look for: new patterns, performance improvements, testing infrastructure
- These are often overlooked but important

### 2.4 Configuration Changes
- Check: config files, constants, environment settings, package files
- Look for: new constants, dependency changes, configuration adjustments
- Even small changes here can be significant

### 2.5 Test Files
- Count new test files vs modified test files
- Check for: new test patterns, test infrastructure, coverage improvements
- Document test coverage added

### 2.6 Documentation
- Check: README files, docs folders, inline documentation
- Look for: new documentation, removed obsolete content, updated instructions

### 2.7 Build & Tooling
- Check: package.json, build configs, CI/CD files, scripts
- Look for: dependency updates, new tooling, build process changes

### 2.8 UI/Frontend Changes
- Check: components, styles, state management
- Look for: new components, UI fixes, styling changes

## Phase 3: Commit-by-Commit Review

For EACH commit in `git log`:

1. Read the commit message - it tells you WHAT category of change
2. Identify which files were changed in that commit
3. Read diffs for key files to understand the WHY
4. Note if commit is: feature, bugfix, test, docs, refactor, perf, chore

**Common prefixes:**
- `fix:` = bug fix (HIGH PRIORITY - always include)
- `feat:` = feature (main work)
- `test:` = test infrastructure
- `docs:` = documentation
- `perf:` = performance optimization
- `refactor:` = code organization
- `chore:` = maintenance tasks

## Phase 4: Verification Checklist

Before writing the summary, confirm you've checked:

- [ ] ALL commits reviewed and categorized
- [ ] Core application changes documented
- [ ] Bug fixes identified and explained
- [ ] Infrastructure/framework changes noted
- [ ] Configuration changes included
- [ ] Test coverage quantified
- [ ] Documentation updates listed
- [ ] Build/tooling changes noted

**If you cannot check ALL boxes, you are not done gathering data.**

## Phase 5: Write Comprehensive Summary

Structure your summary to cover ALL categories of changes.

### Template Structure

```markdown
## Summary

[One sentence covering the MAIN change, plus brief mention of other significant improvements]

## User Impact

**[Main Feature Category]:**
- [Specific user-facing improvements]

**[Secondary Categories if applicable - e.g., Reliability, Performance]:**
- [Bug fixes with impact]
- [Performance improvements]

## Technical Notes

### 1. [Main Feature Name]
[Detailed explanation of main feature with file references]

### 2. [Bug Fixes / Corrections]
[Each bug fix with location, what was wrong, impact, fix]

### 3. [Infrastructure / Performance]
[Test improvements, framework changes, optimizations]

### 4. [Configuration & Dependencies]
[Constants, config changes, dependency updates]

### 5. [Documentation]
[README updates, new docs, removed obsolete content]

## Testing

[Comprehensive test results with specific numbers]

## Implementation Approach

[List ALL commits with brief explanation of each]

1. **[commit message]** - [what it did]
2. **[commit message]** - [what it did]
...

## Next Steps

[Only if applicable]

---

Generated with [Claude Code](https://claude.com/claude-code)
```

## Quality Checklist

Before finalizing, verify:

- **Completeness**: Every commit is represented in the summary
- **Accuracy**: All bug fixes are documented with impact
- **Context**: WHY changes were made, not just WHAT changed
- **Organization**: Changes grouped logically (features, bugs, infrastructure, etc.)
- **Specificity**: File paths for critical changes
- **Impact**: User-facing vs internal changes clearly separated
- **Testing**: Actual test results reported, not assumptions

## Output Instructions

1. **Save to temporary file**: Write the summary to `/tmp/pr-summary.md` (avoids cluttering repo)
2. **Self-review**: Read your summary and verify all commits and file categories are covered
3. **User approval**: Show the summary and ask if they want to update the PR
4. **Update PR** (only if user approves):
   ```bash
   gh pr edit --body-file /tmp/pr-summary.md
   ```

## Common Mistakes to Avoid

- **Focusing only on main feature** - PRs often contain multiple types of changes
- **Skipping "small" changes** - Constants, config, and doc changes matter
- **Ignoring bug fixes** - These are often HIGH PRIORITY to document
- **Missing test infrastructure** - Test improvements affect development velocity
- **Incomplete commit review** - Every commit tells part of the story
- **Vague descriptions** - "Updated files" tells reviewers nothing

## Troubleshooting

**No PR exists yet:**
```bash
# Create PR first
gh pr create --title "Title" --body "WIP"
# Then run the update process
```

**Verify base branch:**
```bash
# Check what base branch the PR is targeting
gh pr view --json baseRefName -q '.baseRefName'
```

```bash
# Or detect default branch if no PR exists
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's#origin/##' || echo 'main'
```

**gh CLI not authenticated:**
```bash
gh auth status
gh auth login
```

---

**Remember**: The PR may contain a week's worth of work across multiple areas. Your job is to tell the complete story, not just the headline feature.
