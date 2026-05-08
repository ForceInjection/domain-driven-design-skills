---
name: mechinterp-crossmodel-matcher
description: Match SAE features between Ultra (24K) and Full (2K) models based on activation patterns and token overlap
---

# MechInterp Cross-Model Matcher

Match features between the Ultra (24K features) and Full (2K features) SAE models to understand feature correspondence and discover monosemantic representations.

## Purpose

The cross-model matcher skill:
- Finds corresponding features across models
- Computes similarity based on top token overlap
- Identifies features unique to each model
- Helps validate interpretations across model scales

## When to Use

Use this skill when you:
- Have interpreted a feature in one model and want to find its counterpart
- Want to validate that a pattern exists across model scales
- Need to understand what the Ultra model decomposes that Full doesn't

## Usage

### Programmatic

```python
from splatnlp.mechinterp.analysis import FeatureMatcher
from splatnlp.mechinterp.skill_helpers import load_context

# Load source context (the model with your known feature)
source_ctx = load_context("ultra")

# Initialize matcher (automatically loads target model)
matcher = FeatureMatcher(source_ctx)

# Find matches for an Ultra feature in the Full model
report = matcher.find_matches(
    source_feature=18712,
    n_candidates=500,  # How many Full features to check
    n_top_matches=10   # How many matches to return
)

# View results
print(f"Searched {report.n_candidates_tested} candidates")
print(f"Best correlation: {report.best_correlation:.3f}")

for match in report.matches:
    print(f"\nFull feature {match.target_feature}:")
    print(f"  Token overlap: {match.top_token_overlap:.3f}")
    print(f"  Shared tokens: {match.shared_top_tokens[:5]}")
    print(f"  Notes: {match.notes}")
```

### Detailed Comparison

```python
# Compare two specific features in detail
comparison = matcher.compare_features(
    source_fid=18712,  # Ultra feature
    target_fid=1024,   # Full feature
)

print(f"Jaccard similarity: {comparison['jaccard_similarity']:.3f}")
print(f"Shared tokens: {comparison['shared_tokens'][:10]}")
print(f"Ultra-only tokens: {comparison['source_only_tokens'][:10]}")
print(f"Full-only tokens: {comparison['target_only_tokens'][:10]}")
```

## Matching Metrics

### Token Overlap (Jaccard Similarity)

Compares top tokens between features:

```
overlap = |source_top ∩ target_top| / |source_top ∪ target_top|
```

- **> 0.3**: Strong match - likely same underlying concept
- **0.1 - 0.3**: Moderate match - related but not identical
- **< 0.1**: Weak match - probably different concepts

### Interpretation

High overlap suggests:
- Features detect the same pattern
- Ultra feature may be a "refinement" of Full feature
- Good candidate for cross-model validation

Low overlap with similar activation patterns suggests:
- Ultra model has decomposed the Full feature
- Multiple Ultra features may combine to match one Full feature

## Example: Finding Ultra Decomposition

```python
# Example: A Full model feature that might be polysemantic
full_ctx = load_context("full")
matcher = FeatureMatcher(full_ctx)  # Source = Full

# Find what Ultra features correspond to Full feature 512
report = matcher.find_matches(source_feature=512)

# If multiple Ultra features match, the Full feature may be polysemantic
if len([m for m in report.matches if m.combined_score > 0.1]) > 3:
    print("Full feature 512 appears to be polysemantic")
    print("Ultra decomposition:")
    for m in report.matches[:5]:
        print(f"  Ultra {m.target_feature}: {m.shared_top_tokens[:3]}")
```

## Workflow Integration

1. **Start with interpreted feature**: Begin with a feature you understand
2. **Find matches**: Use this skill to find counterparts
3. **Validate interpretation**: Check if matches have similar behavior
4. **Document correspondence**: Update research state with cross-model links
5. **Investigate decomposition**: If Ultra splits a Full feature, analyze each part

## Limitations

- Token overlap is a proxy; true matching would require shared activation data
- Different expansion factors mean different granularity
- Some features may not have clear counterparts

## See Also

- **mechinterp-cluster-mapper**: Analyze groups of related features
- **mechinterp-state**: Track cross-model research
- **mechinterp-runner**: Validate matches with experiments
