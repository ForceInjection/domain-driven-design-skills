---
name: initiative-overview-template
description: Generic cross-functional initiative template for creating strategic initiative overview skills. Auto-invoke when user requests initiative skill creation, cross-team coordination framework, or strategic program templates. Do NOT load during specific project work (use project-specific skills instead).
allowed-tools: [Grep]
version: 1.0.0
category: Templates
tags: [template, initiative, strategy, cross-functional]
last-updated: 2025-10-20
---

# Initiative Overview Template

## Purpose
This template guides the creation of initiative overview skills - strategic information about cross-functional initiatives that span multiple products, teams, or projects. These skills ensure coordinated work and shared understanding across organizational boundaries. Replace all `[PLACEHOLDER]` values with actual initiative information.

## SKILL.md Frontmatter Template

```yaml
---
name: [initiative-slug]-overview
description: Initiative overview for [INITIATIVE_NAME] including goals, timeline, and cross-team coordination when discussing [WORK_STREAM_1], [WORK_STREAM_2], or [DELIVERABLE]. Auto-invoke when user mentions [INITIATIVE_NAME], [KEY_MILESTONE], or [INVOLVED_TEAM]. Do NOT load for general [DOMAIN] discussions unrelated to this initiative.
allowed-tools: []
version: 1.0.0
category: Initiative
tags: [[initiative-name], [domain], cross-functional, strategy]
initiative-status: [PLANNING/ACTIVE/ON_HOLD/COMPLETED]
start-date: [YYYY-MM-DD]
target-completion: [YYYY-MM-DD]
last-updated: [YYYY-MM-DD]
---
```

**Description Engineering Guidance**:

✅ **DO** include:
- Initiative name and key work streams
- Specific deliverables or milestones
- Teams or products involved
- Trigger terms people use when discussing this initiative

❌ **DON'T** use:
- Generic descriptions ("Cross-team project...")
- No scope boundaries (will load for unrelated work)
- Missing team or product context

**Example Good Description**:
```
Initiative overview for Pricing Innovation including flexible leasing, custom rate cards, and dynamic pricing when discussing payment options, merchant pricing, or revenue optimization. Auto-invoke when user mentions Pricing Innovation, flexible leasing, or custom rates. Do NOT load for general pricing discussions outside this initiative.
```

## Initiative Overview Content Structure

### 1. Initiative Charter

**Purpose**: Core definition and strategic rationale

#### Initiative Name
`[INITIATIVE_NAME]`

#### Executive Summary (2-3 sentences)
`[WHAT_THIS_INITIATIVE_IS_AND_WHY_IT_MATTERS]`

#### Problem Statement
**Current State**: `[WHAT_PROBLEM_EXISTS_TODAY]`

**Desired State**: `[WHAT_SUCCESS_LOOKS_LIKE]`

**Gap**: `[WHAT_PREVENTS_US_FROM_DESIRED_STATE]`

#### Strategic Rationale
- **Business Driver**: `[WHY_NOW]`
- **Strategic Alignment**: Supports `[COMPANY_GOAL]` and `[PRODUCT_STRATEGY]`
- **Expected Impact**: `[QUANTIFIED_BENEFIT_IF_POSSIBLE]`
  - Example: "Increase revenue by >20% through flexible pricing"
  - Example: "Reduce time-to-market for new products from 6 months to <6 weeks"

### 2. Initiative Scope & Boundaries

**Purpose**: What's in scope, what's explicitly out of scope

#### In Scope
- `[DELIVERABLE_1]`: `[BRIEF_DESCRIPTION]`
- `[DELIVERABLE_2]`: `[BRIEF_DESCRIPTION]`
- `[DELIVERABLE_3]`: `[BRIEF_DESCRIPTION]`

#### Out of Scope (Explicitly)
- ❌ `[OUT_OF_SCOPE_1]`: `[WHY_NOT_INCLUDED]`
- ❌ `[OUT_OF_SCOPE_2]`: `[WHY_NOT_INCLUDED]`
- ❌ `[OUT_OF_SCOPE_3]`: `[WHY_NOT_INCLUDED]`

