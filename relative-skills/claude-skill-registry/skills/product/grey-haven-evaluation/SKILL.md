---
name: grey-haven-evaluation
description: "Evaluate LLM outputs with multi-dimensional rubrics, handle non-determinism, and implement LLM-as-judge patterns. Essential for production LLM systems. Use when testing prompts, validating outputs, comparing models, or when user mentions 'evaluation', 'testing LLM', 'rubric', 'LLM-as-judge', 'output quality', 'prompt testing', or 'model comparison'."
# v2.0.43: Skills to auto-load for evaluation work
skills:
  - grey-haven-prompt-engineering
  - grey-haven-testing-strategy
# v2.0.74: Tools for evaluation work
allowed-tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Evaluation Skill

Evaluate LLM outputs systematically with rubrics, handle non-determinism, and implement LLM-as-judge patterns.

## Core Insight: The 95% Variance Finding

Research shows **95% of output variance** comes from just two sources:
- **80%** from prompt tokens (wording, structure, examples)
- **15%** from random seed/sampling

Temperature, model version, and other factors account for only 5%.

**Implication**: Focus evaluation on prompt quality, not model tweaking.

## What's Included

### Examples (`examples/`)
- **Prompt comparison** - A/B testing prompts with rubrics
- **Model evaluation** - Comparing outputs across models
- **Regression testing** - Detecting output degradation

### Reference Guides (`reference/`)
- **Rubric design** - Multi-dimensional evaluation criteria
- **LLM-as-judge** - Using LLMs to evaluate LLM outputs
- **Statistical methods** - Handling non-determinism

### Templates (`templates/`)
- **Rubric templates** - Ready-to-use evaluation criteria
- **Judge prompts** - LLM-as-judge prompt templates
- **Test case format** - Structured test case templates

### Checklists (`checklists/`)
- **Evaluation setup** - Before running evaluations
- **Rubric validation** - Ensuring rubric quality

## Key Concepts

### 1. Multi-Dimensional Rubrics

Don't use single scores. Break down evaluation into dimensions:

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| Accuracy | 30% | Factually correct, no hallucinations |
| Completeness | 25% | Addresses all requirements |
| Clarity | 20% | Well-organized, easy to understand |
| Conciseness | 15% | No unnecessary content |
| Format | 10% | Follows specified structure |

### 2. Handling Non-Determinism

LLMs are non-deterministic. Handle with:

```
Strategy 1: Multiple Runs
- Run same prompt 3-5 times
- Report mean and variance
- Flag high-variance cases

Strategy 2: Seed Control
- Set temperature=0 for reproducibility
- Document seed for debugging
- Accept some variation is normal

Strategy 3: Statistical Significance
- Use paired comparisons
- Require 70%+ win rate for "better"
- Report confidence intervals
```

### 3. LLM-as-Judge Pattern

Use a judge LLM to evaluate outputs:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Prompt    │────▶│  Test LLM   │────▶│   Output    │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                    ┌─────────────┐     ┌─────────────┐
                    │   Rubric    │────▶│ Judge LLM   │
                    └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   Score     │
                                        └─────────────┘
```

**Best Practice**: Use stronger model as judge (Opus judges Sonnet).

### 4. Test Case Design

Structure test cases with:

```typescript
interface TestCase {
  id: string
  input: string              // User message or context
  expectedBehavior: string   // What output should do
  rubric: RubricItem[]       // Evaluation criteria
  groundTruth?: string       // Optional gold standard
  metadata: {
    category: string
    difficulty: 'easy' | 'medium' | 'hard'
    createdAt: string
  }
}
```

## Evaluation Workflow

### Step 1: Define Rubric

```yaml
rubric:
  dimensions:
    - name: accuracy
      weight: 0.3
      criteria:
        5: "Completely accurate, no errors"
        4: "Minor errors, doesn't affect correctness"
        3: "Some errors, partially correct"
        2: "Significant errors, mostly incorrect"
        1: "Completely incorrect or hallucinated"
```

### Step 2: Create Test Cases

```yaml
test_cases:
  - id: "code-gen-001"
    input: "Write a function to reverse a string"
    expected_behavior: "Returns working reverse function"
    ground_truth: |
      function reverse(s: string): string {
        return s.split('').reverse().join('')
      }
```

### Step 3: Run Evaluation

```bash
# Run test suite
python evaluate.py --suite code-generation --runs 3

# Output
# ┌─────────────────────────────────────────────┐
# │ Test Suite: code-generation                 │
# │ Total: 50 | Pass: 47 | Fail: 3              │
# │ Accuracy: 94% (±2.1%)                       │
# │ Avg Score: 4.2/5.0                          │
# └─────────────────────────────────────────────┘
```

### Step 4: Analyze Results

Look for:
- **Low-scoring dimensions** - Target for improvement
- **High-variance cases** - Prompt needs clarification
- **Regression from baseline** - Investigate changes

## Grey Haven Integration

### With TDD Workflow

```
1. Write test cases (expected behavior)
2. Run baseline evaluation
3. Modify prompt/implementation
4. Run evaluation again
5. Compare: new scores ≥ baseline?
```

### With Pipeline Architecture

```
acquire → prepare → process → parse → render → EVALUATE
                                                  │
                                          ┌───────┴───────┐
                                          │ Compare to    │
                                          │ ground truth  │
                                          │ or rubric     │
                                          └───────────────┘
```

### With Prompt Engineering

```
Current prompt → Evaluate → Score: 3.2
Apply principles → Improve prompt
New prompt → Evaluate → Score: 4.1 ✓
```

## Use This Skill When

- Testing new prompts before production
- Comparing prompt variations (A/B testing)
- Validating model outputs meet quality bar
- Detecting regressions after changes
- Building evaluation datasets
- Implementing automated quality gates

## Related Skills

- `prompt-engineering` - Improve prompts based on evaluation
- `testing-strategy` - Overall testing approaches
- `llm-project-development` - Pipeline with evaluation stage

## Quick Start

```bash
# Design your rubric
cat templates/rubric-template.yaml

# Create test cases
cat templates/test-case-template.yaml

# Learn LLM-as-judge
cat reference/llm-as-judge-guide.md

# Run evaluation checklist
cat checklists/evaluation-setup-checklist.md
```

---

**Skill Version**: 1.0
**Key Finding**: 95% variance from prompts (80%) + sampling (15%)
**Last Updated**: 2025-01-15
