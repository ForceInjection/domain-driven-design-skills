---
name: comparing-branches
description: Use when user wants to compare two autonomy branches to see different approaches, metrics, and outcomes
---

# Comparing Branches

## Overview

Compare two autonomy branches to show where they diverged, how their approaches differ, and what outcomes each achieved.

**Core principle:** Use git merge-base to find divergence, then dispatch branch-analyzer for computational comparison.

## When to Use

Use this skill when:
- User runs `/compare-branches` command
- User wants to see differences between two exploration branches
- User wants to understand alternative approaches
- User wants to compare metrics/outcomes across branches

**DO NOT use for:**
- Analyzing single branch (use analyzing-branch-status instead)
- Listing all branches (use listing-branches instead)
- Current branch review (use reviewing-progress instead)

## Quick Reference

| Step | Action | Tool |
|------|--------|------|
| 1. Parse and validate | Normalize branch names, check both exist | Bash |
| 2. Find divergence | Use git merge-base to find common ancestor | Bash |
| 3. Dispatch agent | Send both branches to branch-analyzer | Task |
| 4. Present comparison | Display comparative report | Direct output |

## Process

### Step 1: Parse and Validate Branch Names

Extract and normalize both branch names:

**Parse arguments:**
```
args = "<branch-a> <branch-b>"
Split on whitespace:
  branch_a = first word
  branch_b = second word

If not exactly 2 words:
  Error: "Usage: /compare-branches <branch-a> <branch-b>"
```

**Normalize:**
```bash
# Add autonomy/ prefix if missing
if [[ "$branch_a" != autonomy/* ]]; then
  branch_a="autonomy/$branch_a"
fi

if [[ "$branch_b" != autonomy/* ]]; then
  branch_b="autonomy/$branch_b"
fi
```

**Validate both exist:**
```bash
# Check branch A
if ! git branch -a | grep -q "$branch_a\$"; then
  echo "Error: Branch '$branch_a' not found."
  echo ""
  echo "Available autonomy branches:"
  git branch -a | grep 'autonomy/' | sed 's/^..//; s/ -> .*//'
  exit 1
fi

# Check branch B
if ! git branch -a | grep -q "$branch_b\$"; then
  echo "Error: Branch '$branch_b' not found."
  echo ""
  echo "Available autonomy branches:"
  git branch -a | grep 'autonomy/' | sed 's/^..//; s/ -> .*//'
  exit 1
fi
```

**Validate both are autonomy branches:**
```bash
for branch in "$branch_a" "$branch_b"; do
  if [[ "$branch" != autonomy/* ]]; then
    echo "Error: Branch '$branch' is not an autonomy branch."
    echo ""
    echo "These commands only operate on autonomy/* branches."
    exit 1
  fi
done
```

### Step 2: Find Divergence Point

Use git to find where the branches diverged:

```bash
# Find common ancestor
merge_base=$(git merge-base "$branch_a" "$branch_b" 2>&1)

# Check if command succeeded
if [ $? -ne 0 ]; then
  echo "Error: Cannot find common ancestor between '$branch_a' and '$branch_b'."
  echo ""
  echo "This may mean:"
  echo "- Branches have completely independent histories"
  echo "- Branch was rebased and history was rewritten"
  echo ""
  echo "Git error: $merge_base"
  exit 1
fi

# Get divergence info
divergence_date=$(git log -1 --format='%ai' "$merge_base")
divergence_short=$(git rev-parse --short "$merge_base")
```

**Find iteration at divergence (if it exists):**
```bash
# Check if divergence point has an iteration tag
divergence_tag=$(git tag --points-at "$merge_base" | grep 'iteration-')
if [ -n "$divergence_tag" ]; then
  divergence_iteration=$(echo "$divergence_tag" | sed 's/.*iteration-//')
else
  divergence_iteration="(no iteration tag at divergence)"
fi
```

### Step 3: Dispatch Branch-Analyzer Agent

Dispatch the `branch-analyzer` agent with comparison instructions:

```bash
Task tool with subagent_type: "autonomy:branch-analyzer"
Model: haiku
Prompt: "Compare two autonomy branches and show differences in approaches and outcomes.

Branches:
- Branch A: $branch_a
- Branch B: $branch_b

Divergence point: $merge_base ($divergence_short)
Divergence date: $divergence_date
Divergence iteration: $divergence_iteration

Tasks:
1. Read all journal commits on branch A since divergence
2. Read all journal commits on branch B since divergence
3. Parse each commit message for: iteration, date, status, metrics, blockers, next steps
4. Generate Python script to compare:
   - Iteration counts on each branch
   - Status patterns (how often active/blocked/etc)
   - Metrics trajectories (if metrics exist)
   - Different decisions/approaches mentioned
   - Outcomes on each branch
5. Execute Python script
6. Output comparative markdown report

Use computational methods (Python scripts), do not eyeball the comparison.

Report format:
- Divergence Information section
- Iteration Comparison section
- Metrics Comparison section (if metrics exist)
- Approach Differences section
- Outcomes and Status section
- Insights and Recommendations section"
```

