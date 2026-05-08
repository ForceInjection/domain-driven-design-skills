---
name: exploratory-analysis
description: Systematic exploratory data analysis process - discover patterns in unfamiliar data, identify meaningful insights, formulate specific questions for deeper investigation
---

# Exploratory Analysis Process

## Overview

This skill guides you through systematic exploration of unfamiliar datasets when you don't yet have a specific question to answer. Unlike hypothesis-testing (where you test a specific claim) or guided-investigation (where you answer a specific question), exploratory analysis helps you **discover** what's interesting in the data and **identify** what questions you should be asking.

Exploratory analysis is appropriate when:
- You have a new dataset and need to understand what's in it
- The user says "Just see what's interesting" or "Tell me what stands out"
- You need to discover patterns before formulating specific questions
- You're looking for unexpected insights or anomalies
- You want to generate hypotheses for later testing

## Prerequisites

Before using this skill, you MUST:
1. Have data imported into SQLite database using the `importing-data` skill
2. Have data quality validated and cleaned using the `cleaning-data` skill (MANDATORY - never skip)
3. Have created an analysis workspace (`just start-analysis exploratory-analysis <name>`)
4. Have NO preconceived hypotheses or specific questions (if you do, use hypothesis-testing or guided-investigation instead)
5. Be familiar with the component skills:
   - `understanding-data` - for data profiling
   - `writing-queries` - for SQL query construction
   - `interpreting-results` - for result analysis
   - `creating-visualizations` - for text-based visualizations

## Mandatory Process Structure

You MUST use TodoWrite to track progress through all 5 phases. Create todos at the start:

```markdown
- Phase 1: Data Familiarization - pending
- Phase 2: Pattern Discovery - pending
- Phase 3: Anomaly Investigation - pending
- Phase 4: Insight Generation - pending
- Phase 5: Question Formulation - pending
```

Update status as you progress. Mark phases complete ONLY after checkpoint verification.

---

## Phase 1: Data Familiarization

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Catalogued all tables and their apparent purposes
- [ ] Documented schema (columns, types, relationships)
- [ ] Assessed data quality (completeness, ranges, distributions)
- [ ] Identified temporal coverage and granularity
- [ ] Saved to `01 - data-familiarization.md`

### Instructions

1. **Understand what data you have**

Create `analysis/[session-name]/01 - data-familiarization.md` with: ./templates/01-data-familiarization.md

2. **Use the understanding-data component skill**
   - Profile the database systematically
   - Don't skip quality checks - surprises are common
   - Look for obvious data issues that would affect exploration

3. **Resist premature pattern-hunting**
   - Don't start with "I wonder if weekends are different"
   - First understand WHAT data you have, THEN explore patterns
   - If you catch yourself forming hypotheses, note them for Phase 2 but finish familiarization first

**Common Rationalization:** "I can see the tables, I don't need detailed familiarization"
**Reality:** Skipping familiarization leads to missing important context about data quality, coverage, and structure.

**Common Rationalization:** "I'll explore patterns while I familiarize myself with the data"
**Reality:** Mixing familiarization and pattern-hunting creates confusion. Separate concerns.

---

## Phase 2: Pattern Discovery

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Explored temporal patterns (trends, seasonality, cycles)
- [ ] Explored segmentation patterns (groups, categories, clusters)
- [ ] Explored relationship patterns (correlations, associations)
- [ ] Documented each exploration with rationale, query, results, observations
- [ ] Created separate files for each exploration vector
- [ ] Files saved as `02-temporal-patterns.md`, `03-segmentation-patterns.md`, `04-relationship-patterns.md`

### Instructions

1. **Explore SYSTEMATICALLY along three vectors**

You MUST explore all three vectors, even if some seem less promising. Surprises often come from unexpected places.

#### Vector 1: Temporal Patterns

Create `analysis/[session-name]/02-temporal-patterns.md` with: ./templates/02-temporal-patterns.md

#### Vector 2: Segmentation Patterns

Create `analysis/[session-name]/03-segmentation-patterns.md` with: ./templates/03-segmentation-patterns.md

#### Vector 3: Relationship Patterns

Create `analysis/[session-name]/04-relationship-patterns.md` with: ./templates/04-relationship-patterns.md

2. **Be systematic, not random**
   - Explore ALL three vectors (temporal, segmentation, relationship)
   - Don't skip a vector just because first query seems uninteresting
   - Patterns often hide in places you don't expect

3. **Separate observation from interpretation**
   - In each analysis, state FACTS (what the numbers show)
   - Save interpretation for Phase 4 (Insight Generation)
   - Resist the urge to explain patterns yet - just catalog them

