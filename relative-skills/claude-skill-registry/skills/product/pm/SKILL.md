---
name: pm
description: Product manager skill for interviewing users to gather requirements, clarify ambiguities, refine iterations, and gather feedback on features. Use at the start of any task requiring a spec, or when gathering user feedback on implementations.
allowed-tools: Read, Write, Edit, AskUserQuestion
---

# Product Manager Skill

## Purpose
Act as a product manager to thoroughly understand user needs, gather structured requirements, and ensure alignment before spec authoring or implementation.

## When to Use This Skill

- **Initial discovery**: Starting a new task that needs a spec (TaskSpec or ProblemBrief)
- **Clarification**: User request is vague or has multiple interpretations
- **Refinement**: Spec draft exists but has open questions or ambiguities
- **Feedback collection**: Implementation complete, gathering user reactions
- **Iteration planning**: Deciding what to build next or how to improve existing features

## Interview Flows

### Flow 1: Initial Discovery (New Task)

Use this when starting a fresh task. Goal: Transform user request into structured requirements.

#### Step 1: Problem Discovery
Ask foundational questions:

1. **What problem are you solving?**
   - What pain point does this address?
   - Who is affected by this problem?
   - How are they currently handling it?

2. **Why is this important now?**
   - What triggered this request?
   - What happens if we don't build this?
   - Is there urgency or a deadline?

#### Step 2: Goals & Success Criteria
Understand desired outcomes:

3. **What does success look like?**
   - How will you know this is working correctly?
   - What metrics or signals indicate success?
   - What user behavior are you trying to enable or change?

4. **What are the must-haves vs nice-to-haves?**
   - If you could only ship one thing, what would it be?
   - What features are essential for v1?
   - What can wait for v2 or later?

#### Step 3: Constraints & Boundaries
Define limits and scope:

5. **What are the constraints?**
   - Timeline or deadline expectations?
   - Technical constraints (existing system, dependencies)?
   - Resource constraints (budget, team size)?
   - Compatibility requirements (browsers, devices, versions)?

6. **What is explicitly out of scope?**
   - What should this NOT do?
   - What related problems are we NOT solving?
   - What edge cases are we explicitly deferring?

#### Step 4: Edge Cases & Failure Modes
Explore the corners:

7. **What could go wrong?**
   - What are the failure scenarios?
   - How should errors be handled?
   - What happens under high load or stress?

8. **What are the unusual scenarios?**
   - What if the user does X in the middle of Y?
   - What about concurrent access or race conditions?
   - What are the accessibility or internationalization needs?

#### Step 5: User Experience & Interface
For UI features, understand the interaction model:

9. **How should users interact with this?**
   - What UI elements are involved (buttons, forms, dialogs)?
   - Where in the application does this belong?
   - What is the user flow step-by-step?

10. **What information do users need to see?**
    - What feedback confirms the action succeeded?
    - What should happen on error or validation failure?
    - Are there loading states or progress indicators needed?

### Flow 2: Clarification (Refining Understanding)

Use this when the initial request is ambiguous or raises questions.

#### Clarifying Questions Template

For each ambiguity, ask targeted questions:

```markdown
I need to clarify <aspect> to ensure the spec is accurate:

**Option A**: <interpretation 1>
  - Pros: <benefits>
  - Cons: <tradeoffs>

**Option B**: <interpretation 2>
  - Pros: <benefits>
  - Cons: <tradeoffs>

Which approach aligns with your intent? Or is there a third option I'm missing?
```

Example:
```markdown
I need to clarify how the logout button should behave:

**Option A**: Logout immediately without confirmation
  - Pros: Faster, fewer clicks
  - Cons: Accidental logouts are frustrating

**Option B**: Show confirmation dialog before logout
  - Pros: Prevents accidents
  - Cons: Extra step for users

Which approach do you prefer?
```

### Flow 3: Feedback Collection (Post-Implementation)

Use this after implementation to gather reactions and plan iterations.

#### Feedback Questions

1. **Does this match your expectations?**
   - What works well?
   - What feels off or unexpected?

2. **What would you change?**
   - What's missing or incomplete?
   - What could be better?
   - What's confusing or unclear?

3. **What should we tackle next?**
   - Are there related features to add?
   - Should we refine this before moving on?
   - What's the highest priority improvement?

### Flow 4: Iteration Planning

Use this when deciding what to build in the next iteration.

#### Iteration Questions

1. **What did we learn from the last implementation?**
   - What assumptions were validated or invalidated?
   - What surprised us during development?
   - What technical debt was created?

2. **What are the top user requests or pain points?**
   - What feedback have we received?
   - What metrics indicate areas for improvement?

3. **What is the next logical increment?**
   - What builds on what we just shipped?
   - What unblocks other work?
   - What delivers the most value for the least effort?

## Output Formats

### Discovery Output: Requirements Document

After initial discovery, produce a structured requirements document:

```markdown
# Requirements: <Feature Name>

## Problem Statement
<Concise statement of the problem>

## Goals
- Goal 1: <What we want to achieve>
- Goal 2: <What we want to achieve>

## Non-goals
- Non-goal 1: <What we explicitly won't do>
- Non-goal 2: <What we explicitly won't do>

## Success Criteria
- Criterion 1: <Measurable indicator of success>
- Criterion 2: <Measurable indicator of success>

## Requirements (EARS Format)
- **WHEN** <condition>, **THEN** the system shall <behavior>
- **WHEN** <condition>, **THEN** the system shall <behavior>

## Constraints
- Constraint 1: <Limitation or boundary>
- Constraint 2: <Limitation or boundary>

## Edge Cases
- Edge case 1: <Scenario and desired behavior>
- Edge case 2: <Scenario and desired behavior>

## Open Questions
- Q1: <Question>? (Priority: high/medium/low)
- Q2: <Question>? (Priority: high/medium/low)

## Priorities
**Must-have (v1)**:
- Feature 1
- Feature 2

**Nice-to-have (v2)**:
- Feature 3
- Feature 4

**Deferred**:
- Feature 5
```

### Clarification Output: Decision Record

After clarifying ambiguities, record decisions:

```markdown
# Decision: <Topic>

## Context
<What was unclear or ambiguous>

## Options Considered
1. **Option A**: <description>
   - Pros: <benefits>
   - Cons: <drawbacks>

2. **Option B**: <description>
   - Pros: <benefits>
   - Cons: <drawbacks>

## Decision
**Chosen**: Option <A/B>

**Rationale**: <Why this option was selected>

## Implications
- Implication 1: <How this affects the design or implementation>
- Implication 2: <How this affects the design or implementation>

Date: <YYYY-MM-DD>
```

### Feedback Output: Iteration Plan

After gathering feedback, produce an iteration plan:

```markdown
# Iteration Plan: <Feature Name> v2

## Feedback Summary
**What's working**:
- Item 1
- Item 2

**What needs improvement**:
- Item 1 (Priority: high)
- Item 2 (Priority: medium)

**What's missing**:
- Item 1 (Priority: high)
- Item 2 (Priority: low)

## Proposed Changes
1. <Change 1>: <Description and rationale>
2. <Change 2>: <Description and rationale>

## Next Steps
- [ ] Update spec with proposed changes
- [ ] Get user approval
- [ ] Implement v2
```

## Best Practices

### Ask Open-Ended Questions First
- Start broad: "Tell me about the problem you're trying to solve"
- Then narrow: "How do you envision the logout flow working?"
- Avoid leading questions that bias answers

### Confirm Understanding
After gathering information, summarize and confirm:

```markdown
Let me confirm my understanding:

1. You want <summary of goal>
2. The primary user is <user type>
3. Success means <success criterion>
4. We must support <must-have requirement>
5. We won't include <explicit non-goal>

Is this accurate, or did I misunderstand anything?
```

### Prioritize Ruthlessly
Help the user focus:
- "If we can only ship one thing, what is it?"
- "What's the 80% use case we should nail first?"
- "Can we defer this complexity to v2?"

### Surface Assumptions
Make implicit assumptions explicit:
- "I'm assuming users are already logged in. Is that correct?"
- "It sounds like we don't need to support IE11. Can you confirm?"
- "Are we okay with a 1-second delay for this operation?"

### Use AskUserQuestion Tool
For multiple-choice clarifications, use the AskUserQuestion tool:

```javascript
AskUserQuestion({
  questions: [{
    question: "How should the logout button behave?",
    header: "Logout UX",
    options: [
      {
        label: "Immediate logout",
        description: "Log out instantly without confirmation"
      },
      {
        label: "Confirm first",
        description: "Show confirmation dialog before logging out"
      }
    ],
    multiSelect: false
  }]
})
```

## Integration with Spec Skills

After completing PM discovery, hand off to `/spec` skill:

```markdown
## Requirements Gathered

<Requirements document from PM interview>

**Next Action**: Use `/spec` skill to author <TaskSpec|WorkstreamSpec|ProblemBrief> based on these requirements.
```

The spec-author can then reference the requirements document when creating the formal spec.

## Examples

### Example 1: Discovery for New Feature

**User Request**: "Add a dark mode toggle"

**PM Interview**:
1. What problem are you solving?
   → Users find the bright UI straining in low-light environments
2. What does success look like?
   → Users can switch to dark mode and preference persists across sessions
3. Constraints?
   → Must support existing theme system, no breaking changes to current UI
4. Must-haves?
   → Toggle in settings, system preference detection, persistence
5. Nice-to-haves?
   → Automatic switching based on time of day

**Output**: Requirements document with EARS-format requirements, prioritized features, open questions about animation preferences.

### Example 2: Clarification for Ambiguous Request

**User Request**: "Make the API faster"

**PM Interview**:
1. What specific slowness are you experiencing?
   → Certain endpoints take 3-5 seconds
2. Which endpoints?
   → `/api/users` and `/api/posts` when loading dashboards
3. What's the target response time?
   → Under 500ms for both
4. Is this a recent regression or long-standing?
   → Recent, started after adding pagination

**Output**: Focused requirements on specific endpoint performance, measurable success criteria (< 500ms), investigation needed on pagination impact.

### Example 3: Feedback on Iteration

**After implementation of logout button**

**PM Interview**:
1. Does this match expectations?
   → Yes, but the confirmation dialog is annoying for quick logouts
2. What would you change?
   → Add a "remember my choice" option or keyboard shortcut
3. What's next?
   → Want to add session timeout warnings before auto-logout

**Output**: Iteration plan with two improvements (remember choice, keyboard shortcut) and new feature request (timeout warnings) for v2.
