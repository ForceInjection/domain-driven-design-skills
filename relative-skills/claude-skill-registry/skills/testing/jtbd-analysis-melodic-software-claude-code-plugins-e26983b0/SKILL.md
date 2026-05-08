---
name: jtbd-analysis
description: Apply Jobs-to-be-Done framework for outcome-driven innovation. Map customer jobs, identify underserved outcomes, and prioritize opportunities using the JTBD methodology.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Jobs-to-be-Done Analysis

## When to Use This Skill

Use this skill when:

- **Jtbd Analysis tasks** - Working on apply jobs-to-be-done framework for outcome-driven innovation. map customer jobs, identify underserved outcomes, and prioritize opportunities using the jtbd methodology
- **Planning or design** - Need guidance on Jtbd Analysis approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Jobs-to-be-Done (JTBD) is a theory of innovation that focuses on what customers are trying to accomplish (jobs) rather than on the products they buy. When people "hire" a product, they hire it to get a job done.

## Core Concepts

### The Fundamental Insight

> "People don't want a quarter-inch drill. They want a quarter-inch hole."
> — Theodore Levitt

Customers buy products to get jobs done. Understanding the job unlocks innovation opportunities.

### Job Types

| Type | Description | Example |
|------|-------------|---------|
| **Functional** | The practical task | "Ensure code quality before merge" |
| **Emotional** | How they want to feel | "Feel confident in my changes" |
| **Social** | How they want to be perceived | "Be seen as a skilled developer" |
| **Consumption** | Jobs related to product usage | "Learn to use the tool effectively" |

### Job Statement Template

```text
When [situation/context],
I want to [motivation/desire],
so I can [expected outcome].
```

**Example**:

```text
When reviewing a pull request,
I want to quickly identify potential bugs,
so I can approve changes with confidence.
```

## Job Mapping (8-Step Process)

Break complex jobs into universal steps:

| Step | Description | Questions to Ask |
|------|-------------|------------------|
| 1. **Define** | Determine goals | What are you trying to achieve? |
| 2. **Locate** | Gather inputs | What information do you need? |
| 3. **Prepare** | Set up environment | How do you get ready? |
| 4. **Confirm** | Validate readiness | How do you know you can proceed? |
| 5. **Execute** | Perform the job | What actions do you take? |
| 6. **Monitor** | Track progress | How do you know it's working? |
| 7. **Modify** | Make adjustments | What changes do you make? |
| 8. **Conclude** | Finish and evaluate | How do you know you're done? |

### Example: Job = "Ensure Code Quality Before Merge"

| Step | Job Step | Desired Outcomes |
|------|----------|------------------|
| Define | Understand what needs review | Know the scope of changes |
| Locate | Gather context about changes | Understand the reasoning behind changes |
| Prepare | Set up review environment | Have tools and context ready |
| Confirm | Verify reviewable state | Ensure CI passes, conflicts resolved |
| Execute | Review the code | Identify bugs, style issues, logic errors |
| Monitor | Track review progress | Know which files are reviewed |
| Modify | Request changes | Get author to fix issues |
| Conclude | Approve and merge | Confident in code quality |

## Outcome Statements

Outcomes are measurable, observable statements of what customers want.

### Outcome Statement Formula

```text
[Direction] + [Unit of Measure] + [Object of Control] + [Context]
```

**Direction**: Minimize, Maximize, Increase, Reduce, Eliminate, Avoid

### Examples

| Job Step | Outcome Statement |
|----------|-------------------|
| Execute | Minimize the time it takes to identify bugs in code changes |
| Execute | Reduce the likelihood of missing a security vulnerability |
| Execute | Minimize the effort required to understand unfamiliar code |
| Modify | Reduce the time to communicate feedback to the author |
| Conclude | Minimize the likelihood of post-merge issues |

### Outcome Quality Criteria

✅ **Good outcomes are**:

