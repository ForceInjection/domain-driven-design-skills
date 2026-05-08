---
name: research-gap-visualizer
description: Identify and visualize research gaps, coverage, and conflicts with explicit constraints and evidence.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
model: sonnet
x-version: 3.2.0
x-category: research
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



## STANDARD OPERATING PROCEDURE

### Purpose
- Map what is known vs. unknown for a research topic and highlight actionable gaps.
- Use constraint hygiene and explicit confidence ceilings to avoid overclaiming coverage.
- Preserve structure-first artifacts (SKILL, README, references, examples).

### Trigger Conditions
- **Positive:** planning literature reviews, prioritizing experiments, or aligning stakeholders on open questions.
- **Negative:** pure synthesis without visualization (use `literature-synthesis`) or execution planning (`interactive-planner`).

### Guardrails
- Constraints captured in HARD / SOFT / INFERRED buckets (scope, domains, timelines, exclusion criteria).
- Two-pass refinement: initial gap map → epistemic validation with evidence strength and conflicts.
- Each gap lists required evidence and confidence ceiling for current assessment.

### Inputs
- Research question or topic; inclusion/exclusion criteria.
- Existing sources and their quality.
- Desired visualization format (table, bullet map, graph description).

### Workflow
1. **Scope & Constraints**: Define boundaries and bucket constraints; confirm INFERRED assumptions.
2. **Evidence Inventory**: Catalog sources, claims, and confidence ceilings; mark conflicts.
3. **Gap Mapping**: Identify unaddressed questions, weak evidence areas, and dependencies.
4. **Validation Pass**: Check coverage vs. constraints; ensure gaps have clear evidence needs and owners.
5. **Deliver & Store**: Produce gap map plus recommendations; update references/examples.

### Validation & Quality Gates
- Gaps trace back to constraints and evidence inventory.
- Conflicts and weaknesses called out with ceilings.
- Recommended next steps/owners attached to each gap.

### Response Template
```
**Scope & Constraints**
- HARD / SOFT / INFERRED.

**Coverage Snapshot**
- What is known (source → confidence).
- Conflicts.

**Gaps**
- Gap → evidence needed → owner/next step → confidence ceiling.

Confidence: 0.78 (ceiling: inference 0.70) - based on current evidence inventory.
```

Confidence: 0.78 (ceiling: inference 0.70) - reflects validated gap mapping against available evidence.
