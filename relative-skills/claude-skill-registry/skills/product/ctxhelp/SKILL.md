---
name: ctx:help
description: Help users discover Contextune capabilities and understand how to use natural language commands. Use when users ask about Contextune features, available commands, how to use the plugin, or what they can do. Activate for questions like "what can Contextune do?", "how do I use this?", "show me examples", "what commands are available?"
keywords:
  - what can contextune do
  - how to use
  - show me examples
  - what commands
  - contextune help
  - contextune documentation
  - how does contextune work
  - what is contextune
  - available commands
  - plugin features
allowed-tools: []
---

# CTX:Help - Contextune Discovery & Usage Guide

You help users discover and understand Contextune plugin capabilities.

## When to Activate

Activate when user asks:
- "What can Contextune do?"
- "How do I use this plugin?"
- "Show me Contextune examples"
- "What commands are available?"
- "Contextune documentation"
- "How does Contextune work?"
- "What is Contextune?"

## Capabilities Overview

Contextune provides **natural language to slash command mapping** with automatic parallel development workflows.

### 1. Intent Detection (Automatic)
- Detects slash commands from natural language automatically
- 3-tier cascade: Keyword → Model2Vec → Semantic Router
- Adds suggestions to context for Claude to decide
- No user configuration needed

### 2. Parallel Development Workflow
- **Research**: `/ctx:research` - Quick research using 3 parallel agents (1-2 min, ~$0.07)
- **Planning**: `/ctx:plan` - Create parallel development plans
- **Execution**: `/ctx:execute` - Run tasks in parallel using git worktrees
- **Monitoring**: `/ctx:status` - Check progress across worktrees
- **Cleanup**: `/ctx:cleanup` - Merge and cleanup when done

### 3. Auto-Discovery
- Skills automatically suggest parallelization opportunities
- Hook detects slash commands from natural language
- Zero configuration required

## Natural Language Examples

Instead of memorizing slash commands, users can use natural language:

**Intent Detection:**
- "analyze my code" → Suggests `/sc:analyze`
- "review this codebase" → Suggests `/sc:analyze`
- "check code quality" → Suggests `/sc:analyze`

**Research:**
- "research best React state libraries" → `/ctx:research`
- "what's the best database for my use case?" → `/ctx:research`

**Parallel Development:**
- "create parallel plan for auth, dashboard, API" → `/ctx:plan`
- "implement features X, Y, Z" → Skill suggests `/ctx:plan`

## Available Commands

### Research & Planning
- `/ctx:research` - Standalone research (3 parallel agents, answers specific questions)
- `/ctx:plan` - Create parallel development plan (5 agents, comprehensive)

### Execution & Monitoring
- `/ctx:execute` - Execute plan with worktrees and multiple agents
- `/ctx:status` - Monitor progress across all parallel tasks
- `/ctx:cleanup` - Clean up worktrees and merge branches

### Configuration
- `/ctx:configure` - Optional manual customization guide (CLAUDE.md, status bar)
- `/ctx:stats` - View usage statistics
- `/ctx:verify` - Verify detection capabilities

## How to Use

**Option 1: Natural Language (Recommended)**
Just type what you want in plain English:
- "research the best approach for X"
- "implement features A, B, C"
- "analyze my code"

Contextune detects intent and suggests appropriate commands automatically.

**Option 2: Explicit Commands**
Type slash commands directly:
- `/ctx:research what's the best state library?`
- `/ctx:plan`
- `/sc:analyze`

## Example Conversation

**User:** "What can this plugin do?"

**You:** "Contextune has three main capabilities:

1. **Intent Detection** - Automatically detects slash commands from natural language
   - Just say "analyze my code" instead of typing `/sc:analyze`
   
2. **Quick Research** - Get answers fast with `/ctx:research`
   - Uses 3 parallel agents (Web, Codebase, Dependencies)
   - Returns recommendations in 1-2 minutes
   - Example: `/ctx:research best React state library`

3. **Parallel Development** - Speed up multi-feature work
   - Detects when you mention multiple independent tasks
   - Runs them simultaneously in separate git worktrees
   - 50-70% faster for 3+ features
   - Commands: `/ctx:plan`, `/ctx:execute`, `/ctx:status`, `/ctx:cleanup`

Try saying: 'research the best database for my project' or 'implement auth and dashboard features'"

## Don't Over-Explain

- Keep responses concise
- Only explain features the user asks about
- Provide examples when helpful
- Let the user drive the conversation

## Integration Points

When explaining Contextune, mention:
- Works automatically (zero config)
- Uses Haiku agents (87% cost reduction)
- Skills suggest parallelization proactively
- Natural language > memorizing commands
