---
name: multi-agent
description: Orchestrate autonomous agent teams to complete complex tasks. PM dynamically selects specialized agents based on task classification and enforces non-negotiable principles. Supports local and remote agents, persistent sessions, and continuous learning through skills.
---

# Multi-Agent Orchestrator

## Overview

This skill enables long-running (4-8 hour) autonomous agent workflows. A PM agent **dynamically selects** specialized agents (explore, plan, architect, dev, test, review) based on task needs, enforcing software engineering principles.

**Key Features:**
- **Dynamic agent selection** based on task classification
- **Non-negotiable principles** (review always, human plan review, plan before code)
- **Human review gates** for task.md and plan.md (high-leverage checkpoints)
- Signal-based decisions (no hardcoded timeouts)
- Persistent agent sessions with follow-up instructions
- Remote coding support (dev/architect via SSH)
- Standardized handoff documents for agent communication
- PM maintains progress.md (single source of truth)
- Project-agnostic framework (tasks/skills in project directory)
- Supports both Claude and Kiro CLI

## Getting Started

### Step 1: Setup Agents (One-Time)

Generate the agent catalog for your project:

```bash
./scripts/setup-agents /path/to/project
```

This creates `.claude/agents/*.md` and `.kiro/agents/*.json`. Run once per project.

### Step 2: Create a Task

```bash
# Interactive (prompts for goal, criteria, context)
./scripts/task --project /path/to/project create my-feature

# Non-interactive (agent bootstraps task.md from goal)
./scripts/task --project /path/to/project --goal "Add user authentication" create my-feature

# Non-interactive (use existing task.md file)
./scripts/task --project /path/to/project --task-file ./my-task.md create my-feature
```

This creates `tasks/my-feature/` with directories and a `task.md` file.

### Step 3: Refine task.md (Optional)

Edit `task.md` to add agent configuration, especially for remote coding:

```bash
vi tasks/my-feature/task.md
```

Example task.md with agent config:

```markdown
# Task: my-feature

## Goal
Add user authentication to the API

## Acceptance Criteria
- [ ] Login endpoint returns JWT token
- [ ] Token validation middleware works
- [ ] Tests pass

## Context
Using existing Express app in src/api/

## Validation
```bash
npm test
curl -X POST localhost:3000/login -d '{"user":"test"}'
```

## Agent Config
```yaml
dev:
  cwd: user@remote:/path/to/project   # Remote coding via SSH
  skills: [my-project-skill]

architect:
  cwd: user@remote:/path/to/project

test:
  cwd: /local/path                    # Device access is always local
  skills: [device-access]
```
```

### Step 4: Start PM

```bash
./scripts/task --project /path/to/project start my-feature

# Or with different CLI
./scripts/task --project /path/to/project --cli claude start my-feature
```

### Step 5: Monitor Progress

```bash
# Check status
./scripts/task status my-feature

# Trigger PM check-in (or set up cron)
./scripts/pm-check-in.sh my-feature

# Attach to watch PM work
./scripts/task attach my-feature
```

### Step 6: Complete

```bash
./scripts/task stop my-feature
```

## Quick Reference

```bash
./scripts/setup-agents <project>                    # One-time: create agents
./scripts/task create <name> [--goal "text"]        # Create task (no PM)
./scripts/task start <name> [--cli claude|kiro]     # Start PM for task
./scripts/task status <name>                        # Check task status
./scripts/task attach <name>                        # Attach to PM session
./scripts/task logs <name>                          # View task logs
./scripts/task stop <name>                          # Stop task
./scripts/pm-check-in.sh <name>                     # Trigger PM check-in
```

**Typical workflow:**
```bash
./scripts/task --project /my/project create my-task --goal "Fix bug X"
vi /my/project/tasks/my-task/task.md   # Refine, add agent config
./scripts/task --project /my/project --cli claude start my-task
```

## CLI Support

| CLI | Agent Location | Agent Format | Invoke |
|-----|----------------|--------------|--------|
| claude | `.claude/agents/<name>.md` | Markdown with YAML frontmatter | `claude <name>` |
| kiro | `.kiro/agents/<name>.json` | JSON | `kiro-cli --agent <name>` |

