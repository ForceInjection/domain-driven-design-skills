---
name: hubspot-master
description: Shared resource library for HubSpot integration skills. DO NOT load directly - provides common references (setup, API docs, error handling, authentication) and scripts used by hubspot-connect and individual HubSpot skills.
---

# HubSpot Master

**This is NOT a user-facing skill.** It's a shared resource library referenced by HubSpot integration skills.

## Purpose

Provides shared resources to eliminate duplication across:
- `hubspot-connect` - Meta-skill for HubSpot CRM operations
- `hubspot-list-contacts` - List contacts
- `hubspot-create-contact` - Create contact
- `hubspot-update-contact` - Update contact
- `hubspot-search-contacts` - Search contacts
- `hubspot-list-companies` - List companies
- `hubspot-create-company` - Create company
- `hubspot-search-companies` - Search companies
- `hubspot-list-deals` - List deals
- `hubspot-create-deal` - Create deal
- `hubspot-update-deal` - Update deal
- `hubspot-search-deals` - Search deals
- `hubspot-get-associations` - Get CRM associations
- `hubspot-list-emails` - List email engagements
- `hubspot-log-email` - Log email engagement
- `hubspot-list-calls` - List call engagements
- `hubspot-log-call` - Log call engagement
- `hubspot-list-notes` - List notes
- `hubspot-create-note` - Create note
- `hubspot-list-meetings` - List meetings
- `hubspot-create-meeting` - Create meeting

**Instead of loading this skill**, users directly invoke the specific skill they need above.

---

## Architecture: DRY Principle

**Problem solved:** HubSpot skills would have duplicated content (setup instructions, API docs, auth flow, error handling).

**Solution:** Extract shared content into `hubspot-master/references/` and `hubspot-master/scripts/`, then reference from each skill.

**Result:** Single source of truth, reduced context per skill.

---

## Shared Resources

All HubSpot skills reference these resources (progressive disclosure).

### references/

**[setup-guide.md](references/setup-guide.md)** - Complete setup wizard
- Creating Private App in HubSpot
- Configuring required scopes
- Getting access token
- Environment configuration

**[api-reference.md](references/api-reference.md)** - HubSpot API patterns
- Base URL and authentication
- All CRM endpoints documented
- Request/response examples
- Common property names

**[error-handling.md](references/error-handling.md)** - Troubleshooting
- Common errors and solutions
- HTTP error codes
- Validation error handling
- Rate limiting

**[authentication.md](references/authentication.md)** - Token management
- Private App setup
- Token format and usage
- Security best practices

### scripts/

#### Authentication & Configuration

**[check_hubspot_config.py](scripts/check_hubspot_config.py)** - Pre-flight validation
```bash
python check_hubspot_config.py [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--json` | No | False | Output structured JSON for AI consumption |

Exit codes: 0=configured, 1=partial, 2=not configured

**When to Use:** Run this FIRST before any HubSpot operation. Use to validate access token is configured, diagnose authentication issues, or check if setup is needed.

---

**[setup_hubspot.py](scripts/setup_hubspot.py)** - Interactive setup wizard
```bash
python setup_hubspot.py
```
No arguments - runs interactively. Guides through Private App setup, tests connection, saves to `.env`.

**When to Use:** Use when HubSpot integration needs initial setup, when check_hubspot_config.py returns exit code 2, or when user needs to reconfigure credentials.

---

#### CRM Operations - Contacts

**[list_contacts.py](scripts/list_contacts.py)** - List contacts (GET /crm/v3/objects/contacts)
```bash
python list_contacts.py [--limit N] [--properties PROPS] [--after CURSOR] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--limit` | No | 10 | Number of results (max 100) |
| `--properties` | No | email,firstname,lastname | Comma-separated properties |
| `--after` | No | - | Pagination cursor |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user says "list contacts", "get contacts", "show contacts".

---

**[create_contact.py](scripts/create_contact.py)** - Create contact (POST /crm/v3/objects/contacts)
```bash
python create_contact.py --email EMAIL [--firstname NAME] [--lastname NAME] [--phone PHONE] [--company COMPANY] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--email` | **Yes** | - | Contact email address |
| `--firstname` | No | - | First name |
| `--lastname` | No | - | Last name |
| `--phone` | No | - | Phone number |
| `--company` | No | - | Company name |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user says "create contact", "add contact", "new contact".

---

**[update_contact.py](scripts/update_contact.py)** - Update contact (PATCH /crm/v3/objects/contacts/{id})
```bash
python update_contact.py --id CONTACT_ID [--email EMAIL] [--firstname NAME] [--lastname NAME] [--phone PHONE] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--id` | **Yes** | - | Contact ID to update |
| `--email` | No | - | New email |
| `--firstname` | No | - | New first name |
| `--lastname` | No | - | New last name |
| `--phone` | No | - | New phone |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user says "update contact", "edit contact", "modify contact".

---

