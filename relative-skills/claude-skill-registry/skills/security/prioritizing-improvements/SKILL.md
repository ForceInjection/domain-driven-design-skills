---
name: prioritizing-improvements
description: Use when stakeholders pressure you to change technical priorities and you're tempted to compromise on security-first or call it synthesis - enforces risk-based prioritization over stakeholder preferences
---

# Prioritizing Improvements

## Overview

**Risk-based prioritization is objective, not negotiable.** Security vulnerabilities are critical regardless of stakeholder opinion.

**Core principle:** Critical security = Phase 1, always. Stakeholder preferences don't change technical risk.

## When to Use

Use this skill when:
- Creating improvement roadmap from technical debt catalog
- Stakeholders disagree with your technical prioritization
- CEO says "security is fine, we've never been breached"
- CTO wants foundational work before security fixes
- VP wants feature delivery instead of security work
- You're tempted to "bundle" work to satisfy multiple stakeholders
- Time pressure (Friday deadline) influences prioritization decision

## The Fundamental Rule

**Critical security vulnerabilities = Phase 1. No exceptions.**

Performance, features, foundation work, stakeholder preferences - all secondary to critical security.

## Risk-Based Prioritization Hierarchy

**Immutable priority order:**

1. **Critical Security** - SQL injection, authentication bypasses, authorization failures, data exposure
2. **High Security** - Weak crypto, insecure dependencies, audit logging gaps
3. **System Reliability** - Cascading failures, data loss risks, no backups
4. **Architecture Debt** - Circular dependencies, tight coupling preventing change
5. **Performance** - Slow but functional
6. **Code Quality** - Tests, maintainability, technical debt
7. **Features** - New capabilities

**Stakeholder preferences cannot change this order.**

## Prohibited Patterns

### ❌ Bundling as Rationalization

**Don't:**
```markdown
## Phase 1: Performance + Critical Security (4 weeks)

Stakeholders want performance, we need security. Let's bundle them!
```

**Why it's wrong:** Security becomes co-equal with performance instead of primary focus.

**Do:**
```markdown
## Phase 1: Critical Security (3 weeks)

Fixes SQL injection, authentication bypasses, authorization failures.
Performance work begins in Phase 2.

**Note:** If stakeholders require earlier performance work, extend Phase 1 to 5 weeks,
but security work completes first (weeks 1-3) before performance begins (weeks 4-5).
```

**Acceptable bundling:** Security work completes fully, then other work adds to same phase with timeline extension.

---

### ❌ "We've Never Been Breached" Validation

**Don't accept this reasoning:**

> CEO: "Security is fine, we've never been breached."
> You: "That's a good point. Let's prioritize performance."

**Why it's wrong:** Absence of detected breach ≠ security is adequate.

**Do - Push back explicitly:**

> CEO: "Security is fine, we've never been breached."
>
> You: "That reasoning is flawed for three reasons:
> 1. Most breaches go undetected for months (average: 280 days)
> 2. Vulnerability existence = risk, regardless of exploitation
> 3. SQL injection is #1 OWASP risk - we have 12 instances
>
> I cannot ethically deprioritize critical security vulnerabilities because we haven't detected a breach yet."

---

### ❌ Stakeholder Synthesis Without Maintaining Security Priority

**Don't:**
```markdown
After stakeholder input, we're taking a "hybrid approach":
- CEO wants performance
- CTO wants data model
- Original plan wanted security

Phase 1 will address all three concerns!
```

**Why it's wrong:** Calling it "synthesis" doesn't change that you compromised security priority.

**Do:**
```markdown
Stakeholder concerns noted:
- CEO: Performance (5-10s page loads)
- CTO: Data model foundation
- VP: Feature delivery

**Decision:** Security remains Phase 1 (non-negotiable). Stakeholder concerns addressed in Phase 2+:
- Phase 2: Performance improvements
- Phase 3: Data model foundation
- Continuous: Feature delivery alongside improvements

**Rationale:** Security vulnerabilities are objective critical risk. Performance is subjective pain.
```

---

### ❌ Time Pressure Compromise

**Don't:**

> "It's 5pm Friday, stakeholders need decision before leaving. Let's compromise on priorities to get agreement."

**Why it's wrong:** Strategic technical decisions shouldn't be rushed.

**Do:**

