---
name: Task Patterns
description: Complete tp CLI reference for Linear integration. Use when working with Linear issues (create, update, comment, labels), managing parent/child relationships, or setting up team configuration. Covers both daily issue management and initial project setup.
---

# Task Patterns CLI Reference

Expert guidance for using `tp` (task-patterns) - an AI-assisted Linear CLI for workflow integration.

## Overview

`tp` provides:
- Quick issue creation and updates
- Hierarchical label management
- Team-based filtering
- Epic/parent-child relationships
- AI context aggregation
- Integration with planning workflows

---

# Part 1: Daily Issue Management

Commands you use constantly during development.

## Basic Commands

### Create Issues
```bash
tp add "Implement user authentication"
tp add "Add Redis caching" --team BE
```

### View Issues
```bash
tp show TEMPO-123                 # Single issue
tp show TEMPO-1 TEMPO-2 TEMPO-3   # Multiple issues
tp context                        # Current work (filtered by team)
```

### Update Issues
```bash
# Status changes
tp update TEMPO-123 --status "In Progress"
tp working TEMPO-123              # Shortcut for "In Progress"
tp done TEMPO-123                 # Shortcut for "Done"

# Labels
tp update TEMPO-123 --add-labels "Epic,Backend,Infrastructure"
tp update TEMPO-123 --remove-labels "Infrastructure"
tp update TEMPO-123 --set-labels "Task,Frontend,Feature Dev"

# Content
tp update TEMPO-123 --title "New title"
tp update TEMPO-123 --description "Detailed description"
```

### Comments
```bash
tp comment TEMPO-123 "This is ready for review"
tp comments TEMPO-123             # View all comments
```

### Parent/Child Relationships
```bash
# Link child to parent (epic structure)
tp link-parent TEMPO-124 TEMPO-123

# Unlink from parent
tp unlink-parent TEMPO-124

# Common pattern: Create epic with children
tp add "Epic: User Authentication"        # → TEMPO-100
tp add "Implement JWT tokens"             # → TEMPO-101
tp add "Add password hashing"             # → TEMPO-102
tp link-parent TEMPO-101 TEMPO-100
tp link-parent TEMPO-102 TEMPO-100
```

## Common Workflows

### Workflow 1: Daily Development

```bash
# Morning
tp context                        # What's on my plate?
tp show TEMPO-42                  # Review details
tp working TEMPO-42               # Start work

# During implementation
# ... make changes ...
git commit -m "feat: implement feature (TEMPO-42)"

# Mark complete
tp done TEMPO-42
```

### Workflow 2: Creating Epic with Children

```bash
# Create epic
tp add "Epic: Redis Caching Layer"        # → TEMPO-100
tp update TEMPO-100 --add-labels "Epic,Backend,Infrastructure"

# Create children
tp add "Add Redis Docker service"          # → TEMPO-101
tp add "Create cache abstraction layer"    # → TEMPO-102
tp add "Implement UserService caching"     # → TEMPO-103

# Link all children to epic
for issue in TEMPO-101 TEMPO-102 TEMPO-103; do
  tp link-parent $issue TEMPO-100
  tp update $issue --add-labels "Task,Backend,Infrastructure"
done
```

### Workflow 3: Bulk Status Updates

```bash
# Move multiple issues to same status
for issue in TEMPO-101 TEMPO-102 TEMPO-103; do
  tp update $issue --status "Ready"
done
```

## Label System

### Label Structure

tp supports hierarchical labels organized into groups:

**Issue Type** (mutually exclusive, one per issue):
- `Epic` - Large, multi-step bodies of work
- `Story` - Complete user-facing features
- `Task` - Individual implementation work
- `Subtask` - Part of an implementation step

**Stack** (mutually exclusive, REQUIRED):
- `Backend` - Backend-only (Python, FastAPI, database)
- `Frontend` - Frontend-only (React, TypeScript, UI)
- `Full Stack` - Work spanning both

**Work Type** (mutually exclusive):
- `Infrastructure` - Setup, tooling, Docker, CI/CD
- `Architecture` - Design, planning, architecture decisions
- `Feature Dev` - New feature implementation
- `Bugfix` - Bug fixes and corrections
- `Documentation` - README, guides, docs

