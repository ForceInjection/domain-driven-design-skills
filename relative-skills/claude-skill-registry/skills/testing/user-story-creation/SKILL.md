---
name: user-story-creation
description: This skill should be used when the user asks to "create user stories", "write user stories", "break down epic into stories", "define user stories", "what stories do I need", "apply INVEST criteria", "write acceptance criteria", "split a large story", "story is too big", "story splitting", or when decomposing epics into specific, valuable user stories.
---

# User Story Creation

## Quick Actions & Routing

| User Intent | Action | Resource |
|-------------|--------|----------|
| Reviewing epic first | Understand scope and value | Step 1: Review the Epic |
| Drafting stories | Map user journeys | Steps 2-3: Identify Journeys and Draft Stories |
| Validating stories | Apply INVEST criteria | `references/invest-criteria.md` |
| Story is too large | Apply splitting techniques | `references/splitting-techniques.md` |
| Creating story issues | Use template | `references/story-template.md` |
| Viewing examples | Load sample story set | `examples/example-story-set.md` |

## Command Integration

The `/re:create-stories` command guides user story creation in GitHub Projects. This skill provides the methodology for writing effective stories—including INVEST criteria validation and splitting techniques for oversized stories. Load this skill for deeper understanding of story creation concepts or when you need guidance beyond what the command provides.

## Overview

User story creation transforms epics into specific, actionable requirements that describe functionality from a user's perspective. Well-written user stories follow the INVEST criteria and provide clear value while remaining small enough to be completed in a single iteration. This skill guides the process of breaking down epics into high-quality user stories.

## Purpose

User stories serve as the detailed requirements layer:

- **Above**: Epics (major capabilities)
- **Stories**: Specific user-facing functionality
- **Below**: Tasks (implementation steps)

Ensure user stories:

- Describe functionality from user perspective
- Deliver independent, testable value
- Fit within a single iteration/sprint
- Enable detailed estimation and planning
- Facilitate conversation and refinement

## Prerequisite

Epic must exist before creating stories. If no epic exists, use the **epic-identification** skill first.

## User Story Format

### Standard Template

```text
As a [user type/persona],
I want [goal/desire],
So that [benefit/value].
```

**Include these components:**

- **User type**: Specify WHO wants this (specific role or persona)
- **Goal**: Define WHAT they want to do (capability or action)
- **Benefit**: State WHY it matters (value or outcome)

### Example Stories

**Good:**

```text
As a marketing manager,
I want to filter campaign data by date range,
So that I can analyze performance for specific time periods.
```

**Poor:**

```text
As a user,  (too vague—which user?)
I want to see data,  (too vague—what data? how?)
So that I can use the app.  (no specific benefit)
```

### When to Deviate from Template

Apply these guidelines:

- Use the template when it clarifies value and perspective
- Deviate when it adds unnecessary words
- Consider alternative: Simple title + detailed description

**Alternative format:**

- **Title**: "Filter campaigns by date range"
- **Description**: Detailed explanation of functionality and value

## INVEST Criteria (Quick Reference)

_Validate every user story against these criteria. For detailed guidance with examples, see `references/invest-criteria.md`._

| Letter | Criterion | Question |
|--------|-----------|----------|
| **I** | Independent | Can it be completed without other stories? |
| **N** | Negotiable | Is there room for discussion on implementation? |
| **V** | Valuable | Does it deliver clear user/business value? |
| **E** | Estimable | Can the team estimate the effort? |
| **S** | Small | Can it be completed in 1-5 days? |
| **T** | Testable | Are there specific acceptance criteria? |

## Story Creation Process

### Step 1: Review the Epic

**Key Actions:**

- Read epic issue in GitHub Projects
- Analyze scope, value, and success criteria
- Identify user types and journeys covered

### Step 2: Identify User Journeys

**Key Actions:**

- Map out user flows within the epic
- Apply task analysis, scenario mapping, and user type breakdown

**Techniques:**

- **Task Analysis**: Identify tasks users complete and their sequence
- **Scenario Mapping**: Document scenarios and paths users might take
- **User Type Breakdown**: Determine if different users need different stories

### Step 3: Draft Initial Stories

**Key Actions:**

- Create draft stories covering the epic
- Start with happy paths, then add edge cases

**Start with happy paths:**

- Cover core functionality for primary scenarios
- Address most common user needs
- Include essential capabilities

**Then add edge cases and variations:**

- Add error handling stories
- Cover alternative flows
- Include advanced features

**Verify coverage:**

- Confirm all epic scope is covered
- Check for gaps in user journeys
- Ensure all success criteria are addressable

### Step 4: Apply INVEST Criteria

**Key Actions:**

- Review each story against INVEST criteria
- Split or revise stories that fail criteria

**Validation checklist:**

- **Independence**: Verify story can be completed without others
- **Value**: Confirm it delivers something users care about
- **Size**: Check it's 1-5 days of work; split if larger
- **Testability**: Define acceptance criteria

### Step 5: Add Acceptance Criteria

**Key Actions:**

- Define clear acceptance criteria for each story
- Use Given-When-Then format or simple checklist

**Given-When-Then Format:**

