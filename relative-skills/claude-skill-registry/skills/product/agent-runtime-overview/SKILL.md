---
name: Agent Runtime Overview
description: This skill should be used when the user asks "what is agent-runtime", "why use agent-runtime", "what does this repo do", "agent runtime architecture", "how does agent-runtime work", or needs to understand the purpose, value proposition, and high-level architecture of the @hhopkins/agent-runtime monorepo.
---

# Agent Runtime Overview

## What is Agent Runtime?

Agent Runtime is a general-purpose platform for launching arbitrary AI agent workloads on demand. It orchestrates AI agents (Claude via Agent SDK, OpenCode) in isolated Modal sandboxes, providing a Node.js backend runtime and React client library for building applications with AI agents.

**Key principle:** The runtime handles session management and agent orchestration - it does not enforce any data schema on the calling application. Data types are passed back to the app, which decides what to do with them.

## Packages

The monorepo provides two packages:

| Package | Purpose |
|---------|---------|
| `@hhopkins/agent-runtime` | Node.js backend runtime for orchestrating agents in Modal sandboxes |
| `@hhopkins/agent-runtime-react` | React hooks and context for connecting to the runtime |

## Why Use Agent Runtime?

### Isolation
Agents execute in Modal sandboxes, not on the application server. This provides:
- Security isolation for arbitrary code execution
- Resource isolation (CPU, memory, disk)
- Clean environment for each session

### Streaming
Real-time block-by-block streaming of agent output via WebSocket:
- `block_start` - New block begins
- `text_delta` - Incremental text updates
- `block_update` - Block metadata changes
- `block_complete` - Block finishes

### Session Management
Built-in session lifecycle with:
- Lazy sandbox creation (sandbox spins up on first message, not session create)
- Idle timeout cleanup
- Periodic state sync to persistence
- Graceful shutdown

### Multi-Architecture Support
Supports multiple agent architectures:
- **Claude Agent SDK** - Anthropic's official agent SDK
- **OpenCode** - Alternative agent runtime

Configure via `AGENT_ARCHITECTURE_TYPE` when creating sessions.

### React-Ready
First-class React integration with hooks for:
- Session lifecycle management
- Message sending and streaming
- File workspace tracking
- Subagent transcript access

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Application                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           AgentServiceProvider (React)               │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │    │
│  │  │useAgentSession│  │ useMessages  │  │useFiles   │  │    │
│  │  └──────────────┘  └──────────────┘  └───────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                    │ REST API        │ WebSocket
                    ▼                 ▼
┌─────────────────────────────────────────────────────────────┐
│                     Backend Runtime                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  SessionManager                      │    │
│  │  ┌──────────────────────────────────────────────┐   │    │
│  │  │              AgentSession                     │   │    │
│  │  │  - Sandbox lifecycle                          │   │    │
│  │  │  - Transcript parsing                         │   │    │
│  │  │  - File watching                              │   │    │
│  │  │  - Periodic sync                              │   │    │
│  │  └──────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────┘    │
│                           │                                  │
│  ┌────────────────────────┴────────────────────────────┐    │
│  │              PersistenceAdapter                      │    │
│  │  (Implemented by your application)                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Modal Sandbox                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │     Agent (Claude SDK or OpenCode)                   │    │
│  │  - Tools (Read, Write, Edit, Bash, Grep, Glob)      │    │
│  │  - Skills                                            │    │
│  │  - Subagents                                         │    │
│  │  - MCP Servers                                       │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

1. **Client creates session** via REST API
2. **Runtime creates AgentSession** (sandbox is NOT created yet - lazy initialization)
3. **Client joins WebSocket room** for the session
4. **First message triggers sandbox creation**, then agent execution begins
5. **Agent output streams** as block events via WebSocket
6. **Session state periodically syncs** to PersistenceAdapter

## Key Concepts

### Sessions
A session represents a single agent conversation. Sessions are:
- Created via REST API
- Identified by unique session ID
- Associated with an agent profile
- Persisted via the application's PersistenceAdapter

### Blocks
Agent output is parsed into typed blocks for rendering:
- `UserMessageBlock` - User input
- `AssistantTextBlock` - Agent text response
- `ToolUseBlock` - Tool invocation
- `ToolResultBlock` - Tool output
- `ThinkingBlock` - Agent reasoning (if exposed)
- `SystemBlock` - System messages
- `SubagentBlock` - Subagent invocation
- `ErrorBlock` - Error information

### Agent Profiles
Configuration defining agent capabilities:
- System prompt and memory file (CLAUDE.md/AGENT.md)
- Available tools
- Skills with supporting files
- Subagents for delegation
- Commands for specific workflows
- MCP server integrations

### PersistenceAdapter
The main integration point between the runtime and application storage. Applications implement this interface to:
- Store and retrieve sessions
- Save transcripts
- Track workspace files
- Manage agent profiles

## When to Use Agent Runtime

**Good fit:**
- Building applications that need AI agents running in isolated environments
- Launching arbitrary agent workloads on demand
- Applications requiring real-time streaming of agent output
- Multi-tenant systems where agent isolation is important
- Building custom AI interfaces (chat UIs, IDEs, automation tools)

**Consider alternatives if:**
- Running a single, long-lived agent process
- No need for sandbox isolation
- Simple request/response patterns without streaming

## Related Skills

- **backend-setup** - Setting up the Node.js backend runtime
- **react-integration** - Building React frontends with the client library
- **agent-design** - Configuring agent profiles and workflows
