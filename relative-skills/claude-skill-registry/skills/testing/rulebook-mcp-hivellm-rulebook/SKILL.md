---
name: rulebook-mcp
description: MCP server integration for programmatic task and skill management. Use when managing tasks via MCP protocol, enabling/disabling skills programmatically, or integrating Rulebook with AI assistants through Model Context Protocol.
version: "1.0.0"
category: core
author: "HiveLLM"
tags: ["mcp", "model-context-protocol", "server", "integration"]
dependencies: []
conflicts: []
---

# Rulebook MCP Server

## Setup

```bash
rulebook mcp init
```

## Starting the Server

```bash
rulebook-mcp
```

## Task Management Functions

```typescript
// Create task
await mcp.rulebook_task_create({ taskId: "my-task" });

// List tasks
await mcp.rulebook_task_list({});

// Show task
await mcp.rulebook_task_show({ taskId: "my-task" });

// Update task file
await mcp.rulebook_task_update({
  taskId: "my-task",
  file: "tasks.md",
  content: "## Tasks\n- [ ] Item 1"
});

// Validate task
await mcp.rulebook_task_validate({ taskId: "my-task" });

// Archive task
await mcp.rulebook_task_archive({ taskId: "my-task" });

// Delete task
await mcp.rulebook_task_delete({ taskId: "my-task" });
```

## Skill Management Functions

```typescript
// List skills
await mcp.rulebook_skill_list({});

// Show skill
await mcp.rulebook_skill_show({ skillId: "languages/typescript" });

// Enable skill
await mcp.rulebook_skill_enable({ skillId: "languages/typescript" });

// Disable skill
await mcp.rulebook_skill_disable({ skillId: "languages/typescript" });

// Search skills
await mcp.rulebook_skill_search({ query: "typescript" });

// Validate skills
await mcp.rulebook_skill_validate({});
```

## MCP Configuration

For Cursor (`.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "rulebook": {
      "command": "rulebook-mcp",
      "args": [],
      "env": {}
    }
  }
}
```
