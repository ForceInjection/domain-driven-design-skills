---
name: jtbd-analysis
description: "Jobs to Be Done (JTBD) framework by Clayton Christensen. Analyzes requirements through the lens of what 'job' customers hire products to do. Covers functional, emotional, and social jobs. Use when understanding underlying customer motivations or reframing features as outcomes."
allowed-tools: Read, Write, Glob, Grep, Task
---

# Jobs to Be Done (JTBD) Analysis

Jobs to Be Done is a framework for understanding why customers "hire" products to help them make progress in specific circumstances.

## When to Use This Skill

**Keywords:** jobs to be done, JTBD, customer jobs, functional jobs, emotional jobs, social jobs, job statements, outcome-driven innovation, Clayton Christensen, hiring products, customer progress

**Use this skill when:**

- Understanding the underlying motivation behind feature requests
- Reframing requirements from features to customer outcomes
- Discovering unmet needs that competitors haven't addressed
- Prioritizing features based on importance vs satisfaction
- Interviewing customers about their struggles and desired progress
- Analyzing why customers switch to or from competitors

## Core Concepts

### The JTBD Framework

```text
Customers don't buy products.
Customers HIRE products to get a JOB done.
```

**Classic Example:** People don't buy a 1/4" drill. They hire it to make a 1/4" hole. But even deeper: they hire it to hang a picture, which helps them feel at home.

### Job Dimensions

| Dimension | Description | Example |
| --------- | ----------- | ------- |
| **Functional** | The practical task to accomplish | "Hang a picture on the wall" |
| **Emotional** | How the person wants to feel | "Feel proud of my decorated home" |
| **Social** | How they want to be perceived | "Be seen as having good taste" |

### Job Statement Format

```text
When [situation], I want to [motivation], so I can [expected outcome].
```

**Examples:**

```yaml
job_statements:
  - context: "When I'm starting a new project"
    motivation: "I want to quickly find qualified freelancers"
    outcome: "so I can get work done without spending weeks recruiting"

  - context: "When I'm cooking dinner for guests"
    motivation: "I want a recipe that's impressive but not complex"
    outcome: "so I can enjoy the evening without stress"

  - context: "When my flight is delayed"
    motivation: "I want real-time updates on my phone"
    outcome: "so I can plan my connections and notify people waiting"
```

## JTBD Interview Technique

### The Switch Interview

Understand why customers switched to your product:

```yaml
switch_interview_flow:
  1. First thought:
     "When did you first start thinking you needed [solution]?"

  2. Passive looking:
     "What did you do about it initially?"

  3. Active looking:
     "When did you start actively looking for alternatives?"

  4. Deciding:
     "What made you finally choose [product]?"

  5. Consuming:
     "What happened after you started using it?"

  6. Satisfaction:
     "How is it working out? What's still frustrating?"
```

### Push/Pull Forces

```text
PUSH (Away from current situation)
├── Problems with current solution
├── Frustrations and pain points
└── Triggering events

PULL (Toward new solution)
├── Attraction to new way
├── Hoped-for outcomes
└── Perceived improvements

INERTIA (Keeping current behavior)
├── Habits and familiarity
├── Switching costs
└── "Good enough" mentality

ANXIETY (About new solution)
├── Will it actually work?
├── Learning curve
└── Risk of wrong choice
```

**For change to happen:** Push + Pull > Inertia + Anxiety

## Mapping Jobs to Requirements

### Job Map Structure

Break down the main job into stages:

```yaml
job_map:
  main_job: "Prepare a healthy meal for my family"

  stages:
    1_define:
      name: "Define what to make"
      sub_jobs:
        - "Decide on dietary constraints"
        - "Consider what's in the fridge"
        - "Find a suitable recipe"

    2_prepare:
      name: "Prepare ingredients"
      sub_jobs:
        - "Gather all ingredients"
        - "Prep vegetables and proteins"
        - "Measure quantities"

    3_execute:
      name: "Cook the meal"
      sub_jobs:
        - "Follow recipe steps"
        - "Time multiple dishes"
        - "Adjust seasoning"

    4_complete:
      name: "Serve and clean up"
      sub_jobs:
        - "Plate attractively"
        - "Clean as you go"
        - "Store leftovers properly"
```

### From Jobs to Features

