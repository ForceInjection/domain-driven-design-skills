---
name: hubspot-connect
description: "Connect to HubSpot CRM for contact, company, deal, and engagement management. Load when user mentions 'hubspot', 'crm', 'contacts', 'companies', 'deals', 'list contacts', 'create contact', 'search deals', or any HubSpot CRM operations. Meta-skill that validates config, discovers CRM objects, and routes to appropriate operations."
---

# HubSpot Connect

**User-facing meta-skill** for HubSpot CRM integration.

## Purpose

Single entry point for all HubSpot CRM operations:
- **Contacts** - List, create, update, search
- **Companies** - List, create, search
- **Deals** - List, create, update, search
- **Associations** - Get linked records
- **Engagements** - Emails, calls, notes, meetings

Follows the master/connect pattern - references `hubspot-master` for shared scripts and references.

---

## Trigger Phrases

Load this skill when user says:
- "hubspot" / "hubspot crm"
- "list contacts" / "show contacts"
- "create contact" / "add contact"
- "search contacts" / "find contact"
- "list companies" / "show companies"
- "create company" / "add company"
- "list deals" / "show deals" / "show pipeline"
- "create deal" / "new opportunity"
- "log email" / "log call" / "add note"
- Any CRM-related query

---

## Pre-Flight Check (ALWAYS RUN FIRST)

Before ANY HubSpot operation, validate configuration:

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

### Handle Config Status

| `ai_action` | What to Do |
|-------------|------------|
| `proceed_with_operation` | Config OK → Continue |
| `prompt_for_access_token` | Ask user for access token, save to .env |
| `create_env_file` | Create .env with token |
| `add_missing_scopes` | Guide user to add scopes in HubSpot |
| `verify_token` | Token exists but invalid |

### If Setup Needed

Display this complete setup guide to user:

```
I need to set up HubSpot integration first.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HUBSPOT PRIVATE APP SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 1: Create Private App
─────────────────────────
1. Log into HubSpot
2. Click gear icon (Settings) → Integrations → Private Apps
3. Click "Create a private app"
4. Name: "Nexus Integration"

STEP 2: Select Required Scopes
──────────────────────────────
In the "Scopes" tab, enable these permissions:

CRM (Required):
  ☑️ crm.objects.contacts.read
  ☑️ crm.objects.contacts.write
  ☑️ crm.objects.companies.read
  ☑️ crm.objects.companies.write
  ☑️ crm.objects.deals.read
  ☑️ crm.objects.deals.write

Engagements (Optional - for emails/calls/notes/meetings):
  ☑️ crm.objects.emails.read
  ☑️ crm.objects.emails.write
  ☑️ crm.objects.calls.read
  ☑️ crm.objects.calls.write
  ☑️ crm.objects.notes.read
  ☑️ crm.objects.notes.write
  ☑️ crm.objects.meetings.read
  ☑️ crm.objects.meetings.write

STEP 3: Get Your Token
──────────────────────
1. Click "Create app"
2. Copy the access token shown
3. Token starts with: pat-na1-... or pat-eu1-...

⚠️  IMPORTANT: Save this token securely - you won't see it again!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please paste your HubSpot access token:
```

After user provides token:
```bash
# Write to .env
HUBSPOT_ACCESS_TOKEN=pat-na1-xxx

# Re-run config check to verify
python 00-system/skills/hubspot/hubspot-master/scripts/check_hubspot_config.py --json
```

### Handling 403 Forbidden (Missing Scopes)

If user gets 403 errors after setup, they're missing scopes:

```
⚠️  Missing HubSpot permissions!

The operation failed because your Private App is missing required scopes.

To fix:
1. Go to HubSpot Settings → Integrations → Private Apps
2. Click on "Nexus Integration" (or your app name)
3. Go to "Scopes" tab
4. Add the missing scope: [scope name from error]
5. Click "Commit changes"
6. IMPORTANT: Copy the NEW access token (it changes after scope updates)
7. Update your .env with the new token

Then try again!
```

---

## Workflows

### Workflow 0: Config Check (Auto)
**Trigger**: Before any operation
**Script**: `check_hubspot_config.py --json`
**Output**: Config status, required actions

---

### Workflow 1: List Contacts
**Trigger**: "list contacts", "show contacts", "get contacts"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_contacts.py --json
```

**Display Format**:
```
Found 10 contacts:

1. John Doe
   Email: john@example.com
   ID: 12345
   Company: Acme Corp

2. Jane Smith
   Email: jane@example.com
   ID: 12346
   ...
```

---

### Workflow 2: Create Contact
**Trigger**: "create contact", "add contact", "new contact"

**Required**: Email
**Optional**: First name, last name, phone, company

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_contact.py \
  --email "user@example.com" \
  --firstname "John" \
  --lastname "Doe" \
  --json
```

---

### Workflow 3: Search Contacts
**Trigger**: "search contacts", "find contact", "lookup contact"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_contacts.py \
  --email "john@example.com" \
  --json
```

or

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_contacts.py \
  --name "John" \
  --json
```

---

### Workflow 4: Update Contact
**Trigger**: "update contact", "edit contact", "modify contact"

