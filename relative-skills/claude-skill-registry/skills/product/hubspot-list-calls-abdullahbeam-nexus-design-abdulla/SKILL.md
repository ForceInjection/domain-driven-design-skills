---
name: hubspot-list-calls
description: "List call engagements from HubSpot CRM. Load when user says 'list calls', 'show calls', 'call history', 'hubspot calls'. Returns logged call records."
---

# List HubSpot Calls

**Specialized skill** for listing call engagements from HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Basic List (default 10 calls)
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_calls.py --json
```

### With Limit
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_calls.py --limit 25 --json
```

### With Pagination
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_calls.py --after "cursor_value" --json
```

---

## Output Format

```json
{
  "results": [
    {
      "id": "14772074448",
      "properties": {
        "hs_call_title": "Discovery Call",
        "hs_call_body": "Discussed requirements and timeline...",
        "hs_call_direction": "OUTBOUND",
        "hs_call_duration": "1800000",
        "hs_call_status": "COMPLETED",
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
Found {count} calls:

1. Discovery Call
   Direction: Outbound
   Duration: 30 minutes
   Status: Completed
   Date: 2025-12-13 10:00
   Notes: Discussed requirements and timeline...
   ID: 14772074448

2. Follow-up Call
   Direction: Inbound
   ...
```

---

## Call Direction Values

| Value | Meaning |
|-------|---------|
| OUTBOUND | Made call |
| INBOUND | Received call |

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.calls.read` scope |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-log-call` - Log new call
- `hubspot-get-associations` - Get call's linked contacts
