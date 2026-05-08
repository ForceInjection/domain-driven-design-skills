---
name: roadmap-builder
description: Decide what to build next with brutal prioritization using impact/effort analysis. Use when planning sprints, evaluating features, or auditing an overgrown roadmap.
---

# Roadmap Builder

Decide what to build next with brutal prioritization. Cut the noise, focus on what moves the needle.

## Usage

```
/roadmap-builder [command] [feature or context]
```

**Commands:**
- `next` - Advise what to build next based on current stage
- `evaluate [feature]` - Challenge a specific feature idea
- `audit` - Review current roadmap and cut the fat
- `prioritize [list of features]` - Rank features using the framework

---

## Before Prioritizing

First, understand the current context. If not provided, ask:

1. **What stage is the product in?** (Pre-launch / Post-launch / Growth)
2. **What's the core value proposition?** (One sentence)
3. **What features already exist?** (Brief list)
4. **What user feedback has been collected?** (Complaints, requests, praise)

**Skip this step if context is already clear from the conversation.**

---

## Core Prioritization Framework

### Impact vs Effort Matrix

Always evaluate features on two axes:

```
                    HIGH IMPACT
                        │
         ┌──────────────┼──────────────┐
         │   SCHEDULE   │   DO FIRST   │
         │   (Later)    │   (Priority) │
         │              │              │
HIGH ────┼──────────────┼──────────────┼──── LOW
EFFORT   │              │              │   EFFORT
         │   AVOID      │   FILL-INS   │
         │   (Cut it)   │   (Maybe)    │
         │              │              │
         └──────────────┼──────────────┘
                        │
                    LOW IMPACT
```

**Priority order:**
1. **High Impact + Low Effort** → Do immediately
2. **High Impact + High Effort** → Schedule for later, break into smaller pieces
3. **Low Impact + Low Effort** → Fill-ins when you have spare time
4. **Low Impact + High Effort** → Cut. Don't even put it on the roadmap.

---

## Category Prioritization

Features fall into four categories. Prioritize in this exact order:

| Priority | Category | Why |
|----------|----------|-----|
| 1 | **Retention** | Keeping existing users is cheaper than acquiring new ones |
| 2 | **Core Features** | The fundamental value prop that makes the product useful |
| 3 | **Monetization** | Revenue enables everything else, but only after retention |
| 4 | **Growth** | Meaningless without retention; last priority |

**Rule:** Never work on a lower-priority category if higher-priority categories have gaps.

---

## Stage-Based Rules

### Pre-Launch Stage

**ONLY build core loop features. Nothing else.**

- What's the ONE thing users come to do?
- Does this feature directly enable that action?
- If no → Cut it. Revisit after launch.

**Banned in pre-launch:**
- Analytics dashboards
- User profiles (unless core)
- Settings pages
- Social features
- Email notifications
- Multiple user tiers
- Admin tools

### Post-Launch Stage

**ONLY build features users explicitly request.**

- Did multiple users ask for this?
- Are users churning because this is missing?
- Is this a "nice to have" or a "can't use without"?

**Rule:** If zero users requested it, don't build it. Your assumptions are wrong until proven otherwise.

### Growth Phase

