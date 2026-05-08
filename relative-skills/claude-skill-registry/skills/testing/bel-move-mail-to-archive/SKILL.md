---
name: bel-move-mail-to-Archive
description: This skill should be used when moving a single email message to the Archive folder in Microsoft 365 Mail. It provides a clean interface to move one specific email using its messageId without polluting the context window. Use this skill when processing bulk archive operations, moving spam emails, or any workflow requiring reliable one-email-at-a-time moves to Archive.
---

# Move Email to Archive Skill

## Purpose

Move one specific email message to the Archive folder in Microsoft 365 Mail with a clean, context-efficient interface.

## When to Use

- Moving individual emails to Archive (spam, no-TODO items, notifications)
- Bulk archive operations (chain multiple calls efficiently)
- Any workflow requiring reliable, one-at-a-time email archival
- When the main context should not be polluted by full email move operation details

## How to Use This Skill

### Quick Start: Direct API Call

For a single email move, use the MS365 mail API directly with these parameters:

**Function:** `mcp__ms365__move-mail-message`

**Required Parameters:**
- `messageId`: The unique message ID of the email to move (string)
- `body`: JSON object with destination folder ID

**Optional Parameter:**
- Archive Folder ID: Use default from `references/archive_config.md` unless overriding

### Example Call Structure

```python
# Minimum parameters needed
messageId = "AAMkADA4YjhhZDYwLWZiMWYtNDVkMy1hNjE3LWI3YzRlMzAwNGE0MgBGAAA..."
archive_folder_id = "AQMkADA4YjhhZDYwLWZiMWYtNDVkMy1hNjE3LWI3YzRlMzAwADRhNDIALgAAA-cCSmDe9C5Ai1IxFty3vKgBACIai-AjXXpFuMeLL-NexTAAAAIBVAAAAA=="

response = move_mail_message(
    messageId=messageId,
    body={"DestinationId": archive_folder_id}
)
```

### Key Success Pattern: One Email at a Time

**Critical Finding:** Moving emails individually (one per call) works reliably. Batch operations cause `ErrorInvalidIdMalformed` errors. Always move ONE email per operation call.

### Python Script Approach (Recommended for Automation)

Use `scripts/move_to_archive.py` for encapsulated, repeatable moves. This script:
- Handles default Archive folder ID lookup
- Accepts simple messageId parameter
- Returns clean success/failure status
- Can be chained in loops without context pollution

**Usage:**
```bash
python scripts/move_to_archive.py --message-id "AAMkADA4YjhhZDYwLWZiMWYtNDVkMy1h..." [--archive-id "custom-id"]
```

## Reference Materials

- **API Documentation:** See `references/api_docs.md` for full MS365 Mail API parameter details
- **Archive Configuration:** See `references/archive_config.md` for Archive folder ID and defaults
- **Archive Folder ID Default:** `AQMkADA4YjhhZDYwLWZiMWYtNDVkMy1hNjE3LWI3YzRlMzAwADRhNDIALgAAA-cCSmDe9C5Ai1IxFty3vKgBACIai-AjXXpFuMeLL-NexTAAAAIBVAAAAA==`

## Expected Response

Success response includes:
- `id`: Email ID (confirming which email was moved)
- `parentFolderId`: Archive folder ID (confirming destination)
- `subject`: Email subject (for reference)
- `receivedDateTime`: When email was received

**Indicates Success:** `parentFolderId` equals the Archive folder ID

## Important Notes

1. **One at a time:** Always move ONE email per operation call
2. **Message ID format:** Use the full message ID from the email list response
3. **No batch operations:** Do not attempt to move multiple emails in a single call
4. **Context efficiency:** This skill is designed to keep operations lean and not blow up context window

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `ErrorInvalidIdMalformed` | Invalid or malformed message ID | Verify message ID from current email list response |
| `ErrorItemNotFound` | Email no longer exists | Refresh email list; may have been deleted |
| `ErrorAccessDenied` | Permission issue | Verify authenticated user has Archive folder access |
| Wrong parentFolderId | Incorrect Archive folder ID | Verify folder ID from `references/archive_config.md` |

## Integration with Agents

To create a sub-agent for bulk archive operations, pass this skill's reference plus a list of messageIds. The sub-agent can:
1. Iterate through messageIds
2. Call move_to_archive.py for each email
3. Collect success/failure results
4. Return summary to main context

This keeps archive operations completely encapsulated away from the main conversation context.
