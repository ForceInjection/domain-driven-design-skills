---
name: reviewing-progress
description: Use when user wants to assess progress toward an open-ended goal by reading and summarizing all iteration journals
---

# Reviewing Progress

## Overview

Assess progress toward an open-ended goal by reading iteration journals, summarizing achievements, identifying patterns, and suggesting next steps.

**Core principle:** Regular review reveals trends, validates strategy, and informs future direction.

## When to Use

Use this skill when:
- User runs `/review-progress` command
- User asks "how are we doing?" or "what's our progress?"
- Need to assess if current strategy is working
- Deciding whether to pivot approach
- Preparing report on goal status

**Can be used:**
- Mid-iteration (doesn't end current iteration)
- Standalone (no active iteration required)
- Anytime user wants status check

## Quick Reference

| Step | Action | Tool/Agent |
|------|--------|------------|
| 1. Locate goal | Find autonomy directory | Glob |
| 2. Load summary | Read summary.md if exists | Read |
| 3. Load recent iterations | Get last 3-5 iterations | Task (journal-reader) |
| 4. Analyze progress | Identify trends, metrics, patterns | Manual analysis |
| 5. Present report | Structured progress summary | Direct output |

## Process

### Step 1: Locate Goal

Find the goal directory:

```bash
# Use Glob to find goal
pattern: "autonomy/*/goal.md"
```

**If multiple goals found:**
- List goals and ask user which to review
- If only one goal, proceed with that one

**If no goal found:**
```
"No autonomy goal found in this project. Use `/start-iteration` to begin tracking an open-ended goal."
```

### Step 2: Load Summary (if exists)

Check for summary.md:

```bash
# Use Read to load summary
file: "autonomy/[goal-name]/summary.md"
```

**If summary exists:**
- Read full content
- Note which iterations it covers
- Use as foundation for report

**If summary doesn't exist:**
- Will rely on reading iterations directly

### Step 3: Load Recent Iterations

Dispatch journal-reader to load recent context:

```
Task tool with subagent_type: "autonomy:journal-reader"
Prompt: "Read all iteration files for goal '[goal-name]' (or last 5-10 if many exist).
        Extract:
        - Progress timeline
        - Completed work by iteration
        - Persistent blockers
        - Metric trends
        - Skills most frequently used
        - Strategic pivots"
Model: haiku
```

Wait for agent response with structured findings.

### Step 4: Analyze Progress

Synthesize information from summary and journal-reader:

**Calculate metrics:**
- If goal tracks metrics: Starting value → Current value → % change
- Iteration count: How many iterations completed?
- Time elapsed: First iteration date → Latest iteration date

**Identify patterns:**
- Which types of work have been most common?
- Are there recurring blockers?
- Has strategy evolved or stayed consistent?
- Which skills/workflows used most frequently?

**Assess trajectory:**
- Is progress accelerating, steady, or slowing?
- Are recent iterations more or less productive?
- Is current approach working?

**Flag concerns:**
- Blockers appearing in multiple iterations (persistent issues)
- Metrics stagnating or declining
- Lack of clear recent progress
- Strategy thrashing (frequent pivots without validation)

### Step 5: Present Report

Generate comprehensive progress report:

```markdown
# Progress Report: [Goal Name]

**Report Date:** [Today's date]
**Goal Status:** Active
**Iterations Completed:** [N]
**Time Elapsed:** [First date] - [Latest date] ([X days/weeks/months])

---

## Goal Statement
[From goal.md]

---

## Progress Overview

### Key Metrics
| Metric | Starting | Current | Change |
|--------|----------|---------|--------|
| [Metric 1] | [Value] | [Value] | [+X% or -Y%] |
| [Metric 2] | [Value] | [Value] | [+X% or -Y%] |

### Timeline of Major Work
- **Iteration 1:** [Summary of work]
- **Iteration 2:** [Summary of work]
- **Iteration N:** [Summary of work]

### Completed Initiatives
✅ [Initiative 1]: [Outcome]
✅ [Initiative 2]: [Outcome]

### In Progress
🚧 [Initiative 3]: [Current state]

---

## Current State

### What's Working Well
- [Positive pattern 1]
- [Positive pattern 2]

### Current Blockers
- **[Blocker 1]:** [First appeared iteration X, still unresolved]
- **[Blocker 2]:** [Description and impact]

### Open Questions
- [Question 1]
- [Question 2]

---

## Analysis

### Strategic Evolution
[How has the approach changed over time?]
- Iteration 1-3: [Initial strategy]
- Iteration 4-6: [Pivot or continuation]
- Current: [Where we are now]

### Skills & Methods Most Used
- **[Skill/workflow]:** Used in [X] iterations for [purpose]
- **[Skill/workflow]:** Used in [Y] iterations for [purpose]

### Effectiveness Assessment
[Is the current approach working?]
- **Strengths:** [What's effective]
- **Weaknesses:** [What's not working]
- **Opportunities:** [What could be explored next]

---

## Recommendations

### Immediate Next Steps
1. [Specific action based on current state]
2. [Specific action based on blockers]

### Strategic Considerations
- [Consider pivot if X]
- [Double down on Y because Z]
- [Investigate new approach for A]

### Health Check
[Overall assessment: Is goal on track? Should strategy change? Is this goal still valuable?]

---

**This is an open-ended goal - continuous iteration and optimization expected.**
```

## Important Notes

### Mid-Iteration Review

If reviewing during active iteration:
- Include current iteration work in report
- Note that current iteration is in progress
- Don't write journal entry (that's ending-an-iteration's job)

### Standalone Review

If no iteration active:
- Report based solely on journal history
- Suggest starting new iteration if next steps are clear

### Frequency Recommendations

Suggest reviewing progress:
- Every 5 iterations (natural checkpoint)
- When considering strategy pivot
- Before major decisions
- If feeling lost or uncertain

### Honesty in Assessment

**Be honest:**
- If metrics aren't improving, say so
- If approach isn't working, acknowledge it
- If goal seems stalled, flag it
- Don't sugarcoat to avoid disappointing user

**Constructive:**
- Always include specific next steps
- Suggest concrete changes if needed
- Identify what IS working to preserve

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Progress looks good" without data | NO. Use specific metrics and evidence. |
| "I'll review just the last iteration" | NO. Look at full history for patterns. |
| "No need to flag concerns" | NO. Honest assessment helps course-correct. |
| "I'll skip analysis and just list work done" | NO. Synthesis and insights are the value. |
| "Goal is open-ended so no progress metrics" | NO. Even open goals have measurable indicators. |

## After Reviewing

Once review is complete:
- User has clear picture of progress
- Can decide: continue current path, pivot strategy, or pause goal
- Next iteration can incorporate review insights
- May identify need to update goal.md with new success criteria
