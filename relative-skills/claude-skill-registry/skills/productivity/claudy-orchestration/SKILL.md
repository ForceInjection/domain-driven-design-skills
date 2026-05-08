---
name: claudy-orchestration
description: Use this skill when delegating to sub-agents that require more flexibility than the Task tool provides - when launching multiple agents in parallel, managing persistent sessions across calls, or coordinating complex multi-agent workflows with custom orchestration patterns.
---

# Claudy Orchestration

Multi-agent session manager for Claude Code. Spawn and manage persistent Claude agent sessions with automatic cleanup.

## Quick Start

**⚠️ IMPORTANT**: Claudy works in **two modes**:
1. **CLI Mode** (Always available, no setup needed) - Use `uvx claudy` commands
2. **MCP Mode** (Optional, for Claude Code integration) - Add to `.mcp.json`

**If you don't have MCP configured, use CLI mode!** It provides the same functionality.

### Option 1: CLI Usage (No Setup Required)

```bash
# Start the server (required first step)
uvx claudy server start

# Call an agent session
uvx claudy call <name> "<message>" [--verbosity quiet|normal|verbose]

# List all sessions
uvx claudy list

# Get session status
uvx claudy status <name>

# Cleanup sessions
uvx claudy cleanup <name>
uvx claudy cleanup --all

# Stop the server
uvx claudy server stop
```

### Option 2: MCP Integration (Optional)

Add to your `.mcp.json` for Claude Code integration:

```json
{
  "mcpServers": {
    "claudy": {
      "type": "stdio",
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/kangjihyeok/claude-agentic-skills.git@main#subdirectory=claudy",
        "fastmcp",
        "run",
        "claudy.mcp_server:mcp"
      ]
    }
  }
}
```

## MCP Tools

### `claudy_call`

