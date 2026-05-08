---
name: using-the-force
description: |
  Comprehensive guide for using The Force MCP server - a unified interface to 11 AI models
  (OpenAI, Google, Anthropic, xAI) with intelligent context management, project memory, and
  multi-model collaboration. This skill should be used when working with The Force MCP tools,
  selecting appropriate AI models for tasks, managing context and sessions, using GroupThink
  for multi-model collaboration, or optimizing AI-assisted workflows.
---

# Using The Force MCP Server

The Force provides unified access to 11 cutting-edge AI models through a single consistent interface with intelligent context management, long-term project memory, and multi-model collaboration capabilities.

## Quick Reference: Model Selection

For 90% of work, use these two models:

| Need | Model | Why |
|------|-------|-----|
| **Default choice** | `chat_with_gpt52_pro` | Smartest reasoning, 400k context, best at search |
| **Large context** | `chat_with_gemini3_pro_preview` | 1M context, fast, excellent code analysis |

### Full Model Roster

| Model | Context | Speed | Best For |
|-------|---------|-------|----------|
| **OpenAI** |
| `chat_with_gpt52_pro` | 400k | Medium | Complex reasoning, code generation, search |
| `chat_with_gpt52_pro_max` | 400k | Slow | 24+ hour tasks, xhigh reasoning, 77.9% SWE-bench |
| `chat_with_gpt41` | 1M | Fast | Large docs, RAG, low hallucination |
| `research_with_o3_deep_research` | 200k | 10-60 min | Exhaustive research with citations |
| `research_with_o4_mini_deep_research` | 200k | 2-10 min | Quick research reconnaissance |
| **Google** |
| `chat_with_gemini3_pro_preview` | 1M | Medium | Giant code synthesis, design reviews |
| `chat_with_gemini3_flash_preview` | 1M | Very fast | Quick summaries, extraction, triage |
| **Anthropic** |
| `chat_with_claude45_opus` | 200k | Slow | Deep extended thinking, premium quality |
| `chat_with_claude45_sonnet` | 1M | Fast | Latest Claude, strong coding |
| `chat_with_claude3_opus` | 200k | Slow | Thoughtful writing, low hallucination |
| **xAI** |
| `chat_with_grok41` | ~2M | Medium | Massive context, Live Search (X/Twitter) |

## Core Concepts

### 1. Context Management

The Force automatically handles large codebases by splitting between inline content and vector stores.

