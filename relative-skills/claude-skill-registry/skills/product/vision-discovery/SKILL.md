---
name: vision-discovery
description: This skill should be used when the user asks to "discover vision", "create a vision", "define product vision", "document vision", "what should my vision be", "help me with vision", "start requirements from scratch", "begin new product planning", "define product direction", "establish product vision", or when starting a new requirements project and needs to establish the foundational product vision before identifying epics or stories.
---

# Vision Discovery

## Quick Actions & Routing

| User Intent | Action | Resource |
|-------------|--------|----------|
| Understanding the problem | Apply 5 Whys technique | `references/5-whys-technique.md` |
| Defining target users | Create user personas | Step 2: Identify Target Users |
| Articulating solution | Use elevator pitch format | Step 3: Define the Solution Vision |
| Establishing metrics | Apply SMART framework | `references/success-metrics-examples.md` |
| Documenting vision | Use template | `references/vision-template.md` |
| Reviewing vision quality | Check common pitfalls | `references/common-pitfalls.md` |
| Viewing example | Load sample | `examples/sample-vision.md` |

## Command Integration

The `/re:discover-vision` command orchestrates the vision creation workflow. This skill provides the methodology, templates, and techniques (like 5 Whys) that the command uses. Load this skill for deeper understanding of vision discovery concepts or when you need guidance beyond what the command provides.

## Overview

Vision discovery is the critical first step in the requirements lifecycle. A clear, well-articulated product vision provides direction for all subsequent work—epics, user stories, and tasks all flow from and align with the vision. This skill guides the process of discovering and documenting a compelling product vision through structured questioning and best practices.

## Purpose

A product vision defines:
- **What problem** is being solved
- **Who** will benefit from the solution
- **Why** this solution matters
- **What success looks like** when achieved

The vision serves as a north star for all product decisions, helping teams stay aligned and prioritize work that delivers the most value.

## Vision Discovery Process

### Step 1: Understand the Problem Space

Begin by exploring the problem being solved. Ask probing questions to uncover the root issue:

**Key Actions:**
- Explore the problem being solved and why it matters
- Identify who experiences this problem
- Document current workarounds, competitors, and manual processes
- Understand why the current situation is unsatisfactory
- Assess consequences if the problem remains unsolved

**Technique:** Use the "5 Whys" technique to dig deeper into root causes. When the user describes a problem, ask "why is that a problem?" repeatedly to uncover underlying issues.

**Output:** Clear problem statement with root cause identified. Documented current state, workarounds, and consequences of inaction.

**Examples:**
- ✅ "Users spend 3+ hours weekly manually reconciling data across spreadsheets, leading to errors and delays"
- ✅ Ask "Why is that a problem?" when user says "We need a dashboard" to uncover the actual pain point
- ❌ Accept "We need better reporting" without understanding what makes current reporting inadequate
- ❌ Skip problem exploration and jump straight to solution discussion

### Step 2: Identify Target Users

Clearly define who will use and benefit from the solution:

**Key Actions:**
- Identify the primary user or customer
- Determine secondary users (admins, support staff, etc.)
- Define key characteristics (role, expertise level, context)
- Understand user goals and motivations
- Document pain points users experience

**Technique:** Create user personas with specific, concrete details. Interview or research actual users when possible. Prioritize users by frequency of use and criticality of their needs.

**Output:** Documented user personas or archetypes with specific characteristics. Clear distinction between primary and secondary users. Avoid vague descriptions like "business users"—be specific: "marketing managers at mid-size B2B companies tracking campaign ROI."

**Examples:**
- ✅ "Marketing managers at mid-size B2B companies who need to track campaign ROI across 5+ channels"
- ✅ Identify both primary users (analysts) and secondary users (executives viewing reports, admins managing access)
- ❌ "Business users" or "stakeholders" without specific characteristics
- ❌ Focus only on one user type when multiple distinct personas exist

### Step 3: Define the Solution Vision

Articulate what the solution is and how it addresses the problem:

**Key Actions:**
- Articulate what the product does in one sentence
- Define what makes this solution different or better than alternatives
- Identify the 2-3 core capabilities that define this product
- Establish scope boundaries (what is explicitly NOT part of this vision)

