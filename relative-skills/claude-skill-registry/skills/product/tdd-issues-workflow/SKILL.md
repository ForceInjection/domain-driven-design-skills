---
name: TDD Issues Workflow
description: Work through docs/ISSUES.md systematically using strict Test-Driven Development. Use this skill when the user asks to work on issues, fix issues, or implement features from the issues list.
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
  - Glob
  - Grep
  - TodoWrite
  - AskUserQuestion
  - mcp__chrome-devtools__navigate_page
  - mcp__chrome-devtools__take_snapshot
  - mcp__chrome-devtools__click
  - mcp__chrome-devtools__fill
  - mcp__chrome-devtools__evaluate_script
  - mcp__chrome-devtools__list_pages
  - mcp__chrome-devtools__take_screenshot
  - mcp__chrome-devtools__wait_for
---

# TDD Issues Workflow

Work through docs/ISSUES.md systematically using strict Test-Driven Development.

## Pre-Flight Checks

Before starting ANY issue:

1. **Verify environment**:
   - Dev server running at http://localhost:3000 (start with `npm start` if not)
   - Git working directory is clean or only has expected changes
   - No failing tests from previous work

2. **Clean up approved issues**:
   - Read docs/ISSUES.md
   - Delete any issues marked 👍 APPROVED from the file
   - Commit the cleanup if changes made
   - **DO NOT** re-number the list

3. **Identify next issue**:
   - Find first issue that needs work:
     - NOT marked as ✅ DONE (new issue), OR
     - Marked as ✅ DONE AND ❌ REJECTED (needs rework)
   - If none found, report completion and STOP

## Issue Workflow

### For CSS-Only Changes

CSS-only = changes ONLY to .css files, no .js/.jsx changes

1. **Create todo list** with TodoWrite for this issue
2. **Read relevant files** (CSS files that need changes)
3. **Implement CSS changes**
4. **Manual verification**:
   - Navigate to http://localhost:3000 using browser devtools
   - Take screenshots showing the changes
   - Explain what changed visually
5. **Commit** (see commit format in reference.md)
6. **Update docs** if CLAUDE.md or docs/ files need updates
7. **Update ISSUES.md** (see Issue Management in reference.md)
8. **Continue to next issue** immediately (return to Pre-Flight Checks)

### For Non-CSS Changes (STRICT TDD)

1. **Create todo list** with TodoWrite for this issue
2. **Read related files** (code files + test files)
3. **Write failing test FIRST**:
   - Bug fixes → tests/regression.spec.js
   - New features → appropriate existing test or new test
   - Explain what the test does
4. **Run test - verify FAILURE**:
   - Run `npm run test:e2e` (Chrome/Chromium only)
   - Confirm fails for the RIGHT reason
   - If passes unexpectedly, STOP and ask user
5. **Implement minimal code** to make test pass
6. **Run test - verify SUCCESS**
7. **Run full suite**:
   - `npm run test:e2e:coverage`
   - ALL tests must pass
   - Coverage must be 100% (statements, functions, lines, branches)
8. **Commit** test + implementation together (see commit format in reference.md)
9. **Update docs** if CLAUDE.md or docs/ files need updates
10. **Update ISSUES.md** (see Issue Management in reference.md)
11. **Continue to next issue** immediately (return to Pre-Flight Checks)

## Absolute Rules

### NEVER:
- ❌ Implement code before writing test (for non-CSS changes)
- ❌ Skip running tests after writing them
- ❌ Commit without running full test suite
- ❌ Mark issue as APPROVED or 👍 APPROVED (only user can approve)
- ❌ Batch multiple issues into one commit
- ❌ Continue if coverage drops below 100%
- ❌ Continue if any test fails unexpectedly
- ❌ Skip pre-flight checks when starting new issue
- ❌ Delete issue that is **NOT** marked APPROVED or 👍 APPROVED
- ❌ Delete issue immediately after completing it
- ❌ Use issue numbers in code or commit messages. Issue numbers are re-used so
  identifying them by number is not useful

### ALWAYS:
- ✅ Write test FIRST (except CSS-only changes)
- ✅ Run tests after every change
- ✅ Commit each issue separately
- ✅ Update ISSUES.md immediately after commit
- ✅ Mark issues only as "✅ DONE" (never as APPROVED)
- ✅ Include user journey context in test assertions
- ✅ Use TodoWrite to track progress on current issue
- ✅ Continue to next issue after successful completion

## When to STOP and Ask User

1. Issue requirements are unclear or ambiguous
2. Test fails for unexpected reason
3. Cannot achieve 100% coverage after reasonable attempt
4. Multiple equally valid implementation approaches exist
5. Issue seems to conflict with existing functionality
6. Need to use `istanbul ignore` (requires permission)
7. Any rule in ABSOLUTE RULES section is violated

See reference.md for detailed rules and examples.md for output format examples.
