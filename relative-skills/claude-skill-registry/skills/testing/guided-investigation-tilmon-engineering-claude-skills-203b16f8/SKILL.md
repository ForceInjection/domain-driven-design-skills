---
name: guided-investigation
description: Systematic process for investigating open-ended questions - decompose vague questions into specific sub-questions, map to data, investigate incrementally, synthesize findings
---

# Guided Investigation Process

## Overview

This skill guides you through systematic investigation of open-ended or exploratory questions. Unlike hypothesis testing (where you test a specific claim), guided investigation helps you answer questions like "Why is X happening?" or "What's driving Y?" by breaking them into specific sub-questions and investigating each systematically.

Guided investigation is appropriate when:
- You have a broad question without a specific hypothesis
- You need to understand a complex phenomenon with multiple potential factors
- The user says "I want to understand..." or "What's causing..."
- You need to decompose a vague question into answerable parts
- You're investigating a business problem with unclear root causes

## Prerequisites

Before using this skill, you MUST:
1. Have data imported into SQLite database using the `importing-data` skill
2. Have data quality validated and cleaned using the `cleaning-data` skill (MANDATORY - never skip)
3. Have created an analysis workspace (`just start-analysis guided-investigation <name>`)
4. Have a clear investigative goal from the user
5. Be familiar with the component skills:
   - `understanding-data` - for data profiling
   - `writing-queries` - for SQL query construction
   - `interpreting-results` - for result analysis
   - `creating-visualizations` - for text-based visualizations

## Mandatory Process Structure

You MUST use TodoWrite to track progress through all 5 phases. Create todos at the start:

```markdown
- Phase 1: Question Decomposition - pending
- Phase 2: Data Discovery - pending
- Phase 3: Systematic Investigation - pending
- Phase 4: Synthesis - pending
- Phase 5: Conclusions and Recommendations - pending
```

Update status as you progress. Mark phases complete ONLY after checkpoint verification.

---

## Phase 1: Question Decomposition

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Clarified the user's broad question
- [ ] Decomposed it into 3-5 specific, answerable sub-questions
- [ ] Prioritized sub-questions by importance/dependency
- [ ] Documented the investigative framework
- [ ] Saved to `01 - question-decomposition.md`

### Instructions

1. **Ask clarifying questions** to understand the user's goal

   - What's the core question you're trying to answer?
   - What decision will this inform?
   - What would constitute a satisfactory answer?
   - What do you already know or suspect?
   - What constraints exist (time, data, etc.)?

2. **Decompose the broad question** into specific sub-questions

Create `analysis/[session-name]/01-question-decomposition.md` with: ./templates/phase-1-question-decomposition.md

3. **STOP and get user confirmation**
   - Review the sub-questions with the user
   - Confirm they address the core question
   - Adjust priorities if needed
   - Do NOT proceed until user confirms the framework

**Common Rationalization:** "The question is clear, I can just start querying data"
**Reality:** Vague questions lead to unfocused investigation. Decompose first, always.

**Common Rationalization:** "I'll figure out the sub-questions as I go"
**Reality:** Without a clear framework, you'll chase random patterns. Plan the investigation first.

---

## Phase 2: Data Discovery

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Mapped each sub-question to specific data tables/columns
- [ ] Identified what data exists vs what's missing
- [ ] Documented data limitations that will constrain the investigation
- [ ] Created a query plan for each sub-question
- [ ] Saved to `02 - data-discovery.md`

### Instructions

1. **Map sub-questions to data**

Create `analysis/[session-name]/02-data-discovery.md` with: ./templates/phase-2-data-discovery.md

2. **Run initial data quality checks**
   - Use `understanding-data` skill to verify table structures
   - Check for NULL values, date ranges, value distributions
   - Document any surprises or data quality issues

3. **Adjust investigation plan if needed**
   - If key data is missing, modify sub-questions
   - Reprioritize based on data availability
   - Document what questions cannot be answered with available data

**Common Rationalization:** "I'll just start with queries and see what the data shows"
**Reality:** Without mapping questions to data first, you'll waste time on unfocused queries.

**Common Rationalization:** "I can skip data quality checks since I know the data"
**Reality:** Assumptions about data often turn out wrong. Check systematically.

---

## Phase 3: Systematic Investigation

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Created one numbered markdown file per sub-question
- [ ] Executed all planned queries for each sub-question
- [ ] Documented rationale, query, results, and observations for each
- [ ] Tracked findings incrementally
- [ ] Files saved as `03-SQ1-*.md`, `04-SQ2-*.md`, etc.

### Instructions

1. **Investigate ONE sub-question at a time**

