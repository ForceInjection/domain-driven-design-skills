---
name: prioritization-framework
description: Apply RICE, ICE, or MoSCoW scoring to prioritize features. Use when deciding what to build first, during backlog grooming, or when product-manager needs to rank items.
allowed-tools: Read, Write, Glob, Grep
---

# Prioritization Framework Skill

## Purpose

This skill applies quantitative prioritization frameworks (RICE, ICE, MoSCoW) to rank features and create data-driven backlogs.

**Use this skill when:**
- Product Manager needs to prioritize the backlog
- Deciding what to build first (strategic roadmap planning)
- User asks "what should we build next?"
- During backlog grooming or sprint planning
- Comparing multiple feature candidates

---

## Framework Selection Guide

Choose the right framework for your context:

| Framework | When to Use | Speed | Precision | Best For |
|-----------|-------------|-------|-----------|----------|
| **RICE** | Roadmap planning, major decisions | Slow | High | Strategic prioritization with stakeholder buy-in |
| **ICE** | Quick triage, daily decisions | Fast | Medium | Fast prioritization during product review |
| **MoSCoW** | Release planning, sprint scope | Medium | Medium | Categorical grouping for time-boxed releases |

**Default recommendation:** ICE for quick decisions, RICE for important prioritization.

---

## RICE Scoring

### Formula

```
RICE Score = (Reach × Impact × Confidence) / Effort
```

Higher score = higher priority

### Parameters

1. **Reach** - How many users affected per time period?
   - Estimate users per quarter (e.g., 1000 users will use this feature in Q1)
   - Be specific: "All users" = total user base count
   - "Power users only" = estimate that subset

2. **Impact** - How much value does it create per user?
   - **3** = Massive impact (transforms workflow, solves critical pain point)
   - **2** = High impact (significant improvement, removes major friction)
   - **1** = Medium impact (nice improvement, makes things easier)
   - **0.5** = Low impact (small convenience, minor enhancement)
   - **0.25** = Minimal impact (cosmetic, rarely noticed)

3. **Confidence** - How certain are you about Reach and Impact estimates?
   - **100%** = Strong data, validated user research, proven demand
   - **80%** = Good evidence, some user feedback, reasonable assumptions
   - **50%** = Educated guess, limited data, hypothetical

4. **Effort** - How many person-days to build?
   - Include design, development, testing, review, deployment
   - Ask Technical PM for effort estimates if uncertain
   - Account for complexity and unknowns

### Example Calculation

**Feature:** Dark mode for Stellaris

- **Reach:** 500 users per quarter (50% of user base prefers dark mode)
- **Impact:** 1 (medium - improves UX, not transformative)
- **Confidence:** 80% (user feedback supports this)
- **Effort:** 5 person-days (frontend + testing)

**RICE Score = (500 × 1 × 0.8) / 5 = 80**

---

## ICE Scoring

### Formula

```
ICE Score = (Impact + Confidence + Ease) / 3
```

Higher score = higher priority. Score range: 1-10.

### Parameters

All rated on 1-10 scale:

1. **Impact** - User value created (1=minimal, 10=transformative)
   - 9-10: Solves critical pain point, game-changing
   - 7-8: Major improvement, highly valuable
   - 5-6: Moderate improvement, useful
   - 3-4: Minor improvement, nice-to-have
   - 1-2: Minimal value, cosmetic

2. **Confidence** - Certainty of success (1=wild guess, 10=proven)
   - 9-10: Strong data, validated demand, proven approach
   - 7-8: Good evidence, user feedback supports
   - 5-6: Reasonable assumption, some supporting data
   - 3-4: Educated guess, limited validation
   - 1-2: Pure hypothesis, no evidence

3. **Ease** - Inverse of effort (1=very hard, 10=trivial)
   - 9-10: Hours of work, no dependencies
   - 7-8: 1-2 days, simple implementation
   - 5-6: 3-5 days, moderate complexity
   - 3-4: 1-2 weeks, complex or risky
   - 1-2: Weeks/months, major undertaking

### Example Calculation

**Feature:** Dark mode for Stellaris

- **Impact:** 6 (moderate improvement, improves UX)
- **Confidence:** 8 (user feedback supports, proven pattern)
- **Ease:** 7 (5 days effort, moderate)

