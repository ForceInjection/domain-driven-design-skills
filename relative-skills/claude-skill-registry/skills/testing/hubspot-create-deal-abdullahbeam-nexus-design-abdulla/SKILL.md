---
name: hubspot-create-deal
description: "Create a new deal in HubSpot CRM. Load when user says 'create deal', 'add deal', 'new deal', 'new opportunity'. Requires name, optional amount, stage, closedate."
---

# Create HubSpot Deal

**Specialized skill** for creating deals in HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Required Parameters
- `--name` - Deal name (required)

### Optional Parameters
- `--amount` - Deal value in dollars
- `--stage` - Deal stage ID
- `--closedate` - Expected close date (YYYY-MM-DD)
- `--pipeline` - Pipeline ID (uses default if not specified)

### Examples

**Minimal (name only):**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_deal.py \
  --name "New Enterprise Deal" \
  --json
```

**Full deal:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_deal.py \
  --name "Acme Corp - Enterprise" \
  --amount 50000 \
  --stage "qualifiedtobuy" \
  --closedate "2025-03-15" \
  --json
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

## Output Format

```json
{
  "id": "5840795376",
  "properties": {
    "dealname": "Acme Corp - Enterprise",
    "amount": "50000",
    "dealstage": "qualifiedtobuy",
    "closedate": "2025-03-15T00:00:00Z",
    "createdate": "2025-12-13T10:00:00Z"
  }
}
```

---

## Display Format

```
✅ Deal created!
  ID: 5840795376
  Name: Acme Corp - Enterprise
  Amount: $50,000
  Stage: Qualified to Buy
  Close Date: 2025-03-15
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.deals.write` scope |
| 400 | Invalid stage ID - check stage list |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-list-deals` - List all deals
- `hubspot-update-deal` - Update deal stage/amount
- `hubspot-search-deals` - Find existing deals
- `hubspot-get-associations` - Link contacts to deal
