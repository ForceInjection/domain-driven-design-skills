---
name: innovation-game-miner
description: This skill should be used when developing, optimizing, testing, or submitting algorithms for The Innovation Game challenges (3-SAT, CVRP, Knapsack). Use it for algorithm development, performance optimization, local testing, dry-run validation, or submission to earn TIG tokens through improved computational algorithms.
---

# Innovation Game Miner

## Overview

The Innovation Game (TIG) is a platform that monetizes algorithm development by rewarding TIG tokens for high-performing algorithms. This skill provides comprehensive support for competitive algorithm development across three challenges: Boolean Satisfiability (3-SAT), Capacitated Vehicle Routing (CVRP), and Knapsack problems.

Use this skill to develop algorithms, test performance locally, optimize for competitive benchmarking, validate submissions, and earn TIG tokens through algorithm royalties when benchmarkers adopt your solutions.

## Core Capabilities

This skill provides three major workflows:

1. **Algorithm Development**: Clone TIG repository, develop new algorithms, optimize performance
2. **Local Testing**: Test algorithms across difficulty levels and seed ranges
3. **Submission Management**: Check costs, validate with dry-runs, submit to earn tokens

## Workflow Decision Tree

Use this decision tree to determine which workflow to follow:

```
Are you starting a new TIG mining project?
├─ YES → Follow "Algorithm Development Workflow"
│
└─ NO → What do you want to do?
    ├─ Test an algorithm locally → "Testing Workflow"
    ├─ Submit an algorithm to TIG → "Submission Workflow"
    └─ Optimize an existing algorithm → "Algorithm Optimization Workflow"
```

## Algorithm Development Workflow

### Step 1: Clone TIG Challenges Repository

```bash
# Clone the official challenges repository
git clone https://github.com/the-innovation-game/challenges.git
cd challenges

# Install dependencies
pip install numpy==1.25.0
```

### Step 2: Understand Challenge Structure

Each challenge follows this structure:
```
c001_satisfiability/
├── challenge.py          # Difficulty and Challenge dataclasses
├── algorithms/
│   ├── default.py        # Baseline algorithm
│   └── <your_algo>.py    # Your algorithm
└── README.md             # Challenge description
```

**Load challenge-specific references** to understand problem details:
- `references/challenge_3sat.md` - 3-SAT strategies and optimization tips
- `references/challenge_cvrp.md` - CVRP algorithms and approaches
- `references/challenge_knapsack.md` - Knapsack techniques

### Step 3: Develop Your Algorithm

Create a new algorithm by copying and modifying an existing one:

```bash
# Copy default algorithm as starting point
cp c001_satisfiability/algorithms/default.py c001_satisfiability/algorithms/my_solver.py
```

**Algorithm requirements**:
```python
def solveChallenge(challenge: Challenge, logIntermediateInteger=int) -> Solution:
    """
    Required function signature for all TIG algorithms.

    Args:
        challenge: Instance of Challenge with seed, difficulty, and problem data
        logIntermediateInteger: Function to log intermediate values (builds signature)

    Returns:
        Solution in format specified by challenge (np.ndarray, List[List[int]], etc.)
    """
    # Your algorithm implementation here
    pass
```

**Critical constraints**:
- **Language**: Python 3.9 only
- **Libraries**: Built-in Python + numpy 1.25.0 only
- **Time limit**: 15 seconds maximum
- **Memory limit**: 1024MB maximum
- **Signature**: Must call `logIntermediateInteger()` regularly
- **No solutions**: Not all instances are solvable; handle gracefully

### Step 4: Implement Algorithm Logic

**Example: 3-SAT WalkSAT Algorithm**