**Agent will:**
1. Get commit range for each branch since divergence
2. Read journal commits from both ranges
3. Parse metadata from commit messages
4. Generate Python script for comparison
5. Execute script to produce comparative analysis
6. Return formatted markdown report

### Step 4: Present Comparison Report

Display agent's comparative report to user.

**Example output format:**
```markdown
# Branch Comparison

**Branch A:** autonomy/experiment-a
**Branch B:** autonomy/experiment-b

---

## Divergence Information

**Common ancestor:** abc123f
**Divergence date:** 2025-12-15
**Divergence iteration:** 0015

Branches have been exploring different approaches for 18 days.

---

## Iteration Comparison

| Branch | Iterations Since Divergence | Current Iteration | Latest Update |
|--------|----------------------------|-------------------|---------------|
| experiment-a | 13 (0016-0028) | 0028 | 2026-01-02 |
| experiment-b | 8 (0016-0023) | 0023 | 2025-12-28 |

**Observation:** Branch A has progressed more iterations but is currently blocked. Branch B has fewer iterations but is active.

---

## Metrics Comparison

### MRR Trajectory

- **experiment-a:** $45k → $62k (+37.8%)
  - Faster growth, reached $62k at iteration 0028
- **experiment-b:** $45k → $58k (+28.9%)
  - Steady growth, reached $58k at iteration 0023

### Build Time

- **experiment-a:** 5.2min → 3.2min (-38.5%)
  - Significant optimization focus
- **experiment-b:** 5.2min → 4.8min (-7.7%)
  - Minor improvements only

---

## Approach Differences

### Branch A (experiment-a): Usage-based pricing
- Implemented tiered usage model
- Real-time usage tracking
- API rate limiting integration
- **Current status:** Blocked on Stripe API integration

### Branch B (experiment-b): Flat enterprise pricing
- Fixed pricing tiers (Startup/Growth/Enterprise)
- Annual commitment discounts
- Sales-assisted onboarding
- **Current status:** Active, implementing pricing page UI

---

## Outcomes and Status

| Branch | Current Status | Key Achievement | Main Blocker |
|--------|----------------|-----------------|--------------|
| experiment-a | blocked | Higher MRR growth (+37.8%) | Stripe webhook docs |
| experiment-b | active | Simpler implementation | None currently |

---

## Insights and Recommendations

**What worked well:**
- **experiment-a:** Usage-based model drove higher revenue but added complexity
- **experiment-b:** Flat pricing is simpler to implement and maintain

**What didn't work:**
- **experiment-a:** Dependency on external Stripe API caused blocking
- **experiment-b:** Slower revenue growth compared to usage model

**Cross-branch learning:**
- experiment-b could adopt experiment-a's build optimizations (-38.5% improvement)
- experiment-a could simplify by borrowing experiment-b's pricing page approach
- Consider hybrid: flat base + usage overage (best of both)

**Recommendations:**
1. If revenue growth is priority: Continue experiment-a, resolve Stripe blocker
2. If speed to market is priority: Continue experiment-b, ship simple version
3. If unsure: Fork new branch from divergence point implementing hybrid approach
```

## Important Notes

### Only Autonomy Branches

This skill ONLY compares `autonomy/*` branches:
- Validates both branches have `autonomy/` prefix
- Will not compare non-autonomy branches
- Branches must share common ancestor (git merge-base succeeds)

### Computational Comparison Required

**DO NOT:**
- Manually compare commits
- "Eyeball" which branch is better
- Guess at metrics differences

**DO:**
- Dispatch branch-analyzer agent
- Let agent generate Python scripts
- Use computational methods for precision

### Read-Only Operations

All comparison happens via git commands:
- Never checkout either branch
- Read commits via `git log <branch>` for each
- Branch-analyzer uses read-only operations
- No modifications to any files

### No Value Judgments

**DO NOT:**
- Declare one branch "better" or "worse"
- Recommend abandoning a branch
- Make strategic decisions for user

**DO:**
- Present objective comparison
- Note trade-offs
- Suggest cross-branch learning opportunities
- Let user decide which approach to continue

### Branches May Have No Metrics

- Not all branches track quantitative metrics
- Metrics section may be "None" in commit messages
- Report should handle missing metrics gracefully
- Can still compare on iterations, status, decisions

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "I'll declare branch A is better" | NO. Present objective comparison, let user decide. |
| "I'll recommend merging branches" | NO. Autonomy branches never merge. Only cross-learning via /analyze-branch. |
| "Only 5 iterations different, I can compare manually" | NO. Always dispatch branch-analyzer for computational analysis. |
| "Branches have no common ancestor, I'll error" | CORRECT. This is a real error case - branches are independent. |
| "I'll checkout branches to compare journals" | NO. Read commit messages via git log. Never checkout. |

## After Comparing

Once comparison is complete:
- Report displayed to user
- No files created or modified
- User can fork new branch from divergence point: `/fork-iteration <iteration> <strategy-name>`
- User can analyze either branch individually: `/branch-status <branch-name>`
- User can use `/analyze-branch` to extract specific learnings from one branch for use in another