**Rationale for Boundaries**: `[WHY_SCOPE_IS_DEFINED_THIS_WAY]`

### 3. Goals & Success Criteria

**Purpose**: Measurable objectives that define success

#### Primary Goals

| Goal | Success Metric | Target | Measurement Method | Owner Role |
|------|----------------|--------|-------------------|------------|
| `[GOAL_1]` | `[METRIC_NAME]` | `[TARGET_VALUE]` | `[HOW_MEASURED]` | `[ROLE]` |
| `[GOAL_2]` | `[METRIC_NAME]` | `[TARGET_VALUE]` | `[HOW_MEASURED]` | `[ROLE]` |
| `[GOAL_3]` | `[METRIC_NAME]` | `[TARGET_VALUE]` | `[HOW_MEASURED]` | `[ROLE]` |

#### Success Criteria (Must Have)
- ✅ `[CRITERION_1]`: `[SPECIFIC_MEASURABLE_REQUIREMENT]`
- ✅ `[CRITERION_2]`: `[SPECIFIC_MEASURABLE_REQUIREMENT]`
- ✅ `[CRITERION_3]`: `[SPECIFIC_MEASURABLE_REQUIREMENT]`

#### Definition of Done
```
Initiative is considered complete when:
1. [COMPLETION_CRITERION_1]
2. [COMPLETION_CRITERION_2]
3. [COMPLETION_CRITERION_3]
4. All primary goals achieved
5. Launch readiness review passed
```

### 4. Work Streams & Deliverables

**Purpose**: Major areas of work and what each will deliver

#### Work Stream 1: `[WORK_STREAM_NAME]`

**Objective**: `[WHAT_THIS_STREAM_DELIVERS]`

**Owner Role**: `[ROLE_RESPONSIBLE]` (not individual name)

**Key Deliverables**:
| Deliverable | Description | Due Date | Status | Dependencies |
|-------------|-------------|----------|--------|--------------|
| `[DELIVERABLE_1]` | `[DESCRIPTION]` | `[YYYY-MM-DD]` | `[STATUS]` | `[PREREQUISITES]` |
| `[DELIVERABLE_2]` | `[DESCRIPTION]` | `[YYYY-MM-DD]` | `[STATUS]` | `[PREREQUISITES]` |

**Success Metrics** (for this stream):
- `[METRIC_1]`: `[TARGET]`
- `[METRIC_2]`: `[TARGET]`

#### Work Stream 2: `[WORK_STREAM_NAME]`
(Repeat structure for each major work stream)

### 5. Timeline & Milestones

**Purpose**: Major checkpoints and overall timeline

#### Initiative Timeline

```
Phase 1: [PHASE_NAME] ([START] - [END])
├── Milestone: [MILESTONE_1] ([DATE])
├── Milestone: [MILESTONE_2] ([DATE])
└── Phase Complete: [COMPLETION_CRITERIA]

Phase 2: [PHASE_NAME] ([START] - [END])
├── Milestone: [MILESTONE_3] ([DATE])
├── Milestone: [MILESTONE_4] ([DATE])
└── Phase Complete: [COMPLETION_CRITERIA]

Phase 3: [PHASE_NAME] ([START] - [END])
├── Milestone: [MILESTONE_5] ([DATE])
└── Initiative Complete: [FINAL_MILESTONE] ([DATE])
```

#### Critical Path
```
[CRITICAL_ITEM_1] → [CRITICAL_ITEM_2] → [CRITICAL_ITEM_3] → Launch
```

**Buffer**: `[BUFFER_TIME]` built into timeline for risks and unknowns

### 6. Cross-Team Coordination

**Purpose**: How teams work together and decision-making process

#### Teams Involved

| Team | Role in Initiative | Key Responsibilities | Contact Point |
|------|-------------------|----------------------|---------------|
| `[TEAM_1]` | `[ROLE]` | `[RESPONSIBILITIES]` | `[SLACK_CHANNEL_OR_MEETING]` |
| `[TEAM_2]` | `[ROLE]` | `[RESPONSIBILITIES]` | `[SLACK_CHANNEL_OR_MEETING]` |
| `[TEAM_3]` | `[ROLE]` | `[RESPONSIBILITIES]` | `[SLACK_CHANNEL_OR_MEETING]` |

