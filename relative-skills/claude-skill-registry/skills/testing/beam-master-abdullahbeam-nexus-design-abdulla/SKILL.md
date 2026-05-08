---
name: beam-master
description: Shared resource library for Beam AI integration skills. DO NOT load directly - provides common references (setup, API docs, error handling, authentication) and scripts used by beam-connect and individual Beam skills.
---

# Beam Master

**This is NOT a user-facing skill.** It's a shared resource library referenced by Beam integration skills.

## Purpose

Provides shared resources to eliminate duplication across:
- `beam-connect` - Meta-skill for Beam AI workspace operations
- `beam-list-agents` - List workspace agents
- `beam-get-agent-graph` - Fetch agent graph configuration
- `beam-get-agent-analytics` - Get agent performance metrics
- `beam-create-agent-task` - Create and execute agent tasks
- `beam-update-graph-node` - Update node configuration
- `beam-test-graph-node` - Test individual nodes
- `beam-get-nodes-by-tool` - Get nodes using specific tools
- `beam-debug-issue-tasks` - Debug failed tasks via Langfuse

**Instead of loading this skill**, users directly invoke the specific skill they need above.

---

## Architecture: DRY Principle

**Problem solved:** Beam skills would have duplicated content (setup instructions, API docs, auth flow, error handling).

**Solution:** Extract shared content into `beam-master/references/` and `beam-master/scripts/`, then reference from each skill.

**Result:** Single source of truth, reduced context per skill.

---

## Shared Resources

All Beam skills reference these resources (progressive disclosure).

### references/

**[setup-guide.md](references/setup-guide.md)** - Complete setup wizard
- Getting Beam API key
- Finding workspace ID
- Configuring .env file
- Token exchange flow

**[api-reference.md](references/api-reference.md)** - Beam API patterns
- Base URL and authentication
- All 22 API endpoints documented
- Request/response examples
- Common curl examples

**[error-handling.md](references/error-handling.md)** - Troubleshooting
- Common errors and solutions
- HTTP error codes
- Authentication issues
- Rate limiting

**[authentication.md](references/authentication.md)** - Token management
- API key to access token exchange
- Token refresh flow
- Header requirements

### scripts/

#### Authentication & Configuration

**[check_beam_config.py](scripts/check_beam_config.py)** - Pre-flight validation
```bash
python check_beam_config.py [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--json` | No | False | Output structured JSON for AI consumption |

Exit codes: 0=configured, 1=partial, 2=not configured

**When to Use:** Run this FIRST before any Beam operation. Use to validate API key and workspace ID are configured, diagnose authentication issues, or check if setup is needed.

---

**[setup_beam.py](scripts/setup_beam.py)** - Interactive setup wizard
```bash
python setup_beam.py
```
No arguments - runs interactively. Guides through API key setup, tests connection, saves to `.env`.

**When to Use:** Use when Beam integration needs initial setup, when check_beam_config.py returns exit code 2, or when user needs to reconfigure credentials.

---

**[get_access_token.py](scripts/get_access_token.py)** - Token exchange (POST /auth/access-token)
```bash
python get_access_token.py [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--json` | No | False | Output as JSON |

**When to Use:** Use to exchange API key for access token. Called automatically by beam_client.py, but use directly when debugging authentication issues or testing token exchange.

---

**[refresh_token.py](scripts/refresh_token.py)** - Token refresh (POST /auth/refresh-token)
```bash
python refresh_token.py --refresh-token TOKEN [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--refresh-token` | **Yes** | - | Refresh token to use |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when access token has expired and you have a refresh token. Typically handled automatically, but use directly for debugging token lifecycle issues.

---

**[get_current_user.py](scripts/get_current_user.py)** - User profile (GET /v2/user/me)
```bash
python get_current_user.py [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--json` | No | False | Output as JSON |

**When to Use:** Use to verify authentication is working, get user profile info, or confirm workspace access after setup.

---

#### Agent Management

**[list_agents.py](scripts/list_agents.py)** - List workspace agents (GET /agent)
```bash
python list_agents.py [--filter NAME] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--filter` | No | - | Filter agents by name/description |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user says "list agents", "show my agents", "what agents do I have", or when you need to find an agent ID for use with other scripts (tasks, graphs, analytics).

---