Send a message to an agent session (auto-creates if doesn't exist).

**Parameters:**
- `name` (str): Session name
- `message` (str): Message to send
- `verbosity` (str): "quiet", "normal", or "verbose" (default: "normal")
- `fork` (bool): Fork before sending (default: false)
- `fork_name` (str, optional): Name for forked session
- `parent_session_id` (str, optional): Explicit parent session to inherit context from

**Returns:** `{"success": true, "name": "...", "response": "...", "session_id": "..."}`

### `claudy_call_async`

Start agent task in background, returns immediately for parallel execution.

**Parameters:**
- `name` (str): Session name
- `message` (str): Message to send
- `verbosity` (str): "quiet", "normal", or "verbose" (default: "normal")
- `parent_session_id` (str, optional): Explicit parent session to inherit context from

**Returns:** `{"success": true, "name": "...", "status": "running"}`

### `claudy_get_results`

Wait for and aggregate results from multiple background agents (blocking until complete).

**Parameters:**
- `names` (list[str]): List of session names to wait for
- `timeout` (int, optional): Timeout in seconds

**Returns:** `{"success": true, "results": {"name1": {...}, "name2": {...}}}`

### `claudy_check_status`

Check if background tasks are still running.

**Parameters:**
- `names` (list[str], optional): Session names to check (if None, checks all)

**Returns:** `{"success": true, "tasks": {"name1": "running", "name2": "completed"}}`

### `claudy_list`

List all active agent sessions.

**Returns:** `{"success": true, "sessions": [...]}`

### `claudy_status`

Get detailed status of a specific session.

**Parameters:**
- `name` (str): Session name

**Returns:** Session metadata (created_at, last_used, message_count, etc.)

### `claudy_share_context` (NEW!)

Share context from one session that other sessions can access.

**Parameters:**
- `session_name` (str): Name of the session sharing the context
- `context_key` (str): Unique identifier for this context (e.g., "verification_findings", "test_results")
- `context_data` (dict): Dictionary containing the context to share

**Returns:** `{"success": true, "context_key": "...", "session_name": "...", "message": "..."}`

**Use Cases:**
- Verifier shares findings → Analyst validates them
- Generator shares solution → Tester shares results → Fixer accesses both
- Multiple specialists share analysis → Lead agent synthesizes

### `claudy_get_shared_context` (NEW!)

Retrieve shared context from other sessions.

**Parameters:**
- `context_key` (str): The context identifier to retrieve
- `source_session` (str, optional): Optional filter by source session name

**Returns:** `{"success": true, "context_key": "...", "count": N, "contexts": [...]}`

Each context contains:
- `session_name`: Source session
- `session_id`: Source session ID
- `data`: The shared data
- `timestamp`: When it was shared

### `claudy_cleanup`

Cleanup one or all sessions.

**Parameters:**
- `name` (str, optional): Session name to cleanup
- `all` (bool): Cleanup all sessions (default: false)

**Returns:** `{"success": true, "message": "..."}`

## Usage Patterns

### Basic Session Management

```
# Auto-create and call a session
Use claudy_call with name="researcher" and message="Search for latest AI papers"

# Check status
Use claudy_status with name="researcher"

# Cleanup
Use claudy_cleanup with name="researcher"
```

### Context Preservation

```
1. claudy_call(name="memory_test", message="Remember this number: 42")
2. claudy_call(name="memory_test", message="What number did I ask you to remember?")
   → "42" ✓ Context preserved!
```

### Inter-Session Context Sharing (NEW!)

```
# Verifier agent shares findings
claudy_call(name="verifier", message="Review code for bugs")
claudy_share_context(
    session_name="verifier",
    context_key="bug_findings",
    context_data={"critical_bugs": [...], "warnings": [...]}
)

# Analyst agent validates findings
claudy_call(name="analyst", message=f"""
Review these bug findings and mark each as 'confirmed' or 'false_positive':
{claudy_get_shared_context("bug_findings", "verifier")}
""")

# Fixer accesses validated findings
claudy_call(name="fixer", message=f"""
Fix only the confirmed bugs:
{claudy_get_shared_context("validated_bugs", "analyst")}
""")
```

### Session Forking

```
# Create base session
claudy_call(name="analysis", message="Analyze this codebase")

# Fork to explore alternatives
claudy_call(
    name="analysis",
    message="Try refactoring approach B",
    fork=True,
    fork_name="analysis_fork_b"
)

# Original session unchanged
claudy_call(name="analysis", message="Continue with approach A")
```

### Parallel Execution

```
# Launch multiple agents in parallel
claudy_call_async('security', 'Audit code for vulnerabilities')
claudy_call_async('performance', 'Find performance bottlenecks')
claudy_call_async('docs', 'Generate API documentation')

# Collect all results
claudy_get_results(['security', 'performance', 'docs'])
```

### IOI/Competitive Programming Pattern (NEW!)

Multi-stage workflow with specialized agents and context sharing. Based on solving Korean Olympiad in Informatics problems using iterative refinement.

```
## Agent Role Templates

# Code Generator Agent - Focuses on initial correctness
GENERATOR_PROMPT = """
You are an IOI algorithm expert specializing in generating optimal solutions.
PRIORITY: Correctness > Optimization
OUTPUT: Working code + complexity analysis + edge cases
Allowed Tools: Read, Grep, Glob, WebSearch
"""

# Strict Verifier Agent - Finds ALL issues (false positives OK)
VERIFIER_PROMPT = """
You are a strict IOI coach and automated judge combined.
PRIORITY: Find ALL potential issues, even if uncertain
OUTPUT: Categorized issues (Critical Logic Error, TLE/MLE, Implementation Bug, Edge Case)
Style: Adversarial, detailed, quote specific code sections
"""

# Analyst Agent - Validates verifier findings (prevents over-fixing!)
ANALYST_PROMPT = """
You are a senior IOI coach judging verification reports.
PRIORITY: Distinguish real issues from false positives
OUTPUT: Each finding marked as 'confirmed' or 'false_positive' with justification
Style: Evidence-based, conservative
"""

# Conservative Fixer Agent - Minimal changes, test after each
FIXER_PROMPT = """
You are a careful code improver for IOI solutions.
PRIORITY: Preserve working functionality, change ONE thing at a time
OUTPUT: Incremental fix + test + next fix (not bulk changes!)
Style: Conservative, test-driven
"""

# Lead Synthesizer Agent - Final integration and decision making
LEAD_PROMPT = """
You are the meta-coordinator for IOI problem solving.
PRIORITY: Synthesize all agent insights, make final decisions
ACCESS: All shared contexts from specialized agents
OUTPUT: Final solution that integrates verified improvements only
Style: Holistic, evidence-based
"""

## Complete IOI Workflow

# Step 1: Generate initial solution
Use claudy_call with name="code_generator" and GENERATOR_PROMPT + problem description
Use claudy_share_context to share the solution under key="solution_v1"

# Step 2: Self-critique
Use claudy_call with name="critic" and message including solution_v1
Use claudy_share_context to share critique under key="critique"

# Step 3: Strict verification
Use claudy_call with name="verifier" and message including solution + critique
Use claudy_share_context to share findings under key="verification_findings"

# Step 4: Analyst validation (CRITICAL - prevents over-fixing!)
Use claudy_call with name="analyst" and message:
  "Review these findings and mark each as 'confirmed' or 'false_positive':
  {claudy_get_shared_context('verification_findings', 'verifier')}"
Use claudy_share_context to share validated issues under key="confirmed_issues"

# Step 5: Incremental fixing with testing
baseline_score = test_solution(solution_v1)
For each confirmed issue (one at a time):
    Use claudy_call with name="fixer" and message:
      "Fix ONLY this issue: {issue}
       Previous score: {current_score}
       {claudy_get_shared_context('solution_v1')}
       Provide updated code."
    Test the fix
    If score >= current_score:
        Accept fix, update current_score
        Use claudy_share_context with key="solution_v{iteration}"
    Else:
        Reject fix, continue to next issue

# Step 6: Lead agent final synthesis (if not 100% score)
If score < 100:
    Use claudy_call with name="lead" and message:
      "Synthesize all contexts and achieve 100 points:
       {claudy_get_shared_context('solution_v1')}
       {claudy_get_shared_context('critique')}
       {claudy_get_shared_context('verification_findings')}
       {claudy_get_shared_context('confirmed_issues')}
       Test results: {all_test_results}
       Make final improvement."
```

**Key Lesson from Real Usage**: The 44→23 point regression happened because we skipped Step 4 (Analyst validation) and applied all verifier findings at once in Step 5. The improved workflow fixes this by:
1. Adding validation layer (Step 4)
2. Applying changes incrementally with testing (Step 5)
3. Lead agent synthesis with full context (Step 6)

## Key Features

- **Dual Mode**: CLI (no setup) or MCP (Claude Code integration)
- **Context Preservation**: Agents remember full conversation history
- **Session Forking**: Branch conversations to explore alternative paths
- **Auto Cleanup**: 20-minute idle timeout prevents resource leaks
- **Independent Sessions**: Clean context, no automatic inheritance
- **Parallel Execution**: Run multiple agents concurrently with `claudy_call_async`
- **Zero Configuration**: CLI works out of the box with uvx

## Configuration

Sessions auto-cleanup after 20 minutes of inactivity. To customize:

Edit `claudy/config.py`:
```python
SESSION_IDLE_TIMEOUT = 1200  # 20 minutes in seconds
SESSION_CLEANUP_INTERVAL = 300  # 5 minutes
```

## Architecture

```
[CLI Mode]                      [MCP Mode]
claudy CLI → HTTP Server        Claude Code → stdio
         ↓                               ↓
         └──────── FastMCP Server ───────┘
                        ↓
            ClaudeSDKClient Sessions (in-memory)
                        ↓
                Auto cleanup (20min idle timeout)
```

**Design:**
- **CLI Mode**: HTTP server (starts with `claudy server start`)
- **MCP Mode**: Direct stdio communication (no HTTP server)
- Global session storage (shared across all connections)
- Background TTL cleanup task (20-minute idle timeout)
- Independent sessions (no automatic context inheritance)

## Important Notes

### Use CLI Mode if MCP is Not Configured

**You don't need MCP to use claudy!** If you see MCP tool errors:
1. Start the HTTP server: `uvx claudy server start`
2. Use CLI commands: `uvx claudy call <name> "<message>"`

CLI mode provides **identical functionality** to MCP mode.

### Server Start Required (CLI Mode)

For CLI usage, you **must** start the server first:

```bash
uvx claudy server start
```

Then you can use `call`, `list`, `status`, `cleanup` commands. The server will **NOT** auto-start.

### Session Persistence

Sessions are **in-memory only**. They are lost when:
- Server stops
- Session idle for 20+ minutes
- Manual cleanup via `claudy_cleanup`

### MCP vs CLI Mode

| Feature | CLI Mode | MCP Mode |
|---------|----------|----------|
| Setup | None (always works) | Requires `.mcp.json` configuration |
| Server | HTTP (manual start) | stdio (auto-managed by Claude Code) |
| Usage | `uvx claudy call ...` | `Use claudy_call tool` |
| Functionality | ✅ Full | ✅ Full |

Both modes share the same session storage and features.

## Troubleshooting

### "Server is not running"

Run `uvx claudy server start` before using CLI commands.

### Sessions disappearing

Sessions cleanup after 20 minutes of inactivity. Use them regularly or reduce `SESSION_IDLE_TIMEOUT`.

### Fork fails

Ensure parent session has sent at least one message (session_id must exist).

## Requirements

- Python 3.10+
- Claude Code 2.0+ (for claude-agent-sdk)
- fastmcp >= 2.12.0
- claude-agent-sdk >= 0.1.4

## License

MIT License

---

**Built with ❤️ using [FastMCP](https://github.com/jlowin/fastmcp) and [claude-agent-sdk](https://github.com/anthropics/claude-agent-sdk-python)**
