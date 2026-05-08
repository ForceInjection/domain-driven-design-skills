---
name: github-issue-breakdown
description: Break down GitHub issues into official GitHub sub-issues by parsing task lists from parent issue descriptions. Use this skill when a user wants to convert a parent issue with tasks into linked sub-issues, when managing complex features that need hierarchical breakdown. Accepts issue number as parameter or prompts user if not provided.
---

# GitHub Issue Breakdown

## Overview

This skill automates breaking down GitHub issues into official GitHub sub-issues using the GitHub GraphQL API. It parses various task list formats from parent issue descriptions, shows a preview of proposed sub-issues, and creates them with proper parent-child relationships while inheriting metadata like labels and assignees.

## When to Use This Skill

**⚠️ CRITICAL: Use this skill IMMEDIATELY after creating an Epic/parent issue with a task list!**

**DO NOT manually create sub-issues** - they won't have proper GitHub parent-child relationships and won't show in the sub-issue UI.

Use this skill when:
- **Right after creating an Epic** - Run this immediately to create official sub-issues ⭐ **MOST IMPORTANT**
- User requests breaking down an issue into sub-tasks (e.g., "break down issue #47 into sub-issues")
- User mentions converting a task list into sub-issues
- User is working with complex features that need hierarchical task management
- User needs to create multiple related child issues from a parent issue

**Invocation patterns:**
- "Break down issue #42 into sub-tasks"
- "Create sub-issues from issue 47"
- "Convert the task list in issue #42 to sub-issues"
- "Use github-issue-breakdown on issue 42"

**⚠️ Common Mistake to Avoid:**

❌ **WRONG - Creates informal sub-tasks WITHOUT parent-child links:**
```bash
# Create epic
gh issue create --title "Epic: Feature X"

# Manually create sub-issues (NO PARENT-CHILD LINK!)
gh issue create --title "Phase 1" --body "Sub-task of #42"
gh issue create --title "Phase 2" --body "Sub-task of #42"
# Result: Issues exist but aren't real sub-issues
```

✅ **CORRECT - Creates official sub-issues WITH parent-child links:**
```bash
# Create epic with task list
gh issue create --title "Epic: Feature X" --body "## Tasks
- [ ] Phase 1: Setup
- [ ] Phase 2: Implementation"

# IMMEDIATELY use this skill to create official sub-issues
python scripts/create_subissues.py --issue 42 --yes
# Result: Proper sub-issues that show in GitHub UI
```

