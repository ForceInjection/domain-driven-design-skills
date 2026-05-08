---
name: custom-command-creator
description: This skill must be used when users want to create custom slash commands. Activates with phrases like "create a command", "make a slash command", "add custom command", "create command for", or "automate with a command".
---

# Custom Command Creator

This skill guides the creation of custom Amp commands accessible via the Command Palette (Cmd/Alt-Shift-A in VS Code or Ctrl-O in CLI).

## What Custom Commands Do

Custom commands append their output to the prompt input when invoked. They provide reusable prompts and automated workflows:

- **Markdown commands** (.md files) — Static prompt templates inserted directly
- **Executable commands** — Scripts that run and output dynamic content (can accept arguments)

## Command Locations

Commands are discovered from various locations:

1. **Workspace-local**: `.agents/commands/` in the current workspace
2. **Global**: `~/.config/amp/commands` (or `$XDG_CONFIG_HOME/amp/commands` if set)
3. **Claude Code-compatible workspace**: `.claude/skills/`
4. **Claude Code-compatible global**: `~/.claude/skills/`

Choose a location based on whether it is specific to the workspace, or would apply across workspaces. Only use the Claude code-compatible locations if the user specifically indicates they want it to work for all agents, not just Amp.

The command name is derived from the filename (without extension).

## Command Types

### Type 1: Markdown Commands

Static prompt templates that insert their contents directly.

**When to use:**

- Consistent prompts reused across sessions
- System prompts, personas, or instruction sets
- Review templates with fixed structure

**Structure:**

```markdown
# Command Title

## SYSTEM (optional)

System-level instructions for Claude's behavior.

## ASSISTANT RULES (optional)

Specific rules for how Claude should respond.

## OUTPUT FORMAT (optional)

Expected structure of Claude's response.

[Main prompt content...]
```

### Type 2: Executable Commands

Scripts that generate dynamic prompts based on context, arguments, or external data.

**When to use:**

- Commands that need runtime data (API calls, git state, file contents)
- Commands accepting user arguments
- Integration with external tools (Linear, GitHub, Jira)

**Requirements:**

- Must be executable (chmod +x) OR have shebang on first line
- Output goes to stdout (combined with stderr, max 50k chars)
- Can accept arguments passed at invocation

**Shebang examples:**

```bash
#!/bin/bash
#!/usr/bin/env python3
#!/usr/bin/env node
```

## Creation Process

### Step 1: Determine Command Type

Ask clarifying questions:

- "Should this command be static (same every time) or dynamic (changes based on context)?"
- "Does it need to accept arguments?"
- "Does it need to fetch data from external APIs or tools?"

**Decision matrix:**
| Need | Type |
|------|------|
| Static prompt | Markdown |
| Accepts arguments | Executable |
| Fetches external data | Executable |
| Uses git/file state | Executable |

### Step 2: Determine Scope

- **Workspace-local** (`.agents/commands/`) — Project-specific commands
- **Global** (`~/.config/amp/commands`) — Commands available everywhere

### Step 3: Create the Command

#### For Markdown Commands

1. Create the file at the appropriate location
2. Write clear, actionable instructions
3. Use sections (SYSTEM, ASSISTANT RULES, OUTPUT FORMAT) for complex prompts

#### For Executable Commands

1. Create the script with proper shebang
2. Handle arguments via `$1`, `$2`, etc. (bash) or `sys.argv` (Python)
3. Output the prompt to stdout
4. Make executable: `chmod +x <command-file>`

### Step 4: Test the Command

Instruct the user to:

1. Open Command Palette (Cmd/Alt-Shift-A or Ctrl-O)
2. Find and invoke the command
3. Verify the output appears in prompt input

## Best Practices

### Markdown Commands

- Use clear section headers for organization
- Include examples of expected output format
- Keep system instructions concise but complete
- Use fenced code blocks for structured output examples

### Executable Commands

- Always validate required arguments exist
- Provide helpful usage messages for missing args
- Handle API errors gracefully with meaningful messages
- Use environment variables for secrets (never hardcode)
- Load .env files from project root when needed
- Exit with non-zero code on errors

### General

- Name commands descriptively: `pr-review`, `work-on-issue`, `daily-standup`
- Document any required setup (API keys, dependencies)
- Keep prompts focused on a single workflow

## Helper Script

To initialize a new command with boilerplate, use:

```bash
scripts/init_command.py <command-name> --type <markdown|bash|python> [--scope <local|global>]
```

See `references/command-examples.md` for complete working examples including:

- PR review template (Markdown)
- Linear issue integration (Bash executable)
