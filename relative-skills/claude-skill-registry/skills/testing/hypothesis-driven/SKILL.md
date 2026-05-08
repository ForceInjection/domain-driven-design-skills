---
name: hypothesis-driven
description: This skill should be used when refining hypotheses, checking testability, improving specificity, or designing verification strategies. Triggered by requests like "refine hypothesis", "validate hypothesis", "check if testable", or "improve this hypothesis". Used AFTER experiments to refine hypotheses based on results.
---

# Hypothesis-Driven Research

## Overview

Provides hypothesis refinement and validation support for bioinformatics research. Helps transform vague ideas into testable, specific hypotheses and designs verification strategies.

**Key principle**: This skill is used AFTER experiment execution to refine hypotheses based on observations, not for initial hypothesis generation.

## Core Capabilities

### 1. Hypothesis Refinement

Transform vague or weak hypotheses into strong, testable predictions.

**When to use**:
- After completing an experiment
- When initial hypothesis was too broad
- When results suggest new hypotheses
- When preparing for next experiment

**Workflow**:
1. Extract existing hypothesis (from lab notebook or user input)
2. Analyze hypothesis quality using `references/validation-criteria.md`
3. Identify weaknesses:
   - Too vague?
   - Not testable?
   - Missing quantitative prediction?
   - Not falsifiable?
4. Provide refined version with improvements
5. Explain reasoning for changes

**Output format**:
```markdown
## Original Hypothesis
[User's original hypothesis]

## Refined Hypothesis
[Improved version]

## Verification Strategy
[How to test this hypothesis]
[Expected results if hypothesis is true]
[Expected results if hypothesis is false]

## Quality Check
- [x] Testable: Can determine true/false
- [x] Specific: No ambiguity
- [x] Evidence-based: Based on observations
- [x] Distinguishable: Results can discriminate hypotheses

## Improvement Notes
[Explanation of changes and why they were needed]
```

### 2. Testability Validation

Check if a hypothesis can be practically tested.

**Good hypotheses are**:
- **Testable**: Can be evaluated with available methods
- **Specific**: Clearly defined variables and relationships
- **Quantitative**: Include measurable predictions when possible
- **Falsifiable**: Can be proven wrong

**Validation questions**:
1. Can this be tested with available data/methods?
2. What exact measurements would be taken?
3. What result would support the hypothesis?
4. What result would reject the hypothesis?
5. Are alternative explanations distinguishable?

**Examples**:

❌ Poor hypothesis:
- "Gene X is important for cancer"
  - Problems: Vague ("important"), not falsifiable, no prediction

✅ Refined hypothesis:
- "Knockout of Gene X reduces cancer cell proliferation by >30% compared to wild-type in HeLa cells"
  - Why better: Specific intervention, quantitative prediction, clear comparison

❌ Poor hypothesis:
- "There will be differences in gene expression between conditions"
  - Problems: No prediction of direction, no specificity, trivially true

✅ Refined hypothesis:
- "Treatment with Drug X will upregulate >100 genes in the cell cycle pathway (adjusted p < 0.05) in breast cancer cells"
  - Why better: Specific direction, quantitative threshold, defined pathway

### 3. Hypothesis Quality Scoring

Evaluate hypotheses against multiple criteria (from `references/validation-criteria.md`).

**Scoring dimensions**:

1. **Specificity** (0-3):
   - 0: Extremely vague
   - 1: Somewhat specific but missing key details
   - 2: Specific with minor ambiguities
   - 3: Completely specific and unambiguous

2. **Testability** (0-3):
   - 0: Cannot be tested with current methods
   - 1: Testable but requires significant method development
   - 2: Testable with standard methods
   - 3: Easily testable with available data/methods

3. **Quantitativeness** (0-3):
   - 0: No quantitative prediction
   - 1: Qualitative comparison (more/less)
   - 2: Approximate magnitude (>2-fold)
   - 3: Specific numerical prediction with confidence

4. **Falsifiability** (0-3):
   - 0: Cannot be disproven
   - 1: Very difficult to falsify
   - 2: Can be falsified with additional data
   - 3: Clearly falsifiable with single experiment

**Interpretation**:
- Total 10-12: Excellent hypothesis
- Total 7-9: Good hypothesis (minor refinement needed)
- Total 4-6: Weak hypothesis (major refinement needed)
- Total 0-3: Poor hypothesis (complete reformulation needed)

### 4. Verification Strategy Design

Design experiments to test hypotheses.

**Strategy components**:

1. **Positive test**: What result would support the hypothesis?
2. **Negative test**: What result would reject the hypothesis?
3. **Alternative hypotheses**: What other explanations exist?
4. **Distinguishing tests**: How to differentiate alternatives?
5. **Controls**: What controls are needed?

**Example**:

Hypothesis: "Gene X knockout reduces cell proliferation by >30%"

