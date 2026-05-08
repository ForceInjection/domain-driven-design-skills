---
name: web-test-wallet-connect
description: Connect wallet to Web3 DApp - navigate to DApp, click Connect Wallet, approve in MetaMask popup, verify connection. Can be used as a test case or as a precondition for other tests.
license: MIT
compatibility: Node.js 18+, Playwright
metadata:
  author: AI Agent
  version: 2.0.0
allowed-tools: Bash Read
---

# Wallet Connect

Connect MetaMask wallet to a Web3 DApp.

## CRITICAL RULE - USE dapp-click WITH SELECTORS

```
┌────────────────────────────────────────────────────────────────────┐
│  ALWAYS USE dapp-click COMMAND FOR CLICKING BUTTONS!               │
│                                                                    │
│  ✅ CORRECT (Use text/css/id selectors):                           │
│     dapp-click "Connect Wallet" --wallet --headed --keep-open      │
│     dapp-click "MetaMask" --wallet --headed --keep-open            │
│     dapp-click --css "button[data-testid='connect']"               │
│     dapp-click --id "connect-btn" --wallet --headed --keep-open    │
│                                                                    │
│  dapp-click uses text/CSS/ID selectors which are RELIABLE.         │
│  It will:                                                          │
│  1. Try text selector first (e.g., "Connect Wallet")               │
│  2. Try CSS selector (e.g., "button.connect-btn")                  │
│  3. Try ID selector (e.g., "#connect-btn")                         │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

## When to Use This Skill

- **As a test case (WALLET-001)** - Connecting wallet is itself a testable feature
- **As a precondition** - When other test cases require wallet to be connected
- **When wallet gets disconnected** - Re-establish connection during test execution

## Usage Modes

### Mode 1: As a Test Case
When `tests/test-cases.yaml` contains a wallet connection test case (e.g., WALLET-001), this skill is invoked to execute that test.

### Mode 2: As a Precondition
When a test case has `preconditions: [WALLET-001 passed]` or similar, the test executor should:
1. Check if wallet is already connected
2. If not, invoke this skill to connect the wallet first

## Prerequisites

1. **web-test-wallet-setup** must have been executed if `web3.enabled: true` in config
2. DApp is running and accessible
3. Wallet extension is initialized with funds (if needed)

## Quick Start

```bash
SKILL_DIR="<path-to-this-skill>"

# Navigate to DApp with wallet
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-navigate "http://localhost:3000" --wallet --headed --keep-open

# Click Connect Wallet button using text selector (PREFERRED METHOD)
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "Connect Wallet" --wallet --headed --keep-open

# If wallet modal appears, click MetaMask option
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "MetaMask" --wallet --headed --keep-open

# Approve connection in MetaMask popup
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-approve --wallet --headed --keep-open

# Verify connection
node $SKILL_DIR/scripts/wallet-connect-helper.js screenshot after-connect.jpg --wallet --headed --keep-open
```

## Instructions

### Step 1: Navigate to DApp

```bash
SKILL_DIR="<path-to-this-skill>"
DAPP_URL="http://localhost:3000"  # Your DApp URL

# Navigate to DApp with wallet extension loaded
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-navigate "$DAPP_URL" --wallet --headed --keep-open
```

**Expected Output:**
```json
{
  "success": true,
  "url": "http://localhost:3000",
  "screenshot": "dapp-home.jpg"
}
```

### Step 2: Click Connect Wallet Button

**Use `dapp-click` with text selector - this is the PREFERRED method:**

```bash
SKILL_DIR="<path-to-this-skill>"

# Try common button text labels
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "Connect Wallet" --wallet --headed --keep-open

# If that doesn't work, try other common labels:
# dapp-click "Connect" --wallet --headed --keep-open
# dapp-click "Sign In" --wallet --headed --keep-open
# dapp-click "Connect wallet" --wallet --headed --keep-open
```

**Common Connect Button Labels (try in order):**
1. "Connect Wallet"
2. "Connect"
3. "Connect wallet"
4. "Sign In"
5. "Login"

**If text selector fails, use CSS selector:**
```bash
# Try CSS selectors
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click --css "button[data-testid='connect']" --wallet --headed --keep-open
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click --css ".connect-button" --wallet --headed --keep-open
```

**ONLY as last resort - use coordinates with fallback:**
```bash
# Take screenshot first to find coordinates
node $SKILL_DIR/scripts/wallet-connect-helper.js screenshot before-connect.jpg --wallet --headed --keep-open

# Then use dapp-click with fallback coordinates
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "Connect Wallet" --fallback-x 900 --fallback-y 50 --wallet --headed --keep-open
```

### Step 3: Handle Wallet Selection Modal

Many DApps show a wallet selection modal (Rainbow Kit, Privy, etc.):

**Use `dapp-click` to select MetaMask option:**

```bash
SKILL_DIR="<path-to-this-skill>"

# Try common MetaMask button labels
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "MetaMask" --wallet --headed --keep-open

# If that doesn't work, try other common labels:
# dapp-click "Injected Wallet" --wallet --headed --keep-open
# dapp-click "Browser Wallet" --wallet --headed --keep-open
# dapp-click "Injected" --wallet --headed --keep-open
```

**Common Modal Options (try in order):**
1. "MetaMask"
2. "Injected Wallet"
3. "Browser Wallet"
4. "Injected"
5. "Rabby"

**If text selector fails, use fallback coordinates:**
```bash
# Take screenshot to find coordinates
node $SKILL_DIR/scripts/wallet-connect-helper.js screenshot wallet-modal.jpg --wallet --headed --keep-open

