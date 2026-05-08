---
name: eval-framework
description: |
  Framework for capturing, storing, and comparing AI evaluations to measure consistency and completeness.
  Use when: comparing reviews, measuring evaluation quality, running reproducibility tests,
  auditing AI outputs, validating findings across runs.
  Triggers: "compare evaluations", "measure consistency", "evaluation framework", "reproducible review",
  "compare reviews", "validate findings", "audit evaluation".
---

# Evaluation Framework Skill

A meta-framework for measuring the quality, consistency, and completeness of AI-generated evaluations.

## Purpose

When you ask Claude to perform evaluations (architecture reviews, code reviews, security audits), how do you know the output is:
- **Consistent** - Would it find the same issues if run again?
- **Complete** - Is it missing important findings?
- **Accurate** - Are severity ratings calibrated correctly?
- **Reproducible** - Can another model/run replicate results?

This framework answers those questions by:
1. Standardizing evaluation output into a comparable schema
2. Storing results in version-controllable format
3. Providing tools to compare and score evaluations

## Quick Start

### 1. Run an Evaluation with Structured Output

```
"Perform an architecture review of deployment/boot-manager/ using the eval-framework output format"
```

### 2. Compare Two Evaluations

```
"Compare evaluation results from .eval-results/arch-review-001.yaml and .eval-results/arch-review-002.yaml"
```

### 3. Generate Consistency Report

```
"Generate a consistency report for all architecture reviews in .eval-results/"
```

## Output Protocol

When producing evaluations for comparison, you MUST output this exact structure:

### Step 1: Evaluation Header

```yaml
---
evaluation:
  id: "eval-[8-char-hex]"           # Unique identifier
  type: "architecture-review"        # Type of evaluation
  date: "2025-12-12T10:30:00Z"      # ISO 8601 timestamp
  model: "claude-opus-4-5-20251101" # Model that produced this

  target:
    path: "deployment/boot-manager/"  # What was evaluated
    commit: "abc1234"                  # Git commit if applicable
    description: "Boot manager for IoT devices"

  context:
    criteria: "IoT production readiness"  # Evaluation criteria
    scope: "full"                          # full, partial, focused
    time_spent_minutes: 45                 # Approximate time
---
```

### Step 2: Findings Array

Each finding MUST have this structure:

```yaml
findings:
  - id: "CRITICAL-001"
    severity: "critical"           # critical, high, medium, low, info
    category: "thread-safety"      # Normalized category

    location:
      file: "state/machine.py"
      line: 391
      function: "_notify_boot_callbacks"

    title: "Callbacks invoked inside lock"

    evidence: |
      The _notify_boot_callbacks method is called while holding
      self._lock, which can cause deadlocks if callbacks attempt
      to acquire the same lock.

    reasoning: |
      RLock is reentrant within the same thread, but callbacks may:
      - Block on I/O while holding lock
      - Call other locked methods
      - Spawn threads that need the lock
      IoT systems run for months - even rare deadlocks are unacceptable.

    impact: "System hang during state transitions"

    recommendation: |
      Copy callback list inside lock, invoke outside lock.

    fix_applied: true              # Was this fixed in the session?
    work_item: "AB#592"            # Associated work item if any
```

### Step 3: Scores

```yaml
scores:
  categories:
    thread_safety: 6
    resource_management: 8
    error_handling: 7
    state_management: 8
    external_operations: 7
    api_web_layer: 8
    configuration: 9
    code_consistency: 7

  overall: 7.5
  production_ready: false
```

### Step 4: Summary

```yaml
summary:
  total_findings: 15
  by_severity:
    critical: 5
    high: 5
    medium: 3
    low: 2
    info: 0

  top_issues:
    - "CRITICAL-001: Callbacks invoked inside lock"
    - "CRITICAL-002: ContainerManager missing thread safety"
    - "CRITICAL-003: HealthMonitor missing thread safety"

  positive_observations:
    - "Excellent separation of concerns"
    - "Good use of typing"
    - "Comprehensive logging"

  # Hash for quick comparison (hash of finding IDs + severities)
  fingerprint: "a1b2c3d4e5f6"
```

## Storage Convention

Store evaluation results in the evaluated project:

```
[project-root]/
└── .eval-results/
    ├── arch-review-2025-12-12-eval-a1b2c3d4.yaml
    ├── arch-review-2025-12-12-eval-e5f6g7h8.yaml
    └── comparison-2025-12-12.md
```

Naming convention: `[type]-[date]-eval-[id].yaml`

## Comparison Protocol