**Domain** (multiple allowed, optional):
- `Accounts`, `Activities`, `Deals`, `Users`, `ai`, `Search`

### Label Commands

```bash
# List and search
tp labels list
tp labels list --hierarchy
tp labels search "backend"

# Create
tp labels create "mvp" --description "MVP scope features"
tp labels create "type:epic" --description "Large bodies of work"
tp labels create "Backend" --color "#EF4444" --description "Backend work"

# Update
tp labels update "Epic" --description "New description"
tp labels update "Epic" --color "#8B5CF6"

# Delete
tp labels delete "old-label"

# Templates
tp labels templates                        # List available
tp labels apply-template task-patterns     # Apply template
```

### Label Application Patterns

```bash
# Epic with full labeling
tp add "Epic: Backend Foundation"
tp update TEMPO-1 --add-labels "Epic,Backend,Infrastructure"

# Task with multiple labels
tp add "Configure Docker services"
tp update TEMPO-2 --add-labels "Task,Backend,Infrastructure"

# Full stack work with domain tags
tp update TEMPO-10 --add-labels "Story,Full Stack,Feature Dev,Accounts,Users"
```

## Integration with Commands

### Planning Command Integration

```bash
# 1. Decompose requirements into YAML
/plan:1-decompose-requirements "Add user authentication system"
# → Generates: issue-plan-user-auth.yaml

# 2. Create Linear issues from YAML
/plan:2-create-issues issue-plan-user-auth.yaml
# → Creates TEMPO-1 (epic) + TEMPO-2..5 (children)

# 3. Generate detailed specs
/plan:3-generate-spec TEMPO-2
# → Creates specs/issue-TEMPO-2-*.md

# 4. Implement
/implement TEMPO-2
```

### Using tp in Commands

Commands can use tp skill for Linear operations:

```markdown
# In a command like /analyze-implementation:
Use task-patterns skill to fetch issue TEMPO-123
Use task-patterns skill to post comment with strategy to TEMPO-123
Use task-patterns skill to add label "state:awaiting-strategy-review" to TEMPO-123
Use task-patterns skill to update status to "Refinement"
```

**Implementation**:
```bash
# Fetch issue
ISSUE_JSON=$(tp show TEMPO-123 --format json)
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')

# Post comment
tp comment TEMPO-123 "Strategy content here..."

# Add label
tp update TEMPO-123 --add-labels "state:awaiting-strategy-review"

# Update status
tp update TEMPO-123 --status "Refinement"
```

## AI Context

Get comprehensive project context for AI assistants:

```bash
tp ai-context
```

Returns: Current issues, team structure, label taxonomy, workflow patterns.

## Command Aliases

- `tp a` = `tp add`
- `tp u` = `tp update`
- `tp s` = `tp show`
- `tp c` = `tp context`
- `tp d` = `tp done`
- `tp w` = `tp working`
- `tp l` = `tp labels`
- `tp t` = `tp team`

## Best Practices

**Issue Creation:**
1. Use clear, action-oriented titles: "Implement JWT authentication" not "JWT"
2. Add descriptions for non-trivial work
3. Label immediately - don't defer

**Label Management:**
1. Always include Stack label (required for workflow integration)
2. One Issue Type per issue (Epic, Story, Task, or Subtask)
3. One Work Type per issue
4. Multiple Domain labels OK

**Epic Structure:**
1. Epic = High-level feature describing complete capability
2. Children = Atomic units that can be implemented independently
3. Order children: foundation → implementation → integration

**Team Organization:**
1. Use team filters: `tp config teams TEMPO`
2. Create team-specific labels when needed
3. Use `Full Stack` label for cross-team work

---

# Part 2: Project Setup (Reference)

Initial configuration - typically done once per project.

## Team Configuration

### Configuration Hierarchy

1. **Local Project** (`.tp/config.json`) - Project-specific settings
2. **Global User** (`~/.task-pattern/config.json`) - User preferences
3. **Environment Variables** - System defaults

### Setup Commands

```bash
# Initialize project
cd /path/to/project
tp config init

# Set team filter
tp config teams TEMPO
tp config teams TEMPO BE          # Multiple teams

# Set default team for new issues
tp config set defaultTeam TEMPO

# View configuration
tp config show
```

### Configuration File Example

