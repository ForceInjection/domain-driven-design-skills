---
name: playwright-browser
description: Browser automation with Playwright. Use for web testing, form filling, file uploads, screenshots. Daemon-based for persistent browser state.
---

# Playwright Browser Skill

Automate browsers via CLI with a daemon that maintains browser state between commands.

## Quick Start (Daemon Required)

```bash
# 1. Start the daemon (visible browser for user interaction)
npx playwright-skill-daemon --headless false

# 2. In another terminal, run commands
npx playwright-skill navigate "https://example.com"
npx playwright-skill snapshot
npx playwright-skill click e2
```

**Important**: The daemon must be running before using CLI commands. If not running, you'll see a clear error message with instructions.

## Core Workflow

### Step 1: Start Daemon
```bash
# Visible browser (recommended for testing with user interaction)
npx playwright-skill-daemon --headless false

# Headless (for automated testing)
npx playwright-skill-daemon --headless true
```

### Step 2: Navigate and Snapshot
```bash
npx playwright-skill navigate "https://example.com/login"
npx playwright-skill snapshot
# Response includes element refs: e1, e2, e5, etc.
```

### Step 3: Interact Using Refs
```bash
npx playwright-skill fill e5 "user@example.com"
npx playwright-skill fill e8 "password"
npx playwright-skill click e12
```

## Commands by Category

### Navigation
```bash
npx playwright-skill navigate <url>      # Go to URL
npx playwright-skill back                # Browser back
npx playwright-skill forward             # Browser forward
npx playwright-skill reload              # Reload page
```

### Interaction (by ref from snapshot)
```bash
npx playwright-skill click <ref>         # Click element
npx playwright-skill fill <ref> <value>  # Fill input
npx playwright-skill type <ref> <text>   # Type text
npx playwright-skill select <ref> <val>  # Select dropdown option
npx playwright-skill press <key>         # Press keyboard key
npx playwright-skill hover <ref>         # Hover over element
```

### Interaction (by CSS selector)
Use when refs aren't available (e.g., modal elements not in snapshot):
```bash
npx playwright-skill click-selector "button[type=submit]"
npx playwright-skill fill-selector "input[name=email]" "user@example.com"
npx playwright-skill upload-selector "input[type=file]" "/path/to/file.csv"
```

### Inspection
```bash
npx playwright-skill snapshot            # Get accessibility tree with refs
npx playwright-skill screenshot          # Take screenshot
npx playwright-skill query <selector>    # Query DOM (read-only)
```

### Query Command (Read-Only DOM Inspection)
Use `query` when snapshot doesn't capture elements (e.g., modals rendered as portals):
```bash
# Find elements matching selector
npx playwright-skill query "button[type=submit]"
# Returns: { count: 2, elements: [{ text: "Submit", visible: true }] }

# Check if element exists
npx playwright-skill query ".modal" --exists
# Returns: { exists: true, count: 1 }

# Get specific attribute
npx playwright-skill query "input[name=csrf]" --attr value
# Returns: { value: "abc123" }
```

### File Upload (Hidden Inputs)
Filament and other frameworks use hidden file inputs. Use `upload-selector`:
```bash
# Open modal with file upload
npx playwright-skill click e198

# Upload to hidden file input
npx playwright-skill upload-selector "input[type=file]" "/path/to/file.csv"

# Click submit using selector (modal buttons may not have refs)
npx playwright-skill click-selector "button[type=submit]:visible"
```

### Auth State
```bash
npx playwright-skill auth-save <name>    # Save cookies/state
npx playwright-skill auth-load <name>    # Restore saved state
npx playwright-skill auth-status         # Show current auth
npx playwright-skill auth-clear          # Clear auth state
```

## Response Format

All commands return JSON:
```json
{
  "id": "req-2025-12-22-1",
  "command": "navigate",
  "success": true,
  "action": "Navigated to https://example.com",
  "pageState": {
    "url": "https://example.com",
    "title": "Example",
    "authStatus": "authenticated",
    "hasErrors": false
  },
  "cacheRef": {
    "id": "cache-abc123",
    "available": ["snapshot", "console", "network", "html"]
  }
}
```

## Common Patterns

### Login Flow
```bash
npx playwright-skill navigate "https://app.example.com/login"
npx playwright-skill snapshot
npx playwright-skill fill e29 "user@example.com"
npx playwright-skill fill e41 "password"
npx playwright-skill click e61
```

### Form with File Upload (Filament/Livewire)
```bash
# Navigate and open modal
npx playwright-skill navigate "https://app.example.com/customers"
npx playwright-skill click e198  # "Import" button

# Upload file to hidden input
npx playwright-skill upload-selector "input[type=file]" "/path/to/data.csv"

# Query to verify submit button exists
npx playwright-skill query "button[type=submit]"

# Click submit using Playwright's native method
npx playwright-skill click-selector "button[type=submit]:visible"
```

