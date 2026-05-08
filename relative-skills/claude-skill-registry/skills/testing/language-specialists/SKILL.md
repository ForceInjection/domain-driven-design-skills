---
name: language-specialists
description: Route language-specific engineering work to the right specialist and maintain language playbooks.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
model: sonnet
x-category: specialists
x-version: 1.1.0
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
Identify language-specific needs, select the correct specialist (Python or TypeScript), and ensure playbooks/examples/tests stay current.

### Triggers
- **Positive:** Requests that specify a target language stack or need language-tailored guidance.
- **Negative:** Framework-agnostic prompts (use prompt-architect) or non-language-specific architecture (system-design-architect).

### Guardrails
- Structure-first: maintain `SKILL.md`, `readme`, `examples/`, `tests/`, `resources/`; ensure child specialists mirror this structure.
- Constraint hygiene: extract HARD/SOFT/INFERRED needs (runtime, frameworks, tooling, quality gates).
- Routing safety: only assign to specialists with intact docs; flag missing artifacts.
- Confidence ceiling on routing decisions (inference/report 0.70; research 0.85; observation/definition 0.95).

### Execution Phases
1. **Intake**: Capture language, framework, runtime, and constraints (quality, performance, deployment targets).
2. **Routing**: Choose `python-specialist` or `typescript-specialist`; include backup and escalation path.
3. **Handoff**: Provide context, constraints, and existing examples/tests relevant to the stack.
4. **Validation**: Confirm outputs meet language-specific standards (formatters, linters, test matrices).

### Output Format
- Routing decision with constraints (HARD/SOFT/INFERRED).
- Selected specialist + reasoning and validation checks.
- Confidence statement with ceiling.

### Validation Checklist
- [ ] Constraints captured and confirmed.
- [ ] Specialist selected from registry with healthy docs.
- [ ] Examples/tests referenced or gaps flagged.
- [ ] Confidence ceiling stated.

## VCL COMPLIANCE APPENDIX (Internal)
[[HON:teineigo]] [[MOR:root:D-L]] [[COM:Dil+Yonetim]] [[CLS:ge_meta_skill]] [[EVD:-DI<gozlem>]] [[ASP:nesov.]] [[SPC:path:/skills/specialists/language-specialists]]

[[HON:teineigo]] [[MOR:root:E-P-S]] [[COM:Epistemik+Tavan]] [[CLS:ge_rule]] [[EVD:-DI<gozlem>]] [[ASP:nesov.]] [[SPC:coord:EVD-CONF]]


Confidence: 0.71 (ceiling: inference 0.70) - SOP rebuilt using prompt-architect routing clarity and skill-forge structure-first rules.
