---
name: managing-jira
description: Creates and manages Jira work items via acli CLI. Use when creating Jira issues, updating tasks, transitioning statuses, adding comments, or querying JQL. For Confluence operations, use managing-confluence instead.
allowed-tools: Bash
---

# Managing Jira

Official Atlassian CLI for Jira work items and comments.

## Basic Syntax

```bash
acli jira [COMMAND] [OPTIONS]
```

## Commands

### Work Items

#### View work item details

```bash
acli jira workitem view --key "<issue-key>"

# Example:
acli jira workitem view --key "CM-2766"
```

#### List work items

```bash
acli jira workitem list [OPTIONS]

# Options:
#   --jql TEXT          JQL query to filter work items
#   --max-results INT   Maximum number of results

# Examples:
acli jira workitem list --jql "project = CM AND status = 'In Progress'"
acli jira workitem list --max-results 10
```

#### Create work item

```bash
acli jira workitem create [OPTIONS]

# Options:
#   --summary TEXT      Work item summary (required)
#   --project TEXT      Project key (required)
#   --type TEXT         Work item type (default: Task)
#   --description TEXT  Work item description

# Example:
acli jira workitem create --summary "Fix OAuth bug" --project "CM" --type "Bug"
```

#### Edit work item

```bash
acli jira workitem edit --key "<issue-key>" [OPTIONS]

# Options:
#   --summary TEXT      New summary
#   --description TEXT  New description

# Example:
acli jira workitem edit --key "CM-2766" --summary "Updated OAuth implementation"
```

#### Transition work item status

```bash
acli jira workitem transition --key "<issue-key>" --status "<status>"

# Example:
acli jira workitem transition --key "CM-2766" --status "In Progress"
```

### Comments

#### Add comment

```bash
acli jira workitem comment create --key "<issue-key>" --body "<comment-text>"

# Examples:
acli jira workitem comment create --key "CM-2766" --body "Updated the implementation"

# Multi-line comment:
acli jira workitem comment create --key "CM-2766" --body "$(cat << 'EOF'
## Resumen Ejecutivo

Se corrigió bug crítico en OAuth...
EOF
)"
```

#### List comments

```bash
acli jira workitem comment list --key "<issue-key>"

# Example:
acli jira workitem comment list --key "CM-2766"
```

## Common Patterns

### Post manager summary to Jira

```bash
# Post Spanish manager summary to Jira issue
acli jira workitem comment create --key "CM-2766" --body "$(cat << 'EOF'
## Resumen Ejecutivo

Se corrigió bug crítico en autenticación OAuth que afectaba...

**Impacto:**
- Sistema de autenticación estabilizado
- Reducción de errores de login en 95%

**Próximos Pasos:**
- Monitorear métricas por 48h
- Documentar cambios
EOF
)"
```

### Check work item before working

```bash
# View full work item details
acli jira workitem view --key "CM-2766"

# List recent comments
acli jira workitem comment list --key "CM-2766"
```

### Query for related work items

```bash
# Find all in-progress issues in project
acli jira workitem list --jql "project = CM AND status = 'In Progress'"

# Find issues assigned to you
acli jira workitem list --jql "assignee = currentUser()"
```

## Common Errors

### Invalid work item key

**ERROR:** `Issue does not exist or you do not have permission to see it`

**SOLUTION:** Verify the issue key format (e.g., "CM-2766") and ensure you have access to the project.

## Getting Help

Use `--help` on any command:

```bash
acli jira --help
acli jira workitem --help
acli jira workitem view --help
acli jira workitem comment --help
```
