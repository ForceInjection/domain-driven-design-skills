---
name: pr-update
description: |
  Update existing pull request title and description based on latest changes.
  Use when user wants to refresh PR with latest commits. Triggers include:
  - Korean: "PR 업데이트해줘", "PR 수정해줘", "PR 다시 만들어줘"
  - English: "update PR", "refresh PR", "regenerate PR description"
  - Context: User has existing PR and wants to update title/description after adding more commits
---

# Pull Request Updater

## Overview

Refresh PR title and description based on latest final diff analysis.

## ⚠️ Critical Execution Rules

**NEVER cd to skill folder.** Always execute scripts from user's current working directory to preserve git repository context.

**Script execution:**
- You know where this skill's SKILL.md is located when you load it
- Marketplace root = parent directory of the skill directory
- Scripts are at: `<marketplace_root>/scripts/`
  - `analyze_diff.py` - Analyze final diff
- Compute the path, then execute from user's current working directory

## Important Principles

1. **Must have existing PR**: Check PR exists for current branch
2. **User confirmation required**: Show old vs new content before updating
3. **Respect PR template**: Use same template as creation workflow
4. **Final diff is source of truth**: PR description based on latest `base..HEAD` diff
5. **Warn about manual edits**: User may have edited PR on GitHub - ask before overwriting

## Workflow

### Step 1: Get Current PR Information

```bash
gh pr view --json number,title,body,baseRefName
```

If no PR exists, inform user to create PR first.

Returns:
```json
{
  "number": 123,
  "title": "Old PR title",
  "body": "Old PR body...",
  "baseRefName": "main"
}
```

### Step 2: Analyze Latest Final Diff

⚠️ **IMPORTANT**: Use final diff as source of truth. Analyze current state of `base..HEAD`.

**Three-tier strategy** for large PRs:
- **Tier 1** (≤5000 lines): Full diff
- **Tier 2** (>5000 total, ≤5000 additions): Additions only
- **Tier 3** (>5000 additions): Error (use `--allow-large` to force)

```bash
# Normal execution (auto-fallback)
python3 <marketplace_root>/scripts/analyze_diff.py <base> --json

# Force large PR (if additions > 5000)
python3 <marketplace_root>/scripts/analyze_diff.py <base> --json --allow-large
```

**Reuse recent analysis**: If user ran this or pr-create recently with same base, and got successful diff, can reuse that analysis for efficiency.

### Step 3: Check for PR Template

Check common locations (same as pr-create):
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE/*.md`
- `docs/PULL_REQUEST_TEMPLATE.md`
- `PULL_REQUEST_TEMPLATE.md` (root)

Use template if found for consistency with original PR.

### Step 4: Generate New Title and Body

Analysis logic:
- Analyze **final diff** (NOT commits) to describe overall change
- Follow Chris Beams' rules for title
- Use PR template structure if available
- Add Claude Code attribution

### Step 5: Show Comparison to User

```
Current PR #123:
Title: [old title]
Body preview: [first 3 lines...]

Proposed update:
Title: [new title]
Body preview: [first 3 lines...]

The body was generated using [template name / default format].

Should I update the PR? You can ask me to:
- Modify the title or body
- Show the full body comparison
- Cancel the update
```

**Warning check**: If old body doesn't have Claude Code attribution, it may have been manually edited. Ask:
```
⚠️ This PR may have been manually edited on GitHub.
Any manual changes will be overwritten by this update.
Do you want to proceed?
```

### Step 6: Update PR

Only after user approval:

```bash
gh pr edit <pr-number> --title "..." --body "..."
```

### Step 7: Confirm Update

```
✅ Pull request #123 updated
View at: https://github.com/owner/repo/pull/123
```

## Use Cases

**Added More Commits**:
```
User: "I added 3 more commits, update the PR"
Assistant: (Run pr-update skill)
- Gets current PR info
- Analyzes latest final diff
- Generates new description including new changes
- Shows comparison and updates after approval
```

**Fixed Review Comments**:
```
User: "I addressed all review comments, refresh the PR description"
Assistant: (Run pr-update skill)
- Regenerates description from current state
- Reflects fixes made during review
```

**Rebased on Latest Main**:
```
User: "Just rebased on main, update PR"
Assistant: (Run pr-update skill)
- Base is still same (main)
- Final diff now relative to latest main
- Description updated to reflect current changes
```

## Requirements

- `gh` CLI must be installed and authenticated
- Current branch must have an open PR
- Latest changes should be pushed to remote

## Examples

**Before Update**:
```
Title: Add authentication
Body: WIP - adding JWT support
```

**After Update** (after adding more commits):
```
Title: Add user authentication system
Body:
## Summary
- Implement JWT authentication with role-based access control
- Add login/logout endpoints
- Integrate session management with Redis
- Add authentication middleware for protected routes

## Testing
- Added unit tests for auth service
- Added integration tests for auth endpoints
- Manually tested with different user roles

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Notes

- This workflow regenerates the entire PR description
- Manual GitHub edits will be overwritten
- If user wants to preserve some manual content, they should mention it before update
- Consider asking "Should I preserve any of the existing content?" if manual edits detected
