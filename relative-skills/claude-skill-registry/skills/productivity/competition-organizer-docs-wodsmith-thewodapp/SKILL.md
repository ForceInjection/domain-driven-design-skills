---
name: competition-organizer-docs
description: Generate and review documentation for competition organizers using Diataxis framework. Use when writing docs for organizer workflows like creating competitions, managing divisions, scheduling heats, handling registrations, entering results, or managing volunteers/judges.
---

# Competition Organizer Documentation Skill

Generates Diataxis-compliant documentation for WODsmith competition organizers.

## Persona: Competition Organizer

**Who they are:** CrossFit gym owners, event directors, competition coordinators. Time-constrained, varying technical comfort, may run 1-2 events/year (casual) or 10+ (professional).

**Documentation needs by experience:**

| Level | Primary Need | Doc Types |
|-------|--------------|-----------|
| First-time | "How do I even start?" | Tutorials |
| Experienced | "How do I do X efficiently?" | How-to guides |
| Power user | "What are the exact options?" | Reference |

## Critical Workflow

**REQUIRED**: Before writing organizer docs:

1. Load the base skill: `skills_use(name="documentation")`
2. Read the relevant Diataxis reference from `documentation/references/`
3. Load the workflow reference below for organizer-specific details
4. Apply both Diataxis principles AND organizer context

## Workflow References (load on demand)

**REQUIRED**: Before writing docs, load the relevant reference:

| If documenting... | Load this reference |
|-------------------|---------------------|
| Create, Edit, Settings, Delete competition | `references/competition-setup.md` |
| Registrations, Divisions, Pricing, Athletes | `references/athlete-management.md` |
| Events, Schedule, Heats, Results, Scoring | `references/event-operations.md` |
| Volunteers, Judges, Rotations | `references/volunteer-coordination.md` |
| Revenue, Sponsors, Series | `references/business-operations.md` |

## Workflow Overview

### Tutorials (4 workflows)
- Create Competition, Configure Divisions, Configure Registration, Add First Event

### How-to Guides (13 workflows)  
- Schedule Heats, Manage Registrations, Volunteers, Judge Rotations, Enter Results, Track Revenue, Manage Sponsors, Competition Series, Edit Competition, Settings, Delete Competition, Assign Athletes to Heats, Configure Scoring

### Reference (6 topics)
- Event Types, Division Configuration, Registration Fields, Schedule API, Scoring Rules, Permissions

### Explanation (4 topics)
- Scoring System, Judge Rotations, Heat Scheduling, Division Structure

## User Journeys

**Journey 1: First-Time Organizer** (11 steps)
Create competition → Set divisions → Add events → Configure scoring → Set pricing → Open registration → Process registrations → Schedule heats → Recruit volunteers → Event day ops → Publish results

**Journey 2: Event Day Operations**
Check-in athletes → Assign heats → Enter results → Handle disputes → Publish live scores

**Journey 3: Post-Competition**
Finalize results → Export data → Track revenue → Thank sponsors → Archive competition

## Structured Output Templates

```yaml
# Documentation request
type: documentation-request
persona: organizer
workflow: <workflow-name>
doc_type: tutorial | how-to | reference | explanation
context:
  route: <route-path>
  complexity: low | medium | high | very-high
```
