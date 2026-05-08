---
name: requirements-feedback
description: This skill should be used when the user asks about "feedback loops", "iterate on requirements", "continuous documentation", "refine requirements", "update requirements", "requirements changed", "stakeholder review", "validate requirements", "incorporate feedback", "gather feedback", "requirements review meeting", "backlog refinement feedback", "user research findings", "sprint retrospective feedback", "help me gather feedback", "run a feedback session", "get input on my vision", "get input on my epics", "get input on my stories", "collect user feedback", "document feedback from meeting", "review requirements with stakeholders", or when they need guidance on collecting and incorporating feedback throughout the requirements lifecycle.
---

# Requirements Feedback & Continuous Documentation

## Quick Actions & Routing

| User Intent | Action | Resource |
|-------------|--------|----------|
| Collecting feedback methods | Load techniques reference | `references/feedback-techniques.md` |
| Stage-specific guidance | Load stage guide | `references/stage-feedback-guide.md` |
| Running a review | Load checklist | `references/feedback-checklist.md` |
| Incorporating feedback | Use 7-step workflow | Quick Reference section below |
| Complete example | Load example | `examples/feedback-workflow-example.md` |

## Command Integration

The `/re:review` and `/re:status` commands handle automated validation. This skill complements them with human feedback collection and incorporation workflows.

## Overview

Requirements feedback is the systematic process of gathering, analyzing, and incorporating input from users, stakeholders, and team members throughout the requirements lifecycle. Unlike static documentation, requirements in GitHub Projects are living documents that evolve as understanding deepens. This skill guides the collection and integration of feedback to continuously refine vision, epics, user stories, and tasks—ensuring requirements stay aligned with real-world needs and learnings.

## Purpose

Feedback serves as the quality assurance layer across the requirements hierarchy:

- **Vision level**: Validates problem understanding and strategic alignment
- **Epic level**: Confirms capability scope and feasibility
- **Story level**: Refines user value and acceptance criteria
- **Task level**: Surfaces implementation insights and blockers

Effective feedback:

- Catches misunderstandings early before costly rework
- Incorporates real-world learnings into requirements
- Keeps requirements aligned with evolving user needs
- Enables data-driven refinement of priorities and scope

## Feedback Collection Process

### Step 1: Collect Feedback

**Key Actions:**

- Gather insights from users, stakeholders, and team members
- Use appropriate techniques for each audience (see `references/feedback-techniques.md`)
- Document feedback systematically with source, date, and context

**Guidelines:**

- Match technique to audience: interviews for stakeholders, testing for users
- Capture both explicit feedback and observed behaviors
- Reference "Feedback at Each Stage" below for level-specific guidance

### Step 2: Analyze Feedback

**Key Actions:**

- Identify patterns and themes across multiple feedback sources
- Validate assumptions against collected data
- Extract actionable insights from raw feedback

**Guidelines:**

- Look for recurring themes—single data points may be outliers
- Separate signal from noise; not all feedback requires action
- Note conflicting feedback for stakeholder discussion

### Step 3: Decide

**Key Actions:**

- Prioritize feedback items by impact and alignment with vision
- Determine which changes to make to requirements
- Document decisions and rationale

**Guidelines:**

- Use impact/effort analysis for prioritization
- Involve stakeholders in decisions affecting scope or priority
- Some feedback may be deferred to future iterations—document explicitly

### Step 4: Update

**Key Actions:**

- Modify GitHub issues (vision, epics, stories, tasks) based on decisions
- Update acceptance criteria to reflect new understanding
- Adjust priorities if feedback changes relative importance

**Guidelines:**

- Add comments explaining what changed and why
- Keep changes traceable via GitHub's edit history
- Tag relevant team members on significant updates

### Step 5: Communicate

**Key Actions:**

- Inform stakeholders and team of changes made
- Explain how specific feedback was incorporated
- Acknowledge feedback providers

**Guidelines:**

- Close the loop—tell people how their input was used
- Explain decisions even when feedback wasn't incorporated
- Use GitHub comments to keep communication in context

### Step 6: Validate

**Key Actions:**

- Verify changes actually address the original feedback
- Check for unintended consequences of updates
- Confirm with feedback source when appropriate

**Guidelines:**

- Quick review with original feedback provider builds trust
- Watch for ripple effects on related requirements
- Iterate if validation reveals issues

### Step 7: Repeat

**Key Actions:**

- Schedule regular feedback cycles throughout the project
- Build feedback collection into standard workflows
- Continuously refine based on ongoing learnings

**Guidelines:**

- Don't wait for perfect timing—continuous feedback beats batched reviews
- Adjust feedback frequency based on project phase
- Feedback is an ongoing activity, not a one-time event

## Feedback at Each Stage

Each level of the requirements hierarchy has distinct feedback needs. For detailed guidance on who to involve, what questions to ask, and how to incorporate feedback at each level, see `references/stage-feedback-guide.md`.

