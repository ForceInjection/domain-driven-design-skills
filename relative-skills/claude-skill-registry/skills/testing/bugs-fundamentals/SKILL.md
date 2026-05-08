---
name: bugs-fundamentals
description: Foundational knowledge for writing BUGS/JAGS models including precision parameterization, declarative syntax, distributions, and R integration. Use when creating or reviewing BUGS/JAGS models.
---

# BUGS/JAGS Fundamentals

## When to Use This Skill

- Writing new WinBUGS or JAGS models
- Understanding BUGS declarative syntax
- Converting between BUGS and Stan
- Integrating with R via R2jags or R2WinBUGS

## Model Structure

BUGS uses a **single declarative block** where order doesn't matter:

```
model {
  # Likelihood (order doesn't matter)
  for (i in 1:N) {
    y[i] ~ dnorm(mu[i], tau)
    mu[i] <- alpha + beta * x[i]
  }

  # Priors
  alpha ~ dnorm(0, 0.001)
  beta ~ dnorm(0, 0.001)
  tau ~ dgamma(0.001, 0.001)

  # Derived quantities
  sigma <- 1 / sqrt(tau)
}
```

## CRITICAL: Precision Parameterization

**BUGS uses PRECISION (tau = 1/variance), NOT standard deviation:**

| Distribution | BUGS Syntax | Meaning |
|-------------|-------------|---------|
| Normal | `dnorm(mu, tau)` | tau = 1/sigma² |
| MVN | `dmnorm(mu[], Omega[,])` | Omega = inverse(Sigma) |

### Converting SD ↔ Precision
```
# Precision from SD
tau <- pow(sigma, -2)

# SD from precision
sigma <- 1 / sqrt(tau)
```

## Distribution Reference

### Continuous (All use precision!)
```
y ~ dnorm(mu, tau)        # Normal: tau = 1/sigma²
y ~ dlnorm(mu, tau)       # Log-normal (log-scale)
y ~ dt(mu, tau, df)       # Student-t
y ~ dunif(lower, upper)   # Uniform
y ~ dgamma(shape, rate)   # Gamma
y ~ dbeta(a, b)           # Beta
y ~ dexp(lambda)          # Exponential (rate)
y ~ dweib(shape, lambda)  # Weibull
y ~ ddexp(mu, tau)        # Double exponential
```

### Discrete
```
y ~ dbern(p)              # Bernoulli
y ~ dbin(p, n)            # Binomial (p first!)
y ~ dpois(lambda)         # Poisson
y ~ dnegbin(p, r)         # Negative binomial
y ~ dcat(p[])             # Categorical
y ~ dmulti(p[], n)        # Multinomial
```

### Multivariate
```
y[1:K] ~ dmnorm(mu[], Omega[,])    # MVN (precision matrix!)
Omega[1:K,1:K] ~ dwish(R[,], df)   # Wishart (for precision)
p[1:K] ~ ddirch(alpha[])           # Dirichlet
```

## Syntax Essentials

### Stochastic vs Deterministic
```
# Stochastic (random variable)
y ~ dnorm(mu, tau)

# Deterministic (function)
mu <- alpha + beta * x
```

### Loops
```
for (i in 1:N) {
  y[i] ~ dnorm(mu[i], tau)
}
```

### Truncation (JAGS)
```
y ~ dnorm(mu, tau) T(lower, upper)
y ~ dnorm(mu, tau) T(0, )     # Lower only
```

### Logical Functions (JAGS)
```
ind <- step(y - threshold)   # 1 if y >= threshold
eq <- equals(y, 0)           # 1 if y == 0
```

## Common Priors

```
# Vague normal (variance = 1000)
alpha ~ dnorm(0, 0.001)

# Half-Cauchy on SD (via uniform)
sigma ~ dunif(0, 100)
tau <- pow(sigma, -2)

# Vague gamma on precision
tau ~ dgamma(0.001, 0.001)

# Correlation matrix
Omega ~ dwish(I[,], K + 1)
```

## R Integration

### R2jags (Recommended)
```r
library(R2jags)

jags.data <- list(N = 100, y = y, x = x)
jags.params <- c("alpha", "beta", "sigma")
jags.inits <- function() {
  list(alpha = 0, beta = 0, tau = 1)
}

fit <- jags(
  data = jags.data,
  inits = jags.inits,
  parameters.to.save = jags.params,
  model.file = "model.txt",
  n.chains = 4,
  n.iter = 10000,
  n.burnin = 5000
)

print(fit)
fit$BUGSoutput$summary
```

### R2WinBUGS (Windows)
```r
library(R2WinBUGS)

fit <- bugs(
  data = bugs.data,
  inits = bugs.inits,
  parameters.to.save = bugs.params,
  model.file = "model.txt",
  n.chains = 3,
  n.iter = 10000,
  bugs.directory = "C:/WinBUGS14/"
)
```

## Key Differences from Stan

| Feature | BUGS/JAGS | Stan |
|---------|-----------|------|
| Normal | `dnorm(mu, tau)` precision | `normal(mu, sigma)` SD |
| MVN | `dmnorm(mu, Omega)` precision | `multi_normal(mu, Sigma)` cov |
| Syntax | Declarative (DAG) | Imperative (sequential) |
| Blocks | Single model{} | 7 optional blocks |
| Sampling | Gibbs + Metropolis | HMC/NUTS |
| Discrete | Direct sampling | Marginalization required |

## Common Errors

1. **Using SD instead of precision**: `dnorm(0, 1)` means variance=1, NOT SD=1
2. **Wrong binomial order**: `dbin(p, n)` not `dbin(n, p)`
3. **Missing initial values**: Provide inits for complex models
4. **Invalid parent values**: Check for NA/NaN in data
