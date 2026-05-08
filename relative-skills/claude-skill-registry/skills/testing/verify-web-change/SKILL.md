---
name: verify-web-change
description: Verify web application changes work by launching the app stack and testing in a real browser. This skill should be used when the user asks to "verify the change", "test in browser", "check if it works", or after completing a PR to validate the implementation. Requires Playwright MCP server. MUST exit if Playwright MCP is unavailable.
---

# Verify Web Change

Verify that pull request changes work correctly in a running web application using browser automation.

## Critical Requirements

**Playwright MCP is MANDATORY.** This skill cannot function without it.

## Workflow

Execute these steps in order. Do not skip steps.

### Step 1: Verify Playwright MCP Availability

**MUST exit if this step fails.**

Test Playwright MCP by attempting to list browser tabs:

```
mcp__playwright__browser_tabs
  action: "list"
```

If this tool:
- **Succeeds**: Continue to Step 2
- **Fails with "tool not found"**: EXIT immediately with message:
  ```
  ❌ VERIFICATION FAILED: Playwright MCP server is not installed.

  To install:
  1. Run: npx @anthropic-ai/mcp-server-playwright
  2. Configure in Claude Code MCP settings
  3. Restart Claude Code
  ```
- **Fails with connection error**: EXIT with message about MCP server not running

**Do NOT proceed if Playwright MCP is unavailable.**

### Step 2: Analyze PR Changes

Before launching the application, understand what to verify.

#### 2.1 Get Changed Files

```bash
git diff main --name-only
git diff main --stat
```

#### 2.2 Understand the Changes (ULTRATHINK)

Read the changed files and related context to understand:
- What UI elements were added/modified?
- What user interactions should work?
- What visual changes should be visible?
- Are there related test files that show expected behavior?

```bash
# Check for existing Playwright/E2E tests
find . -name "*.spec.ts" -o -name "*.test.ts" -o -name "*.e2e.ts" | head -20
ls -la tests/ e2e/ playwright/ __tests__/ 2>/dev/null || true
```

If Playwright tests exist, read them to understand:
- What pages/routes are tested
- What elements are interacted with
- What assertions are made

#### 2.3 Define Verification Criteria

Create a mental checklist of what must be verified:
- [ ] Specific UI element(s) present
- [ ] Specific interaction(s) work
- [ ] No console errors
- [ ] Expected visual appearance

### Step 3: Launch Application Stack

#### 3.1 Detect and Start Services

Check for docker-compose/compose files:

```bash
ls -la docker-compose.yml docker-compose.yaml compose.yml compose.yaml 2>/dev/null || echo "No compose file found"
```

If compose file exists:
```bash
docker compose up -d
sleep 5  # Wait for services to initialize
```

#### 3.2 Detect Package Manager

```bash
# Check for lockfiles in order of preference
if [[ -f "bun.lockb" ]] || [[ -f "bun.lock" ]]; then
    PM="bun"
elif [[ -f "pnpm-lock.yaml" ]]; then
    PM="pnpm"
elif [[ -f "yarn.lock" ]]; then
    PM="yarn"
else
    PM="npm"
fi
echo "Package manager: $PM"
```

#### 3.3 Install Dependencies (if needed)

```bash
# Only if node_modules doesn't exist
[[ -d "node_modules" ]] || $PM install
```

#### 3.4 Start Development Server

Start the dev server in background:

```bash
# Common dev commands - check package.json scripts
$PM run dev &
```

Wait for server to be ready:
```bash
sleep 10  # Adjust based on typical startup time
```

Or use Playwright to wait:
```
mcp__playwright__browser_navigate
  url: "http://localhost:3000"  # Adjust port as needed
```

### Step 4: Verify Application Loads

#### 4.1 Navigate to Application

```
mcp__playwright__browser_navigate
  url: "http://localhost:3000"
```

#### 4.2 Take Initial Snapshot

```
mcp__playwright__browser_snapshot
```

#### 4.3 Check for Errors

```
mcp__playwright__browser_console_messages
  level: "error"
```

If critical errors exist, report them and investigate.

#### 4.4 Verify Basic Functionality

Confirm the application loads and shows expected content. If it doesn't load:
- Check if server is running
- Check console for errors
- Check network requests for failures

### Step 5: Verify Specific Changes

This is the core verification step. Based on the PR changes identified in Step 2:

#### 5.1 Navigate to Affected Area

If the change affects a specific route/page:
```
mcp__playwright__browser_navigate
  url: "http://localhost:3000/affected-route"
```

#### 5.2 Snapshot and Verify Elements

```
mcp__playwright__browser_snapshot
```

Check the snapshot for:
- New UI elements mentioned in the PR
- Modified text/labels
- New columns, buttons, or interactive elements

#### 5.3 Test Interactions (if applicable)

For interactive changes, test the interaction:
```
mcp__playwright__browser_click
  element: "description of element"
  ref: "ref-from-snapshot"
```

Then snapshot again to verify the result:
```
mcp__playwright__browser_snapshot
```

#### 5.4 Verify Against Existing Tests

If the codebase has Playwright tests for the changed area:
1. Read the test file
2. Manually replicate key assertions
3. Verify the same conditions pass

### Step 6: Report Results

#### Success Criteria

The ONLY success criteria is: **The actual changes made in the PR are verified to be present and working in the running application.**

#### Success Report

```
✅ VERIFICATION PASSED

Changes Verified:
- [specific change 1]: ✅ Working
- [specific change 2]: ✅ Working
- [specific change N]: ✅ Working

Evidence:
- [what was observed that confirms each change]
```

#### Failure Report

```
❌ VERIFICATION FAILED

Expected: [what should have been observed]
Actual: [what was actually observed]

Details:
- [specific issue 1]
- [specific issue 2]

Console Errors: [if any]
```

### Step 7: Cleanup

Stop background processes:
```bash
# Kill dev server if started
pkill -f "bun run dev" || pkill -f "npm run dev" || true

# Stop docker services if started
docker compose down 2>/dev/null || true
```

## Reference

For detailed Playwright MCP tool documentation, see: `references/playwright-mcp.md`

## Bundled Scripts

- `scripts/launch-app-stack.sh` - Detect and launch application stack
- `scripts/check-playwright-mcp.sh` - Verify Playwright MCP availability

## Common Application Ports

| Framework | Default Port |
|-----------|-------------|
| Vite | 5173 |
| Next.js | 3000 |
| Create React App | 3000 |
| TanStack Start | 3000 |
| Remix | 3000 |
| Nuxt | 3000 |
| SvelteKit | 5173 |

## Troubleshooting

### Playwright MCP Not Found
Install the MCP server and configure it in Claude Code settings.

### Application Won't Start
- Check if ports are already in use
- Verify docker services are running
- Check for missing environment variables
- Review startup logs for errors

### Element Not Found in Snapshot
- The page may not have fully loaded; use `browser_wait_for`
- The element may be in a different route/page
- The element may require interaction to appear (expand, click, etc.)

### Console Errors Present
- Note errors but distinguish between critical and non-critical
- Pre-existing errors may not be related to the PR changes
- Focus on errors that appeared with the new changes
