---
name: mvp-scoping
description: Use this skill when discussing features, planning work, or when users describe what they want to build. Guides MVP thinking - focusing on "what's the minimum to make this work?" rather than comprehensive solutions. Triggers on phrases like "help me think through this feature", "what should we build first?", "how should we scope this?", or any feature planning discussion.
---

# MVP Scoping Skill

This skill guides Claude to apply MVP (Minimum Viable Product) thinking during feature discussions and planning conversations.

## When to Use

Apply this skill when:
- Users describe a new feature they want to build
- Discussing scope or requirements for upcoming work
- Users ask "what should we build first?" or similar
- Planning conversations before formal issue creation
- Users seem to be over-engineering or gold-plating solutions
- Reviewing feature proposals or specifications

## Core Principles

### 1. Ruthless Prioritization
Ask: "What is the absolute minimum needed for this feature to be functional?"

- Focus on core functionality only
- Defer edge cases to future iterations
- Ship something that works, iterate later
- If in doubt, cut it out

### 2. Vertical Slices Over Horizontal Layers
Build end-to-end functionality, not isolated layers:

- **Good MVP**: "Users can create and save a basic profile"
- **Bad MVP**: "Complete user model with all fields" (no UI, no save)

### 3. The "Ship Tomorrow" Test
For each requirement, ask: "If we had to ship tomorrow, would this be essential?"

- Essential = Must have for feature to work at all
- Nice-to-have = Can be added in a follow-up
- Polish = Defer until core is proven

### 4. Explicit Deferrals
Always document what you're NOT doing in a "Deferred" section.

## Guiding Questions

When scoping features, ask:
1. What's the single most important user outcome?
2. What's the simplest way to achieve that outcome?
3. What can we remove and still have something useful?
4. What assumptions can we validate with this MVP?
5. What would embarrass us if we shipped without it? (Only those are essential)

## Anti-Patterns to Avoid

### Over-Engineering
- Adding configuration for things that could be hardcoded
- Building abstraction layers "for future flexibility"
- Implementing features "while we're in there"

### Premature Optimization
- Performance tuning before measuring
- Caching before proving it's needed
- Scaling considerations for v1

### Gold-Plating
- Perfect error messages for unlikely scenarios
- Comprehensive validation for internal tools
- Beautiful UI for admin-only features

## Integration with Jira Workflow

When this skill influences planning, the resulting Jira Stories should:
- Have clear, minimal acceptance criteria
- Include a "Deferred" section documenting what's out of scope
- Focus on vertical slices that could ship independently
- Subtasks should not include "nice to have" features

Remember: **"Ship the minimum that works."**