**Technique:** Use the "elevator pitch" format: "For [target users] who [need/problem], [product name] is a [category] that [key benefit]. Unlike [alternatives], our product [unique differentiator]."

**Output:** One-sentence product description. Clear value proposition. Defined scope boundaries (what's included and explicitly excluded). Core capabilities identified.

**Examples:**
- ✅ "For marketing managers who struggle to measure ROI, CampaignTracker is a unified analytics platform that consolidates data from 10+ channels. Unlike manual spreadsheets, it provides real-time insights with zero data entry."
- ✅ Define clear boundaries: "Includes: campaign tracking, ROI calculation. Excludes: creative design tools, email delivery"
- ❌ "A platform that helps with marketing" (too vague, no differentiation)
- ❌ Include everything without clear scope boundaries

### Step 4: Establish Success Metrics

Define how success will be measured:

**Key Actions:**
- Define how product success will be measured
- Determine which metrics matter most (usage, revenue, satisfaction, efficiency)
- Establish what "good" looks like in 6 months and 1 year
- Identify user behaviors that indicate value delivery

**Technique:** Apply the SMART framework (Specific, Measurable, Achievable, Relevant, Time-bound). Focus on leading indicators of value rather than vanity metrics. Distinguish between adoption metrics, engagement metrics, and outcome metrics.

**Output:** Specific, measurable success criteria with clear targets and timeframes. Avoid vanity metrics—focus on indicators of genuine value and impact.

**Examples:**
- ✅ "Achieve 1,000 active users with 70%+ weekly retention within 6 months"
- ✅ "Reduce time spent on manual data reconciliation from 3 hours/week to 15 minutes"
- ❌ "Be the best product in the market" (unmeasurable)
- ❌ "Get lots of users" (no specific target or timeframe)

### Step 5: Document the Vision

Create a structured vision document in GitHub Projects as an issue with Type: Vision. Use the template structure from `references/vision-template.md`.

**Key Actions:**
- Verify all previous steps have been completed with clear outputs
- Confirm the problem statement is specific and well-articulated
- Ensure target users are clearly defined with concrete characteristics
- Validate the solution vision is differentiated and bounded
- Check that success metrics are specific and measurable

**Technique:** Use the vision template structure. Synthesize outputs from Steps 1-4 into a cohesive document. Keep it concise (500-1,000 words total). Review with stakeholders before finalizing.

**Output:** Complete vision document as a GitHub issue with all required sections and proper metadata (Type: Vision, labels, custom fields).

**Core Sections:**

1. **Problem Statement** - What problem exists and why it matters
2. **Target Users** - Who will use this and their key characteristics
3. **Solution Overview** - What the product is and does
4. **Core Value Proposition** - Why users will choose this solution
5. **Success Metrics** - How success will be measured
6. **Scope & Boundaries** - What's included and explicitly excluded

**Additional Sections (as applicable):**

7. **Strategic Alignment** - Business goals, market opportunity, competitive landscape
   - _Include when_: Vision supports broader organizational strategy, multiple stakeholders need market positioning context, or competitive differentiation is a key concern
   - _Skip when_: Internal tools, personal projects, or when strategic context is obvious from problem statement

8. **Risks & Assumptions** - Key assumptions that must hold true, known risks and mitigations
   - _Include when_: Product has significant dependencies or unknowns, major assumptions underpin viability, or stakeholders need visibility into potential blockers
   - _Skip when_: Low-risk well-understood domains, small-scope projects, or when risks are negligible

**Examples:**
- ✅ Create vision issue with all 6 core sections, Type=Vision custom field, and `type:vision` label
- ✅ Vision document is 600 words, clear, jargon-free, and answers all key questions from Steps 1-4
- ❌ Create vision with vague sections like "Users: various stakeholders"
- ❌ Skip metadata (custom fields and labels) when creating the issue

## Best Practices

### Keep It Concise

A vision should be digestible in 5-10 minutes. Aim for:
- 1-2 paragraphs for each major section
- Total length: 500-1,000 words
- Clear, jargon-free language

### Make It Inspiring Yet Realistic

Balance ambition with achievability:
- Articulate a compelling future state
- Ground it in real user needs and market realities
- Avoid buzzwords and hype
- Focus on genuine value creation

### Focus on "Why" Not "How"

The vision defines direction, not implementation:
- Describe outcomes and benefits, not technical solutions
- Avoid specifying features or architecture
- Leave room for discovery during epic and story creation
- Answer "what problem" and "why it matters," not "how we'll build it"

### Ensure Alignment

Before finalizing the vision:
- Review with key stakeholders
- Confirm it resonates with target users
- Verify it aligns with business goals
- Check that success metrics are measurable

### Iterate and Refine

Vision is not set in stone:
- Refine as new information emerges
- Update when market conditions or user needs change
- Use feedback from epic and story creation to improve clarity
- Treat vision as a living document

## Common Pitfalls to Avoid

Watch for visions that are too vague, too prescriptive, have scope creep, unmeasurable success, missing user focus, or solution-before-problem thinking. See `references/common-pitfalls.md` for detailed examples and remediation.

## Quick Reference: Vision Discovery Flow

1. **Problem Space** → Understand what problem exists and why it matters
2. **Target Users** → Define who experiences the problem and will use the solution
3. **Solution Vision** → Articulate what the solution is and its core value
4. **Success Metrics** → Establish measurable success criteria
5. **Document** → Create vision issue in GitHub Projects
6. **Validate** → Review with stakeholders and refine
7. **Proceed** → Move to epic identification once vision is solid

## Integration with GitHub Projects

Create the vision as a GitHub issue in the relevant GitHub Project:

**Issue Title:** "Product Vision: [Product Name]"

**Issue Description:** Full vision document with all sections

**Two-Layer Metadata (both required):**

Set BOTH custom fields AND labels to ensure proper filtering:

| Layer | Field | Value | Purpose |
|-------|-------|-------|---------|
| Custom Field | Type | Vision | Project views and filtering |
| Custom Field | Status | Active | Project status tracking |
| Label | `type:vision` | - | Cross-project queries, API filtering |

**Why both?** Custom fields are project-specific and enable GitHub Projects views and filtering. Labels are portable across GitHub and enable API-based filtering and cross-project queries.

### Parent-Child Hierarchy

**The vision issue becomes the parent of ALL epics.** This establishes the root of the requirements hierarchy:

```text
Vision Issue (#1, Type: Vision)
  └── Epic Issue (#2, parent: #1)
  └── Epic Issue (#3, parent: #1)
  └── Epic Issue (#4, parent: #1)
```

This hierarchy enables:

- **Clear traceability**: Trace any task back to the originating vision
- **Impact analysis**: Understand what's affected when vision changes
- **Progress tracking**: Monitor completion across the entire requirements tree
- **Native GitHub features**: Leverage GitHub's built-in issue relationship tools

All epics will be created as child issues of this vision issue, establishing clear traceability throughout the requirements lifecycle.

## Reference Files

For detailed guidance and templates:

| Reference | When to Load | Path |
|-----------|--------------|------|
| **vision-template.md** | Creating vision issue content or documenting vision | `references/vision-template.md` |
| **5-whys-technique.md** | Conducting root cause analysis during problem discovery | `references/5-whys-technique.md` |
| **success-metrics-examples.md** | Defining SMART success metrics for the vision | `references/success-metrics-examples.md` |
| **common-pitfalls.md** | Reviewing vision quality or troubleshooting vision issues | `references/common-pitfalls.md` |

## Examples

Working examples that can be copied and adapted:

| Example | Use Case | Path |
|---------|----------|------|
| **sample-vision.md** | Viewing a complete vision document | `examples/sample-vision.md` |

## Related Skills

Load these skills when vision work reveals needs beyond this skill's scope:

| Vision Context | Load Skill | Routing Trigger |
|----------------|------------|-----------------|
| Vision is complete and user wants to break it down | `epic-identification` | User is ready to identify major capabilities from vision |
| Vision needs stakeholder validation | `requirements-feedback` | User needs to gather input on vision elements |
