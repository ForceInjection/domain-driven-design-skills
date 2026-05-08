---
name: rca-analyst
description: Structured root cause analysis methodology with three-test isolation and prevention analysis
---

# Root Cause Analysis Skill

> Evidence-based methodology for isolating true root causes from contributing factors.

---

## Core Philosophy

**Root cause analysis is evidence gathering, not solution design.**

The RCA process produces:
- Clear problem definition with failure boundaries
- Complete evidence timeline
- Causal chain with differentiated root cause vs contributing factors
- Prevention analysis (WHAT needs to change, not HOW)

The RCA process does NOT produce:
- Proposed solutions
- Implementation roadmaps
- Prioritization decisions
- Resource allocation

---

## The Three Tests for Root Cause Isolation

Most teams conflate **root cause** with **contributing factors**. Use these three tests to isolate the true root cause:

### Test 1: Counterfactual Test
> "If this factor didn't exist, would the failure still have occurred?"

- **Root Cause**: NO - removing it prevents the failure
- **Contributing Factor**: YES - failure would still occur via another path

### Test 2: Sufficiency Test
> "Is this factor alone sufficient to cause the failure?"

- **Root Cause**: YES - this factor alone can cause the failure
- **Contributing Factor**: NO - requires other factors to cause failure

### Test 3: Necessity Test
> "Is this factor necessary for the failure to occur?"

- **Root Cause**: YES - failure cannot occur without it
- **Contributing Factor**: NO - failure could occur without it

### Applying the Tests

| Factor | Counterfactual | Sufficiency | Necessity | Classification |
|--------|----------------|-------------|-----------|----------------|
| True Root Cause | NO (prevents failure) | YES | YES | **ROOT CAUSE** |
| Contributing Factor | YES (still fails) | NO | NO | Contributing |
| Necessary Condition | NO | NO | YES | Enabler |
| Amplifying Factor | YES | NO | NO | Amplifier |

**The root cause is the factor that passes ALL THREE tests.**

---

## Five-Phase Workflow

### Phase 1: Problem Definition

**Goal**: Establish clear boundaries around what failed and what didn't.

**Required Outputs**:
1. **Failure Statement**: One sentence describing what failed
2. **Scope Boundaries**: What's in scope, what's explicitly out
3. **Success Criteria**: What would "working correctly" look like?
4. **Timeline Bounds**: When did the failure window start/end?

**Checkpoint Questions**:
- [ ] Can you state the failure in one sentence?
- [ ] Are scope boundaries explicit?
- [ ] Is the success criteria measurable?

### Phase 2: Evidence Gathering

**Goal**: Collect all relevant data without interpretation.

**Evidence Types**:
- **System Evidence**: Logs, metrics, traces, error messages
- **Human Evidence**: Who did what, when, communications
- **Environmental Evidence**: Config states, deployment status, external factors
- **Temporal Evidence**: Timeline of events

**Rules**:
- Record timestamps for everything
- Capture exact error messages/codes
- Note absence of expected events
- Don't interpret yet - just collect

**Checkpoint Questions**:
- [ ] Do you have a complete timeline?
- [ ] Are all system states captured?
- [ ] Are human actions documented?
- [ ] Are environmental factors recorded?

### Phase 3: Causal Chain Construction

**Goal**: Build the chain of events that led to failure.

**Process**:
1. Start from the failure event
2. Ask "What directly caused this?" for each event
3. Continue until you reach actionable factors
4. Map dependencies between events

**Output Format**:
```
[Triggering Event]
    ↓
[Intermediate Event 1]
    ↓
[Intermediate Event 2]
    ↓
[Failure Event]
```

**Checkpoint Questions**:
- [ ] Does each link have evidence?
- [ ] Are there gaps in the chain?
- [ ] Have you identified branch points?

### Phase 4: Root Cause Isolation

**Goal**: Apply the three tests to identify the true root cause.

**Process**:
1. List all candidate factors from the causal chain
2. Apply Counterfactual Test to each
3. Apply Sufficiency Test to survivors
4. Apply Necessity Test to survivors
5. Factor passing all three = Root Cause

**Classification Output**:

| Factor | Counterfactual | Sufficiency | Necessity | Classification |
|--------|----------------|-------------|-----------|----------------|
| [Factor A] | [Result] | [Result] | [Result] | [Type] |
| [Factor B] | [Result] | [Result] | [Result] | [Type] |

**Checkpoint Questions**:
- [ ] Did you test every candidate?
- [ ] Does your root cause pass all three tests?
- [ ] Can you explain why contributing factors failed each test?

### Phase 5: Prevention Analysis

**Goal**: Identify WHAT needs to change to prevent recurrence (not HOW to change it).

**Categories**:

1. **Detection Gaps**: What monitoring/alerting would have caught this earlier?
2. **Process Gaps**: What process changes would prevent the root cause?
3. **System Gaps**: What system changes would eliminate the failure mode?
4. **Knowledge Gaps**: What documentation/training gaps contributed?

**Rules**:
- State the gap, not the solution
- Focus on prevention, not recovery
- Identify gaps at multiple levels

**Checkpoint Questions**:
- [ ] Have you identified gaps in each category?
- [ ] Are gaps stated without prescribing solutions?
- [ ] Do gaps map back to root cause and contributing factors?

---

## Differential Analysis

**Critical Question**: Why did THIS case fail when similar cases succeed?

This section is REQUIRED for every RCA. It forces examination of:
- What was different about this specific failure?
- What conditions existed that don't exist in successful cases?
- Why didn't existing safeguards prevent this?

