---
name: sub-agents
description: How to create and use specialized subagents in Claude Code for task delegation. Use when user asks about creating specialized agents, delegating tasks, agent configuration, or subagent features.
---

# Subagents

## Overview
Subagents are specialized AI assistants that Claude Code can delegate tasks to. Each operates with its own context window, custom system prompt, and configurable tool access.

## Key Features

**Context Management**: Each subagent operates in its own context, preventing pollution of the main conversation

**Specialization**: Task-specific configurations enable higher success rates on designated work

**Reusability**: Once created, subagents work across different projects and teams

**Flexible Permissions**: Individual tool access control per subagent

## Quick Start

1. Run `/agents` command
2. Select "Create New Agent"
3. Choose project-level or user-level scope
4. Define purpose, select tools, customize system prompt
5. Save and invoke automatically or explicitly

## Configuration

### File Locations
- **Project subagents**: `.claude/agents/`
- **User subagents**: `~/.claude/agents/`
- Project-level takes precedence over user-level

### File Format
Markdown with YAML frontmatter containing:
- `name`: Unique identifier
- `description`: Purpose and invocation guidance
- `tools`: Optional comma-separated list
- `model`: Optional model alias (sonnet/opus/haiku) or 'inherit'

### Example Structure
```yaml
---
name: code-reviewer
description: Expert code review specialist. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: inherit
---

Your system prompt explaining the subagent's role and approach...
```

## Available Tools

When configuring subagents, you can grant access to these tools via the `tools` field in frontmatter:

### Tools That Require Permission

**Bash** - Executes shell commands in your environment
- Use for: Running tests, git commands, build scripts
- Example: `Bash`

**Edit** - Makes targeted edits to specific files
- Use for: Code modifications, refactoring
- Example: `Edit`

**NotebookEdit** - Modifies Jupyter notebook cells
- Use for: Data science workflows, notebook updates
- Example: `NotebookEdit`

**SlashCommand** - Runs a custom slash command
- Use for: Invoking user-defined commands
- Example: `SlashCommand`

**WebFetch** - Fetches content from a specified URL
- Use for: Documentation lookup, API calls
- Example: `WebFetch`

**WebSearch** - Performs web searches with domain filtering
- Use for: Finding current information, research
- Example: `WebSearch`

**Write** - Creates or overwrites files
- Use for: Generating new files, reports
- Example: `Write`

### Tools That Don't Require Permission

**Glob** - Finds files based on pattern matching
- Use for: Finding files by name pattern
- Example: `Glob`

**Grep** - Searches for patterns in file contents
- Use for: Code search, pattern matching
- Example: `Grep`

**NotebookRead** - Reads and displays Jupyter notebook contents
- Use for: Analyzing notebooks
- Example: `NotebookRead`

**Read** - Reads the contents of files
- Use for: Code review, analysis
- Example: `Read`

**Task** - Runs a sub-agent to handle complex, multi-step tasks
- Use for: Delegating to other specialized agents
- Example: `Task`

**TodoWrite** - Creates and manages structured task lists
- Use for: Planning and tracking work
- Example: `TodoWrite`

### Configuring Tool Access

**Grant all tools:**
```yaml
tools: Bash, Edit, Read, Write, Glob, Grep, WebFetch, WebSearch
```

**Grant minimal tools (read-only):**
```yaml
tools: Read, Glob, Grep
```

**Grant specific tools for specialized tasks:**
```yaml
tools: Read, Bash, TodoWrite  # For a test runner agent
```

**Omit tools field to inherit from parent:**
```yaml
# No tools field - uses same tools as main Claude instance
```

## Usage Patterns

**Automatic Delegation**: Claude recognizes matching tasks and invokes appropriate subagents

**Explicit Invocation**: Request specific subagents via natural language commands like "Use the debugger subagent to investigate this error"

## Example Subagents

### Code Reviewer
Reviews code for quality, security, and maintainability. Provides feedback categorized by priority (critical/warnings/suggestions).

### Debugger
Specializes in root cause analysis. Captures error messages, isolates failures, and implements minimal fixes.

### Data Scientist
Handles SQL queries and data analysis. Writes optimized queries and provides data-driven recommendations.

## Best Practices

- Generate initial subagents with Claude, then customize
- Design focused subagents with single responsibilities
- Write detailed system prompts with specific instructions
- Limit tool access to necessary functions only
- Version control project-level subagents

## Advanced Usage

**Chaining**: Combine multiple subagents for complex workflows

**Dynamic Selection**: Claude intelligently chooses subagents based on task context and description fields

**Performance**: Subagents preserve main context but may add latency during initial context gathering

## CLI Configuration

Define subagents dynamically with `--agents` flag accepting JSON objects for session-specific or automation-based configurations.
