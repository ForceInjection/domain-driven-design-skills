---
name: orchestrate-spec
description: Auto-detects next pending Smart Orchestrator component, spawns 2-3 research agents, generates evidence-backed specs, validates, and offers optional implementation with automatic progress tracking.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
---

# Orchestrate Spec Skill (Enhanced v2.0)

> **Research-First Specification System with Auto-Progress** - Deterministic, evidence-based component specification with automatic progress tracking and implementation loop

**Validated On**: Phase 0 SDK Integration (2026-01-05)

**Status**: ✅ VALIDATED - Production-ready with auto-progress

---

## Purpose

Generates validated, evidence-backed specifications for Smart Orchestrator components through **automatic progress detection, parallel research, specification writing, validation, and optional implementation**.

**User End State**: Just say `/orchestrate-spec` and the skill automatically determines what's next, executes, updates progress, and offers to implement.

---

## What This Skill Does (Enhanced v2.0)

### Full Automated Workflow

```
User: /orchestrate-spec
  ↓
1. CHECK PROGRESS (read or create PROGRESS.md)
  ↓ Identify next pending component
2. RESEARCH (2-3 parallel agents)
  ↓ Verified findings
3. SPECIFY (component + test specs in parallel)
  ↓ Evidence-backed specs
4. VALIDATE (automated checks)
  ↓ PASS/FAIL result
5. UPDATE PROGRESS (mark current component done)
  ↓
6. OFFER IMPLEMENTATION (optional)
   If yes: IMPLEMENT → VERIFY → UPDATE PROGRESS
   ↓
7. REPORT NEXT COMPONENT (ready for next /orchestrate-spec)
```

### Key Enhancements

| Feature             | v1.0                                    | v2.0 (Enhanced)                                     |
| ------------------- | --------------------------------------- | --------------------------------------------------- |
| Progress Tracking   | Manual                                  | **Automatic (PROGRESS.md)**                         |
| Component Detection | User specifies                          | **Auto-detects next pending**                       |
| Implementation      | Separate task                           | **Optional in-skill implementation**                |
| Workflow            | Research → Spec → Validate              | **Research → Spec → Validate → Implement → Verify** |
| Invocation          | `/orchestrate-spec [component] [phase]` | **`/orchestrate-spec` (auto-mode)**                 |

---

## How to Invoke

### Auto-Progress Mode (Recommended)

```bash
/orchestrate-spec
```

**What happens**:

1. Reads PROGRESS.md to see what's done
2. Identifies next pending component
3. Executes full workflow
4. Updates progress
5. Reports next component

**Perfect for**: "I don't remember what's next, just continue"

### Specific Component Mode

```bash
/orchestrate-spec [component-name] [phase-number]
```

**Examples**:

- `/orchestrate-spec ResourceManager Phase-1`
- `/orchestrate-spec PromptValidator Phase-1`

**Perfect for**: "I want to specify this specific component now"

### Force Reset Progress

```bash
/orchestrate-spec --reset-progress
```

**What happens**: Rebuilds PROGRESS.md from filesystem scan

**Perfect for**: Progress file corrupted or out of sync

---

## Implementation Steps (Full Workflow)

### Step 0: Check/Create Progress File

**Location**: `.claude/orchestration/specs/PROGRESS.md`

**Action**:

1. Try to read PROGRESS.md
2. If missing → Create from integration plan
3. If corrupted → Rebuild from filesystem scan

**Progress File Format**:

```yaml
# Orchestration Specification Progress

metadata:
  version: "2.0.0"
  last_updated: "2026-01-05T12:00:00Z"
  current_phase: "Phase-0"
  current_component: "SDKIntegration"
  total_components: 9
  completed: 1
  pending: 8

components:
  - name: SDKIntegration
    phase: Phase-0
    status: specified # pending | researching | specified | implementing | implemented | verified
    research_complete: true
    component_spec_complete: true
    test_spec_complete: true
    validation_status: PASS
    implementation_status: pending
    files:
      - research-spec.yaml
      - research-findings.md
      - component-spec.yaml
      - test-spec.yaml
      - VALIDATION_SUMMARY.md
    started: "2026-01-05T10:00:00Z"
    completed: "2026-01-05T14:00:00Z"

  - name: BaselineMeasurement
    phase: Phase-0
    status: pending
    # ... (same structure)

next_component:
  name: BaselineMeasurement
  phase: Phase-0
  reason: "First pending component in Phase-0"
  action: specify
```

