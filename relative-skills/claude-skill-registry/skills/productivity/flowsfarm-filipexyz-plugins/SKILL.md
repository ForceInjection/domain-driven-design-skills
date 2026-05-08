---
name: flowsfarm
description: Manage n8n workflows with FlowsFarm CLI. Use when user wants to sync, create, edit, or manage n8n workflows locally. Triggers for n8n automation tasks, workflow version control, or multi-instance workflow management.
---

# FlowsFarm CLI

Local-first n8n workflow synchronization. Requires `bun` runtime.

## Setup

```bash
# Install
bun install -g flowsfarm

# Initialize in project
flowsfarm init

# Add n8n connection (requires API key from n8n settings)
flowsfarm connect add -n <name> -u <url> -k <api-key>
```

## Core Commands

| Command | Description |
|---------|-------------|
| `flowsfarm pull` | Download workflows from n8n |
| `flowsfarm push` | Upload local changes to n8n |
| `flowsfarm status` | Show sync status |
| `flowsfarm diff` | Show differences |
| `flowsfarm list` | List workflows |
| `flowsfarm list --json` | List as JSON |
| `flowsfarm show <name>` | Show workflow details |
| `flowsfarm show <name> --json` | Full workflow JSON |
| `flowsfarm create <name>` | Create empty workflow |
| `flowsfarm create <name> -t <template>` | Create from template |

## File Structure

```
.flowsfarm/
├── flowsfarm.db              # SQLite metadata
├── workflows/<conn>/<id>/
│   └── workflow.json         # Editable workflow
└── templates/*.json          # Reusable templates
```

## Workflow JSON

```json
{
  "name": "Workflow Name",
  "active": false,
  "nodes": [
    {
      "name": "HTTP Request",
      "type": "n8n-nodes-base.httpRequest",
      "position": [250, 300],
      "parameters": {
        "url": "https://api.example.com",
        "method": "GET"
      }
    }
  ],
  "connections": {
    "Trigger": {
      "main": [[{ "node": "HTTP Request", "type": "main", "index": 0 }]]
    }
  }
}
```

## Common Node Types

| Type | Purpose |
|------|---------|
| `n8n-nodes-base.webhook` | HTTP trigger |
| `n8n-nodes-base.schedule` | Cron trigger |
| `n8n-nodes-base.httpRequest` | API calls |
| `n8n-nodes-base.code` | JavaScript/Python |
| `n8n-nodes-base.if` | Conditional |
| `n8n-nodes-base.switch` | Multi-condition |
| `n8n-nodes-base.set` | Transform data |
| `n8n-nodes-base.merge` | Combine streams |

## Templates

```bash
# Save workflow as template
flowsfarm templates save "My Workflow" -n my-template

# List templates
flowsfarm templates

# Create from template
flowsfarm create "New Workflow" -t my-template
```

## Sync Workflow

1. `flowsfarm pull` - Get latest from n8n
2. Edit `.flowsfarm/workflows/.../workflow.json`
3. `flowsfarm push` - Upload changes

Use `--force` to overwrite on conflicts.