**Why this matters:**
- Manual issues only have informal text links ("Sub-task of #X")
- They don't show in GitHub's sub-issue UI
- No automatic tracking of parent-child relationships
- Can't use GitHub's task completion features
- Harder to track Epic progress
- Must be recreated to fix (GitHub doesn't support retroactive conversion)

## Quick Start

### Prerequisites

1. **Environment Variables:**
   ```bash
   export GITHUB_TOKEN="ghp_xxxx"      # GitHub token with repo scope
   ```

2. **Token Scopes:**
   - `GITHUB_TOKEN` - Requires `repo` scope for issue operations
   - Must have write access to the repository

3. **Setup Location:**
   Configure in `.devcontainer/.env` (gitignored):
   ```bash
   GITHUB_TOKEN=your_token_here
   ```

### Basic Usage

```bash
# Break down an issue (interactive - will show preview)
python /workspace/.claude/skills/github-issue-breakdown/scripts/create_subissues.py --issue 42

# Specify repository explicitly
python /workspace/.claude/skills/github-issue-breakdown/scripts/create_subissues.py --issue 42 --repo owner/repo

# Dry-run mode (preview only, no creation)
python /workspace/.claude/skills/github-issue-breakdown/scripts/create_subissues.py --issue 42 --dry-run
```

## Task Workflows

### Task 1: Break Down Issue with Parameter

When user provides an issue number in their request:

1. **Extract issue number from user request:**
   ```
   User: "Break down issue #42 into sub-tasks"
   ```

2. **Execute the script:**
   ```bash
   cd /workspace/.claude/skills/github-issue-breakdown
   python scripts/create_subissues.py --issue 42
   ```

3. **Script workflow:**
   - Auto-detects current repository from git context
   - Fetches parent issue content
   - Parses task lists (markdown checkboxes, numbered lists, bullets)
   - Shows preview of proposed sub-issues
   - Asks for confirmation
   - Creates sub-issues with parent-child relationships
   - Reports results with URLs

4. **Example output:**
   ```
   Repository: codekiln/langstar
   Parent Issue: #42 - Add user authentication

   Found 4 tasks to convert into sub-issues:

   1. Create login endpoint
   2. Create registration endpoint
   3. Implement JWT token generation
   4. Add authentication middleware

   Create these 4 sub-issues? (y/n):
   ```

### Task 2: Break Down Issue Without Parameter

When user requests breakdown but doesn't specify which issue:

1. **Recognize the request:**
   ```
   User: "Break down this issue into sub-tasks"
   User: "Create sub-issues from the task list"
   ```

2. **Ask user for issue number:**
   Use the AskUserQuestion tool to prompt for the issue number.

3. **Execute with provided issue number:**
   ```bash
   python scripts/create_subissues.py --issue <user_provided_number>
   ```

### Task 3: Preview Sub-Issues (Dry Run)

When user wants to see what would be created without actually creating:

1. **Execute in dry-run mode:**
   ```bash
   python scripts/create_subissues.py --issue 42 --dry-run
   ```

2. **Script will:**
   - Show all parsed tasks
   - Display what sub-issues would be created
   - Show inherited metadata (labels, assignees)
   - Exit without creating anything

## Script Details

### Location

```
/workspace/.claude/skills/github-issue-breakdown/scripts/create_subissues.py
/workspace/.claude/skills/github-issue-breakdown/scripts/gh_helpers.py
```

### Arguments

| Argument | Required | Description | Example |
|----------|----------|-------------|---------|
| --issue | Yes | Issue number to break down | `--issue 42` or `--issue 47` |
| --repo | No | Repository (auto-detected if not provided) | `--repo codekiln/langstar` |
| --dry-run | No | Preview mode without creating | `--dry-run` |
| --inherit-labels | No | Inherit labels from parent (default: true) | `--inherit-labels` |
| --inherit-assignees | No | Inherit assignees from parent (default: true) | `--inherit-assignees` |
| --section | No | Only parse under this section header | `--section "Implementation Tasks"` |
| --checkbox-only | No | Only parse checkboxes `- [ ]`, ignore bullets/numbers | `--checkbox-only` |
| --max-depth | No | Maximum indentation depth (0 = top-level, default: 0) | `--max-depth 1` |
| --all-bullets | No | Disable section filtering (legacy behavior) | `--all-bullets` |
| --yes, -y | No | Auto-confirm creation without prompting | `--yes` |

### Environment Variables

**Required:**
- `GITHUB_TOKEN` - Fine-grained or classic PAT with `repo` scope

**Optional:**
- `GH_TOKEN` - Alternative name for GitHub token (fallback)

### What the Script Does

1. **Auto-detects repository** - Uses git context to determine owner/repo
2. **Fetches parent issue** - Retrieves issue title, body, labels, assignees via GraphQL
3. **Parses task lists** - Supports multiple formats (see Parsing Patterns)
4. **Shows preview** - Displays proposed sub-issues with inherited metadata
5. **Confirms with user** - Waits for confirmation before creating
6. **Creates sub-issues** - Uses GraphQL `createIssue` mutation with `parentIssueId`
7. **Reports results** - Shows success/failure for each sub-issue with URLs

### Script Behavior

- **Interactive** - Shows preview and waits for confirmation
- **Idempotent** - Safe to run dry-run multiple times
- **Error handling** - Reports specific errors for each sub-issue
- **Repository-agnostic** - Works in any repository without modification
- **Portable** - No hardcoded repository or project IDs
- **Context-aware parsing** - By default, only parses tasks under dedicated task sections

## Best Practices for Parent Issues

The skill uses context-aware parsing by default. Structure your parent issues properly for best results:

### ✅ Good Structure

Place your tasks under a dedicated section header:

```markdown
## Overview
Detailed description of the feature...

## Implementation Tasks

- [ ] Phase 1: Research & Experimentation
- [ ] Phase 2: SDK Layer
- [ ] Phase 3: CLI Layer
- [ ] Phase 4: Testing

## Background
Any explanatory content here won't be parsed as tasks.

## Configuration Details
- **Environment variables**: FOO_BAR (won't be parsed - not under Tasks section)
- **Config file**: settings.toml (won't be parsed)
```

**Why this works:**
- Tasks are clearly separated under `## Implementation Tasks` header
- Explanatory bullets elsewhere are ignored
- Section headers like "Tasks", "Sub-Issues", "Implementation Tasks", "Sub-Tasks" are auto-detected

### ❌ Avoid This Structure

Don't use bullets for non-task content throughout your issue:

```markdown
## Configuration Methods
- **Environment variables**: FOO (this will be parsed as a task!)
- **Config file**: bar.toml (this will be parsed as a task!)
- **CLI flags**: --flag (this will be parsed as a task!)

## Behavior
- When condition X happens (this will be parsed as a task!)
- Need explicit flag Y (this will be parsed as a task!)
```

**Why this fails:**
- Without section filtering, ALL bullets become tasks
- Configuration options become "sub-issues"
- Explanatory text becomes "sub-issues"
- Results in 50+ unwanted sub-issues

**How to fix:**
- Use paragraphs for explanatory content instead of bullets
- Or use `--section "Tasks"` to explicitly specify which section contains actual tasks
- Or restructure to have a dedicated "Tasks" section

## Common Pitfalls

### Pitfall 1: Over-Parsing Complex Spec Documents

**Problem:** Issue has 100+ lines with bullets for formatting, configuration options, and explanations.

**Symptom:** Script finds 50+ tasks when you only want 5-10.

**Solution:**
1. Use `--dry-run` first to preview what will be parsed
2. Add a dedicated `## Tasks` or `## Implementation Tasks` section
3. Or use `--section "Phase Tasks"` to target specific section
4. Or use `--checkbox-only` for strict checkbox-only parsing

### Pitfall 2: Nested Task Lists

**Problem:** Issue has multi-level nested tasks with sub-items.

**Symptom:** All nested items become separate sub-issues.

**Solution:**
- By default, only top-level items (indent 0) are parsed
- Nested items are automatically skipped
- Use `--max-depth 1` if you want one level of nesting

### Pitfall 3: Using Bullets for Everything

**Problem:** Using `- ` for all content (explanations, options, tasks).

**Symptom:** Everything becomes a task.

**Solution:**
- Reserve bullets for actual tasks only
- Use prose paragraphs for explanations
- Structure issue with dedicated task section
- Or use checkbox-only mode: `--checkbox-only`

## Troubleshooting

### Issue: Too Many Tasks Parsed

**Symptom:** Script finds 50+ tasks but you only have 5-10 actual tasks.

**Diagnosis:** The parser is picking up explanatory bullets, configuration options, or nested details.

**Solutions:**
1. **Preview first:** `--dry-run` to see what's being parsed
2. **Add task section:** Restructure issue with `## Tasks` header
3. **Target specific section:** Use `--section "Implementation Tasks"`
4. **Strict mode:** Use `--checkbox-only` to only parse `- [ ]` items
5. **Check for nesting:** Verify indented items aren't being parsed (they shouldn't be by default)

