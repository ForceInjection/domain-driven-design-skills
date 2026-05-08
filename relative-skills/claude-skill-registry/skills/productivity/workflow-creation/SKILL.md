---
name: Workflow Creation
description: This skill should be used when the user asks to "create a workflow", "make a slash command", "add a command", "automate a task with a command", "workflow vs plugin", "should this be a workflow or plugin", or needs guidance on Claude Code command structure, workflow design patterns, or determining appropriate scope for automation requests.
version: 0.1.0
---

# Workflow Creation for Claude Code

## Overview

This skill provides guidance for creating effective Claude Code workflows (slash commands) and determining when a request needs a simple workflow versus a full plugin.

**Key concepts:**
- Workflows are Markdown files that become slash commands
- Commands are instructions FOR Claude, not TO users
- Scope assessment determines workflow vs plugin routing
- Quality standards ensure team consistency

## Workflow vs Plugin Decision Framework

### Choose WORKFLOW (slash command) when:

| Criterion | Workflow Appropriate |
|-----------|---------------------|
| **Purpose** | Single, focused task |
| **State** | No persistent state needed |
| **Execution** | One-shot, runs and completes |
| **Scope** | Project-specific or personal |
| **Complexity** | Simple logic, no validation hooks |
| **Integration** | Uses built-in tools only |
| **Reusability** | Used in one project mainly |

**Examples of workflows:**
- `review-pr` - Review current PR changes
- `run-tests` - Execute test suite with coverage
- `generate-docs` - Create documentation for file
- `commit-changes` - Stage and commit with message
- `fix-lint` - Auto-fix linting issues

### Choose PLUGIN when:

| Criterion | Plugin Required |
|-----------|-----------------|
| **Commands** | Multiple related commands needed |
| **Automation** | Needs hooks for automatic triggering |
| **Autonomy** | Needs agents for complex autonomous tasks |
| **Knowledge** | Needs skills for specialized guidance |
| **Integration** | External service via MCP servers |
| **Scope** | Reusable across multiple projects |
| **Validation** | Complex validation or enforcement logic |

**Examples requiring plugins:**
- Database migration system (create, run, rollback commands + validation hooks)
- API testing framework (multiple commands + test runner agent)
- Code review system (command + reviewer agent + standards skill)
- External service integration (MCP server + commands)

### Decision Questions

Ask these to determine scope:

1. "Will this need multiple related commands?" → Yes = Plugin
2. "Should something happen automatically on certain events?" → Yes = Plugin (hooks)
3. "Does it need to work autonomously on complex tasks?" → Yes = Plugin (agents)
4. "Does it integrate with external services?" → Yes = Plugin (MCP)
5. "Will multiple projects use this?" → Yes = Plugin

If all answers are "No" → Workflow is appropriate.

## Workflow Structure

### File Location

```
.claude/commands/
├── workflow-name.md      # /workflow-name command
└── category/
    └── specific.md       # /specific (project:category)
```

### Basic Format

```markdown
---
description: Brief description under 60 chars
argument-hint: [required-arg] [optional-arg]
allowed-tools: Read, Write, Grep
---

[Instructions for Claude - imperative form]
```

### Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `description` | Recommended | Shows in /help, under 60 chars |
| `argument-hint` | If args used | Documents expected arguments |
| `allowed-tools` | Recommended | Restrict tools (security) |
| `model` | Optional | Force specific model |

### Writing Instructions

**Critical Rule**: Write instructions FOR Claude to execute, not messages TO the user.

**Correct (imperative form):**
```markdown
Review the code changes in the current branch.

Check for:
1. Security vulnerabilities
2. Performance issues
3. Code style violations

Report findings with file paths and line numbers.
```

**Incorrect (user-facing):**
```markdown
This command will review your code.
You'll receive a report with issues found.
```

## Arguments and Dynamic Content

### Single Argument

```markdown
---
argument-hint: [file-path]
---

Review @$1 for code quality issues.
```

Usage: `/review src/api/users.ts`

### Multiple Arguments