| Level | When to Gather Feedback | Key Focus |
|-------|------------------------|-----------|
| **Vision** | After creating/updating vision | Problem validation, strategic alignment |
| **Epic** | After identifying epics, before stories | Completeness, feasibility, dependencies |
| **Story** | During refinement, after user testing | INVEST criteria, acceptance criteria clarity |
| **Task** | During implementation, code review | Accuracy, discovered work, blockers |

## The Build-Measure-Learn Loop

| Phase | Action | Examples |
|-------|--------|----------|
| **Build** | Implement requirements | Epic → Stories → Tasks |
| **Measure** | Collect data and feedback | User testing, analytics, business metrics, retrospectives |
| **Learn** | Extract insights and refine | What worked? What didn't? What's missing? What changed? |
| **Repeat** | Update requirements | Iterate with refined understanding |

## Continuous Documentation Practices

### Keep Requirements Up to Date

Living document principles:

- Requirements in GitHub issues are living documents, not static specs
- Update issues as understanding evolves
- Add clarifications when questions arise
- Document decisions made during implementation
- Link to discussions or PRs that informed changes

### Document Learnings

- Add comments to issues with findings from user research
- Link to test results or analytics that inform requirements
- Reference customer feedback or support tickets
- Note technical discoveries that impact requirements

### Maintain Traceability

- Tasks link to parent stories
- Stories link to parent epics
- Epics link to parent vision
- Full chain of traceability maintained
- Link to supporting documents (design mocks, research findings)

## Best Practices

| Practice | Key Actions | Avoid |
|----------|-------------|-------|
| **Create Safe Space** | Reward early problem-catching; ask open questions ("What's missing?") | Blame when requirements change |
| **Act Quickly** | Update within 24 hours; communicate changes to feedback providers | Collecting feedback then taking no action |
| **Balance Stability/Flexibility** | Batch small changes; major changes need broader review | Refusing updates because "scope is agreed" |
| **Document the "Why"** | Add comments explaining changes; reference evidence (user quotes, data) | Silent edits with no explanation |
| **Validate with Real Users** | Regular usability sessions; observe actual usage, not just opinions | Waiting until launch to discover misalignment |

## Common Pitfalls to Avoid

| Pitfall | Problem | Solution |
|---------|---------|----------|
| **Treating requirements as contracts** | Resistance to change | Collaborate; requirements should evolve |
| **Ignoring implementation feedback** | Missing important technical details | Listen when developers raise concerns |
| **Feedback without action** | Disengages contributors | Act on feedback or explain why not |
| **Changing too frequently** | Confusion and churn | Batch minor updates; communicate major changes |
| **Only internal feedback** | Echo chamber risk | Involve real users regularly |

## Quick Reference: Feedback Integration Flow

1. **Collect Feedback** → Gather insights from users, stakeholders, team
2. **Analyze** → Identify patterns, validate assumptions, extract learnings
3. **Decide** → Determine what changes to make to requirements
4. **Update** → Modify GitHub issues (vision, epics, stories, tasks)
5. **Communicate** → Inform stakeholders and team of changes
6. **Validate** → Verify changes address feedback and improve requirements
7. **Repeat** → Continuous cycle throughout product lifecycle

## GitHub Projects Integration

### Tracking Feedback

- Add feedback as comments on relevant issues
- Tag people who provided feedback
- Link to supporting evidence (research findings, analytics)

**Useful labels:**

- `needs-validation` - Requires user feedback
- `feedback-received` - Feedback available, needs incorporation
- `updated-from-feedback` - Changed based on feedback

### Documenting Changes

- GitHub tracks all changes via edit history
- Add comment on significant updates explaining what changed and why
- Reference feedback sources (user quotes, data, discussions)
- Link to related issues, test results, or PRs

## Reference Files

Load references as needed:

| Reference | When to Load | Path |
|-----------|--------------|------|
| **stage-feedback-guide.md** | Detailed guidance for feedback at each requirements level (Vision, Epic, Story, Task) | `references/stage-feedback-guide.md` |
| **feedback-techniques.md** | Methods for user research, stakeholder reviews, team feedback, and automated feedback | `references/feedback-techniques.md` |
| **feedback-checklist.md** | Conducting feedback reviews or validating requirements at any level | `references/feedback-checklist.md` |
| **feedback-templates.md** | GitHub comment templates for documenting feedback | `references/feedback-templates.md` |

## Examples

Working examples that can be copied and adapted:

| Example | Use Case | Path |
|---------|----------|------|
| **feedback-workflow-example.md** | Complete end-to-end feedback collection and incorporation cycle | `examples/feedback-workflow-example.md` |

## Related Skills

Load these skills when feedback reveals needs beyond this skill's scope:

| Feedback Context | Load Skill | Routing Trigger |
|------------------|------------|-----------------|
| Vision feedback reveals gaps in vision definition | `vision-discovery` | User needs to revise or create vision elements |
| Epic feedback reveals scoping issues | `epic-identification` | User needs to adjust epic boundaries or dependencies |
| Story feedback reveals INVEST violations | `user-story-creation` | User needs to rewrite stories to meet criteria |
| Task feedback reveals breakdown issues | `task-breakdown` | User needs to reorganize task structure |
| Feedback changes priorities | `prioritization` | User needs to re-apply MoSCoW framework |
