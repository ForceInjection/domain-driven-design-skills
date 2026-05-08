---
name: telemetry-pr-insights
description: Concise, PR-friendly telemetry reports scoped to current branch lifetime. For CI/automation.
---

# Telemetry PR Insights

## Scope

### Default: Branch Lifetime

1. Find merge-base: `git merge-base HEAD origin/main`
2. Get timestamp: `git show -s --format=%cI <merge_base>`
3. Query events where `timestamp >= branch_start` for current workspace

### Fallback: Last 7 Days

If Git unavailable or merge-base fails.

---

## Data Access (Combined Platforms)

**Database**: `~/.blueplane/telemetry.db`

- **Claude Code** (`claude_raw_traces`):
  - Filter by `cwd LIKE '/path/to/workspace%'`
  - Tokens: `input_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, `output_tokens`
  - Model: `message_model`, Role: `message_role`, Branch: `git_branch`

- **Cursor** (`cursor_sessions` + `cursor_raw_traces`):
  - Step 1: Get `workspace_hash` from `cursor_sessions WHERE workspace_path LIKE '/path/to/workspace%'`
  - Step 2: Get `composer_id`s from `cursor_raw_traces WHERE event_type='composer' AND workspace_hash=?`
  - Step 3: Filter bubbles by composer_id extracted from `item_key = "bubbleId:{composerId}:{bubbleId}"`
  - Tokens: `token_count_up_until_here` (cumulative only; use for activity, not precise totals)
  - Message type: `message_type` (0=user, 1=assistant, often NULL for ~all events)
  - Model: **not stored** (always treated as unknown)

For full schema details, see the **Data Access / Schema Reference** section in `telemetry-insights/SKILL.md`. This skill uses the same combined Cursor + Claude access patterns, but scoped to the PR branch window.

### Tool Usage & Workflow Patterns (Claude Code only)

**Data source**: Decompress `event_data` blob from `claude_raw_traces`

```python
import zlib, json
decompressed = zlib.decompress(row['event_data'])
event = json.loads(decompressed)
tools = event['payload']['entry_data']['message']['content']
# Filter: item['type'] == 'tool_use'
# Extract: item['name'], item['input']['file_path'], item['input']['command']
```

**Tool operation churn** (detect both productive and unproductive patterns):

**Negative patterns** (wasted effort):
- Files written then deleted without commit (e.g., created but not in git)
- Same file edited multiple times in short succession (trial-and-error)
- Bash commands repeated with similar patterns (debugging loops)
- Write operations for files later removed (unwanted artifacts)

**Positive patterns** (intentional iteration):
- Progressive refinement: Write → Read → Edit (deliberate improvement)
- Test-driven flow: Write test → Run → Edit code → Run (TDD cycle)
- Exploration: Multiple Read/Grep before Write (research-based development)
- Read-before-edit ratio > 0.8 (careful, informed changes)

**Workflow efficiency signals**:
- Tool distribution (Bash, Write, Edit, Read, Task usage)
- Read-before-edit ratio (higher = more careful)
- File touch count (edits per unique file path)
- Time between tool uses (rapid = reactive, spaced = deliberate)

Cross-reference with git to classify churn:
- Compare Write/Edit file paths against final committed files
- Flag operations on files not in `git diff --name-only`
- Distinguish exploration (positive) from mistakes (negative)

---

## Metrics (Lean Subset)

```json
{
  "window": {
    "analysis_scope": "branch_pr|time_period",
    "branch_name": "...",
    "branch_start": "YYYY-MM-DD",
    "days_active": N
  },
  "activity": {
    "total_prompts": N,
    "total_responses": N,
    "breakdown": {
      "claude_code": {"prompts": N, "responses": N},
      "cursor": {"prompts": N, "responses": N}
    },
    "active_days": N
  },
  "tokens": {
    "note": "Claude Code only - Cursor does not provide per-message token counts",
    "total_input": N,
    "total_output": N,
    "ratio": X.XX
  },
  "models": {
    "note": "Claude Code only - Cursor does not persist model names",
    "breakdown": {"model-name": N}
  },
  "daily": {
    "YYYY-MM-DD": {"input": N, "output": N, "prompts": N}
  },
  "tool_usage": {
    "note": "Claude Code only - extracted from event_data blob",
    "distribution": {"Bash": N, "Write": N, "Edit": N, "Read": N},
    "workflow_signals": {
      "read_before_edit_ratio": X.XX,
      "files_created_not_committed": N,
      "high_churn_files": ["path/to/file"]
    },
    "pattern_classification": {
      "productive_iteration": N,
      "trial_and_error": N
    }
  }
}
```

---

## Derived Insights (3-5 max)

- **Efficiency**: token ratio, cache usage, assessment (Claude Code only)
- **Activity Pattern**: steady/bursty/spiky, platform distribution
- **Model Strategy**: dominant model, cost awareness (Claude Code only)
- **Platform Usage**: Claude Code vs Cursor breakdown, workflow insights
- **Workflow Quality**: Tool usage patterns, churn classification (productive vs wasteful), read-before-edit discipline

---

## Output Format

### Executive Summary (2-4 sentences)

**First sentence MUST state time frame**:
- "Since this branch diverged from `main` on YYYY-MM-DD, ..."
- "Over the last 7 days, ..."

Then: activity level, efficiency, standout patterns.

### Key Metrics (compact)

**Activity** (combined across platforms)
- Total prompts / responses
- Breakdown by platform (Claude Code vs Cursor)
- Active days

**Tokens** (Claude Code only)
- Input/output tokens and ratio
- Per-day snapshot (3-5 days max)

**Models** (Claude Code only)
- Model distribution
- Strategic usage patterns

**Tool Usage & Workflow** (Claude Code only, optional)
- Tool operation distribution
- Files created but not committed (potential waste)
- Workflow patterns (productive iteration vs trial-and-error)
- Read-before-edit ratio

### Recommendations (3-5 bullets)

Pragmatic, low-risk suggestions. No personal commentary.

---

## Privacy

- Never include raw code content
- No verbatim prompts/responses
- Focus on aggregated metrics only