### Matching Findings

Two findings are considered "matching" if:
1. **Same location** (file + function/line within 10 lines), OR
2. **Similar title** (>70% token overlap), OR
3. **Same evidence pattern** (key code snippet matches)

### Comparison Metrics

| Metric | Definition | Formula |
|--------|------------|---------|
| **Overlap** | Findings in both evaluations | \|A ∩ B\| / \|A ∪ B\| |
| **Precision** | Of A's findings, how many in B? | \|A ∩ B\| / \|A\| |
| **Recall** | Of B's findings, how many in A? | \|A ∩ B\| / \|B\| |
| **Severity Agreement** | Matching findings with same severity | matching_severity / total_matched |
| **Category Agreement** | Matching findings with same category | matching_category / total_matched |

### Comparison Report Format

```markdown
# Evaluation Comparison Report

## Evaluations Compared
- **A**: arch-review-2025-12-12-eval-a1b2c3d4
- **B**: arch-review-2025-12-12-eval-e5f6g7h8

## Metrics
| Metric | Value |
|--------|-------|
| Overlap (Jaccard) | 0.85 |
| Precision (A→B) | 0.90 |
| Recall (A→B) | 0.80 |
| Severity Agreement | 0.95 |
| Category Agreement | 0.88 |

## Finding Comparison

### Found in Both (Matched)
| A Finding | B Finding | Severity Match | Category Match |
|-----------|-----------|----------------|----------------|
| CRITICAL-001 | CRITICAL-001 | ✅ | ✅ |
| HIGH-002 | HIGH-003 | ✅ | ❌ |

### Only in A (Potentially Missed by B)
- HIGH-004: Some finding only A found

### Only in B (Potentially Missed by A)
- MEDIUM-007: Some finding only B found

## Consistency Score: 87%
```

## Category Normalization

To enable comparison across different evaluation types, normalize categories:

| Raw Category | Normalized |
|--------------|------------|
| thread safety, concurrency, race condition, deadlock | `thread-safety` |
| resource leak, memory leak, fd leak, connection leak | `resource-management` |
| error handling, exception, recovery | `error-handling` |
| state machine, persistence, atomic | `state-management` |
| timeout, retry, external call, api | `external-operations` |
| validation, input, web, api endpoint | `api-web-layer` |
| config, secrets, credentials | `configuration` |
| pattern, consistency, dead code, naming | `code-consistency` |
| security, auth, injection, xss | `security` |
| performance, optimization, complexity | `performance` |

## Workflow Examples

### Example 1: Reproducibility Test

Run the same review twice and compare:

```
User: "Perform an architecture review of src/ using eval-framework format, save to .eval-results/"
[Run 1 completes, saved as arch-review-...-eval-abc123.yaml]

User: "Perform the same architecture review again with eval-framework format"
[Run 2 completes, saved as arch-review-...-eval-def456.yaml]

User: "Compare the two architecture reviews and generate consistency report"
[Comparison report generated]
```

### Example 2: Cross-Model Comparison

Compare Opus vs Sonnet evaluations:

```
User: "Using Opus, perform security review with eval-framework format"
User: "Using Sonnet, perform security review with eval-framework format"
User: "Compare the two security reviews"
```

### Example 3: Regression Testing

After code changes, verify findings are still valid:

```
User: "Load previous evaluation .eval-results/arch-review-prev.yaml"
User: "Re-evaluate the same scope and compare to previous"
User: "Which findings are now fixed? Which are new?"
```

## Integration with Other Skills

### With code-review Skill
```
"Perform a code review of AuthService.cs with eval-framework output"
```

### With architecture-review Skill (when created)
```
"Perform an architecture review with eval-framework format"
```

### With security-review Skill (when created)
```
"Perform a security audit with eval-framework format"
```

## Files Reference

| File | Purpose |
|------|---------|
| `SKILL.md` | This file - framework documentation |
| `schemas/evaluation.schema.yaml` | JSON Schema for evaluation output |
| `templates/comparison-report.md` | Template for comparison reports |
| `scripts/compare-evaluations.py` | Python script for comparison |
| `examples/architecture-review.md` | Example: architecture review with framework |

## Best Practices

1. **Always include evidence** - Code snippets make findings matchable
2. **Use consistent categories** - Refer to normalization table
3. **Include reasoning** - Explains *why*, not just *what*
4. **Generate fingerprint** - Enables quick change detection
5. **Store in version control** - Track evaluation evolution over time
6. **Run multiple times** - Single run may miss issues
7. **Compare across models** - Different models find different things
