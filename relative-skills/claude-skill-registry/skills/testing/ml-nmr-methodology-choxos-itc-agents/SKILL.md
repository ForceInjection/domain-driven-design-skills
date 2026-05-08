---
name: ml-nmr-methodology
description: Deep methodology knowledge for ML-NMR including IPD/AgD integration, population adjustment, numerical integration, and prediction to target populations. Use when conducting or reviewing ML-NMR analyses.
---

# ML-NMR Methodology

Comprehensive methodological guidance for conducting rigorous Multilevel Network Meta-Regression following NICE DSU guidance and multinma package documentation.

## When to Use This Skill

- Deciding whether ML-NMR is appropriate
- Setting up integration points for AgD
- Specifying priors and models
- Understanding marginal vs conditional effects
- Predicting to target populations
- Reviewing ML-NMR code or results

## When to Use ML-NMR

### ML-NMR is Appropriate When:

1. **Network Structure**
   - Multiple treatments form (partial) network
   - Some studies have IPD, others only AgD
   - Want to leverage all available evidence

2. **Population Differences**
   - Effect modifiers differ across populations
   - Standard NMA transitivity violated
   - Need population-adjusted estimates

3. **Target Population**
   - Want predictions for specific population
   - Different from any single trial population
   - Policy-relevant population definition

### ML-NMR vs Alternatives

| Scenario | Recommended Method |
|----------|-------------------|
| All AgD, similar populations | Standard NMA |
| All AgD, different populations | NMA meta-regression |
| IPD for one study, AgD for one | MAIC or STC |
| IPD + AgD network | ML-NMR |
| Disconnected with IPD | ML-NMR (with assumptions) |

## Key Concepts

### Individual-Level vs Study-Level

```
ML-NMR Models Both:
├── Individual-level (within IPD studies)
│   - Patient-level outcomes
│   - Patient-level covariates
│   - Exact covariate-outcome relationships
│
└── Study-level (for AgD studies)
    - Aggregate outcomes
    - Covariate summaries
    - Integration over covariate distribution
```

### Population Adjustment

**Problem**: AgD studies provide aggregate summaries, but we need individual-level predictions.

**Solution**: Numerical integration over the AgD population's covariate distribution.

```
For AgD study:
Expected outcome = ∫ f(outcome | covariates, treatment) × p(covariates) d(covariates)

Where:
- f(): Individual-level outcome model (from IPD)
- p(): Covariate distribution in AgD population
```

## Integration Points

### What Are Integration Points?

Discrete approximation to the integral over AgD population:

```r
# Specify covariate distribution
add_integration(
  network,
  age = distr(qnorm, mean = 62, sd = 10),
  sex = distr(qbinom, prob = 0.55),
  n_int = 500
)

# Creates 500 "pseudo-individuals" sampled from
# the specified covariate distribution
```

### Choosing Number of Integration Points

| Complexity | n_int | Description |
|------------|-------|-------------|
| Simple | 100-200 | 1-2 covariates, linear effects |
| Moderate | 300-500 | 2-3 covariates, typical use |
| Complex | 500-1000 | Many covariates, interactions |
| Very complex | 1000+ | Nonlinear effects, many variables |

**Best Practice**: Test sensitivity to n_int by running with different values.

### Specifying Distributions

```r
# Continuous: Normal distribution
age = distr(qnorm, mean = 62, sd = 10)

# Binary: Bernoulli (using binomial with size=1)
sex = distr(qbinom, prob = 0.55)

# Categorical: Discrete distribution
# May need special handling

# Correlated covariates: Copula methods
# More complex setup required
```

## Model Specification

### Regression Component

```r
nma(
  network,
  regression = ~ age + sex + age:sex,  # Covariate effects
  ...
)

# Interprets as:
# Linear predictor = trt_effect + β_age × age + β_sex × sex + β_age:sex × age × sex
```

### Effect Modifier vs Prognostic Factor

```
In ML-NMR regression formula:
├── Effect modifiers: Interact with treatment
│   - regression = ~ age
│   - Creates age × treatment interaction
│
└── Prognostic factors: Affect baseline risk only
    - Handled through study random effects
    - Or explicit prognostic regression
```

### Prior Specification

```r
nma(
  ...,
  prior_intercept = prior_normal(0, 10),    # Baseline risk
  prior_trt = prior_normal(0, 5),           # Treatment effects
  prior_reg = prior_normal(0, 2),           # Regression coefficients
  prior_het = prior_half_normal(1)          # Heterogeneity
)

# Considerations:
# - Scale depends on link function
# - Log-odds: 2-3 is large effect
# - Informative priors from Turner et al. for het
```

## Marginal vs Conditional Effects

### Conditional Effects

- Effect at specific covariate values
- "Effect for a 65-year-old male"
- Directly from model coefficients

### Marginal (Population-Averaged) Effects

- Effect averaged over population
- "Average effect in UK population"
- Obtained via integration

```r
# Predict to target population
target <- data.frame(
  age = seq(50, 80, 5),
  sex = 0.5  # 50% male
)

predictions <- predict(fit, newdata = target)
```

### Why the Difference Matters