**Output**: Progress state loaded, next component identified

---

### Step 1: Initialize Research Specification

**Input**: Component name (from auto-detection or user input)

**Action**:

1. Create directory structure: `specs/phase-[X]/[component]/evidence/`
2. Copy template: `_templates/research-spec.yaml.template`
3. Replace placeholders with component-specific values
4. Define 3-5 research questions
5. Define 2-3 parallel research streams

**Update Progress**: Set status to "researching"

**Output**: `research-spec.yaml` ready for agent execution

---

### Step 2: Execute Parallel Research (MAX 2-3 AGENTS)

**CRITICAL**: Never exceed 2-3 parallel research agents (system resource limit)

**Agent 1 Prompt Template**:

```
Task: Research [research question from stream_1]
Evidence Sources: context7 MCP, official documentation
Output: evidence/[component]-capabilities.md
Format: Markdown with verified claims table

Requirements:
- Every claim must have verified source (URL)
- No speculation ("I think", "probably")
- Include code examples for API usage
- References section with all sources

Return structured summary with:
- claims_verified: [list]
- evidence_sources: [list of URLs]
- code_examples: [list]
- next_steps: [action items]
```

**Agent 2 Prompt Template**:

```
Task: Research [research question from stream_2]
Evidence Sources: system measurements, codebase analysis
Output: evidence/[component]-constraints.md
Format: Markdown with verified claims table

Requirements:
- All thresholds must have measured values
- No guessing or estimating
- Include verification methodology
- Reference existing infrastructure

Return structured summary with:
- thresholds_verified: [map of metric → value]
- constraints_identified: [list]
- integration_points: [list]
- risks: [list with probability/impact]
```

**Wait for both agents to complete before proceeding.**

**Update Progress**: Set research_complete to true

---

### Step 3: Consolidate Research Findings

**Action**:

1. Read both agent outputs
2. Merge into single `research-findings.md`
3. Create claims table with evidence IDs
4. Include all code examples
5. Complete references section

**Output Format**:

```markdown
# Research Evidence: [Component Name]

## Evidence Summary

[Consolidated findings from both agents]

## Verified Claims Table

| Claim ID | Capability | Status | Evidence Source | Verified By |

## Code Evidence

[All code examples from agents]

## References

[All source URLs]

## Next Steps

✅ Research complete
⏳ Create component-spec.yaml
⏳ Create test-spec.yaml
```

**Update Progress**: Add research-findings.md to files list

---

### Step 4: Write Component Specification

**Action**:

1. Copy template: `_templates/component-spec.yaml.template`
2. Define interface (class, methods, dependencies)
3. For each method:
   - Define signature with input/output types
   - Define 3-4 failure modes (detection + recovery + timeout)
   - Map claims to evidence IDs
4. Define integration points
5. Define 3-6 success criteria (measurable, binary)
6. Define constraints and prohibitions

**Evidence Requirements**:

```yaml
- id: "EVIDENCE-XXX"
  claim: "[specific verifiable claim]"
  source: "evidence/research-findings.md#[claim-id]"
  verification_method: "[how to verify]"
  required_for: "[method or feature]"
```

**Failure Mode Requirements**:

```yaml
- error: "ERROR_CODE"
  description: "[what went wrong]"
  detection: "[how to detect]"
  recovery: "[how to recover]"
  timeout: "[seconds or N/A]"
```

**Success Criteria Requirements**:

````yaml
- criterion: "[Measurable criterion]"
  measurement_method: |
    ```bash
    # Verification command
    ```
  threshold: "[PASS/FAIL condition]"
  evidence: "[What log proves it works]"
  status: "pending"
  priority: "critical | high | medium"
````

**Update Progress**: Set component_spec_complete to true

---

### Step 5: Write Test Specification (Can Parallelize)

**Action**:

