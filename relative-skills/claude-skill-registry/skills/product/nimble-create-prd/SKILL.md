---
name: nimble-create-prd
description: Guide for creating Product Requirements Documents (PRDs) following Nimble's standard. Use when creating new PRDs, defining requirements, documenting features, or planning product releases. Covers structure, AI-friendly formatting, requirement IDs, and all PRD sections.
---

# Nimble PRD Creation

## Documentation Source

Reference Nimble's Compass documentation. Fetch the latest from:
- **PRD Standard**: https://nimblehq.co/compass/product/technical-documentation/product-requirements-document/
- **PRD Example**: https://nimblehq.co/compass/product/technical-documentation/product-requirements-document-example/

## Core Principles

1. **Outcome Over Process**: State what success looks like, not how to do the work
2. **Context First, Details Second**: Lead with the problem and why it matters
3. **Structured for Parsing**: Use consistent sections and explicit logic that both AI and humans can understand
4. **Minimal but Complete**: Include everything needed to build, exclude everything else
5. **Decisions, Not Debates**: Document what we're doing and why

## PRD Structure

Follow this structure for every PRD:

### 1. Overview

**PRD ID** (Required)
- Format: `UPPERCASE-WITH-HYPHENS`
- Keep it concise (2-4 words max)
- Make it descriptive of the feature/domain
- Examples: `AUTH-PWD-RESET`, `CHECKOUT-FLOW`, `ADMIN-DASH`, `USER-PROFILE`
- Used as prefix for all requirements to ensure global uniqueness

**What are we building?**
- One clear sentence
- No jargon, no hedging

**Why does it matter?**
- The business or user problem this solves
- Keep it to 2-3 sentences

**Success looks like:**
- Concrete, measurable outcomes
- Examples: "Users complete onboarding in under 2 minutes" or "API latency drops below 200ms"

### 2. Context

**Current State**
- What exists today
- What's broken, missing, or limiting

**User/Business Problem**
- Who is affected and how
- Use real scenarios, not hypotheticals

**Constraints**
- Technical, timeline, resource, or business limitations

**Assumptions**
- What we're assuming to be true
- Call these out explicitly - if they're wrong, the plan changes

### 3. Proposed Solution

**High-Level Approach**
- What we're building and how it works
- Description of the system's behavior, not a detailed spec

**Key Components**
- Break solution into logical parts
- Examples: "User authentication flow," "Notification engine," "Admin dashboard"

**User Flow** (if applicable)
- Step-by-step description of user interaction
- Plain language for simple flows
- **MUST use Mermaid diagrams for complex flows with branching logic** (ensures AI readability)

**Technical Approach** (if relevant)
- High-level tech decisions: architecture, integrations, data models, APIs
- Just enough to orient the team, not exhaustive

**UI/UX Details** (if applicable)
- **Wireframes/Mockups**: Link to Figma, Sketch, or design files
- **Key Screens**: List of screens/views needed with brief descriptions

### 4. Scope

**In Scope**
- What we're delivering in this release
- Be explicit

**Out of Scope**
- What we're NOT doing and why
- This prevents scope drift

### 5. Requirements

**Functional Requirements**

Table format with columns:
- **ID**: `[PRD-ID]-FR-[NUMBER]` (e.g., `AUTH-PWD-RESET-FR-001`)
- **Requirement**: What must be built
- **Acceptance Criteria**: Bullet list starting with action verbs (Accept, Validate, Display, etc.)
- **Priority**: Must-have / Should-have / Nice-to-have
- **User Impact**: How this benefits users

**Priority Levels:**
- **Must-have**: Core functionality, blocks release without it
- **Should-have**: Important but can be deferred if needed
- **Nice-to-have**: Desirable but not critical

**Non-Functional Requirements**

Table format with columns:
- **ID**: `[PRD-ID]-NFR-[NUMBER]` (e.g., `AUTH-PWD-RESET-NFR-001`)
- **Requirement**: Performance, security, compliance requirements
- **Acceptance Criteria**: How to verify/test (use action verbs)
- **Priority**: Must-have / Should-have / Nice-to-have

**CRUD Operations** (if applicable)

Table showing which roles can Create/Read/Update/Delete each entity:
- Entity name
- Create / Read / Update / Delete permissions
- Notes about special handling

**Edge Cases**

Table format:
- **Scenario**: What unusual situation might occur
- **Expected Behavior**: How system should handle it (use action verbs)
- **Priority**: Must-have / Should-have

### 6. Roles & Permissions (if applicable)

Table showing which roles can perform which actions:
- Action
- Guest / User / Admin / Other roles
- Notes about special conditions

### 7. Dependencies

Table format:
- **Dependency**: What's needed
- **Type**: Technical / External / Infrastructure
- **Owner**: Who's responsible
- **Status**: Complete / In Progress / Pending

## AI-Friendly Formatting Rules

To maximize AI effectiveness when augmenting story creation:

1. **Define unique PRD ID** at the top of every document in the Overview section
2. **Use tables** for requirements and dependencies
3. **MUST use Mermaid diagrams** for all visual diagrams and flows (images/screenshots are not AI-readable)
4. **Label requirements with IDs** using consistent format to ensure global uniqueness
5. **Write acceptance criteria as bullet lists** within table cells, **starting with verbs**
6. **Use "must/should/may"** language in priority column for clear signal
7. **Keep one requirement per row** - don't combine multiple requirements
8. **Use consistent column headers** across all PRDs (AI learns the pattern)
9. **Separate user impact from technical detail** - AI can route these to appropriate story fields
10. **Include explicit scope boundaries** in the Scope section to prevent hallucinated features

