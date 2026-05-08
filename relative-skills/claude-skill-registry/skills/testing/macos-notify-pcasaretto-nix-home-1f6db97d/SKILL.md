---
name: macos-notify
description: Send macOS desktop notifications after completing tasks, making significant changes, or before requesting permission. Use for task completion, file modifications, test results, and major milestones.
---

# macOS Notification Skill

Send desktop notifications using AppleScript via osascript. This provides immediate feedback when Claude completes work.

## When to Use

Send notifications in these situations:
- After completing a set of file changes
- After finishing tasks or major milestones
- Before requesting permission for significant actions
- After running tests or builds successfully
- When long-running operations complete

## Implementation

Use the Bash tool with osascript to display notifications:

```bash
/usr/bin/osascript -e "display notification \"message\" with title \"title\" sound name \"Hero\""
```

## Parameters

### Required
- **title**: Short notification title (appears in bold)
- **message**: Main notification body text

### Optional
- **sound**: Sound name (e.g., "Hero", "Ping", "Glass", "Basso", "Blow", "Bottle", "Frog", "Funk", "Pop", "Purr", "Sosumi", "Submarine", "Tink")
- **subtitle**: Additional context line between title and message
- **group**: Identifier for notification coalescing (groups related notifications)

## String Escaping

AppleScript requires escaping special characters:
- Backslash: Replace `\` with `\\`
- Double quote: Replace `"` with `\"`

Example: To display `Fixed "foo" function`, use:
```bash
"display notification \"Fixed \\\"foo\\\" function\" with title \"Update\""
```

## Usage Examples

### Basic Notification
```bash
/usr/bin/osascript -e "display notification \"Task completed successfully\" with title \"Claude Code\" sound name \"Hero\""
```

### With Subtitle
```bash
/usr/bin/osascript -e "display notification \"Modified 3 files\" with title \"Task Complete\" subtitle \"Build passing\" sound name \"Hero\""
```

### With Proper Escaping
```bash
/usr/bin/osascript -e "display notification \"Fixed \\\"calculateTotal\\\" function\" with title \"Code Update\" sound name \"Ping\""
```

### Different Sounds
```bash
/usr/bin/osascript -e "display notification \"Tests passing\" with title \"Test Results\" sound name \"Glass\""
```

### Grouped Notifications
```bash
/usr/bin/osascript -e "display notification \"Step 1 complete\" with title \"Migration\" sound name \"Hero\""
/usr/bin/osascript -e "display notification \"Step 2 complete\" with title \"Migration\" sound name \"Hero\""
```

## Common Patterns

### After File Changes
```bash
/usr/bin/osascript -e "display notification \"Updated 5 files in src/components/\" with title \"Files Modified\" sound name \"Hero\""
```

### After Test Run
```bash
/usr/bin/osascript -e "display notification \"All 47 tests passed\" with title \"Test Suite\" subtitle \"0 failures\" sound name \"Glass\""
```

### Before Destructive Action
```bash
/usr/bin/osascript -e "display notification \"Ready to delete 15 files\" with title \"Confirmation Needed\" sound name \"Basso\""
```

### Build Complete
```bash
/usr/bin/osascript -e "display notification \"Build completed in 23s\" with title \"Build Success\" sound name \"Hero\""
```

## Error Handling

If osascript fails, the command will return an error. Common issues:
- Notification Center permissions not granted
- Invalid sound name (will use default sound)
- Malformed AppleScript (check escaping)

## Best Practices

1. Keep messages concise and actionable
2. Use "Hero" sound for successful completions (user preference)
3. Use descriptive titles that indicate what completed
4. Include relevant metrics when available (file count, test results, timing)
5. Don't spam - be selective about when to notify
6. Always use `/usr/bin/osascript` with full path for reliability
