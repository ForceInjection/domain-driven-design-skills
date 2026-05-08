---
name: debate-workflow
description: Multi-agent debate with 3-phase workflow. Optional --deep mode for feedback loop.
license: MIT
---

# Debate Workflow

Multi-agent debate system with 3-phase workflow. Optional deep mode with convergence-based feedback loop.

## When to Use

Activate this skill when:
- User needs multiple perspectives on a decision
- Complex tradeoffs require structured analysis
- Brainstorming needs systematic synthesis
- User invokes `/debate` command

## Core Concepts

### Standard Mode (default)
```
Phase 1 (Parallel) → Phase 2 (Parallel) → Phase 3
```

### Deep Mode (--deep flag)
```
Phase 1 → Phase 2 → Convergence Check ─┬─► (converged) → Phase 3
                                       └─► (not converged) → Phase 2b → Phase 3
```

**Usage:**
- `/debate monolith vs microservices` → Standard 3-phase
- `/debate monolith vs microservices --deep` → With feedback loop

### Agent Roles

| Agent | Focus | Personality |
|-------|-------|-------------|
| Researcher | Evidence, possibilities | Curious, thorough |
| Critic | Risks, weaknesses | Skeptical, constructive |
| Synthesizer | Patterns, integration | Balanced, practical |

## Deep Mode: Convergence Detection

**Only applies when using `--deep` flag.**

### How It Works

After Phase 2, compare the 3 KEY RECOMMENDATIONs from each agent.

### Convergence Criteria (meet ANY)

1. All 3 agents recommend same general direction
2. 2 agents agree AND third acknowledges as valid
3. All agree on decision framework

### Convergence NOT Met If

1. Agents recommend fundamentally opposing directions
2. Key trade-offs still contested without resolution
3. New concerns emerged that weren't addressed

### Decision Flow

| Condition | Action |
|-----------|--------|
| Converged | Proceed to Phase 3 |
| Not converged | Execute Phase 2b (1 additional round) |
| Max rounds reached | Proceed to Phase 3, note "Divergent" status |

## Deep Mode: Feedback Loop (Phase 2b)

Triggered only when convergence NOT met in deep mode. Each agent must:

1. Address specific disagreement directly
2. Either CONCEDE or provide STRONGER justification
3. Propose path forward


## Behavioral Contracts

Each agent has constraints on what they MUST NOT do:

| Agent | MUST NOT |
|-------|----------|
| Researcher | Conclude without evidence gaps; present speculation as fact |
| Critic | Critique without mitigation; skip likelihood/impact estimates |
| Synthesizer | Declare single best option; hide disagreements; force consensus |

These contracts enforce genuine perspective diversity beyond stylistic variation.

## Phase 2 Validation

Before Phase 3, verify each agent:
- [ ] Referenced at least 2 specific claims from other agents
- [ ] Acknowledged at least 1 valid point they initially missed
- [ ] Stated a KEY RECOMMENDATION
- [ ] (Deep mode only) Convergence check was performed

If validation fails: document in output, do not retry silently.

## Error Handling

| Scenario | Action |
|----------|--------|
| Agent Task fails | Note failure, continue with available responses |
| Phase 2 validation fails | Document which requirements not met |
| Agent doesn't follow format | Use available content, note deviation |
| Convergence unclear | Default to Phase 2b (err on thoroughness) |
| Max rounds reached | Proceed to Phase 3, mark as "Divergent" |

## Prompt Isolation

All agent prompts MUST include this preamble to prevent context confusion:

```
CONTEXT ISOLATION: This is a standalone debate exercise. IGNORE any repository, codebase, or file context. Focus ONLY on the debate topic below. Do NOT ask clarifying questions - just produce the requested analysis.
```

This prevents general-purpose subagents from getting distracted by repository context.

## Best Practices

- Include CONTEXT ISOLATION preamble in all agent prompts
- Discussion phase MUST directly reference others' points (mandatory citations)
- Synthesis should acknowledge disagreements, not force consensus
- Include actionable next steps in final output
- Recommend decision frameworks, not decisions
- Max 2 discussion rounds (Phase 2 + Phase 2b) - no infinite loops

## Model Configuration

**Decision**: Use `model: haiku` for all agent Task calls.

**Rationale**:
- Cost efficiency (agent files specify haiku)
- Sufficient for structured debate format

**Override**: For complex topics requiring deeper analysis, orchestrator may use `model: sonnet` for Phase 3 synthesis only.

## Execution

- Use Task tool for parallel execution (faster)
- Feedback loop only triggered when agents diverge

## Output Template

```markdown
## Debate: {topic}

### Phase 1: Individual Perspectives

**Researcher**: {summary}
**Critic**: {summary}
**Synthesizer**: {summary}

### Phase 2: Discussion

{key exchanges and refinements}

### Convergence Status

**Rounds**: {1 or 2}
**Status**: {Converged | Partially Converged | Divergent}
**Key Agreement**: {what agents aligned on}
**Remaining Tension**: {what still differs}

### Phase 3: Final Synthesis

**Consensus**: {what all agree on}
**Tensions**: {unresolved disagreements}
**Decision Framework**: {how to decide, not what to decide}

### Next Steps
- {action item 1}
- {action item 2}
```
