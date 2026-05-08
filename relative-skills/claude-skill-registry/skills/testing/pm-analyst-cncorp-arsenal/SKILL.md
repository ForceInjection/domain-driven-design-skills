---
name: pm-analyst
description: End-to-end PM workflow - from data analysis to pragmatic Linear tickets. Analyzes user behavior, identifies opportunities, creates specs, and audits for simplicity.
---

# PM Analyst Skill

**The pragmatic product manager's workflow** - from data to shipping.

## When to Use

Use this skill when you need to:
- Answer product questions with data ("How did users react to our 1:1 messages?")
- Identify the #1 product opportunity from analysis
- Create a Linear ticket with complete requirements
- **Audit that ticket to ship 80% of value at 20% of complexity**

## The PM Analyst Philosophy

### Core Principles

1. **Data-driven, not opinion-driven**
   - Start with real user behavior
   - Measure what matters
   - Let data reveal opportunities

2. **Impact > Effort**
   - Identify the 80/20 solution
   - Ship small, learn fast
   - Avoid premature optimization

3. **Ship to learn**
   - Perfect is the enemy of shipped
   - Prefer MVPs over big designs
   - Measure, then iterate

4. **Lean startup thinking**
   - Smallest change that tests hypothesis
   - Gradual rollouts
   - Decision gates based on data

## The Workflow

### Step 1: Analyze (Data → Insights)

**Use skills:**
- `funnel-analysis` - For activation/retention questions ("show me the funnel")
- `sql-reader` + `product-analytics` - For general product questions
- `therapist-data-scientist` - For therapeutic metrics

**Question format:**
- "Show me the funnel" → use funnel-analysis
- "How did users react to our 1:1 messages?" → use sql-reader
- "What % of users are power users?" → use funnel-analysis

**Output:** Comprehensive analysis markdown file

**Quality checks:**
- ✅ Queried production database
- ✅ Sample size documented
- ✅ Patterns identified and named
- ✅ Qualitative examples included
- ✅ Failure modes analyzed
- ✅ Statistical context provided

**Example:** `codel_1on1_reactions_analysis.md`

---

### Step 2: Identify Opportunity (Insights → Priority)

**Framework:** Apply PM judgment to analysis

**Questions to answer:**
1. **What's the #1 insight?**
   - Which finding has highest impact?
   - What creates most user value?
   - What's unique to our product?

2. **Is this worth building?**
   - How many users affected?
   - How big is the pain?
   - What's the revenue impact?

3. **Can we ship it?**
   - What's the technical complexity?
   - Do we have the resources?
   - What's the risk?

**Prioritization matrix:**

| Impact | Effort | Priority |
|--------|--------|----------|
| High | Low | 🔥 SHIP NOW |
| High | Medium | ✅ Prioritize |
| High | High | 🤔 Break down |
| Medium | Low | ✅ Quick win |
| Low | High | ❌ Don't build |

**Output:** 1-2 paragraph justification of top opportunity

**Example:**
> "Meta-Commentary (🌟) is the #1 opportunity. It's already our highest-performing feature (85.9% loved), but we're only celebrating ~5-10% of positive moments due to a 6-hour cooldown. Reducing to 1-hour cooldown is HIGH IMPACT (2-3x more of what users love) and LOW EFFORT (change one SQL condition). This is our product differentiation—'coach watching over your shoulder' in real-time."

---

### Step 3: Spec the Feature (Opportunity → Requirements)

**Use skill:** feature-spec-writer

**Template:** Use "Quick Spec for Linear" format

**Requirements:**
```markdown
## Problem
{1-2 sentences: What user pain are we solving?}

## Proposed Solution (MVP)
{1-2 sentences: What's the SMALLEST change that delivers value?}

## Success Metrics
- {Metric 1}: {Current} → {Target}
- {Metric 2}: {Current} → {Target}

## Implementation
{3-5 bullet points: What needs to change?}

## Non-Goals
{What are we explicitly NOT doing in v1?}
```

**Output:** Feature spec markdown

---

### Step 4: Create Linear Ticket

**Use skill:** linear-manager

**Format:**
```bash
export LINEAR_API_KEY={key_from_arsenal/.env}

# Get team ID
.claude/skills/linear-manager/scripts/get_teams.sh

# Create ticket
.claude/skills/linear-manager/scripts/create_issue.sh \
  --title "{Concise title with key metrics/changes}" \
  --team-id "{team-uuid}" \
  --priority "{high/medium/low}" \
  --description "{Feature spec from Step 3}"
```

**Title format:** "{Action}: {Key change} ({Metric})"
- ✅ Good: "Reduce PR cooldown from 6h to 1h (2-3x increase)"
- ❌ Bad: "Improve positive reinforcement"

**Priority guide:**
- **High:** Affects many users, high impact, low risk
- **Medium:** Moderate impact or effort
- **Low:** Nice-to-have, low impact

**Output:** Linear ticket URL (CODEL-XXX)

---

### Step 5: AUDIT THE TICKET 🔍

