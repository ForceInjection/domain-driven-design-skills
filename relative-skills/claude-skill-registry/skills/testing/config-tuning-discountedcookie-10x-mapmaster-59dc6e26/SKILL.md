---
name: config-tuning
description: >-
  Use when you notice a pattern that should be in the config. Analyzes current
  setup, researches best practices, and proposes specific config changes. Also
  use when asked to improve agent behavior or workflows.
---

# Config Tuning

Analyze and improve OpenCode configuration based on observed patterns.

> **Announce:** "I'm using config-tuning to analyze this pattern and propose config improvements."

## When to Use

- User describes a pattern they noticed (good or bad)
- User asks to improve agent behavior
- User wants to add a new workflow or skill
- After noticing repeated friction in workflows

## Process

### Phase 1: Understand the Pattern

Ask clarifying questions if needed:
- What behavior did you observe?
- When does this happen?
- What would you prefer instead?

### Phase 2: Analyze Current Config

Read relevant files:
```
opencode.jsonc           # Main config
AGENTS.md                # Root rules
.opencode/agent/*.md     # Agent definitions
.opencode/skills/*/      # Existing skills
.opencode/command/*.md   # Existing commands
```

### Phase 3: Research

If the pattern relates to:
- Agent behavior → Research OpenCode agent docs
- Prompting patterns → Research Claude best practices
- Tool usage → Research OpenCode tools docs
- Workflows → Check existing skills for similar patterns

Use `exa_web_search` or `webfetch` for OpenCode docs if needed.

### Phase 4: Propose Changes

Present a structured proposal:

```markdown
## Observation

[What pattern was noticed]

## Analysis

[Why this happens with current config]

## Proposed Changes

### Option A: [Name]
- File: [path]
- Change: [specific edit]
- Tradeoff: [pros/cons]

### Option B: [Name] (if applicable)
- File: [path]
- Change: [specific edit]
- Tradeoff: [pros/cons]

## Recommendation

[Which option and why]
```

### Phase 5: Apply (with approval)

**ALWAYS ASK** before modifying config files.

After approval:
1. Make the changes
2. Explain what was changed
3. Suggest how to test the improvement

## Config Locations

| Config Type | Location | Purpose |
|-------------|----------|---------|
| Main | `opencode.jsonc` | Models, tools, permissions |
| Rules | `AGENTS.md`, `*/AGENTS.md` | Instructions for all agents |
| Agents | `.opencode/agent/*.md` | Specialized agent definitions |
| Skills | `.opencode/skills/*/SKILL.md` | Workflow guides |
| Commands | `.opencode/command/*.md` | Quick shortcuts |

## Common Patterns

### Agent not using skills enough
→ Add `<skill_awareness>` block to AGENTS.md
→ Improve skill descriptions to be more triggering

### Agent doing X when it should do Y
→ Add explicit rule to AGENTS.md or agent definition
→ Consider permission restrictions

### Repeated workflow friction
→ Create a new skill to guide the workflow
→ Or create a command for quick access

### Context getting too large
→ Use progressive disclosure (read docs on-demand)
→ Consider DCP plugin for context pruning

## Red Flags - STOP

If you catch yourself:
- Modifying config without user approval
- Making changes that affect security (permissions)
- Removing existing functionality

STOP. Always get explicit approval for config changes.