## Working with This Skill

### Step 1: Gather Context

Before creating the PRD, understand:
- What problem are we solving?
- Who is affected?
- What are the constraints?
- What does success look like?

### Step 2: Define PRD ID

Create a unique, descriptive PRD ID:
- Use 2-4 words
- UPPERCASE with hyphens
- Describes the feature/domain
- Will be used as prefix for all requirements

### Step 3: Start with Overview & Context

Write these sections first:
- What we're building (one sentence)
- Why it matters (2-3 sentences)
- Success metrics (concrete outcomes)
- Current state and problem
- Constraints and assumptions

This ensures the PRD is grounded in real user/business needs.

### Step 4: Design the Solution

Document:
- High-level approach
- Key components
- User flow (with Mermaid for complex flows)
- Technical approach (high-level only)
- UI/UX details (wireframes + key screens)

### Step 5: Define Scope Boundaries

Be explicit about:
- What IS in scope for this release
- What is NOT in scope and why

### Step 6: Write Requirements

For each requirement:
1. Assign unique ID with PRD prefix
2. Write clear requirement description
3. List acceptance criteria starting with action verbs
4. Set priority level
5. Explain user impact (for FRs)

Don't forget:
- Non-functional requirements (performance, security, compliance)
- CRUD operations table (if applicable)
- Edge cases with expected behaviors

### Step 7: Document Roles, Permissions, Dependencies

Complete the PRD with:
- Roles & Permissions table (if applicable)
- Dependencies table with owners and status

### Step 8: Quality Check

Before finalizing, verify:
- [ ] PRD ID is defined and used consistently in all requirement IDs
- [ ] "What/Why/Success" clearly stated in Overview
- [ ] All requirements have unique IDs with PRD prefix
- [ ] Acceptance criteria start with action verbs
- [ ] Complex flows use Mermaid diagrams (not images)
- [ ] UI/UX details include wireframe links and key screens
- [ ] Scope boundaries are explicit
- [ ] Priority levels are assigned to all requirements
- [ ] Edge cases are documented
- [ ] Dependencies are listed with owners

## Example Requirement Formats

### Good Functional Requirement

| ID | Requirement | Acceptance Criteria | Priority | User Impact |
|----|-------------|---------------------|----------|-------------|
| AUTH-PWD-RESET-FR-001 | Users can request password reset via email | • Accept email input in form<br>• Validate email format<br>• Display success message regardless of email existence<br>• Send email within 30s if account exists | Must-have | Enables self-service account recovery |

**Why this is good:**
- Unique ID with PRD prefix
- Clear requirement description
- Action verbs in acceptance criteria (Accept, Validate, Display, Send)
- Priority defined
- User impact clearly stated

### Good Non-Functional Requirement

| ID | Requirement | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| AUTH-PWD-RESET-NFR-001 | API response time <200ms at p95 | Verify performance with load test of 1000 concurrent users | Must-have |

**Why this is good:**
- Unique ID with PRD prefix
- Measurable requirement
- Action verb in criteria (Verify)
- Testable

### Good Edge Case

| Scenario | Expected Behavior | Priority |
|----------|-------------------|----------|
| Non-existent email provided | Display success message (don't reveal account status) | Must-have |

**Why this is good:**
- Specific scenario
- Clear expected behavior with action verb
- Security consideration documented
- Priority assigned

## Common Pitfalls to Avoid

1. **Forgetting PRD ID**: Every PRD must have a unique ID in Overview section
2. **Inconsistent requirement IDs**: All requirements must use `[PRD-ID]-FR-###` or `[PRD-ID]-NFR-###` format
3. **Acceptance criteria without verbs**: "Form accepts" → "Accept email in form"
4. **Using images instead of Mermaid**: AI cannot parse images; always use Mermaid for flows
5. **Vague success metrics**: "Better performance" → "95% of users complete flow in <2 minutes"
6. **Missing scope boundaries**: Always document what's out of scope to prevent drift
7. **Combining multiple requirements**: Keep one requirement per table row
8. **No user impact**: For FRs, always explain how it benefits users
9. **Missing edge cases**: Document how system handles unusual scenarios
10. **No UI/UX details**: Include wireframe links and key screens for frontend work

## Tips for Success

1. **Always fetch latest documentation**: The PRD standard may have been updated since this skill was created
2. **Start with Why**: If you can't articulate user problem and business value, the PRD isn't ready
3. **Use action verbs consistently**: Accept, Validate, Display, Send, Verify, etc.
4. **Link to designs and specs**: Don't make developers hunt for information
5. **Keep requirements atomic**: One requirement = one testable outcome
6. **Document edge cases early**: They're often discovered during implementation; capture them upfront
7. **Get feedback before finalizing**: Review with engineering and design teams
8. **Think about AI consumption**: Structure and consistency help AI generate accurate stories

Remember: A good PRD removes ambiguity. It gives engineers what they need to build, designers what they need to create, and AI what it needs to augment PM work with clean, actionable output.
