---
name: message
description: Send iMessages via macOS Messages app. Use when the user asks to send a text message or iMessage.
---

# Message Skill Guide

```bash
scripts/imessage.sh "<recipient>" "<message>"
```

Constraint: Use `AskUserQuestion` to confirm with the user before sending.

Note: Requires Accessibility permissions for Terminal.