```python
from c001_satisfiability.challenge import Challenge
import numpy as np

def solveChallenge(challenge: Challenge, logIntermediateInteger=int) -> np.ndarray:
    np.random.seed(challenge.seed)

    # Random initial assignment
    assignment = np.random.rand(challenge.difficulty.num_variables) < 0.5

    max_steps = 10000
    noise_prob = 0.3

    for step in range(max_steps):
        # Check if solved
        if challenge.verifySolution(assignment):
            return assignment

        # Log intermediate value for signature
        if step % 100 == 0:
            logIntermediateInteger(int(np.sum(assignment) * 1e6))

        # Find unsatisfied clauses
        v = assignment[np.abs(challenge.clauses) - 1]
        np.logical_not(v, where=challenge.clauses < 0, out=v)
        satisfied = np.any(v, axis=1)
        unsatisfied_clauses = np.where(~satisfied)[0]

        if len(unsatisfied_clauses) == 0:
            return assignment

        # Pick random unsatisfied clause
        clause_idx = np.random.choice(unsatisfied_clauses)
        clause = challenge.clauses[clause_idx]

        # Flip variable (with noise)
        if np.random.rand() < noise_prob:
            var = np.abs(np.random.choice(clause)) - 1  # Random
        else:
            var = np.abs(clause[0]) - 1  # Greedy (simplified)

        assignment[var] = not assignment[var]

    return assignment  # Return best found (may not satisfy)
```

**Refer to optimization strategies**: Load `references/optimization_strategies.md` for cross-challenge performance techniques including time management, memory optimization, vectorization, and competitive analysis.

## Testing Workflow

### Local Testing with Script

Use the provided testing script to validate algorithm correctness and performance:

```bash
# Test 3-SAT solver
python scripts/test_algorithm.py c001_satisfiability my_solver \
    --difficulty '{"num_variables": 50, "clauses_to_variables_percent": 425}' \
    --seeds 100

# Test CVRP router
python scripts/test_algorithm.py c002_vehicle_routing my_router \
    --difficulty '{"num_nodes": 20, "percent_better_than_baseline": 15}' \
    --seeds 50

# Test Knapsack solver
python scripts/test_algorithm.py c003_knapsack my_knapsack \
    --difficulty '{"num_items": 100, "percent_better_than_expected_value": 10}' \
    --seeds 100 \
    --verbose
```

**Script output**:
- Success rate (% solved)
- Time elapsed
- Errors encountered

**Success criteria**:
- ✅ 80%+ success rate on medium difficulty
- ✅ Completes within 14s per seed (leave 1s buffer)
- ✅ No memory errors

### Testing Across Difficulty Spectrum

Test multiple difficulty levels to ensure robustness:

```python
# Example: Comprehensive 3-SAT testing
difficulties = [
    {"num_variables": 30, "clauses_to_variables_percent": 350},   # Easy
    {"num_variables": 50, "clauses_to_variables_percent": 425},   # Medium
    {"num_variables": 100, "clauses_to_variables_percent": 430},  # Hard
    {"num_variables": 150, "clauses_to_variables_percent": 425},  # Scale test
]

for diff in difficulties:
    print(f"\nTesting difficulty: {diff}")
    # Run test_algorithm.py script for each difficulty
```

**Pro tip**: Most benchmarkers use default difficulty settings. Optimize for medium difficulty first, then scale to handle hard instances.

## Submission Workflow

### Step 1: Check Submission Cost and Round Status

```bash
# Check if submissions are enabled and cost
python scripts/check_submission_cost.py
```

**Output provides**:
- Current round number
- Whether submissions are enabled
- TIG token cost to submit
- Adoption threshold for royalties

**Important**: Submissions only allowed when round is active (Mondays 00:00 UTC start new rounds)

### Step 2: Check Your TIG Token Balance

```bash
# Check available balance
python scripts/check_balance.py <your-api-key>
```