1. Copy template: `_templates/test-spec.yaml.template`
2. Define test requirements (coverage ≥80%, test counts)
3. For each method in component-spec:
   - Define 3+ unit test cases
   - Define coverage requirements (80-90%)
4. Define 3+ integration test scenarios
5. Define 4+ chaos test scenarios
6. Map success criteria to component-spec
7. Define verification commands

**Test Case Format**:

```yaml
- name: "[Test case name]"
  input:
    [param]: "[value]"
  expected:
    [result]: "[expected value]"
  assertions:
    - "[assertion description]"
```

**Update Progress**: Set test_spec_complete to true

---

### Step 6: Validate Specifications

**Action**:

1. Copy validation summary from Phase 0 example
2. Verify evidence alignment:
   - All claims in component-spec have evidence IDs
   - All evidence IDs trace to research-findings.md
   - All test requirements map to component methods
3. Verify completeness:
   - All 8 sections present in both specs
   - All failure modes have detection + recovery + timeout
   - All success criteria are measurable (PASS/FAIL)
4. Generate validation summary

**Validation Checklist**:

```
Evidence Alignment:
✅ All claims have evidence IDs
✅ All IDs trace to research-findings.md
✅ All tests map to component methods
✅ All thresholds verified numbers

Completeness:
✅ 8/8 sections in component-spec
✅ 8/8 sections in test-spec
✅ All failure modes documented
✅ All success criteria measurable

Gate Readiness:
✅ 3-6 criteria with verification commands
✅ Go/No-Go paths documented
✅ Iteration loop referenced
```

**Output**: `VALIDATION_SUMMARY.md` with PASS/FAIL result

**Update Progress**:

- Set validation_status to "PASS" or "FAIL"
- Set status to "specified"
- Mark component completed

---

### Step 7: Offer Implementation (NEW in v2.0)

**Action**: After validation PASS, ask user:

```
✅ Specification complete: [Component Name]
Validation result: PASS

Would you like to implement this component now? (y/n)

If yes:
  - Implement component code
  - Run quality gates (typecheck, lint, test)
  - Update progress status to "implemented"

If no:
  - Update progress status to "specified"
  - Continue to next component
```

**Implementation Workflow** (if user confirms):

1. Spawn developer agent with component-spec.yaml
2. Implement all methods with failure modes in `rad-engineer/src/`
3. Write all tests from test-spec.yaml in `rad-engineer/test/`
4. Run quality gates:
   - `cd rad-engineer && pnpm typecheck` (must pass, 0 errors)
   - `cd rad-engineer && pnpm lint` (must pass)
   - `cd rad-engineer && pnpm test` (must pass, ≥80% coverage)
5. Update progress:
   - Set implementation_status to "implemented"
   - Add implementation files to list

**Implementation Root**: `rad-engineer/` (see CLAUDE.md for structure)

**Update Progress**: Set implementation_status

---

### Step 8: Update Progress and Report Next

**Action**:

1. Update PROGRESS.md with current component status
2. Calculate next pending component
3. Generate summary report

**Return to User**:

```markdown
## ✅ Complete: [Component Name] (Phase [X])

### Status: SPECIFIED ✅

**Validation**: PASS
**Evidence Quality**: HIGH
**Files Created**: [list]

### Progress Updated

**Total Components**: 9
**Completed**: [N]
**Pending**: [9-N]

### Next Component

**Name**: [Next Component Name]
**Phase**: Phase [X]
**Action**: Ready to specify

### Ready to Continue

Type `/orchestrate-spec` to continue with next component
```

---

## Progress File Management

### Initial Creation

**When PROGRESS.md doesn't exist**:

Create from integration plan (SMART_ORCHESTRATOR_EXECUTE_INTEGRATION_PLAN.md):

```yaml
components:
  - name: SDKIntegration
    phase: Phase-0
    status: specified # Already validated
    completed: "2026-01-05"

  - name: BaselineMeasurement
    phase: Phase-0
    status: pending

  - name: ResourceManager
    phase: Phase-1
    status: pending

  # ... all 9 components from plan
```

### Recovery from Corruption

**When PROGRESS.md is corrupted or missing**:

Rebuild from filesystem scan:

