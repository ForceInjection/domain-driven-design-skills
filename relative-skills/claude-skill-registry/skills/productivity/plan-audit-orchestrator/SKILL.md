---
name: plan-audit-orchestrator
description: Coordinate planning, auditing, and validation workflows. Use when the user mentions plan/planning, audit/auditing, review, or validation for engineering, data, or pipeline work.
---

# Plan Audit Orchestrator

## Overview
Route requests to the right modular planning or auditing skill and enforce research and validation gates.

## Workflow
1. Classify intent: plan, audit, validate, or a combination.
2. Select modules:
   - Plan needed -> plan-with-research
   - Plan review -> plan-audit
   - Validation or confidence request -> plan-validation
   - Production readiness or release -> production-readiness
   - Codebase understanding -> codebase-audit
   - Missing tools or required installs -> action-gate
3. If honesty/urgency/frustration is present, apply truthfulness-check alongside the chosen module(s).
4. Execute in order: plan -> audit -> validation -> readiness. Skip steps only when user asks.
5. State assumptions, missing inputs, and what evidence is used.

## Output Rules
- Include scope, constraints, assumptions, risks, and validation steps.
- Call out unknowns and confidence when evidence is thin.
- Summarize sources used or state if research is still needed.
- Ask only the minimum questions to unblock.

## Acceptance Criteria
- Name the modules selected and the order used.
- Mark any skipped modules and why.
- State what evidence was checked vs assumed.
