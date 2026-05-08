---
name: hubspot-list-meetings
description: "List meeting engagements from HubSpot CRM. Load when user says 'list meetings', 'show meetings', 'meeting history', 'hubspot meetings'. Returns scheduled meeting records."
---

# List HubSpot Meetings

**Specialized skill** for listing meeting engagements from HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Basic List (default 10 meetings)
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_meetings.py --json
```

### With Limit
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_meetings.py --limit 25 --json
```

### With Pagination
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_meetings.py --after "cursor_value" --json
```

---

## Output Format

```json
{
  "results": [
    {
      "id": "14771947458",
      "properties": {
        "hs_meeting_title": "Product Demo",
        "hs_meeting_body": "Demo of new features for enterprise team",
        "hs_meeting_start_time": "2025-12-15T14:00:00Z",
        "hs_meeting_end_time": "2025-12-15T15:00:00Z",
        "hs_timestamp": "2025-12-15T14:00:00Z"
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
Found {count} meetings:

1. Product Demo
   Start: 2025-12-15 14:00
   End: 2025-12-15 15:00
   Duration: 1 hour
   Notes: Demo of new features for enterprise team
   ID: 14771947458

2. Discovery Call
   Start: 2025-12-16 10:00
   ...
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.meetings.read` scope |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-create-meeting` - Schedule new meeting
- `hubspot-get-associations` - Get meeting attendees
