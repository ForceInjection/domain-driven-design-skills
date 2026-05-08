---
name: websocket-integration-testing
description: Use when testing WebSocket servers, validating message protocols, executing Gate 3A, or tempted to use mocks - enforces functional testing with wscat and real filesystem operations, NO MOCKS allowed
---

# WebSocket Integration Testing - NO MOCKS

## Overview

Test WebSocket servers with functional testing: real connections, real filesystem, real protocol validation.

**Core principle:** NO MOCKS. Test actual behavior. Verify filesystem changes.

**Announce at start:** "I'm using the websocket-integration-testing skill for functional WebSocket testing."

**REQUIRED BACKGROUND**: @testing-anti-patterns (explains NO MOCKS principle)

## When to Use

- Testing WebSocket servers (Gate 3A)
- Validating message protocol compliance
- Testing tool execution through WebSocket
- Verifying session management
- Integration testing (Gates 6A-E)

## Quick Reference

| Test | Method | Verification |
|------|--------|--------------|
| Connection | wscat | Connection succeeds |
| init_session | wscat + JSON | session_initialized received |
| Message | wscat + JSON | content_delta received |
| Tool execution | wscat → file check | File ACTUALLY created on disk |
| Slash commands | wscat + JSON | Command response received |

## Core Workflow

### 1. Start Backend

```typescript
mcp__serena__execute_shell_command({
  command: "cd backend && npm start",
  cwd: "/Users/nick/Desktop/claude-mobile-expo"
});
```

### 2. Connect with wscat

```typescript
mcp__serena__execute_shell_command({
  command: "wscat -c 'ws://localhost:3001/ws'"
});
```

### 3. Send init_session

```json
{"type":"init_session","projectPath":"/tmp/test-project"}
```

**VERIFY**: session_initialized with UUID received

### 4. Test Tool Execution

```json
{"type":"message","message":"Create a test.txt file with 'Test content'"}
```

**VERIFY**:
- tool_execution message received ✅
- tool_result shows success ✅
- **File ACTUALLY created** (check filesystem) ✅

```typescript
// CRITICAL: Verify real file exists
mcp__serena__read_file({
  relative_path: "../../../tmp/test-project/test.txt"
});
// Must return: "Test content"
```

### 5. Test All Tools

For each tool, verify ACTUAL filesystem/git changes:
- write_file → File exists on disk ✅
- read_file → Content returned correctly ✅
- list_files → Directory listing matches actual files ✅
- execute_command → Command actually ran ✅
- git_status → Real git status ✅
- git_commit → Commit in git log ✅

### 6. Use Automation Script

```typescript
mcp__serena__execute_shell_command({
  command: "./scripts/test-websocket.sh ws://localhost:3001/ws /tmp/test-project"
});
```

Exit code 0 = all pass

## NO MOCKS Principle

### ❌ WRONG: Unit tests with mocks

```typescript
// DON'T do this:
jest.mock('ws');
const mockWs = {send: jest.fn(), on: jest.fn()};

jest.mock('fs');
fs.writeFileSync = jest.fn();
```

**Why wrong**: Testing mock behavior, not real system

### ✅ CORRECT: Functional testing

```typescript
// Real WebSocket connection
import WebSocket from 'ws';
const ws = new WebSocket('ws://localhost:3001/ws');

// Real file verification
import fs from 'fs';
const content = fs.readFileSync('/tmp/test-project/test.txt', 'utf8');
assert(content === 'Test content');
```

**Why correct**: Testing actual system behavior

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Unit tests with mocks are faster" | WRONG. They test mocks, not reality. |
| "Mocks are more reliable" | WRONG. Mocks pass when real code fails. |
| "Don't need all message types" | WRONG. Protocol compliance requires all. |
| "Integration tests are complex" | WRONG. wscat + file check is simple. |

## Red Flags

- "Mocks are sufficient" → WRONG. NO MOCKS.
- "Skip protocol tests" → WRONG. Test all message types.
- "Unit tests first" → WRONG. Functional tests only.

## Integration

- **Use FOR**: Validation Gate 3A
- **Use WITH**: `@claude-mobile-validation-gate`
- **Principle FROM**: `@testing-anti-patterns` (NO MOCKS)
