---
name: persona-development
description: Create evidence-based user personas with empathy maps. Develop detailed user archetypes from research data to guide product decisions and maintain user-centered focus.
allowed-tools: Read, Write, Glob, Grep, Task, WebSearch, WebFetch
---

# Persona Development

## When to Use This Skill

Use this skill when:

- **Persona Development tasks** - Working on create evidence-based user personas with empathy maps. develop detailed user archetypes from research data to guide product decisions and maintain user-centered focus
- **Planning or design** - Need guidance on Persona Development approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Personas are fictional representations of key user segments based on real research data. They help teams maintain empathy for users throughout the product development process by making abstract user segments concrete and memorable.

## Persona Types

| Type | Based On | Best For |
|------|----------|----------|
| **Research-Based** | Extensive user research | Mature products, significant investment |
| **Proto-Persona** | Team assumptions | Early stage, hypothesis generation |
| **Jobs Persona** | JTBD analysis | Outcome-focused products |
| **Buyer Persona** | Purchase behavior | B2B, sales-focused products |
| **Negative Persona** | Anti-patterns | Avoiding wrong customers |

## Persona Components

### Core Elements

| Component | Description | Example |
|-----------|-------------|---------|
| **Name** | Memorable, representative | "Developer Dana" |
| **Photo** | Representative image | Stock photo or illustration |
| **Quote** | Captures essence | "I need to ship fast without breaking things" |
| **Demographics** | Relevant background | Role, experience, company size |
| **Goals** | What they want to achieve | "Reduce code review time" |
| **Frustrations** | Pain points and blockers | "Manual processes slow me down" |
| **Behaviors** | How they work | "Reviews 5-10 PRs daily" |
| **Technology** | Tools and preferences | "VS Code, GitHub, Slack" |

### Extended Elements

| Component | Description |
|-----------|-------------|
| **Bio** | Brief narrative background |
| **Day in the Life** | Typical workflow |
| **Influence Map** | Who influences their decisions |
| **Success Metrics** | How they measure success |
| **Objections** | Concerns about solutions |

## Empathy Map

The empathy map captures four quadrants of user experience:

```text
┌─────────────────────────────────────────────────────────────────┐
│                           SAYS                                  │
│  What do they say out loud? Direct quotes from interviews.      │
│  "I spend half my day in code reviews"                          │
│  "The process is frustrating but necessary"                     │
├────────────────────────────────┬────────────────────────────────┤
│            THINKS              │            DOES                │
│  What are they thinking?       │  What actions do they take?    │
│  (May differ from says)        │  Observable behaviors          │
│  "Is this code really safe?"   │  Reads every line carefully    │
│  "I might miss something"      │  Cross-references documentation│
│  "This is taking too long"     │  Uses multiple browser tabs    │
├────────────────────────────────┴────────────────────────────────┤
│                           FEELS                                 │
│  Emotional state during the experience                          │
│  😰 Anxious about missing bugs    😤 Frustrated with slow tools │
│  😊 Satisfied when helping team   😩 Overwhelmed by PR volume   │
└─────────────────────────────────────────────────────────────────┘
```

### Extended Empathy Map

```text
┌─────────────────────────────────────────────────────────────────┐
│                          PAINS                                  │
│  Obstacles, frustrations, risks                                 │
│  • Repetitive manual tasks                                      │
│  • Context switching overhead                                   │
│  • Fear of missing critical issues                              │
├─────────────────────────────────────────────────────────────────┤
│                          GAINS                                  │
│  Wants, needs, success measures                                 │
│  • Faster time to merge                                         │
│  • Confidence in code quality                                   │
│  • Recognition from team                                        │
└─────────────────────────────────────────────────────────────────┘
```

## Creating Personas

### Step 1: Gather Research Data

**Data Sources**:

- User interviews (primary)
- Customer support tickets
- Survey responses
- Usage analytics
- Sales call notes
- Social media / forum discussions

**Minimum Viable Research**:

- 5-8 user interviews
- Support ticket themes analysis
- Basic usage data

### Step 2: Identify Patterns

**Affinity Mapping**:

1. Write key observations on sticky notes
2. Group similar observations
3. Name each group
4. Look for persona-defining clusters

**Behavioral Variables**:

- Frequency of use
- Feature preferences
- Decision-making process
- Information sources
- Pain tolerance

### Step 3: Draft Personas

For each distinct user segment:

1. **Synthesize demographics** from research data
2. **Craft representative quote** capturing essence
3. **List goals and frustrations** in user's language
4. **Describe typical behaviors** with specifics
5. **Create empathy map** from interview data

### Step 4: Validate and Refine

- Review with team for accuracy
- Check against additional data
- Validate with users if possible
- Iterate based on feedback

## Persona Template

### [Persona Name]

**Role**: [Job Title / Role]
**Experience**: [Years in role, expertise level]
**Context**: [Company size, industry, team structure]

**Quote**: *"[Memorable quote that captures their perspective]"*

#### Goals

- [Primary goal]
- [Secondary goal]
- [Tertiary goal]

#### Frustrations

- [Major pain point]
- [Secondary frustration]
- [Minor annoyance]

