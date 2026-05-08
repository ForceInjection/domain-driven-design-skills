---
name: test-mcp-connector
description: |
  ONLY trigger this skill when the user EXPLICITLY asks for MCP-based testing:

  **Required triggers (ALL must mention "MCP" explicitly):**
  - "test connector with mcp"
  - "test mcp connector"
  - "test [provider] with mcp"
  - "use mcp to test [provider]"
  - "run mcp connector test"
  - "mcp test for [provider]"

  **DO NOT trigger for:**
  - Generic "test the connector" requests (use stackone run / test_actions instead)
  - "test [provider]" without explicit MCP mention
  - Regular validation or testing requests
  - Any testing that doesn't explicitly mention MCP

  This skill builds a REAL agent with Claude Agent SDK that sends natural language prompts to evaluate if action descriptions are agent-friendly. It's more intensive than regular testing and should only be used when explicitly requested.
---

# MCP Connector Testing

## Setup (REQUIRED - Collect ALL upfront)

| Required | Description |
|----------|-------------|
| **Account ID** | StackOne account ID (linked provider account) |
| **StackOne API Key** | StackOne API key (`credentials:read` scope) |
| **Anthropic API Key** | For the test agent (check `ANTHROPIC_API_KEY` env, ask if not set) |
| **Profile** | CLI profile for `stackone push` |
| **Provider** | Provider name (e.g., `datadog`, `intercom`) |

### ⛔ Account ID = Complete Authentication

**If the user provides an Account ID, you have EVERYTHING needed for authentication.**

The Account ID is a linked account where provider credentials (API keys, tokens, subdomains, secrets) are ALREADY stored in StackOne.

**When Account ID is provided, DO NOT ask for:**
- ❌ Provider API keys
- ❌ Provider tokens or secrets
- ❌ Any provider-specific credentials

**Authentication = Account ID + StackOne API Key. Nothing else needed.**

---

## Phase 1: Quick Connectivity Check (Optional)

```bash
# Test single action
stackone run src/configs/<provider>/<provider>.connector.s1.yaml \
  --account-id <ACCOUNT_ID> --action-id <key>_<action> --profile=<profile>

# Push after changes
stackone push src/configs/<provider>/<provider>.connector.s1.yaml --profile=<profile>
```

---

## Phase 2: Agent Simulation (PRIMARY)

### Core Principle

Test via **agent conversations**, not direct tool calls. The goal: can an agent understand action descriptions and use them correctly?

```typescript
// ❌ WRONG - bypasses agent understanding
await callMCPTool("provider_list_items", { path: {}, query: {} });

// ✅ CORRECT - agent decides what to call
await agent.chat("Show me all items in the system");
```

### Test Agent Setup

All test files: `test-agent/<provider>/` (gitignored)

```bash
mkdir -p test-agent/<provider> && cd test-agent/<provider>
npm init -y && npm install @anthropic-ai/claude-agent-sdk tsx
```

**Agent code:**
```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

const STACKONE_API_KEY = process.env.STACKONE_API_KEY;
const ACCOUNT_ID = process.env.ACCOUNT_ID;

async function testPrompt(prompt: string) {
  const toolCalls: any[] = [];
  let result: any;

  for await (const message of query({
    prompt,
    options: {
      model: "claude-haiku-4-5",
      mcpServers: {
        "stackone": {
          type: "http",
          url: "https://api.stackone.com/mcp",
          headers: {
            "Authorization": `Basic ${Buffer.from(`${STACKONE_API_KEY}:`).toString("base64")}`,
            "x-account-id": ACCOUNT_ID
          }
        }
      },
      allowedTools: ["mcp__stackone__*"]
    }
  })) {
    if (message.type === "assistant" && message.message?.content) {
      toolCalls.push(...message.message.content.filter((b: any) => b.type === "tool_use"));
    }
    if (message.type === "result" && message.subtype === "success") {
      result = message.result;
    }
  }
  return { prompt, toolCalls, result };
}
```

Run: `cd test-agent/<provider> && npx tsx test.ts`

### Testing Process

For **EACH action** in the connector:

1. **Generate realistic prompt** (natural language, no action names)
2. **Send to agent**, capture: tool called, params, interpretation
3. **Evaluate**: ✅ Right tool + params = PASS | ❌ Wrong = FAIL → fix

**Include multi-turn workflows:**
```
User: "Show me items in category X"     → list_items
User: "Get details on the first one"    → get_item (uses ID from previous)
User: "Update its status to active"     → update_item (same ID)
```

### Coverage Requirements

- **Test ALL actions** - if connector has 50 actions, test 50 actions
- Track progress: `[15/50] action_name... ✅ PASS`
- Include single-turn AND multi-turn tests
- Don't skip write operations

### Fix Loop

1. **Diagnose** failure (description unclear? missing param? wrong tool?)
2. **Fix** connector YAML
3. **Push**: `stackone push <path> --profile=<profile>`
4. **Retry** same prompt → verify fix
5. **Continue** to next action

---

## Output

```markdown
## Test Results: <provider> connector

### Summary
- Total actions: 50 | Tested: 50 (100%)
- Initial pass rate: 85% (42/50)
- Final pass rate: 100% (50/50)
- Fixes applied: 8

### Changes Made
| Action | Issue | Fix |
|--------|-------|-----|
| list_items | Agent confused with search | Added "primary listing endpoint" to description |
| create_item | Missing required field | Added `category_id` to required params |

### Issue Patterns
- Description clarity: 5 fixes
- Missing params: 2 fixes
- Naming conflicts: 1 fix

### Files Modified
- src/configs/<provider>/<provider>.connector.s1.yaml
```

**Required in report:** Total vs tested (must equal), before/after pass rates, every fix, files modified.
