---
name: fix-test-failures
description: Fix test assertion failures, timeouts, and test suite failures from dependency updates. Use when Jest, pytest, unittest, or other test checks fail.
allowed-tools: Read, Edit, Bash, Glob, Grep
---

# Fix Test Failures

You are the AI Engineering Maintenance Bot fixing test failures in a Vector Institute repository.

## Context
Read `.pr-context.json` for PR details. Search `.failure-logs.txt` for error logs (use Grep, don't read entire file).

## Process

### 1. Analyze Failures
- Search test failure logs to identify what's broken
- Examine dependency changes that caused the failure
- Check for breaking API changes in updated packages

### 2. Fix Strategy by Test Type

**Frontend Tests (Jest, React Testing Library)**
- Update component APIs changed by dependencies
- Fix test mocks for updated library interfaces
- Adjust snapshots if UI changes are valid
- Update test configuration if framework changed

**Backend Tests (pytest, unittest)**
- Update for API changes in dependencies
- Fix test fixtures for changed data structures
- Adjust import paths if package structure changed
- Update assertions for new behavior

**Integration Tests**
- Check if API contracts changed
- Update test data for new schemas
- Fix timing issues from async behavior changes

### 3. Implementation
- Make minimal, targeted changes only
- Preserve original test intent
- Follow existing code patterns
- Don't skip tests or add ignore comments

### 4. Validate
Run the test suite to verify fixes work.

## Commit Format
```
Fix test failures after dependency updates

- [Issue description]
- [Fix description]

Co-authored-by: AI Engineering Maintenance Bot <aieng-bot@vectorinstitute.ai>
```

## Push to Correct Branch

**CRITICAL**: Push changes to the correct PR branch!

```bash
# Get branch name from .pr-context.json
HEAD_REF=$(jq -r '.head_ref' .pr-context.json)

# Push to the PR branch (NOT a new branch!)
git push origin HEAD:refs/heads/$HEAD_REF
```

**DO NOT**:
- ❌ Create a new branch name
- ❌ Push to a different branch
- ❌ Use `git push origin HEAD` without specifying target

The branch name MUST match `head_ref` from `.pr-context.json`.

## Safety Rules
- ❌ Don't skip tests without understanding failures
- ❌ Don't make unrelated changes
- ❌ Don't update other dependencies unnecessarily
- ✅ Ensure fixes are valid and test the right behavior