```markdown
---
argument-hint: [source] [target]
---

Compare @$1 with @$2 and list differences.
```

Usage: `/compare old.js new.js`

### All Arguments

```markdown
---
argument-hint: [search-terms...]
---

Search codebase for: $ARGUMENTS
```

Usage: `/search authentication user login`

### File References

Use `@` to include file contents:

```markdown
Review @$1 for issues.           # File from argument
Review @package.json settings.   # Static file reference
```

## Tool Restrictions

### Principle of Least Privilege

Only grant tools the workflow actually needs:

| Task Type | Recommended Tools |
|-----------|-------------------|
| Read-only analysis | `Read, Grep, Glob` |
| Code modification | `Read, Write, Edit` |
| Git operations | `Bash(git:*)` |
| Testing | `Bash(npm:test), Read` |
| Full automation | Omit field (all tools) |

### Tool Patterns

```yaml
# Specific tools
allowed-tools: Read, Write, Grep

# Bash with restrictions
allowed-tools: Bash(git:*), Bash(npm:*)

# All tools (rarely needed)
allowed-tools: "*"
```

## Quality Checklist

Before finalizing a workflow, verify:

- [ ] **Name**: kebab-case, verb-noun pattern
- [ ] **Description**: Clear, under 60 characters
- [ ] **Instructions**: Written FOR Claude (imperative)
- [ ] **Arguments**: Documented with argument-hint
- [ ] **Tools**: Minimal necessary set
- [ ] **Location**: In `.claude/commands/`
- [ ] **Testing**: Verify it works as expected

## Common Patterns

### Code Review Pattern

```markdown
---
description: Review code changes for quality issues
allowed-tools: Read, Grep, Glob, Bash(git:*)
---

Get changed files: !`git diff --name-only HEAD~1`

For each changed file:
1. Read the file content
2. Check for security issues
3. Check for performance problems
4. Verify code style

Report issues with:
- File path and line number
- Issue description
- Suggested fix
```

### Testing Pattern

```markdown
---
description: Run tests for specific module
argument-hint: [module-path]
allowed-tools: Bash(npm:*), Read
---

Run tests: !`npm test -- $1`

Analyze results:
- List failing tests
- Identify root causes
- Suggest fixes

If all pass, confirm success.
```

### Generation Pattern

```markdown
---
description: Generate documentation for file
argument-hint: [source-file]
---

Read and analyze @$1

Generate documentation including:
- Purpose and overview
- Function/class descriptions
- Parameters and return values
- Usage examples

Write to appropriate location based on project structure.
```

### Git Workflow Pattern

```markdown
---
description: Commit changes with conventional message
argument-hint: [type] [description]
allowed-tools: Bash(git:*)
---

Stage changes: !`git add -A`
Show staged: !`git diff --cached --stat`

Create commit with type "$1" and message "$2".
Follow conventional commits format:
- feat: new feature
- fix: bug fix
- docs: documentation
- refactor: code refactoring

Confirm commit created successfully.
```

## Troubleshooting

**Workflow not appearing in /help:**
- Check file is in `.claude/commands/`
- Verify `.md` extension
- Restart Claude Code session

**Arguments not working:**
- Use `$1`, `$2` for positional
- Use `$ARGUMENTS` for all
- Check argument-hint matches usage

**Tools not available:**
- Verify allowed-tools includes needed tools
- Check tool name spelling
- Use `Bash(pattern:*)` for bash restrictions

**File references not loading:**
- Use `@` prefix for file paths
- Ensure Read tool is allowed
- Check file path is correct

## Integration with Plugin Components

When a workflow needs to leverage plugin components:

**Invoke Agent:**
```markdown
Use the code-reviewer agent for detailed analysis.
```

**Reference Skill:**
```markdown
Apply coding-standards skill guidelines.
```

**Trigger Another Command:**
```markdown
After completion, run /validate-changes.
```

This skill provides the foundation for creating effective, well-structured workflows that maintain team consistency and follow Claude Code best practices.
