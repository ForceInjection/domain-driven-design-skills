---
name: plan-audit
description: Audit or critique a plan for feasibility, risks, missing steps, and test coverage. Use when the user asks to review, audit, or critique a plan or process.
---

# Plan Audit

## Overview
Evaluate a proposed plan for gaps, risks, and weak validation.

## Workflow
1. Restate the plan scope and goals to confirm alignment.
2. Check for missing steps: dependencies, data migrations, access, approvals, or rollback.
3. Evaluate risks: security, privacy, performance, cost, and maintainability.
4. Assess validation: tests, metrics, and acceptance criteria for each step.
5. Provide fixes: add steps, reorder, or split into phases.

## Audit Output
- Findings grouped by severity: critical, major, minor.
- For each finding, include impact and the recommended change.
- Note any assumptions that need confirmation.

## Honesty Guardrails
- Flag evidence gaps and avoid implying verification that did not happen.
- Provide confidence notes for high-risk claims.

## Acceptance Criteria
- Findings are grouped by severity with impact and fix.
- Assumptions and evidence gaps are explicit.
