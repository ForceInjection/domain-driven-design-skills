---
name: compare-tech
description: Compare technologies with weighted scoring matrix. Use when evaluating libraries, frameworks, SaaS products, or infrastructure options.
---

# Compare Technologies

Rigorous, unbiased comparisons with quantified scoring.

## Process

1. Clarify scope (options + use case)
2. Define 5-8 criteria, assign weights totaling 100 pts
3. Score each option 1-5 per criterion
4. Calculate weighted totals, recommend with confidence level

## Output Template

```markdown
# [Option A] vs [Option B]

**Use Case:** [One sentence]

## At a Glance

| | [A] | [B] |
|---|---|---|
| **Docs** | [link](url) | [link](url) |
| **Type** | [category] | [category] |
| **License** | [MIT/etc] | [license] |

## Weighted Comparison

| Criterion | Weight | [A] | [B] | Notes |
|-----------|-------:|:---:|:---:|-------|
| [criterion] | XX | X | X | [key differentiator] |
| **Total** | **100** | **XX** | **XX** | |

*Scoring: 1=Poor, 2=Below Avg, 3=Adequate, 4=Good, 5=Excellent*

## Key Differentiators

- **[A]:** [≤15 words]
- **[B]:** [≤15 words]

## Recommendation

**Winner:** [Option] ([XX] pts)
**Confidence:** [High/Medium/Low]
**Caveat:** [When another option wins]
```

## Guidelines

- Weights: must-haves 15-25 pts, should-haves 10-15 pts, nice-to-haves 5-10 pts
- Score 3 is baseline; justify deviations in Notes
- Stay neutral, cite sources for contested claims
- No extended prose, no code snippets unless requested
- Don't pick criteria that favor predetermined winner
