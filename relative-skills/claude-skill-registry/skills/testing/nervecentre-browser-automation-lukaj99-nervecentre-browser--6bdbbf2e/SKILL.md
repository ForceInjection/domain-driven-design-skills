---
name: nervecentre-browser-automation
description: Browser automation for NHS Nervecentre EPR systems using local MCP servers. Use when asked to scrape, extract, or interact with Nervecentre patient data, worklists, clinical notes, or any NHS EPR system that requires local network access. Supports browser-use MCP (primary), Playwright MCP (fallback), and Browser MCP extension. Handles OAuth 2.0 authentication, dynamic SPA content, and FHIR-compliant data extraction. IMPORTANT - Requires local network access (hospital WiFi) - cloud browser services will not work.
---

# Nervecentre Browser Automation

Automate NHS Nervecentre EPR interactions using local browser MCP servers with Claude Code.

## Quick Start

### 1. Run Installation Script

```bash
# From skill directory
./scripts/install.sh
```

This installs browser-use, Playwright, and configures Claude Code MCP servers.

### 2. Verify Setup

```bash
claude mcp list
```

Should show `browser-use` and/or `playwright` connected.

### 3. Start Automation

```
Navigate to Nervecentre test instance.
Log in with credentials from environment.
Extract patient list from Ward A.
```

---

## Tool Selection

| Scenario | Use This |
|----------|----------|
| Natural language tasks, exploration | `browser-use` |
| Deterministic extraction, regression | `playwright` |
| Use existing Chrome session | `browser-mcp` extension |

---

## Core Commands

### browser-use MCP

```
# Navigation
"Navigate to https://nervecentre-test.nhs.uk"

# Actions (natural language)
"Click the login button"
"Enter username testuser into the username field"
"Select Ward A from the ward dropdown"

# Extraction
"Extract all patient names and hospital numbers from the table"

# Screenshots
"Take a screenshot of the current page"
```

### Playwright MCP

```
# Navigation
playwright_navigate: { url: "https://nervecentre-test.nhs.uk" }

# Click (uses accessibility tree)
playwright_click: { element: "Login button" }

# Fill form
playwright_fill: { element: "Username field", value: "testuser" }

# Extract text
playwright_snapshot  # Returns accessibility tree
```

---

## Authentication

### Option A: Environment Variables (Recommended)

Set before starting Claude Code:

```bash
export NC_USERNAME="your-username"
export NC_PASSWORD="your-password"
export NC_URL="https://nervecentre-test.nhs.uk"
```

Then prompt:
```
Log into Nervecentre using credentials from NC_USERNAME and NC_PASSWORD environment variables.
```

### Option B: Session Persistence

1. Log in manually in headed mode
2. Save browser state
3. Reuse in subsequent sessions

```bash
# Start headed browser for manual login
claude mcp add-json "browser-use-headed" '{
  "command": "uvx",
  "args": ["browser-use", "--mcp", "--headed"],
  "env": {"ANTHROPIC_API_KEY": "..."}
}'
```

### Option C: Use Existing Chrome Session

Install Browser MCP extension, then Claude controls your already-authenticated browser.

---

## Common Workflows

### Extract Patient List

```
1. Navigate to Nervecentre patient worklist
2. Filter by ward if specified
3. Extract table data: hospital_number, name, ward, bed, admission_date
4. Output as JSON array
5. Handle pagination if multiple pages
```

### Access Clinical Notes

```
1. Search for patient by hospital number
2. Open patient record
3. Navigate to Clinical Notes section
4. Extract notes with: date, author, role, content
5. Preserve chronological order
```

### Security Assessment

```
1. Log in as test user
2. Attempt unauthorized access (e.g., different ward)
3. Document authorization response
4. Capture screenshot evidence
5. Report findings
```

---

## Output Formats

### JSON (Default)

```json
{
  "patients": [
    {
      "hospital_number": "12345678",
      "name": "Test Patient",
      "ward": "Ward A",
      "bed": "Bed 1"
    }
  ],
  "metadata": {
    "extracted_at": "2025-12-18T10:30:00Z",
    "total_count": 15
  }
}
```

### Markdown Table

```markdown
| Hospital # | Name | Ward | Bed |
|------------|------|------|-----|
| 12345678 | Test Patient | Ward A | Bed 1 |
```

---

## Troubleshooting

### "Cannot connect to Nervecentre"
- Verify on hospital WiFi/VPN
- Check NC_URL environment variable
- Try `curl $NC_URL` to test connectivity

### "Authentication failed"
- Verify credentials in environment
- Check OAuth flow completed
- Try headed mode for manual intervention

### "Element not found"
- Nervecentre uses dynamic loading; add waits
- Try natural language description instead of selector
- Use `playwright_snapshot` to see available elements

### "MCP server not connected"
- Run `claude mcp list` to check status
- Restart Claude Code
- Check logs: `~/.claude/logs/`

---

## Security Requirements

- ✅ Non-live/test instance ONLY
- ✅ NHS Information Governance approval
- ✅ Test patient data only (never real PII)
- ✅ Document all automated access
- ✅ Session cleanup after use
- ✅ DSPT compliance boundaries

---

## Reference Files

- [Installation Guide](references/installation.md) - Detailed setup for all platforms
- [MCP Configuration](references/mcp-config.md) - Full configuration options
- [Nervecentre Patterns](references/nervecentre-patterns.md) - Common selectors and workflows
