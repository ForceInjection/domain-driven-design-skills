---
name: test-cli
description: Start tmux sessions, send prompts to the CLI, capture output, and verify behavior using helper scripts. Use when testing the CLI, interactive mode, TUI components, or when the user mentions tmux sessions.
allowed-tools:
  - Bash
  - Read
---

# Test CLI Skill

This skill helps test the interactive CLI application using tmux sessions via bash commands, providing a real terminal environment for testing OpenTUI-based interactive components.

## Quick Start: Use Helper Scripts First

**IMPORTANT: Always use these helper scripts for testing. Only use raw tmux commands (documented below) if the scripts don't support your specific use case.**

All scripts are located at `.claude/skills/test-cli/scripts/` and should be run from your project root directory.

### Basic Testing Workflow

```bash
# 1. Start a test session
PANE_ID=$(./.claude/skills/test-cli/scripts/start-cli-test.sh)

# 2. Send a prompt to the CLI
./.claude/skills/test-cli/scripts/send-prompt.sh $PANE_ID "your prompt here" --submit

# 3. Wait for response and capture output
sleep 5
tmux capture-pane -t $PANE_ID -p

# 4. Exit CLI cleanly
./.claude/skills/test-cli/scripts/exit-cli-test.sh $PANE_ID

# 5. Cleanup sessions
./.claude/skills/test-cli/scripts/cleanup-cli-tests.sh
```

### Helper Scripts Reference

#### start-cli-test.sh

Creates a tmux session and launches the CLI. Returns the pane ID.

```bash
# Auto-generated session name
PANE_ID=$(./.claude/skills/test-cli/scripts/start-cli-test.sh)

# Custom session name
PANE_ID=$(./.claude/skills/test-cli/scripts/start-cli-test.sh my-test)
```

#### send-prompt.sh

Sends text character-by-character (simulates realistic typing).

```bash
# Send text without submitting
./.claude/skills/test-cli/scripts/send-prompt.sh $PANE_ID "hello world"

# Send text and press Enter
./.claude/skills/test-cli/scripts/send-prompt.sh $PANE_ID "hello world" --submit
```

#### exit-cli-test.sh

Properly exits the CLI (sends two Ctrl+C within 3 seconds).

```bash
./.claude/skills/test-cli/scripts/exit-cli-test.sh $PANE_ID
```

#### cleanup-cli-tests.sh

Kills test sessions matching a pattern.

```bash
# Kill all "cli-test-*" sessions
./.claude/skills/test-cli/scripts/cleanup-cli-tests.sh

# Custom pattern
./.claude/skills/test-cli/scripts/cleanup-cli-tests.sh "my-test-*"
```

---

## CLI-Specific Behavior

### Exit Confirmation

The CLI requires two Ctrl+C presses within 3 seconds to exit (src/tui/components/TUIApp.tsx:111-123). The `exit-cli-test.sh` script handles this automatically.

## Essential tmux Commands for Debugging

```bash
# Capture output (use after sending prompts)
tmux capture-pane -t $PANE_ID -p              # Current screen
tmux capture-pane -t $PANE_ID -p -S -100      # Last 100 lines
tmux capture-pane -t $PANE_ID -p -S -500      # Last 500 lines

# List all sessions
tmux list-sessions
```

**IMPORTANT: Never use `tmux attach` - it blocks execution. Always use `capture-pane` to read output.**

## Troubleshooting

- **No output after sending prompt**: Add `sleep 5-10` before capturing output
- **Pane not found**: Check session exists with `tmux list-sessions`
- **Need to see what happened**: Capture more lines with `tmux capture-pane -t $PANE_ID -p -S -500`
- **CLI seems stuck**: Capture output to see current state, don't attach to session

## Related Files

- `testing-cli-with-tmux.md` - Original documentation and learnings
- `interactive-tests/` - Interactive test suite using tmux
- `src/tui/components/TUIApp.tsx` - CLI exit behavior implementation
