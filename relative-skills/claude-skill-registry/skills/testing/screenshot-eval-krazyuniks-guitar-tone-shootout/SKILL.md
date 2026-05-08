---
name: screenshot-eval
description: Evaluate browser screenshots and page state for errors. Use when verifying features work correctly, detecting error conditions, or validating UI state during browser testing.
---

# Screenshot Evaluation Skill

**Activation:** screenshot evaluation, error detection, browser testing, UI verification, feature validation, console errors, network failures

## Overview

This skill provides a systematic approach to evaluating browser state during testing. It ensures features actually work by checking for console errors, network failures, and visual error indicators before declaring success.

**Critical Rule:** A feature is NOT complete until browser testing passes with no errors.

## Evaluation Checklist

Execute these steps in order after navigating to the page or completing an action:

### Step 1: Check Console for Errors

```
Use mcp__playwright__browser_console_messages with level="error"
```

**Pass criteria:**
- No console errors related to your feature
- React errors (component crashes) = FAIL
- Network/fetch errors = FAIL
- TypeScript/undefined errors = FAIL

**Acceptable errors (can ignore):**
- Third-party script warnings (analytics, etc.)
- Deprecated API warnings not related to your code

### Step 2: Check Network Requests

```
Use mcp__playwright__browser_network_requests
```

**Pass criteria:**
- All API requests return 2xx status codes
- No 4xx errors (except expected 401/403 for auth tests)
- No 5xx server errors
- All requests complete (no pending/cancelled)

**Check specifically:**
- Your API endpoints return expected data
- Static assets load successfully
- WebSocket connections establish if needed

### Step 3: Take Accessibility Snapshot

```
Use mcp__playwright__browser_snapshot
```

**Error patterns to look for in snapshot:**

| Pattern | Indicates |
|---------|-----------|
| "404" or "Not Found" | Missing route or resource |
| "500" or "Internal Server Error" | Backend crash |
| "Error" in heading/alert | Application error state |
| "Something went wrong" | Error boundary triggered |
| "Loading..." persisting | Infinite loading state |
| Empty content where data expected | Failed data fetch |
| "undefined" or "null" in text | Missing data handling |

### Step 4: Take Screenshot Proof

```
Use mcp__playwright__browser_take_screenshot
```

**This screenshot is REQUIRED evidence** that the feature works:
- Shows the expected UI state
- Proves the feature rendered correctly
- Attached to PR or issue as verification

## Pass/Fail Criteria

### PASS - All conditions met:
- [ ] No console errors (Step 1)
- [ ] All network requests succeeded (Step 2)
- [ ] No error patterns in snapshot (Step 3)
- [ ] Screenshot shows expected state (Step 4)

### FAIL - Any condition:
- [ ] Console errors present
- [ ] Network requests failed (4xx/5xx)
- [ ] Error patterns detected in snapshot
- [ ] UI shows error state or missing content

## Example Evaluation Workflow

### Testing a New Feature

```markdown
## Feature: Create Shootout Form

1. Navigate to /builder
   → mcp__playwright__browser_navigate url="/builder"

2. Check for errors after page load
   → mcp__playwright__browser_console_messages level="error"
   ✓ No console errors

3. Check network requests
   → mcp__playwright__browser_network_requests
   ✓ All 200 OK

4. Take snapshot, verify form elements
   → mcp__playwright__browser_snapshot
   ✓ Form visible with expected fields

5. Fill form and submit
   → mcp__playwright__browser_fill_form
   → mcp__playwright__browser_click (submit button)

6. Check for errors after submission
   → mcp__playwright__browser_console_messages level="error"
   ✓ No console errors

7. Check API call succeeded
   → mcp__playwright__browser_network_requests
   ✓ POST /api/v1/shootouts returned 201

8. Verify success state
   → mcp__playwright__browser_snapshot
   ✓ Success message visible OR redirected to new shootout

9. Take final screenshot proof
   → mcp__playwright__browser_take_screenshot
   ✓ Screenshot captured
```

### Debugging a Failure

When evaluation fails:

1. **Console error?** → Check the error message, fix the code
2. **Network failure?** → Check backend logs, verify endpoint exists
3. **Error in snapshot?** → Identify the component showing error, trace the cause
4. **Infinite loading?** → Check if API call returned, verify data handling

## MCP Tools Reference

### Playwright (PR Verification)

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `mcp__playwright__browser_navigate` | Go to URL | Start of test |
| `mcp__playwright__browser_console_messages` | Get console output | After page load, after actions |
| `mcp__playwright__browser_network_requests` | Get network activity | Verify API calls |
| `mcp__playwright__browser_snapshot` | Accessibility tree | Verify page content |
| `mcp__playwright__browser_take_screenshot` | Visual capture | Final proof |
| `mcp__playwright__browser_click` | Click element | User interactions |
| `mcp__playwright__browser_fill_form` | Fill form fields | Form testing |

### Chrome DevTools (Deep Debugging)

When Playwright checks show errors, use Chrome DevTools for deeper investigation:

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `mcp__chrome-devtools__get_console_logs` | Full console output | Debug error details |
| `mcp__chrome-devtools__get_network_logs` | Request/response details | Debug API failures |
| `mcp__chrome-devtools__get_computed_style` | CSS debugging | Fix styling issues |
| `mcp__chrome-devtools__get_element_info` | Element properties | Debug layout problems |
| `mcp__chrome-devtools__evaluate` | Run JS in context | Debug state issues |

**Workflow:** Playwright finds issue → Chrome DevTools investigates → Fix code → Playwright verifies

## Integration with /pr Command

The `/pr` command enforces this evaluation before PR creation:

1. Runs quality gates (tests, lint, build)
2. **Requires browser testing** using this skill
3. Checks console for errors
4. Checks network for failures
5. Captures screenshot proof
6. Includes evidence in PR body

**Never bypass browser testing** - unit tests passing does NOT mean the feature works.

## Common Issues and Solutions

### React Error Boundary Triggered
- Check for unhandled promises
- Verify data shape matches component expectations
- Check for null/undefined access

### API Returns 404
- Verify endpoint URL is correct
- Check if backend route exists
- Verify path parameters are valid

### API Returns 500
- Check backend container logs
- Verify database migrations ran
- Check for missing environment variables

### Infinite Loading
- API might be hanging - check backend
- Data might not trigger render - check state updates
- WebSocket might not connect - check connection setup

### Empty Content
- API might return empty array - verify test data exists
- Conditional rendering might hide content - check conditions
- Data might be undefined - check fetch success
