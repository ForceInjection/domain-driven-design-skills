---
name: web-test-wallet-setup
description: Set up MetaMask wallet extension for Web3 DApp testing - download extension, import wallet from private key. Run at test start if tests/config.yaml has web3.enabled=true.
license: MIT
compatibility: Node.js 18+, Playwright
metadata:
  author: AI Agent
  version: 2.1.0
allowed-tools: Bash Read
---

# Wallet Setup

Set up MetaMask wallet extension for Web3 DApp testing.

**Updated for MetaMask v13** with new UI support.

## When to Use This Skill

This skill should be executed **automatically at the start of testing** when:

```yaml
# In tests/config.yaml
web3:
  enabled: true  # <-- If this is true, run wallet-setup FIRST
```

**Execution timing:**
- **Run once at test start** - Before any test cases are executed
- **NOT between tests** - Setup only needs to run once per test session
- **Automatic by web-test** - The web-test skill checks config.yaml and calls this automatically

## Prerequisites

1. **`tests/.test-env`** file with `WALLET_PRIVATE_KEY` already exists
2. **`tests/config.yaml`** exists with `web3.enabled: true`
3. Project research completed (web-test-research)

## Quick Start

```bash
SKILL_DIR="<path-to-this-skill>"

# Step 1: Download wallet extension
node $SKILL_DIR/scripts/wallet-setup-helper.js wallet-setup

# Step 2: Initialize wallet (reads WALLET_PRIVATE_KEY from .test-env, writes WALLET_PASSWORD)
node $SKILL_DIR/scripts/wallet-setup-helper.js wallet-init --wallet --headed
```

## How It Works

- **Reads** `WALLET_PRIVATE_KEY` from `tests/.test-env`
- **Converts** private key to 24-word mnemonic using BIP-39 algorithm
- **Imports** wallet using the generated mnemonic (first account = your private key's address)
- **Writes** `WALLET_PASSWORD` to `tests/.test-env` (auto-generated if not set)
- Private key is only used locally in Playwright browser, never exposed to AI APIs

**Technical Note**: The private key (256 bits) is used as entropy to generate a 24-word BIP-39 mnemonic. This mnemonic, when imported into MetaMask, creates a wallet where the first derived account corresponds exactly to the original private key.

## Instructions

### Step 1: Download Wallet Extension

```bash
SKILL_DIR="<path-to-this-skill>"

# Download and install MetaMask wallet extension
node $SKILL_DIR/scripts/wallet-setup-helper.js wallet-setup
```

**What this does:**
- Downloads MetaMask wallet from GitHub releases
- Extracts to `./test-output/extensions/metamask/`
- Prepares extension for browser loading

**Expected Output:**
```json
{
  "success": true,
  "message": "MetaMask Wallet v13.13.1 installed successfully",
  "extensionPath": "./test-output/extensions/metamask"
}
```

### Step 2: Initialize Wallet

```bash
SKILL_DIR="<path-to-this-skill>"

# Initialize wallet (reads from .test-env automatically)
node $SKILL_DIR/scripts/wallet-setup-helper.js wallet-init --wallet --headed
```

**What this does:**
- Reads `WALLET_PRIVATE_KEY` from `tests/.test-env`
- Launches browser with wallet extension
- Imports wallet using private key
- Generates and saves `WALLET_PASSWORD` to `.test-env`
- Verifies wallet is ready

**Expected Output:**
```json
{
  "success": true,
  "message": "Wallet initialization completed successfully",
  "nextStep": "Use web-test-wallet-connect to connect wallet to DApp"
}
```

## Troubleshooting

### "WALLET_PRIVATE_KEY not found in .test-env file"

The `.test-env` file does not exist or does not contain the private key. Ensure `tests/.test-env` exists with `WALLET_PRIVATE_KEY` before running this skill.

### "Extension download failed"

Check network connection. The script downloads from GitHub releases.

### "Wallet initialization failed"

1. Check if headed mode is working (display available)
2. Verify private key format (should start with 0x)
3. Check `./test-output/screenshots/` for error screenshots

### "Wallet already initialized"

If wallet was previously set up, it will be unlocked automatically using the password from `.test-env`.

To reset:
```bash
rm -rf ./test-output/chrome-profile/
node $SKILL_DIR/scripts/wallet-setup-helper.js wallet-setup
node $SKILL_DIR/scripts/wallet-setup-helper.js wallet-init --wallet --headed
```

## Data Storage

```
<project-root>/
├── tests/
│   └── .test-env        # Reads WALLET_PRIVATE_KEY, writes WALLET_PASSWORD
└── test-output/
    ├── extensions/
    │   └── metamask/    # MetaMask extension files
    ├── chrome-profile/  # Browser profile with wallet state
    └── screenshots/     # Setup screenshots for debugging
```

## Related Skills

- **web-test-research** - Analyze project, detect Web3 features
- **web-test-case-gen** - Generates config.yaml with web3.enabled setting
- **web-test-wallet-connect** - Called as test case or precondition (not mandatory after setup)
- **web-test** - Orchestrates test execution, calls wallet-setup if web3.enabled
- **web-test-cleanup** - Clean up wallet data when done

## Next Steps

After wallet setup is complete:
1. **web-test** will execute test cases from `tests/test-cases.yaml`
2. **web-test-wallet-connect** will be invoked when needed by test cases (as a test or precondition)

## Notes

- Wallet setup only needs to run once per test-output directory
- Wallet state persists in chrome-profile between test runs
- Use `web-test-cleanup` without `--keep-data` to reset wallet
- Always use a test wallet with minimal funds for testing

## Technical Details (MetaMask v13)

The script supports both the new MetaMask v13 UI and older versions:

**New UI Flow (v13+)**:
1. Welcome Page: Click "I have an existing wallet"
2. Sign-in Options: Click "Import using Secret Recovery Phrase"
3. SRP Input: Single textarea (use `keyboard.type()` for proper event handling)
4. Password: "Create new password" + "Confirm password" + checkbox
5. Complete: Click through "Got it" / "Done" dialogs

**Key Selectors (v13)**:
- Welcome: `button:has-text("I have an existing wallet")`
- Import SRP: `button:has-text("Import using Secret Recovery Phrase")`
- SRP Input: `textarea` (NOT 12 separate inputs)
- Continue: `button:has-text("Continue")`
- Password: `input[type="password"]` (2 inputs)
- Create: `button:has-text("Create password")`
- Account menu: `[data-testid="account-menu-icon"]`
- Add account: `[data-testid="multichain-account-menu-popover-action-button"]`
- Import account: `[data-testid="multichain-account-menu-popover-add-imported-account"]`
- Private key: `#private-key-box`