**[search_contacts.py](scripts/search_contacts.py)** - Search contacts (POST /crm/v3/objects/contacts/search)
```bash
python search_contacts.py [--email EMAIL] [--name NAME] [--company COMPANY] [--limit N] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--email` | No | - | Search by email |
| `--name` | No | - | Search by name (first or last) |
| `--company` | No | - | Search by company |
| `--limit` | No | 10 | Max results |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user says "search contacts", "find contact", "lookup contact".

---

#### CRM Operations - Companies

**[list_companies.py](scripts/list_companies.py)** - List companies (GET /crm/v3/objects/companies)
```bash
python list_companies.py [--limit N] [--properties PROPS] [--after CURSOR] [--json]
```

**When to Use:** Use when user says "list companies", "get companies", "show companies".

---

**[create_company.py](scripts/create_company.py)** - Create company (POST /crm/v3/objects/companies)
```bash
python create_company.py --name NAME [--domain DOMAIN] [--industry INDUSTRY] [--json]
```

**When to Use:** Use when user says "create company", "add company", "new company".

---

**[search_companies.py](scripts/search_companies.py)** - Search companies (POST /crm/v3/objects/companies/search)
```bash
python search_companies.py [--name NAME] [--domain DOMAIN] [--industry INDUSTRY] [--limit N] [--json]
```

**When to Use:** Use when user says "search companies", "find company", "lookup company".

---

#### CRM Operations - Deals

**[list_deals.py](scripts/list_deals.py)** - List deals (GET /crm/v3/objects/deals)
```bash
python list_deals.py [--limit N] [--properties PROPS] [--after CURSOR] [--json]
```

**When to Use:** Use when user says "list deals", "get deals", "show deals", "show pipeline".

---

**[create_deal.py](scripts/create_deal.py)** - Create deal (POST /crm/v3/objects/deals)
```bash
python create_deal.py --name NAME [--amount AMOUNT] [--stage STAGE] [--pipeline PIPELINE] [--json]
```

**When to Use:** Use when user says "create deal", "add deal", "new deal", "new opportunity".

---

**[update_deal.py](scripts/update_deal.py)** - Update deal (PATCH /crm/v3/objects/deals/{id})
```bash
python update_deal.py --id DEAL_ID [--name NAME] [--amount AMOUNT] [--stage STAGE] [--json]
```

**When to Use:** Use when user says "update deal", "edit deal", "change deal stage".

---

**[search_deals.py](scripts/search_deals.py)** - Search deals (POST /crm/v3/objects/deals/search)
```bash
python search_deals.py [--name NAME] [--stage STAGE] [--min-amount N] [--max-amount N] [--limit N] [--json]
```

**When to Use:** Use when user says "search deals", "find deal", "lookup deal".

---

#### Associations

**[get_associations.py](scripts/get_associations.py)** - Get associations (GET /crm/v4/objects/{type}/{id}/associations/{toType})
```bash
python get_associations.py --object-type TYPE --object-id ID --to-type TO_TYPE [--json]
```

**When to Use:** Use when user says "get associations", "linked records", "related contacts".

---

#### Engagements

**[list_emails.py](scripts/list_emails.py)** - List email engagements
**[log_email.py](scripts/log_email.py)** - Log email engagement
**[list_calls.py](scripts/list_calls.py)** - List call engagements
**[log_call.py](scripts/log_call.py)** - Log call engagement
**[list_notes.py](scripts/list_notes.py)** - List notes
**[create_note.py](scripts/create_note.py)** - Create note
**[list_meetings.py](scripts/list_meetings.py)** - List meetings
**[create_meeting.py](scripts/create_meeting.py)** - Create meeting

---

## Intelligent Error Detection Flow

When a HubSpot skill fails due to missing configuration, the AI should:

### Step 1: Run Config Check with JSON Output

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

### Step 2: Parse the `ai_action` Field

| ai_action | What to Do |
|-----------|------------|
| `proceed_with_operation` | Config OK, continue with the original operation |
| `prompt_for_access_token` | Ask user: "I need your HubSpot access token. Create a Private App to get one." |
| `create_env_file` | Create `.env` file and ask user for credentials |
| `add_missing_scopes` | Guide user to add scopes in HubSpot Private App settings |
| `verify_token` | Token exists but connection failed - verify it's correct |

### Step 3: Help User Fix Issues

If `ai_action` is `prompt_for_access_token`:

1. Tell user: "HubSpot integration needs setup. I need your Private App access token."
2. Show them: "Create one in HubSpot: Settings → Integrations → Private Apps"
3. Ask: "Paste your HubSpot access token here (starts with 'pat-'):"
4. Once they provide it, **write directly to `.env`**:
   ```
   HUBSPOT_ACCESS_TOKEN=pat-na1-their-token-here
   ```
5. Re-run config check to verify

---

## Environment Variables

Required in `.env`:
```
HUBSPOT_ACCESS_TOKEN=pat-na1-xxxxxxxxxxxxx
```

---

## API Base URL

All API requests go to: `https://api.hubapi.com`

---

**Version**: 1.0
**Created**: 2025-12-13
**Status**: Production Ready