**Template**:
```
## Differential Analysis

### Similar Cases That Succeeded
[List similar situations that didn't fail]

### Key Differences in Failure Case
[What was different about this case?]

### Safeguard Failures
[Why didn't existing protections work?]

### Unique Conditions
[What conditions were present only in this failure?]
```

---

## RCA Output Template

```markdown
# Root Cause Analysis: [Incident Name]

**Date**: [Analysis Date]
**Incident Date**: [When failure occurred]
**Analyst**: [Who conducted RCA]
**Status**: [Draft | Review | Final]

---

## 1. Problem Definition

### Failure Statement
[One sentence describing what failed]

### Scope
- **In Scope**: [What this RCA covers]
- **Out of Scope**: [What this RCA excludes]

### Success Criteria
[What "working correctly" looks like]

### Timeline Bounds
- **Start**: [When failure window began]
- **End**: [When failure was resolved]

---

## 2. Evidence Timeline

| Timestamp | Event | Source | Evidence |
|-----------|-------|--------|----------|
| [Time] | [What happened] | [Log/Person/System] | [Exact data] |

---

## 3. Causal Chain

[Visual chain from trigger to failure]

```
[Event 1] → [Event 2] → [Event 3] → [FAILURE]
```

### Chain Narrative
[Prose explanation of how events connected]

---

## 4. Root Cause Isolation

### Candidate Factors

| Factor | Counterfactual | Sufficiency | Necessity | Classification |
|--------|----------------|-------------|-----------|----------------|
| [Factor] | [YES/NO] | [YES/NO] | [YES/NO] | [Type] |

### Root Cause Statement
[The factor that passed all three tests]

### Contributing Factors
[Factors that amplified or enabled but aren't root cause]

---

## 5. Differential Analysis

### Similar Cases That Succeeded
[List similar situations that didn't fail]

### Key Differences
[What was unique about this failure case?]

### Safeguard Failures
[Why didn't existing protections work?]

---

## 6. Prevention Analysis

### Detection Gaps
- [What monitoring would catch this earlier?]

### Process Gaps
- [What process changes would prevent root cause?]

### System Gaps
- [What system changes would eliminate failure mode?]

### Knowledge Gaps
- [What documentation/training gaps contributed?]

---

## Appendix: Raw Evidence

[Attach logs, screenshots, configs, communications]
```

---

## Interactive Workflow for Agents

When conducting RCA with a user, follow this interactive flow:

### Starting the RCA
```
I'll guide you through a structured Root Cause Analysis. We'll work through 5 phases:
1. Problem Definition
2. Evidence Gathering
3. Causal Chain Construction
4. Root Cause Isolation (using three tests)
5. Prevention Analysis

Let's start with Phase 1: Problem Definition.

Can you describe in one sentence what failed?
```

### Phase Transitions
At each phase checkpoint, verify completion before proceeding:
```
Before we move to [Next Phase], let me verify:
- [ ] [Checkpoint 1]
- [ ] [Checkpoint 2]
- [ ] [Checkpoint 3]

[If incomplete]: We're missing [X]. Can you provide [specific ask]?
[If complete]: Great, let's proceed to [Next Phase].
```

### Root Cause Isolation Dialogue
```
Now let's apply the three tests to isolate the root cause.

For [Factor]:
1. Counterfactual: If [Factor] didn't happen, would the failure still occur?
2. Sufficiency: Is [Factor] alone enough to cause this failure?
3. Necessity: Is [Factor] required for this failure to occur?

Based on your answers: [Classification]
```

### Completing the RCA
```
Based on our analysis:

**Root Cause**: [Statement]
**Contributing Factors**: [List]
**Prevention Gaps**: [Categories]

Would you like me to generate the full RCA document?
```

---

## Worked Example: API Rate Limiting Incident

### Context
Merchant integration failed during high-traffic sale event.

### Phase 1: Problem Definition
- **Failure**: Merchant orders dropped for 47 minutes during Black Friday
- **Scope**: Order processing via Channel API
- **Success**: All valid orders processed within SLA

### Phase 2: Evidence
| Time | Event | Source |
|------|-------|--------|
| 09:15 | Traffic spike began | Metrics |
| 09:23 | MAX_COST_EXCEEDED errors started | API logs |
| 09:24 | Retry storm began | Client logs |
| 10:10 | Manual intervention resolved | Incident channel |

### Phase 3: Causal Chain
```
[Traffic spike] → [Query complexity exceeded limit] → [MAX_COST_EXCEEDED] → [Client retries] → [Amplified load] → [Extended outage]
```

### Phase 4: Root Cause Isolation

| Factor | Counterfactual | Sufficiency | Necessity | Classification |
|--------|----------------|-------------|-----------|----------------|
| Traffic spike | YES (still fails if queries complex) | NO | NO | Amplifier |
| Complex queries | NO (prevents error) | YES | YES | **ROOT CAUSE** |
| Aggressive retries | YES (still errors) | NO | NO | Amplifier |
| No alerting | YES (still errors) | NO | NO | Enabler |

**Root Cause**: Query complexity exceeded platform limits under normal traffic patterns.

### Phase 5: Differential Analysis

**Why This Merchant?**
- Other merchants with same traffic didn't fail
- This merchant's query pattern was 3x more complex
- Query complexity wasn't validated during onboarding

### Prevention Gaps
- **Detection**: No query complexity monitoring pre-incident
- **Process**: No onboarding validation of query patterns
- **System**: No graceful degradation for complex queries
- **Knowledge**: Rate limit documentation didn't cover complexity costs
