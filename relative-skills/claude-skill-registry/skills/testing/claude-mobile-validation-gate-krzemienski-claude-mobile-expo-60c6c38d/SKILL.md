---
name: claude-mobile-validation-gate
description: Use when executing validation gates 3A, 4A, or 6A-E, verifying phase completion with expo-mcp visual testing, or encountering test failures - automates gate execution with expo-mcp autonomous verification and HARD STOP enforcement
---

# Validation Gate Automation with expo-mcp

## Overview

Execute validation gates with expo-mcp autonomous testing (visual verification) and HARD STOP enforcement on failures.

**Core principle:** ALL tests must pass. Use expo-mcp for visual verification. STOP immediately if any fail.

**Announce at start:** "I'm using the claude-mobile-validation-gate skill to execute Validation Gate [X]."

## When to Use

- Executing Gate 3A (backend functional testing)
- Executing Gate 4A (frontend visual testing with expo-mcp)
- Executing Gates 6A-E (integration testing with expo-mcp)
- Verifying phase completion
- Re-testing after fixes

## Gate Overview

| Gate | Type | Primary Tool | Pass Criteria |
|------|------|-------------|---------------|
| 3A | Backend functional | wscat + filesystem | All 14 tests pass |
| 4A | Frontend visual | expo-mcp autonomous | AI verifies all screens |
| 6A | Connection | expo-mcp visual | Green dot shows "Connected" |
| 6B | Message flow | expo-mcp visual | Message appears, streams, completes |
| 6C | Tool execution | expo-mcp visual | Tool card appears, file created |
| 6D | File browser | expo-mcp visual | Navigation works, file opens |
| 6E | Sessions | expo-mcp visual | Create, switch, delete work |

## Gate 4A: Frontend Visual Testing (expo-mcp)

**Prerequisites**: Metro with EXPO_UNSTABLE_MCP_SERVER=1, app built and running

**Autonomous Testing Workflow**:

```
Step 1: "Take screenshot of Chat screen empty state"
AI analyzes: Purple gradient ✅, Input field ✅, Send button ✅

Step 2: "Find view with testID 'message-input'"
expo-mcp: {found: true, accessible: true, enabled: true} ✅

Step 3: "Tap button with testID 'send-button'"
expo-mcp: Tapped successfully ✅

Step 4: "Take screenshot showing all 5 screens"
AI verifies: All screens render correctly ✅

Step 5: "Test navigation between screens"
expo-mcp: Navigation works ✅

Step 6: AI determines: PASS or FAIL
```

### Execute Gate 4A

```typescript
// Manual expo-mcp testing workflow (not bash script)
// Use natural language prompts:

"Take screenshot of Chat screen and verify purple gradient background"
"Find view with testID 'settings-button' and verify it exists"
"Tap button with testID 'settings-button'"
"Take screenshot and verify Settings screen loaded"
"Navigate through all 5 screens and verify each renders correctly"

// AI analyzes each screenshot visually
// AI determines overall PASS/FAIL
```

## Gate 3A: Backend Functional Testing

**Execute**:

```typescript
mcp__serena__execute_shell_command({
  command: "./scripts/validate-gate-3a.sh",
  cwd: "/Users/nick/Desktop/claude-mobile-expo"
});
```

**Pass Criteria**: Exit code 0, all 14 tests pass

## Gates 6A-E: Integration Testing (expo-mcp)

All integration gates use expo-mcp for visual verification:

**Gate 6A Example**:
```
"Take screenshot of Chat screen connection status"
AI verifies: Green dot visible ✅, "Connected" text ✅
```

**Gate 6B Example**:
```
"Type 'Hello Claude' in message input"
"Tap send button with testID 'send-button'"
"Take screenshot and verify user message appears"
"Take screenshot and verify assistant response streams in"
```

## HARD STOP Enforcement

**If ANY test fails**:

```typescript
// 1. STOP immediately
// 2. Read error logs
mcp__serena__read_file({relative_path: "logs/combined.log"});
mcp__serena__read_file({relative_path: "logs/error.log"});

// 3. Invoke debugging
// Use @systematic-debugging

// 4. Fix issues

// 5. Re-run gate

// 6. Do NOT proceed to next phase until PASS
```

## Save Results (MANDATORY)

```typescript
mcp__serena__write_memory({
  memory_name: "validation-gate-[X]-results-YYYY-MM-DD",
  content: `
# Gate [X] Results
Status: PASSED ✅

[All test results]
[Screenshots if applicable]
[expo-mcp verification details]

Ready for next phase.
`
});
```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Skip some tests" | WRONG. ALL tests required. |
| "One failure is OK" | WRONG. ANY failure = HARD STOP. |
| "Manual testing is better" | WRONG for Gate 4A. expo-mcp autonomous required. |
| "Proceed anyway" | WRONG. Fix and re-test. |

## Red Flags

- "This test is obvious" → WRONG. Run it anyway.
- "One failure won't matter" → WRONG. HARD STOP on ANY failure.
- "I'll fix in integration" → WRONG. Fix now, re-validate.

## Integration

- **Uses**: `@claude-mobile-ios-testing` for Gate 4A
- **Uses**: `@websocket-integration-testing` for Gate 3A
- **Triggers**: `@systematic-debugging` if failures occur
