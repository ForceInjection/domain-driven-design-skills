---
name: mechinterp-validation-suite
description: Run credibility checks on feature interpretations including split-half stability and shuffle null tests
---

# MechInterp Validation Suite

Run comprehensive credibility checks on feature interpretations to ensure findings are robust and not artifacts.

## Purpose

The validation suite skill:
- Tests stability of analysis results across data splits
- Creates null distributions to assess significance
- Generates validation reports with pass/fail criteria
- Helps identify unreliable interpretations early

## When to Use

Use this skill when:
- A hypothesis reaches high confidence (>0.7) and needs validation
- You want to verify that a pattern is real, not noise
- Before finalizing feature labels or interpretations
- As part of a standard research checkpoint

## Validation Tests

### 1. Split-Half Stability

Tests if analysis results are consistent across random splits of the data.

**What it measures**: Correlation of token frequency rankings between two halves
**Pass criterion**: Mean correlation > 0.7

```python
from splatnlp.mechinterp.schemas import ExperimentSpec, ExperimentType
from splatnlp.mechinterp.experiments import get_runner_for_type
from splatnlp.mechinterp.skill_helpers import load_context

# Create split-half spec
spec = ExperimentSpec(
    type=ExperimentType.SPLIT_HALF,
    feature_id=18712,
    model_type="ultra",
    variables={
        "n_splits": 10,
        "metric": "token_frequency_correlation"
    }
)

# Run validation
ctx = load_context("ultra")
runner = get_runner_for_type(spec.type)
result = runner.run(spec, ctx)

# Check results
mean_corr = result.aggregates.custom["mean_correlation"]
passed = result.aggregates.custom["stability_passed"]
print(f"Split-half correlation: {mean_corr:.3f} ({'PASS' if passed else 'FAIL'})")
```

### 2. Shuffle Null Test

Creates a null distribution by shuffling activations to test if observed patterns are significant.

**What it measures**: Whether top-token concentration exceeds null expectation
**Pass criterion**: p-value < 0.05

```python
spec = ExperimentSpec(
    type=ExperimentType.SHUFFLE_NULL,
    feature_id=18712,
    model_type="ultra",
    variables={
        "n_shuffles": 100
    }
)

result = runner.run(spec, ctx)

p_value = result.aggregates.custom["p_value"]
significant = result.aggregates.custom["significant"]
print(f"Shuffle null p-value: {p_value:.4f} ({'SIGNIFICANT' if significant else 'NOT SIGNIFICANT'})")
```

## Running Full Validation Suite

```python
from splatnlp.mechinterp.schemas import ExperimentSpec, ExperimentType
from splatnlp.mechinterp.experiments import get_runner_for_type
from splatnlp.mechinterp.skill_helpers import load_context
from splatnlp.mechinterp.state.io import SPECS_DIR, RESULTS_DIR
from datetime import datetime
import json

def run_validation_suite(feature_id: int, model_type: str = "ultra"):
    """Run all validation tests for a feature."""
    ctx = load_context(model_type)
    results = {}

    # Test 1: Split-half stability
    split_spec = ExperimentSpec(
        type=ExperimentType.SPLIT_HALF,
        feature_id=feature_id,
        model_type=model_type,
        variables={"n_splits": 10}
    )
    runner = get_runner_for_type(split_spec.type)
    split_result = runner.run(split_spec, ctx)
    results["split_half"] = {
        "mean_correlation": split_result.aggregates.custom.get("mean_correlation"),
        "passed": split_result.aggregates.custom.get("stability_passed", 0) == 1
    }

    # Test 2: Shuffle null
    null_spec = ExperimentSpec(
        type=ExperimentType.SHUFFLE_NULL,
        feature_id=feature_id,
        model_type=model_type,
        variables={"n_shuffles": 100}
    )
    runner = get_runner_for_type(null_spec.type)
    null_result = runner.run(null_spec, ctx)
    results["shuffle_null"] = {
        "p_value": null_result.aggregates.custom.get("p_value"),
        "passed": null_result.aggregates.custom.get("significant", 0) == 1
    }

    # Overall pass/fail
    all_passed = all(r["passed"] for r in results.values())

    return {
        "feature_id": feature_id,
        "model_type": model_type,
        "tests": results,
        "overall_passed": all_passed,
        "timestamp": datetime.now().isoformat()
    }

# Run suite
validation = run_validation_suite(18712, "ultra")
print(f"\nValidation Suite for Feature {validation['feature_id']}:")
print(f"  Split-half: {validation['tests']['split_half']['mean_correlation']:.3f} "
      f"({'PASS' if validation['tests']['split_half']['passed'] else 'FAIL'})")
print(f"  Shuffle null: p={validation['tests']['shuffle_null']['p_value']:.4f} "
      f"({'PASS' if validation['tests']['shuffle_null']['passed'] else 'FAIL'})")
print(f"\nOVERALL: {'PASS' if validation['overall_passed'] else 'FAIL'}")
```

## Interpretation Guide

### Split-Half Results

| Correlation | Interpretation |
|-------------|----------------|
| > 0.8 | Excellent stability - results are highly reproducible |
| 0.7 - 0.8 | Good stability - results are reliable |
| 0.5 - 0.7 | Moderate stability - some patterns may be noisy |
| < 0.5 | Poor stability - interpret with caution |

### Shuffle Null Results

| p-value | Interpretation |
|---------|----------------|
| < 0.01 | Highly significant - pattern very unlikely by chance |
| 0.01 - 0.05 | Significant - pattern unlikely by chance |
| 0.05 - 0.10 | Marginally significant - borderline |
| > 0.10 | Not significant - pattern may be noise |

## Workflow Integration

1. **Conduct research**: Build hypotheses, gather evidence
2. **Reach confidence threshold**: When hypothesis confidence > 0.7
3. **Run validation suite**: Execute this skill
4. **Update state**: Mark hypothesis as validated (or not)
5. **Document**: Add validation results to evidence

```python
from splatnlp.mechinterp.state import ResearchStateManager
from splatnlp.mechinterp.schemas.research_state import HypothesisStatus

# After validation passes
manager = ResearchStateManager(18712, "ultra")
manager.update_hypothesis(
    "h001",
    status=HypothesisStatus.SUPPORTED,
    confidence_absolute=0.9
)
manager.add_evidence(
    experiment_id="validation_suite",
    result_path="/mnt/e/mechinterp_runs/results/validation.json",
    summary="Passed split-half (r=0.85) and shuffle null (p<0.01)",
    strength=EvidenceStrength.STRONG,
    supports=["h001"]
)
```

## CLI Usage

```bash
cd /root/dev/SplatNLP

# Run split-half validation
poetry run python -m splatnlp.mechinterp.cli.runner_cli \
    --spec-path specs/split_half_spec.json

# Run shuffle null validation
poetry run python -m splatnlp.mechinterp.cli.runner_cli \
    --spec-path specs/shuffle_null_spec.json
```

## See Also

- **mechinterp-state**: Update hypotheses after validation
- **mechinterp-summarizer**: Document validation results
- **mechinterp-runner**: Execute validation experiments
