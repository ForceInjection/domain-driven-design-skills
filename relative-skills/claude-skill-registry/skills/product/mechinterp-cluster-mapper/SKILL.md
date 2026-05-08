---
name: mechinterp-cluster-mapper
description: Analyze relationships across multiple SAE features - co-activation patterns, shared drivers, and subsystem identification
---

# MechInterp Cluster Mapper

Analyze relationships across multiple SAE features to identify subsystems, shared structure, and co-activation patterns.

## Purpose

The cluster mapper skill:
- Computes co-activation correlations between features
- Identifies shared token drivers across features
- Groups features into subclusters
- Reveals feature subsystems and redundancy

## When to Use

Use this skill when you have:
- A cluster of related features to investigate
- Multiple features that seem to respond to similar patterns
- Need to understand feature redundancy/complementarity

## Usage

### Programmatic

```python
from splatnlp.mechinterp.analysis import ClusterAnalyzer
from splatnlp.mechinterp.skill_helpers import load_context

# Load context
ctx = load_context("ultra")

# Initialize analyzer
analyzer = ClusterAnalyzer(ctx)

# Analyze a cluster of features
feature_ids = [18712, 18715, 18720, 18725, 18730]
report = analyzer.analyze_cluster(feature_ids, sample_size=5000)

# View results
print(f"Mean correlation: {report.mean_correlation:.3f}")
print(f"Strong pairs (corr > 0.5): {report.n_strong_pairs}")

# Co-activation matrix
for fid1, corr_dict in report.coactivation_matrix.items():
    print(f"\nFeature {fid1}:")
    for fid2, corr in sorted(corr_dict.items(), key=lambda x: -x[1]):
        print(f"  -> {fid2}: {corr:.3f}")

# Shared drivers
print("\nShared token drivers:")
for driver in report.shared_drivers[:10]:
    print(f"  {driver['token']}: {driver['n_features']} features")

# Subclusters
print("\nSubclusters identified:")
for i, cluster in enumerate(report.subclusters):
    print(f"  Cluster {i+1}: {cluster}")
```

## Report Contents

### Co-activation Matrix

Pairwise Pearson correlations between feature activations:

```python
{
    18712: {18715: 0.82, 18720: 0.45, 18725: 0.12},
    18715: {18712: 0.82, 18720: 0.38, 18725: 0.15},
    # ...
}
```

### Shared Drivers

Tokens that appear in high-activation examples across multiple features:

```python
[
    {"token": "special_charge_up_57", "n_features": 4, "feature_ids": [18712, 18715, 18720, 18725]},
    {"token": "swim_speed_up_41", "n_features": 3, "feature_ids": [18712, 18720, 18730]},
    # ...
]
```

### Subclusters

Groups of features with correlation above threshold (default 0.5):

```python
[
    [18712, 18715, 18720],  # Highly correlated group
    [18725, 18730],         # Another group
]
```

## Example Analysis

```python
# Full example: analyze Ultra model's SCU-related features
from splatnlp.mechinterp.analysis import ClusterAnalyzer
from splatnlp.mechinterp.skill_helpers import load_context

ctx = load_context("ultra")
analyzer = ClusterAnalyzer(ctx)

# Find features that might be related (e.g., from prior PageRank)
candidate_features = [18712, 18713, 18714, 18715, 18716]

report = analyzer.analyze_cluster(candidate_features)

# Interpretation
if report.mean_correlation > 0.5:
    print("High overall correlation - features may be redundant")
elif report.mean_correlation > 0.2:
    print("Moderate correlation - features capture related but distinct aspects")
else:
    print("Low correlation - features are largely independent")

# Find the core subsystem
if report.subclusters:
    main_cluster = report.subclusters[0]
    print(f"Main subsystem: {main_cluster}")

# Identify the key shared driver
if report.shared_drivers:
    key_driver = report.shared_drivers[0]
    print(f"Key shared driver: {key_driver['token']}")
```

## Integration with Research Workflow

1. **Identify candidates**: Use PageRank or itemsets to find features with similar patterns
2. **Run cluster analysis**: Use this skill to quantify relationships
3. **Interpret structure**: Identify subsystems and shared drivers
4. **Update hypotheses**: Add cluster-level hypotheses to research state
5. **Plan experiments**: Use insights to design targeted experiments

## See Also

- **mechinterp-state**: Track cluster-level research
- **mechinterp-crossmodel-matcher**: Match clusters across models
- **mechinterp-runner**: Run experiments on identified clusters