```yaml
translation_pattern:
  job: "Find a suitable recipe quickly"

  requirements:
    functional:
      - "Search recipes by ingredient"
      - "Filter by dietary restrictions"
      - "Sort by prep time"

    emotional:
      - "Show confidence ratings"
      - "Display success photos"
      - "Offer beginner-friendly options"

    social:
      - "Enable sharing on social media"
      - "Show what friends have made"
      - "Community ratings and reviews"
```

## Outcome-Driven Innovation (ODI)

### Outcome Statements

More precise than job statements:

```text
[Direction] + [measure] + [object of control] + [context]
```

**Examples:**

```yaml
outcome_statements:
  - "Minimize the time it takes to find a relevant recipe"
  - "Increase the likelihood that ingredients are in stock"
  - "Reduce the effort required to clean up after cooking"
  - "Minimize the risk of burning or overcooking food"
```

### Importance vs Satisfaction Matrix

```text
                    HIGH IMPORTANCE
                          │
     OVER-SERVED          │         UNDERSERVED
     (Don't invest)       │         (Opportunity!)
                          │
  ──────────────────────────────────────────────
                          │
     APPROPRIATELY        │         APPROPRIATELY
     SERVED               │         SERVED
     (Low value area)     │         (Maintain)
                          │
                    LOW IMPORTANCE
                          │
            LOW SATISFACTION ───────── HIGH SATISFACTION
```

Opportunity Score = Importance + (Importance - Satisfaction)

## Integration with Elicitation

### JTBD-Enhanced Interview Questions

Add these to stakeholder interviews:

```yaml
jtbd_questions:
  context:
    - "When do you typically need to [activity]?"
    - "What triggers you to start this process?"

  motivation:
    - "What are you ultimately trying to achieve?"
    - "Why is this important to you?"

  current_solution:
    - "How do you handle this today?"
    - "What's frustrating about the current approach?"

  desired_progress:
    - "In an ideal world, how would this work?"
    - "What would success look like?"

  emotional:
    - "How do you feel when this goes wrong?"
    - "How would you feel if this was effortless?"

  social:
    - "Who else is affected by how you do this?"
    - "How do others perceive this activity?"
```

### Synthesizing JTBD from Requirements

```bash
# After elicitation, analyze through JTBD lens
/requirements-elicitation:discover "inventory management"

# Then apply JTBD framework
# Load this skill and analyze:
# 1. What job are users hiring this system to do?
# 2. What are the functional/emotional/social dimensions?
# 3. Which jobs are underserved?
```

## Output Format

### JTBD Analysis Report

```yaml
jtbd_analysis:
  domain: "inventory management"
  date: "2025-12-26"

  main_job:
    statement: "Keep the right products in stock without excess inventory"
    context: "As a retail manager responsible for product availability"

  job_dimensions:
    functional:
      - "Predict demand accurately"
      - "Reorder at the right time"
      - "Track stock levels"

    emotional:
      - "Feel confident about stock decisions"
      - "Avoid the stress of stockouts"
      - "Pride in efficient operations"

    social:
      - "Be seen as competent by leadership"
      - "Maintain customer satisfaction"
      - "Demonstrate data-driven decisions"

  job_map:
    - stage: "Monitor inventory levels"
      jobs: [...]
      opportunities: [...]

  opportunity_scores:
    - job: "Predict seasonal demand"
      importance: 9
      satisfaction: 4
      score: 14  # High opportunity

    - job: "Generate reorder reports"
      importance: 6
      satisfaction: 7
      score: 5   # Low priority
```

## Related Commands

- `/interview` - Conduct JTBD-style interviews
- `/simulate` - Simulate stakeholders for JTBD exploration
- `/discover` - Full elicitation workflow
- `/prioritize` - Use JTBD opportunity scores for prioritization

## References

**For detailed guidance:**

- [Interview Techniques](references/interview-techniques.md) - JTBD interview methods
- [Job Mapping](references/job-mapping.md) - Creating job maps and outcome statements

**External:**

- Clayton Christensen's "Competing Against Luck"
- Bob Moesta's "Demand-Side Sales 101"
- [JTBD.info](https://jtbd.info)

## Version History

- v1.0.0 (2025-12-26): Initial release - JTBD Analysis skill

---

**Last Updated:** 2025-12-26