```text
Given [context],
When [action],
Then [expected outcome].
```

**Or simple checklist:**

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Example:**

Story: "User can filter campaigns by date range"

Acceptance Criteria:

- [ ] Date picker UI for start date and end date
- [ ] Only campaigns with activity in date range are shown
- [ ] Selecting invalid range (end before start) shows error message
- [ ] Clearing filters shows all campaigns again

### Step 6: Prioritize Stories

**Key Actions:**

- Determine sequence and priority for stories
- Apply MoSCoW framework for prioritization

**Guidelines:**

- **Sequencing**: Identify which stories must come first (dependencies)
- **Prioritization**: Rank by value using MoSCoW framework

### Step 7: Create Story Issues in GitHub Projects

**Key Actions:**

- Create a GitHub issue for each story
- Set custom fields, labels, and parent link

**Issue Configuration:**

- **Title**: "[Story summary in user voice]"
- **Description**: Full story with acceptance criteria using template from `references/story-template.md`

**Custom Fields:**

- Type: Story
- Priority: [Must Have / Should Have / Could Have]
- Status: Not Started

**Labels:**

- `type:story`
- `priority:[moscow-level]`

**Parent:** Link to Epic issue as parent

## Story Splitting

Split stories that are too large (more than 1 week of work) using these techniques:

| Technique | When to Use | Example Split |
|-----------|-------------|---------------|
| **Workflow Steps** | Multi-step process | View → Edit → Delete subscription |
| **Operations (CRUD)** | Managing entities | Invite, view, remove, change role |
| **Business Rules** | Multiple conditions | % discount, $ discount, BOGO |
| **Happy Path vs. Variations** | Simple core + complex edges | Basic upload → Multiple files → Drag & drop |
| **Data Variations** | Multiple formats/sources | CSV import → Excel → Google Contacts |
| **Platforms** | Multiple interfaces | In-app → Email → SMS notifications |
| **User Roles** | Multiple user types | Owner, admin, member views |
| **Performance Tiers** | Performance-sensitive | Basic → Cached → Optimized |

For detailed guidance and examples for each technique, see `references/splitting-techniques.md`.

## Best Practices

### Write from User Perspective

Frame stories around what users see and experience:

- ❌ "Implement database indexes for performance"
- ✅ "Campaign list loads in under 2 seconds"

### Keep Stories Testable

Include acceptance criteria for every story:

- Add 3-5 acceptance criteria per story
- Define specific, observable outcomes
- Ensure testability without looking at code

### Avoid Technical Tasks as Stories

Convert technical work into tasks within user-facing stories:

- ❌ Story: "Set up CI/CD pipeline"
- ✅ Story: "User can see deployment status" (tasks include CI/CD setup)

### One Story, One Goal

Limit each story to a singular focus:

- ❌ "User can edit profile and change password and upload avatar"
- ✅ Split into three separate stories

### Include Non-Functional Requirements

Address quality attributes in stories:

- Include performance requirements
- Specify security constraints
- Define accessibility standards
- Document usability expectations

## Common Pitfalls to Avoid

| Pitfall | Problem | Action |
|---------|---------|--------|
| **Too Large** | Takes weeks, not days | Split using techniques above |
| **Too Small** | Trivial, just a task | Combine into meaningful story |
| **Missing Acceptance Criteria** | Cannot verify completion | Add 3-5 specific criteria |
| **Pure Technical Story** | No user value | Frame in terms of user impact |

## Quick Reference: Story Creation Flow

1. **Review Epic** → Understand scope, value, success criteria
2. **Identify Journeys** → Map user flows and scenarios
3. **Draft Stories** → Cover happy paths, then edge cases
4. **Apply INVEST** → Check and refine against criteria
5. **Add Acceptance Criteria** → Define testability for each story
6. **Prioritize** → Sequence and rank by value
7. **Create Issues** → Add to GitHub Projects as children of epic
8. **Proceed** → Move to task breakdown for each story

## Reference Files

Load references as needed:

| Reference | When to Load | Path |
|-----------|--------------|------|
| **invest-criteria.md** | Validating stories against INVEST | `references/invest-criteria.md` |
| **splitting-techniques.md** | Story is too large and needs splitting | `references/splitting-techniques.md` |
| **story-template.md** | Creating story issue content | `references/story-template.md` |

## Examples

Working examples that can be copied and adapted:

| Example | Use Case | Path |
|---------|----------|------|
| **example-story-issue.md** | Creating a single story with full detail | `examples/example-story-issue.md` |
| **example-story-set.md** | Viewing related stories for an epic | `examples/example-story-set.md` |

## Related Skills

Load these skills when story work reveals needs beyond this skill's scope:

| Story Context | Load Skill | Routing Trigger |
|---------------|------------|-----------------|
| No epics exist or epic scope is unclear | `epic-identification` | User needs to create or refine epics |
| Stories are complete and user wants tasks | `task-breakdown` | User is ready to break a story into implementation tasks |
| Story priorities need to be established | `prioritization` | User needs to apply MoSCoW framework to stories |
| Stories need user or stakeholder validation | `requirements-feedback` | User needs to gather input on story scope or acceptance criteria |