**Example:**
```bash
# Preview what will be created
python scripts/create_subissues.py --issue 46 --dry-run

# Only parse under "Implementation Tasks" section
python scripts/create_subissues.py --issue 46 --section "Implementation Tasks"

# Strict checkbox-only mode
python scripts/create_subissues.py --issue 46 --checkbox-only
```

### Issue: No Tasks Found

**Symptom:** Script reports "No tasks found" but issue clearly has tasks.

**Diagnosis:** Tasks aren't under a recognized section header.

**Solutions:**
1. **Check section header:** Ensure tasks are under `## Tasks`, `## Sub-Issues`, or similar
2. **Specify section explicitly:** Use `--section "Your Custom Header"`
3. **Disable filtering:** Use `--all-bullets` to parse all bullets (legacy behavior)
4. **Verify format:** Ensure using supported formats (`- [ ]`, `1.`, `*`, `-`)

**Example:**
```bash
# Parse under custom section header
python scripts/create_subissues.py --issue 46 --section "Phase List"

# Disable section filtering (parse all bullets)
python scripts/create_subissues.py --issue 46 --all-bullets
```

### Issue: Warning About 20+ Tasks

**Symptom:** Script warns "Found more than 20 tasks" and suggests alternatives.

**Diagnosis:** Likely over-parsing explanatory content.

