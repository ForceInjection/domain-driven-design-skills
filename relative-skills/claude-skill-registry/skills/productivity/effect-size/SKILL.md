---
name: effect-size
description: "Calculate and interpret effect sizes for statistical analyses. Use when: (1) Reporting research results to show practical significance, (2) Meta-analysis to combine study results, (3) Grant writing to justify expected effects, (4) Interpreting published studies beyond p-values, (5) Sample size planning for power analysis."
allowed-tools: Read, Write
version: 1.0.0
---

# Effect Size Calculation Skill

## Purpose

Calculate standardized effect sizes to quantify the magnitude of research findings. Essential for reporting practical significance beyond p-values.

## Common Effect Size Measures

### Cohen's d (Mean Differences)
**Use:** T-tests, group comparisons on continuous outcomes

```
d = (M₁ - M₂) / SD_pooled

Interpretation:
- Small: d = 0.2
- Medium: d = 0.5
- Large: d = 0.8
```

### Pearson's r (Correlations)
**Interpretation:**
- Small: r = 0.10
- Medium: r = 0.30
- Large: r = 0.50

### Eta-squared (η²) and Partial Eta-squared (η²ₚ)
**Use:** ANOVA, variance explained

```
η² = SS_effect / SS_total
η²ₚ = SS_effect / (SS_effect + SS_error)

Interpretation:
- Small: η² = 0.01
- Medium: η² = 0.06
- Large: η² = 0.14
```

### Odds Ratio (OR) and Risk Ratio (RR)
**Use:** Binary outcomes, clinical trials

```
OR = (a/b) / (c/d)  [from 2x2 table]

Interpretation:
- OR = 1: No effect
- OR > 1: Increased odds
- OR < 1: Decreased odds
```

## Always Report with Confidence Intervals

```
Example: d = 0.52, 95% CI [0.28, 0.76]

This shows:
- Best estimate: d = 0.52 (medium effect)
- Precision: CI width suggests adequate sample size
- Excludes zero: Effect is statistically significant
```

## Integration

Use with power-analysis skill for study planning and with statistical analysis for results reporting.

---

**Version:** 1.0.0