4. **Use visualizations liberally**
   - Text-based tables, ASCII charts, markdown formatting
   - Help patterns become visible
   - Refer to `creating-visualizations` component skill

**Common Rationalization:** "I found an interesting pattern, I'll just focus on that"
**Reality:** Focusing on first interesting pattern causes you to miss better patterns elsewhere. Complete all three vectors.

**Common Rationalization:** "This dimension looks boring, I'll skip it"
**Reality:** "Boring" dimensions often hide surprising patterns. Explore systematically.

**Common Rationalization:** "I'll combine all patterns into one analysis file"
**Reality:** Separate files by vector creates structure and makes findings easy to locate.

---

## Phase 3: Anomaly Investigation

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Identified 3-5 specific anomalies, outliers, or unexpected patterns from Phase 2
- [ ] Investigated each anomaly with follow-up queries
- [ ] Determined if anomalies are data quality issues or real phenomena
- [ ] Documented findings
- [ ] Saved to `05 - anomaly-investigation.md`

### Instructions

1. **Review Phase 2 for anomalies**

Go back through temporal, segmentation, and relationship explorations and identify:
- Unexpected spikes or drops
- Outlier values or segments
- Counterintuitive patterns
- Violations of expected business logic
- Inconsistencies or irregularities

2. **Investigate each anomaly**

Create `analysis/[session-name]/05 - anomaly-investigation.md` with: ./templates/05-anomaly-investigation.md

3. **Distinguish data quality from real patterns**
   - NULL values, duplicates, data entry errors → data quality issues
   - Seasonal events, one-time promotions, external shocks → real phenomena
   - When unclear, state that explicitly

4. **Don't ignore anomalies**
   - Anomalies are often where the most interesting insights hide
   - Investigate thoroughly, don't dismiss as "probably nothing"
   - Data quality issues found now save headaches later

**Common Rationalization:** "That spike is probably a holiday, I'll ignore it"
**Reality:** VERIFY your assumption. "Probably" isn't good enough. Check.

**Common Rationalization:** "This anomaly is a data quality issue, I'll just exclude it"
**Reality:** Document what you're excluding and why. Future analysts need to know.

**Common Rationalization:** "I found 20 anomalies, I'll investigate them all"
**Reality:** Focus on the 3-5 most significant. You're exploring, not auditing every data point.

---

## Phase 4: Insight Generation

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Reviewed all patterns and anomalies from Phases 2-3
- [ ] Identified 3-5 insights that are actionable, surprising, or meaningful
- [ ] For each insight, documented: finding, significance, context, caveats
- [ ] Assessed confidence level for each insight
- [ ] Saved to `06 - insights.md`

### Instructions

1. **Extract insights from patterns**

Not every pattern is an insight. An insight must be:
- **Actionable:** Suggests a decision or further investigation
- **Surprising:** Non-obvious, counter to expectations, or revealing hidden structure
- **Meaningful:** Materially significant magnitude or impact

2. **Document insights systematically**

Create `analysis/[session-name]/06 - insights.md` with: ./templates/06-insights.md

3. **Be selective**
   - Don't try to turn every pattern into an insight
   - 3-5 high-quality insights beat 20 marginal observations
   - If you have more than 5, rank them and focus on top 5

4. **Quantify magnitude**
   - "Sales vary by region" is not enough
   - "Top region has 3x sales of bottom region" is specific
   - Numbers make insights actionable

5. **Assess confidence honestly**
   - High confidence: Strong evidence, large sample, consistent pattern, clear interpretation
   - Medium confidence: Clear pattern but causation unclear OR limited time window OR potential confounds
   - Low confidence: Interesting but small sample OR inconsistent OR multiple plausible explanations

**Common Rationalization:** "Every pattern I found is an insight"
**Reality:** Most patterns are noise or expected. Be selective. Insights must clear the bar: actionable, surprising, meaningful.

**Common Rationalization:** "I'll just state the pattern and let the user figure out if it matters"
**Reality:** Your job is to interpret. Explain WHY the pattern matters and WHAT it suggests.

**Common Rationalization:** "I'm very confident in this insight"
**Reality:** Exploratory analysis rarely produces high confidence. Be honest about uncertainty and limitations.

---

## Phase 5: Question Formulation

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Generated 3-5 specific, answerable questions based on insights
- [ ] For each question, identified: what process to use, what data is needed, why it matters
- [ ] Prioritized questions by potential value
- [ ] Saved to `07 - next-questions.md`
- [ ] Updated `00 - overview.md` with exploration summary

### Instructions

1. **Convert insights into questions**

Each insight should suggest 1-2 follow-up questions. Good questions:
- Build on what you learned in exploration
- Are specific enough to be answerable
- Have clear business value
- Can be addressed with available (or obtainable) data