Important: **ONE FILE PER SUB-QUESTION**, not one file per query. Each sub-question file may contain multiple queries.

2. **For each sub-question, create a dedicated file:**

Create `analysis/[session-name]/03-SQ1-[descriptive-name].md` (then 04-SQ2, 05-SQ3, etc.) with: ./templates/phase-3-sub-question.md

3. **Investigation sequence**
   - Follow the dependency order from Phase 1
   - Complete each sub-question fully before moving to next
   - Build on findings: let earlier answers inform later queries
   - Update your investigation plan if findings suggest new directions

4. **Use component skills as needed**
   - `writing-queries` skill for complex SQL
   - `interpreting-results` skill for understanding patterns
   - `creating-visualizations` skill for markdown tables/text charts

5. **Document incrementally**
   - Don't wait until the end to document
   - Capture observations immediately after each query
   - Note surprises, anomalies, or unexpected patterns

**Common Rationalization:** "I'll run all queries first, then document everything at the end"
**Reality:** You'll forget context and rationale. Document as you go.

**Common Rationalization:** "I found something interesting, I'll chase it instead of finishing current sub-question"
**Reality:** Stay disciplined. Note the interesting finding, complete current sub-question, then decide if it warrants investigation.

**Common Rationalization:** "I can combine multiple sub-questions into one file"
**Reality:** One file per sub-question creates clear structure and makes findings easy to locate.

---

## Phase 4: Synthesis

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Reviewed all sub-question findings together
- [ ] Identified patterns and connections across sub-questions
- [ ] Assessed which hypotheses from Phase 1 are supported/refuted
- [ ] Created a coherent narrative explaining the findings
- [ ] Saved to `XX - synthesis.md` (use next sequential number)

### Instructions

1. **Create synthesis file**

Create `analysis/[session-name]/XX-synthesis.md` with: ./templates/phase-4-synthesis.md

2. **Build a coherent narrative**
   - Connect the dots between sub-question findings
   - Identify the most parsimonious explanation
   - Acknowledge where evidence is strong vs weak
   - Be honest about alternative explanations

3. **Check your logic**
   - Does the explanation account for ALL the findings?
   - Are there contradictions you're ignoring?
   - Are you cherry-picking evidence that fits your story?
   - What would someone skeptical say?

**Common Rationalization:** "The first sub-question gave me the answer, I don't need synthesis"
**Reality:** Individual findings need integration. Synthesis reveals connections and tests coherence.

**Common Rationalization:** "I'll just present the findings separately and let the user synthesize"
**Reality:** Your job is to synthesize. Don't pass the cognitive work to the user.

---

## Phase 5: Conclusions and Recommendations

**CHECKPOINT:** Before proceeding, you MUST have:
- [ ] Written clear answer to the original broad question
- [ ] Provided specific, actionable recommendations
- [ ] Listed concrete next steps or follow-up investigations
- [ ] Documented key limitations and caveats
- [ ] Saved to `XX - conclusions.md` (use next sequential number)
- [ ] Updated `00 - overview.md` with summary

### Instructions

1. **Create conclusions file**

Create `analysis/[session-name]/XX-conclusions.md` with: ./templates/phase-5-conclusions.md

2. **Update overview file**

Update: `00 - overview.md`

Add at the end:

```markdown
## Investigation Summary

**Broad Question:** [Original question]

**Answer:** [One-sentence conclusion]

**Confidence:** [High/Medium/Low]

**Key Finding:** [Most important discovery]

**Primary Recommendation:** [Top priority action]

**Critical Limitation:** [Most important caveat]

**Recommended Follow-up:** [Most valuable next investigation]

---

## File Index

- 01 - Question Decomposition
- 02 - Data Discovery
- 03-SQ1 - [Sub-question 1 name]
- 04-SQ2 - [Sub-question 2 name]
- 05-SQ3 - [Sub-question 3 name]
- [etc. - list all files]
- XX - Synthesis
- XX - Conclusions
```

3. **Final verification checklist**
   - [ ] All sub-questions answered
   - [ ] Synthesis creates coherent narrative
   - [ ] Recommendations are specific and actionable
   - [ ] Limitations honestly stated
   - [ ] Follow-ups identified
   - [ ] Overview updated
   - [ ] User informed of conclusions

**Common Rationalization:** "I found interesting patterns, that's enough"
**Reality:** Patterns aren't conclusions. Synthesize findings into clear answer to original question.

**Common Rationalization:** "I'll let the user decide what to do with the findings"
**Reality:** Provide specific recommendations. Don't make them do all the strategic thinking.

