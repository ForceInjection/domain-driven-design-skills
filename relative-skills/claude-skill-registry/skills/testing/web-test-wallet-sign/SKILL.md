---
name: web-test-wallet-sign
description: Handle MetaMask signature and transaction popups during Web3 DApp testing - approve signatures, send transactions, call contracts. Detects popup type and handles gas errors.
license: MIT
compatibility: Node.js 18+, Playwright
metadata:
  author: AI Agent
  version: 1.0.0
allowed-tools: Bash Read
---

# Wallet Sign

Handle MetaMask signature requests and transaction popups during Web3 DApp testing.

## When to Use This Skill

- **During web-test execution** when MetaMask popup appears
- **When DApp requests signature** (personal_sign, signTypedData)
- **When DApp sends transaction** (eth_sendTransaction)
- **When DApp calls contract** (write operations)

## Prerequisites

1. **web-test-wallet-setup** completed
2. **web-test-wallet-connect** completed (wallet connected to DApp)
3. Browser session active with wallet

## Quick Start

```bash
SKILL_DIR="<path-to-this-skill>"

# Handle any MetaMask popup (auto-detects type)
node $SKILL_DIR/scripts/wallet-sign-helper.js wallet-sign --wallet --headed --keep-open
```

## Popup Types

### 1. Sign Message (personal_sign)
- **Action**: Auto-approve
- **Risk**: Low (read-only, no gas)
- **Result**: Always succeeds

### 2. Sign Typed Data (signTypedData_v4)
- **Action**: Auto-approve
- **Risk**: Low (read-only, no gas)
- **Result**: Always succeeds

### 3. Send Transaction (eth_sendTransaction)
- **Action**: Check gas, then approve/reject
- **Risk**: Medium (costs gas, transfers value)
- **Result**: Fails if insufficient gas

### 4. Contract Call (write operations)
- **Action**: Check gas, then approve/reject
- **Risk**: Medium (costs gas)
- **Result**: Fails if insufficient gas

## Instructions

### Detect and Handle Popup

```bash
SKILL_DIR="<path-to-this-skill>"

# Auto-detect popup type and handle appropriately
node $SKILL_DIR/scripts/wallet-sign-helper.js wallet-sign --wallet --headed --keep-open
```

**Output for Signature:**
```json
{
  "success": true,
  "type": "signature",
  "subtype": "personal_sign",
  "action": "approved",
  "message": "Signature request approved"
}
```

**Output for Transaction (success):**
```json
{
  "success": true,
  "type": "transaction",
  "action": "approved",
  "txHash": "0x...",
  "message": "Transaction sent successfully"
}
```

**Output for Transaction (gas error):**
```json
{
  "success": false,
  "type": "transaction",
  "action": "failed",
  "error": "insufficient_gas",
  "message": "Transaction failed: insufficient funds for gas"
}
```

### Force Reject

```bash
# Reject any popup (for testing negative flows)
node $SKILL_DIR/scripts/wallet-sign-helper.js wallet-reject --wallet --headed --keep-open
```

### Check Popup Status

```bash
# Check if there's a pending popup without acting
node $SKILL_DIR/scripts/wallet-sign-helper.js wallet-check --wallet --headed --keep-open
```

## Command Reference

| Command | Description |
|---------|-------------|
| `wallet-sign` | Auto-detect and handle popup (approve signatures, check gas for tx) |
| `wallet-reject` | Reject any pending popup |
| `wallet-check` | Check popup status without acting |

## Error Handling

### Gas Errors (Test Failure)

When a transaction or contract call fails due to insufficient gas:

```json
{
  "success": false,
  "type": "transaction",
  "error": "insufficient_gas",
  "details": {
    "required": "0.01 ETH",
    "available": "0.001 ETH"
  },
  "action": "test_failed",
  "message": "Insufficient funds for gas - test marked as FAILED"
}
```

**Important**: Gas errors should fail the current test case in web-test.

### Network Errors

```json
{
  "success": false,
  "error": "network_error",
  "message": "Failed to broadcast transaction"
}
```

## Integration with web-test

During test execution, when a MetaMask popup is detected:

1. **Pause test execution**
2. **Call wallet-sign**
3. **Check result**:
   - If `success: true` → continue test
   - If `success: false` with `error: insufficient_gas` → **FAIL test**
   - If `success: false` with other errors → retry or fail based on test config

## Related Skills

- **web-test-wallet-setup** - Must complete first
- **web-test-wallet-connect** - Must connect before signing
- **web-test** - Main test runner that uses this skill
- **web-test-cleanup** - Clean up after testing

## MetaMask UI Detection

The skill detects popup type by analyzing the MetaMask notification page:

- **Signature Request**: Contains "Sign" button, "Message" text, no gas info
- **Transaction**: Contains "Confirm" button, gas fee display, value transfer
- **Contract Call**: Contains "Confirm" button, gas fee, function call data

## Notes

- Signatures (personal_sign, signTypedData) never fail - always approve
- Transactions and contract calls check for gas errors before approval
- If gas error detected, popup is rejected and test is marked as failed
- Screenshots are taken at each step for debugging