**[get_agent_graph.py](scripts/get_agent_graph.py)** - Get agent workflow graph (GET /agent-graphs/{agentId})
```bash
python get_agent_graph.py --agent-id AGENT [--graph-id GRAPH] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | **Yes** | - | Agent ID |
| `--graph-id` | No | - | Specific graph version ID |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user wants to see agent workflow structure, understand node configuration, get node IDs for testing/updating, or analyze agent architecture.

---

#### Graph & Node Operations

**[test_graph_node.py](scripts/test_graph_node.py)** - Test a specific node (POST /agent-graphs/test-node)
```bash
python test_graph_node.py --agent-id AGENT --node-id NODE --graph-id GRAPH [--input JSON] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | **Yes** | - | Agent ID |
| `--node-id` | **Yes** | - | Node ID to test |
| `--graph-id` | **Yes** | - | Graph ID |
| `--input` | No | `{}` | JSON input params |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when debugging a specific node, testing node behavior with custom input, validating node configuration changes, or isolating issues in a workflow.

---

**[update_graph_node.py](scripts/update_graph_node.py)** - Update node configuration (PATCH /agent-graphs/update-node)
```bash
python update_graph_node.py --node-id NODE [--objective TEXT] [--on-error STOP|CONTINUE] [--auto-retry BOOL] [--config JSON] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--node-id` | **Yes** | - | Node ID to update |
| `--objective` | No | - | New objective text |
| `--on-error` | No | - | Error behavior: STOP or CONTINUE |
| `--auto-retry` | No | - | Enable auto retry (true/false) |
| `--config` | No | - | JSON config object to merge |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when modifying node objectives/prompts, changing error handling behavior, enabling/disabling auto-retry, or updating node configuration programmatically.

---

**[get_nodes_by_tool.py](scripts/get_nodes_by_tool.py)** - Find nodes by tool (GET /agent-graphs/agent-task-nodes/{toolFunctionName})
```bash
python get_nodes_by_tool.py --tool TOOL_NAME [--agent-id AGENT] [--rated] [--page N] [--page-size N] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--tool` | **Yes** | - | Tool function name |
| `--agent-id` | No | - | Filter by agent ID |
| `--rated` | No | False | Only return rated nodes |
| `--page` | No | 1 | Page number |
| `--page-size` | No | 50 | Items per page |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when finding all nodes that use a specific tool, analyzing tool usage patterns across agents, or gathering rated nodes for optimization training.

---

**[get_tool_output_schema.py](scripts/get_tool_output_schema.py)** - Get node output schema (GET /agent-tasks/tool-output-schema/{graphNodeId})
```bash
python get_tool_output_schema.py --node-id NODE [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--node-id` | **Yes** | - | Graph node ID |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when understanding what output format a node produces, debugging output parsing issues, or documenting node interfaces.

---

#### Task Operations