#### Governance & Decision-Making

**Steering Committee** (Strategic Decisions):
- **Composition**: `[ROLES_REPRESENTED]`
- **Meeting Cadence**: `[FREQUENCY]`
- **Decision Authority**: `[WHAT_THEY_DECIDE]`

**Working Group** (Tactical Execution):
- **Composition**: `[ROLES_REPRESENTED]`
- **Meeting Cadence**: `[FREQUENCY]`
- **Decision Authority**: `[WHAT_THEY_DECIDE]`

**Escalation Path**:
```
Team Level → Work Stream Lead → Initiative Lead → Steering Committee
```

**Decision Log** (Key Decisions Made):
| Date | Decision | Rationale | Decided By | Impact |
|------|----------|-----------|------------|--------|
| `[YYYY-MM-DD]` | `[DECISION]` | `[WHY]` | `[ROLE/GROUP]` | `[IMPACT]` |

### 7. Dependencies & Risks

**Purpose**: What could block or derail the initiative

#### External Dependencies

| Dependency | Owner | Status | Impact if Delayed | Mitigation |
|------------|-------|--------|-------------------|------------|
| `[DEPENDENCY_1]` | `[ROLE/TEAM]` | `[STATUS]` | `[IMPACT]` | `[MITIGATION_PLAN]` |
| `[DEPENDENCY_2]` | `[ROLE/TEAM]` | `[STATUS]` | `[IMPACT]` | `[MITIGATION_PLAN]` |

#### Risk Register

| Risk | Probability | Impact | Mitigation Strategy | Contingency Plan | Owner |
|------|-------------|--------|--------------------|--------------------|-------|
| `[RISK_1]` | `[L/M/H]` | `[L/M/H]` | `[PROACTIVE_MITIGATION]` | `[IF_IT_HAPPENS]` | `[ROLE]` |
| `[RISK_2]` | `[L/M/H]` | `[L/M/H]` | `[PROACTIVE_MITIGATION]` | `[IF_IT_HAPPENS]` | `[ROLE]` |

### 8. Communication & Status

**Purpose**: How progress is communicated

#### Communication Channels
- **Status Updates**: `[FREQUENCY]` via `[CHANNEL]`
- **Stakeholder Updates**: `[FREQUENCY]` via `[CHANNEL]`
- **Team Coordination**: `[SLACK/EMAIL/WIKI_LOCATION]`
- **Documentation**: `[CONFLUENCE/NOTION/WIKI_LINK]`

#### Status Dashboard (Current State)

**Overall Health**: `[GREEN/YELLOW/RED]`

**Current Phase**: `[PHASE_NAME]`

**Completion**: `[XX]`% complete

**Timeline Status**: `[ON_TRACK/AT_RISK/DELAYED]`

**Recent Wins**:
- ✅ `[RECENT_ACHIEVEMENT_1]`
- ✅ `[RECENT_ACHIEVEMENT_2]`

**Active Blockers**:
- 🚫 `[BLOCKER_1]`: `[MITIGATION_IN_PROGRESS]`
- 🚫 `[BLOCKER_2]`: `[MITIGATION_IN_PROGRESS]`

**Next Milestones**:
- `[NEXT_MILESTONE_1]`: `[DATE]`
- `[NEXT_MILESTONE_2]`: `[DATE]`

### 9. Resources & Budget

**Purpose**: What resources are allocated (use relative terms, not specifics)

#### Team Allocation
| Team | FTE Allocation | Duration |
|------|----------------|----------|
| `[TEAM_1]` | `[X FTE]` | `[TIME_PERIOD]` |
| `[TEAM_2]` | `[X FTE]` | `[TIME_PERIOD]` |

**Note**: Use relative terms (e.g., "2 FTE", "50% allocation") not individual names

#### Budget Considerations
- **Priority Level**: `[HIGH/MEDIUM/LOW]` company priority
- **Resource Constraints**: `[KNOWN_LIMITATIONS]`
- **Investment Justification**: `[WHY_RESOURCES_ALLOCATED]`

