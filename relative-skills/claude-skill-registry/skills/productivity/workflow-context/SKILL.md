---
name: workflow-context
description: Auto-load workflow settings when working in a project directory
---

# Workflow Context

Automatically load and apply workflow settings when working in a project.

## When to Use

This skill should be used implicitly by other plugins (git, jira, confluence, notion) when they need to read workflow configuration.

## Loading Configuration

### Step 1: Check for workflow.json

```bash
cat .claude/workflow.json 2>/dev/null
```

### Step 2: Parse Configuration

If file exists, parse and extract:

**Git Settings:**
- `git.strategy` - Branching strategy (github-flow, git-flow, trunk-based)
- `git.branches.main` - Main branch name
- `git.branches.develop` - Develop branch name (for git-flow)
- `git.merge.method` - Merge method (squash, merge, rebase)
- `git.pr.defaultTarget` - Default PR target branch

**Jira Settings:**
- `jira.enabled` - Whether Jira integration is active
- `jira.cloudId` - Atlassian cloud ID
- `jira.projectKey` - Current project key
- `jira.includeInBranch` - Include issue key in branch names
- `jira.includeInCommit` - Include issue key in commit messages

**Notion Settings:**
- `notion.enabled` - Whether Notion integration is active
- `notion.databases.todo.id` - TODO database ID
- `notion.databases.til.id` - TIL database ID
- `notion.databases.blog.id` - BLOG database ID

**Confluence Settings:**
- `confluence.enabled` - Whether Confluence sync is active
- `confluence.spaceKey` - Confluence space key

## Usage by Other Plugins

### git plugin

```markdown
# In git:branch, git:commit, git:pr

## Step 0: Load Workflow Context
cat .claude/workflow.json 2>/dev/null

If jira.enabled && jira.includeInBranch:
  - Offer to link Jira issue to branch
  - Include issue key in branch name

If jira.enabled && jira.includeInCommit:
  - Extract issue key from branch name
  - Append [ISSUE-KEY] to commit message
```

### jira plugin

```markdown
# In jira:start, jira:create, jira:done

## Step 0: Load Workflow Context
cat .claude/workflow.json 2>/dev/null

Use jira.cloudId for API calls
Use jira.projectKey for issue queries
Use notion.databases.todo.id for Notion sync
```

### confluence plugin

```markdown
# In confluence:sync

## Step 0: Load Workflow Context
cat .claude/workflow.json 2>/dev/null

If confluence.enabled:
  - Sync files to Confluence
  - Use confluence.spaceKey for page creation
```

### notion plugin

```markdown
# In notion:til, notion:blog

## Step 0: Load Workflow Context
cat .claude/workflow.json 2>/dev/null

If notion.enabled:
  - Use notion.databases.til.id for TIL
  - Use notion.databases.blog.id for BLOG
```

## Configuration Not Found

When `.claude/workflow.json` does not exist:

1. Inform user that workflow is not configured
2. Suggest running `/workflow:init`
3. Continue with default behavior (if applicable)

Example message:
```
ℹ Workflow not configured. Run /workflow:init to set up Jira and Git integration.
```

## Default Values

When workflow.json exists but specific settings are missing:

| Setting | Default |
|---------|---------|
| git.strategy | github-flow |
| git.branches.main | main |
| git.merge.method | squash |
| jira.enabled | false |
| jira.includeInBranch | true |
| jira.includeInCommit | true |
| notion.enabled | false |
| confluence.enabled | false |
