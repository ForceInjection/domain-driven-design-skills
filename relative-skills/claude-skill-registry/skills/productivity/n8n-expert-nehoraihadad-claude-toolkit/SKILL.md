---
name: n8n-expert
description: Expert guidance for n8n workflow automation using REST API and CLI. Use when creating, updating, debugging, or managing n8n workflows. Provides efficient alternatives to MCP server with direct API calls and scripts. Covers workflow patterns, node configuration, API endpoints, CLI commands, and debugging strategies. Activate for any n8n-related task.
---

# n8n Expert

Comprehensive guidance for efficient n8n workflow automation. This skill provides direct REST API and CLI approaches that are significantly more token-efficient than the MCP server.

## When to Use This Skill

Use this skill when:
- Creating new n8n workflows
- Updating existing workflows (nodes, connections, settings)
- Running and testing workflows
- Debugging failed executions
- Managing workflow lifecycle (activate/deactivate)
- Working with n8n API or CLI
- Optimizing workflow performance

## Approach Selection Guide

Choose the right approach based on your task:

| Task | Recommended Approach | Why |
|------|---------------------|-----|
| Quick workflow list | `scripts/quick-actions.sh` | One command, minimal output |
| Create workflow | REST API + template | Full control, JSON-based |
| Update workflow | REST API | Direct PUT request |
| Debug execution | `scripts/execution-manager.py` | Detailed logs and data |
| Bulk operations | Python scripts | Iteration support |
| Complex workflows | Templates + API | Structured starting point |

## Quick Reference

### Environment Setup

Ensure these environment variables are set:
```bash
export N8N_API_URL="http://localhost:5678"  # Your n8n instance
export N8N_API_KEY="your-api-key"           # From n8n Settings > API
```

### Most Common Operations

**List all workflows:**
```bash
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_API_URL/api/v1/workflows" | jq '.data[] | {id, name, active}'
```

**Get specific workflow:**
```bash
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_API_URL/api/v1/workflows/{id}"
```

**Activate workflow:**
```bash
curl -s -X POST -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_API_URL/api/v1/workflows/{id}/activate"
```

**Trigger webhook workflow:**
```bash
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' "$N8N_API_URL/webhook/{path}"
```

**List recent executions:**
```bash
curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "$N8N_API_URL/api/v1/executions?limit=10" | jq '.data[] | {id, workflowId, status, startedAt}'
```

## Decision Tree: When to Use MCP vs Direct API

```
Need to work with n8n?
├── Simple query (list, get, status)?
│   └── Use: Direct API call or quick-actions.sh
├── Create/Update workflow?
│   ├── From scratch?
│   │   └── Use: Template + REST API
│   └── Modify existing?
│       └── Use: GET → modify JSON → PUT
├── Debug execution?
│   └── Use: execution-manager.py
├── Complex node discovery?
│   └── Use: MCP search_nodes (only case for MCP)
└── Bulk operations?
    └── Use: Python scripts
```

## Available Scripts

Execute from: `~/.claude/skills/n8n-expert/scripts/`

### n8n-api.sh - Bash API Wrapper
```bash
./n8n-api.sh list-workflows         # List all workflows
./n8n-api.sh get-workflow <id>      # Get workflow JSON
./n8n-api.sh create-workflow <file> # Create from JSON
./n8n-api.sh update-workflow <id> <file>
./n8n-api.sh activate <id>
./n8n-api.sh deactivate <id>
./n8n-api.sh list-executions [workflow-id]
./n8n-api.sh get-execution <id>
./n8n-api.sh trigger <webhook-path> [json-data]
```

### workflow-crud.py - Python CRUD Operations
```bash
python workflow-crud.py list
python workflow-crud.py get <id>
python workflow-crud.py create <file.json>
python workflow-crud.py update <id> <file.json>
python workflow-crud.py delete <id>
python workflow-crud.py activate <id>
python workflow-crud.py deactivate <id>
python workflow-crud.py export <id> [output.json]
```