**What to do:**
1. Run `--dry-run` to review what's being parsed
2. Restructure issue to have clear task section
3. Use `--section` or `--checkbox-only` for stricter parsing
4. If truly 20+ tasks, proceed with caution or break down further

### Issue: Sub-Issues Not Showing in GitHub UI

**Symptom:** Issues created but don't show as "sub-issues" on parent issue.

**Diagnosis:** Only affects manually created issues via `gh issue create` (which doesn't support parent relationships).

**Solution:** Always use this skill's script - it's the only CLI way to create proper parent-child relationships. The script uses GraphQL `createIssue` with `parentIssueId` parameter.

## Parsing Patterns

The skill supports multiple task list formats. For detailed documentation, load `references/parsing-patterns.md` into context.

**Quick reference:**

- Markdown checkboxes: `- [ ] Task name`
- Markdown checked boxes: `- [x] Task name` (skipped by default)
- Numbered lists: `1. Task name`
- Bullet points: `* Task name` or `- Task name`

## Common Use Cases

### Use Case 1: Feature Development with Sub-Tasks

User says: "Break down issue #42 (Add authentication) into sub-tasks"

Execute:
```bash
python scripts/create_subissues.py --issue 42
```

Result: Creates sub-issues for each task in the parent issue description.

### Use Case 2: Preview Before Creating

User says: "Show me what sub-issues would be created from issue #47"

Execute:
```bash
python scripts/create_subissues.py --issue 47 --dry-run
```

Result: Shows preview without creating anything.

### Use Case 3: Cross-Repository Sub-Issues

User says: "Create sub-issues from issue #10 in my other-repo"

Execute:
```bash
python scripts/create_subissues.py --issue 10 --repo username/other-repo
```

Result: Creates sub-issues in specified repository.

## Tips for Effective Usage

1. **Check parent issue format** - Ensure parent issue has clear task list
2. **Use dry-run first** - Preview before creating to verify parsing
3. **Support multiple formats** - Script handles various task list styles
4. **Inherit metadata by default** - Sub-issues get parent labels and assignees
5. **Repository auto-detection** - Works automatically in any git repository
6. **Confirmation required** - Script always asks before creating
7. **Review created sub-issues** - Check URLs in output to verify
8. **Integration with workflows** - Complements GitHub Projects

## Integration with Existing Workflow

This skill enhances the project's GitHub issue-driven development workflow:

**Standard Workflow:**
1. Create parent issue (existing)
2. **NEW: Use this skill to break down into sub-issues**
3. Create branch for sub-issue work (existing)
4. Development (existing)
5. Create PR (existing)
6. Review & Merge (existing)

## References

This skill includes reference documentation:

- `references/parsing-patterns.md` - Detailed documentation of supported task list formats

Load reference files into context when needing detailed information about parsing logic or troubleshooting parsing issues.