The `setup-agents` script generates agents for both CLIs from shared templates.

## Project Structure

```
~/.claude/skills/multi-agent/       # This skill (shared framework)
├── scripts/                        # CLI and orchestration scripts
├── references/
│   ├── agent-prompts/system-prompts.md  # Shared system prompts
│   ├── claude_agents.md            # Claude-specific config (tools, model)
│   └── kiro_agents.md              # Kiro-specific config (tools, model)
└── SKILL.md

<project>/                          # Your project
├── .claude/agents/                 # Generated Claude agents
├── .kiro/agents/                   # Generated Kiro agents
├── .claude/skills/                 # Project-specific skills
├── tasks/                          # Task instances
│   └── {task-name}/
│       ├── task.md                 # Requirements + agent config
│       ├── plan.md                 # Implementation plan (human-reviewed)
│       ├── pm_state.json           # PM tracking state
│       ├── progress.md             # PM's status summary
│       ├── handoffs/               # Agent communication
│       ├── artifacts/              # Generated outputs (namespaced)
│       │   ├── explore-hotplug/    # Research findings by topic
│       │   ├── plan/               # Design documents
│       │   ├── dev-v1/             # Implementation iteration 1
│       │   ├── test/               # Test results, logs
│       │   └── review-iter1/       # Review findings
│       └── scratchpad/             # Agent working files
└── src/                            # Project source code
```

## Agent Catalog

Before starting tasks, generate the agent catalog for your project:

```bash
./scripts/setup-agents /path/to/project
```

This is a **one-time setup** that creates:
- `.claude/agents/*.md` - Claude agent files
- `.kiro/agents/*.json` - Kiro agent files

The agent catalog contains all available agents the PM can choose from. **Existing agents are skipped** (not overwritten). After bootstrap, you can:
- Edit agent prompts to customize behavior
- Add new agents for project-specific needs
- Adjust tools, model, or skills per agent

The generated agents are yours to modify. Re-running `setup-agents` will only add missing agents.

## Dynamic Agent Selection

PM dynamically selects agents based on:

### Task Classification

| Dimension | Options | Impact |
|-----------|---------|--------|
| **Complexity** | low / medium / high | Determines planning depth |
| **Type** | feature / bugfix / refactor / research / hotfix | Suggests agent patterns |
| **Scope** | single-file / module / cross-cutting | Affects architecture needs |
| **Familiarity** | known / unknown area | Affects exploration needs |

### Non-Negotiable Principles

| Principle | Requirement | Agent/Action |
|-----------|-------------|--------------|
| **Validate & Iterate** | All work reviewed before completion | review (ALWAYS) |
| **Document Decisions** | Capture context for posterity | PM updates progress.md |
| **Plan Before Code** | Understand approach before implementing | plan (unless trivial) |
| **Human Review of Plan** | Plan reviewed before implementation | PM pauses for human approval |
| **Design Before Build** | Complex changes need architecture | architect (when needed) |

### PM Agent Delegation Rules (CRITICAL)

**PM orchestrates, PM does NOT investigate.**

| PM Should | PM Should NOT |
|-----------|---------------|
| Create handoff documents | Read logs directly |
| Spawn explore/dev agents | Run grep/search commands |
| Monitor agent progress | Analyze code/data itself |
| Make workflow decisions | Debug issues directly |
| Summarize agent findings | Write implementation code |

**If PM finds itself investigating directly (reading logs, running searches), it should STOP and spawn an explore agent instead.**

### PM Helper Agents

PM should run headless one-shot commands for routine operations:

| Helper | Purpose | Returns |
|--------|---------|---------|
| status-check | Capture-pane + parse status | 1-2 line summary |
| sync-artifacts | Pull files from remote | List of synced files |
| artifact-inventory | What does next agent need? | Paths + locations |
| summarize-handoffs | Digest recent handoffs | Bullet point summary |

**Why helpers?**
- Raw `tmux capture-pane` floods PM context with 100+ lines
- Artifact sync requires commands that produce verbose output
- Reading 5 handoffs consumes context better used for orchestration

**Headless execution:**
```bash
# Claude
claude -p "Context... Goal... Return ONLY: ..." --allowedTools "Bash,Read"

# Kiro
kiro-cli chat --no-interactive "Context... Goal..." --trust-tools shell,read
```