- Measurable (can be quantified)
- Observable (can be seen/detected)
- Customer-controlled (customer can influence)
- Job-specific (tied to a job step)
- Solution-agnostic (no specific product implied)

❌ **Avoid**:

- Vague statements ("make it better")
- Solution-embedded outcomes ("use AI to...")
- Company-controlled outcomes ("increase revenue")

## Opportunity Scoring

### Importance vs. Satisfaction

Survey customers on each outcome:

**Importance**: "How important is [outcome] to you?"
(1 = Not important, 10 = Extremely important)

**Satisfaction**: "How satisfied are you with your current solution for [outcome]?"
(1 = Not satisfied, 10 = Extremely satisfied)

### Opportunity Score Formula

```text
Opportunity Score = Importance + (Importance - Satisfaction)
```

| Score Range | Interpretation |
|-------------|----------------|
| > 15 | High opportunity (underserved) |
| 10-15 | Moderate opportunity |
| < 10 | Low opportunity (appropriately served) |
| < 0 | Overserved (potential to simplify) |

### Opportunity Landscape

```text
                    High Importance
                          │
              ┌───────────┼───────────┐
     Over-    │           │           │   Under-
     served   │   Table   │   High    │   served
              │   Stakes  │ Opportunity│
              ├───────────┼───────────┤
    Low       │   Low     │   Niche   │
    Satisfaction Priority │ Opportunity│   High
              │           │           │   Satisfaction
              └───────────┼───────────┘
                          │
                   Low Importance
```

## Interview Techniques

### Switch Interview (For Existing Products)

Understand why customers "fired" one product and "hired" another:

1. **First thought**: When did you first think about switching?
2. **Event**: What triggered the switch?
3. **Consideration**: What alternatives did you consider?
4. **Decision**: What made you choose the new solution?
5. **Consumption**: How did you get started?

### Forces Diagram

```text
          ┌─────────────────────────────────────────┐
          │           PROGRESS                      │
          │      (Desired Outcome)                  │
          └─────────────────────────────────────────┘
                     ▲             ▲
                     │             │
          ┌──────────┴──┐     ┌────┴───────────┐
          │ Push of     │     │ Pull of New    │
          │ Current     │     │ Solution       │
          │ Situation   │     │                │
          └─────────────┘     └────────────────┘
                     │             │
                     ▼             ▼
          ┌─────────────────────────────────────────┐
          │           RESISTANCE                    │
          └─────────────────────────────────────────┘
                     ▲             ▲
                     │             │
          ┌──────────┴──┐     ┌────┴───────────┐
          │ Anxiety of  │     │ Habit of       │
          │ New Solution│     │ Present        │
          └─────────────┘     └────────────────┘
```

**Questions**:

- Push: "What's frustrating about your current situation?"
- Pull: "What attracted you to the new solution?"
- Anxiety: "What concerns did you have about switching?"
- Habit: "What made it hard to leave the old solution?"

## AI-Assisted JTBD Analysis

### Job Discovery

Given a product domain, generate:

1. Main functional jobs customers need done
2. Related emotional and social jobs
3. Job context variations
4. Job statement formulations

### Job Mapping

For a given job, generate:

1. 8-step job map
2. 3-5 desired outcomes per step
3. Properly formatted outcome statements

### Opportunity Identification

When satisfaction data is available:

1. Calculate opportunity scores
2. Identify underserved outcomes (score > 15)
3. Suggest solution directions
4. Prioritize by opportunity size

### Interview Guide Creation

For a specific job, generate:

1. Screening questions
2. Switch interview questions
3. Forces diagram exploration questions
4. Outcome importance probes

## Integration Points

**Inputs from**:

- `design-thinking` skill: Empathy insights → Job context
- User research data → Satisfaction ratings
- Customer support data → Pain points → Job failures

**Outputs to**:

- `opportunity-mapping` skill: Outcomes → Opportunity tree
- `lean-startup` skill: Underserved outcomes → Hypotheses
- `persona-development` skill: Job context → Persona attributes

## References

For additional JTBD resources, see:
