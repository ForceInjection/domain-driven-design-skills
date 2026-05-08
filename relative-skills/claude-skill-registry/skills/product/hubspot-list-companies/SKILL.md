---
name: hubspot-list-companies
description: "List companies from HubSpot CRM. Load when user says 'list companies', 'show companies', 'get companies', 'hubspot companies'. Returns paginated company list."
---

# List HubSpot Companies

**Specialized skill** for listing companies from HubSpot CRM.

## Pre-Flight Check

Before running, execute config check:
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

If `ai_action` is not `proceed_with_operation`, follow hubspot-connect setup guide.

---

## Usage

### Basic List (default 10 companies)
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_companies.py --json
```

### With Limit
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_companies.py --limit 25 --json
```

### With Pagination
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_companies.py --after "cursor_value" --json
```

---

## Output Format

```json
{
  "results": [
    {
      "id": "6493611979",
      "properties": {
        "name": "Acme Corp",
        "domain": "acme.com",
        "industry": "Technology",
        "city": "San Francisco",
        "numberofemployees": "500",
        "phone": "+1234567890"
      },
      "url": "https://app.hubspot.com/contacts/.../record/0-2/6493611979"
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
Found {count} companies:

1. Acme Corp
   Domain: acme.com
   Industry: Technology
   City: San Francisco
   Employees: 500
   ID: 6493611979

2. Tech Inc
   Domain: techinc.io
   ...
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| 401 | Invalid token - re-run setup |
| 403 | Missing `crm.objects.companies.read` scope |
| 429 | Rate limited - wait and retry |

---

## Related Skills

- `hubspot-create-company` - Create new company
- `hubspot-search-companies` - Search by name/domain
- `hubspot-get-associations` - Get contacts at company