**Required**: Contact ID

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/update_contact.py \
  --id 12345 \
  --phone "+1234567890" \
  --json
```

---

### Workflow 5: List Companies
**Trigger**: "list companies", "show companies"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_companies.py --json
```

---

### Workflow 6: Create Company
**Trigger**: "create company", "add company", "new company"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_company.py \
  --name "Acme Corp" \
  --domain "acme.com" \
  --industry "Technology" \
  --json
```

---

### Workflow 7: Search Companies
**Trigger**: "search companies", "find company"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_companies.py \
  --name "Acme" \
  --json
```

---

### Workflow 8: List Deals
**Trigger**: "list deals", "show deals", "show pipeline"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_deals.py --json
```

---

### Workflow 9: Create Deal
**Trigger**: "create deal", "add deal", "new deal", "new opportunity"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_deal.py \
  --name "Enterprise Deal" \
  --amount 50000 \
  --stage "qualifiedtobuy" \
  --json
```

---

### Workflow 10: Update Deal
**Trigger**: "update deal", "edit deal", "change deal stage"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/update_deal.py \
  --id 12345 \
  --stage "closedwon" \
  --json
```

---

### Workflow 11: Search Deals
**Trigger**: "search deals", "find deal"

```bash
python 00-system/skills/hubspot/hubspot-master/scripts/search_deals.py \
  --name "Enterprise" \
  --min-amount 10000 \
  --json
```

---

### Workflow 12: Get Associations
**Trigger**: "get associations", "linked records", "related contacts", "contacts on deal"

```bash
# Get contacts associated with a deal
python 00-system/skills/hubspot/hubspot-master/scripts/get_associations.py \
  --object-type deals \
  --object-id 12345 \
  --to-type contacts \
  --json
```

---

### Workflow 13: Engagement Operations
**Trigger**: Various engagement operations

**List Emails:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_emails.py --json
```

**Log Email:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/log_email.py \
  --subject "Follow up" \
  --body "Meeting follow-up email" \
  --json
```

**List Calls:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_calls.py --json
```

**Log Call:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/log_call.py \
  --title "Sales Call" \
  --body "Discussed pricing" \
  --duration 30 \
  --json
```

**List Notes:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_notes.py --json
```

**Create Note:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_note.py \
  --body "Important note about this contact" \
  --json
```

**List Meetings:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/list_meetings.py --json
```

**Create Meeting:**
```bash
python 00-system/skills/hubspot/hubspot-master/scripts/create_meeting.py \
  --title "Product Demo" \
  --body "Demo of new features" \
  --start "2025-12-15T14:00:00Z" \
  --end "2025-12-15T15:00:00Z" \
  --json
```

---

## Smart Routing

When user mentions:

| Phrase | Route To |
|--------|----------|
| "list contacts", "show contacts" | Workflow 1 |
| "create contact", "add contact" | Workflow 2 |
| "search contacts", "find contact" | Workflow 3 |
| "update contact", "edit contact" | Workflow 4 |
| "list companies", "show companies" | Workflow 5 |
| "create company", "add company" | Workflow 6 |
| "search companies", "find company" | Workflow 7 |
| "list deals", "show pipeline" | Workflow 8 |
| "create deal", "new opportunity" | Workflow 9 |
| "update deal", "change stage" | Workflow 10 |
| "search deals", "find deal" | Workflow 11 |
| "associations", "linked records" | Workflow 12 |
| "emails", "calls", "notes", "meetings" | Workflow 13 |

---

## Error Handling

**Common Errors**:

| Error | Solution |
|-------|----------|
| 401 Unauthorized | Token invalid - check HUBSPOT_ACCESS_TOKEN |
| 403 Forbidden | Missing scope - add to Private App |
| 404 Not Found | Record doesn't exist |
| 409 Conflict | Duplicate record - search first |
| 429 Rate Limited | Wait and retry |

**On Error**:
1. Load: `hubspot-master/references/error-handling.md`
2. Display user-friendly message
3. Offer fix if possible

---

## Context Caching

After listing records, cache for session:
```python
# Store in conversation context
contacts_cache = [
    {"name": "John Doe", "id": "12345", "email": "john@example.com"},
    {"name": "Jane Smith", "id": "12346", "email": "jane@example.com"}
]
```

When user says "update John Doe", match to cached contact ID.

---

## Example Interactions

**User**: "list my hubspot contacts"

**AI**:
```
Let me check your HubSpot configuration first...
✅ Configuration valid

Found 10 contacts:

1. John Doe
   Email: john@example.com
   ID: 12345
   Company: Acme Corp

2. Jane Smith
   Email: jane@example.com
   ID: 12346
   Company: TechStart Inc

...

What would you like to do?
- "create contact" to add a new contact
- "search contacts by company" to filter
- "update John Doe" to modify a record
```

---

**User**: "create a new deal for Acme Corp worth $50,000"

**AI**:
```
Creating deal...

✅ Deal created!
  ID: 98765
  Name: Acme Corp - $50,000
  Amount: $50,000
  Stage: qualifiedtobuy

Would you like to associate this deal with a contact or company?
```

---

## Version

**Version**: 1.0
**Created**: 2025-12-13
**Status**: Production Ready
