---
name: agent-spec-generator
description: "Design and generate Glean Agent specifications. Use when creating new agents, speccing out agent requirements, or generating JSON for Agent Builder import. Triggers on: 'create an agent', 'design an agent', 'agent spec', 'build an agent for [use case]'."
---

# Agent Spec Generator

Generate complete, importable specifications for Glean Agent Builder.

## What This Skill Does

1. **Interview** — Gather requirements through structured questions
2. **Design** — Map requirements to agent architecture (steps, tools, fields)
3. **Generate** — Output valid JSON matching Glean's export schema
4. **Document** — Create human-readable markdown spec

---

## Quick Start

When the user asks to create an agent, follow this flow:

### Phase 1: Discovery

Ask these questions to understand the agent (use the `AskUserQuestion` tool to guide the user):

```markdown
1. **Purpose**: What problem does this agent solve? What task does it complete?
2. **Audience**: Who will use this agent? (Role, department)
3. **Trigger**: How should it start? (Manual form, scheduled, Slack command, webhook)
4. **Inputs**: What information does the user provide? (Text fields, dates, file uploads, entity selections)
5. **Data Sources**: What does the agent need to read? (Gong, Slack, Email, Salesforce, specific docs)
6. **Process**: What steps should it take? Walk me through the workflow.
7. **Output**: What should the final response look like? (Report, summary, table, action taken)
8. **Actions**: Should it take actions? (Send Slack DM, create Jira ticket, draft email)
```

### Phase 2: Architecture

Map requirements to agent structure:

1. **Decompose into steps** — Each distinct operation becomes a step
2. **Identify dependencies** — Which steps need output from previous steps?
3. **Select tools** — Match each step to the right tool (see Tools Catalog)
4. **Define fields** — Map inputs to field types
5. **Configure triggers** — Set up the trigger type

### Phase 3: Generate

Output two artifacts:

1. **JSON Specification** — Valid `rootWorkflow` object for import
2. **Markdown Documentation** — Human-readable spec for review

---

## JSON Schema Reference

See `references/schema.md` for the complete schema.

### Minimal Agent Structure

```json
{
  "rootWorkflow": {
    "name": "Agent Name",
    "description": "What this agent does",
    "icon": {
      "backgroundColor": "var(--theme-brand-light-blue-50)",
      "color": "#333",
      "iconType": "GLYPH",
      "name": "rocket-2"
    },
    "schema": {
      "goal": "High-level objective",
      "steps": [],
      "fields": [],
      "modelOptions": {
        "llmConfig": {
          "provider": "OPEN_AI",
          "model": "GPT41_20250414"
        }
      },
      "trigger": {
        "type": "INPUT_FORM",
        "config": {
          "inputForm": {
            "scheduleConfig": {}
          }
        }
      }
    }
  }
}
```

### Step Types

| Type | When to Use | Key Config |
|------|-------------|------------|
| `TOOL` | Execute a single tool or action | `toolConfig[]` |
| `AGENT` | Call another agent as a sub-workflow | `runAgentConfig`, agent ID |
| `BRANCH` | Conditional logic (if/else) | `branchConfig: { branches[], default }` |
| `LOOP` | Iterate over a collection | `loopConfig: { inputStepDependency }` |
| `PARALLEL` | Multiple tools in one step | Multiple `toolConfig` entries |

### Step Template

```json
{
  "id": "unique-step-id",
  "instructionTemplate": "Prompt with [[variable]] or [[previous-step-id]] references",
  "type": "TOOL",
  "stepDependencies": ["previous-step-id"],
  "toolConfig": [
    {
      "id": "Tool Name",
      "respondConfig": { "temperature": "FACTUAL" }
    }
  ],
  "modelOptions": {
    "llmConfig": {
      "provider": "VERTEX_AI",
      "model": "GEMINI_3_0"
    }
  },
  "memoryConfig": "ALL_DEPENDENCIES"
}
```

### Field Types

| Type | JSON | Use Case |
|------|------|----------|
| Text | `{ "type": "TEXT" }` | Freeform input |
| Select | `{ "type": "SELECT" }` + `options[]` | Dropdown |
| Multi-Select | `{ "type": "MULTI_SELECT" }` | Multiple choices |
| Number | `{ "type": "NUMBER" }` | Numeric input |
| Date | `{ "type": "DATE" }` | Date picker |
| Boolean | `{ "type": "BOOLEAN" }` | Toggle |
| File | `{ "type": "FILE" }` | File upload |
| Entity | `{ "type": "ENTITY" }` | Person/Team autocomplete |

### Field Template

```json
{
  "name": "field_name",
  "displayName": "Display Name",
  "description": "Help text for the user",
  "defaultValue": "optional default",
  "type": { "type": "TEXT" },
  "options": [
    { "value": "option1", "label": "Option 1" }
  ]
}
```

### Trigger Types

| Type | Config | Use Case |
|------|--------|----------|
| `INPUT_FORM` | `scheduleConfig: {}` | Manual form submission |
| `INPUT_FORM` + schedule | `scheduleConfig: { enabled: true }` | Scheduled execution |
| `WEBHOOK` | Webhook endpoint | External HTTP trigger |
| `SLACK_COMMAND` | Slash command config | Slack integration |
| `CONTENT_TRIGGER` | Content filters | Document change detection |

---

## Variable Syntax

Glean uses `[[variable]]` syntax for references:

- **Input fields**: `[[field_name]]` — References a form input
- **Step outputs**: `[[step-id]]` — References output from a previous step
- **Chaining**: Steps can read from multiple previous steps

Example:
```
instructionTemplate: "Search for [[Account Name]] in [[previous-step-id]] and summarize"
```

---

## Tools Catalog

See `references/tools-catalog.md` for the complete list.

### Core Tools

| Tool ID | Config Key | Purpose |
|---------|------------|---------|
| `Glean Search` | `gleanSearchConfig` | Enterprise search across all apps |
| `Glean Document Reader` | `documentReaderConfig` | Read specific documents |
| `Respond` | `respondConfig` | Generate final output |
| `Think` | `thinkConfig` | Intermediate reasoning (no visible output) |
| `Data Analysis` | — | Process structured data |

### Glean Search Config

```json
{
  "id": "Glean Search",
  "inputTemplate": [
    { "template": "[[Account]] app:gong" }
  ],
  "gleanSearchConfig": {
    "numResults": 30,
    "enableFullDocumentSnippets": true
  }
}
```

### Respond Config

```json
{
  "id": "Respond",
  "respondConfig": {
    "temperature": "FACTUAL"
  }
}
```

### Action Examples

```json
// Slack DM
{ "name": "slackdirectmessageuser" }

// Create Google Doc
{ "name": "creategdoc" }

// Draft Gmail
{ "name": "googledraftemail" }

// Web Search
{ "name": "googlegeminiwebsearch" }
```

---

## Common Patterns

### Pattern 1: Search → Synthesize

Most common pattern. Search for context, then respond.

```json
{
  "steps": [
    {
      "id": "search",
      "type": "TOOL",
      "toolConfig": [
        { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account]] app:gong" }] },
        { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account]] app:slack" }] },
        { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account]] app:salescloud" }] }
      ],
      "memoryConfig": "ALL_DEPENDENCIES"
    },
    {
      "id": "respond",
      "instructionTemplate": "Based on the context, provide a comprehensive summary...",
      "type": "TOOL",
      "stepDependencies": ["search"],
      "toolConfig": [{ "id": "Respond", "respondConfig": { "temperature": "FACTUAL" } }],
      "memoryConfig": "ALL_DEPENDENCIES"
    }
  ]
}
```

### Pattern 2: Read Documents → Process → Output

Read specific files, process data, generate output.

```json
{
  "steps": [
    {
      "id": "read-data",
      "instructionTemplate": "READ [[Data File]]",
      "type": "TOOL",
      "toolConfig": [{ "id": "Glean Document Reader", "documentReaderConfig": {} }]
    },
    {
      "id": "analyze",
      "instructionTemplate": "Analyze the data...",
      "type": "TOOL",
      "stepDependencies": ["read-data"],
      "toolConfig": [{ "name": "Data Analysis" }],
      "modelOptions": { "llmConfig": { "provider": "VERTEX_AI", "model": "GEMINI_3_0" } }
    },
    {
      "id": "respond",
      "instructionTemplate": "Format the analysis as a report...",
      "type": "TOOL",
      "stepDependencies": ["analyze"],
      "toolConfig": [{ "id": "Respond" }]
    }
  ]
}
```

### Pattern 3: Agent Orchestration

Call another agent as a step.

```json
{
  "id": "run-sub-agent",
  "type": "AGENT",
  "toolConfig": [
    {
      "id": "agent-uuid-here",
      "name": "agent-uuid-here",
      "inputTemplate": [
        { "template": "[[Prospect]]", "name": "Prospect" }
      ],
      "runAgentConfig": {}
    }
  ],
  "memoryConfig": "ALL_DEPENDENCIES"
}
```

### Pattern 4: Conditional Branching

Execute different paths based on conditions.

```json
{
  "id": "branch-step",
  "type": "BRANCH",
  "branchConfig": {
    "branches": [
      {
        "condition": {
          "boolFunction": {
            "id": "Think",
            "inputTemplate": [{ "template": "[[field]] is \"yes\"" }]
          }
        },
        "stepId": "path-a"
      }
    ],
    "default": { "stepId": "path-b" }
  }
}
```

### Pattern 5: Respond + Take Action

Generate response AND perform an action (e.g., Slack DM).

```json
{
  "steps": [
    {
      "id": "generate-report",
      "instructionTemplate": "Generate the daily report...",
      "type": "TOOL",
      "toolConfig": [{ "id": "Respond" }]
    },
    {
      "id": "send-slack",
      "instructionTemplate": "Send me a Slack DM with [[generate-report]]",
      "type": "TOOL",
      "stepDependencies": ["generate-report"],
      "toolConfig": [{ "name": "slackdirectmessageuser", "customisationData": { "skipUserInteraction": true } }]
    }
  ]
}
```

---

## Model Options

### Available Models

| Provider | Model | Best For |
|----------|-------|----------|
| `OPEN_AI` | `GPT41_20250414` | General purpose, strong reasoning |
| `VERTEX_AI` | `GEMINI_3_0` | Data analysis, long context |

### Per-Step Model Override

```json
{
  "modelOptions": {
    "llmConfig": {
      "provider": "VERTEX_AI",
      "model": "GEMINI_3_0"
    }
  }
}
```

---

## Memory Config

Controls how much context a step receives:

| Value | Behavior |
|-------|----------|
| `ALL_DEPENDENCIES` | Receives output from all dependent steps (default) |
| `NO_MEMORY` | Fresh context, no previous step outputs |

---

## Output Format

When generating specs, provide both:

### 1. JSON (for import)

```json
{
  "rootWorkflow": {
    // ... complete spec
  }
}
```

### 2. Markdown Documentation

```markdown
# Agent Specification: [Name]

## Overview
- **Purpose:** [What it does]
- **Audience:** [Who uses it]
- **Trigger:** [How it starts]

## Input Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| ... | ... | ... | ... |

## Workflow Steps
1. **[Step Name]** — [What it does]
2. **[Step Name]** — [What it does]

## Data Sources
- [Source 1]
- [Source 2]

## Output
[Description of what the agent returns]

## Testing
| Scenario | Expected Result |
|----------|-----------------|
| ... | ... |
```

---

## Best Practices

1. **Start simple** — Get a working agent, then add complexity
2. **Use meaningful step IDs** — `search-accounts` not `step-1`
3. **Chain with dependencies** — Use `stepDependencies` to control flow
4. **Set memory config** — Usually `ALL_DEPENDENCIES` for multi-step
5. **Test incrementally** — Build and test step by step
6. **Document prompts** — Long `instructionTemplate` values should be clear

---

## Example: Account Status Agent

```json
{
  "rootWorkflow": {
    "name": "Account Status Agent",
    "description": "Pre-meeting briefing for any customer account",
    "icon": {
      "backgroundColor": "var(--theme-brand-light-blue-50)",
      "color": "#333",
      "iconType": "GLYPH",
      "name": "briefcase"
    },
    "schema": {
      "goal": "Provide comprehensive pre-meeting context for customer accounts",
      "steps": [
        {
          "id": "gather-context",
          "type": "TOOL",
          "toolConfig": [
            { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account Name]] app:gong" }] },
            { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account Name]] app:slack" }] },
            { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account Name]] app:gmail" }] },
            { "id": "Glean Search", "inputTemplate": [{ "template": "[[Account Name]] app:salescloud" }] }
          ],
          "memoryConfig": "ALL_DEPENDENCIES"
        },
        {
          "id": "synthesize-briefing",
          "instructionTemplate": "Based on the gathered context, create a pre-meeting briefing with:\n\n1. **Last Meeting** - Date, key points, commitments\n2. **Open To-Dos** - Action items for Glean team\n3. **Missed Communications** - Unresponded messages\n4. **Internal Flags** - Team concerns or notes\n5. **Account Health** - Overall status assessment\n\nBe concise. Cite sources. Flag anything urgent.",
          "type": "TOOL",
          "stepDependencies": ["gather-context"],
          "toolConfig": [{ "id": "Respond", "respondConfig": { "temperature": "FACTUAL" } }],
          "memoryConfig": "ALL_DEPENDENCIES"
        }
      ],
      "fields": [
        {
          "name": "Account Name",
          "displayName": "Account Name",
          "description": "Customer account name (e.g., 'Snap Inc.', 'Northbeam')",
          "type": { "type": "TEXT" }
        }
      ],
      "modelOptions": {
        "llmConfig": { "provider": "OPEN_AI", "model": "GPT41_20250414" }
      },
      "trigger": {
        "type": "INPUT_FORM",
        "config": { "inputForm": { "scheduleConfig": {} } }
      }
    }
  }
}
```

---

*When generating specs, always validate JSON syntax and ensure all step references are valid.*
