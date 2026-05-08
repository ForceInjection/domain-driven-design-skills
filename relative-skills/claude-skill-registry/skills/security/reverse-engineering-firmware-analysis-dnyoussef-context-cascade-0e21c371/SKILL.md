---
name: reverse-engineering-firmware-analysis
description: Extended firmware analysis for embedded/IoT images with deep extraction, emulation, and vulnerability assessment.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
model: sonnet
x-version: 3.2.0
x-category: security
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



## Purpose
Perform comprehensive firmware analysis: partition extraction, config/secret hunting, service hardening review, and emulation-based behavior analysis. Aligns with **skill-forge** structure-first and **prompt-architect** constraint/confidence standards.

## Use When / Redirect When
- **Use when:** complex firmware with custom partitions, update paths, or services that need behavioral validation.
- **Redirect when:** general binary analysis (`reverse-engineer-debug`/`-deep`) or quick IOC-only triage (`reverse-engineering-quick-triage`).

## Guardrails
- Authorized firmware/hardware only; respect licenses/export rules.
- Isolated environments with snapshots; never flash production devices.
- Sanitize secrets; avoid external uploads without approval.
- Confidence ceilings enforced (inference/report ≤0.70, research 0.85, observation/definition 0.95).

## Prompt Architecture Overlay
1. HARD/SOFT/INFERRED constraints (device model, arch, services of interest, outputs needed).
2. Two-pass refinement: structure → epistemic.
3. English-only output with explicit confidence line.

## SOP (Extended Firmware Loop)
1. **Scope & Setup**: Authorization, hashes, device metadata, and objectives; stage isolated workspace.
2. **Extraction & Mapping**: Unpack partitions; identify file systems and startup/init flows; map attack surface (services, ports, update channels).
3. **Static Review**: Hunt for credentials/keys/endpoints, unsafe defaults, crypto misuse, and outdated components (CVE mapping).
4. **Emulation/Dynamic (if allowed)**: qemu/chroot for service behavior; capture logs/traces and persistence/install paths.
5. **Validation & Delivery**: Cross-check static/dynamic findings; produce SBOM, remediation plan, and archive artifacts to `skills/security/reverse-engineering-extended/reverse-engineering-firmware-analysis/{project}/{timestamp}` with MCP tags (`WHO=reverse-engineering-firmware-analysis-{session}`, `WHY=skill-execution`).

## Deliverables
- Firmware report (attack surface, findings, CVE/CWE mapping) and SBOM.
- Evidence bundle (extraction logs, configs, traces) with timestamps.
- Remediation/hardening guidance and safe update/rollback notes.

## Quality Gates
- Structure-first documentation; missing resources/examples/tests tracked.
- Chain-of-custody maintained (hashes, env, tool versions).
- Evidence with confidence ceilings; dual validation for critical/high.
- Isolation and approval confirmed before emulation.

## Anti-Patterns
- Flashing unvetted firmware to production devices.
- Publishing secrets or proprietary code.
- Ignoring update/rollback safety.

## Output Format
- Scope + constraints table (HARD/SOFT/INFERRED).
- Findings and SBOM summary with evidence.
- Remediation and validation log.
- Confidence line: `Confidence: X.XX (ceiling: TYPE Y.YY) - reason`.

Confidence: 0.72 (ceiling: inference 0.70) - Extended firmware SOP aligned with skill-forge and prompt-architect standards.