```bash
# Scan specs directory structure
find specs/phase-* -name "VALIDATION_SUMMARY.md" | while read file; do
  # Extract component info from path
  # Mark as "specified" if VALIDATION_SUMMARY.md exists with PASS
done
```

### Status Transitions

```
pending → researching → specified → (implementing) → implemented → verified
```

| Status         | Meaning                  | Next Action           |
| -------------- | ------------------------ | --------------------- |
| `pending`      | Not started                                    | Research phase                        |
| `researching`  | Agents running                                   | Wait for completion                   |
| `specified`    | Specs validated, PASS                          | Implement in `rad-engineer/` (optional) |
| `implementing` | Code being written in `rad-engineer/src/`      | Wait for completion                   |
| `implemented`  | Code in `rad-engineer/`, tests pass            | Ready for integration                 |
| `verified`     | Full integration tested                        | Done                                  |

---

## Auto-Detection Logic

### Finding Next Component

**Priority Order**:

1. Current phase, first pending component
2. Next phase, first component
3. End of plan (all done)

**Algorithm**:

```
next_component = null
for phase in [Phase-0, Phase-1, Phase-2, Phase-3]:
  for component in components[phase]:
    if component.status == "pending":
      next_component = component
      break
  if next_component:
    break
```

**Output**: Next component name and phase

---

## Full Workflow Example

### User Session

```
User: /orchestrate-spec

Skill: Checking progress...
  → PROGRESS.md found
  → Current: SDKIntegration (specified)
  → Next: BaselineMeasurement (pending)

Skill: Starting specification for BaselineMeasurement...
  → Step 1: Research (2 parallel agents)
  → Step 2: Consolidate findings
  → Step 3: Write component spec
  → Step 4: Write test spec
  → Step 5: Validate

Skill: ✅ Specification complete: BaselineMeasurement
  Validation: PASS
  Files: [list]

Skill: Would you like to implement now? (y/n)

User: y

Skill: Implementing BaselineMeasurement...
  → Spawning developer agent
  → Implementing in rad-engineer/src/baseline/...
  → Writing tests in rad-engineer/test/baseline/...
  → Running quality gates...
  → PASS ✅

Skill: ✅ Implementation complete: BaselineMeasurement
  Progress updated: 2/9 components done
  Location: rad-engineer/src/baseline/

Skill: Next component: ResourceManager (Phase-1)
  Ready when you are: /orchestrate-spec
```

---

## Constraints and Rules

### CRITICAL: Agent Concurrency Limit

```
⛔ MAXIMUM 2-3 PARALLEL RESEARCH AGENTS
   Exceeding this causes system crash (verified: 5 agents = 685 threads)
```

**Enforcement**:

1. Count currently running agents before spawning
2. If count ≥ 2: Wait for completion
3. Only spawn when count < 2

### Prohibited Patterns

**NEVER use in research findings**:

- "I think..." → Find primary source or mark as unknown
- "It should work..." → Test and document actual result
- "Probably..." → Verify or state "unknown"
- "We can assume..." → Document as assumption, not claim

**NEVER use in specifications**:

- Unverified claims → Must have evidence ID
- Missing failure modes → Every method needs 3-4 failure modes
- Non-measurable criteria → Must have PASS/FAIL threshold
- Hardcoded thresholds → Must be verified numbers from research

### Quality Gates

**Before marking specs as ready**:

- [ ] All claims have verified sources
- [ ] All evidence IDs trace to research-findings.md
- [ ] All failure modes have detection + recovery + timeout
- [ ] All success criteria are measurable (binary)
- [ ] Test coverage ≥80% specified
- [ ] Go/No-Go criteria documented

**Before marking implementation as ready**:

- [ ] All methods implemented in `rad-engineer/src/`
- [ ] All tests written in `rad-engineer/test/`
- [ ] `cd rad-engineer && pnpm typecheck` passes (0 errors)
- [ ] `cd rad-engineer && pnpm lint` passes
- [ ] `cd rad-engineer && pnpm test` passes (≥80% coverage)

---

## Component Catalog (From 16-Week Plan)

### Phase 0: Prerequisites & Foundation (Week 1-4)

- ✅ **SDK Integration** - VALIDATED
- ⏳ **Baseline Measurement** - Pending