See `references/agent-prompts/pm.md` for full helper command templates.

**Artifact sync workflow (CRITICAL):**
Before spawning LOCAL agent that needs REMOTE artifacts:
1. Run artifact-inventory helper to identify needed files
2. Sync artifacts from remote to local
3. Include LOCAL paths in handoff (not remote paths)

### Handoff Best Practices

Every handoff to an agent should include:

1. **Task description** - Clear, specific goal
2. **Skills reference from task.md** - Include skills the agent should use:
   ```yaml
   Skills available:
     skills: [amelia-logs, amelia-athena]
   ```
3. **Search commands** - Specific commands to run
4. **Expected output location** - Where to write findings
5. **Done criteria** - How agent knows it's finished

**When user corrects PM:**
- Update handoff with correction
- Spawn NEW agent with corrected instructions
- Don't try to fix it in current PM context

### Remote Agent Handoffs

Remote agents run LOCALLY on the target machine. Do NOT include SSH connection details - use local paths only.

### Continuation vs Fresh Agent

When spawning same agent type again, PM decides: **continue existing session** or **spawn fresh agent**.

| Situation | Action | Reason |
|-----------|--------|--------|
| Minor correction (same topic) | `send_to_agent.sh` | Preserve context |
| Follow-up question | `send_to_agent.sh` | Build on findings |
| Different topic/investigation | `spawn_agent.sh --topic X` | Fresh perspective |
| Major pivot in approach | `spawn_agent.sh --topic X` | Avoid context pollution |
| Agent already exited | `spawn_agent.sh --topic X` | Must spawn new |
| Context overflow risk | `spawn_agent.sh` with cliff notes | Summarize previous work |

**Parallel agents**: Multiple agents of same type can run simultaneously on different topics (e.g., `explore-logs` and `explore-athena`).

### Cliff Notes for Fresh Agents

When spawning a fresh agent that continues previous work, include a summary in the handoff:

```markdown
## Previous Findings (see: handoffs/explore-hotplug-20251201.md)
- Cable physically connected during failures
- Headset client disconnected at 18:16:51 UTC
- ROS service timeouts observed

## Your Task
Now investigate set_feature_state failures...
```

This gives the new agent context without full history.

### Agent Selection Matrix

| Task Type | explore | plan | architect | dev | test | review |
|-----------|:-------:|:----:|:---------:|:---:|:----:|:------:|
| **Feature (high)** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Feature (med)** | ? | ✓ | ? | ✓ | ? | ✓ |
| **Feature (low)** | - | ? | - | ✓ | ? | ✓ |
| **Bugfix** | ? | ? | - | ✓ | ✓ | ✓ |
| **Hotfix** | - | - | - | ✓ | ? | ✓ |
| **Refactor** | ✓ | ✓ | ? | ✓ | ✓ | ✓ |
| **Research** | ✓ | ? | - | ? | ? | ? |

**Legend:** ✓ = Always, ? = Conditional, - = Usually skip

PM documents selection rationale in `pm_state.json`, including why agents were selected or skipped.

## Handoff Naming Convention

All handoffs use: `{content}-{YYYYMMDD}-{HHMMSS}.md`

| Agent | Output Pattern | Example |
|-------|---------------|---------|
| explore | `research-{ts}.md` | `research-20251127-090000.md` |
| plan | `plan-{ts}.md` | `plan-20251127-100000.md` |
| architect | `design-{ts}.md` | `design-20251127-110000.md` |
| dev | `PR-iter{N}-{ts}.md` | `PR-iter1-20251127-120000.md` |
| test | `test-results-{ts}.md` | `test-results-20251127-150000.md` |
| review | `review-iter{N}-{ts}.md` | `review-iter1-20251127-160000.md` |
| PM | `pm-to-{agent}-{ts}.md` | `pm-to-dev-20251127-170000.md` |

## Artifact Storage Convention

Artifacts are namespaced by agent and topic: `artifacts/<agent>-<topic>/`

PM advertises the artifact path when spawning agents. Agents should:
1. Store generated outputs in their artifact directory
2. Reference artifact paths in handoff documents
3. Read artifacts from previous agents as specified in PM handoff

