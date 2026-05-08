---
name: Iterm2
description: iTerm2 terminal emulator and tmux multiplexer expertise. USE WHEN user mentions iTerm2, tmux, terminal sessions, split panes, window management, OR terminal productivity on macOS.
---

# Iterm2

Complete reference for iTerm2 terminal emulator and tmux terminal multiplexer on macOS. Covers keyboard shortcuts, configuration, tmux integration, and productivity workflows.

## Workflow Routing

**When executing a workflow, do BOTH of these:**

1. **Call the notification script** (for observability tracking):
   ```bash
   ~/.claude/Tools/SkillWorkflowNotification WORKFLOWNAME Iterm2
   ```

2. **Output the text notification** (for user visibility):
   ```
   Running the **WorkflowName** workflow from the **Iterm2** skill...
   ```

| Workflow | Trigger | File |
|----------|---------|------|
| **SetupTmux** | "setup tmux", "configure tmux" | `workflows/SetupTmux.md` |
| **TmuxSession** | "tmux session", "attach session", "detach" | `workflows/TmuxSession.md` |
| **TroubleshootTmux** | "tmux not working", "fix tmux" | `workflows/TroubleshootTmux.md` |

## Examples

**Example 1: Split terminal into multiple panes**
```
User: "How do I split my terminal in iTerm2?"
→ References Shortcuts.md
→ Explains Cmd+D (vertical) and Cmd+Shift+D (horizontal)
→ Shows navigation with Cmd+Option+Arrow
```

**Example 2: Setup tmux with iTerm2 integration**
```
User: "How do I use tmux with iTerm2?"
→ Invokes SetupTmux workflow
→ Explains tmux -CC control mode
→ Shows native window integration benefits
```

**Example 3: Manage persistent sessions over SSH**
```
User: "Keep my terminal running after disconnect"
→ Invokes TmuxSession workflow
→ Creates named session with tmux new -s
→ Shows how to reattach after disconnect
```

## Quick Reference

### iTerm2 Essentials

| Action | Shortcut |
|--------|----------|
| Split Vertical | `Cmd+D` |
| Split Horizontal | `Cmd+Shift+D` |
| Navigate Panes | `Cmd+Option+Arrow` |
| Maximize Pane | `Cmd+Shift+Enter` |
| Next/Prev Tab | `Cmd+{` / `Cmd+}` |
| Find | `Cmd+F` |
| Autocomplete | `Cmd+;` |
| Paste History | `Cmd+Shift+H` |
| Instant Replay | `Cmd+Option+B` |
| Find Cursor | `Cmd+/` |

### tmux Essentials

Default prefix: `Ctrl+b`

| Action | Shortcut |
|--------|----------|
| New Session | `tmux new -s name` |
| List Sessions | `tmux ls` or `Ctrl+b s` |
| Attach Session | `tmux attach -t name` |
| Detach | `Ctrl+b d` |
| New Window | `Ctrl+b c` |
| Split Vertical | `Ctrl+b %` |
| Split Horizontal | `Ctrl+b "` |
| Navigate Panes | `Ctrl+b Arrow` |
| Zoom Pane | `Ctrl+b z` |
| Close Pane | `Ctrl+b x` |
| Copy Mode | `Ctrl+b [` |

### iTerm2 + tmux Integration

Run `tmux -CC` for native iTerm2 integration:
- tmux windows appear as native iTerm2 windows
- Use iTerm2 shortcuts instead of tmux prefix
- Sessions persist through disconnects
- Dashboard available via Shell > tmux > Dashboard

## Documentation Index

| Document | Purpose |
|----------|---------|
| `Shortcuts.md` | Complete keyboard shortcut reference |
| `TmuxConfig.md` | tmux configuration (.tmux.conf) guide |
| `TmuxCommands.md` | Full tmux command reference |