**ICE Score = (6 + 8 + 7) / 3 = 7.0**

---

## MoSCoW Categorization

### Categories

- **Must Have** - Non-negotiable for this release (60% max of capacity)
- **Should Have** - Important but not critical (can defer if needed)
- **Could Have** - Nice-to-have if capacity allows (20% buffer)
- **Won't Have** - Explicitly out of scope for this release

### Assignment Rules

1. **Must Have:**
   - Blockers for other work
   - Critical bugs affecting all users
   - Compliance/security requirements
   - Core functionality for release goal

2. **Should Have:**
   - High-value features (RICE/ICE score > 7)
   - Major UX improvements
   - High-demand user requests

3. **Could Have:**
   - Medium-value features (RICE/ICE score 4-7)
   - Polish and refinements
   - Buffer for unexpected work

4. **Won't Have:**
   - Low-value features (RICE/ICE score < 4)
   - Can wait for next release
   - Explicitly deferred

### Capacity Rule

**Must Have should be ≤60% of total capacity** to leave buffer for:
- Unexpected bugs
- Scope creep
- Learning/unknowns

---

## Output Format

### RICE/ICE Ranked Backlog

Write to `00 Inbox/backlog/prioritized-backlog.md`:

```markdown
# Prioritized Backlog

**Last updated:** [ISO timestamp]
**Framework used:** [RICE/ICE]
**Total items:** [count]

---

## Ranked Items

| Rank | Item | Score | Reach | Impact | Confidence | Effort | Status |
|------|------|-------|-------|--------|------------|--------|--------|
| 1 | Dark mode | 80 | 500 | 1.0 | 80% | 5d | Ready for scoping |
| 2 | Offline lessons | 75 | 800 | 2.0 | 50% | 8d | Needs spike |
| 3 | PDF export | 40 | 200 | 1.0 | 80% | 4d | Ready for scoping |

**Top 3 priorities:**
1. Dark mode (RICE: 80) - Ready for Technical PM scoping
2. Offline lessons (RICE: 75) - Needs spike for offline storage approach
3. PDF export (RICE: 40) - Ready for plan creation

**Deferred (score < 20):**
- Custom color themes (RICE: 15) - Low reach, defer to future release
```

### MoSCoW Release Plan

Write to `00 Inbox/backlog/release-plan-[release-name].md`:

```markdown
# Release Plan: [Release Name/Version]

**Last updated:** [ISO timestamp]
**Framework used:** MoSCoW
**Target release date:** [date]
**Team capacity:** [person-days available]

---

## Must Have (60% capacity = [X] days)

- [ ] Feature 1 (5d) - [Brief description]
- [ ] Feature 2 (8d) - [Brief description]

**Total:** [Y] days ([Z]% of capacity)

---

## Should Have

- [ ] Feature 3 (3d) - [Brief description]
- [ ] Feature 4 (5d) - [Brief description]

**Total:** [Y] days

---

## Could Have (Buffer)

- [ ] Feature 5 (2d) - [Brief description]
- [ ] Feature 6 (4d) - [Brief description]

**Total:** [Y] days

---

## Won't Have (This Release)

- Feature 7 - Deferred to next release (low priority)
- Feature 8 - Needs more user validation

---

## Release Health Check

- Must Have at [X]% capacity (target: ≤60%) → [PASS/WARN]
- Buffer available: [Y] days → [PASS/WARN]
- All Must Have items clearly defined → [PASS/WARN]
```

---

## Workflow

### Step 1: Gather Input

Collect items to prioritize from:
- `00 Inbox/feedback/` (recent user feedback)
- `00 Inbox/backlog/` (existing backlog items)
- User-provided feature list

For each item, you need:
- Feature description
- User need it serves
- Rough effort estimate (ask Technical PM if uncertain)

### Step 2: Choose Framework

Ask user or default:
- **RICE** if strategic/important prioritization
- **ICE** if quick triage needed
- **MoSCoW** if release planning

### Step 3: Score Each Item

For RICE:
1. Estimate Reach (users per quarter)
2. Assess Impact (0.25 to 3 scale)
3. Determine Confidence (50%, 80%, 100%)
4. Get Effort estimate (person-days)
5. Calculate: (R × I × C) / E