| Agent | Artifact Path | Example Contents |
|-------|---------------|------------------|
| explore | `artifacts/explore-{topic}/` | Analysis reports, diagrams, timelines |
| plan | `artifacts/plan/` | Design docs, architecture diagrams |
| architect | `artifacts/architect/` | Interface definitions, system diagrams |
| dev | `artifacts/dev-{topic}/` | Generated code, patches, configs |
| test | `artifacts/test/` | Logs, screenshots, test results |
| review | `artifacts/review-iter{N}/` | Review reports, findings |

**Example handoff referencing artifacts:**
```markdown
## Context
See research at: artifacts/explore-hotplug/analysis.md

## Artifacts Generated
- artifacts/dev-v1/fix.patch
- artifacts/dev-v1/config.yaml
```

### Artifact Preservation (PM Responsibility)

**PM must ensure critical outputs are preserved as files, not just prose in handoffs.**

| Must Preserve | Examples | Action |
|---------------|----------|--------|
| Code from dev | Scripts, patches | Verify file exists in `artifacts/dev-*/` |
| Commands from test | Repro scripts, test commands | Save to `artifacts/test/` |
| Smoking guns | Log snippets proving root cause | Extract to `artifacts/evidence/` |
| Key findings | Timing analysis, race proofs | Ensure analysis file exists |

**PM Artifact Check:** After each agent completes, PM reviews handoff for code blocks, log snippets, and key findings. If important content exists only in prose, PM follows up to ensure it's saved as a file.

## Scripts

### Setup

**`scripts/setup-agents`** - Generate agent files for project
```bash
./scripts/setup-agents /path/to/project
```

### User-Facing

**`scripts/task`** - Main CLI
```bash
# Create task (does NOT start PM)
./scripts/task create <name> [--goal <text>] [--task-file <path>]

# Start PM for existing task
./scripts/task start <name> [--cli claude|kiro]

# Other commands
./scripts/task status <name>
./scripts/task list
./scripts/task attach <name>
./scripts/task stop <name>
./scripts/task logs <name>

# Global flags (before command)
--project <path>      # Project directory
--cli claude|kiro     # CLI to use (default: kiro)
```

### PM-Facing

**`scripts/spawn_agent.sh`** - Spawn agent in tmux window
```bash
# NOTE: --handoff and --cli are REQUIRED

# Local agent with topic (window name: explore-hotplug)
./scripts/spawn_agent.sh --task <name> --agent explore --window 7 \
  --topic hotplug --handoff <file> --cli claude

# Dev agent with version topic (window name: dev-v2)
./scripts/spawn_agent.sh --task <name> --agent dev --window 3 \
  --topic v2 --handoff <file> --cli kiro

# Remote agent - creates window in single remote session
# Session name: task-{name}-agents (ONE session per task, all agents share it)
./scripts/spawn_agent.sh --task <name> --agent dev --window 3 \
  --remote user@host:/path --topic impl --handoff <file> --cli claude
```

**`scripts/send_to_remote_agent.sh`** - Send follow-up to remote agent
```bash
./scripts/send_to_remote_agent.sh --task <name> --window 3 \
  --remote user@host --message "your follow-up message"
```

**`scripts/sync_from_remote.sh`** - Pull results from remote agent
```bash
# REQUIRED after remote agent completes
./scripts/sync_from_remote.sh --task <name> --remote user@host:/path
```

**Topic examples:**
- `explore-hotplug`, `explore-setfeat`, `explore-athena`
- `dev-v1`, `dev-v2`, `dev-auth`
- `plan-initial`, `plan-revised`

**`scripts/send_to_agent.sh`** - Send follow-up to existing agent
```bash
./scripts/send_to_agent.sh --task <name> --agent <type> --handoff <file>
```

**`scripts/pm-check-in.sh`** - Trigger PM check-in
```bash
./scripts/pm-check-in.sh <task-name> [--project <path>]
```

## Agent Config in task.md

task.md can specify per-agent configuration:

```yaml
## Agent Config

dev:
  cwd: user@host:/remote/path    # Remote coding via SSH
  skills: [project-skill]

architect:
  cwd: user@host:/remote/path

test:
  cwd: /local/path               # Device access is always local
  skills: [device-access]
```

