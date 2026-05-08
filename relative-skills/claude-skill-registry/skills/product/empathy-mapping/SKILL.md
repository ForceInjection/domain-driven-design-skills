---
name: empathy-mapping
description: Create structured visualizations of stakeholder perspectives (says, thinks, does, feels) to build deep understanding. Use when conducting user research or validating assumptions.
---

# Empathy Mapping

## Overview
Create a structured visualization of what a stakeholder says, thinks, does, and feels to build deep understanding of their perspective.

## When to Use
- During the Empathize phase
- After conducting observations or interviews
- When synthesizing user research
- When validating assumptions about stakeholder needs

## How to Apply

### 1. Choose Your Subject
Identify the specific stakeholder or stakeholder group to map.

### 2. Gather Data
Review observation and interview notes for this stakeholder.

### 3. Create the Map
Organize findings into four quadrants:

**SAYS** — Direct quotes, what they verbalize
- What exact words do they use?
- What do they tell others?
- What have you heard them say?

**THINKS** — Beliefs, concerns, interpretations
- What might they be thinking?
- What matters to them?
- What are their concerns?
- What occupies their thoughts?

**DOES** — Actions, behaviors, observable activities
- What actions have you observed?
- What do they do today?
- How do they behave?
- What workflows do they follow?

**FEELS** — Emotional states, frustrations, aspirations
- What emotions have you observed?
- What frustrates them?
- What excites them?
- What are their fears and aspirations?

### 4. Identify Insights
Look for:
- **Contradictions** — Where SAYS differs from DOES or THINKS
- **Pain Points** — Negative emotions or frustrations
- **Gains** — Positive emotions or aspirations
- **Unmet Needs** — Gaps between what they do and what they want

### 5. Document
Save the empathy map in `projects/[project_name]/insights/` and link it from the stakeholder's profile in currentstate.json.

## Example Structure

```markdown
# Empathy Map: [Stakeholder Name]

## Says
- "I don't have time to learn new systems"
- "It needs to just work"

## Thinks
- Worried about making mistakes
- Believes current tool is holding them back
- Wants to be more efficient

## Does
- Uses workarounds to avoid broken features
- Checks work multiple times
- Stays late to complete tasks

## Feels
- Frustrated when tools fail
- Anxious about deadlines
- Proud when delivering good work

## Insights
**Pain:** Lack of reliability creates anxiety and extra work
**Need:** Simple, reliable tools that don't require extensive training
**Opportunity:** Reduce cognitive load and improve confidence
```

## Tips
- Use the stakeholder's own words in SAYS
- Infer THINKS and FEELS from observations and context
- Focus on behaviors, not just self-reported actions
- Look for emotional patterns and intensity
- One empathy map per distinct stakeholder type
