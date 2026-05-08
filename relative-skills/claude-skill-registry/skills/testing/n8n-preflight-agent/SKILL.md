---
name: n8n-preflight-agent
description: Validates n8n workflow JSON files, tests APIs with real credentials, auto-fixes common issues, and learns new problems. Use when you need to CHECK, VALIDATE, FIX, TEST, PREFLIGHT, or REPAIR n8n workflow JSON files before importing them.
---

# n8n Preflight Agent

Intelligent validation agent that gets your n8n workflows 90% ready before you even open n8n. Upload any workflow JSON from YouTube tutorials, community templates, or exports - this agent validates, tests, and fixes it automatically.

## Capabilities

- Validates workflow JSON against 50+ known issues
- Tests APIs with real credentials (curl commands)
- Auto-fixes deprecated models, syntax errors, missing headers
- Detects platform-specific issues (Cloud vs Self-hosted)
- Learns new issues and remembers them for future validations
- Outputs clean, ready-to-import workflow

## How to Use

1. Type `/preflight` or say "validate this n8n workflow"
2. Provide the workflow JSON file
3. Answer platform question (Cloud or Self-hosted)
4. Provide API credentials when asked
5. Review the preflight report
6. Import `clean_workflow.json` into n8n

## Input Format

- **n8n workflow JSON**: Raw JSON export from n8n or copied from tutorials
- **Platform**: n8n Cloud or Docker/Self-hosted
- **API Credentials**: Keys for detected services (OpenAI, Supabase, HeyGen, etc.)

## Output Format

```
═══════════════════════════════════════════════════════════════
🛫 PREFLIGHT REPORT: [workflow-name].json
═══════════════════════════════════════════════════════════════

PLATFORM: n8n Cloud / Self-hosted

API TESTS:
✅ OpenAI    - Connected (gpt-4o available)
✅ Supabase  - Connected (table "scripts" found)
⚠️ Webhook   - Cannot test (needs deployment)

AUTO-FIXED (X):
✅ text-davinci-003 → gpt-4o (Node 4)
✅ Added Authorization header (Node 7)
✅ $('HTTP').item → $('HTTP').first() (Node 9)

MANUAL TASKS (X):
1. Set webhook path after deployment
2. Review hardcoded URL in Node 12

📁 SAVED: clean_workflow.json

Ready for SaaS? Type /build-saas
═══════════════════════════════════════════════════════════════
```

## What Gets Tested

### API Connectivity (Real Calls)

| Service | Test Endpoint | Success |
|---------|---------------|---------|
| OpenAI | `/v1/models` | 200 |
| Supabase | `/rest/v1/` | 200 |
| HeyGen | `/v2/avatars` | 200 |
| Anthropic | `/v1/messages` | 200 |
| ElevenLabs | `/v1/user` | 200 |

### Validation Checks

**Critical (Auto-Fix):**
- Deprecated AI models
- Missing Supabase headers
- Old expression syntax (`.item` → `.first()`)

**Warning (Flag for Review):**
- Hardcoded credentials
- Ghost/orphan nodes
- Missing webhook path
- AI Agent without memory

**Info:**
- Credentials needed list
- Platform-specific notes

## Confidence Levels

```
🟢 AUTO-FIX (Just do it):
   • Deprecated model names
   • Missing standard headers
   • Old expression syntax

🟡 SUGGEST (Show user, let them approve):
   • Removing nodes
   • Changing URLs
   • Modifying credentials structure

🔴 WARN ONLY (Just flag it):
   • Hardcoded credentials
   • Potential timeout issues
   • Complex nested loops
```

## Learning System

When a NEW issue is discovered (not in the knowledge base):

1. Agent describes the issue found
2. Suggests a fix
3. Asks: "Add this to my knowledge? [YES / NO / EDIT]"
4. If YES → Appends to `references/gotchas.md`

This builds YOUR personal n8n expert knowledge base over time.

## Example Usage

"Validate this n8n workflow"

"/preflight"

"Check this workflow for issues"

"Test if my APIs work in this workflow"

"Fix my broken n8n JSON"

## Best Practices

1. Always run preflight BEFORE importing to n8n
2. Provide real API keys for accurate testing
3. Choose correct platform (Cloud vs Self-hosted)
4. Review manual tasks before importing
5. Use `/build-saas` after preflight for frontend generation

## Limitations

- Cannot test webhooks (require deployment first)
- OAuth flows need manual re-authentication in n8n
- Some complex issues require manual intervention
- Credentials stay local (never sent anywhere)
