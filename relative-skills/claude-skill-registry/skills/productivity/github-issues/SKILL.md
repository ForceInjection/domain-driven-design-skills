---
name: github-issues
description: |
  Local-first GitHub issue planning and synchronization system. Use this skill when planning projects locally, creating issue files in .issues/, working with the /plan-issue, /update-issue, /sync-issue, or /list-issues commands, or synchronizing local plans with GitHub issues. Covers frontmatter schema, file structure conventions, sub-issue management, and gh CLI operations.
---

# GitHub Issues Planning System

A local-first system for planning projects and synchronizing with GitHub issues. Plan and iterate locally, then sync to GitHub when ready.

## Quick Reference

### Commands

| Command | Purpose |
|---------|---------|
| `/plan-issue <prompt>` | Create new issue plan from prompt |
| `/update-issue <path> <prompt>` | Update existing plan |
| `/sync-issue <path>` | Sync local ↔ GitHub |
| `/list-issues` | List all local issue plans |

### File Locations

- **Issue files**: `.issues/` directory (gitignored)
- **Simple issues**: `.issues/YYYY-MM-slug.md`
- **Multi-phase projects**: `.issues/YYYY-MM-slug/` directory

## Frontmatter Schema

### Single Issue

```yaml
---
repo: org/repo           # Auto-detected from git remote
issue: 123               # GitHub issue number (null if draft)
state: draft             # draft | open | closed
labels:
  - enhancement
  - priority:high
created: 2025-01-15T10:30:00Z
updated: 2025-01-15T14:20:00Z
---
```

### Parent Issue (with sub-issues)

```yaml
---
repo: org/repo
issue: 123
state: open
labels:
  - epic
sub_issues:              # Ordered list - execution sequence
  - 01-database-schema.md
  - 02-api-endpoints.md
  - 03-frontend-ui.md
created: 2025-01-15T10:30:00Z
updated: 2025-01-15T14:20:00Z
---
```

### Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `repo` | string | GitHub repo in `org/repo` format. Auto-detected from git remote |
| `issue` | number \| null | GitHub issue number. `null` for drafts not yet pushed |
| `state` | enum | `draft` (local only), `open`, or `closed` |
| `labels` | string[] | GitHub labels to apply |
| `sub_issues` | string[] | Ordered list of sub-issue filenames (parent issues only) |
| `created` | ISO 8601 | Creation timestamp |
| `updated` | ISO 8601 | Last modification timestamp |

## File Structure

### Simple Issue (single file)

For straightforward issues without phases:

```
.issues/
└── 2025-01-user-auth.md
```

### Multi-Phase Project (directory)

For complex projects with ordered phases:

```
.issues/
└── 2025-01-api-migration/
    ├── 00-parent.md           # Parent issue with overview
    ├── 01-deprecate-v1.md     # Phase 1
    ├── 02-implement-v2.md     # Phase 2
    └── 03-remove-v1.md        # Phase 3
```

**Naming conventions**:
- Date prefix: `YYYY-MM-`
- Slug: lowercase, hyphens for spaces
- Sub-issues: Two-digit prefix (00, 01, 02, ...) for ordering
- Parent file: Always `00-parent.md`

## Markdown Content Structure

### Required Sections

```markdown
# Title

<high-level description - becomes the GitHub issue body intro>

## Research

<background research and analysis of current codebase state>
- What exists today
- What needs to change
- Dependencies and constraints
- Related code locations

## Proposed Design

<description of the design to implement>
- Architecture decisions
- API changes
- User-facing changes

## Implementation Details

<how this will be implemented>
- Step-by-step implementation approach
- Files to modify
- Testing strategy
```

### Parent Issue Additional Section

Parent issues include a **Contents** section linking to sub-issues:

```markdown
## Contents

Links to sub-issues in execution order:

1. [Deprecate V1 endpoints](./01-deprecate-v1.md) - #124
2. [Implement V2 API](./02-implement-v2.md) - #125
3. [Remove V1 code](./03-remove-v1.md) - #126
```

## Writing Effective Issue Plans

### Research Section Best Practices

- Include specific file paths and line numbers
- Document current behavior vs desired behavior
- List dependencies that might be affected
- Note any technical debt or constraints

### Design Section Best Practices

- Focus on the "what" and "why", not implementation details
- Include diagrams or ASCII art for complex flows
- Document trade-offs considered
- Reference relevant patterns in the codebase

### Implementation Section Best Practices

- Break into discrete, testable steps
- Each step should be achievable in a single PR
- Include acceptance criteria
- Note testing requirements

### When to Use Sub-Issues

Convert to multi-phase when:
- Project requires multiple PRs
- Work can/should be parallelized
- Different reviewers needed for different phases
- Project spans multiple systems or packages

## GitHub Synchronization

### Draft → Open Workflow