### execution-manager.py - Debug Executions
```bash
python execution-manager.py list [--status error] [--workflow-id <id>]
python execution-manager.py get <execution-id>
python execution-manager.py debug <execution-id>  # Detailed node-by-node output
python execution-manager.py errors [--limit 10]   # Recent failed executions
```

### quick-actions.sh - One-Liners
Source this file to get shortcuts:
```bash
source ~/.claude/skills/n8n-expert/scripts/quick-actions.sh
n8n-list          # List workflows (compact)
n8n-active        # List active workflows only
n8n-errors        # Recent failed executions
n8n-trigger PATH  # Trigger webhook
```

## Available Templates

Located in: `~/.claude/skills/n8n-expert/templates/`

### Workflow Templates
- `workflow-webhook.json` - Webhook trigger base template
- `workflow-schedule.json` - Cron schedule trigger template
- `workflow-manual.json` - Manual trigger template

### Node Configuration Templates
- `node-configs/http-request.json` - HTTP Request node patterns
- `node-configs/code-node.json` - Code node (JS/Python) patterns
- `node-configs/if-node.json` - IF node conditional patterns

## Reference Documentation

Detailed documentation in `references/`:

- **rest-api-guide.md** - Complete REST API reference with all endpoints
- **cli-commands.md** - CLI commands for self-hosted instances
- **workflow-patterns.md** - Common workflow structures and patterns
- **node-configuration.md** - Node configuration best practices
- **debugging-guide.md** - Troubleshooting and debug strategies

## Workflow Structure Overview

n8n workflows are JSON objects with this structure:
```json
{
  "name": "Workflow Name",
  "nodes": [
    {
      "id": "unique-id",
      "name": "Node Name",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": { /* node-specific config */ }
    }
  ],
  "connections": {
    "source-node-id": {
      "main": [[{"node": "target-node-id", "type": "main", "index": 0}]]
    }
  },
  "settings": {
    "executionOrder": "v1"
  }
}
```

## Common Node Types

| Node Type | Purpose | Package |
|-----------|---------|---------|
| `webhook` | HTTP trigger | n8n-nodes-base |
| `scheduleTrigger` | Cron/interval trigger | n8n-nodes-base |
| `httpRequest` | Make HTTP calls | n8n-nodes-base |
| `code` | JavaScript/Python code | n8n-nodes-base |
| `if` | Conditional branching | n8n-nodes-base |
| `set` | Set/modify data | n8n-nodes-base |
| `merge` | Merge data streams | n8n-nodes-base |
| `splitInBatches` | Process items in batches | n8n-nodes-base |

## Error Handling Pattern

For robust workflows, implement error handling:
```json
{
  "nodes": [
    {
      "name": "Main Node",
      "onError": "continueErrorOutput"
    },
    {
      "name": "Error Handler",
      "type": "n8n-nodes-base.set"
    }
  ],
  "connections": {
    "Main Node": {
      "main": [[/* success path */]],
      "error": [[{"node": "Error Handler", "type": "main", "index": 0}]]
    }
  }
}
```

## Token Efficiency Comparison

| Operation | MCP Server | Direct API/Script |
|-----------|------------|-------------------|
| List workflows | ~1500 tokens | ~50 tokens |
| Get workflow | ~2000 tokens | ~100 tokens |
| Create workflow | ~3000 tokens | ~200 tokens |
| Debug execution | ~2500 tokens | ~150 tokens |
| **Typical savings** | - | **90-95%** |

## Best Practices

1. **Always use templates** for new workflows - modify rather than build from scratch
2. **Use scripts for repetitive operations** - they handle auth and formatting
3. **Check executions API for debugging** - faster than UI for error details
4. **Export workflows to JSON** before major changes - easy rollback
5. **Use jq for JSON manipulation** - powerful filtering and transformation

## When MCP is Still Useful

Use MCP server only for:
- **Node discovery** - `search_nodes` for finding unfamiliar nodes
- **Node schema lookup** - `get_node` for complex node configuration
- **Template search** - `search_templates` for workflow examples
- **Validation** - `validate_workflow` before deployment

For everything else, direct API/scripts are more efficient.

---

See `references/` for detailed documentation on each topic.
