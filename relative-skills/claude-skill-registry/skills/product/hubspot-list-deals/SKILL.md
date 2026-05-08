---
name: hubspot-list-deals
description: "List deals from HubSpot CRM. Load when user says 'list deals', 'show deals', 'show pipeline', 'get deals', 'hubspot deals'. Returns paginated deal list."
---

# List HubSpot Deals

**Specialized skill** for listing deals from HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Basic List (default 10 deals)
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_deals.py --json
```

### With Limit
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_deals.py --limit 25 --json
```

### With Pagination
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_deals.py --after "cursor_value" --json
```

---

## Output Format

```json
{
  "results": [
    {
      "id": "5840795376",
      "properties": {
        "dealname": "Enterprise Deal",
        "amount": "50000",
        "dealstage": "qualifiedtobuy",
        "pipeline": "default",
        "closedate": "2025-03-15T00:00:00Z"
      },
      "url": "https://app.hubspot.com/contacts/.../record/0-3/5840795376"
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
Found {count} deals:

1. Enterprise Deal
   Amount: $50,000
   Stage: Qualified to Buy
   Close Date: 2025-03-15
   ID: 5840795376

2. Startup Package
   Amount: $5,000
   Stage: Proposal Sent
   ...
```

---

## Common Deal Stages

| Stage ID | Name |
|----------|------|
| appointmentscheduled | Appointment Scheduled |
| qualifiedtobuy | Qualified to Buy |
| presentationscheduled | Presentation Scheduled |
| decisionmakerboughtin | Decision Maker Bought In |
| contractsent | Contract Sent |
| closedwon | Closed Won |
| closedlost | Closed Lost |

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.deals.read` scope |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-create-deal` - Create new deal
- `hubspot-search-deals` - Search by name/amount
- `hubspot-update-deal` - Update deal stage
- `hubspot-get-associations` - Get deal contacts