**[create_task.py](scripts/create_task.py)** - Create new agent task (POST /agent-tasks)
```bash
python create_task.py --agent-id AGENT --query "Task instructions" [--urls URL1,URL2] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | **Yes** | - | Agent ID |
| `--query` | **Yes** | - | Task query/instructions |
| `--urls` | No | - | Comma-separated URLs to parse |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user wants to run an agent, execute a task, start a job, or invoke an agent with specific instructions. This is the primary way to trigger agent execution.

---

**[get_task.py](scripts/get_task.py)** - Get task details (GET /agent-tasks/{taskId})
```bash
python get_task.py --task-id TASK [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when checking task status after creation, getting detailed results of a completed task, reviewing task execution history, or debugging why a task failed.

---

**[list_tasks.py](scripts/list_tasks.py)** - List tasks with filtering (GET /agent-tasks)
```bash
python list_tasks.py [--agent-id AGENT] [--status STATUS1,STATUS2] [--search TEXT] [--start-date DATE] [--end-date DATE] [--page N] [--page-size N] [--order FIELD:DIR] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | No | - | Filter by agent ID |
| `--status` | No | - | Comma-separated: COMPLETED,FAILED,RUNNING,etc |
| `--search` | No | - | Search query text |
| `--start-date` | No | - | Start date (ISO 8601) |
| `--end-date` | No | - | End date (ISO 8601) |
| `--page` | No | 1 | Page number |
| `--page-size` | No | 20 | Items per page |
| `--order` | No | createdAt:desc | Sort order (field:asc/desc) |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user asks "show my tasks", "list failed tasks", "what tasks ran today", or when finding tasks by status, date range, or search criteria. Best for filtered views.

---

**[iterate_tasks.py](scripts/iterate_tasks.py)** - Paginated task iteration (GET /agent-tasks/iterate)
```bash
python iterate_tasks.py [--agent-id AGENT] [--cursor CURSOR] [--limit N] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | No | - | Filter by agent ID |
| `--cursor` | No | - | Pagination cursor |
| `--limit` | No | 50 | Items per page |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when iterating through large numbers of tasks efficiently, exporting task data, or building reports. Better than list_tasks for bulk operations due to cursor-based pagination.

---

**[retry_task.py](scripts/retry_task.py)** - Retry failed task (POST /agent-tasks/retry)
```bash
python retry_task.py --task-id TASK [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID to retry |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when a task has failed and user wants to re-run it, after fixing underlying issues that caused failure, or when retrying transient errors.

---

**[get_task_updates.py](scripts/get_task_updates.py)** - Stream real-time updates (GET /agent-tasks/{taskId}/updates - SSE)
```bash
python get_task_updates.py --task-id TASK [--timeout SECONDS] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID |
| `--timeout` | No | 300 | Timeout in seconds |
| `--json` | No | False | Output as JSON lines |

**When to Use:** Use when monitoring a running task in real-time, watching for HITL (human-in-the-loop) requests, or streaming task progress updates to the user.

---

#### Task Feedback & HITL

**[approve_task.py](scripts/approve_task.py)** - Approve HITL task (POST /agent-tasks/execution/{taskId}/user-consent)
```bash
python approve_task.py --task-id TASK [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID to approve |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when a task is waiting for human approval (HITL), agent requests user consent to proceed, or task status shows "WAITING_FOR_CONSENT".

---

**[reject_task.py](scripts/reject_task.py)** - Reject task execution (POST /agent-tasks/execution/{taskId}/rejection)
```bash
python reject_task.py --task-id TASK [--reason TEXT] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID to reject |
| `--reason` | No | - | Rejection reason |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user wants to cancel/reject a running task, stop task execution, or provide negative feedback that halts the task.

---

**[provide_user_input.py](scripts/provide_user_input.py)** - Provide HITL input (PATCH /agent-tasks/execution/{taskId}/user-input)
```bash
python provide_user_input.py --task-id TASK --input "User response" [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID |
| `--input` | **Yes** | - | User input/response text |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when a task is waiting for human input (HITL), agent asks a question and needs user's answer, or task status shows "WAITING_FOR_USER_INPUT".

---

**[rate_task_output.py](scripts/rate_task_output.py)** - Rate task output (PATCH /agent-tasks/execution/{taskId}/output-rating)
```bash
python rate_task_output.py --task-id TASK --node-id NODE --rating RATING [--feedback TEXT] [--expected-output TEXT] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--task-id` | **Yes** | - | Task ID |
| `--node-id` | **Yes** | - | Task node ID |
| `--rating` | **Yes** | - | positive, negative, or excellent |
| `--feedback` | No | - | Feedback text |
| `--expected-output` | No | - | Expected output for comparison |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when providing feedback on task/node output quality, training the system with positive/negative examples, or improving agent performance through ratings.

---

#### Analytics & Optimization

**[get_analytics.py](scripts/get_analytics.py)** - Agent performance analytics (GET /agent-tasks/analytics)
```bash
python get_analytics.py --agent-id AGENT [--start-date YYYY-MM-DD] [--end-date YYYY-MM-DD] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | **Yes** | - | Agent ID |
| `--start-date` | No | 30 days ago | Start date (YYYY-MM-DD) |
| `--end-date` | No | today | End date (YYYY-MM-DD) |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user asks "how is my agent performing", "show analytics", "success rate", or when analyzing agent performance metrics over a time period.

---

**[get_latest_executions.py](scripts/get_latest_executions.py)** - Recent executions (GET /agent-tasks/latest-executions)
```bash
python get_latest_executions.py [--agent-id AGENT] [--limit N] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | No | - | Filter by agent ID |
| `--limit` | No | 10 | Number of results |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user asks "what ran recently", "show recent tasks", "latest executions", or when quickly checking what tasks completed recently without complex filtering.

---

**[optimize_tool.py](scripts/optimize_tool.py)** - Start tool optimization (POST /tool/optimize/{toolFunctionName})
```bash
python optimize_tool.py --tool TOOL_NAME [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--tool` | **Yes** | - | Tool function name |
| `--json` | No | False | Output as JSON |

**When to Use:** Use when user wants to improve a tool's performance, has collected rated node examples, or wants to trigger AI-driven optimization of tool prompts/behavior.

---

**[get_optimization_status.py](scripts/get_optimization_status.py)** - Check optimization status (POST /tool/optimization-status/thread/{threadId})
```bash
python get_optimization_status.py --thread-id THREAD [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--thread-id` | **Yes** | - | Optimization thread ID |
| `--json` | No | False | Output as JSON |

**When to Use:** Use after starting an optimization with optimize_tool.py to check progress, see if optimization is complete, or get optimization results.

---

#### File Operations

**[download_context_file.py](scripts/download_context_file.py)** - Download agent context file (GET /agent/{agentId}/context/file/{fileId}/download)
```bash
python download_context_file.py --agent-id AGENT --file-id FILE [--output PATH] [--json]
```
| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `--agent-id` | **Yes** | - | Agent ID |
| `--file-id` | **Yes** | - | File ID to download |
| `--output` | No | from headers | Output file path |
| `--json` | No | False | Output metadata as JSON |

**When to Use:** Use when user needs to download a file attached to an agent's context, retrieve agent documentation/assets, or access files stored in agent configuration.

---

## Intelligent Error Detection Flow

When a Beam skill fails due to missing configuration, the AI should:

### Step 1: Run Config Check with JSON Output

```bash
python 00-system/skills/beam/beam-master/scripts/check_beam_config.py --json
```

### Step 2: Parse the `ai_action` Field

The JSON output includes an `ai_action` field that tells the AI what to do:

| ai_action | What to Do |
|-----------|------------|
| `proceed_with_operation` | Config OK, continue with the original operation |
| `prompt_for_api_key` | Ask user: "I need your Beam API key. Get one from your Beam workspace settings" |
| `prompt_for_workspace_id` | Ask user: "I need your Beam workspace ID" |
| `create_env_file` | Create `.env` file and ask user for credentials |
| `run_setup_wizard` | Run: `python 00-system/skills/beam/beam-master/scripts/setup_beam.py` |

### Step 3: Help User Fix Issues

If `ai_action` is `prompt_for_api_key`:

1. Tell user: "Beam integration needs setup. I need your API key."
2. Show them: "Get one from: Beam workspace → Settings → API Keys"
3. Ask: "Paste your Beam API key here (starts with 'bm_key_'):"
4. Once they provide it, **write directly to `.env`**:
   ```
   # Edit .env file to add:
   BEAM_API_KEY=bm_key_their_key_here
   BEAM_WORKSPACE_ID=their-workspace-id
   ```
5. Re-run config check to verify

### JSON Output Structure

```json
{
  "status": "not_configured",
  "exit_code": 2,
  "ai_action": "prompt_for_api_key",
  "missing": [
    {"item": "BEAM_API_KEY", "required": true, "location": ".env"}
  ],
  "fix_instructions": [...],
  "env_template": "BEAM_API_KEY=bm_key_YOUR_API_KEY_HERE\nBEAM_WORKSPACE_ID=your-workspace-id",
  "setup_wizard": "python 00-system/skills/beam/beam-master/scripts/setup_beam.py"
}
```

---

## How Skills Reference This

Each skill loads shared resources **only when needed** (progressive disclosure):

**beam-connect** uses:
- `check_beam_config.py` (validate before any operation)
- All API scripts based on user request
- All references as needed

**beam-list-agents** uses:
- `check_beam_config.py` (validate before query)
- `list_agents.py` (core functionality)
- `error-handling.md` (troubleshooting)

**beam-create-agent-task** uses:
- `check_beam_config.py` (validate before task creation)
- `create_task.py` (core functionality)
- `get_task_updates.py` (monitor execution)
- `api-reference.md` (request format)

---

## Usage Example

**User says:** "list my beam agents"

**What happens:**
1. AI loads `beam-connect` skill (NOT beam-master)
2. `beam-connect` SKILL.md says: "Run check_beam_config.py first"
3. AI executes: `python beam-master/scripts/check_beam_config.py --json`
4. AI executes: `python beam-master/scripts/list_agents.py`
5. If errors occur, AI loads: `beam-master/references/error-handling.md`

**beam-master is NEVER loaded directly** - it's just a resource library.

---

## Environment Variables

Required in `.env`:
```
BEAM_API_KEY=bm_key_xxxxxxxxxxxxx
BEAM_WORKSPACE_ID=your-workspace-id
```

---

## API Base URL

All API requests go to: `https://api.beamstudio.ai`

---

**Version**: 1.2
**Created**: 2025-12-11
**Updated**: 2025-12-11
**Status**: Production Ready

**Changelog**:
- v1.2: Added "When to Use" sections to all 27 scripts for AI routing guidance
- v1.1: Added comprehensive script argument documentation with usage examples and argument tables
