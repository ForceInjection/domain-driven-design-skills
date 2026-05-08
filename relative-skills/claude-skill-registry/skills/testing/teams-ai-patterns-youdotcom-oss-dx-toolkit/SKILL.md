---
name: teams-ai-patterns
description: Microsoft Teams.ai integration patterns for dx-toolkit - Memory API, Anthropic SDK, MCP client setup
---

# Teams.ai Integration Patterns

Package-specific patterns for `@youdotcom-oss/teams-anthropic`. Use these patterns when developing Teams.ai applications with Anthropic Claude.

---

## Teams.ai Memory API

Always use `push()` and `values()`, NEVER `addMessage()` or `getMessages()`

```ts
// ✅ Correct - Teams.ai memory API
const memory = options?.messages || new LocalMemory();
await memory.push(input);
const messages = await memory.values();

// ❌ Wrong - these methods don't exist
await memory.addMessage(input);
const messages = await memory.getMessages();
```

**Why this pattern?**
- Teams.ai Memory interface uses `push()` and `values()` methods
- `addMessage()` and `getMessages()` are not part of the IMemory interface
- Type errors will occur if incorrect methods are used

## FunctionMessage Structure

ALWAYS include `function_id` property in FunctionMessage

```ts
// ✅ Correct - includes function_id
const fnResult: Message = {
  role: 'function',
  function_id: fnCall.id || fnCall.name,
  content: typeof result === 'string' ? result : JSON.stringify(result),
};

// ❌ Wrong - missing function_id (will fail)
const fnResult: Message = {
  role: 'function',
  content: result,
};
```

**Why this pattern?**
- Teams.ai requires `function_id` to match function calls with results
- Missing `function_id` causes runtime errors
- Use `fnCall.id` or fall back to `fnCall.name`

## Function Handler Access

NEVER call function definition directly, always access handler property

```ts
// ✅ Correct - access handler property
const fnDef = options.functions[fnCall.name];
if (fnDef && typeof fnDef === 'object' && 'handler' in fnDef) {
  const handler = (fnDef as { handler: (args: unknown) => Promise<unknown> }).handler;
  const result = await handler(fnCall.arguments);
}

// ❌ Wrong - Function type has no call signatures
const fn = options.functions[fnCall.name];
const result = await fn(fnCall.arguments);
```

**Why this pattern?**
- TypeScript Function type has no call signatures
- Functions in Teams.ai are objects with handler property
- Direct invocation causes "Type 'Function' has no call signatures" error

## Anthropic Streaming

Use `messages.stream()` method, NEVER `messages.create()` with stream parameter

```ts
// ✅ Correct - use stream() method
const stream = this._anthropic.messages.stream({
  ...requestParams,
  stream: true,
});

for await (const event of stream) {
  if (event.type === 'content_block_delta') {
    if (event.delta.type === 'text_delta') {
      const delta = event.delta.text;
      textParts.push(delta);
      if (options.onChunk) {
        await options.onChunk(delta);
      }
    }
  }
}

// ❌ Wrong - type errors with create() + stream parameter
requestParams.stream = true;
const stream = await this._anthropic.messages.create(requestParams);
```

**Why this pattern?**
- `messages.create()` returns MessageResponse, not Stream
- `messages.stream()` returns proper streaming interface
- Attempting to add stream parameter causes type errors

## Anthropic System Messages

Extract system messages separately, Anthropic requires them as separate parameter

```ts
// ✅ Correct - system as separate parameter
const systemMessage = extractSystemMessage(conversationMessages);
if (systemMessage) {
  requestParams.system = systemMessage;
}

// ❌ Wrong - system messages in conversation array
const anthropicMessages = transformToAnthropicMessages([
  { role: 'system', content: 'You are helpful' },
  { role: 'user', content: 'Hello' },
]);
```

**Why this pattern?**
- Anthropic API requires system messages as separate `system` parameter
- System messages in conversation array will be rejected
- Use `extractSystemMessage()` utility to separate them

## Anthropic Content Block Type Assertions

Always use explicit type assertions for content blocks

```ts
// ✅ Correct - explicit type assertions
for (const block of response.content) {
  if (block.type === 'text') {
    const textBlock = block as Anthropic.TextBlock;
    textParts.push(textBlock.text);
  } else if (block.type === 'tool_use') {
    const toolBlock = block as Anthropic.ToolUseBlock;
    toolUses.push({ id: toolBlock.id, name: toolBlock.name, input: toolBlock.input });
  }
}

// ❌ Wrong - missing citations property error
for (const block of response.content) {
  if (block.type === 'text') {
    textParts.push(block.text);
  }
}
```

**Why this pattern?**
- Anthropic ContentBlock is union type (TextBlock | ToolUseBlock | etc.)
- TypeScript can't narrow union without explicit assertion
- Accessing properties directly causes "missing citations property" errors

## MCP Client Integration

Use `getYouMcpConfig()` utility for automatic MCP configuration

```ts
// ✅ Correct - automatic configuration
const prompt = new ChatPrompt(
  {
    instructions,
    model: new AnthropicChatModel({
      model: AnthropicModel.CLAUDE_SONNET_4_5,
      apiKey: process.env.ANTHROPIC_API_KEY,
    }),
  },
  [new McpClientPlugin({ logger })]
).usePlugin(
  'mcpClient',
  getYouMcpConfig({
    // apiKey: 'custom-key', // Optional: falls back to YDC_API_KEY env var
  })
);

// ❌ Wrong - manual configuration (error-prone)
.usePlugin('mcpClient', {
  url: 'https://api.you.com/mcp',
  authentication: { bearerToken: process.env.YDC_API_KEY },
});
```

**Why this pattern?**
- `getYouMcpConfig()` automatically configures URL and authentication
- Includes proper User-Agent with package version
- Falls back to YDC_API_KEY environment variable
- Reduces configuration errors

## Template Integration

**For NEW Teams apps**: Use entire template from `@youdotcom-oss/teams-anthropic/templates/mcp-client.ts`

**For EXISTING Teams apps**: Follow inline markers in template:
- `// ← EXISTING APP: SKIP THIS LINE` - Skip for existing apps
- `// ← EXISTING APP: START HERE` - Start copying here
- `// ← EXISTING APP: SKIP THIS ENTIRE SECTION` - Skip section

**Required sections for existing apps**:
1. Imports (lines 21-28) - Skip App import
2. Environment validation (lines 34-44)
3. ChatPrompt setup (lines 55-72) - Core integration
4. Skip app setup section (lines 80-91) - Use your existing app structure

## Related Resources

- Package documentation: `packages/teams-anthropic/AGENTS.md`
- MCP template: `packages/teams-anthropic/templates/mcp-client.ts`
- Plugin command: `plugins/teams-anthropic-integration/commands/generate-teams-app.md`
- Universal patterns: `.claude/skills/code-patterns`
