---
name: greedy-selection-algorithm
description: Use when building selection algorithms that must balance multiple diversity/coverage constraints (e.g., selecting test cases, sampling datasets, portfolio optimization). Especially useful when hard co...
tags:
  - code-pattern
  - learned
  - algorithms
  - selection
  - diversity
  - constraints
  - migration
---

# Greedy selection algorithm pattern for subset selection with diversity constraints

## When to Use
Use when building selection algorithms that must balance multiple diversity/coverage constraints (e.g., selecting test cases, sampling datasets, portfolio optimization). Especially useful when hard constraints can conflict and you need observable, debuggable scoring.

## Code Pattern

When implementing a greedy selection algorithm that needs to balance multiple constraints (diversity, coverage, distribution):

1. **Tracking Sets Pattern**: Maintain separate tracking sets for each constraint dimension
   - Set for selected items (deduplication)
   - Set for categorical attributes (e.g., instructors, tags)
   - Map for distribution tracking (e.g., era counts)

2. **Scoring Function**: Break down total score into named components
   - Return score breakdown object (aids debugging)
   - Weight factors by importance (uniqueness > coverage > balance)
   - Use bonuses (+10, +5, +1) instead of multiplication (clearer semantics)

3. **Superset Guarantee**: Always seed with previous results for incremental expansion
   - Initialize tracking from seed data
   - Prevents regression in constraint satisfaction

4. **Constraint Validation**: Separate scoring from validation
   - Score = selection priority (greedy step)
   - Validation = hard constraints (exit criteria)
   - Report both target and actual values

5. **Progress Reporting**: Log every Nth iteration with score breakdown
   - Helps debug why selection stalls or diverges
   - Shows which constraints are dominating selection

Example structure:
```typescript
function scoreItem(item, selected, tracking, constraints) {
  const breakdown = {
    uniqueness: !tracking.has(item.key) ? 10 : 0,
    coverage: item.newAttributes.filter(a => !tracking.seen.has(a)).length,
    balance: isUnderrepresented(item.category) ? 5 : 0,
  };
  return { ...item, score: sum(breakdown), breakdown };
}

while (selected.size < target) {
  const remaining = candidates.filter(c => !selected.has(c));
  const scored = remaining.map(c => scoreItem(c, selected, tracking, constraints));
  scored.sort((a, b) => b.score - a.score);
  
  const winner = scored[0];
  selected.add(winner);
  updateTracking(winner, tracking);
  
  if (iteration % 10 === 0) logProgress(winner);
}
```


## Reference Files

- `migration/scripts/select-courses.ts`
- `migration/scripts/query-phase2-courses.ts`


---
*Learned from swarm execution on 2025-12-13*