Default cwd for all agents is `<project>` (project root).

## PM Check-in Flow

```
pm-check-in.sh triggered (cron or manual)
         │
         ▼
┌─────────────────────────┐
│  Nudge PM               │  (scans handoffs, updates progress.md, decides next action)
└─────────────────────────┘
```

PM handles progress tracking directly (no separate scribe agent).

Set up cron for periodic check-ins:
```bash
*/10 * * * * /path/to/scripts/pm-check-in.sh my-task --project /path/to/project
```

## Human Review Gates

The framework includes blocking human review checkpoints at high-leverage points:

### Plan Review Gate

After plan agent completes, PM **blocks** until human approves the plan:

1. Plan agent writes `plan.md` with implementation phases
2. PM verifies plan quality (auto/manual verification, file:line refs, scope)
3. PM sets `human_review_gates.plan = "awaiting"` in pm_state.json
4. PM updates progress.md with AWAITING_REVIEW status
5. **PM STOPS** - does not spawn dev agent until human approves
6. Human reviews plan.md and provides approval or feedback
7. On approval: PM proceeds to implementation
8. On feedback: PM sends follow-up to plan agent, re-reviews

### Why Human Review at Planning?

From ACE-FCA: "Bad plan = hundreds of bad lines of code"

Human leverage hierarchy:
- Bad research → thousands of bad lines of code
- Bad plan → hundreds of bad lines of code
- Bad code → bad code

A few minutes reviewing the plan prevents hours of wasted implementation.

## Tmux Session Structure

### Local Session

Session: `task-{task-name}-pm`

Window numbers are **sequential based on spawn order**, not tied to agent roles:

| Window | Purpose |
|--------|---------|
| 0 | PM (always) |
| 1, 2, 3, ... | Agents in spawn order |

Example with topics:
| Window | Name | Purpose |
|--------|------|---------|
| 0 | pm | Orchestrator |
| 1 | explore-logs | First spawned agent |
| 2 | plan | Second spawned |
| 3 | dev-v1 | Third spawned |
| 4 | explore-athena | Fourth spawned (parallel explore) |

Window names use format `{agent}-{topic}` when topic is provided.

### Remote Agent Architecture

All remote agents for a task share **ONE tmux session** on the remote host:

- **Session name:** `task-{task-name}-agents`
- **Each agent gets its own window** (sequential, based on spawn order)
- **No local window created** - user monitors via iTerm

**File Transfer (No automatic sync):**
1. **At spawn:** Handoff file is copied to remote via scp (automatic)
2. **After completion:** PM must run `sync_from_remote.sh` to pull results

**User monitoring:**
```bash
ssh -t user@host 'tmux attach -t task-{name}-agents'
```

**PM sends commands via SSH:**
```bash
# Using helper script
./scripts/send_to_remote_agent.sh --task <name> --window 3 \
  --remote user@host --message "your message"

# Or directly
ssh host "tmux send-keys -t 'task-{name}-agents:{window}' 'message' Enter"
```

**PM pulls results:**
```bash
./scripts/sync_from_remote.sh --task <name> --remote user@host:/path
```

## Iterative Feedback Loop (Exploratory Tasks)

For complex debugging, research, or exploratory tasks, PM should use an **iterative feedback loop** with domain expert agents rather than one-shot delegation.

### Pattern: PM <-> Plan <-> Expert Agent Loop

```
┌──────────────────────────────────────────────────────────────────────┐
│                         ITERATIVE LOOP                               │
│                                                                      │
│   PM ──handoff──> Expert Agent (explore/dev/test)                    │
│    │                    │                                            │
│    │              runs experiment                                    │
│    │                    │                                            │
│    │ <───────────── handoff with results                             │
│    │                                                                 │
│    ├── analyze results                                               │
│    ├── if goal NOT achieved:                                         │
│    │      ├── spawn plan agent with learnings + failed approaches    │
│    │      │         │                                                │
│    │      │   plan-iteration-N.md (next approach)                    │
│    │      │         │                                                │
│    │      ├── HUMAN REVIEW GATE (unless iteration_plan_review: auto) │
│    │      │         │                                                │
│    │      └── spawn expert agent with approved plan (loop)           │
│    └── if goal achieved OR blocked:                                  │
│         └── exit loop                                                │
└──────────────────────────────────────────────────────────────────────┘
```