2. **Document questions for follow-up**

Create `analysis/[session-name]/07 - next-questions.md` with: ./templates/07-next-questions.md

3. **Update exploration overview**

Update `analysis/[session-name]/00 - overview.md` by adding content from: ./templates/overview-summary.md

4. **Final verification checklist**
   - [ ] Explored all three vectors (temporal, segmentation, relationship)
   - [ ] Investigated significant anomalies
   - [ ] Generated 3-5 qualified insights (actionable, surprising, meaningful)
   - [ ] Formulated specific follow-up questions
   - [ ] Prioritized questions by value
   - [ ] Updated overview with summary
   - [ ] Communicated findings to user

**Common Rationalization:** "I found interesting patterns, I'm done"
**Reality:** Exploration isn't complete until you've formulated what to investigate next. Always end with questions.

**Common Rationalization:** "I'll just suggest broad areas to explore further"
**Reality:** Be specific. "Investigate customer behavior" is not actionable. "Compare weekend vs weekday sales per operating hour using comparative-analysis skill" is actionable.

**Common Rationalization:** "I'll list every possible question I can think of"
**Reality:** Focus on the 3-5 highest-value questions. Too many options create decision paralysis.

---

## Common Rationalizations

### "I can see interesting patterns already, I'll skip data familiarization"
**Why this is wrong:** Without understanding data quality, coverage, and structure, your pattern discoveries may be artifacts or noise.

**Do instead:** Complete Phase 1 fully. Familiarization prevents false discoveries and wasted effort.

### "This exploration vector looks boring, I'll skip it"
**Why this is wrong:** The most surprising insights often come from places you didn't expect. "Boring" dimensions frequently hide interesting patterns.

**Do instead:** Explore ALL three vectors (temporal, segmentation, relationship) systematically. Be comprehensive.

### "I found one great insight, that's enough"
**Why this is wrong:** One insight doesn't exhaust a dataset. You likely missed other valuable patterns.

**Do instead:** Continue systematic exploration. Aim for 3-5 insights across different dimensions.

### "Every pattern I found is an insight"
**Why this is wrong:** Most patterns are noise, expected, or immaterial. Calling everything an insight dilutes the valuable discoveries.

**Do instead:** Apply strict criteria: actionable, surprising, meaningful. Be selective.

### "I'll just describe patterns and let the user decide if they're important"
**Why this is wrong:** Your job is interpretation, not just data reporting. Users expect you to identify what matters and why.

**Do instead:** Assess significance, provide context, explain business implications. Do the analytical thinking.

### "I'm very confident in these exploratory findings"
**Why this is wrong:** Exploratory analysis generates hypotheses, not confirmations. Patterns need validation through targeted investigation.

**Do instead:** Be honest about confidence levels. Exploratory findings are typically medium-low confidence until validated.

### "I found interesting patterns, analysis is complete"
**Why this is wrong:** Exploration is the beginning, not the end. The goal is to identify what to investigate deeply.

**Do instead:** Always complete Phase 5. Convert insights into specific, answerable questions for follow-up.

### "I'll combine all patterns into one big report"
**Why this is wrong:** Mixing temporal, segmentation, and relationship analyses creates confusion and makes findings hard to locate.

**Do instead:** Separate files by exploration vector (02-temporal, 03-segmentation, 04-relationship). Clear structure aids comprehension.

### "This anomaly is probably a data error, I'll just exclude it"
**Why this is wrong:** Assumptions about anomalies are often wrong. "Probably" isn't good enough. Also, excluding data without documentation creates reproducibility issues.

**Do instead:** Investigate anomalies in Phase 3. Document what you exclude and why. Verify your assumptions.

### "I have 15 follow-up questions, I'll list them all"
**Why this is wrong:** Too many options create decision paralysis. Not all questions are equally valuable.

**Do instead:** Prioritize ruthlessly. Focus on 3-5 highest-value questions. Help the user know where to start.

---

## Summary

This skill ensures systematic, thorough exploration of unfamiliar datasets by:

1. **Familiarizing with data first:** Understand structure, quality, and coverage before pattern-hunting
2. **Exploring systematically:** Three vectors (temporal, segmentation, relationship) ensure comprehensive discovery
3. **Investigating anomalies:** Surprises and outliers often contain the most valuable insights
4. **Generating selective insights:** Apply strict criteria (actionable, surprising, meaningful) to separate signal from noise
5. **Formulating specific questions:** Convert insights into answerable questions for deeper investigation
6. **Prioritizing next steps:** Help users know what to investigate first and why

Follow this process and you'll discover what's truly interesting in unfamiliar data, avoid random pattern-chasing, and identify high-value questions for targeted investigation.
