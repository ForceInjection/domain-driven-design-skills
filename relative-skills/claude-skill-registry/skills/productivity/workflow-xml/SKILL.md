---
name: Workflow XML
description: This skill should be used when the user asks about "workflow XML", "planner", "agent dependencies", "workflow parsing", "task orchestration", or needs to understand the workflow system in XSky.
version: 1.0.0
---

# Workflow XML in XSky

This skill provides knowledge for the workflow planning and execution system.

## Workflow XML Format

```xml
<workflow name="Task Name" taskId="uuid">
  <agent name="browser" id="1">
    <task>Navigate and search</task>
  </agent>
  <agent name="llm" id="2" depends="1">
    <task>Analyze results</task>
    <input>{{agent_1_result}}</input>
  </agent>
</workflow>
```

## Agent Attributes

| Attribute | Required | Description |
|-----------|----------|-------------|
| `name` | Yes | Agent type (browser, llm, file, shell) |
| `id` | Yes | Unique ID for dependencies |
| `depends` | No | Comma-separated dependency IDs |

## Dependency Resolution

```
No depends → Runs immediately
Same depends → Runs in parallel
Sequential depends → Runs in order
```

Example:
```xml
<!-- Agent 1: No depends - runs first -->
<agent name="browser" id="1">...</agent>

<!-- Agent 2 & 3: Both depend on 1 - run in parallel -->
<agent name="llm" id="2" depends="1">...</agent>
<agent name="llm" id="3" depends="1">...</agent>

<!-- Agent 4: Depends on 2,3 - runs after both complete -->
<agent name="file" id="4" depends="2,3">...</agent>
```

## Variable References

```xml
<!-- Previous agent result -->
<input>{{agent_1_result}}</input>

<!-- Context variable -->
<input>{{variable_name}}</input>

<!-- User input -->
<input>{{context.user_input}}</input>
```

## Programmatic Workflow Creation

```typescript
import { buildSimpleAgentWorkflow } from "@xsky/ai-agent-core";

const workflow = buildSimpleAgentWorkflow({
  name: "My Workflow",
  agents: [
    { name: "browser", task: "Go to URL" },
    { name: "llm", task: "Analyze", dependsOnPrevious: true }
  ]
});
```

## Manual Execution

```typescript
const workflow: Workflow = {
  name: "Custom",
  taskId: uuidv4(),
  agents: [/* ... */]
};

const xsky = new XSky(config);
await xsky.initContext(workflow);
const result = await xsky.execute(workflow.taskId);
```

## Key Source Files

| File | Purpose |
|------|---------|
| `packages/ai-agent-core/src/core/plan.ts` | Planner implementation |
| `packages/ai-agent-core/src/common/xml.ts` | XML parsing utilities |
| `packages/ai-agent-core/src/types/core.types.ts` | Core types (Workflow) |
| `packages/ai-agent-core/src/prompt/plan.ts` | Planning prompts |
