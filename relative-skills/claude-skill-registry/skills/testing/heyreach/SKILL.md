---
name: heyreach
description: "HeyReach LinkedIn automation integration. Load when user mentions 'heyreach', 'linkedin outreach', 'linkedin campaigns', 'list campaigns', 'add leads', 'campaign stats', or any LinkedIn automation operations."
---

# HeyReach Integration

Complete integration for HeyReach LinkedIn automation platform.

## Trigger Phrases

Load this skill when user mentions:
- "heyreach" / "heyreach campaigns"
- "linkedin outreach" / "linkedin automation"
- "list campaigns" / "show campaigns"
- "campaign stats" / "campaign metrics"
- "add leads to campaign"
- "get campaign leads"
- "linkedin accounts"
- "create lead list"

---

## Pre-Flight Check (ALWAYS RUN FIRST)

Before ANY operation, validate configuration:

```bash
python 00-system/skills/heyreach/heyreach-master/scripts/check_heyreach_config.py --json
```

### Handle Config Status

| `ai_action` | What to Do |
|-------------|------------|
| `proceed_with_operation` | Config OK → Continue |
| `prompt_for_api_key` | Ask user for API key, save to .env |
| `create_env_file` | Create .env with API key |
| `verify_api_key` | Key exists but invalid |

### If Setup Needed

```
I need to set up HeyReach integration first.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HEYREACH API SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Log into HeyReach at https://app.heyreach.io
2. Go to Settings → API (or Integrations)
3. Copy your API key

Paste your HeyReach API key:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After user provides key, add to `.env`:
```
HEYREACH_API_KEY=their-key-here
```

---

## Scripts Reference

All scripts are in `00-system/skills/heyreach/heyreach-master/scripts/`

### Campaign Operations

**list_campaigns.py** - List all campaigns
```bash
python list_campaigns.py [--limit N] [--offset N] [--json]
```
Trigger: "list campaigns", "show campaigns", "my campaigns"

---

**get_campaign.py** - Get campaign details
```bash
python get_campaign.py --campaign-id ID [--json]
```
Trigger: "campaign details", "show campaign [name]"

---

**toggle_campaign.py** - Pause/resume campaign
```bash
python toggle_campaign.py --campaign-id ID --status ACTIVE|PAUSED [--json]
```
Trigger: "pause campaign", "resume campaign", "start/stop campaign"

---

### Lead Operations

**add_leads.py** - Add leads to campaign
```bash
python add_leads.py --campaign-id ID --linkedin-urls URL1,URL2 [--json]
python add_leads.py --campaign-id ID --leads '[{"linkedInUrl":"..."}]' [--json]
```
Trigger: "add leads", "add to campaign", "import leads"

---

**get_leads.py** - Get campaign leads
```bash
python get_leads.py --campaign-id ID [--limit N] [--json]
```
Trigger: "campaign leads", "show leads", "list leads"

---

### Conversation Operations

**get_conversations.py** - Get message threads
```bash
python get_conversations.py [--campaign-id ID] [--limit N] [--json]
```
Trigger: "conversations", "messages", "inbox", "replies"

---

### LinkedIn Account Operations

**list_accounts.py** - List connected accounts
```bash
python list_accounts.py [--json]
```
Trigger: "linkedin accounts", "connected accounts", "my accounts"

---

### List Operations

**list_lists.py** - List lead lists
```bash
python list_lists.py [--limit N] [--json]
```
Trigger: "lead lists", "show lists", "my lists"

---

**create_list.py** - Create lead list
```bash
python create_list.py --name NAME [--description DESC] [--json]
```
Trigger: "create list", "new list"

---

### Analytics Operations

**get_stats.py** - Get overall analytics
```bash
python get_stats.py [--json]
```
Trigger: "heyreach stats", "overall stats", "analytics"

---

**get_metrics.py** - Get campaign metrics
```bash
python get_metrics.py --campaign-id ID [--json]
```
Trigger: "campaign metrics", "campaign performance"

---

## Smart Routing Table

| User Says | Script | Required Args |
|-----------|--------|---------------|
| "list campaigns" | list_campaigns.py | - |
| "campaign details [X]" | get_campaign.py | --campaign-id |
| "pause/resume [campaign]" | toggle_campaign.py | --campaign-id --status |
| "add leads to [campaign]" | add_leads.py | --campaign-id --linkedin-urls |
| "leads in [campaign]" | get_leads.py | --campaign-id |
| "conversations" | get_conversations.py | - |
| "linkedin accounts" | list_accounts.py | - |
| "lead lists" | list_lists.py | - |
| "create list [name]" | create_list.py | --name |
| "analytics/stats" | get_stats.py | - |
| "metrics for [campaign]" | get_metrics.py | --campaign-id |

---

## Example Interactions

**User**: "show my heyreach campaigns"

```bash
python 00-system/skills/heyreach/heyreach-master/scripts/list_campaigns.py --json
```

**Display**:
```
Found 3 campaigns:

1. Q4 Enterprise Outreach
   Status: ACTIVE
   Leads: 350 | Contacted: 180 | Replied: 22
   ID: camp-abc123

2. Startup Founders
   Status: PAUSED
   Leads: 200 | Contacted: 95 | Replied: 12
   ID: camp-def456
```

---

**User**: "add linkedin.com/in/john-doe and linkedin.com/in/jane-smith to Q4 Enterprise"

```bash
python 00-system/skills/heyreach/heyreach-master/scripts/add_leads.py \
  --campaign-id camp-abc123 \
  --linkedin-urls "linkedin.com/in/john-doe,linkedin.com/in/jane-smith" \
  --json
```

**Display**:
```
✅ Leads added to campaign!
   Campaign ID: camp-abc123
   Added: 2
```

---

**User**: "what are my overall stats?"

```bash
python 00-system/skills/heyreach/heyreach-master/scripts/get_stats.py --json
```

**Display**:
```
📊 HeyReach Analytics Overview

Total Campaigns: 5
Active Campaigns: 3

Overall Performance:
  Total Leads: 1,200
  Contacted: 650
  Replied: 78

Rates:
  Connection Rate: 45.5%
  Reply Rate: 12.0%
```

---

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| 401 | Invalid API key | Re-run setup, get new key |
| 403 | API not available | Check subscription |
| 404 | Resource not found | Verify campaign/lead ID |
| 429 | Rate limited | Auto-retry (handled by client) |

---

## References

- **[setup-guide.md](heyreach-master/references/setup-guide.md)** - Complete setup
- **[api-reference.md](heyreach-master/references/api-reference.md)** - API docs
- **[error-handling.md](heyreach-master/references/error-handling.md)** - Troubleshooting

---

**Version**: 1.0
**Created**: 2025-12-19
