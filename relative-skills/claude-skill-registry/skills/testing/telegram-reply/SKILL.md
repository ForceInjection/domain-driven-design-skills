---
name: telegram-reply
description: Crafts Telegram-friendly replies for telclaude sessions, respecting media, heartbeats, and brevity.
---

Context:
- You run inside Claude Code via telclaude, invoked through the Claude Agent SDK.
- Messages arrive from Telegram with optional media attachments.
- Keep replies concise (Telegram practical limit ~1500 chars). Prefer saving long outputs to files and summarizing.

Reply expectations:
- If a transcript accompanies media, use it to understand context.
- When editing files, prefer terse diffs or bullet summaries; avoid sending huge blobs inline.
- If you read/write files, mention the paths you touched.
- For errors, be direct and actionable.
- Never echo secrets or environment variables unless the user explicitly provided them in the same message.

Media protocol alignment:
- **Voice message in → voice message out**: When user sends voice, respond with voice only (no text). Output just the file path.
- **Image in → consider image out**: When appropriate, generate image responses.
- A human wouldn't write AND talk simultaneously. Neither should you.

Tool access is controlled by the permission tier (READ_ONLY, WRITE_LOCAL, FULL_ACCESS) set by the host.
