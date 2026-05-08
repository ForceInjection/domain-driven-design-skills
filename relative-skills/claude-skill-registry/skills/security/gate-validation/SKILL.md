---
name: gate-validation
description: Validate that quality, security, and release gates are correctly defined, implemented, and enforced with evidence.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - TodoWrite
model: sonnet
x-version: 3.2.0
x-category: quality
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
Assess gate definitions and enforcement mechanisms to ensure the right checks run at the right time with measurable outcomes and auditable evidence.

### Trigger Conditions
- **Positive:** preparing for release, auditing CI/CD gates, or validating that policy controls are active (tests, coverage, security scans, approvals).
- **Negative:** single code review findings (use code-review-assistant) or runtime bug hunts (use functionality-audit).

### Guardrails
- **Confidence ceiling:** Append `Confidence: X.XX (ceiling: TYPE Y.YY)` using ceilings {inference/report 0.70, research 0.85, observation/definition 0.95}.
- **Evidence-first:** For each gate, capture definition, enforcement point, and proof (logs, status checks, metrics).
- **Structure-first:** Keep examples/tests that show compliant vs. noncompliant pipelines.
- **Adversarial validation:** Attempt bypass scenarios and ensure detections fire; record gaps.

### Execution Phases
1. **Inventory & Scope**
   - List required gates (tests, coverage, lint, SAST/DAST, approvals, change management) and environments.
   - Identify owners and SLAs for each gate.
2. **Design vs. Implementation Review**
   - Compare documented gate policy to pipeline configuration (CI files, branch rules, deployment scripts).
   - Note mismatches and missing controls.
3. **Enforcement Testing**
   - Run simulations: failing tests, coverage drops, lint violations, vulnerable dependencies, missing approvals.
   - Capture evidence of block/allow outcomes.
4. **Reporting & Remediation**
   - Summarize gaps, severity, and recommended fixes (policy updates, tooling changes, training).
   - Log follow-ups and owners; provide confidence with ceiling.

### Output Format
- Gate inventory with definition, enforcement point, and owner.
- Evidence of pass/fail behavior for each tested scenario.
- Gaps with remediation steps and prioritization.
- Confidence statement using ceiling syntax.

### Validation Checklist
- [ ] Gate list confirmed against policy.
- [ ] Implementation matches design or deviations recorded.
- [ ] Bypass attempts executed with evidence.
- [ ] Owners and SLAs captured for remediations.
- [ ] Confidence ceiling included; English-only output.

Confidence: 0.71 (ceiling: inference 0.70) - SOP rewritten with Prompt Architect confidence discipline and Skill Forge structure-first validation.
