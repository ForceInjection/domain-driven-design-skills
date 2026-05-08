---
name: notification
description: Send push notifications to user's phone via Pushover. Use when the user asks to be notified, alerted, or reminded about something.
---

# Notification Skill Guide

```bash
scripts/notify.sh "<title>" "<message>"
scripts/notify.sh "<title>" "<message>" --priority 1
scripts/notify.sh "<title>" "<message>" --url "https://example.com"
```

## Priority Levels

| Level | Description |
|-------|-------------|
| -2 | Lowest (no notification) |
| -1 | Low (quiet) |
| 0 | Normal (default) |
| 1 | High (bypass quiet hours) |
| 2 | Emergency (requires --retry and --expire) |

## Emergency Priority Example

```bash
scripts/notify.sh "Critical" "Server down!" --priority 2 --retry 60 --expire 1800
```

Note: Requires Pushover credentials in macOS Keychain. Run `setup-service.sh` to configure.
