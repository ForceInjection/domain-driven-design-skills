---
name: google-master
description: Shared resource library for Google integration skills. DO NOT load directly - provides common references (setup, API docs, error handling, authentication) and scripts used by gmail, google-docs, google-sheets, google-calendar, and future Google skills.
---

# Google Master

**This is NOT a user-facing skill.** It's a shared resource library referenced by all Google integration skills.

## Purpose

Provides shared resources to eliminate duplication across:
- `gmail` - Email operations (read, send, reply, forward)
- `google-docs` - Document operations (read, write, create, export)
- `google-sheets` - Spreadsheet operations (read, write, append)
- `google-calendar` - Calendar operations (events, availability, scheduling)

**Instead of loading this skill**, users directly invoke the specific skill they need above.

---

## Architecture: DRY Principle

**Problem solved:** Google skills would have duplicated content (OAuth setup, credentials management, error handling, API patterns).

**Solution:** Extract shared content into `google-master/references/` and `google-master/scripts/`, then reference from each skill.

**Result:**
- Single OAuth flow for all Google services
- One credentials source (`.env` file with GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_PROJECT_ID)
- One unified token with all scopes
- Consistent error handling across skills

---

## Shared Resources

All Google skills reference these resources (progressive disclosure).

### scripts/

#### Authentication & Configuration

**[google_auth.py](scripts/google_auth.py)** - Unified OAuth for all Google services
```bash
python google_auth.py --check [--service SERVICE] [--json]
python google_auth.py --login [--service SERVICE]
python google_auth.py --logout
python google_auth.py --status
```

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--check` | No | - | Check if authenticated and ready |
| `--login` | No | - | Initiate OAuth login flow |
| `--logout` | No | - | Remove stored token |
| `--status` | No | - | Show detailed auth status |
| `--service` | No | all | Specific service: gmail, docs, sheets, calendar, or all |
| `--json` | No | False | Output as JSON |

**Exit codes:**
- 0 = configured and ready
- 1 = needs login (credentials exist but not authenticated)
- 2 = not configured (missing credentials or dependencies)

**When to Use:** Run this FIRST before any Google operation. Called automatically by individual skills.

---

**[check_google_config.py](scripts/check_google_config.py)** - Pre-flight validation
```bash
python check_google_config.py [--json]
```

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--json` | No | False | Output structured JSON for AI consumption |

**When to Use:** Quick check if Google integration is configured. Use for diagnostics.

---

### references/

**[setup-guide.md](references/setup-guide.md)** - Complete setup wizard
- Creating Google Cloud project
- Enabling APIs (Gmail, Docs, Sheets, Calendar)
- Creating OAuth 2.0 credentials
- Adding credentials to `.env` file
- First-time authentication flow

**[error-handling.md](references/error-handling.md)** - Troubleshooting
- Common errors and solutions
- HTTP error codes (401, 403, 404)
- Scope/permission issues
- Rate limiting
- Token refresh failures

**[api-patterns.md](references/api-patterns.md)** - Common patterns
- Authentication headers
- Pagination
- Batch requests
- Error responses

---

## Service Scopes

The unified token requests all scopes on first login:

| Service | Scopes |
|---------|--------|
| Gmail | gmail.readonly, gmail.send, gmail.compose, gmail.modify, gmail.labels |
| Docs | documents, drive |
| Sheets | spreadsheets, drive.readonly |
| Calendar | calendar, calendar.events |

**Note:** User grants all permissions once, then all Google skills work.

---

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| OAuth credentials | `.env` (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_PROJECT_ID) | App identity from Google Cloud |
| Access token | `01-memory/integrations/google-token.json` | User's authenticated token |

---

## How Skills Reference This

Each skill imports the shared auth module:

```python
# In any Google skill's operations script
import sys
from pathlib import Path

# Add google-master to path
NEXUS_ROOT = Path(__file__).resolve().parents[4]  # Adjust based on skill location
sys.path.insert(0, str(NEXUS_ROOT / "00-system/skills/google/google-master/scripts"))

from google_auth import get_credentials, get_service

# Get authenticated service
gmail = get_service('gmail', 'v1')
docs = get_service('docs', 'v1')
sheets = get_service('sheets', 'v4')
calendar = get_service('calendar', 'v3')
```

---

## Intelligent Error Detection Flow

When a Google skill fails due to missing configuration, the AI should:

### Step 1: Run Config Check with JSON Output

```bash
python 00-system/skills/google/google-master/scripts/check_google_config.py --json
```

### Step 2: Parse the `ai_action` Field

| ai_action | What to Do |
|-----------|------------|
| `proceed` | Config OK, continue with operation |
| `install_dependencies` | Run: `pip install google-auth google-auth-oauthlib google-api-python-client` |
| `need_credentials` | Guide user to create OAuth credentials in Google Cloud Console |
| `need_login` | Run: `python google_auth.py --login` |

### Step 3: Help User Fix Issues

If credentials missing:
1. Direct user to: https://console.cloud.google.com/
2. Guide through: APIs & Services > Credentials > Create OAuth Client ID (Desktop app)
3. Copy Client ID and Client Secret, add to `.env`:
   ```
   GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=your-client-secret
   GOOGLE_PROJECT_ID=your-project-id
   ```
4. Run `--login` to authenticate

---

## Usage Example

**User says:** "send an email to john@example.com"

**What happens:**
1. AI loads `gmail` skill (NOT google-master)
2. `gmail` SKILL.md says: "Run pre-flight check first"
3. AI executes: `python google-master/scripts/google_auth.py --check --service gmail`
4. If exit code 0: proceed with gmail_operations.py
5. If exit code 1: run `--login` automatically
6. If exit code 2: load error-handling.md, guide user through setup

**google-master is NEVER loaded directly** - it's just a resource library.

---

## Adding New Google Services

To add a new Google service (e.g., Google Drive, Google Tasks):

1. Add scopes to `SCOPES` dict in `google_auth.py`
2. Create new skill folder with operations script
3. Import `get_service()` from google-master
4. Document in this SKILL.md

---

**Version**: 1.0
**Created**: 2025-12-17
**Updated**: 2025-12-17
**Status**: Production Ready