**How to get an API key**: Use the [Simple Benchmarker on Google Colab](https://colab.research.google.com/github/the-innovation-game/simple_benchmarker/blob/master/notebook.ipynb)

**If insufficient balance**: Earn tokens by running the Simple Benchmarker to test algorithms and submit high-performing benchmarks.

### Step 3: Dry-Run Validation

**Always test submission acceptance first** without spending tokens:

```bash
# Dry run (FREE - no tokens spent)
python scripts/submit_algorithm.py c001_satisfiability my_solver <api-key> --dry-run
```

**Dry-run validates**:
- Algorithm code syntax
- Algorithm ID format (max 20 characters)
- File structure
- API connectivity

**If dry-run fails**: Fix errors and retry until it passes.

### Step 4: Production Submission

Once dry-run succeeds and you have sufficient balance:

```bash
# Production submission (SPENDS TIG TOKENS)
python scripts/submit_algorithm.py c001_satisfiability my_solver <api-key> \
    --accept-terms \
    --git-user "your-github-username" \
    --git-email "your@email.com" \
    --algorithm-md "path/to/description.md"
```

**What happens after submission**:
1. TIG tokens deducted from balance
2. Algorithm queued for review
3. Monday 00:00 UTC: Algorithm merged to public repository
4. Benchmarkers can start testing your algorithm
5. You earn royalties when benchmarkers use your algorithm (after adoption threshold)

**Licensing note**: All submissions must use Open Source licenses. If deriving from existing code, respect original license terms.

## Algorithm Optimization Workflow

### Performance Analysis

Compare your algorithm against the default baseline:

```python
# Benchmark against default
from c001_satisfiability.algorithms.default import solveChallenge as default_solver
from c001_satisfiability.algorithms.my_solver import solveChallenge as my_solver
from c001_satisfiability.challenge import Challenge, Difficulty
import time

difficulty = Difficulty(num_variables=50, clauses_to_variables_percent=425)
wins = 0
total = 100

for seed in range(total):
    challenge = Challenge.generateInstance(seed, difficulty)

    # Test default
    start = time.time()
    default_result = default_solver(challenge, lambda x: None)
    default_time = time.time() - start
    default_solved = challenge.verifySolution(default_result)

    # Test yours
    start = time.time()
    my_result = my_solver(challenge, lambda x: None)
    my_time = time.time() - start
    my_solved = challenge.verifySolution(my_result)

    if my_solved and not default_solved:
        wins += 1

print(f"Win rate: {wins}/{total} ({wins/total*100:.1f}%)")
```

**Target win rate**: 80%+ to be competitive

### Optimization Strategies

Load detailed optimization guidance from `references/optimization_strategies.md`, which covers:
- Time management (tiered approach, budgeting)
- Memory optimization (numpy efficiency, avoiding copies)
- Signature generation best practices
- Early termination detection
- Vectorization with numpy (10-100x speedups)
- Algorithm selection (greedy, DP, local search, genetic)
- Hybrid approaches
- Competitive analysis techniques

**Key optimization checklist**:
- [ ] Use numpy arrays instead of Python lists (32x memory savings)
- [ ] Vectorize operations with numpy (10-100x speed)
- [ ] Implement early termination for impossible instances
- [ ] Call `logIntermediateInteger()` every 10-100 iterations
- [ ] Test with profiling to find bottlenecks
- [ ] Stay under 14s time limit (leave 1s buffer)
- [ ] Keep memory under 900MB (leave buffer)

## Challenge-Specific Guidance

### 3-SAT (c001_satisfiability)

**Problem**: Determine if Boolean formula with 3 literals per clause can be satisfied

**Key insights**:
- Phase transition at ~4.2x clause-to-variable ratio (hardest region)
- WalkSAT local search performs well
- Not all instances are satisfiable

**Refer to**: `references/challenge_3sat.md` for:
- Formula representation
- Solution format
- Algorithm strategies (random search, DPLL, WalkSAT, hybrid)
- Testing strategy
- Phase transition behavior

### CVRP (c002_vehicle_routing)

**Problem**: Route vehicles to minimize distance while respecting capacity constraints

**Key insights**:
- Clarke-Wright savings algorithm beats greedy
- 2-opt refinement improves routes
- Route consolidation reduces distance

**Refer to**: `references/challenge_cvrp.md` for:
- Instance generation details
- Solution constraints
- Algorithm strategies (greedy, Clarke-Wright, k-opt, genetic)
- Validation checklist
- Real-world applications

### Knapsack (c003_knapsack)

**Problem**: Select items to maximize value within weight constraint

**Key insights**:
- Dynamic programming optimal for small-to-medium instances
- Greedy by value/weight ratio gives good approximation
- Space-optimized DP reduces memory from O(n×W) to O(W)

**Refer to**: `references/challenge_knapsack.md` for:
- Instance generation
- Solution format
- Algorithm strategies (greedy, DP, branch-and-bound, genetic)
- Memory optimization techniques
- Testing strategy

## TIG API Reference

For direct API usage or custom tooling, refer to `references/api_reference.md`, which documents:
- **GET /tig/getLatestBlock**: Round configuration and submission costs
- **GET /player/getSummary**: Token balance and earnings
- **POST /player/submitAlgorithm/{challenge_id}**: Algorithm submission (dry-run and production)
- Authentication with API keys
- Error handling
- Token economics and royalty system
- Round structure (weekly, Mondays 00:00 UTC)

## Token Economics Summary

**Earning TIG Tokens**:
- **As Innovator**: Submit algorithms, earn royalties when benchmarkers use them
- **As Benchmarker**: Run benchmarks, earn tokens for top-performing results

**Spending TIG Tokens**:
- Algorithm submissions (cost varies by round, typically 10-100 TIG)

**Royalty System**:
- Adoption threshold must be met (e.g., 5% of benchmarkers)
- Creates incentive alignment: better algorithms → more adoption → more royalties

**Round Structure**:
- New rounds start every Monday 00:00 UTC
- Algorithms submitted during the week are merged on Monday
- Check `algorithm_submissions_killswitch` before submitting

## Pre-Submission Checklist

Before submitting any algorithm, verify:
- [ ] **Correctness**: 95%+ success rate on 100+ seeds
- [ ] **Time compliance**: Never exceeds 14s (AWS Lambda has 15s timeout)
- [ ] **Memory compliance**: Peak usage < 900MB (AWS Lambda has 1024MB limit)
- [ ] **Signature generation**: Calls `logIntermediateInteger()` regularly
- [ ] **Error handling**: Gracefully handles edge cases (no solution, timeout, etc.)
- [ ] **License compliance**: Open source compatible
- [ ] **Dry-run success**: Passes API dry-run validation
- [ ] **Sufficient balance**: Enough TIG tokens for submission cost
- [ ] **Round active**: Submissions are enabled (not killswitched)

## Resources

This skill includes comprehensive resources:

### scripts/
- `test_algorithm.py` - Local testing with configurable difficulty and seeds
- `check_submission_cost.py` - Check round status and submission costs
- `check_balance.py` - Check TIG token balance and earnings
- `submit_algorithm.py` - Submit algorithms with dry-run and production modes

### references/
- `challenge_3sat.md` - 3-SAT problem details, strategies, and optimization tips
- `challenge_cvrp.md` - CVRP algorithms, techniques, and validation checklist
- `challenge_knapsack.md` - Knapsack approaches and memory optimization
- `api_reference.md` - TIG API endpoints, authentication, and token economics
- `optimization_strategies.md` - Cross-challenge optimization techniques

## External Resources

- **TIG Website**: https://the-innovation-game.com
- **TIG GitHub**: https://github.com/the-innovation-game/challenges
- **Discord Community**: https://discord.gg/cAuS733x4d
- **Simple Benchmarker**: https://colab.research.google.com/github/the-innovation-game/simple_benchmarker/blob/master/notebook.ipynb
- **TIG Whitepaper**: https://files.the-innovation-game.com/the-innovation-game-whitepaper-v1.pdf

## Quick Start Example

Complete workflow for a new TIG miner:

```bash
# 1. Clone and setup
git clone https://github.com/the-innovation-game/challenges.git
cd challenges
pip install numpy==1.25.0

# 2. Create algorithm
cp c001_satisfiability/algorithms/default.py c001_satisfiability/algorithms/my_solver.py
# (Edit my_solver.py with your improvements)

# 3. Test locally
python scripts/test_algorithm.py c001_satisfiability my_solver \
    --difficulty '{"num_variables": 50, "clauses_to_variables_percent": 425}' \
    --seeds 100

# 4. Check submission status
python scripts/check_submission_cost.py
python scripts/check_balance.py <api-key>

# 5. Dry-run validation
python scripts/submit_algorithm.py c001_satisfiability my_solver <api-key> --dry-run

# 6. Submit for real
python scripts/submit_algorithm.py c001_satisfiability my_solver <api-key> --accept-terms
```

**Congratulations!** You're now mining competitively on The Innovation Game. Monitor your algorithm's adoption and royalties through the API or TIG website.
