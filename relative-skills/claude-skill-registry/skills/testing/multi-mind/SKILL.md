---
name: multi-mind
description: Multi-specialist collaborative analysis for complex decisions. Spawns parallel subagents with diverse domain expertise to analyze a topic from multiple angles. Use when user says "multi-mind", or for complex architecture decisions, technology choices, strategic planning, or any multi-faceted problem with no obvious right answer.
compatibility: Assumes a filesystem shell; may use network access for external research (prefer native web search if available/enabled; otherwise use `curl`); does not require subagent/task tooling.
---

# Multi-Mind Analysis

Spawn parallel specialist subagents to analyze a complex topic from diverse perspectives, then synthesize their findings into actionable insights.

## When to Use

- Complex architecture or technology decisions
- Strategic planning with multiple tradeoffs
- Evaluating unfamiliar territory
- Design reviews needing diverse perspectives
- Any question where different domains intersect

## Rounds Configuration

- **Default (quick)**: Single round — parallel specialist analysis → synthesis
- **Deep mode**: If user includes "deep", "thorough", "multiple rounds", or "rounds=N":
  - Run N rounds (default 3 if not specified)
  - Each round: specialists review previous findings, cross-pollinate, go deeper

## Process

### 1. Parse Request

Extract:
- The topic/question to analyze
- Round mode: quick (default) or deep (with round count)

### 2. Select Specialists

Analyze the topic and select specialists. Open [SPECIALIST-GUIDE.md](SPECIALIST-GUIDE.md) and follow it for selection criteria.

Specialist count:
- Default to **3** specialists
- Add an obvious **4th** specialist when a distinct stakeholder/domain lens is clearly necessary (avoid marginal or overlapping roles)

Each specialist must have:
- Unique domain expertise relevant to the topic
- Different methodological approach from others
- Distinct risk/opportunity sensitivity

### 3. Launch Parallel Research

Use the Task tool to spawn 3-4 subagents simultaneously. Each subagent prompt should:

```
As a {Specialist Role}, analyze: "{topic}"

Your perspective focuses on: {domain-specific focus areas}

1. If external research is necessary, prefer native web search if available/enabled; otherwise use the shell to retrieve primary sources (for example with `curl`)
2. Analyze the topic from your specialist perspective
3. Identify risks, opportunities, and considerations others might miss
4. Provide concrete recommendations from your viewpoint

Be specific and actionable. Cite sources from your research.
```

### 4. Synthesize Findings

After all subagents return, synthesize using [SYNTHESIS-GUIDE.md](SYNTHESIS-GUIDE.md).

### 5. Deep Mode (if requested)

For each additional round:
- Share previous round's synthesis with specialists
- Ask them to: challenge assumptions, go deeper, identify what was missed
- Re-synthesize with new insights

## Output Format

```
## Multi-Mind Analysis: {Topic}

**Mode**: {Quick | Deep (N rounds)} | **Specialists**: {list}

### Specialist Perspectives

**{Specialist 1}**: {key findings and recommendations}

**{Specialist 2}**: {key findings and recommendations}

**{Specialist 3}**: {key findings and recommendations}

[**{Specialist 4}**: {if applicable}]

### Synthesis

**Key Insights**:
- {Insight that emerged from multiple perspectives}
- {Insight that emerged from multiple perspectives}

**Points of Agreement**:
- {Where specialists aligned}

**Points of Tension**:
- {Where specialists disagreed and why}

**Recommendations**:
1. {Actionable recommendation with rationale}
2. {Actionable recommendation with rationale}

**Remaining Uncertainties**:
- {What couldn't be resolved}

**Suggested Next Steps**:
- {Concrete action to move forward}
```

## Anti-Repetition (Deep Mode)

When running multiple rounds:
- Track what has been thoroughly covered
- Push specialists toward new angles, not rehashing
- Each round should produce genuinely new insights
- Synthesize without homogenizing distinct perspectives
