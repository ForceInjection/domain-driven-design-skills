---
name: epic-identification
description: |
  This skill should be used when the user asks to "identify epics", "break down vision into epics", "find major features", "discover capability areas", "decompose vision", "group requirements into themes", "define high-level features", "what epics do I need", "turn vision into work items", or "split project into epics". Provides methodology for deriving epics from a vision statement using user journey mapping, capability decomposition, and stakeholder analysis.
---

# Epic Identification

## Quick Actions & Routing

| User Intent | Action | Resource |
|-------------|--------|----------|
| Reviewing vision first | Understand scope and capabilities | Step 1: Review the Vision |
| Identifying capabilities | Apply discovery techniques | `references/discovery-techniques.md` |
| Naming epics | Use epic naming patterns | Step 4: Name and Describe Each Epic |
| Checking completeness | Perform gap analysis | Step 5: Validate Completeness |
| Creating epic issues | Use template | `references/epic-template.md` |
| Viewing examples | Load sample epic set | `examples/example-epic-set.md` |

## Command Integration

The `/re:identify-epics` command guides epic creation in GitHub Projects. This skill provides the methodology for identifying and defining epics—including discovery techniques (user journey mapping, capability decomposition), validation criteria, and common patterns. Load this skill for technique guidance beyond what the command provides.

## Overview

Systematically decompose a product vision into well-defined epics—major capabilities or features that can be further broken down into user stories and tasks. Epics represent significant bodies of work that are too large for a single iteration but directly contribute to achieving the vision.

## Purpose

Epics serve as the middle layer in the requirements hierarchy:
- **Above**: Product Vision (the "why" and "what" at highest level)
- **Epics**: Major capabilities (the "what" at feature level)
- **Below**: User Stories (the "what" at detailed level)

Well-defined epics:
- Organize work into logical, valuable chunks
- Enable roadmap planning and sequencing
- Provide clear scope boundaries for teams
- Facilitate prioritization of major capabilities

## Prerequisite

Vision must exist before identifying epics. If no vision exists, use the **vision-discovery** skill first.

## Epic Identification Process

### Step 1: Review the Vision

Begin by thoroughly understanding the vision:

**Key Actions:**
- Read the vision issue in GitHub Projects
- Identify core capabilities mentioned or implied
- Note user goals and success metrics
- Understand scope boundaries (what's included/excluded)

**Guidelines:**
- Identify major capabilities the solution needs
- Map user journeys that must be supported
- Note integration points and dependencies
- Review success metrics driving capability requirements

**Examples:**
- ✅ Review vision, identify 3 user types and 5 core capabilities before proceeding
- ✅ Map "user uploads file → processes → downloads result" as a key journey
- ❌ Skip vision review and jump straight to naming epics
- ❌ Focus only on technical capabilities, ignoring user goals

### Step 2: Identify Major Capabilities

Break down the vision into distinct major capabilities:

**Key Actions:**
- Apply multiple discovery techniques (below)
- Group related functionality into logical capabilities
- Identify 5-10 major things the product must do

**Guidelines:**

Apply discovery techniques from `references/discovery-techniques.md`:
- User Journey Mapping
- Capability Decomposition
- Stakeholder Needs Analysis
- Technical Enablers Identification

See reference for detailed process and examples for each technique.

**Examples:**
- ✅ "User Onboarding", "Content Creation", "Analytics & Reporting"
- ✅ "User Authentication", "Data Import/Export", "Collaboration Features"
- ✅ "User Management", "Permissions & Access Control"
- ✅ "Third-party Integrations", "Data Synchronization"

### Step 3: Define Epic Characteristics

For each identified capability, determine if it qualifies as an epic:

**Key Actions:**
- Evaluate each capability against epic criteria
- Check size appropriateness
- Combine or split as needed

**Guidelines:**
- **Valuable**: Delivers significant user or business value
- **Large**: Too big to complete in a single iteration (typically multiple user stories)
- **Cohesive**: Represents a logical grouping of related functionality
- **Bounded**: Has clear scope—what's included and excluded
- **Measurable**: Success can be defined and tracked

_Size Guidelines:_
- An epic typically contains 3-12 user stories
- Takes multiple sprints/iterations to complete
- If smaller, consider combining with related epics
- If larger, consider splitting into multiple epics

**Examples:**
- ✅ "User Authentication" epic: valuable (enables access), large (multiple stories), cohesive (all auth-related), bounded (login/logout/reset only)
- ✅ Split "Platform" into "User Management", "Content Management", "Analytics" (each meets criteria)
- ❌ "Add login button" as an epic (too small—this is a task)
- ❌ "Build the product" as an epic (too large—needs decomposition)

### Step 4: Name and Describe Each Epic

Create clear, descriptive titles and summaries:

**Key Actions:**
- Create descriptive titles for each epic
- Write structured descriptions using template
- Ensure names focus on capability, not implementation

**Guidelines:**
- Use noun phrases describing the capability
- Be specific but concise (3-6 words)
- Focus on "what" not "how"

**Examples:**
- ✅ "User Authentication & Authorization"
- ✅ "Campaign Performance Dashboard"
- ✅ "Automated Email Notifications"
- ✅ "Third-party Calendar Integration"
- ❌ "Build the backend" (too vague, technical)
- ❌ "Make users happy" (outcome, not capability)
- ❌ "Phase 1" (not descriptive)

### Epic Issue Template (Quick Reference)

_For comprehensive templates with domain-specific examples, see `references/epic-template.md`._

```markdown
## Epic Overview
[Brief description]

## Value Proposition
[Why this matters]

## Scope
- Included: [capabilities]
- Excluded: [out of scope]

## Success Criteria
- [ ] [Measurable outcomes]
```

### Step 5: Validate Completeness

Ensure all necessary epics have been identified:

**Key Actions:**
- Verify epics collectively deliver the full vision
- Identify and fill any gaps
- Map epics back to vision sections

**Guidelines:**
- Verify epics collectively deliver the full vision
- Identify gaps in user journeys or capabilities
- Confirm coverage of all target user types and their needs
- Check that success metrics are addressable with these epics
- Ensure infrastructure and technical epics are identified

_Gap Analysis Technique:_
- Map epics back to vision sections (problem, users, capabilities, metrics)
- Identify vision elements not covered by any epic
- Create additional epics to fill gaps

**Examples:**
- ✅ Discover vision mentions "mobile access" but no epic covers it → add "Mobile Application" epic
- ✅ Map 8 epics to vision and confirm all 4 user types have supporting capabilities
- ❌ Assume 3 epics cover everything without checking against vision
- ❌ Skip completeness check and proceed directly to issue creation

### Step 6: Organize and Prioritize

Structure epics for planning and sequencing:

**Key Actions:**
- Group related epics logically
- Map dependencies between epics
- Apply initial prioritization

**Guidelines:**

_Logical Grouping:_
- Group related epics (e.g., all authentication-related, all reporting-related)
- Identify epic clusters that deliver cohesive value together

_Dependency Mapping:_
- Identify which epics must come before others
- Map the critical path through epic delivery

_Initial Prioritization:_
- Apply MoSCoW framework (Must/Should/Could/Won't)
- Consider value, risk, dependencies, effort
- Use the prioritization skill for detailed prioritization

**Examples:**
- ✅ "User Authentication" likely precedes "User Profile Management"
- ✅ Group: Authentication → Profile → Settings (related cluster)

### Step 7: Create Epic Issues in GitHub Projects

For each epic, create a GitHub issue in the relevant GitHub Project:

**Key Actions:**
- Create GitHub issue for each epic
- Set custom fields (Type, Priority, Status)
- Apply labels and link to Vision as parent

**Guidelines:**

_Issue Title:_ "[Epic Name]"

_Issue Description:_ Full epic definition using template

_Custom Fields:_
- Type: Epic
- Priority: [Must Have / Should Have / Could Have]
- Status: Not Started

_Labels:_
- `type:epic`
- `priority:[moscow-level]`

_Parent:_ Link to Vision issue as parent

All user stories for this epic will be created as child issues, establishing hierarchy.

**Examples:**
- ✅ Create issue titled "User Authentication & Authorization" with Type=Epic, Priority=Must Have, linked to Vision #1
- ✅ Include clear scope in issue body: "Includes: login, logout, password reset. Excludes: SSO, social login"
- ❌ Create issue with vague title "Auth stuff" and no description
- ❌ Forget to set Type field to Epic or link to parent Vision issue

## Epic Templates and Patterns

For common epic patterns (universal and domain-specific) and working examples, consult `references/common-patterns.md`.

## Best Practices

### Right Level of Granularity

Epics should be:
- **Not too big**: "Build the entire platform" → Split into multiple epics
- **Not too small**: "Add a button" → This is a task, not an epic
- **Just right**: "Shopping Cart & Checkout" → Major capability with multiple stories

### Ensure User-Centric Value

Every epic should answer: "What can users do with this that they couldn't before?"

If an epic is purely technical with no user-facing impact, consider:
- Is it really necessary as a standalone epic?
- Can it be folded into a user-facing epic?
- Is it an enabler for multiple epics? (Then it's valid as infrastructure epic)

### Avoid Epic Overlap

Epics should be distinct and non-overlapping:
- Clear boundaries between epics
- Related functionality grouped into one epic, not split across several
- If unsure, combine into one epic and split later if needed

### Plan for Iteration

Epics will likely be refined:
- Initial identification may miss epics—add them as discovered
- Epics may be split or combined as understanding grows
- Scope boundaries may shift during user story creation
- This is normal—embrace learning and adaptation

## Common Pitfalls to Avoid

Watch for wrong granularity (too many/few epics), implementation-focused names, vague names, and missing infrastructure epics. See `references/common-pitfalls.md` for detailed examples and remediation.

## Quick Reference: Epic Identification Flow

| Step | Action | Output |
|------|--------|--------|
| 1 | Review Vision | Problem, users, capabilities, metrics understood |
| 2 | Identify Capabilities | Journey mapping, decomposition, stakeholder needs applied |
| 3 | Validate as Epics | Valuable, large, cohesive, bounded, measurable confirmed |
| 4 | Name & Describe | Clear titles, structured descriptions using template |
| 5 | Check Completeness | All vision elements covered, no gaps |
| 6 | Organize & Prioritize | Logical grouping, dependencies mapped, MoSCoW applied |
| 7 | Create Issues | Added to GitHub Projects as children of vision |
| — | Next | Move to user story creation for each epic |

## Integration with Requirements Lifecycle

### Before Epic Identification

**Vision exists** (created via vision-discovery skill)
- Problem, users, solution, success metrics defined
- Scope boundaries established

### During Epic Identification

**Create epic issues** in GitHub Projects
- Each epic is a child of the vision issue
- Epics organized and prioritized

### After Epic Identification

**Proceed to user story creation** (user-story-creation skill)
- Select an epic and break it down into stories
- Iterate epic-by-epic until all epics have stories

## Reference Files

Load references based on context:

| Reference | When to Load | Path |
|-----------|--------------|------|
| **discovery-techniques.md** | Applying multiple discovery methods or user needs technique guidance | `references/discovery-techniques.md` |
| **epic-template.md** | Creating epic issue content or user requests templates | `references/epic-template.md` |
| **common-patterns.md** | User's domain is identified for pattern suggestions | `references/common-patterns.md` |
| **common-pitfalls.md** | Reviewing epics for quality or troubleshooting epic definition issues | `references/common-pitfalls.md` |

## Examples

Working examples that can be copied and adapted:

| Example | Use Case | Path |
|---------|----------|------|
| **example-epic-issue.md** | Creating a single epic issue with full detail | `examples/example-epic-issue.md` |
| **example-epic-set.md** | Viewing a complete set of 8 epics for a sample product | `examples/example-epic-set.md` |

## Related Skills

Load these skills when epic work reveals needs beyond this skill's scope:

| Epic Context | Load Skill | Routing Trigger |
|--------------|------------|-----------------|
| No vision exists or vision needs revision | `vision-discovery` | User needs to create or refine the product vision |
| Epics are complete and user wants stories | `user-story-creation` | User is ready to break an epic into user stories |
| Epic priorities need to be established | `prioritization` | User needs to apply MoSCoW framework to epics |
| Epics need stakeholder validation | `requirements-feedback` | User needs to gather input on epic scope or priorities |