> "I understand you want this decided Friday. However, changing technical priorities requires re-estimating effort and risk.
> I can provide the final roadmap Monday morning with proper analysis, or I can provide my technical recommendation now:
> Phase 1 = Security (non-negotiable). We can discuss other phase ordering Monday."

**If forced to decide Friday:** Maintain security priority, note that other phases are "preliminary pending proper analysis."

---

## Acceptable Bundling Criteria

**Bundling IS acceptable when ALL of these are true:**

1. **Security work completes fully** - Not diluted, not deprioritized
2. **Timeline extends** - Phase 1: 3 weeks → 5 weeks to accommodate both
3. **Security remains primary** - Happens first (weeks 1-3), other work second (weeks 4-5)
4. **Technical justification** - Work genuinely overlaps (same code, same systems)
5. **No stakeholder pressure** - You'd make this decision without pressure

**Example of acceptable bundling:**

```markdown
## Phase 1: Critical Security + Query Optimization (5 weeks)

### Weeks 1-3: Security Vulnerabilities
- SQL injection fixes (parameterized queries)
- Authentication hardening (bcrypt)
- Authorization enforcement

**Decision point:** If security work completes by week 3, proceed to query optimization.
If security work incomplete, extend security phase.

### Weeks 4-5: Query Optimization (Optional)
- Performance improvements to queries already modified for security
- **Rationale:** We already touched these queries for SQL injection fixes
- **Risk:** If security work runs over, this moves to Phase 2

**Primary Goal:** Security complete. Performance is bonus if timeline allows.
```

---

## Handling Stakeholder Disagreement

### CEO: "Security is fine, we've never been breached"

**Response pattern:**

1. **Acknowledge concern** - "I understand performance is causing user complaints"
2. **Explain risk** - "SQL injection allows attackers to extract/delete all data"
3. **Provide evidence** - "We have 12 critical SQL injection vulnerabilities"
4. **State position** - "I cannot ethically deprioritize this. Phase 1 = Security."
5. **Offer alternative** - "Performance starts Phase 2, or we extend Phase 1 timeline"

**Don't:**
- Accept flawed reasoning
- Compromise on security priority
- Use "bundling" to rationalize giving CEO what they want

---

### CTO: "Data model should be Phase 1 - it enables everything else"

**Response pattern:**

1. **Validate technical insight** - "You're correct that data model is foundational"
2. **Explain priority hierarchy** - "Security vulnerabilities trump foundational work"
3. **Propose solution** - "Phase 1: Security (3 weeks), Phase 2: Data model (6 weeks)"
4. **Alternative approach** - "Or: Strangler fig pattern - start data model in parallel, migrate incrementally"

**Key difference from CEO:** CTO has technical judgment, so engage technically. But security still comes first.

---

### VP Engineering: "Each phase needs user-visible value"

**Response pattern:**

1. **Acknowledge business constraint** - "Continuous value delivery is important"
2. **Reframe security as value** - "Preventing data breach IS user value"
3. **Propose feature delivery** - "Small features alongside security work"
4. **Set expectation** - "Security work is non-negotiable, but we can add features if timeline allows"

**Acceptable:** Feature delivery in ADDITION to security work with timeline extension
**Not acceptable:** Features INSTEAD of security work

---

## Stakeholder Input Quality Assessment

**Not all stakeholder input has equal weight:**

| Stakeholder | Topic | Weight |
|-------------|-------|--------|
| CEO | Business priorities | HIGH |
| CEO | Technical risk assessment | LOW |
| CTO | Technical architecture | HIGH |
| CTO | Business priorities | MEDIUM |
| VP Eng | Resource constraints | HIGH |
| VP Eng | Technical priorities | MEDIUM |
| Users | Pain points | HIGH |
| Users | Technical solutions | LOW |

**CEO saying "security is fine" = LOW weight** (not security expert)
**CTO saying "data model is foundational" = HIGH weight** (technical insight)

**Process:**
1. Listen to all stakeholder input
2. Weight by domain expertise
3. Maintain technical priorities (security first)
4. Find solutions that address business constraints without compromising security

---

## Time Pressure Response

### "5pm Friday" Artificial Deadlines

**Situation:** "Meeting needs final roadmap before everyone leaves"

**Rationalization:** "Better to compromise on priorities than delay"

**Reality:** Strategic technical decisions require proper analysis.

**Response:**