**This is where PMs fail.** They create elaborate tickets without asking:
- **Is this the simplest version?**
- **What can we cut and still deliver 80% of value?**
- **Are we solving real problems or theoretical ones?**

#### Audit Framework

**Read the ticket and ask:**

##### 1. Scope Creep Check
- [ ] How many phases/sprints?
- [ ] Is Phase 1 independently valuable?
- [ ] Can we ship Phase 1 and stop there?

**If >1 sprint:**
→ Challenge: "Why can't we ship Phase 1 alone?"

##### 2. Premature Optimization Check
- [ ] Are we building infrastructure for hypothetical problems?
- [ ] Are we solving edge cases before validating core value?
- [ ] Do we have user evidence this complexity is needed?

**Red flags:**
- "Variety tracking for power users" (before increasing volume)
- "A/B testing framework" (before simple change)
- "User preference system" (before knowing preferences vary)

##### 3. Power User Bias Check
- [ ] What % of users are power users?
- [ ] Are we optimizing for the 1% or the 99%?
- [ ] Does the ticket clearly state user distribution?

**If optimizing for outliers:**
→ Challenge: "Should we solve for typical users first?"

##### 4. Evidence-Based Decision Check
- [ ] Do we have data showing this problem exists?
- [ ] Or are we assuming users will have this problem?
- [ ] Can we ship small and THEN decide?

**Principle:** Ship to learn, don't build to guess

##### 5. Complexity Cost Check
- [ ] What's the eng effort? (days/weeks/months)
- [ ] What's the opportunity cost? (what else could we build?)
- [ ] Is the ROI worth it?

**Calculate:** (Value delivered) / (Eng weeks spent)

#### Audit Output Format

```markdown
## 🚨 TICKET AUDIT (PM's Boss Perspective)

### Original Scope
- **Effort:** {X sprints / Y eng weeks}
- **Value:** {Expected impact}
- **Phases:** {Number}

### Critical Questions
1. **{Question 1}** - {Challenge assumption}
2. **{Question 2}** - {Challenge assumption}
3. **{Question 3}** - {Challenge assumption}

### What to Cut
❌ **Phase X:** {Why this is premature optimization}
❌ **Feature Y:** {Why this solves theoretical problem}
❌ **Infrastructure Z:** {Why this is overengineering}

### 80/20 Solution
✅ **Ship ONLY:** {Minimal scope}
✅ **Effort:** {Reduced effort}
✅ **Value:** {80% of original value}

### Revised Scope
{Simplified ticket description}

### Decision Gate
**After {timeframe}, measure:**
- {Metric 1}
- {Metric 2}

**Then decide:**
- ✅ If {condition} → Ship and move on
- ✅ If {condition} → Consider Phase 2
- ✅ If {condition} → Rollback

### Cost/Benefit
- **Original:** {X weeks} for {Y value} = {Z ROI}
- **Simplified:** {A weeks} for {B value} = **{C ROI}** (better)
```

---

## Complete Workflow Example

### User asks: "How did users react to our 1:1 messages?"

#### Step 1: Analyze
```bash
# Use therapist-data-scientist skill
# Query: message_reactions table
# Output: codel_1on1_reactions_analysis.md
```

**Key findings:**
- 71 reactions total (0.7% rate)
- 85.9% loved, 14.1% liked, 4.2% disliked
- Meta-Commentary (MC) highest-performing type
- craig (1 user) = 49% of all reactions

#### Step 2: Identify Opportunity

**Analysis:**
- MC is already best feature (85.9% loved)
- Currently under-utilized (~5-10% coverage)
- 6-hour cooldown limits frequency
- Opportunity: Celebrate 3-4x MORE growth moments

**Priority:** 🔥 HIGH IMPACT + LOW EFFORT = SHIP NOW

#### Step 3: Spec the Feature

```markdown
## Problem
Positive Reinforcement (🌟) is highest-performing message type,
but 6-hour cooldown limits coverage to ~5-10% of positive moments.

## Proposed Solution (MVP)
Reduce cooldown from 6 hours to 1 hour.

## Success Metrics
- PR volume: 2-3x increase
- Love rate: Maintain >80%
- No spam complaints

## Implementation
1. Change SQL condition: `last_6_hours` → `last_1_hour`
2. Deploy to staging (3 days)
3. Deploy to prod gradual rollout (25%→50%→100%)
4. Measure for 4 weeks

## Non-Goals
- ❌ Expanding to Medium emotional depth (Phase 2)
- ❌ Variety tracking infrastructure (Phase 3)
- ❌ Additional affect categories (Phase 4)
```

#### Step 4: Create Linear Ticket

```bash
.claude/skills/linear-manager/scripts/create_issue.sh \
  --title "Reduce PR cooldown from 6h to 1h (2-3x increase)" \
  --team-id "cf35cf6c-5d97-4123-a8d3-0f257364a795" \
  --priority "high" \
  --description "{spec from Step 3}"
```

**Output:** CODEL-803 created ✅

