---
name: platform-integration
description: Integrate platforms and services with clear contracts and resilient connectors
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
model: sonnet
x-version: 3.2.0
x-category: operations
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
Connect systems through well-defined interfaces, mapping, and resilient middleware with observability and fallback paths.

### Trigger Conditions
- **Positive:** Connect two or more platforms/services; Define data contracts and mappings; Need middleware with retries/backoff and monitoring
- **Negative:** Simple webhook routing (route to hooks-automation); GitHub-specific automation (route to github-integration); Single-API test harness (route to infrastructure/tooling)

### Guardrails
- Structure-first: keep SKILL.md aligned with examples/, tests/, and any resources/references so downstream agents always have scaffolding.
- Adversarial validation is mandatory: cover boundary cases, failure paths, and rollback drills before declaring the SOP complete.
- Prompt hygiene: separate hard vs. soft vs. inferred constraints and confirm inferred constraints before acting.
- Explicit confidence ceilings: format as 'Confidence: X.XX (ceiling: TYPE Y.YY)' and never exceed the ceiling for the claim type.
- MCP traceability: tag sessions WHO=operations-{name}-{session_id}, WHY=skill-execution, and capture evidence links in outputs.
- Avoid anti-patterns: undocumented changes, missing rollback paths, skipped tests, or unbounded automation without approvals.

### Required Artifacts
- SKILL.md (this SOP)
- examples/ for integrations
- tests/ for contract validation
- resources/ for templates

### Execution Phases
1. **Map systems and constraints**
   - Identify APIs, auth models, and data domains
   - Clarify SLAs, throughput, and ordering needs
   - Flag compliance/security requirements

2. **Define contracts and flows**
   - Design payload schemas and transformations
   - Specify retries, backoff, idempotency, and error handling
   - Plan observability, alerts, and dashboards

3. **Implement connectors**
   - Build or configure middleware with least privilege
   - Add structured logging and correlation IDs
   - Test happy-path and failure scenarios

4. **Validate and operate**
   - Run integration tests and performance checks
   - Document runbooks and fallback paths
   - Schedule periodic reviews for drift and SLA health

### Output Format
- Integration specification with auth, endpoints, and contracts
- Data mapping and transformation rules
- Test matrix with happy-path and failure cases
- Deployment and runbook notes with monitoring
- Risk and rollback plan for connector changes

### Validation Checklist
- Auth and permissions validated across systems
- Idempotency/backoff and retries tested
- Monitoring and alerting configured
- Fallback/disablement procedures documented
- Confidence ceiling stated for integration readiness

Confidence: 0.70 (ceiling: inference 0.70) - Platform integration SOP keeps contracts, retries, and observability explicit