**With plan_iterations: false** (simpler loop, PM creates handoffs directly):
```
PM ──handoff──> Expert ──results──> PM ──refined handoff──> Expert (loop)
```

### When to Use

| Scenario | Use Iterative Loop? |
|----------|---------------------|
| Bug reproduction with hypothesis testing | YES |
| Root cause analysis with multiple leads | YES |
| Performance optimization with metrics | YES |
| Feature implementation (clear spec) | NO |
| Simple bugfix (obvious solution) | NO |

### Configuration in task.md

Add iteration config to task.md for exploratory tasks:

```yaml
## Iteration Config
max_iterations: 5              # Max attempts before escalating to human
blocked_after: 3               # Flag as blocked after N failures
plan_iterations: true          # Spawn plan agent between iterations (default: true)
success_criteria: |
  - POOL_EXHAUSTED error observed in logs
  - Publisher process crashed (exit code != 0)

## Human Review Overrides
# Options: required (default) | auto | skip
initial_plan_review: required      # Human reviews initial plan.md
iteration_plan_review: required    # Human reviews each iteration plan
```

**Review override options:**
| Value | Behavior |
|-------|----------|
| `required` | Human must approve before proceeding (default) |
| `auto` | PM auto-approves if quality criteria met |
| `skip` | Skip plan agent entirely for that stage |

### PM Responsibilities in Loop

1. **After each iteration:**
   - Read agent's handoff
   - Compare results against success_criteria
   - Document what worked and what didn't in pm_state.json

2. **Before next iteration (with plan_iterations: true):**
   - Spawn plan agent with:
     - All previous attempts and their results
     - What was learned from each attempt
     - Success criteria still to achieve
   - Plan agent produces `plan-iteration-N.md` with next approach
   - **HUMAN REVIEW GATE** (unless `iteration_plan_review: auto|skip`)
   - After approval, spawn expert agent with approved plan

3. **Before next iteration (with plan_iterations: false):**
   - PM synthesizes learnings directly
   - Creates handoff with refined hypothesis/approach
   - Include "cliff notes" of what was tried

4. **Exit conditions:**
   - Success criteria met → proceed to next phase
   - max_iterations reached → escalate to human
   - Agent reports "blocked" → evaluate if unblockable

### Plan Agent Iteration Handoff

When spawning plan agent between iterations, include:

```markdown
# PM → Plan: Iteration {N} Planning

## Goal
{Original success criteria from task.md}

## Previous Attempts
| Iteration | Approach | Result | Insight |
|-----------|----------|--------|---------|
| 1 | {approach} | {survived/crashed/blocked} | {what we learned} |
| 2 | {approach} | {survived/crashed/blocked} | {what we learned} |

## Constraints
- Must not retry approaches that failed for same reason
- Must build on insights from previous iterations

## Deliverable
Write `plan-iteration-{N}.md` with:
1. Analysis of why previous approaches failed
2. New hypothesis based on learnings
3. Specific approach for next iteration
4. Expected outcome and verification method
```

### Example: Bug Reproduction Loop

```markdown
## Iteration 1 Handoff (PM -> explore)
Goal: Reproduce POOL_EXHAUSTED crash
Approach: Kill both subscribers simultaneously

## Iteration 1 Results (explore -> PM)
- 16K BLOCKED events observed
- reclaimed_slots=1 every time (no crash)
- Publisher survived

## Iteration 2 Handoff (PM -> explore)
Previous attempts: Killing subscribers triggers "ACKed by all" code path
New hypothesis: Need readers alive but selectively ACKing
Approach: Try smaller pool size via XML config

## Iteration 2 Results...
```

### pm_state.json Tracking

