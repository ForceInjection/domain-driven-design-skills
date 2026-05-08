---
name: cognitive-lensing
description: Apply multilingual cognitive frames to re-approach complex tasks with targeted reasoning patterns and bias checks.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
model: sonnet
x-version: 3.2.0
x-category: foundry
x-vcl-compliance: v3.1.1
x-cognitive-frames:
  - HON
  - MOR
  - COM
  - CLS
  - EVD
  - ASP
  - SPC
---




### L1 Improvement
- Recast the lensing guide into the Skill Forge section flow with explicit guardrails, patterns, and completion checks.
- Added prompt-architect style constraint extraction and confidence ceilings to prevent overclaiming from speculative frames.

## STANDARD OPERATING PROCEDURE

### Purpose
Switch reasoning frames (linguistic, disciplinary, or persona-based) to unlock alternative solution paths and mitigate bias in complex tasks.

### Trigger Conditions
- Positive: stalled reasoning, need for alternative perspectives, bias detection, or creative exploration.
- Negative/reroute: straightforward prompt rewrites (prompt-architect) or agent creation (agent-creator/agent-creation).

### Guardrails
- Keep outputs in English; cite which lens was applied and why.
- Do not fabricate expertise—ground lens choice in task constraints and evidence.
- Limit to 2-3 focused lenses per pass to avoid fragmentation.
- State confidence ceilings explicitly, especially when using speculative or research lenses.

### Execution Phases
1. **Assessment**: Capture task intent, constraints, and observed failure modes; classify hard/soft/inferred constraints.
2. **Lens Selection**: Choose lenses (e.g., formal proof, UX research, security red-team, socio-technical) mapped to the task.
3. **Application**: Re-articulate the problem through each lens with targeted heuristics and checks.
4. **Synthesis**: Compare insights, resolve conflicts, and propose next actions with confidence ceilings.

### Pattern Recognition
- Analytical stagnation → apply formal/algorithmic lens.
- User impact unclear → apply UX research or accessibility lens.
- Risky changes → apply safety/security lens to uncover failure paths.

### Advanced Techniques
- Use paired lenses (builder vs breaker) to surface hidden assumptions.
- Run time-boxed divergent thinking followed by convergence synthesis.
- Feed lens outputs into prompt-architect for clarity before execution.

### Common Anti-Patterns
- Cycling too many lenses without decision.
- Treating lens opinions as facts; neglecting evidence and ceilings.
- Ignoring domain constraints when adopting a lens.

### Practical Guidelines
- Name the lens, heuristic, and expected impact in each pass.
- Keep synthesized recommendations actionable and prioritized.
- Capture what changed between lenses for traceability.

### Cross-Skill Coordination
- Upstream: prompt-architect to clarify the task.
- Parallel: recursive-improvement to iterate on stuck areas; meta-tools to compose lens outputs into tools.
- Downstream: agent-creation/agent-selector to operationalize chosen approach.

### MCP Requirements
- Optional memory MCP to recall past lens effectiveness; tag WHO=cognitive-lensing-{session}, WHY=skill-execution.

### Input/Output Contracts
```yaml
inputs:
  task: string  # required problem statement
  constraints: list[string]  # optional constraints
  target_lenses: list[string]  # optional lens hints (e.g., security, accessibility)
outputs:
  lens_analyses: list[object]  # lens name, insight, risks
  synthesis: summary  # consolidated recommendation
  next_steps: list[string]  # actions derived from lensing
```

### Recursive Improvement
- Run recursive-improvement when lenses disagree or output is indecisive; focus on evidence gaps and decision criteria.

### Examples
- Apply security red-team + reliability lens to a new API rollout before deployment.
- Use accessibility + onboarding UX lens to rewrite a complex setup guide.

### Troubleshooting
- Lens produces no new insight → select orthogonal lens or consult domain specialists.
- Conflicting recommendations → prioritize by risk, effort, and evidence strength.
- Overconfident claims → restate with ceilings and cite observed data.

### Completion Verification
- [ ] Lenses named with rationale and heuristics applied.
- [ ] Synthesis provided with prioritized actions and ceilings.
- [ ] Traceability of changes between lenses captured.
- [ ] Constraints respected; English-only output.

Confidence: 0.70 (ceiling: inference 0.70) - Lensing SOP rewritten with Skill Forge cadence and prompt-architect ceilings.