#### Step 5: Audit the Ticket

**PM initially proposed:**
- Phase 1: Reduce cooldown (1 sprint)
- Phase 2: Expand depth (1 sprint + A/B test)
- Phase 3: Variety tracking (2 sprints + database)
- Phase 4: Expand affects (1 sprint)
- **Total: 4-6 sprints**

**Audit findings:**
- Phase 1 alone delivers 80% of value
- Phases 2-4 are premature optimization
- No user evidence variety tracking is needed
- Building for craig (1 user) instead of 99%

**Revised scope:** Ship ONLY Phase 1
- **Effort:** 1 week (vs 4-6 sprints)
- **Value:** 80% of original (2-3x increase)
- **ROI:** 20x better

**Decision gate:** Measure for 4 weeks, then decide on Phase 2

---

## PM Analyst Checklist

Before considering your work done:

### Analysis Quality
- [ ] Used production database
- [ ] Sample size documented
- [ ] Patterns identified with clear names
- [ ] Qualitative examples included
- [ ] Failure modes analyzed
- [ ] Statistical context provided

### Opportunity Identification
- [ ] #1 insight clearly stated
- [ ] Impact vs. Effort assessed
- [ ] User segment size known
- [ ] Competitive differentiation noted

### Feature Spec
- [ ] Problem statement (1-2 sentences)
- [ ] MVP solution (simplest version)
- [ ] Success metrics with targets
- [ ] Implementation steps (3-5 bullets)
- [ ] Non-goals explicitly stated

### Linear Ticket
- [ ] Created with linear-manager skill
- [ ] Descriptive title with metrics
- [ ] Appropriate priority set
- [ ] Team ID correct
- [ ] URL returned and tested

### Audit Completion
- [ ] Challenged scope creep
- [ ] Identified premature optimization
- [ ] Checked for power user bias
- [ ] Verified evidence-based decisions
- [ ] Calculated complexity cost
- [ ] Proposed 80/20 solution
- [ ] Reduced effort by >50%
- [ ] Maintained >70% of value

---

## Red Flags to Watch For

### In Analysis
- ❌ Small sample sizes (<30)
- ❌ No qualitative examples
- ❌ Missing failure modes
- ❌ Power user skew not acknowledged

### In Opportunity Selection
- ❌ Optimizing for outliers (1% of users)
- ❌ No clear success metric
- ❌ Theoretical problem (no user evidence)
- ❌ Low impact / high effort

### In Specs
- ❌ "Big design up front"
- ❌ Multi-phase plans without decision gates
- ❌ Building infrastructure before validating need
- ❌ No non-goals section

### In Tickets
- ❌ >2 sprints for Phase 1
- ❌ A/B testing before simple change
- ❌ Database migrations for unproven features
- ❌ Solving problems that don't exist yet

---

## Integration with Other Skills

**Analysis skills:**
- `sql-reader` - Query production data
- `funnel-analysis` - User activation funnel (use for retention/activation questions)
- `therapist-data-scientist` - Calculate therapeutic metrics
- `product-analytics` - General analysis framework

**Output skills:**
- `feature-spec-writer` - Structure requirements
- `linear-manager` - Create tickets

---

## Output Files

A complete pm-analyst run produces:

1. **Analysis:** `{topic}_analysis.md`
   - Data tables
   - Pattern analysis
   - Insights and recommendations

2. **Audit:** `{topic}_audit.md` OR append to analysis
   - Critical questions
   - What to cut
   - 80/20 solution
   - Revised scope

3. **Linear ticket:** CODEL-XXX
   - Created with simplified scope
   - Decision gate at 4 weeks
   - Clear success metrics

---

## Notes

**Why this skill exists:**

Product managers often:
- Create elaborate multi-phase plans
- Build infrastructure for hypothetical problems
- Optimize for edge cases (power users)
- Skip the "ship small and learn" step

**This skill enforces:**
- Ship Phase 1 alone
- Measure for 4 weeks
- THEN decide on Phase 2
- Based on DATA, not assumptions

**The philosophy:**
> "Perfect is the enemy of shipped. Ship 80% of value at 20% of complexity. Measure. Iterate."

---

## Quick Reference

```bash
# Step 1: Analyze
# Use sql-reader or therapist-data-scientist
# Output: {topic}_analysis.md

# Step 2: Identify top opportunity
# Manual: Review analysis, pick #1 insight

# Step 3+4: Spec + Create ticket
export LINEAR_API_KEY={from arsenal/.env}
.claude/skills/linear-manager/scripts/get_teams.sh
.claude/skills/linear-manager/scripts/create_issue.sh \
  --title "{concise with metrics}" \
  --team-id "{uuid}" \
  --priority "{high/med/low}" \
  --description "{feature spec}"

# Step 5: Audit
# Review ticket through "PM's boss" lens
# Cut scope to 80/20 solution
# Add decision gate for Phase 2
```

**Remember:** The best PMs ship small and learn fast. Avoid "big design up front."