#### Behaviors

- [Key behavior 1]
- [Key behavior 2]
- [Key behavior 3]

#### Technology Profile

- **Primary tools**: [List]
- **Preferred platforms**: [List]
- **Tech savviness**: [Low/Medium/High]

#### A Day in Their Life

[2-3 paragraph narrative of typical day]

#### Success Metrics

- [How they measure their own success]
- [What their manager measures]

#### Objections / Concerns

- [Potential concerns about your solution]
- [What would make them hesitant]

---

## Example Persona

### Developer Dana

**Role**: Senior Software Engineer
**Experience**: 6 years, full-stack development
**Context**: Mid-size SaaS company (200 employees), 8-person engineering team

**Quote**: *"I want to ship quality code fast. The review process shouldn't be the bottleneck."*

#### Goals

- Maintain high code quality across the team
- Reduce time spent on repetitive review tasks
- Help junior developers learn best practices

#### Frustrations

- Inconsistent code review standards across team
- Context switching between reviews and coding
- Catching the same types of issues repeatedly

#### Behaviors

- Reviews 5-10 pull requests per day
- Uses VS Code with multiple extensions
- Writes detailed PR descriptions
- Creates documentation for complex changes

#### Technology Profile

- **Primary tools**: VS Code, GitHub, Slack, Jira
- **Preferred platforms**: macOS, Linux
- **Tech savviness**: High

#### A Day in Their Life

Dana starts the day by checking Slack and email for urgent reviews. After the daily standup, she spends about 2 hours reviewing PRs from overnight work. She tries to batch reviews to minimize context switching, but urgent PRs often interrupt her coding blocks.

Afternoons are for her own development work, but she's frequently pulled into discussions about code patterns and architecture decisions. She mentors two junior developers who often ask for quick reviews of their work.

#### Success Metrics

- Sprint velocity (team metric)
- Bugs found in production (team metric)
- PR review turnaround time (personal goal: < 4 hours)

#### Objections / Concerns

- "Will this slow down my workflow?"
- "How accurate are AI suggestions really?"
- "I need to maintain my own judgment, not outsource it"

---

## Proto-Personas

When research data is limited, create proto-personas based on team assumptions.

### Proto-Persona Template

```text
┌─────────────────────────────────────────────────────────────────┐
│  Name: [Descriptive Name]                         [Sketch/Icon] │
│  Role: [Job Title]                                              │
├─────────────────────────────────────────────────────────────────┤
│  Behaviors:               │  Needs/Goals:                       │
│  • [Assumed behavior 1]   │  • [Assumed need 1]                 │
│  • [Assumed behavior 2]   │  • [Assumed need 2]                 │
│  • [Assumed behavior 3]   │  • [Assumed need 3]                 │
├─────────────────────────────────────────────────────────────────┤
│  Pain Points:             │  Demographics:                      │
│  • [Assumed pain 1]       │  • [Age range, if relevant]         │
│  • [Assumed pain 2]       │  • [Company size]                   │
│  • [Assumed pain 3]       │  • [Tech experience]                │
└─────────────────────────────────────────────────────────────────┘
```

**Important**: Proto-personas are hypotheses. Validate with research!

## Jobs Personas

When using JTBD, create personas around jobs rather than demographics.

### Jobs Persona Template

**Job**: [The main job to be done]

**When I...** [situation/context]
**I want to...** [motivation]
**So I can...** [expected outcome]

**Hiring Criteria**:

- [What they look for in a solution]
- [What would make them "hire" a product]

**Firing Triggers**:

- [What would make them "fire" a product]
- [Deal breakers]

## AI-Assisted Persona Development

### From Interview Data

Given interview transcripts:

1. Extract behavioral patterns
2. Identify goals and frustrations
3. Find representative quotes
4. Create empathy map
5. Draft persona narrative

### From Analytics Data

Given usage data:

1. Identify behavioral segments
2. Characterize each segment
3. Hypothesize goals/frustrations
4. Flag areas needing interview validation

### Persona Validation

Review persona against:

1. Does it represent real users?
2. Is it specific enough to be useful?
3. Does it help make decisions?
4. Would users recognize themselves?

## Using Personas

### In Product Development

- Reference personas in user stories
- Include persona name in requirements
- Design for specific personas first
- Prioritize features by persona value

### In Meetings

- "What would [Persona] think?"
- "How does this help [Persona]'s goal?"
- "Would [Persona] understand this?"

### Anti-Patterns

❌ **Creating too many personas** (3-5 is usually enough)
❌ **Including irrelevant demographics** (if it doesn't affect behavior, skip it)
❌ **Making personas too perfect** (include realistic flaws)
❌ **Letting personas become stale** (update quarterly)

## Integration Points

**Inputs from**:

- `design-thinking` skill: Empathy research → Persona data
- `jtbd-analysis` skill: Job context → Jobs personas
- User interviews → Quotes, behaviors

**Outputs to**:

- User stories → "As [Persona]..."
- `design-sprint` skill: Personas for prototype testing
- Marketing → Messaging and positioning

## References

For additional Persona Development resources, see:
