---
name: browser-agent
description: >
  Autonomous browser agent for complex multi-step web tasks.
  WHEN: User needs complex web automation, multi-page workflows, form filling sequences, tasks requiring multiple browser actions.
  WHEN NOT: Simple single-action tasks like one click (use browser_click), one navigation (use browser_navigate), one extraction (use browser_extract_text).
version: 0.1.0
---

# browser_agent - Autonomous Web Automation

## Core Concept

`mcp__plugin_kg_kodegen__browser_agent` is an autonomous agent that performs complex multi-step web tasks. It:
- Plans and executes browser actions autonomously
- Handles dynamic content and SPAs
- Supports session management for parallel tasks
- Runs in background with progress monitoring

Uses session-based execution. Actions: PROMPT, READ, KILL.

## Key Parameters

### action (required)
- `PROMPT`: Start agent with a task
- `READ`: Check agent progress
- `KILL`: Terminate agent session

### task (required for PROMPT)
Natural language description of what to accomplish.

### agent (optional, default: 0)
Agent slot number for parallel execution.

### start_url (optional)
Initial URL to navigate to before starting task.

### max_steps (optional, default: 10)
Maximum iterations the agent will perform.

### await_completion_ms (optional, default: 600000)
Timeout in ms. 0 = fire-and-forget.

### temperature (optional, default: 0.7)
LLM creativity (0.0-2.0).

### max_actions_per_step (optional, default: 3)
Actions per iteration.

### additional_info (optional)
Extra context for the agent.

## Usage Examples

### Start Agent Task
```json
browser_agent({
  "action": "PROMPT",
  "task": "Find the latest Rust release notes and extract key features",
  "start_url": "https://www.rust-lang.org",
  "max_steps": 8
})
```

### Form Filling Workflow
```json
browser_agent({
  "action": "PROMPT",
  "task": "Fill out the contact form with name 'John Doe' and email 'john@example.com', then submit",
  "start_url": "https://example.com/contact",
  "temperature": 0.5,
  "max_actions_per_step": 2
})
```

### Check Progress
```json
browser_agent({
  "action": "READ",
  "agent": 0
})
```

### Fire and Forget
```json
browser_agent({
  "action": "PROMPT",
  "task": "Download the PDF from the resources page",
  "start_url": "https://example.com",
  "await_completion_ms": 0
})
// Returns immediately, agent works in background
```

### Kill Agent
```json
browser_agent({
  "action": "KILL",
  "agent": 0
})
```

## Response Format

```json
{
  "agent": 0,
  "task": "Find latest Rust release notes",
  "steps_taken": 5,
  "completed": true,
  "summary": "Found release notes for Rust 1.75...",
  "history": [
    {"step": 1, "actions": ["navigate"], "summary": "Navigated to rust-lang.org"},
    {"step": 2, "actions": ["click"], "summary": "Clicked releases link"}
  ]
}
```

## When to Use What

| Complexity | Tool | Use Case |
|------------|------|----------|
| Single action | browser_click/type/etc | Click a button, type text |
| 2-3 actions | Manual tool calls | Login form, simple search |
| 4+ actions | browser_agent | Multi-page workflows |
| Research | browser_research | Topic research with summaries |

## Configuration Guide

| Scenario | Settings |
|----------|----------|
| Web research | temperature: 0.8, max_steps: 12 |
| Form filling | temperature: 0.5, max_actions_per_step: 2 |
| Complex workflow | max_steps: 15-20 |
| Quick task | max_steps: 5, await_completion_ms: 60000 |

## Remember

- Use for complex multi-step tasks only
- Simple tasks are faster with direct tool calls
- Agent runs in background (check with READ)
- Provide clear task descriptions
- Include start_url when known
- Kill agent when done to free resources