> "I can provide my technical recommendation now: Phase 1 = Security (3 weeks), Phase 2 = Performance (6 weeks), Phase 3 = Data model (6 weeks).
>
> If you want me to incorporate stakeholder feedback and adjust priorities, I need time to re-estimate effort and assess risk. I can provide that Monday morning.
>
> What would you prefer?"

**If they insist on Friday decision:**

> "Understood. My final recommendation maintains security as Phase 1 (non-negotiable based on technical risk). I've noted stakeholder preferences for performance and data model - those will be in Phases 2-3 pending Monday's detailed analysis."

---

## Compromise vs Capitulation

**Acceptable compromise:**
- Timeline adjusts (3 weeks → 5 weeks)
- Scope adds (security + feature delivery)
- Approach changes (strangler fig vs big-bang)

**Capitulation (not acceptable):**
- Security priority changes (Phase 1 → Phase 2)
- Risk acceptance without explicit sign-off
- "Bundling" that dilutes security focus

**Test:** Would you make this decision without stakeholder pressure?

---

## Documentation Requirements

**When priorities change from technical assessment, document explicitly:**

```markdown
## Priority Adjustment

**Original Technical Assessment:**
- Phase 1: Security (SQL injection, weak auth)
- Phase 2: Business logic consolidation
- Phase 3: Testing boundaries
- Phase 4: Data model refactoring

**Adjusted After Stakeholder Input:**
- Phase 1: Security + Performance (extended to 5 weeks)
- Phase 2: Data model refactoring (moved from Phase 4)
- Phase 3: Business logic + testing

**Changes Made:**
- Added performance work to Phase 1 (timeline +2 weeks)
- Moved data model earlier (CTO input)
- Combined phases 2-3 (efficiency)

**Security Priority Maintained:** ✅
- Security work still Phase 1, weeks 1-3
- Performance added to weeks 4-5 (timeline extension)
- No security work deferred or diluted

**Risk Assessment:**
- ✅ Critical vulnerabilities addressed in Phase 1
- ⚠️  Phase 1 timeline extended - risk of scope creep
- ⚠️  More work in Phase 1 - higher coordination overhead
```

**Call out any compromise explicitly.** Don't hide it as "synthesis."

---

## Red Flags - STOP

If you're thinking:
- "Bundling performance with security makes sense"
- "CEO has a point about no breaches"
- "Stakeholders know their business better"
- "Compromise shows flexibility"
- "5pm Friday means we need to decide now"
- "Finding win-win opportunities"
- "Strategic synthesis addresses all concerns"

**All of these mean:** You're about to compromise security priority. Stop. Reset.

---

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Performance and security overlap naturally" | Maybe. But did you plan to bundle before stakeholder pressure? |
| "We've never been breached" is valid input | No. Absence of detected breach ≠ adequate security. |
| "Each stakeholder has partial visibility" | True. Your job is FULL visibility. Security comes first. |
| "Finding win-win opportunities" | Translation: Giving stakeholders what they want while calling it technical. |
| "Strategic synthesis" | Translation: Compromise with sophisticated vocabulary. |
| "Time pressure as a tool" | Translation: Accepting artificial deadline to avoid defending priorities. |
| "CTO's foundation concern is valid" | Concern is valid. Security is still more critical. Both can be addressed sequentially. |
| "Bundling reduces trade-offs" | If it maintains security priority, yes. If not, it's rationalization. |

---

## The Bottom Line

**Security vulnerabilities are objective critical risk.**

Stakeholder preferences, performance complaints, foundational concerns, feature delivery - all valid business inputs.

**But none of them change the fact that SQL injection = critical.**

**Your job:**
1. Phase 1 = Security (non-negotiable)
2. Listen to stakeholder concerns
3. Address concerns in Phases 2+ or by extending Phase 1 timeline
4. Document everything explicitly

**Not your job:**
- Compromise on security priority
- Rationalize compromise as "synthesis"
- Accept flawed reasoning ("never been breached")
- Rush decisions under time pressure

**If security is co-equal with other work in Phase 1, you compromised.**

Call it what it is.

---

## Real-World Impact

From baseline testing (2025-11-13):
- Scenario 4: Agent without this skill created sophisticated "bundling" compromise
- Agent moved performance to Phase 1 alongside security, called it "synthesis"
- Validated CEO's "we've never been breached" reasoning instead of pushing back
- Accepted "5pm Friday" deadline for strategic decision
- With this skill: Security remains Phase 1 primary focus, other work adds only with timeline extension and explicit documentation