### When Refs Don't Work (Modals/Overlays)
Modal elements render as portals and may not appear in snapshot. Use selectors:
```bash
# 1. Query to find elements (read-only)
npx playwright-skill query ".fi-modal button"

# 2. Click using selector
npx playwright-skill click-selector "button:has-text('Submit')"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Daemon not running" | Start with `npx playwright-skill-daemon --headless false` |
| Element ref not found | Take fresh snapshot, page may have changed |
| Modal buttons not in snapshot | Use `query` + `click-selector` instead |
| File upload not working | Use `upload-selector` for hidden inputs |
| Livewire action not firing | Use `click-selector` (native Playwright click) |

## Worktree Detection (Multi-Worktree Projects)

This skill supports projects with multiple git worktrees. It auto-detects which worktree you're in and uses the appropriate configuration.

### Initial Setup

On first use, if configuration files don't exist, the agent will prompt you to create them:

1. **`./skill/worktrees.json`** - Maps worktree directories to base URLs and credentials
2. **`./skill/.secrets.json`** - Stores passwords (gitignored, never committed)

Both files are gitignored and project-specific. Example templates are provided:

```bash
# Copy example files and customize
cp ./skill/worktrees.example.json ./skill/worktrees.json
cp ./skill/secrets.example.json ./skill/.secrets.json

# Edit with your project's URLs and credentials
```

See [worktrees.example.json](./skill/worktrees.example.json) and [secrets.example.json](./skill/secrets.example.json) for templates.

### How It Works

1. **Detection**: The skill reads your current working directory to determine which worktree you're in
2. **Configuration**: Each worktree maps to a `baseUrl`, credentials, and tenant settings in `./skill/worktrees.json`
3. **Usage**: When you run commands, use the worktree-specific base URL

### Example Worktree Configuration

```json
{
  "worktrees": {
    "my-app": {
      "baseUrl": "https://my-app.test",
      "branch": "develop",
      "description": "Main development",
      "auth": {
        "defaultUser": "admin@example.com",
        "roles": {
          "admin": "admin@example.com",
          "user": "user@example.com"
        }
      }
    },
    "my-app-staging": {
      "baseUrl": "https://staging.my-app.test",
      "branch": "main",
      "description": "Staging environment"
    }
  }
}
```

### Detecting Current Worktree

Before running tests, verify which worktree you're in:

```bash
# Check current directory
pwd
# e.g., /path/to/project/my-app

# The last directory component (my-app) determines the worktree
```

### Using Worktree-Specific URLs

Always use the correct base URL for your worktree:

```bash
# If in my-app worktree:
npx playwright-skill navigate "https://my-app.test/dashboard"

# If in my-app-staging worktree:
npx playwright-skill navigate "https://staging.my-app.test/dashboard"
```

### Credentials Configuration

Usernames are stored in `./skill/worktrees.json`. Passwords are stored separately in `./skill/.secrets.json` (gitignored):

```json
{
  "passwords": {
    "admin@example.com": "yourPassword",
    "user@example.com": "password"
  }
}
```

### Getting Credentials Programmatically

To get the correct credentials for the current worktree:

```bash
# 1. Detect worktree from current directory
WORKTREE=$(basename $(pwd))

# 2. Read base URL and credentials from config
cat ./skill/worktrees.json | jq ".worktrees[\"$WORKTREE\"]"

# 3. For passwords (if secrets file exists)
cat ./skill/.secrets.json | jq '.passwords'
```

### Multi-Tenant Panel URLs

For multi-tenant apps, panel URLs can include a tenant slug:

```json
{
  "tenant": {
    "slug": "acme-corp",
    "panels": {
      "admin": "/admin",
      "office": "/office/acme-corp",
      "user": "/app/acme-corp"
    }
  }
}
```

```bash
# Admin panel (no tenant in URL)
npx playwright-skill navigate "https://my-app.test/admin"

# Office panel (tenant in URL)
npx playwright-skill navigate "https://my-app.test/office/acme-corp"
```

---

## Architecture

```
┌─────────────────────────────────────────┐
│           CLI Commands                   │
│  npx playwright-skill <command>          │
└─────────────────────────────────────────┘
                    │
          Unix Socket (/tmp/playwright-skill.sock)
                    │
                    ▼
┌─────────────────────────────────────────┐
│              Daemon                      │
│  - Owns browser instance                 │
│  - Maintains page state                  │
│  - 30 min idle timeout                   │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│           Chromium Browser               │
│  - Visible when --headless false         │
│  - User can interact directly            │
└─────────────────────────────────────────┘
```

**Reference Documentation:**
- [REFERENCE.md](./skill/REFERENCE.md) - Full command reference
- [AUTH.md](./skill/AUTH.md) - Authentication patterns
- [CONFIG.md](./skill/CONFIG.md) - Project configuration
- [worktrees.example.json](./skill/worktrees.example.json) - Worktree configuration template
- [secrets.example.json](./skill/secrets.example.json) - Credentials template
