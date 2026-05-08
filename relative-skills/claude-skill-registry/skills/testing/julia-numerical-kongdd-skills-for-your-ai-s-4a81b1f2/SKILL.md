---
name: julia-numerical
description: Execute numerical calculations and mathematical computations using Julia. Use this skill for matrix operations, linear algebra, numerical integration, optimization, statistics, and scientific computing tasks.
---

# Julia Numerical Calculation Skill

This skill enables you to execute numerical calculations using Julia, a high-performance programming language designed for numerical and scientific computing.

## When to Use

Use this skill when you need to:
- Perform matrix operations and linear algebra
- Solve differential equations
- Execute numerical integration or optimization
- Calculate statistical measures
- Handle large-scale numerical computations
- Work with complex mathematical operations

## Setup

Before using this skill, ensure Julia is installed on your system:

```bash
# On macOS (using Homebrew)
brew install julia

# On Linux (Ubuntu/Debian)
sudo apt-get install julia

# On Windows (using Chocolatey)
choco install julia

# Or download from https://julialang.org/downloads/
```

## Basic Examples

### Linear Algebra

```julia
using LinearAlgebra

# Create matrices
A = [1 2; 3 4]
B = [5 6; 7 8]

# Matrix multiplication
C = A * B

# Eigenvalues and eigenvectors
eigenvals, eigenvecs = eigen(A)

# Matrix inverse
A_inv = inv(A)
```

### Numerical Integration

```julia
using QuadGK

# Define a function
f(x) = sin(x) * exp(-x)

# Integrate from 0 to ∞
result, error = quadgk(f, 0, Inf)
```

### Optimization

```julia
using Optim

# Define objective function
f(x) = (x[1] - 2)^2 + (x[2] - 3)^2

# Minimize
result = optimize(f, [0.0, 0.0])
```

### Statistics

```julia
using Statistics

data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Statistical measures
mean_val = mean(data)
std_val = std(data)
var_val = var(data)
median_val = median(data)
```

## How to Use This Skill

When you ask me to perform a numerical calculation:
1. I'll identify the appropriate Julia packages needed
2. Write Julia code to solve the problem
3. Execute the code
4. Return results and explanations

## Common Julia Packages

- **LinearAlgebra**: Matrix operations and linear algebra
- **Statistics**: Statistical functions
- **QuadGK**: Numerical integration
- **Optim**: Optimization algorithms
- **DifferentialEquations**: Solving differential equations
- **Plots**: Visualization
- **Distributions**: Probability distributions
- **Random**: Random number generation

## Notes

- Julia is JIT-compiled, so first runs may include compilation time
- Use `.jl` files for organizing longer scripts
- Install packages with `using Pkg; Pkg.add("PackageName")`
- Results are returned as Julia objects that are converted to readable format
