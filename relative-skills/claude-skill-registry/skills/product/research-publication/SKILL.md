---
name: research-publication
description: Prepare research outputs for publication with compliance to venue rules, evidence integrity, and confidence ceilings.
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
- Convert research artifacts into submission-ready packages while preserving evidential rigor.
- Enforce venue constraints, ethics/compliance requirements, and explicit ceilings on claims.
- Maintain structure-first documentation for repeatability.

### Trigger Conditions
- **Positive:** preparing papers, artifacts, or supplements for conferences/journals; responding to reviews.
- **Negative:** initial ideation (use `rapid-idea-generator`) or core method design (`method-development`).

### Guardrails
- Constraint buckets: HARD (venue format, policies, deadlines), SOFT (tone, emphasis), INFERRED (reviewer expectations) with sources.
- Two-pass refinement: structure/formatting → epistemic/evidence audit.
- All claims trace to evidence; compliance (ethics, licenses, data) validated.

### Inputs
- Target venue guidelines and templates.
- Final results, figures, tables, and references.
- Ethics approvals, licenses, and author info.

### Workflow
1. **Scope & Constraints**: Capture venue rules, deadlines, and compliance needs; confirm INFERRED expectations.
2. **Structure Pass**: Organize sections, figures/tables, and formatting per template.
3. **Evidence Pass**: Link claims to evidence, check for overclaims, and apply confidence ceilings.
4. **Compliance & QA**: Verify ethics, licenses, checklists, and reproducibility artifacts.
5. **Package & Review**: Produce submission bundle, response notes, and storage locations; update references/examples.

### Validation & Quality Gates
- Formatting and length comply with venue.
- Claims carry evidence and confidence ceilings.
- Compliance artifacts present (ethics, licenses, reproducibility).
- Submission package logged with paths and versioning.

### Response Template
```
**Constraints**
- HARD / SOFT / INFERRED.

**Readiness**
- Sections/figures status, formatting, compliance checks.

**Evidence & Risks**
- Overclaim audit, missing artifacts, reviewer risks.

**Next Steps**
- ...

Confidence: 0.83 (ceiling: research 0.85) - based on compliance and evidence checks.
```

Confidence: 0.83 (ceiling: research 0.85) - reflects validated packaging and compliance review.
