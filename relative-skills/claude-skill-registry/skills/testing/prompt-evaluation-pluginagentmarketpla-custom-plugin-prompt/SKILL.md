---
name: prompt-evaluation
description: Prompt testing, metrics, and A/B testing frameworks
sasmp_version: "1.3.0"
bonded_agent: 06-evaluation-testing-agent
bond_type: PRIMARY_BOND
---

# Prompt Evaluation Skill

**Bonded to:** `evaluation-testing-agent`

---

## Quick Start

```bash
Skill("custom-plugin-prompt-engineering:prompt-evaluation")
```

---

## Parameter Schema

```yaml
parameters:
  evaluation_type:
    type: enum
    values: [accuracy, consistency, robustness, efficiency, ab_test]
    required: true

  test_cases:
    type: array
    items:
      input: string
      expected: string|object
      category: string
    min_items: 5

  metrics:
    type: array
    items: string
    default: [accuracy, consistency]
```

---

## Evaluation Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| Accuracy | correct / total | > 0.90 |
| Consistency | identical_runs / total_runs | > 0.85 |
| Robustness | edge_cases_passed / edge_cases_total | > 0.80 |
| Format Compliance | valid_format / total | > 0.95 |
| Token Efficiency | quality_score / tokens_used | Maximize |

---

## Test Case Framework

### Test Case Schema

```yaml
test_case:
  id: "TC001"
  category: "happy_path|edge_case|adversarial|regression"
  description: "What this test verifies"
  priority: "critical|high|medium|low"

  input:
    user_message: "Test input text"
    context: {}  # Optional additional context

  expected:
    contains: ["required", "phrases"]
    not_contains: ["forbidden", "content"]
    format: "json|text|markdown"
    schema: {}  # Optional JSON schema

  evaluation:
    metrics: ["accuracy", "format_compliance"]
    threshold: 0.9
    timeout: 30
```

### Test Categories

```yaml
categories:
  happy_path:
    description: "Standard expected inputs"
    coverage_target: 40%
    examples:
      - typical_user_query
      - common_use_case
      - expected_format

  edge_cases:
    description: "Boundary conditions"
    coverage_target: 25%
    examples:
      - empty_input
      - very_long_input
      - special_characters
      - unicode_text
      - minimal_input

  adversarial:
    description: "Attempts to break prompt"
    coverage_target: 20%
    examples:
      - injection_attempts
      - conflicting_instructions
      - ambiguous_requests
      - malformed_input

  regression:
    description: "Previously failed cases"
    coverage_target: 15%
    examples:
      - fixed_bugs
      - known_edge_cases
```

---

## Scoring Rubric

```yaml
accuracy_rubric:
  1.0: "Exact match to expected output"
  0.8: "Semantically equivalent, minor differences"
  0.5: "Partially correct, major elements present"
  0.2: "Related but incorrect"
  0.0: "Completely wrong or off-topic"

consistency_rubric:
  1.0: "Identical across all runs"
  0.8: "Minor variations (punctuation, formatting)"
  0.5: "Significant variations, same meaning"
  0.2: "Different approaches, inconsistent"
  0.0: "Completely different each time"

robustness_rubric:
  1.0: "Handles all edge cases correctly"
  0.8: "Fails gracefully with clear error messages"
  0.5: "Some edge cases cause issues"
  0.2: "Many edge cases fail"
  0.0: "Breaks on most edge cases"
```

---

## A/B Testing Framework

```yaml
ab_test_config:
  name: "Prompt Variant Comparison"
  hypothesis: "New prompt improves accuracy by 10%"

  variants:
    control:
      prompt: "{original_prompt}"
      allocation: 50%
    treatment:
      prompt: "{new_prompt}"
      allocation: 50%

  metrics:
    primary:
      - name: accuracy
        min_improvement: 0.05
        significance: 0.05
    secondary:
      - token_count
      - response_time
      - user_satisfaction

  sample:
    minimum: 100
    power: 0.8

  stopping_rules:
    - condition: significant_regression
      action: stop_treatment
    - condition: clear_winner
      threshold: 0.99
      action: early_stop
```

---

## Evaluation Report Template

```yaml
report:
  metadata:
    prompt_name: "string"
    version: "string"
    date: "ISO8601"
    evaluator: "string"

  summary:
    overall_score: 0.87
    status: "PASS|FAIL|REVIEW"
    recommendation: "string"

  metrics:
    accuracy: 0.92
    consistency: 0.88
    robustness: 0.79
    format_compliance: 0.95

  test_results:
    total: 50
    passed: 43
    failed: 7
    pass_rate: 0.86

  failures:
    - id: "TC023"
      category: "edge_case"
      issue: "Description of failure"
      severity: "high|medium|low"
      input: "..."
      expected: "..."
      actual: "..."

  recommendations:
    - priority: high
      action: "Specific improvement"
    - priority: medium
      action: "Another improvement"
```

---

## Evaluation Workflow

```yaml
workflow:
  1_prepare:
    - Load prompt under test
    - Load test cases
    - Configure metrics

  2_execute:
    - Run all test cases
    - Record outputs
    - Measure latency

  3_score:
    - Compare against expected
    - Calculate metrics
    - Identify patterns

  4_analyze:
    - Categorize failures
    - Find root causes
    - Prioritize issues

  5_report:
    - Generate report
    - Make recommendations
    - Archive results
```

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| All tests fail | Wrong expected outputs | Review test design |
| Flaky tests | Non-determinism | Lower temperature |
| False positives | Lenient matching | Tighten criteria |
| False negatives | Strict matching | Use semantic similarity |
| Slow evaluation | Too many tests | Sample strategically |

---

## Integration

```yaml
integrates_with:
  - prompt-optimization: Improvement feedback loop
  - all skills: Quality gate before deployment

automation:
  ci_cd: "Run on prompt changes"
  scheduled: "Weekly regression"
  triggered: "On demand"
```

---

## References

See `references/GUIDE.md` for evaluation methodology.
See `scripts/helper.py` for automation utilities.
