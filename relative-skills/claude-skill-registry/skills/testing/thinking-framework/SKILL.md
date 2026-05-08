---
name: thinking-framework
description: Use this when complex problem-solving, root cause analysis, strategic decision-making, or systematic thinking is needed. Applies 15 thinking methods with multi-agent orchestration and Clear-Thought MCP integration for enhanced analysis quality.
---

# Thinking Framework v4.0 - Multi-Agent Systematic Problem-Solving

> **Purpose**: Decompose complex problems and derive optimal solutions using structured thinking methods with multi-agent orchestration.

## When to Use

- **Complex problem-solving** requiring systematic decomposition
- **Root cause analysis** (finding the "why" behind issues)
- **Strategic planning** (strengths/weaknesses, competitive analysis)
- **Decision-making** under uncertainty
- **Innovation** requiring creative breakthroughs

---

## Multi-Agent Architecture (v4.0)

### Agent Tiers

| Tier | Agent | Role | Clear-Thought Tools |
|------|-------|------|---------------------|
| **1** | Orchestrator | Workflow coordination, complexity routing | decisionframework, metacognitivemonitoring |
| **2** | ProblemDefiner | Problem clarification, decomposition | sequentialthinking, mentalmodel |
| **2** | MethodExecutor | Thinking method execution | Method-specific (see mapping) |
| **2** | StrategyArchitect | Strategic synthesis, action planning | collaborativereasoning, decisionframework |

### Complexity-Based Routing

| Complexity | Indicators | Agent Configuration | Time |
|------------|-----------|---------------------|------|
| **Simple** | Single cause, 1-2 steps, clear path | Orchestrator only | <30s |
| **Medium** | 3-5 factors, some ambiguity | + 1 Specialist (sequential) | 30-60s |
| **Complex** | 5+ factors, high interdependencies | + 2-3 Specialists (parallel) | 60s+ |

### Clear-Thought Tool Mapping

| Method | Primary Tool | Secondary Tool |
|--------|--------------|----------------|
| **5 Why** | `sequentialthinking` | - |
| **Fishbone** | `collaborativereasoning` | `visualreasoning` |
| **First Principles** | `mentalmodel` | `sequentialthinking` |
| **SWOT** | `decisionframework` | - |
| **OODA Loop** | `scientificmethod` | `sequentialthinking` |
| **Dialectic** | `structuredargumentation` | - |
| **Design Thinking** | `collaborativereasoning` | `mentalmodel` |
| **Pareto** | `decisionframework` | `mentalmodel` |
| **PDCA** | `scientificmethod` | - |
| **GAP Analysis** | `visualreasoning` | `decisionframework` |
| **Kepner-Tregoe** | `decisionframework` | `structuredargumentation` |
| **TRIZ** | `mentalmodel` | `designpattern` |
| **SCAMPER** | `collaborativereasoning` | - |
| **DMAIC** | `scientificmethod` | `metacognitivemonitoring` |

---

## Execution Routines

### A. Divide & Conquer (Complex Only)

**When**: Systemic problems with 5+ interdependent factors

**Agent Flow**:
```
Orchestrator → ProblemDefiner → MethodExecutor(s) [parallel] → StrategyArchitect → Orchestrator
```

**Process**:
1. **Orchestrator**: Assess complexity, dispatch ProblemDefiner
2. **ProblemDefiner**: Define problem, decompose into ≤5 sub-problems
3. **MethodExecutor(s)**: Analyze sub-problems in parallel
   - Each executor uses appropriate Clear-Thought tool
4. **StrategyArchitect**: Synthesize findings, create action plan
5. **Orchestrator**: Quality gate, final integration

**Output**:
```markdown
## Problem Definition
[Clear statement from ProblemDefiner]

## Sub-Problem Analyses
| Sub-Problem | Method | Root Cause | Recommendation |
|-------------|--------|------------|----------------|
| SP1 | [method] | [cause] | [action] |

## Integrated Strategy
[From StrategyArchitect]

## Quality Assessment
- Confidence: [%]
- Uncertainties: [list]

## Core Insight
[One sentence]
```

---

### B. Method Selection (All Cases)

