---
name: stakeholder-discovery-template
description: Generic stakeholder discovery template for creating new project-specific stakeholder skills. Auto-invoke when user requests stakeholder skill creation, stakeholder analysis framework, or team context templates. Do NOT load during actual stakeholder discussions (use project-specific skills instead).
allowed-tools: [Grep]
version: 1.0.0
category: Templates
tags: [template, stakeholder-discovery, skill-creation]
last-updated: 2025-10-19
---

# Stakeholder Discovery Template

## Purpose
This template guides the creation of project-specific stakeholder skills. Replace all `[PLACEHOLDER]` values with actual project information.

## SKILL.md Frontmatter Template

```yaml
---
name: [project]-[domain]-stakeholders
description: Stakeholder context for [PROJECT_NAME] [DOMAIN] when discussing [USE_CASE_1], [USE_CASE_2], or [USE_CASE_3]. Auto-invoke when user mentions [PROJECT_TRIGGER], [DOMAIN_TRIGGER], or [TEAM_TRIGGER]. Do NOT load for general [DOMAIN] discussions unrelated to [PROJECT_NAME].
allowed-tools: []
version: 1.0.0
category: Stakeholders
tags: [[project], [domain], [key-theme-1], [key-theme-2]]
last-updated: [YYYY-MM-DD]
---
```

**Description Engineering Guidance**:

✅ **DO** include specific trigger terms:
- Project name (exact capitalization users will mention)
- Domain keywords (fintech, UX research, payment processing)
- Team names users will reference

❌ **DON'T** use generic descriptions:
- "Provides stakeholder information" (too broad)
- "Use when discussing stakeholders" (will load too often)
- No explicit project scope (will contaminate other projects)

**Example Good Description**:
```
Stakeholder context for Phoenix UX research project when discussing user testing, research synthesis, or design validation. Auto-invoke when user mentions Phoenix, UX research stakeholders, or design team collaboration. Do NOT load for general UX discussions unrelated to Phoenix.
```

## Skill Content Structure Template

### `[TEAM_NAME]` Team

#### Team Objectives
- `[PRIMARY_OBJECTIVE_1]` (quantified if possible: >95% accuracy, <100ms latency)
- `[PRIMARY_OBJECTIVE_2]`
- `[PRIMARY_OBJECTIVE_3]`

#### Key Stakeholders

**`[ROLE_TITLE]`** (Use role, not individual name - NO PII)
- **Decision Authority**: `[SPECIFIC_DECISIONS_THIS_ROLE_MAKES]`
- **Communication Preference**: `[PREFERRED_CHANNELS_AND_STYLE]`
  - Examples: "Data-driven with A/B test results", "Formal written proposals", "Technical RFCs with diagrams"
- **Success Metrics**: `[QUANTIFIABLE_METRICS_THIS_ROLE_CARES_ABOUT]`
  - Format: "[Metric name] [operator][value]" (e.g., "Fraud detection rate >95%")
- **Pain Points**:
  - `[CURRENT_CHALLENGE_1]` (quantified if possible)
  - `[CURRENT_CHALLENGE_2]`
  - `[CURRENT_CHALLENGE_3]`

#### Decision-Making Patterns
- **`[DECISION_TYPE]`**: `[APPROVAL_PROCESS_AND_CRITERIA]`
  - Example: "Rule Changes: Requires statistical significance (p<0.05) with 2-week A/B test"
- **Review Cycle**: `[FREQUENCY_AND_FORMAT]`
  - Example: "Weekly sprint reviews for non-critical updates"
- **Escalation Protocols**: `[WHEN_AND_HOW_TO_ESCALATE]`
  - Example: "Emergency fraud spike triggers immediate team call"
- **Approval Chain**: `[ROLE_1]` → `[ROLE_2]` → `[ROLE_3]` (for `[DECISION_SCOPE]`)

#### Communication Channels (Optional)
- **Primary**: `[SLACK_CHANNEL_OR_EMAIL_GROUP]`
- **Meetings**: `[RECURRING_MEETING_SCHEDULE]`
- **Documentation**: `[CONFLUENCE_WIKI_OR_DOC_LOCATION]`
- **Escalations**: `[EMERGENCY_CONTACT_METHOD]` (NO personal phone numbers)

## Validation Checklist

Before finalizing skill, verify:

**Content Quality**:
- [ ] All `[PLACEHOLDERS]` replaced with actual values
- [ ] Zero PII (no names, emails, phone numbers, personal identifiers)
- [ ] Zero business-confidential metrics (use relative: ">95%" not "$5M revenue")
- [ ] Quantified metrics where possible (not "high accuracy", say ">95%")

**Description Engineering**:
- [ ] Description includes specific WHEN triggers (project name, domain keywords)
- [ ] Description includes explicit WHEN NOT boundaries
- [ ] Tested with positive queries (should load): `[LIST_TEST_QUERIES]`
- [ ] Tested with negative queries (should NOT load): `[LIST_TEST_QUERIES]`

**Metadata & Tracking**:
- [ ] Ground truth source documented with date
- [ ] Validation date included
- [ ] Next review date specified (recommend quarterly)
- [ ] `allowed-tools: []` set (stakeholder skills are read-only reference)
- [ ] Category and tags aid discovery

**Security & Scope**:
- [ ] File location matches scope (project skills in `.claude/skills/projects/[name]/`)
- [ ] No personal preferences mixed with stakeholder context
- [ ] Reviewed by at least one other team member (if team skill)

## Usage Examples

**Creating New Stakeholder Skill**:
```
User: "Create a stakeholder skill for the Phoenix UX research team"

Claude: [Loads this template skill, uses structure to create Phoenix-specific skill]
```

**Finding Template for Reference**:
```
User: "What's the standard format for stakeholder skills?"

Claude: [Loads this template skill, shows structure and best practices]
```

**Do NOT Use This Template For**:
- Actual stakeholder discussions (use project-specific skills instead)
- Ground truth documentation (use ground-truth template)
- Product context (use product skill template)

---

**Template Source**: Research report + eval committee consensus
**Template Version**: 1.0.0
**Last Updated**: 2025-10-19
**Validation**: Ready for Week 1 PoC testing