### 10. Lessons Learned & Retrospectives

**Purpose**: Capture learnings for future initiatives

#### What's Working Well
- ✅ `[SUCCESS_PATTERN_1]`
- ✅ `[SUCCESS_PATTERN_2]`

#### What Could Be Better
- ⚠️ `[IMPROVEMENT_AREA_1]`: `[WHAT_WE_ARE_DOING_ABOUT_IT]`
- ⚠️ `[IMPROVEMENT_AREA_2]`: `[WHAT_WE_ARE_DOING_ABOUT_IT]`

#### Key Learnings
1. **`[LEARNING_1]`**: `[DESCRIPTION_AND_APPLICATION]`
2. **`[LEARNING_2]`**: `[DESCRIPTION_AND_APPLICATION]`

## Validation Checklist

Before finalizing initiative overview skill, verify:

**Content Quality**:
- [ ] All `[PLACEHOLDERS]` replaced with actual values
- [ ] Zero PII (no names, emails, phone numbers - use roles instead)
- [ ] Zero business-confidential data (budget specifics, revenue targets)
- [ ] Goals are specific and measurable
- [ ] Success criteria are clear and testable

**Scope & Governance**:
- [ ] In-scope and out-of-scope clearly defined
- [ ] Decision-making authority documented
- [ ] Escalation paths clear
- [ ] Cross-team coordination defined

**Timeline & Risk**:
- [ ] Milestones have dates and owners (roles)
- [ ] Dependencies identified with mitigation
- [ ] Risks assessed with probabilities
- [ ] Critical path documented

**Metadata & Tracking**:
- [ ] `initiative-status` reflects current state
- [ ] `start-date` and `target-completion` set
- [ ] Last updated date is current
- [ ] `allowed-tools: []` set (initiative overview is read-only reference)
- [ ] Category and tags aid discovery

**Security & Scope**:
- [ ] File location matches scope (cross-team initiatives in `.claude/skills/shared/initiatives/`)
- [ ] No sensitive strategic information exposed
- [ ] Reviewed by initiative lead

## Usage Examples

**Creating New Initiative Overview Skill**:
```
User: "Create an initiative overview skill for the Pricing Innovation initiative"

Claude: [Loads this template skill, uses structure to create Pricing Innovation-specific overview]
```

**Coordination Check**:
```
User: "Are we coordinating with the payments team on flexible leasing?"

Claude: [Loads initiative overview skill, checks cross-team coordination section]
Response: "Yes, payments team is involved in Work Stream 2 (Technical Integration) with responsibility for payment processing hooks. Their contact point is #pricing-innovation-eng channel."
```

**Dependency Tracking**:
```
User: "What's blocking the custom rate cards feature?"

Claude: [Loads initiative overview skill, checks dependencies and blockers]
Response: "Custom rate cards has external dependency on billing system API update (owned by Platform team, status: In Progress). If delayed, impact is Q2 launch at risk. Mitigation: parallel development with mock API."
```

**Do NOT Use This Template For**:
- Single-team projects (use project skills instead)
- Product-specific work (use product context template)
- Technical specifications (use ground truth template)
- Completed initiatives (archive or mark as historical reference)

## Maintenance & Freshness

**Update Triggers**:
- Weekly during active initiative (status updates)
- After major milestones
- When decisions made by steering committee
- When risks or blockers change
- Phase transitions

**Review Cadence**:
- **Status/Blockers**: Weekly
- **Risks/Dependencies**: Bi-weekly
- **Goals/Timeline**: Monthly
- **Scope/Charter**: Only on major changes

**Archival Process**:
When initiative completes:
1. Update `initiative-status` to `COMPLETED`
2. Add final retrospective section
3. Document final metrics vs. targets
4. Move to historical reference location
5. Link to any ongoing work that continues

**Version Control**:
- Update `last-updated` date frequently during active phase
- Track major decisions in git commits
- Reference milestone completions in commit messages

---

**Template Source**: Phase 2 requirements + program management best practices
**Template Version**: 1.0.0
**Last Updated**: 2025-10-20
**Validation**: Ready for Phase 2 implementation