**How it works:**
1. Calculate token budget (85% of model's context window)
2. Sort files smallest-first to maximize complete files inline
3. Fill budget with files directly in prompt
4. Remaining files → searchable vector store
5. Cache this "stable list" for subsequent calls

**Key parameters:**

```
context: ["/abs/path/to/src", "/abs/path/to/docs"]
  - Files/directories to include
  - MUST be absolute paths
  - Auto-splits between inline and vector store

priority_context: ["/abs/path/to/critical/config.py"]
  - Files that MUST be inline regardless of size
  - Use sparingly for security configs, schemas
  - Still respects total budget
```

**Rules:**
- Always use **absolute paths** (relative paths resolve to server's CWD)
- Size limits: 500KB per file, 50MB total
- Respects `.gitignore`, skips binaries
- 60+ text file types supported

### 2. Session Management

Sessions enable multi-turn conversations with memory persistence.

```
session_id: "jwt-auth-refactor-2024-12-10"
```

**Best practices:**
- One session per logical thread of reasoning
- Use descriptive IDs: `debug-race-condition-2024-12-10`
- Reuse same `session_id` for follow-ups (conversation continues)
- Sessions work across models (switch models mid-conversation)
- Default TTL: 6 months

**Session strategy:**
```
# First call: Creates session
chat_with_gpt52_pro(
    instructions="Analyze auth flow",
    context=["/src/auth"],
    session_id="auth-analysis"
)

# Follow-up: Leverages prior context
chat_with_gpt52_pro(
    instructions="Now focus on the JWT validation",
    session_id="auth-analysis"  # Same session = remembers context
)

# Switch models, same session
chat_with_gemini3_pro_preview(
    instructions="Review what we found for security issues",
    session_id="auth-analysis"  # Works across models
)
```

### 3. Structured Output

Force models to return valid JSON matching a schema:

```
structured_output_schema: {
    "type": "object",
    "properties": {
        "issues": {"type": "array", "items": {"type": "string"}},
        "severity": {"type": "string", "enum": ["low", "medium", "high"]}
    },
    "required": ["issues", "severity"],
    "additionalProperties": false
}
```

Supported by most models. OpenAI requires strict schema (all props in `required`, `additionalProperties: false`).

### 4. Reasoning Effort

Control depth of model thinking (where supported):

| Level | Use Case | Models |
|-------|----------|--------|
| `low` | Quick answers | o3, o4-mini, gpt51-codex |
| `medium` | Balanced (default) | o3, o4-mini, gpt51-codex |
| `high` | Deep analysis | o3, o3-pro, gpt51-codex |
| `xhigh` | Maximum depth | gpt51-codex-max only |

```
reasoning_effort: "high"  # For complex problems
```

## Utility Tools

### Project History Search

Search past conversations AND git commits:

```
search_project_history(
    query="JWT authentication decisions; refresh token strategy",
    max_results=20,
    store_types=["conversation", "commit"]
)
```

**Important:** Returns HISTORICAL data that may be outdated. Use to understand past decisions, not current code state.

### Session Management

```
list_sessions(limit=10, include_summary=true)
describe_session(session_id="auth-analysis")
```

### Token Counting

Estimate context size before sending:

```
count_project_tokens(
    items=["/src", "/tests"],
    top_n=10  # Show top 10 largest files
)
```

### Async Jobs

For operations >60s (deep research, large token counts):

```
# Start background job
job = start_job(
    target_tool="research_with_o3_deep_research",
    args={"instructions": "...", "session_id": "..."},
    max_runtime_s=3600
)

# Poll until complete
result = poll_job(job_id=job["job_id"])
# status: pending | running | completed | failed | cancelled

# Cancel if needed
cancel_job(job_id=job["job_id"])
```

## Multi-Model Collaboration (GroupThink)

Orchestrate multiple models on complex problems:

```
group_think(
    session_id="design-auth-system",
    objective="Design zero-downtime auth service with JWT rotation",
    models=[
        "chat_with_gpt52_pro",         # Best reasoning
        "chat_with_gemini3_pro_preview", # Large context analysis
        "chat_with_claude45_opus"        # Design documentation
    ],
    output_format="Design doc with: Architecture, API endpoints, Migration plan",
    context=["/src/auth"],
    priority_context=["/docs/security-requirements.md"],
    discussion_turns=6,
    validation_rounds=2
)
```

**How it works:**
1. **Discussion phase**: Models take turns contributing to shared whiteboard
2. **Synthesis phase**: Large-context model creates final deliverable
3. **Validation phase**: Original models review and critique

**Key parameters:**

| Parameter | Purpose | Default |
|-----------|---------|---------|
| `session_id` | Panel identifier (reuse to continue) | Required |
| `objective` | Problem to solve | Required |
| `models` | List of model tool names | Required |
| `output_format` | Deliverable specification | Required |
| `discussion_turns` | Back-and-forth rounds | 6 |
| `validation_rounds` | Review iterations | 2 |
| `synthesis_model` | Model for final synthesis | gemini3_pro_preview |
| `direct_context` | Inject history directly (vs vector search) | true |

**Continue existing panel:**
```
group_think(
    session_id="design-auth-system",  # Same ID
    user_input="Now focus on the migration path",
    models=[...],  # Can be same or different
    objective="...",
    output_format="..."
)
```

## Three-Phase Intelligence Gathering

Optimal pattern for complex analysis:

### Phase 1: Broad Surface Scan (5-10s)
```
# Launch 2-3 fast queries in parallel
chat_with_gemini3_flash_preview(
    instructions="What are the main issues here?",
    context=["/src"],
    session_id="analysis-phase1-issues"
)

chat_with_gemini3_flash_preview(
    instructions="What patterns exist in this codebase?",
    context=["/src"],
    session_id="analysis-phase1-patterns"
)
```

### Phase 2: Deep Focus (30-60s)
```
# Pursue top insights from Phase 1
chat_with_gpt52_pro(
    instructions="Deep analysis of [specific issue from Phase 1]",
    context=["/src"],
    session_id="analysis-phase2-deep"
)
```

### Phase 3: Synthesis (10s)
```
# Reconcile findings
chat_with_gemini3_flash_preview(
    instructions="Synthesize these findings: [Phase 1 + Phase 2 results]",
    session_id="analysis-phase3-synthesis"
)
```

## Model Selection Strategies

### For Debugging
```
# Fast hypothesis generation
chat_with_gemini3_flash_preview("What could cause this error?", context=[...])

# Deep reasoning on top hypothesis
chat_with_gpt52_pro("Trace execution of [hypothesis]", context=[...])

# Validation from different perspective
chat_with_gemini3_pro_preview("What did we miss?", context=[...])
```

### For Architecture Review
```
# Overview with large context
chat_with_gpt41(context=["/entire/codebase"], instructions="Find inconsistencies")

# Deep dive on subsystems
chat_with_gemini3_pro_preview("Analyze data layer for ACID issues")

# External research
research_with_o3_deep_research("Industry standards for [patterns found]")
```

### For Code Generation
```
# Planning
chat_with_gpt52_pro("Design API structure for [requirements]")

# Implementation
chat_with_gemini3_pro_preview("Implement [design] with error handling")

# Review
chat_with_gpt41("Review for security and performance")
```

## Error Handling

### Rate Limits (429)
- Stagger launches by 100ms
- Use async jobs for high concurrency
- Fallback to cheaper models

### Context Overflow
- Run `count_project_tokens` first
- Switch to larger-context model (gpt41, gemini3_pro)
- Use `priority_context` for must-includes
- Let server handle vector store split

### Timeouts
- Offload to `start_job` / `poll_job`
- Use faster models for initial scan
- Break into smaller queries

## Configuration

### Environment Variables
```bash
OPENAI_API_KEY="sk-..."
GEMINI_API_KEY="..."
XAI_API_KEY="xai-..."
ANTHROPIC_API_KEY="sk-ant-..."
VERTEX_PROJECT="my-project"
VERTEX_LOCATION="us-central1"
```

### Key Settings (config.yaml)
```yaml
mcp:
  context_percentage: 0.85  # % of model context to use
  default_temperature: 0.2

session:
  ttl_seconds: 15552000  # 6 months

history:
  enabled: true
```

## Best Practices Summary

1. **Start Fast, Go Deep**: Use gemini3_flash_preview for exploration, then targeted deep models
2. **Parallel Everything**: Launch multiple models simultaneously when possible
3. **Session Hygiene**: One session per logical thread of reasoning
4. **Smart Fallbacks**: Always have a faster/cheaper model as backup
5. **Absolute Paths Only**: Never use relative paths in context
6. **Reuse Sessions**: Save tokens by continuing conversations
7. **Priority Context Sparingly**: Only for truly critical files
8. **Check History First**: Search project history before making decisions
9. **Monitor Tokens**: Use `count_project_tokens` for large contexts
10. **Async for Long Tasks**: Use job system for >60s operations

## Resources

This skill includes quick-reference materials in `references/`:

- **model-selection-guide.md**: Detailed model comparison and selection criteria
- **common-patterns.md**: Copy-paste patterns for common workflows