```json
{
  "iterative_loops": {
    "config": {
      "max_iterations": 5,
      "plan_iterations": true,
      "iteration_plan_review": "required"
    },
    "current": {
      "goal": "Reproduce POOL_EXHAUSTED crash",
      "expert_agent": "explore",
      "iteration": 3,
      "attempts": [
        {"iteration": 1, "approach": "kill both subs", "result": "survived", "insight": "ACKed-by-all path"},
        {"iteration": 2, "approach": "slower readers", "result": "survived", "insight": "reclaimed_slots=1"}
      ],
      "current_plan": {
        "file": "plan-iteration-3.md",
        "approach": "smaller pool via XML config",
        "status": "awaiting_human_review"
      }
    }
  },
  "human_review_gates": {
    "task": { "status": "approved", "timestamp": "..." },
    "plan": { "status": "approved", "timestamp": "..." },
    "iteration_plan_3": { "status": "awaiting", "file": "plan-iteration-3.md", "timestamp": "..." }
  }
}
```

### Benefits

- **Human leverage at highest point**: Plan review before each iteration catches bad approaches early
- **Accumulated knowledge**: Each iteration builds on previous learnings
- **Systematic exploration**: Plan agent ensures we don't retry same failed approaches
- **Human visibility**: progress.md shows iteration history, iteration plans available for review
- **Graceful degradation**: Escalates when stuck, doesn't loop forever
- **Configurable autonomy**: `iteration_plan_review: auto` for fully autonomous, `required` for maximum oversight

## Decision Framework

PM makes signal-based decisions (NO hardcoded timeouts):

| Signal | Action |
|--------|--------|
| Agent STATUS: COMPLETE | Spawn next agent in workflow (check human gates first) |
| Agent STATUS: NEEDS_REVIEW | Spawn review |
| Agent STATUS: BLOCKED | Evaluate: unblock or escalate |
| Plan agent COMPLETE | Set plan gate to "awaiting", STOP for human review |
| Human approves plan | Proceed to implementation |
| Review RESULT: PASS | Update progress.md with final summary, complete task |
| Review RESULT: FAIL | Send follow-up to dev with feedback |
| Missing handoff | Send follow-up or use capture-pane fallback |

**Review owns retry logic.** No "max 3 attempts" - review decides if more iterations worthwhile.

### pm_state.json Structure

PM tracks dynamic selection and rationale:

```json
{
  "status": "ACTIVE",
  "task_classification": {
    "complexity": "medium",
    "type": "feature",
    "scope": "module",
    "scope_paths": ["src/api/", "src/models/"],
    "familiarity": "known"
  },
  "available_agents": ["explore", "plan", "architect", "dev", "test", "review"],
  "selected_workflow": {
    "agents": ["explore", "plan", "dev", "review"],
    "skipped": {
      "architect": "no new interfaces, extending existing pattern",
      "test": "no testable acceptance criteria specified"
    },
    "rationale": "Medium complexity feature, familiar codebase area",
    "adaptations": []
  },
  "human_review_gates": {
    "task": { "status": "approved", "timestamp": "2025-11-30T09:00:00Z" },
    "plan": { "status": "awaiting", "file": "plan.md", "timestamp": "2025-11-30T10:00:00Z" }
  },
  "principles_satisfied": {
    "validate_and_iterate": "pending",
    "document_decisions": "pending",
    "plan_before_code": true,
    "human_review_of_plan": "awaiting",
    "design_before_build": "skipped - no new interfaces"
  },
  "current_phase": "plan",
  "iteration": 1,
  "spawned_agents": [
    {"agent": "explore", "topic": "hotplug", "window": 1, "status": "complete", "handoff": "explore-20251201-085449.md"},
    {"agent": "explore", "topic": "setfeat", "window": 6, "status": "complete", "handoff": "explore-20251201-090753.md"},
    {"agent": "plan", "window": 2, "status": "complete", "handoff": "plan-20251201-100000.md"}
  ],
  "last_checkin": "2025-11-30T10:30:00Z"
}
```

## References

- `references/agent-prompts/*.md` - System prompts for each agent
- `references/claude_agents.md` - Claude agent configs (tools, model)
- `references/kiro_agents.md` - Kiro agent configs (tools, model)
- `references/decision-protocols.md` - PM decision framework
- `references/task-template.md` - Template for task.md
- `docs/PRFAQ-Agent-Orchestrator.md` - Product vision
- `docs/Implementation-Agent-Orchestrator.md` - Technical design
