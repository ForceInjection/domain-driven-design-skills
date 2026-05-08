---
name: thinking-frameworks
description: PROACTIVELY invoke this skill for any task, problem, or decision requiring structured thought, fresh perspectives, or 'out-of-the-box' thinking. Provides unified thinking frameworks for strategic thinking, prioritization, and problem analysis.
---

# Objective

Provide a unified set of thinking frameworks that help with strategic thinking, prioritization, and problem analysis. These frameworks enable structured and multi-perspective thinking for any task, problem, or decision.

<intake_protocol>
What kind of problem are you solving? Please describe:

1. **The specific challenge or decision** you're facing
2. **Your current context** (technical, business, personal, etc.)
3. **What outcome** you're trying to achieve
4. **Any constraints or considerations** (time, resources, priorities)

Based on your description, I'll select the most appropriate framework(s) to help you think through this systematically.
</intake_protocol>

<routing_logic>
Based on the user's input, I'll route to one or more of these framework categories:

## Strategic / Long-Term / Foundational Problems

**Route to**: `references/strategic.md`

Use when the user needs:

- Long-term perspective or big-picture analysis
- Understanding temporal impact and consequences
- Challenging assumptions or thinking from first principles
- Strategic positioning or comprehensive situation analysis
- Overcoming present bias in decisions

**Frameworks**: first-principles, inversion, second-order, swot, 10-10-10

## Prioritization / Focus / Resource Allocation

**Route to**: `references/prioritization.md`

Use when the user needs:

- Focus on high-impact activities
- Clarity on what to do first
- Reducing overwhelm or cutting through noise
- Identifying leverage points
- Task triage or resource allocation

**Frameworks**: pareto, one-thing, eisenhower-matrix

## Problem Analysis / Root Cause / Simplification

**Route to**: `references/problem-analysis.md`

Use when the user needs:

- Deep understanding or root cause analysis
- Making optimal choices under constraints
- Simplifying complexity
- Evaluating trade-offs
- Finding the simplest solution

**Frameworks**: 5-whys, opportunity-cost, occams-razor, via-negativa

## Multi-Framework Combinations

For complex problems, I may combine multiple frameworks:

- **first-principles + inversion**: Rebuilding while avoiding failure modes
- **second-order + 10-10-10**: Understanding cascading impacts across time
- **pareto + one-thing**: Identifying leverage points
- **5-whys + occams-razor**: Root cause analysis with simple solutions
- **eisenhower-matrix + pareto**: Task triage with impact focus

## How Routing Works

1. **Analyze the request**: Understand the context and challenge
2. **Determine category**: Is this primarily strategic, prioritization, or problem analysis?
3. **Select framework(s)**: Choose the most appropriate framework(s) from the relevant category
4. **Apply systematically**: Follow the framework process exactly
5. **Provide structured output**: Present results in a clear, actionable format
</routing_logic>

# Available Frameworks

## Strategic Thinking (references/strategic.md)

- **first-principles**: Break down to fundamentals and rebuild from base truths
- **inversion**: Identify what would guarantee failure, then avoid those things
- **second-order**: Think through consequences of consequences
- **swot**: Map strengths, weaknesses, opportunities, and threats
- **10-10-10**: Evaluate decisions across three time horizons

## Prioritization (references/prioritization.md)

- **pareto**: Apply 80/20 rule to identify vital few factors
- **one-thing**: Identify single highest-leverage action
- **eisenhower-matrix**: Categorize by urgency vs importance

## Problem Analysis (references/problem-analysis.md)

- **5-whys**: Drill to root cause by asking why repeatedly
- **opportunity-cost**: Analyze what you give up by choosing an option
- **occams-razor**: Find simplest explanation that fits all facts
- **via-negativa**: Improve by removing rather than adding

# Integration Notes

This unified skill serves the `brainstormer` agent, providing structured thinking capabilities across all three framework categories. The Router Pattern enables dynamic framework selection based on user needs while maintaining access to the full spectrum of thinking frameworks in a single, cohesive skill.
