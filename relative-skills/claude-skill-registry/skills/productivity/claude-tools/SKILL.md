---
name: claude-tools
description: This skill provides knowledge about Claude tools (Prompts, Skills, Subagents, Commands, and MCPs). Use this skill when knowledge about Claude tools is needed, when the user mentions Claude tools or when the user needs help identifying the best Claude tool to use/create for a task. Common questions include 'Should I create a Claude tool for this use-case?', 'What type of Claude tool should I create for this use-case?."
---

# Claude Tools

## Purpose
This skill gives you structured knowledge about the different Claude tool types: their definitions, when to use them, and how they differ.

## When to Use This Skill
Invoke this skill when:
- User asks "Should I create a Claude tool for...?" or "Which Claude tool should I create...?"
- User asks "Is a Skill/Command/MCP/Subagent right for...?"
- User needs help deciding between different Claude tool types for their use case
- User mentions Claude tools and needs structured guidance on which to use

## Tools Overview
Each tool type serves a distinct role with its own strengths and trade-offs.

### Prompt
**Definition**: The simplest way to instruct Claude. They are the instructions provided to Claude in natural language during a conversation (moment-to-moment). They are ephemeral, conversational, and reactive. They provide context and direction in the moment. They are the only Claude tool that is not stored or persisted across conversations. For a quick, specific request that is unlikely to repeat.

**Example**: “Analyse these server logs and summarise the errors.”

---

### Command
**Definition**: A user-invoked alias/instruction to perform a specific repeated task. Stored/persisted across conversations and triggered explicitly by the user. For a frequent, consistent action that users perform and should be standardised. Claude evaluates user request, then picks up the relevant Skill if applicable.

**Example**: `/create-user` that guides Claude to perform steps in a CRM system.

---

### Skill
**Definition**: Skills are folders containing instructions, scripts, and resources that Claude discovers and loads dynamically when relevant to a task. They are specialized training manuals that give Claude expertise in specific domains. From interacting with a specialized tool to following user coding guidelines. For a workflow or domain knowledge Claude should reuse across many contexts and that Claude should internalise.

**Example**: A brand guidelines Skill that includes a company's color palette, typography rules, and layout specifications. When Claude creates presentations or documents, it automatically applies these standards without the user needing to explain them each time.

---

### Subagent
**Definition**: Subagents are specialized AI assistants with their own context windows, custom system prompts, and specific tool permissions. The main agent triggers them to handle discrete tasks independently. They return results to the main agent. They are useful when the context of the task becomes obsolete as soon as the task is completed to avoid filling the main agent's context with information that is no longer relevant.

**Example**: A subagent that interacts with a specialized tool to perform a task independently and returns the results to the main agent.

---

### MCP
**Definition**: A system/protocol enabling Claude to connect to external systems (APIs, databases, services) for live or up-to-date information. For when your task relies on external system state, live data or tooling integration.

**Example**: An MCP that queries a database to pull user data.

---

## Creation Guidance
When creating a new Claude tool, select the most appropriate tool type:

1. Does it need external data/APIs? → Consider MCP
2. Is it a one-time request? → Use Prompt
3. Does it repeat frequently with identical steps? → Create Command
4. Does it require specialized domain knowledge? → Create Skill
5. Does it need isolated context/permissions? → Create Subagent
6. Does it need multiple of the above? → Combine types