Verification strategy:
```markdown
### Positive Test
- Measure proliferation in Gene X knockout vs wild-type cells
- Expected: ≥30% reduction in knockout

### Negative Test
- No significant difference or <30% reduction

### Alternative Hypotheses
1. Gene X affects cell death, not proliferation
2. Effect is cell-line specific
3. Compensation by paralog Gene Y

### Distinguishing Tests
1. Measure apoptosis markers (distinguishes death vs proliferation)
2. Test in multiple cell lines (checks generality)
3. Double knockout X+Y (checks compensation)

### Controls
- Wild-type cells (negative control)
- Known proliferation inhibitor (positive control)
- Gene X rescue (specificity control)
```

## Usage Workflow

### Typical Usage Pattern

1. **After completing experiment**:
   ```
   User: "I finished Exp03. Can you help refine my hypothesis based on the results?"
   ```

2. **Read experiment notebook**:
   - Extract original hypothesis
   - Review results
   - Identify observations that inform hypothesis

3. **Refine hypothesis**:
   - Apply quality criteria
   - Improve specificity and testability
   - Add quantitative predictions

4. **Provide verification strategy**:
   - Design next experiment
   - Identify controls needed
   - Consider alternative explanations

5. **Update lab notebook**:
   - User updates Discussion section with refined hypothesis
   - Add verification strategy to Next Steps

### Integration with Workflow

**Fits between**:
- Lab notebook completion → Hypothesis refinement → Next experiment planning
- Multiple experiments → Hypothesis refinement → Report generation

**When to use**:
- After initial exploratory experiment (refine for confirmatory test)
- When results partially support hypothesis (refine prediction)
- When unexpected results emerge (formulate new hypothesis)
- Before planning next experiment (ensure testable hypothesis)

## Resources

### references/

- `validation-criteria.md`: Detailed criteria for hypothesis quality assessment

## Usage Notes

### Best Practices

1. **Base on observations**: Always ground hypotheses in actual data
2. **Be specific**: Replace vague terms with measurable variables
3. **Quantify predictions**: Include expected effect sizes
4. **Consider alternatives**: Design tests that can distinguish hypotheses
5. **Iterate**: Refine hypotheses based on accumulating evidence

### Common Patterns

**Broadening → Narrowing**:
- Original (too broad): "Gene X affects cancer"
- Refined: "Gene X knockdown reduces migration in breast cancer cell line MDA-MB-231 by >50%"

**Qualitative → Quantitative**:
- Original: "Treatment will improve survival"
- Refined: "Treatment will improve median survival by ≥3 months (HR < 0.7, p < 0.05)"

**Vague → Mechanistic**:
- Original: "Pathway Y is involved"
- Refined: "Activation of pathway Y through phosphorylation of protein Z increases within 30 minutes of stimulus"

### Avoid

❌ **Circular hypotheses**:
- "Gene X is upregulated because it's important"

❌ **Unfalsifiable statements**:
- "Gene X might have some role somewhere"

❌ **Confirmation bias**:
- Only refining hypotheses that match preconceptions
- Ignoring alternative explanations

❌ **Overfitting to noise**:
- Creating complex hypotheses from small sample sizes
- Post-hoc explanation of every fluctuation

## Examples

### Example 1: Exploratory → Confirmatory

**Context**: After exploratory RNA-seq experiment

**Original**: "Gene expression changes between conditions"

**Issues**:
- Not falsifiable (always true)
- No direction or specificity
- No quantitative prediction

**Refined**: "Treatment with compound X will upregulate ≥200 genes in cell cycle pathways (GO:0007049) by >2-fold (adjusted p < 0.05) in MCF7 cells after 24h exposure"

**Improvements**:
- Specific intervention and endpoint
- Quantitative thresholds (200 genes, 2-fold)
- Defined pathway
- Statistical criterion
- Temporal and cell-type specificity

**Verification**:
- Perform RNA-seq after 24h treatment
- Expected: ≥200 cell cycle genes upregulated >2-fold
- Alternative: Different pathway affected or different time course

### Example 2: Correlation → Causation Test

**Context**: Found correlation between gene X expression and survival

**Original**: "Gene X is associated with survival"

**Issues**:
- Correlational, not causal
- Doesn't suggest mechanism
- Not actionable

**Refined**: "High expression of Gene X (top tertile) predicts poor overall survival (HR > 2.0, p < 0.01) in TCGA-BRCA cohort, and this effect is mediated by enhanced metastatic potential based on enrichment of migration genes in high-X tumors"

**Improvements**:
- Quantified expression threshold
- Specific effect size
- Proposed mechanism (metastasis)
- Testable prediction (migration gene enrichment)

**Verification**:
- Validate in independent cohort
- Test Gene X knockdown effect on migration
- Check if migration genes mediate survival association

## Quality Principles

From `references/validation-criteria.md`:

1. **Testability**: Can be evaluated with practical experiments
2. **Specificity**: Unambiguous variables and relationships
3. **Quantitativeness**: Measurable predictions
4. **Falsifiability**: Can be proven wrong
5. **Parsimony**: Simplest explanation that fits data
6. **Evidence-based**: Grounded in observations

**Remember**:
- Strong hypotheses are at risk of being wrong (falsifiable)
- Vague hypotheses are unfalsifiable but useless
- Best hypotheses make bold, specific, testable predictions
