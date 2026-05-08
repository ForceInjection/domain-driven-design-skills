---
name: testing-quality
description: Coordinate research-focused testing and quality validation with clear constraints, gates, and confidence ceilings.
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
- Provide a hub for research testing skills (code review, functionality audit, verification, style audit, theater detection).
- Enforce constraint hygiene, quality gates, and explicit confidence ceilings on test results.
- Maintain structure-first documentation for all sub-skills.

### Trigger Conditions
- **Positive:** any request to validate research code, results, or quality using the contained sub-skills.
- **Negative:** non-research production testing (route to quality/operations categories).

### Guardrails
- Capture HARD / SOFT / INFERRED testing constraints (coverage targets, latency, risk tolerance, compliance).
- Two-pass refinement: choose appropriate sub-skill(s) → validate findings with evidence and ceilings.
- Route tasks to sub-skills: code-review-assistant, functionality-audit, verification-quality, style-audit, theater-detection.

### Inputs
- Artifact to test (code, models, data, results) and context.
- Constraints and success criteria; environment details if applicable.

### Workflow
1. **Scope & Route**: Record constraints and select relevant sub-skills; confirm INFERRED risks.
2. **Plan Checks**: Define coverage, tools, and expected outputs per sub-skill.
3. **Execute Tests**: Run selected skills, gather evidence, and log configurations.
4. **Validate & Synthesize**: Aggregate findings, mark severity, and apply confidence ceilings.
5. **Deliver & Store**: Provide consolidated report and next actions; update references/examples.

### Validation & Quality Gates
- Sub-skill selection justified and constraints mapped.
- Evidence attached to findings; ceilings aligned to evidence type.
- Recommendations include remediation steps and owners.

### Response Template
```
**Scope & Constraints**
- HARD / SOFT / INFERRED.

**Selected Checks**
- Sub-skill → rationale.

**Findings**
- Issue → evidence → severity → confidence ceiling.

**Actions**
- Remediation + owner + due date.

Confidence: 0.81 (ceiling: inference 0.70) - based on executed checks and evidence.
```

Confidence: 0.81 (ceiling: inference 0.70) - reflects validated testing coverage and findings.