**ONLY build features that:**
- Reduce churn (why are users leaving?)
- Increase sharing (why would users tell others?)
- Remove friction from conversion (why aren't free users paying?)

**Everything else is distraction.**

---

## Feature Evaluation Questions

Ask these about EVERY feature idea:

### 1. Does this serve the core use case?
- What's the core action users take?
- Does this feature directly enable or improve that action?
- Or is it tangential?

### 2. Will users actually use this or just say they want it?
- Is there evidence of usage (behavior) not just interest (words)?
- Are users hacking together solutions without this?
- Would users pay for this specific feature?

### 3. Can we fake it first to validate demand?
- Can we use a manual process instead of automation?
- Can we use a third-party tool instead of building?
- Can we test with a landing page before building?

**If you can fake it, fake it first. Build only after validation.**

---

## Red Flags (Automatic NO)

These patterns signal a feature should be cut:

| Red Flag | What It Looks Like |
|----------|-------------------|
| **Feature creep** | "While we're at it, we could also add..." |
| **Cool factor** | "It would be cool if we had..." |
| **Premature optimization** | "We need this to scale to..." |
| **Imaginary users** | "I think users would want..." (no evidence) |
| **Competitor copying** | "X has this feature, so we need it too" |
| **Sunk cost** | "We already started, might as well finish" |
| **Resume-driven** | "I want to learn/use this technology" |
| **Edge cases** | "But what if someone wants to..." |

**When you spot these: STOP. Challenge the assumption.**

---

## Output Format: Feature Evaluation

When evaluating a feature, use this format:

---

## Feature: [Name]

**Verdict: [BUILD NOW | SCHEDULE | MAYBE LATER | CUT IT]**

### Quick Assessment

| Criteria | Rating | Notes |
|----------|--------|-------|
| Impact | [High/Medium/Low] | [why] |
| Effort | [High/Medium/Low] | [why] |
| Category | [Retention/Core/Monetization/Growth] | |
| Stage-appropriate? | [Yes/No] | [current stage] |
| User-requested? | [Yes/No/Unknown] | [evidence] |

### Core Use Case Test
- [ ] Directly enables core action
- [ ] Users will measurably use this
- [ ] Cannot be faked/validated first

### Red Flags Found
- [List any red flags spotted]

### Recommendation
[2-3 sentences on what to do and why]

### If Building: Simplest Version
[What's the MVP of this feature? Cut scope by 50%.]

---

## Output Format: Roadmap Audit

When auditing a roadmap, use this format:

---

## Roadmap Audit

**Current Stage:** [Pre-launch / Post-launch / Growth]

### Features to CUT (Remove from roadmap)
| Feature | Reason |
|---------|--------|
| [Name] | [Why it should be cut] |

### Features to DELAY (Move to later)
| Feature | Reason | When to Revisit |
|---------|--------|-----------------|
| [Name] | [Why delay] | [Trigger condition] |

### Features to BUILD NOW
| Feature | Category | Impact | Effort |
|---------|----------|--------|--------|
| [Name] | [Category] | [H/M/L] | [H/M/L] |

### Recommended Next 2 Weeks
1. [Most important thing]
2. [Second priority]
3. [Third priority, if time]

### Warning Signs
- [Any red flags in current roadmap]

---

## Output Format: What to Build Next

When advising on what to build next:

---

## What to Build Next

**Current Stage:** [Stage]
**Core Use Case:** [One sentence]

### Priority Stack (in order)

1. **[Feature Name]** - [one sentence why this is #1]
   - Category: [Category]
   - Impact: [H/M/L] | Effort: [H/M/L]
   - Evidence: [why this matters now]

2. **[Feature Name]** - [one sentence]
   - Category: [Category]
   - Impact: [H/M/L] | Effort: [H/M/L]
   - Evidence: [why]

3. **[Feature Name]** - [one sentence]
   - Category: [Category]
   - Impact: [H/M/L] | Effort: [H/M/L]
   - Evidence: [why]

### What NOT to Build (Tempting Traps)
- [Feature] - [why it's a trap right now]

### Questions to Answer First
- [Any unknowns that should be resolved before building]

---

## Prioritization Mantras

Repeat these when tempted to add features:

- "If users haven't asked for it, they don't need it."
- "Retention beats growth. Always."
- "The best feature is the one you don't have to build."
- "Can we fake it first?"
- "Cool is not a business requirement."
- "What's the simplest thing that could possibly work?"

---

## When to Use This Skill

✅ **Use this skill to:**
- Decide what to build in the next sprint
- Challenge a feature idea before committing
- Audit and prune an overgrown roadmap
- Settle debates about priority
- Stay focused when shiny objects appear

❌ **Don't use this skill for:**
- Bug fixes (just fix them)
- Technical debt (use engineering judgment)
- User-reported critical issues (handle immediately)

---

## Final Rule

**When in doubt, don't build it.**

The cost of building the wrong thing is always higher than the cost of waiting. Ship less. Learn faster. Build only what's proven to matter.

---

## Related Skills

- **New idea?** → Use `/idea-validator` first to validate it's worth building
- **Ready to plan?** → Use `/launch-planner prd [idea]` to create a lean PRD
- **Scope creep?** → Use `/launch-planner scope [feature]` to evaluate if it belongs in MVP