**Common Rationalization:** "I'll skip the limitations section since the conclusion is solid"
**Reality:** Every investigation has limitations. Acknowledging them increases credibility.

---

## Complete Example: Customer Churn Investigation

### Example Scenario
User asks: "Why are we losing customers in the premium segment?"

### Phase 1: Question Decomposition (01 - question-decomposition.md)

```markdown
# Question Decomposition

## Broad Investigative Question

"Why are we losing customers in the premium segment?"

## Context and Motivation

Premium customers (>$500/month) have historically been our most stable segment with <5% annual churn. In Q1 2024, churn rate jumped to 12%. Need to understand root cause to stem the losses.

## Sub-Questions

### Sub-Question 1: When did the churn increase begin?
**What we need to learn:** Precise timing of when churn accelerated
**Why it matters:** Helps identify triggering events (pricing change, product issue, competitor launch)
**Success criteria:** Month-by-month churn rate showing inflection point

### Sub-Question 2: Are churned customers concentrated in specific product lines?
**What we need to learn:** Whether churn is product-specific or segment-wide
**Why it matters:** Product-specific churn suggests product issues; broad churn suggests market/competitive factors
**Success criteria:** Churn rate by product category with statistical significance

### Sub-Question 3: What was the tenure of churned customers?
**What we need to learn:** Are we losing new customers or long-tenured ones?
**Why it matters:** New customer churn suggests onboarding issues; long-tenure churn suggests value erosion
**Success criteria:** Distribution of churned customers by tenure (0-6mo, 6-12mo, 12-24mo, 24mo+)

### Sub-Question 4: Did churned customers show usage decline before churning?
**What we need to learn:** Whether churn was preceded by disengagement
**Why it matters:** Usage decline signals value realization problems; sudden churn suggests competitive switching
**Success criteria:** Usage metrics 30/60/90 days before churn vs stable customers

### Sub-Question 5: Are there geographic patterns to churn?
**What we need to learn:** Whether churn is concentrated in specific regions
**Why it matters:** Geographic concentration suggests regional competitive or operational factors
**Success criteria:** Churn rate by region with sample size validation

## Investigation Dependencies

1. SQ1 first (timing) - establishes when to focus detailed analysis
2. SQ2 and SQ5 parallel (product and geography) - identify concentration
3. SQ3 (tenure) - requires churn cohort identified from SQ1
4. SQ4 last (usage) - most complex, builds on understanding from others

## Hypotheses to Consider

1. **Price increase impact:** 8% price increase in January may have pushed customers over threshold
2. **Competitor launches:** Competitor Y launched enterprise tier in December
3. **Product quality:** Premium features had stability issues in Q4 2023
4. **Support degradation:** Support team had high turnover in Q1
5. **Contract renewal timing:** Many premium contracts up for renewal in Q1

## Success Criteria for Overall Investigation

Investigation complete when we can identify:
1. Primary driver of increased churn (with 70%+ confidence)
2. Quantified impact of that driver
3. Actionable recommendations to reduce churn
```

### Phase 2: Data Discovery (02 - data-discovery.md)

```markdown
# Data Discovery

## Available Data

### Tables Overview

- `customers`: Customer master data (id, signup_date, segment, region)
- `subscriptions`: Subscription details (customer_id, product_id, start_date, end_date, status)
- `usage_metrics`: Daily usage stats (customer_id, date, login_count, feature_usage)
- `products`: Product catalog (id, name, category, tier)
- `support_tickets`: Customer support interactions

### Relevant Columns by Sub-Question

#### Sub-Question 1: Timing of churn increase
**Required data:**
- `subscriptions.end_date` - when subscription ended
- `subscriptions.status` - to identify churns vs active
- `customers.segment` - to filter to premium

**Data check needed:**
- Definition of "churn" - is end_date populated for all churns?
- Completeness of historical data - how far back do we have data?

#### Sub-Question 2: Product concentration
**Required data:**
- `subscriptions.product_id` - what they were subscribed to
- `products.category` - to group products

**Data check needed:**
- Are multi-product customers handled correctly?
- Do we have category mapping for all products?

#### Sub-Question 3: Customer tenure
**Required data:**
- `customers.signup_date` - when they joined
- `subscriptions.end_date` - when they churned

**Data check needed:**
- Consistency between signup_date and first subscription start_date

#### Sub-Question 4: Usage decline
**Required data:**
- `usage_metrics.login_count` - engagement measure
- `usage_metrics.feature_usage` - specific feature adoption

**Data check needed:**
- Is usage data complete for all customers?
- What's the grain (daily, weekly)?

#### Sub-Question 5: Geographic patterns
**Required data:**
- `customers.region` - geographic identifier

**Data check needed:**
- Region data completeness
- Region definition granularity (country, state, city?)

## Data Gaps and Limitations

1. **No explicit churn reason:** Don't have exit interview data or cancellation reasons
2. **No competitor data:** Cannot directly measure competitive switching
3. **No pricing history:** Cannot analyze individual price points or grandfathered rates
4. **Limited support quality metrics:** Have ticket count but not resolution time or satisfaction scores

## Query Plan

### Sub-Question 1: Timing
1. Monthly churn count and rate for premium segment (last 12 months)
2. Comparison to prior year same period
3. Weekly granularity for Q1 2024 to identify precise inflection point

### Sub-Question 2: Product concentration
1. Churn rate by product category
2. Expected vs actual churn by category (chi-square test approach)

### Sub-Question 3: Tenure
1. Distribution of churned customers by tenure bucket
2. Churn rate by tenure bucket (churned / total in bucket)

### Sub-Question 4: Usage patterns
1. Average usage metrics 30/60/90 days before churn
2. Comparison to stable premium customers in same timeframe

### Sub-Question 5: Geography
1. Churn count and rate by region
2. Statistical significance test for regions

## Investigation Strategy

1. Start with SQ1 (timing) - will identify the specific churn cohort to analyze
2. Then SQ2 (product) and SQ5 (geography) in parallel - both straightforward, high-value
3. Then SQ3 (tenure) - quick analysis once cohort is identified
4. Finally SQ4 (usage) - most complex, requires time-series analysis
```