1. Create plan locally with `/plan-issue`
2. Iterate with `/update-issue` until ready
3. Run `/sync-issue` to create GitHub issue
4. Frontmatter updates with issue number and state

### Sync Behavior

**For drafts (issue: null)**:
- Creates new GitHub issue
- Updates frontmatter with issue number
- Sets state to `open`

**For existing issues**:
- Fetches current GitHub state
- Compares local vs remote content
- Shows diff if different
- Asks user to push, pull, or skip

### Parent-Child Linking

When syncing parent issues with sub-issues:
1. Create all sub-issues first (they need issue IDs)
2. Create the parent issue
3. Link sub-issues to parent using the Sub-Issues REST API
4. Parent body includes task list with sub-issue links

**Important**: GitHub's sub-issues feature uses the issue's internal `id` (a large integer like `3731549400`), not the issue `number` (like `#346`).

## gh CLI Reference

### Auto-detect Repository

```bash
git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/'
```

### Create Issue

```bash
gh issue create \
  --repo org/repo \
  --title "Issue Title" \
  --body "Issue body content" \
  --label "label1,label2"
```

### View Issue (JSON)

```bash
gh issue view 123 --repo org/repo --json title,body,state,labels
```

### Update Issue

```bash
gh issue edit 123 \
  --repo org/repo \
  --title "New Title" \
  --body "New body content"
```

### Manage Labels

```bash
# Add labels
gh issue edit 123 --repo org/repo --add-label "label1,label2"

# Remove labels
gh issue edit 123 --repo org/repo --remove-label "label1"
```

### Change State

```bash
# Close issue
gh issue close 123 --repo org/repo

# Reopen issue
gh issue reopen 123 --repo org/repo
```

### List Issues

```bash
gh issue list --repo org/repo --json number,title,state,labels
```

## Sub-Issues REST API

GitHub's sub-issues feature allows hierarchical issue organization. The `gh` CLI doesn't have built-in sub-issue commands, so use the REST API via `gh api`.

### Get Issue ID

Sub-issues API requires the issue's internal `id`, not the `number`. Get it from the issue JSON:

```bash
# Get the internal id for issue #123
gh api repos/org/repo/issues/123 --jq '.id'
# Returns: 3731549400
```

### Add Sub-Issue to Parent

Link a sub-issue to a parent issue:

```bash
# Get the sub-issue's internal id first
SUB_ISSUE_ID=$(gh api repos/org/repo/issues/456 --jq '.id')

# Add as sub-issue to parent #123
gh api repos/org/repo/issues/123/sub_issues \
  -X POST \
  --input - <<< "{\"sub_issue_id\": $SUB_ISSUE_ID}"
```

**Important**: The `sub_issue_id` must be an integer, not a string. Use `--input` with JSON to ensure correct typing (the `-f` flag sends strings).

### List Sub-Issues

```bash
gh api repos/org/repo/issues/123/sub_issues --jq '.[].number'
```

### Remove Sub-Issue

```bash
SUB_ISSUE_ID=$(gh api repos/org/repo/issues/456 --jq '.id')

gh api repos/org/repo/issues/123/sub_issues/$SUB_ISSUE_ID -X DELETE
```

### Get Parent Issue

Check if an issue has a parent:

```bash
gh api repos/org/repo/issues/456/parent --jq '.number'
```

### Sync Workflow for Multi-Phase Projects

When syncing a directory with parent and sub-issues:

1. **Create sub-issues first** (in order):
   ```bash
   for file in 01-*.md 02-*.md 03-*.md; do
     gh issue create --repo org/repo --title "..." --body "..."
   done
   ```

2. **Create parent issue**:
   ```bash
   gh issue create --repo org/repo --title "..." --body "..."
   ```

3. **Link sub-issues to parent**:
   ```bash
   PARENT_NUM=123

   for SUB_NUM in 124 125 126; do
     SUB_ID=$(gh api repos/org/repo/issues/$SUB_NUM --jq '.id')
     gh api repos/org/repo/issues/$PARENT_NUM/sub_issues \
       -X POST \
       --input - <<< "{\"sub_issue_id\": $SUB_ID}"
   done
   ```

4. **Update local frontmatter** with issue numbers and set `state: open`

### Sub-Issues Limits

- Maximum 100 sub-issues per parent
- Maximum 8 levels of nesting
- Sub-issues can be in different repositories (cross-repo)

## Troubleshooting

### "Not logged in to GitHub"

Run `gh auth login` to authenticate.

### "Repository not found"

- Check that the repo in frontmatter matches GitHub
- Ensure you have access to the repository
- Verify git remote is configured correctly

### Sync Conflicts

When local and remote differ:
1. Review the diff shown
2. Choose to push (overwrite GitHub) or pull (overwrite local)
3. If unsure, skip and manually resolve

### Missing Issue Number After Sync

Check that:
- `gh issue create` completed successfully
- Network connectivity during sync
- GitHub API rate limits not exceeded