For non-collapsible effect measures (OR, HR):
- Marginal effect ≠ Average of conditional effects
- Must integrate properly over population
- ML-NMR handles this correctly

## Consistency Assessment

### Node-Splitting in ML-NMR

```r
# Fit node-split model
nodesplit_fit <- nma(
  network,
  consistency = "nodesplit",
  ...
)

# Check for direct vs indirect disagreement
summary(nodesplit_fit)
```

### Interpretation with Population Adjustment

- Inconsistency could be due to true treatment effect heterogeneity
- Or due to population differences not captured
- Node-splitting should be done after population adjustment

## Treatment Rankings

### Posterior Rank Probabilities

```r
rank_probs <- posterior_rank_probs(fit)

# Returns probability matrix:
# P(treatment j has rank r)
```

### Interpretation Cautions

Same as standard NMA:
- Rankings have uncertainty
- Small effect differences → large rank uncertainty
- Consider clinical significance alongside ranks

## Prediction to Target Population

### Specifying Target Population

```r
# Method 1: Point prediction
target <- data.frame(age = 62, sex = 0.5)

# Method 2: Distribution prediction
# Provide many points representing target distribution
target <- data.frame(
  age = rnorm(1000, 60, 12),
  sex = rbinom(1000, 1, 0.45)
)
```

### Types of Predictions

```r
# Relative effects (log scale)
predict(fit, type = "link")

# Relative effects (natural scale)
predict(fit, type = "response")

# Absolute outcomes
predict(fit, type = "response", baseline = ...)
```

## Convergence Diagnostics

### Essential Checks

```r
# 1. Print summary (shows R-hat, ESS)
print(fit)

# 2. Trace plots
plot(fit, pars = "d")

# 3. R-hat should be < 1.05
# 4. ESS should be > 400 per parameter
```

### Addressing Convergence Issues

1. **Increase iterations**: More warmup/sampling
2. **Adjust adapt_delta**: Higher (0.95, 0.99) for divergences
3. **Reparameterize**: Different model specifications
4. **Informative priors**: If posterior too diffuse
5. **Check data**: Sparse comparisons cause issues

## Reporting Requirements

### Methods
- [ ] Network structure description
- [ ] IPD vs AgD studies identified
- [ ] Covariate selection for adjustment
- [ ] Integration point specification
- [ ] Prior specification with justification
- [ ] Target population definition
- [ ] Convergence criteria

### Results
- [ ] Network diagram
- [ ] Convergence diagnostics (R-hat, ESS)
- [ ] Relative effects for all comparisons
- [ ] Treatment rankings with uncertainty
- [ ] Consistency assessment
- [ ] Predictions to target population
- [ ] Sensitivity analyses

## Common Pitfalls

### 1. Insufficient Integration Points
- Results may be unstable
- Check sensitivity to n_int
- Increase until results stabilize

### 2. Ignoring Convergence
- Must check R-hat and ESS
- Divergent transitions indicate problems
- Don't trust results without convergence

### 3. Wrong Covariate Distributions
- Must match AgD population
- Extract from publications carefully
- Consider correlation between covariates

### 4. Misinterpreting Marginal Effects
- Non-collapsible measures need care
- OR/HR: Marginal ≠ conditional
- Use predict() for proper marginalization

### 5. Not Specifying Target Population
- Default may not be policy-relevant
- Explicitly define target
- Sensitivity to target specification

## Quick Reference Code

```r
library(multinma)

# 1. Set up IPD studies
ipd_net <- set_ipd(ipd_data,
                   study = study, trt = treatment, r = response)

# 2. Set up AgD studies
agd_net <- set_agd_arm(agd_data,
                       study = study, trt = treatment,
                       r = responders, n = sampleSize)

# 3. Combine network
network <- combine_network(ipd_net, agd_net)

# 4. Add integration points
network <- add_integration(
  network,
  age = distr(qnorm, mean = age_mean, sd = age_sd),
  sex = distr(qbinom, prob = sex_prop),
  n_int = 500
)

# 5. Fit ML-NMR
fit <- nma(
  network,
  trt_effects = "random",
  regression = ~ age + sex,
  prior_intercept = prior_normal(0, 10),
  prior_trt = prior_normal(0, 5),
  prior_reg = prior_normal(0, 2),
  prior_het = prior_half_normal(1),
  adapt_delta = 0.95,
  chains = 4,
  iter = 4000,
  warmup = 2000,
  seed = 12345
)

# 6. Check convergence
print(fit)

# 7. Relative effects
rel_eff <- relative_effects(fit)
plot(rel_eff)

# 8. Rankings
ranks <- posterior_rank_probs(fit)
plot(ranks)

# 9. Predict to target
target <- data.frame(age = 60, sex = 0.5)
pred <- predict(fit, newdata = target)

# 10. Node-splitting
nodesplit_fit <- nma(network, consistency = "nodesplit", ...)
```

## Resources

- NICE DSU TSD 18: Population-adjusted comparisons
- Phillippo et al. (2020): ML-NMR methods paper
- multinma package: https://dmphillippo.github.io/multinma/
- Stan User's Guide (for MCMC diagnostics)