# Use dapp-click with fallback
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "MetaMask" --fallback-x 400 --fallback-y 300 --wallet --headed --keep-open
```

### Step 4: Approve Connection in MetaMask

```bash
SKILL_DIR="<path-to-this-skill>"

# Auto-approve the MetaMask connection popup
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-approve --wallet --headed --keep-open
```

**What this does:**
- Detects MetaMask popup window
- Takes screenshot of popup
- Clicks "Connect" or "Confirm" button
- Waits for popup to close

### Step 5: Verify Connection

```bash
SKILL_DIR="<path-to-this-skill>"

# Take screenshot to verify wallet is connected
node $SKILL_DIR/scripts/wallet-connect-helper.js screenshot after-connect.jpg --wallet --headed --keep-open
```

**Verification Criteria:**
- Wallet address (0x...) visible on page
- "Connect Wallet" button replaced with address/avatar
- Account menu or profile icon appears

### Step 6: Handle Failures

If connection fails, retry up to 3 times:

```bash
# Attempt 1 failed? Try again
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-navigate "$DAPP_URL" --wallet --headed --keep-open
# ... repeat steps 2-6

# After 3 failures, STOP and report error
```

## Complete Flow Example

```bash
SKILL_DIR="<path-to-this-skill>"
DAPP_URL="http://localhost:3000"

# 1. Navigate to DApp
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-navigate "$DAPP_URL" --wallet --headed --keep-open

# 2. Click Connect Wallet using text selector (PREFERRED)
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "Connect Wallet" --wallet --headed --keep-open
# Output: { "success": true, "method": "text selector: button:has-text(\"Connect Wallet\")" }

# 3. If wallet modal appears, click MetaMask option
node $SKILL_DIR/scripts/wallet-connect-helper.js wait 1000 --wallet --headed --keep-open
node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "MetaMask" --wallet --headed --keep-open
# Output: { "success": true, "method": "text selector: text=\"MetaMask\"" }

# 4. Approve in MetaMask
node $SKILL_DIR/scripts/wallet-connect-helper.js wallet-approve --wallet --headed --keep-open

# 5. Verify connection
node $SKILL_DIR/scripts/wallet-connect-helper.js screenshot connected.jpg --wallet --headed --keep-open
# AI verifies: "Wallet address 0x1234...abcd visible - SUCCESS"
```

### Fallback Example (when text selectors fail)

```bash
# If dapp-click "Connect Wallet" fails, use fallback coordinates:
node $SKILL_DIR/scripts/wallet-connect-helper.js screenshot find-button.jpg --wallet --headed --keep-open
# AI analyzes screenshot: "Connect button at x=900, y=50"

node $SKILL_DIR/scripts/wallet-connect-helper.js dapp-click "Connect Wallet" --fallback-x 900 --fallback-y 50 --wallet --headed --keep-open
```

## Command Reference

### Primary Commands (Use These!)

| Command | Description |
|---------|-------------|
| `dapp-click "<text>"` | **PREFERRED** - Click element by text (e.g., "Connect Wallet", "MetaMask") |
| `dapp-click --css "<selector>"` | Click element by CSS selector |
| `dapp-click "<text>" --fallback-x X --fallback-y Y` | Click with coordinate fallback |
| `wallet-navigate <url>` | Navigate to DApp with wallet extension |
| `wallet-approve` | Auto-approve MetaMask popup |

### Secondary Commands

| Command | Description |
|---------|-------------|
| `wallet-switch-network <name>` | Switch network |
| `wallet-get-address` | Get connected address |
| `screenshot [name]` | Take screenshot for AI analysis |
| `wait <ms>` | Wait milliseconds |

### dapp-click Examples

```bash
# By text (try multiple labels)
dapp-click "Connect Wallet" --wallet --headed --keep-open
dapp-click "MetaMask" --wallet --headed --keep-open

# By CSS selector
dapp-click --css "button[data-testid='connect']" --wallet --headed --keep-open
dapp-click --css ".connect-button" --wallet --headed --keep-open

# With fallback coordinates (when selectors fail)
dapp-click "Connect" --fallback-x 900 --fallback-y 50 --wallet --headed --keep-open
```

## Troubleshooting

### "Connect button not found"
- Try different text labels: "Connect Wallet", "Connect", "Connect wallet", "Sign In"
- Use CSS selector: `dapp-click --css "button.connect-btn"`
- Add wait time before clicking: `wait 2000`
- As last resort, take screenshot and use fallback coordinates

### "Wallet modal doesn't appear"
- dapp-click may not have found the button - check output for method used
- If it says "coordinates", the text selector failed - try different text or CSS

### "MetaMask popup not detected"
- Extension may not be properly loaded
- Check `./test-output/extensions/metamask/` exists

### "Connection rejected"
- Check if DApp requires specific network
- Switch network before connecting

## Related Skills

- **web-test-wallet-setup** - Required first if `web3.enabled: true` in config
- **web-test** - Executes test cases (may call this skill as precondition)
- **web-test-report** - Generate report after testing
- **web-test-cleanup** - Clean up after testing

## Next Steps

After wallet connection is verified:
1. Proceed to **web-test** skill to execute test cases
2. Handle wallet transaction popups during tests with `wallet-approve`

## Notes

- Keep browser open (`--keep-open`) for subsequent test steps
- Always use `--wallet --headed` flags for wallet operations
- Max 3 retry attempts for connection
- If all retries fail, stop testing and report error
