---
name: browser-auth
description: Browser automation with 1Password credential integration for authenticated workflows
---

# Browser Auth Skill

Integrates Claude in Chrome browser automation with 1Password CLI for secure authenticated workflows.

## When to Use

Invoke this skill when:
- Logging into external services (Linear, GitHub, Vercel, etc.)
- Testing authentication flows in local apps
- Verifying features behind authentication
- Running authenticated E2E scenarios
- Automating repetitive authenticated workflows

---

## Part 1: Prerequisites

### Required

1. **1Password CLI** installed with desktop app running
2. **Claude Code** launched with `claude --chrome` flag
3. **Chrome Integration** connected (verify with `/chrome`)

### Verification

```bash
# Check 1Password CLI
op --version
op vault list

# In Claude Code, verify Chrome tools available
/chrome
```

---

## Part 2: Core Workflow - Authenticated Login

### Step 1: Initialize Browser Session

```
# Get available tabs
mcp__claude-in-chrome__tabs_context_mcp(createIfEmpty: true)

# Create a new tab for this workflow
mcp__claude-in-chrome__tabs_create_mcp()
```

### Step 2: Navigate to Login Page

```
mcp__claude-in-chrome__navigate(url: "https://site.com/login", tabId: TAB_ID)
```

### Step 3: Detect Login Form

Use `find` to locate form elements:

```
mcp__claude-in-chrome__find(query: "email or username input field", tabId: TAB_ID)
mcp__claude-in-chrome__find(query: "password input field", tabId: TAB_ID)
mcp__claude-in-chrome__find(query: "sign in or login button", tabId: TAB_ID)
```

### Step 4: Retrieve Credentials (Just-in-Time)

Only retrieve when ready to fill:

```bash
# Get username/email
op item get "Site Name" --fields username

# Get password
op item get "Site Name" --fields password
```

### Step 5: Fill Form

Using element references from detection:

```
mcp__claude-in-chrome__form_input(ref: "ref_email", value: "[email]", tabId: TAB_ID)
mcp__claude-in-chrome__form_input(ref: "ref_password", value: "[password]", tabId: TAB_ID)
```

### Step 6: Submit and Verify

```
# Click submit button
mcp__claude-in-chrome__computer(action: "left_click", ref: "ref_submit", tabId: TAB_ID)

# Wait for navigation
mcp__claude-in-chrome__computer(action: "wait", duration: 3, tabId: TAB_ID)

# Take screenshot to verify success
mcp__claude-in-chrome__computer(action: "screenshot", tabId: TAB_ID)
```

---

## Part 3: MFA/TOTP Handling

When MFA is required after login:

### Detect MFA Prompt

```
mcp__claude-in-chrome__find(query: "verification code input OR authenticator code field", tabId: TAB_ID)
```

### Retrieve TOTP (Time-Sensitive)

TOTP codes refresh every 30 seconds. Retrieve immediately before entering:

```bash
op item get "Site Name" --otp
```

### Enter Code

```
mcp__claude-in-chrome__form_input(ref: "ref_totp", value: "[TOTP_CODE]", tabId: TAB_ID)
mcp__claude-in-chrome__computer(action: "left_click", ref: "ref_verify", tabId: TAB_ID)
```

---

## Part 4: Known Site Configurations

Reference `.claude/lib/auth-sites.json` for pre-configured sites.

| Site | 1Password Item | Notes |
|------|----------------|-------|
| Linear | `Linear` | May offer magic link option |
| GitHub | `GitHub` | Usually requires MFA |
| Vercel | `Vercel` | Two-step: email then password |

### Using Site Configs

```bash
# List available items matching a site
op item list | grep -i "linear"

# Get item details
op item get "Linear" --format json
```

---

## Part 5: Security Best Practices

### DO

1. **Retrieve credentials immediately before use** - Don't pre-load passwords
2. **Confirm with user before login** - Ask before attempting authentication
3. **Verify URL before filling** - Ensure you're on the expected domain
4. **Check login success** - Verify redirect to expected page
5. **Use fresh TOTP codes** - Retrieve OTP right before entering

### DO NOT

1. Store credentials in variables longer than necessary
2. Log credential values anywhere in conversation
3. Retry failed logins automatically with same credentials
4. Fill forms on unexpected domains
5. Skip MFA when it's required

---

## Part 6: Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| `connecting to desktop app timed out` | 1Password app not running | Start 1Password desktop app |
| `item not found` | Wrong item name | List items with `op item list` |
| `no such vault` | Vault access issue | Check `op vault list` |
| `form element not found` | Page structure changed | Use `read_page` to analyze structure |
| `MFA required` | Account has 2FA enabled | Use TOTP workflow |
| `tab not found` | Tab closed or invalid | Get fresh context with `tabs_context_mcp` |

---

## Part 7: Example Workflows

### Login to Linear

```
1. tabs_context_mcp() → tabs_create_mcp()
2. navigate(url: "linear.app")
3. Wait for page, check if already logged in
4. If login needed:
   - find("email input")
   - find("password input")
   - op item get "Linear" --fields email,password
   - form_input(ref_email, email)
   - form_input(ref_password, password)
   - click submit
5. Handle MFA if prompted
6. Screenshot dashboard to confirm
```

### Test Local App Authentication

```
1. Ensure dev server running (npm run dev)
2. tabs_create_mcp()
3. navigate(url: "localhost:3000/login")
4. find form elements
5. op item get "Local Test Account" --fields email,password
6. Fill and submit
7. Verify redirect to authenticated page
8. Screenshot for verification
```

### Record Authenticated Demo GIF

```
1. gif_creator(action: "start_recording", tabId: TAB_ID)
2. screenshot (capture initial state)
3. Complete login workflow
4. Navigate to feature being demoed
5. Perform demo actions
6. screenshot (capture final state)
7. gif_creator(action: "stop_recording", tabId: TAB_ID)
8. gif_creator(action: "export", download: true, filename: "demo.gif", tabId: TAB_ID)
```

---

## Part 8: Integration with PDOS

### With /workflow-verify

When verifying UI features that require authentication:

```
1. Start browser session
2. Login using browser-auth workflow
3. Navigate to feature
4. Verify acceptance criteria
5. Screenshot results
```

### With /tasks-autopilot

For Linear issues requiring authenticated verification:

```
1. Implement feature (TDD)
2. Start dev server
3. Login with test credentials
4. Verify feature works as expected
5. Capture evidence for PR
```

---

## Quick Reference

### 1Password CLI Commands

```bash
op vault list                              # List vaults
op item list                               # List all items
op item list --vault "Development"         # Items in vault
op item get "Item" --fields username       # Get username
op item get "Item" --fields password       # Get password
op item get "Item" --otp                   # Get TOTP code
op item get "Item" --format json           # Full item as JSON
```

### Chrome MCP Tools

```
tabs_context_mcp()                         # Get tab info
tabs_create_mcp()                          # New tab
navigate(url, tabId)                       # Go to URL
find(query, tabId)                         # Find elements
read_page(tabId)                           # Get DOM tree
form_input(ref, value, tabId)              # Fill field
computer(action, tabId, ...)               # Mouse/keyboard
gif_creator(action, tabId)                 # Record GIFs
```
