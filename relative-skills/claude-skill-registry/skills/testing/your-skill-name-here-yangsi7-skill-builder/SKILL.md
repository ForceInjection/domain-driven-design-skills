---
# Name: Use kebab-case (letters, numbers, hyphens only)
# Examples: api-error-handling, condition-based-waiting, flatten-with-flags
# NO parentheses, NO special chars, NO underscores
name: your-skill-name-here

# Description: CRITICAL for Claude Search Optimization (CSO)
# Format: "Use when [specific triggering conditions] - [what it does and how it helps]"
# Write in THIRD PERSON (injected into system prompt)
# Include CONCRETE symptoms, error messages, situations
# Keep under 500 characters if possible
#
# Examples:
# GOOD: "Use when tests have race conditions, timing dependencies, or pass/fail inconsistently - replaces arbitrary timeouts with condition polling for reliable async tests"
# GOOD: "Use when implementing any feature or bugfix, before writing implementation code - write the test first, watch it fail, write minimal code to pass; ensures tests actually verify behavior by requiring failure first"
# BAD: "For async testing" (too vague, no triggers)
# BAD: "I can help with flaky tests" (first person)
description: Use when [specific triggering conditions and symptoms] - [what the skill does and how it helps, written in third person]
---

# [Skill Title]

<!-- Replace brackets with actual content. Delete all comments before finalizing. -->

## Overview

<!-- Core principle in 1-2 sentences. What is this skill and why does it matter? -->

[What is this skill? State the core principle clearly and concisely.]

<!-- For discipline-enforcing skills (TDD, verification-before-completion, etc), add: -->
<!-- **Violating the letter of the rules is violating the spirit of the rules.** -->

<!-- This cuts off "I'm following the spirit" rationalizations -->

## When to Use

<!-- List SPECIFIC symptoms and use cases that trigger this skill -->
<!-- Think: What problems does someone face that should make them load this skill? -->

**Use this skill when:**
- [Symptom or situation 1 - be concrete and specific]
- [Symptom or situation 2 - include error messages if applicable]
- [Symptom or situation 3 - describe observable behaviors]

**When NOT to use:**
- [Counter-example 1 - helps clarify boundaries]
- [Counter-example 2]

<!-- Optional: Add small inline flowchart ONLY if decision is non-obvious -->
<!-- Use graphviz dot format. See @graphviz-conventions.dot for style rules -->
<!-- DON'T use flowcharts for: reference material, code examples, linear steps -->

## [Main Content Section]

<!-- Choose appropriate section name based on skill type: -->
<!-- - For TECHNIQUE skills: "The Process" -->
<!-- - For PATTERN skills: "Core Pattern" -->
<!-- - For REFERENCE skills: "Quick Reference" -->
<!-- - For DISCIPLINE skills: "The Iron Law" -->

<!-- TECHNIQUE Example (step-by-step how-to): -->
### The Process

1. [Step 1 - be specific and actionable]
2. [Step 2]
3. [Step 3]

<!-- PATTERN Example (mental model or code pattern): -->
### Core Pattern

**Before:**
```[language]
// Show the problematic approach
```

**After:**
```[language]
// Show the improved approach with comments explaining WHY
```

<!-- REFERENCE Example (quick lookup): -->
### Quick Reference

| Operation | Command | Notes |
|-----------|---------|-------|
| [Common task 1] | `command` | [Important details] |
| [Common task 2] | `command` | [Important details] |

<!-- DISCIPLINE Example (rule enforcement): -->
### The Iron Law

```
[STATE THE CORE RULE IN ALL CAPS]
```

[Explain consequences of violation]

**No exceptions:**
- [Close specific loophole 1]
- [Close specific loophole 2]
- [Close specific loophole 3]

<!-- Explicitly forbid workarounds you discovered during testing -->

## Implementation

<!-- Show concrete code examples. ONE excellent example beats many mediocre ones. -->

<!-- Choose most relevant language for your domain:
- Testing techniques → TypeScript/JavaScript
- System debugging → Shell/Python
- Data processing → Python
-->

```[language]
// Complete, runnable example from real scenario
// Well-commented explaining WHY, not just what
// Shows pattern clearly and ready to adapt

[code example]
```

<!-- For reference skills with heavy API docs (>100 lines): -->
<!-- Link to separate file instead of inline: -->
<!-- See [library-name-reference.md](./library-name-reference.md) for complete API -->

## Common Mistakes

<!-- Based on ACTUAL testing with subagents, not hypothetical issues -->
<!-- Use RED-GREEN-REFACTOR: test WITHOUT skill, document failures, address in skill -->

**[Mistake 1 heading - make it searchable]**

[What goes wrong and why]

[How to fix it - be specific]

**[Mistake 2 heading]**

[What goes wrong and why]

[How to fix it]

<!-- For DISCIPLINE skills, add Red Flags section: -->
## Red Flags - STOP and Start Over

<!-- List warning signs from testing that indicate agent is rationalizing -->

- [Warning sign 1 - quote actual rationalizations from baseline testing]
- [Warning sign 2]
- [Warning sign 3]
- "I'm following the spirit" or "This is different because..."

**All of these mean:** [Correct action - usually "Stop. Start over."]

<!-- For DISCIPLINE skills, add Rationalization Table: -->
## Rationalization Table

<!-- Build from ACTUAL rationalizations discovered during baseline testing -->
<!-- Every excuse agents made goes here with counter-argument -->

| Excuse | Reality |
|--------|---------|
| [Common rationalization 1] | [Counter-argument with evidence] |
| [Common rationalization 2] | [Counter-argument] |
| [Common rationalization 3] | [Counter-argument] |

## [Optional: Real-World Impact / Trade-offs]

<!-- Only include if you have concrete data or important trade-offs to discuss -->

**Impact:**
- [Concrete result 1]
- [Concrete result 2]

**Trade-offs:**
- **Advantage:** [Benefit]
- **Cost:** [What you give up]
- **When worth it:** [Conditions]

<!-- DELETE THIS ENTIRE SECTION if not applicable -->
