---
name: hubspot-list-notes
description: "List note engagements from HubSpot CRM. Load when user says 'list notes', 'show notes', 'note history', 'hubspot notes'. Returns logged note records."
---

# List HubSpot Notes

**Specialized skill** for listing note engagements from HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Basic List (default 10 notes)
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_notes.py --json
```

### With Limit
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_notes.py --limit 25 --json
```

### With Pagination
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_notes.py --after "cursor_value" --json
```

---

## Output Format

```json
{
  "results": [
    {
      "id": "16977760701",
      "properties": {
        "hs_note_body": "<p>Important note about this contact...</p>",
        "hs_timestamp": "2025-12-13T10:00:00Z"
      }
    }
  ],
  "paging": {
    "next": {
      "after": "cursor_for_next_page"
    }
  }
}
```

---

## Display Format

```
Found {count} notes:

1. Note ID: 16977760701
   Date: 2025-12-13 10:00
   Content: Important note about this contact...

2. Note ID: 16977942725
   Date: 2025-12-12 15:30
   Content: Meeting follow-up...
```

---

## Note Content

- Notes can contain HTML formatting
- Strip HTML tags for plain text display
- Notes may include links, lists, and formatted text

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.notes.read` scope |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-create-note` - Create new note
- `hubspot-get-associations` - Get note's linked contacts
