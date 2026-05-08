---
name: hubspot-search-deals
description: "Search deals in HubSpot CRM by name or amount. Load when user says 'search deals', 'find deal', 'lookup deal', 'deals over $X', 'search for [deal]'."
---

# Search HubSpot Deals

**Specialized skill** for searching deals in HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Search by Name
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_deals.py \
  --name "Enterprise" \
  --json
```

### Search by Minimum Amount
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_deals.py \
  --min-amount 10000 \
  --json
```

### Combined Search
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_deals.py \
  --name "Acme" \
  --min-amount 50000 \
  --limit 20 \
  --json
```

---

## Output Format

```json
{
  "total": 5,
  "results": [
    {
      "id": "5840795376",
      "properties": {
        "dealname": "Acme Corp - Enterprise",
        "amount": "50000",
        "dealstage": "qualifiedtobuy",
        "closedate": "2025-03-15T00:00:00Z"
      },
      "url": "https://app.hubspot.com/..."
    }
  ]
}
```

---

## Display Format

```
Found 5 deals matching "Enterprise" (min $10,000):

1. Acme Corp - Enterprise
   Amount: $50,000
   Stage: Qualified to Buy
   Close Date: 2025-03-15
   ID: 5840795376

2. Enterprise Package - Tech Inc
   Amount: $25,000
   Stage: Contract Sent
   ...
```

---

## Search Behavior

- Name search uses `CONTAINS_TOKEN` operator (partial match)
- Amount filter uses `GTE` (greater than or equal)
- Results sorted by creation date (newest first)

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.deals.read` scope |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-list-deals` - List all deals
- `hubspot-update-deal` - Update found deal
- `hubspot-create-deal` - Create if not found