**When**: Any problem, especially Simple-Medium complexity

**Agent Flow**:
- Simple: Orchestrator only (direct method application)
- Medium: Orchestrator → MethodExecutor → Orchestrator

**Process**:
1. **Classify** problem type
2. **Select** method using matching matrix
3. **Execute** with appropriate Clear-Thought tool
4. **Output** optimized format

**Method-Problem Matching**:

| Problem Type | Methods | Clear-Thought Tool |
|--------------|---------|-------------------|
| root_cause | 5 Why, Fishbone | sequentialthinking, collaborativereasoning |
| creative_innovation | SCAMPER, TRIZ, Design Thinking | collaborativereasoning, mentalmodel |
| strategic_planning | SWOT + 2x2, GAP Analysis | decisionframework, visualreasoning |
| process_improvement | Pareto, PDCA, GAP | decisionframework, scientificmethod |
| decision_making | OODA Loop, Kepner-Tregoe | scientificmethod, decisionframework |

---

### C. Strategy Routine (Strategic Decisions)

**When**: Strategic planning with strengths/weaknesses analysis

**Agent Flow**:
```
Orchestrator → ProblemDefiner → MethodExecutor (SWOT) → StrategyArchitect → Orchestrator
```

**Process**:
1. **Diagnose**: Strengths (with evidence) + Weaknesses (root cause via 5 Why)
2. **Analyze**: Use `decisionframework` for SWOT evaluation
3. **Strategize**: StrategyArchitect creates 2x2 matrix
4. **Plan**: GAP Analysis → Action items

**2x2 Matrix (MANDATORY)**:
```
           │ Maximize Strengths │ Address Weaknesses │
───────────┼────────────────────┼────────────────────┤
High       │   DO FIRST         │   REMOVE RISK      │
Priority   │   (Invest now)     │   (Critical fix)   │
───────────┼────────────────────┼────────────────────┤
Low        │   LONG-TERM R&D    │   STRATEGIC IGNORE │
Priority   │   (Future bet)     │   (Accept risk)    │
```

**Core Strategy Template**:
> "Maximize [strength] through [method], address [weakness] via [action], to achieve [goal]."

---

## Quality Gates

| Gate | Stage | Check | Tool |
|------|-------|-------|------|
| G1 | Problem Definition | Clarity, specificity, boundedness | metacognitivemonitoring |
| G2 | Method Selection | Problem-method fit | decisionframework |
| G3 | Analysis | Depth, evidence, logic | metacognitivemonitoring |
| G4 | Integration | Coherence, completeness, actionability | metacognitivemonitoring |

**Gate Protocol**:
- Complex: All gates mandatory
- Medium: G2 + G4
- Simple: G4 only

---

## Output Guidelines

**Format Selection**:
- Structured comparisons → Markdown tables
- Sequential processes → Numbered lists
- Problem decomposition → Mermaid diagrams
- Strategic decisions → 2x2 Matrix

**Always Include**:
- Complexity assessment (pre-flight)
- Method selection justification
- Confidence score
- One-sentence summary

---

## Quick Reference

- **Agent Prompts**: [agents/](agents/)
- **Method Catalog**: [reference/INDEX.md](reference/INDEX.md)
- **60-sec Selector**: [reference/QUICK_SELECTOR.md](reference/QUICK_SELECTOR.md)
- **Multi-Method Workflows**: [reference/METHOD_COMBINATIONS.md](reference/METHOD_COMBINATIONS.md)
- **Agent Patterns**: [reference/AGENT_PATTERNS.md](reference/AGENT_PATTERNS.md)
- **Practical Examples**: [GUIDE.md](GUIDE.md)

---

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Over-engineering | A Routine for simple problems | Use complexity assessment |
| Under-analysis | Simple method for complex problems | Proper routing |
| Tool mismatch | Wrong Clear-Thought tool for method | Follow mapping table |
| Skip quality gates | Missing validation | Enforce gate protocol |
| Sequential when parallel | Slow complex analysis | Use parallel agents |

---

## Meta

After analysis, briefly reflect:
- What worked? What could improve?
- Was method optimal? Was tool mapping effective?
- Agent coordination smooth?
