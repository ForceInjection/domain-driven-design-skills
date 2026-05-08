---
name: prd
description: "Guides product managers through creating comprehensive PRDs via structured conversation. Adapts depth and format based on project complexity—from quick feature specs to full product requirements with compliance considerations."
---

# PRD Creation Guide

## Purpose

Help product managers create implementation-ready Product Requirements Documents through structured conversation. This skill adapts its approach based on project complexity, regulatory context, and organizational needs.

## When to Activate

Respond to requests like:
- "Help me create a PRD for..."
- "I need to write requirements for..."
- "Let's spec out..."
- "Create product requirements for..."
- Any request for product specifications or requirements documentation

## Core Methodology

### Step 1: Assess Before Acting

Before generating any PRD content, gather essential context through targeted questions. Never assume—ask.

**Required Context (always gather):**
- What is the product/feature? (Get specifics, not just the name)
- Who are the target users? (Roles, not just "users")
- What problem does this solve? (Business justification)
- What does success look like? (Measurable outcomes)

**Conditional Context (gather when relevant):**
- Existing system constraints (for features added to existing products)
- Compliance requirements (for regulated industries: healthcare, finance, government)
- Integration dependencies (when connecting to other systems)
- Timeline pressures (affects scope recommendations)

### Step 2: Determine Project Scope

Based on gathered context, classify the project:

**Lightweight Spec** — Use for:
- Single feature additions
- Well-understood problem space
- Limited stakeholder complexity
- Internal tools with clear requirements

**Standard PRD** — Use for:
- New products or major features
- Multiple user personas
- Cross-functional dependencies
- External-facing functionality

**Comprehensive PRD** — Use for:
- Regulated industries (healthcare, finance, government)
- Mission-critical systems
- Multi-team coordination required
- Significant compliance or security requirements

### Step 3: Generate Appropriate Structure

Adapt the PRD structure to match project scope:

---

#### Lightweight Spec Structure

```markdown
# [Feature Name] Specification

## Overview
Brief description of what this feature does and why it matters.

## User Story
As a [user type], I want [capability] so that [benefit].

## Requirements
### Functional Requirements
- FR-1: [Requirement]
- FR-2: [Requirement]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes
Any implementation considerations or constraints.

## Out of Scope
What this feature explicitly does NOT include.
```

---

#### Standard PRD Structure

```markdown
# [Product/Feature Name] PRD

## Executive Summary
One paragraph: what, why, and expected impact.

## Problem Statement
- Current state and pain points
- Who is affected
- Cost of inaction

## Goals & Success Metrics
| Goal | Metric | Target |
|------|--------|--------|
| [Goal 1] | [How measured] | [Target value] |

## User Personas
### Primary: [Persona Name]
- Role/Context
- Goals
- Pain points

### Secondary: [Persona Name]
- Role/Context
- Goals
- Pain points

## Requirements

### Functional Requirements
Organized by epic or capability area:

**[Epic 1 Name]**
- FR-1.1: [Requirement] | Priority: [Must/Should/Could]
- FR-1.2: [Requirement] | Priority: [Must/Should/Could]

**[Epic 2 Name]**
- FR-2.1: [Requirement] | Priority: [Must/Should/Could]

### Non-Functional Requirements
- Performance: [Specific targets]
- Security: [Requirements]
- Scalability: [Expectations]
- Accessibility: [Standards to meet]

## User Flows
Describe key user journeys through the system.

## Dependencies & Constraints
- Technical dependencies
- Business constraints
- Timeline considerations

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

## Out of Scope
Explicit boundaries for this version.

## Open Questions
Items requiring further discussion or decision.
```

---

#### Comprehensive PRD Structure

Includes everything in Standard PRD, plus:

```markdown
## Compliance & Regulatory
- Applicable regulations (HIPAA, GDPR, SOC2, FedRAMP, FISMA, etc.)
- Compliance requirements mapped to features
- Audit and reporting needs
- Data residency requirements

## Security Requirements
- Authentication/Authorization requirements
- Data classification and handling
- Encryption requirements (at rest, in transit)
- Audit logging requirements

## Change Management
- Impact on existing users/workflows
- Migration strategy
- Training requirements
- Rollback plan

## Stakeholder Sign-off
| Stakeholder | Role | Approval Status | Date |
|-------------|------|-----------------|------|

## Appendices
- Detailed technical specifications
- Compliance mapping documents
- Integration specifications
```

---

### Step 4: Validate Requirements Quality

Before finalizing, verify each requirement against these criteria:

**Clarity Check:**
- Is it unambiguous? (One interpretation only)
- Is it testable? (Clear pass/fail criteria)
- Is it atomic? (One requirement per statement)

**Completeness Check:**
- Are all user personas addressed?
- Are error states and edge cases covered?
- Are non-functional requirements specified?

**Feasibility Check:**
- Has technical feasibility been considered?
- Are dependencies identified?
- Is the scope realistic for the timeline?

### Step 5: Identify Gaps and Follow-ups

Conclude PRD generation by explicitly noting:
- Open questions requiring stakeholder input
- Areas needing technical feasibility validation
- Assumptions that should be verified
- Recommended next steps

## Adaptation Guidelines

### For Government/B2G Projects
- Always use Comprehensive structure
- Include compliance section (FISMA, FedRAMP, Section 508)
- Add change management section (government projects have strict change control)
- Include explicit traceability (requirement IDs that map to contract deliverables)
- Consider ATO (Authority to Operate) implications

### For Startup/MVP Projects
- Use Lightweight or Standard structure
- Emphasize learning metrics over vanity metrics
- Include explicit "What we're NOT building" section
- Focus on core value proposition, defer nice-to-haves

### For Enterprise Features
- Use Standard or Comprehensive structure
- Heavy emphasis on integration requirements
- Include migration and backward compatibility
- Address multi-tenant considerations if applicable

### For API/Technical Products
- Include API contract specifications
- Define rate limiting, authentication, versioning
- Specify error response formats
- Include developer experience requirements

## Interaction Style

### Do:
- Ask clarifying questions before generating content
- Challenge vague requirements ("users" → which users?)
- Suggest scope reductions when complexity is high
- Flag risks and assumptions explicitly
- Offer to expand or drill into specific sections

### Don't:
- Generate a full PRD without gathering context first
- Assume compliance requirements—always ask
- Include implementation details in requirements
- Let scope creep go unaddressed
- Skip the "Out of Scope" section

## Example Interaction Flow

**User:** "Help me create a PRD for a dashboard"

**Response approach:**
1. Acknowledge the request
2. Ask: What kind of dashboard? Who uses it? What decisions does it support? Is this for an existing product or new? Any compliance considerations?
3. Based on answers, propose appropriate structure
4. Generate PRD iteratively, checking alignment
5. Conclude with open questions and next steps

## Output Formats

When generating the final PRD:
- Default to markdown format (copy-paste friendly)
- Offer to create as downloadable document if requested
- For complex PRDs, offer to break into multiple focused documents
