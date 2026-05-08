---
name: spec-pipeline
description: Explains the required sequence and success signals for each stage.
---

# Spec pipeline (ADR → PRD → SDS → SEA™ → Codegen)


## Sequence
1) ADR (decisions + constraints)
2) PRD (requirements satisfying ADR IDs)
3) SDS YAML (design satisfying PRD IDs)
4) SEA™ (domain + flows, Flow-only CQRS tagging)
5) Run `nx run workspace:check`

## Success signals
- Specs include correct IDs and traceability
- SEA™ passes flow lint
- Repo remains clean after generation

## Common failure signals
- Missing `@cqrs` on Flow → flow lint fails
- Wrong namespace → compiler rejects
- Regeneration changes files every run → determinism failure (fix generator ordering)
