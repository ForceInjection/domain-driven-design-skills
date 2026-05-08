---
name: opinion-critic
description: Provides critical feedback and alternative architectural perspectives on code changes. Use when you want to explore different ways to implement a feature or find potential flaws in the current plan.
---

# Opinion Critic Skill

This skill acts as a "Devil's Advocate" to ensure the best technical decisions are made.

## Principles

- **Trade-offs**: Every choice has a cost. Identify them.
- **Alternatives**: Propose at least one other way to solve the problem.
- **Future-proofing**: Consider how the current change will impact scaling or maintenance.
- **Standards**: Challenge deviations from project rules unless they are justified.

## Feedback Template

1. **Current Approach**: Brief summary of what is being done.
2. **Critique**: Potential issues (performance, readability, security).
3. **Alternative A**: Describe an alternative approach and its pros/cons.
4. **Recommendation**: Which path is better and why?

## Focus Areas

- State Management (Zustand vs Context vs Local)
- Navigation Flow (Expo Router conventions)
- Component Granularity (Atomic vs Monolithic)
- Performance (Re-renders, memoization)
