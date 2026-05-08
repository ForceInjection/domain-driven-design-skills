---
name: grey-haven-context-management
description: "Multi-agent workflow orchestration with state persistence, handoff patterns, and resumable workflows. Use when building multi-agent workflows, coordinating complex tasks, or implementing resumable processes. Triggers: 'orchestration', 'workflow', 'context save', 'handoff', 'multi-agent'."
# v2.0.43: Skills to auto-load for orchestration work
skills:
  - grey-haven-code-style
  - grey-haven-testing-strategy
# v2.0.74: Tools for orchestration work
allowed-tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
  - TodoWrite
  - Task
---

# Context Management Skill

Multi-agent workflow orchestration with state persistence, handoff patterns, and resumable workflows.

## Description

This skill enables sophisticated multi-agent workflows through context save/restore operations, supporting sequential handoffs, parallel execution, conditional routing, and long-running resumable workflows.

## Token Efficiency Awareness

Multi-agent architectures have significant token costs. Understand the multipliers:

| Architecture | Token Multiplier | Example (10K input) |
|--------------|------------------|---------------------|
| Single agent | 1x | 10K tokens |
| Agent + tools | 4x | 40K tokens |
| Multi-agent | 15x | 150K tokens |

**Key insight**: A 3-agent workflow costs ~15x more than a single agent. Design accordingly.

## What's Included

### Examples (`examples/`)
- **Sequential handoff** - Linear 4-phase workflow (Design → Implement → Test → Deploy)
- **Parallel execution** - Full-stack feature with frontend + backend + tests (2.25x speedup)
- **Conditional routing** - Dynamic agent selection based on results
- **Resumable workflows** - Checkpoint-based long-running tasks

### Reference Guides (`reference/`)
- **Complete reference** - Save/restore operations, workflow patterns, performance optimization
- **Token efficiency** - Token multipliers, attention budget, context optimization strategies
- **Troubleshooting guide** - 6 issue categories with solutions (save failures, restore failures, performance, corruption)
- **Best practices** - Context design, handoff patterns, error handling, security

### Templates (`templates/`)
- **JSON Schema** - Context structure validation with required/optional fields
- **Context templates** - Ready-to-use structures for different workflow types

### Checklists (`checklists/`)
- **100-point verification** - Comprehensive validation across 10 categories with weighted scoring

## Workflow Patterns

1. **Sequential Handoff** - Agent A → Context Save → Agent B → Context Save → Agent C
2. **Parallel Execution** - Parent spawns 3 agents → Merge results → Integration
3. **Conditional Routing** - Analyze → Route based on conditions → Targeted agent
4. **Resumable Long-Running** - Checkpoints enable resume after interruption

## Performance Metrics

- **Context Size**: Target <100KB for 80% of workflows
- **Serialization**: <200ms (P99)
- **Restore**: <500ms (P99)
- **Speedup**: 2-3x faster with parallel execution

## Use This Skill When

- Building multi-agent workflows
- Need state persistence across sessions
- Coordinating multiple agents on complex tasks
- Implementing resumable long-running processes
- Optimizing workflow execution time

## Related Agents

- `context-manager` - Automated context save/restore with validation
- `tdd-orchestrator` - Multi-agent TDD workflows
- `incident-responder` - Multi-phase incident response

## Quick Start

```bash
# View workflow examples
cat examples/feature-development-handoff.md
cat examples/parallel-workflow-example.md

# Check reference guides
cat reference/INDEX.md
cat reference/workflow-best-practices.md

# Use context schema
cat templates/context-schema-template.json

# Validate context
cat checklists/context-verification-checklist.md
```

## Security

- ✅ Never save secrets in context (use secret references)
- ✅ Implement access control for context files
- ✅ Sanitize before saving (remove API keys, passwords)
- ✅ Use relative file paths (not absolute)

---

**Skill Version**: 1.0
**Last Updated**: 2025-01-15