### Phase 1: Core Orchestrator (Week 5-8)

- ⏳ **ResourceManager** - Resource limits, concurrent agent management
- ⏳ **PromptValidator** - Prompt size validation, sanitization
- ⏳ **ResponseParser** - Parse agent responses, extract outputs

### Phase 2: Advanced Features (Week 9-12)

- ⏳ **WaveOrchestrator** - Wave execution, dependency management
- ⏳ **StateManager** - State persistence, recovery, compaction

### Phase 3: Integration & Polish (Week 13-16)

- ⏳ **ErrorRecoveryEngine** - Retry logic, circuit breakers, saga pattern
- ⏳ **SecurityLayer** - Input sanitization, output scanning, audit logging

---

## Error Handling

### Progress File Missing

**Detection**: PROGRESS.md not found

**Recovery**:

1. Create from integration plan
2. Scan specs directory for existing components
3. Initialize all components as "pending"
4. Update existing ones to "specified" if VALIDATION_SUMMARY.md exists

### Progress File Corrupted

**Detection**: Invalid YAML, missing fields

**Recovery**:

1. Backup corrupted file
2. Rebuild from filesystem scan
3. Cross-check with integration plan
4. Restore completed components from directory structure

### Research Agents Return Speculation

**Detection**: Claims without source URLs, "I think" patterns

**Recovery**:

1. Re-prompt agent: "Use context7 MCP to verify against official documentation"
2. If still speculation, mark as "unknown" not "verified"
3. Document assumptions separately from claims

### Validation FAIL

**Detection**: Validation summary shows FAIL result

**Recovery**:

1. Identify failing criteria from validation summary
2. Fix component-spec or test-spec
3. Re-run validation
4. Max 3 iterations, then escalate

### Implementation Tests Fail

**Detection**: Quality gates fail (typecheck, lint, test)

**Recovery**:

1. Read error output from `rad-engineer/`
2. Spawn fix agent to address failures in `rad-engineer/src/`
3. Re-run quality gates: `cd rad-engineer && pnpm typecheck && pnpm lint && pnpm test`
4. Max 3 iterations, then mark as "blocked"

---

## Dependencies

### Required Tools

- context7 MCP: For retrieving library documentation
- Task tool: For spawning parallel research agents
- Templates: Located in `_templates/` directory

### Required Files

- `.claude/orchestration/specs/_templates/*.template`
- `.claude/orchestration/specs/PROGRESS.md` (auto-created)
- `.claude/orchestration/docs/planning/SMART_ORCHESTRATOR_EXECUTE_INTEGRATION_PLAN.md`
- `.claude/orchestration/docs/planning/PHASE_GATE_ITERATION_PATTERN.md`

### External Documentation

- Phase 0 validated example
- Integration plan (16-week timeline)
- Phase gate iteration pattern

---

## Success Metrics

**Per Component**:

- ✅ All claims verified against primary sources
- ✅ All evidence IDs trace to research findings
- ✅ All methods have documented failure modes
- ✅ All success criteria are measurable
- ✅ Test coverage ≥80% specified
- ✅ Validation summary with PASS result
- ✅ (Optional) Implementation passes quality gates

**Overall**:

- Time per component: 4-6 hours (spec), +2-4 hours (implement)
- Evidence quality: HIGH (no speculation)
- Spec quality: PRODUCTION-READY
- Implementation readiness: IMMEDIATE
- Progress tracking: AUTOMATIC

---

## Quick Reference

| Command                              | What It Does                                         |
| ------------------------------------ | ---------------------------------------------------- |
| `/orchestrate-spec`                  | Auto-detect next component, specify, update progress |
| `/orchestrate-spec [comp] [phase]`   | Specify specific component                           |
| `/orchestrate-spec --reset-progress` | Rebuild PROGRESS.md from filesystem                  |

---

**Version**: 2.0.0 (Enhanced with Auto-Progress)
**Status**: VALIDATED and PRODUCTION-READY
**Last Updated**: 2026-01-05
**Validated Against**: Phase 0 SDK Integration
**New in v2.0**: Automatic progress tracking, next-component detection, optional implementation loop