For ICE:
1. Rate Impact (1-10)
2. Rate Confidence (1-10)
3. Rate Ease (1-10, inverse of effort)
4. Calculate: (I + C + E) / 3

For MoSCoW:
1. Identify Must Haves (blockers, critical)
2. Identify Should Haves (high value)
3. Identify Could Haves (nice-to-have)
4. Identify Won't Haves (deferred)
5. Verify Must Have ≤60% capacity

### Step 4: Rank and Write Output

- Sort by score (highest first)
- Write to appropriate file
- Highlight top 3-5 priorities
- Note any items needing Technical PM scoping or spikes

### Step 5: Communicate Results

Summarize for Product Manager:
- Top priorities ready for action
- Items needing investigation
- Deferred items with reasoning
- Total estimated effort for top N items

---

## Validation Rules

Before finalizing backlog:

1. **Score sanity check:**
   - RICE scores typically range 1-200 (outliers possible)
   - ICE scores range 1-10 (average should be 4-6)
   - If all items score >8, recalibrate (too optimistic)
   - If all items score <3, recalibrate (too pessimistic)

2. **Effort estimates:**
   - If effort unknown, mark "Needs Technical PM scoping"
   - Don't guess effort - ask Technical PM for estimates
   - Account for testing, review, deployment time

3. **Confidence checks:**
   - If confidence <50%, consider user research or spike
   - High-effort + low-confidence = risky, flag for investigation

4. **Must Have capacity:**
   - For MoSCoW: Must Have should be ≤60% capacity
   - If >60%, move items to Should Have

---

## Example Invocation

```
Product Manager: "Prioritize the current backlog using ICE scoring"

You (skill execution):
1. Read items from 00 Inbox/feedback/intake-2025-12-30.md
2. Read items from 00 Inbox/backlog/unprioritized.md
3. For each item:
   - Rate Impact: How valuable to users? (1-10)
   - Rate Confidence: How certain of success? (1-10)
   - Rate Ease: How easy to build? (1-10)
   - Calculate ICE score
4. Sort by score (highest first)
5. Write to 00 Inbox/backlog/prioritized-backlog.md
6. Return summary:

   "Prioritized 15 backlog items using ICE framework.

   Top 3 priorities:
   1. Dark mode (ICE: 7.0) - Ready for scoping
   2. Offline lessons (ICE: 6.7) - Needs spike
   3. PDF export (ICE: 6.3) - Ready for scoping

   Medium priority (5 items, scores 4-6):
   - Audio waveform visualization (ICE: 5.5)
   - Custom lesson playlists (ICE: 5.0)
   - ...

   Low priority (7 items, scores <4):
   - Custom color themes (ICE: 3.2) - Defer
   - ...

   Next steps:
   - Technical PM scoping for top 2 ready items
   - Spike for offline lessons approach
   - Defer low-priority items to future release

   Full backlog: 00 Inbox/backlog/prioritized-backlog.md"
```

---

## Dealing with Ties

If multiple items have identical scores:

1. **Secondary criteria:**
   - Strategic alignment (roadmap fit)
   - Dependencies (unblocks other work)
   - User pain level (critical vs nice-to-have)
   - Time sensitivity (contractual deadline, seasonal)

2. **Ask Product Manager:**
   "Items A and B have identical ICE scores (6.5). Which should take priority?
   - Item A: [description]
   - Item B: [description]"

---

## Important Notes

- **Scoring is subjective** - Frameworks provide structure, not absolute truth
- **Get effort estimates from Technical PM** - Don't guess complex work
- **Update regularly** - Re-score as new data emerges
- **Document assumptions** - Record why you scored items a certain way
- **Bias toward action** - ICE for speed, RICE for rigor, both are valid

---

## Common Pitfalls to Avoid

1. **Overconfidence:** Don't rate everything 100% confidence - be realistic
2. **Effort underestimation:** Always ask Technical PM for complex features
3. **Impact inflation:** Not everything is "high impact" - calibrate realistically
4. **Ignoring capacity:** MoSCoW Must Have >80% = recipe for failure
5. **Analysis paralysis:** ICE is good enough for most decisions - don't overthink

---

**Remember:** Prioritization frameworks are tools to support decisions, not replace judgment. Use them to structure thinking and communicate reasoning, but always apply product sense and strategic context.
