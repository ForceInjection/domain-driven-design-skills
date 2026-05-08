---
name: reverse-engineering-deep
description: Advanced reverse engineering with dynamic tracing, memory inspection, and symbolic execution for complex binaries.
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
Perform level 3-4 reverse engineering: runtime tracing, memory dumps, symbolic path exploration, and exploit validation. Built with **skill-forge** structure-first requirements and **prompt-architect** constraint/evidence rules.

## Use When / Redirect When
- **Use when:** extracting secrets/keys at runtime, generating inputs to reach deep code paths, validating exploitability, or producing full behavioral reports.
- **Redirect when:** quick IOC triage (`reverse-engineering-quick`), firmware focus (`reverse-engineering-firmware`), or lightweight triage (`reverse-engineer-debug`).

## Guardrails
- Strictly isolated sandboxes with snapshots; never on production hosts.
- Contain network activity (block/allowlist only); disable unintended propagation.
- Maintain chain-of-custody (hashes, timestamps, environment).
- Confidence ceilings enforced (inference/report ≤0.70, research 0.85, observation/definition 0.95).

## Prompt Architecture Overlay
1. HARD/SOFT/INFERRED constraints (architecture, obfuscation, goals, risk tolerance, allowed tooling).
2. Two-pass refinement: structure (coverage, safety) then epistemic (evidence, ceilings).
3. English-only outputs with explicit confidence line.

## SOP (Deep Analysis Loop)
1. **Scope & Toolchain**
   - Confirm authorization, sample hashes, target platforms, and objectives (exploit validation, unpacking, IOC extraction).
   - Select tooling: debuggers, dynamic instrumentation, symbolic executors, decompilers, tracers.
2. **Static & Preparation**
   - Unpack/unwrap (if allowed), identify protections (packers, anti-debug), and set hooks.
   - Build test harnesses and snapshots; prep controlled inputs.
3. **Dynamic Execution**
   - Instrument runtime (syscalls, memory, IPC, network), capture dumps, and trace control/data flows.
   - Execute path exploration/symbolic execution to reach guarded code.
4. **Exploitability & Secrets**
   - Validate vulnerability reachability, exploit primitives, and mitigations (ASLR/DEP/CFI).
   - Extract secrets/keys/configs when permitted; sanitize outputs.
5. **Validation & Delivery**
   - Cross-validate static vs. dynamic vs. symbolic findings.
   - Produce reproduction steps, mitigations, and IOC set; archive to `skills/security/reverse-engineering-deep/{project}/{timestamp}` with MCP tags (`WHO=reverse-engineering-deep-{session}`, `WHY=skill-execution`).

## Deliverables
- Full behavioral report with traces, dumps (hashed), and IOC inventory.
- Exploitability assessment with mitigations and recommended fixes.
- Reproduction steps, harnesses/scripts, and sanitized artifacts.

## Quality Gates
- Structure-first documentation; missing resources/examples/tests logged for follow-up.
- Safety controls verified (isolation, snapshots, network controls).
- Evidence per claim with confidence ceilings; dual validation for critical findings.
- Chain-of-custody recorded (hashes, env, timestamps).

## Anti-Patterns
- Running without snapshots or rollback plan.
- Exposing live malware to external services.
- Over-claiming exploitability without proof-of-reach.
- Skipping escalation to firmware/quick triage paths when better fit.

## Output Format
- Scope + constraints table (HARD/SOFT/INFERRED).
- Behavioral/trace summary, IOC list, and exploitability assessment.
- Mitigation recommendations and validation log.
- Confidence line: `Confidence: X.XX (ceiling: TYPE Y.YY) - reason`.

Confidence: 0.72 (ceiling: inference 0.70) - Deep RE SOP rebuilt with skill-forge structure and prompt-architect constraint handling.
