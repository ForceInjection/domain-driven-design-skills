---
name: Terminal Pane & Tab Management
description: Manages terminal panes and tabs for multi-instance workflows. Use when spawning multiple instances, creating new panes/tabs, running commands in separate terminals, splitting the terminal, or when the user mentions "new pane", "new tab", "split terminal", "spawn instance", "multiple terminals", or needs parallel terminal sessions.
---

# Zellij Pane & Tab Management

Helps programmatically manage Zellij terminal multiplexer panes and tabs. Enables Claude Code to spawn multiple instances, run commands in separate terminals, and organize development workflows across multiple panes and tabs.

## Core Responsibilities

1. **Pane creation** - Create new panes in specific directions (left, right, up, down)
2. **Tab management** - Create and close tabs for organizing work
3. **Command execution** - Run commands in new panes/tabs
4. **Instance spawning** - Launch multiple Claude Code or tool instances
5. **Layout organization** - Set up multi-pane development environments

## When to Use Zellij vs Alternatives

**Use Zellij when**:
- Already running inside a Zellij session
- Need to spawn multiple Claude Code instances
- Want to run commands in separate visible panes
- Organizing different tasks (dev server, tests, logs) in one view
- User explicitly mentions Zellij or panes/tabs

**Use direct commands when**:
- Simple background processes (use `&`)
- Not in a Zellij session
- Single terminal is sufficient

## Installation Check

```bash
# Check if Zellij is installed
which zellij || echo "zellij not installed"

# Install if needed
cargo install zellij
# Or via package managers
brew install zellij  # macOS
```

## Basic Usage

```bash
# Create panes in specific directions
zellij action new-pane --direction left
zellij action new-pane --direction right
zellij action new-pane --direction up
zellij action new-pane --direction down

# Create new tab
zellij action new-tab

# Close current pane
zellij action close-pane

# Close current tab
zellij action close-tab

# Run command in new pane (opens pane with command)
zellij run -- npm test
zellij run -- python server.py
zellij run --direction right -- tail -f logs/app.log

# Run command in new tab
zellij run --direction right --name "Tests" -- npm test
```

## Common Patterns

```bash
# Spawn Claude Code instance in new pane
zellij action new-pane --direction right

# Run tests in split pane
zellij run --direction down -- npm test

# Start dev server in new pane
zellij run --direction right -- npm run dev

# Monitor logs in new pane
zellij run --direction down -- tail -f /var/log/app.log

# Create new tab for different project
zellij action new-tab
```

## Common Workflows

### Spawn Multiple Claude Code Instances

```bash
# Create pane on the left for another Claude Code session
zellij action new-pane --direction left

# Create pane below for third instance
zellij action new-pane --direction down
```

### Run Command in New Pane

```bash
# Run tests while keeping current pane active
zellij run --direction right -- npm test

# Start dev server in separate pane
zellij run --direction down -- npm run dev

# Watch build output
zellij run --direction right -- npm run build -- --watch
```

### Organize Work in Tabs

```bash
# Create new tab for backend work
zellij action new-tab

# Create new tab for frontend
zellij action new-tab

# Close tab when done
zellij action close-tab
```

## Best Practices

- Use `zellij run --` to execute commands in new panes (auto-creates pane)
- Use `zellij action new-pane` when you need empty pane for manual work
- Choose appropriate direction based on screen layout
- Use tabs to separate different projects or concerns
- Close panes/tabs when done to keep workspace clean

## Integration Examples

```bash
# Spawn Claude Code in left pane, run tests in right
zellij action new-pane --direction left
zellij run --direction right -- npm test

# Development layout: code (current) | server (right) | logs (down)
zellij run --direction right -- npm run dev
zellij run --direction down -- tail -f logs/app.log
```

## Troubleshooting

- **Command fails**: Ensure you're inside a Zellij session (`echo $ZELLIJ` should not be empty)
- **Pane not created**: Check if there's enough space for new pane in that direction
- **Command not found**: Verify Zellij is installed and in PATH

## Example Workflows

```bash
# Workflow 1: Spawn multiple Claude Code instances for parallel work
zellij action new-pane --direction left   # Claude Code instance 1
zellij action new-pane --direction right  # Claude Code instance 2

# Workflow 2: Run tests while coding
zellij run --direction down -- npm test

# Workflow 3: Monitor application (server + logs)
zellij run --direction right -- npm run dev
zellij run --direction down -- tail -f logs/error.log
```

## Resources

- Docs: https://zellij.dev/documentation/
- GitHub: https://github.com/zellij-org/zellij
