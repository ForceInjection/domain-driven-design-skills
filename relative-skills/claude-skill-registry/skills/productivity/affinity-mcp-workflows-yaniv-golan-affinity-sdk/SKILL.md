---
name: affinity-mcp-workflows
description: Use when working with Affinity CRM via MCP tools - find entities, manage workflows, log interactions, prepare briefings, find warm intros. Also use when user mentions "pipeline", "deals", "relationship strength", or wants to prepare for meetings.
---

# Affinity MCP Workflows

This skill covers the xaffinity MCP server tools, prompts, and resources for working with Affinity CRM.

## Prerequisites

The MCP server requires the xaffinity CLI to be installed:

```bash
pip install "affinity-sdk[cli]"
```

The CLI must be configured with an API key before the MCP server will work.

## IMPORTANT: Write Operations Only After Explicit User Request

**Only use tools or prompts that modify CRM data when the user explicitly asks to do so.**

Write operations include:
- **Tools**: `set-workflow-status`, `update-workflow-fields`, `add-note`, `log-interaction`, `execute-write-command`
- **Prompts**: `log-interaction-and-update-workflow`, `change-status`, `log-call`, `log-message`

Read-only operations (search, lookup, briefings) can be used proactively to help the user. But never create, update, or delete CRM records unless the user specifically requests it.

## Available Tools

### Search & Lookup (read-only)

| Tool | Use Case |
|------|----------|
| `find-entities` | Search persons, companies, opportunities by name/email |
| `find-lists` | Find Affinity lists by name |
| `get-entity-dossier` | Comprehensive entity info (details, relationship strength, interactions, notes, list memberships) |
| `read-xaffinity-resource` | Access dynamic resources via `xaffinity://` URIs |

### Workflow Management

| Tool | Use Case |
|------|----------|
| `get-list-workflow-config` | Get workflow config (statuses, fields) for a list |
| `get-workflow-view` | Get items from a saved workflow view |
| `resolve-workflow-item` | Resolve entity to list entry ID (needed before status updates) |
| `set-workflow-status` | **(write)** Update workflow item status - requires explicit user request |
| `update-workflow-fields` | **(write)** Update multiple fields on workflow item - requires explicit user request |

### Relationships & Intelligence

| Tool | Use Case |
|------|----------|
| `get-relationship-insights` | Relationship strength scores, warm intro paths via shared connections |
| `get-status-timeline` | Status change history for a workflow item |
| `get-interactions` | Interaction history (calls, meetings, emails) for an entity |

### Logging (write operations - require explicit user request)

| Tool | Use Case |
|------|----------|
| `add-note` | **(write)** Add note to a person, company, or opportunity |
| `log-interaction` | **(write)** Log call, meeting, email, or chat message |

### CLI Gateway (full CLI access)

For operations not covered by specialized tools, use the CLI Gateway:

| Tool | Use Case |
|------|----------|
| `discover-commands` | Search CLI commands by keyword (e.g., "create person", "export list") |
| `execute-read-command` | Execute read-only CLI commands (get, search, list, export) |
| `execute-write-command` | **(write)** Execute write CLI commands (create, update, delete) |

**Usage pattern:**

1. **Discover** the right command: `discover-commands(query: "create person", category: "write")`
2. **Execute** it: `execute-write-command(command: "person create", argv: ["--first-name", "John", "--last-name", "Doe"])`

**Destructive commands** (delete operations) require double confirmation:

1. **Look up the entity first** using `execute-read-command` to show what will be deleted
2. **Ask the user in your response** by showing them the entity details and requesting confirmation
3. **Wait for user's next message** - do NOT proceed until they explicitly confirm
4. **Only after user confirms** should you execute with `confirm: true`

Example flow:
```
User: "Delete person 123"
You: execute-read-command(command: "person get", argv: ["123"])
You: "This will permanently delete John Smith (ID: 123, email: john@example.com).
      Type 'yes' to confirm deletion."
[Stop here and wait for user's response]

User: "yes"
You: execute-write-command(command: "person delete", argv: ["123"], confirm: true)
```

**Note**: This is conversation-based confirmation - you ask, then wait for the user's next message. This works with all MCP clients regardless of elicitation support. The `confirm: true` parameter bypasses the CLI prompt, but you must get explicit user confirmation in the conversation first.

## MCP Prompts (Guided Workflows)

These prompts provide guided multi-step workflows. Suggest them when appropriate.

**Note**: Prompts marked with (write) modify CRM data - only use when user explicitly requests.

| Prompt | Type | When to Suggest |
|--------|------|-----------------|
| `prepare-briefing` | read-only | User has upcoming meeting, needs context on a person/company |
| `pipeline-review` | read-only | User wants weekly/monthly pipeline review |
| `warm-intro` | read-only | User wants to find introduction path to someone |
| `interaction-brief` | read-only | Get interaction history summary for an entity |
| `log-interaction-and-update-workflow` | **write** | User explicitly asks to log a call/meeting and update pipeline |
| `change-status` | **write** | User explicitly asks to move a deal to new stage |
| `log-call` | **write** | User explicitly asks to log a phone call |
| `log-message` | **write** | User explicitly asks to log a chat/text message |

### How to Invoke Prompts

Prompts are invoked with arguments. Example:
- `prepare-briefing(entityName: "John Smith", meetingType: "demo")`
- `warm-intro(targetName: "Jane Doe", context: "partnership discussion")`
- `log-interaction-and-update-workflow(personName: "Alice", interactionType: "call", summary: "Discussed pricing")`

## Resources

Access dynamic data via `xaffinity://` URIs using `read-xaffinity-resource`:

| URI | Returns |
|-----|---------|
| `xaffinity://me` | Current authenticated user details |
| `xaffinity://me/person-id` | Current user's person ID in Affinity |
| `xaffinity://interaction-enums` | Valid interaction types and directions |
| `xaffinity://saved-views/{listId}` | Saved views available for a list |
| `xaffinity://field-catalogs/{listId}` | Field definitions for a list |
| `xaffinity://workflow-config/{listId}` | Workflow configuration for a list |

## Common Workflow Patterns

### Before a Meeting
1. `find-entities` to locate the person/company
2. `get-entity-dossier` for full context (relationship strength, recent interactions, notes)
3. **Or use**: `prepare-briefing` prompt for a guided flow

### After a Call/Meeting
1. `log-interaction` to record what happened
2. `resolve-workflow-item` to get list entry ID (if updating pipeline)
3. `set-workflow-status` if deal stage changed
4. **Or use**: `log-interaction-and-update-workflow` prompt

### Finding Warm Introductions
1. `find-entities` to locate target person
2. `get-relationship-insights` for connection paths
3. **Or use**: `warm-intro` prompt for guided flow

### Pipeline Review
1. `find-lists` to locate the pipeline list
2. `get-workflow-view` to see items in a saved view
3. **Or use**: `pipeline-review` prompt

### Updating Deal Status
1. `find-entities` to find the opportunity
2. `resolve-workflow-item` to get list entry ID
3. `get-list-workflow-config` to see available statuses
4. `set-workflow-status` to update
5. **Or use**: `change-status` prompt

## Tips

- **Entity types**: `person`, `company`, `opportunity`
- **Interaction types**: `call`, `meeting`, `email`, `chat_message`, `in_person`
- **Dossier is comprehensive**: `get-entity-dossier` returns relationship strength, interactions, notes, and list memberships in one call
- **Resolve before update**: Always use `resolve-workflow-item` before `set-workflow-status` or `update-workflow-fields`
- **Check workflow config**: Use `get-list-workflow-config` to discover valid status options before updating