### Phases 3-5

[Would continue with actual queries and findings, following the same detailed structure as the hypothesis-testing example. For brevity in this skill documentation, showing structure rather than complete worked example.]

---

## Common Rationalizations

### "The question is vague, I'll just explore the data and see what I find"
**Why this is wrong:** Unfocused exploration leads to random pattern-chasing and analysis paralysis.

**Do instead:** Decompose the vague question into specific sub-questions in Phase 1. Structure the investigation.

### "I'll skip question decomposition since I know what to investigate"
**Why this is wrong:** Your initial instinct about what to investigate often misses important angles. Systematic decomposition reveals blind spots.

**Do instead:** Always do Phase 1. Writing down sub-questions forces you to think comprehensively.

### "I found an interesting pattern, I'll investigate that instead of my planned sub-questions"
**Why this is wrong:** Chasing tangents destroys investigation coherence. You end up with fragments, not a complete answer.

**Do instead:** Note interesting patterns for potential follow-up, but complete your current sub-question first.

### "I'll combine multiple sub-questions into one analysis"
**Why this is wrong:** Mixing sub-questions creates confusion and makes findings hard to locate later.

**Do instead:** One file per sub-question. Keep them separate and focused.

### "The data shows X, so the answer must be Y"
**Why this is wrong:** Correlation isn't causation. Data patterns have multiple possible explanations.

**Do instead:** Use Phase 4 synthesis to consider multiple explanations. Test competing hypotheses.

### "I have some findings, I'll just list them for the user"
**Why this is wrong:** Raw findings without synthesis don't answer the original question. You're not a data printer, you're an analyst.

**Do instead:** Synthesize findings into a coherent narrative in Phase 4. Answer the actual question asked.

### "I'll make strong recommendations even though I'm not confident"
**Why this is wrong:** Overconfident recommendations based on weak evidence damage credibility and lead to bad decisions.

**Do instead:** Calibrate recommendations to confidence level. If confidence is medium, say so and explain what would increase it.

### "I found the answer, I don't need to identify follow-up questions"
**Why this is wrong:** Every investigation should identify what to investigate next. Good analysis always reveals new questions.

**Do instead:** Always list 2-3 follow-up investigations in Phase 5. Show what the next layer of analysis would be.

### "I'll skip documenting limitations since it weakens my conclusion"
**Why this is wrong:** Hiding limitations destroys trust. Readers find them anyway, and then they distrust everything.

**Do instead:** Explicitly document limitations. Honest uncertainty is more credible than false certainty.

---

## Summary

This skill ensures systematic, comprehensive investigation of open-ended questions by:

1. **Decomposing vague questions:** Break broad questions into specific, answerable sub-questions
2. **Mapping questions to data:** Verify what data exists before diving into analysis
3. **Investigating systematically:** One sub-question at a time, building incrementally
4. **Synthesizing findings:** Connect the dots to create coherent explanations
5. **Providing actionable conclusions:** Answer the original question with specific recommendations
6. **Identifying next questions:** Every investigation reveals what to investigate next

Follow this process and you'll produce thorough, defensible investigations that answer complex business questions.
