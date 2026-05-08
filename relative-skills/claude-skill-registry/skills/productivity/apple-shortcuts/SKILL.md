---
name: apple-shortcuts
description: Run user-defined macOS Shortcuts for custom automation workflows. Use when user wants to trigger a Shortcut by name or execute a custom automation.
allowed-tools:
  - Bash
  - AskUserQuestion
---

# Apple Shortcuts

Run user-defined macOS Shortcuts via the `shortcuts` CLI.

## Quick Start

| You want to... | Run... |
|----------------|--------|
| List shortcuts | `shortcuts list` |
| Run a shortcut | `shortcuts run "Name"` |
| View details | `shortcuts view "Name"` |
| Run with file input | `shortcuts run "Name" --input-path /path` |

## Security

**ALWAYS require user confirmation before running any shortcut.**

Shortcuts can do anything - file operations, network requests, app automation.

**Workflow**:
1. `shortcuts list` to find exact name
2. `shortcuts view "Name"` to show what it does
3. Use `AskUserQuestion` to confirm
4. If confirmed: `shortcuts run "Name"`

## Common Issues

| Problem | Solution |
|---------|----------|
| Not found | `shortcuts list` - names are case-sensitive |
| Signing error | `shortcuts sign --mode people-who-know-me "Name"` |
| Permission denied | System Settings > Privacy & Security > Automation |

## Limitations

- **Cannot create/edit** shortcuts - only run existing ones
- **Binary format** - cannot view internal structure
- **Permissions** - user must grant in System Settings

## Troubleshooting & Ideas

See [reference/troubleshooting.md](reference/troubleshooting.md) for detailed troubleshooting and shortcut ideas.

## Related Skills

- `apple-productivity` - Calendar, Contacts, Mail, Messages
- `apple-photos` - Photo library access