`.tp/config.json`:
```json
{
  "teamFilter": ["TEMPO", "BE"],
  "defaultTeam": "TEMPO",
  "workspaceId": "optional_workspace_id"
}
```

**Note**: Commit `.tp/config.json` to git for team standardization.

### Multi-Team Coordination

```bash
# Set team filters for cross-team visibility
tp config teams BACKEND FRONTEND

# Override for specific command
tp add "Backend task" --team BACKEND

# Switch contexts
tp config teams TEMPO             # Focus on TEMPO team
tp context                        # Shows TEMPO issues only
```

## Initial Label Setup

### Apply Label Templates

```bash
# List available templates
tp labels templates

# Apply template to team
tp labels apply-template task-patterns -t TEMPO
tp labels apply-template engineering -t TEMPO
```

### Create Custom Label Structure

```bash
# Issue Types
tp labels create "Epic" --color "#8B5CF6" --description "Large features"
tp labels create "Story" --color "#3B82F6" --description "User stories"
tp labels create "Task" --color "#10B981" --description "Implementation work"

# Stack
tp labels create "Backend" --color "#EF4444" --description "Backend work"
tp labels create "Frontend" --color "#F59E0B" --description "Frontend work"
tp labels create "Full Stack" --color "#8B5CF6" --description "Full stack work"

# Work Types
tp labels create "Infrastructure" --color "#6B7280" --description "Setup and tooling"
tp labels create "Feature Dev" --color "#10B981" --description "New features"
tp labels create "Bugfix" --color "#DC2626" --description "Bug fixes"
```

### Hierarchical Labels

```bash
# Use category:value format for automatic grouping
tp labels create "type:epic" --description "Large features"
tp labels create "type:task" --description "Implementation work"
tp labels create "stack:backend" --description "Backend work"
tp labels create "stack:frontend" --description "Frontend work"
```

## Team Management

```bash
# List all teams
tp team list

# Show team details
tp team show TEMPO

# Team analytics
tp team stats TEMPO

# Set default team
tp team set-default TEMPO
```

## New Project Setup Checklist

1. **Initialize configuration**:
   ```bash
   cd /path/to/project
   tp config init
   tp config teams MYTEAM
   ```

2. **Set up labels**:
   ```bash
   tp labels apply-template task-patterns -t MYTEAM
   ```

3. **Create initial issues**:
   ```bash
   tp add "Project setup and infrastructure"
   tp add "Core feature implementation"
   ```

4. **Commit config**:
   ```bash
   git add .tp/config.json
   git commit -m "chore: add tp config for MYTEAM"
   ```

## Troubleshooting

### Label Errors

**"Label not found"**:
```bash
tp labels list                    # Check available labels
tp labels search "backend"        # Search for label
tp config show                    # Verify team filter
```

**"LabelIds not exclusive child labels"**:
```bash
tp labels hierarchy               # View label groups
# Only apply one label per exclusive group
# Example: Can't use both "Backend" and "Frontend"
```

### Configuration Issues

**Reset configuration**:
```bash
tp config reset
tp config init
tp config teams TEMPO
```

**Check configuration sources**:
```bash
tp config show                    # Merged config
cat .tp/config.json              # Local project
cat ~/.task-pattern/config.json  # Global user
```

### Status Errors

**"Issue must be in Refinement status"**:
```bash
tp show TEMPO-123                 # Check current status
tp update TEMPO-123 --status "Refinement"
```

## Debugging

Enable verbose logging:
```bash
LOG_LEVEL=debug tp context
LOG_LEVEL=info tp labels list --team TEMPO
```

---

## Quick Tips

1. **Use `tp context` frequently** - Stay oriented with current work
2. **Reference IDs in commits** - `git commit -m "feat: add X (TEMPO-123)"`
3. **Label as you go** - Don't batch labeling
4. **Use epic structure** - Break large work into epics with children
5. **Leverage AI context** - `tp ai-context` provides comprehensive info
6. **Update status progressively** - Don't wait to batch update

---

## Resources

- `tp --help` - Complete command reference
- `tp <command> --help` - Specific command details
- `tp ai-context` - AI assistant guidance
- `tp team stats <KEY>` - Team analytics
- `tp labels hierarchy` - Visualize label structure
