---
name: dev-swarm-prd
description: Create comprehensive Product Requirements Document (PRD) defining product behavior, functional and non-functional requirements. Use when user asks to create PRD, write requirements, or start Stage 4 after MVP definition.
---

# AI Builder - Product Requirements Document (PRD)

This skill creates/updates the Product Requirements Document (PRD) that locks down product behavior and requirements without specifying the technical implementation or tech stack.

## When to Use This Skill

- User asks to "create PRD" or "write PRD"
- User requests to start Stage 4 or the next stage after MVP definition
- User wants to define detailed product requirements
- User wants to document functional and non-functional requirements
- User needs to expand MVP scope into full product specification

## Prerequisites

This skill requires **03-mvp** to be completed. The PRD will expand the MVP scope into a comprehensive product specification with detailed requirements.

## Your Roles in This Skill

- **Product Manager**: Lead PRD creation with detailed feature specifications. Refine and expand user stories from MVP into complete requirements. Define acceptance criteria for each feature. Ensure alignment with business goals and user needs. Create product overview, goals, and user journeys.
- **UX Designer**: Provide user experience perspective on requirements. Define user journeys and interaction expectations. Ensure requirements support good user experience. Contribute to functional requirements from UX perspective.
- **Tech Manager (Architect)**: Review requirements for technical feasibility. Define non-functional requirements (performance, security, scalability). Identify technical constraints and dependencies. Ensure requirements are implementable without over-specifying technology.

## Role Communication

As an expert in your assigned roles, you must announce your actions before performing them using the following format:

As a {Role} [and {Role}, ...], I will {action description}

This communication pattern ensures transparency and allows for human-in-the-loop oversight at key decision points.
## Instructions

Follow these steps in order:

### Step 0: Verify Prerequisites and Gather Context

1. **Check if `03-mvp/` folder exists (mandatory):**
   - If NOT found: Inform user they need to define MVP first, then STOP
   - If found: Read all files to understand:
     - MVP scope and P0 features
     - Out-of-scope items (P1/P2 features)
     - Success metrics
     - Target users

2. **Check if `02-personas/` folder exists (mandatory):**
   - If NOT found: Inform user they need personas first, then STOP
   - If found: Read to understand:
     - User personas
     - All user stories (P0/P1/P2)
     - User needs and pain points

3. **Check if `00-init-ideas/` folder exists (recommended):**
   - If found: Read to understand:
     - Problem statement
     - Value proposition
     - Owner requirements
     - Cost budget (to understand constraints for this stage)

4. **Check if `01-market-research/` folder exists (optional):**
   - If found: Read to understand:
     - Market context
     - Competitive landscape
     - Validation findings

5. **Check if this stage should be skipped:**
   - Check if `04-prd/SKIP.md` exists
   - **If SKIP.md exists:**
     - Read SKIP.md to understand why this stage was skipped
     - Inform the user: "Stage 4 (prd) is marked as SKIP because [reason from SKIP.md]"
     - Ask the user: "Would you like to proceed to the next stage (ux)?"
     - **If user says yes:**
       - Exit this skill and inform them to run the next stage skill
     - **If user says no:**
       - Ask if they want to proceed with PRD anyway
       - If yes, delete SKIP.md and continue with this skill
       - If no, exit the skill

6. **Check if `04-prd/` folder exists:**
   - If exists: Read all existing files to understand current PRD state
   - If NOT exists: Will create new structure

7. **If README.md exists:** Check whether it requires diagrams. If it does,
   follow `dev-swarm/docs/mermaid-diagram-guide.md` and use the
   `dev-swarm-mermaid` skill to render outputs.

8. Proceed to Step 1 with gathered context

### Step 1: Refine Design Requirements in README and Get Approval

**CRITICAL: Create/update README.md first based on previous stage results, get user approval, then create other docs.**

1. **Analyze information from previous stages:**
   - Read `03-mvp/` to understand MVP scope and features
   - Read `02-personas/` to understand user stories (P0/P1/P2)
   - Read `00-init-ideas/` to understand problem statement and value proposition
   - Read `01-market-research/` (if exists) to understand market context
   - Consider cost-budget constraints for this stage

2. **Create or update 04-prd/README.md with refined requirements:**
   - List deliverables explicitly in README (typical: prd.md, functional-requirements.md, non-functional-requirements.md, out-of-scope.md)
   - **Stage overview and objectives** (based on previous stage context)
   - **Owners:** Product Manager (lead), UX Designer, Tech Manager
   - **Diagrams (if required by project init):**
     - Reference `dev-swarm/docs/mermaid-diagram-guide.md`
     - Include `diagram/` deliverables when needed
   - **What PRD will include:**
     - Product overview, goals, and user journeys
     - Functional requirements (based on user stories)
     - Non-functional requirements (performance, security, scalability)
     - Out-of-scope items
   - **Methodology:**
     - How requirements will be defined (from MVP + all user stories)
     - How functional requirements will be structured
   - **Deliverables planned:**
     - List of files that will be created (prd.md, functional-requirements.md, etc.)
   - **Budget allocation for this stage** (from cost-budget.md)
   - **Status:** In Progress (update to "Completed" after implementation)

3. **Present README to user:**
   - Show the PRD approach and what will be documented
   - Show what documentation files will be created
   - Explain how it aligns with previous stages
   - Ask: "Does this PRD plan look good? Should I proceed with creating comprehensive product requirements?"

4. **Wait for user approval:**
   - **If user says yes:** Proceed to Step 2
   - **If user says no:**
     - Ask what needs to be changed
     - Update README based on feedback
     - Ask for approval again

### Step 2: Create/Update PRD Structure

**Only after user approves the README:**

1. **Create files as specified in the approved README.md:**

   **IMPORTANT:** The file structure below is a SAMPLE only. The actual files you create must follow what was approved in the README.md in Step 1.

   **Typical structure (example):**
   ```
   04-prd/
   ├── README.md (already created and approved in Step 1)
   ├── prd.md (if specified in README)
   ├── functional-requirements.md (if specified in README)
   ├── non-functional-requirements.md (if specified in README)
   └── out-of-scope.md (if specified in README)
   ```

   **Create only the files listed in the README's "Deliverables planned" section.**

### Step 3: Create/Update PRD Documentation

**IMPORTANT: Only create PRD documentation after README is approved in Step 1.**

**NOTE:** The content structure below provides GUIDELINES for typical PRD documentation. Adapt based on the approved README and project needs.

**prd.md (if specified in README - Main Product Requirements Document):**

This is the core PRD document covering product overview, goals, and user journeys:

1. **Product Overview:**
   - Product name and tagline
   - Product vision (what is this product?)
   - Problem statement (recap from 00-init-ideas)
   - Solution overview (how does this product solve the problem?)
   - Target market and users

2. **Product Goals:**
   - **Business Goals:**
     - Revenue targets or business model
     - Market positioning
     - Competitive differentiation
     - Strategic objectives

   - **User Goals:**
     - What users want to accomplish
     - User needs being addressed
     - User pain points being solved

   - **Product Goals:**
     - Activation goals
     - Engagement goals
     - Retention goals
     - Growth goals

3. **Target Users:**
   - Primary persona (link to 02-personas/persona-primary.md)
   - Secondary persona if applicable (link to 02-personas/persona-secondary.md)
   - User segments and characteristics
   - User assumptions and constraints

4. **User Journeys:**
   - **Critical User Journeys:**
     - End-to-end journey for primary persona
     - Key touchpoints and interactions
     - Entry points and exit points
     - Success states and failure states

   - **Secondary User Journeys:**
     - Additional important flows
     - Edge case journeys

5. **MVP Alignment:**
   - How this PRD builds on the MVP (link to 03-mvp/)
   - What's included from MVP scope
   - What's being added beyond MVP (P1/P2 features)
   - Phasing plan (what ships when)

6. **Feature Overview:**
   - High-level feature list organized by category
   - Feature prioritization (P0/P1/P2)
   - Dependencies between features
   - Feature roadmap (MVP vs. v1.0 vs. future)

**functional-requirements.md:**

Define what the product must do (behaviors, not implementation):

1. **Requirements Organization:**
   - Group requirements by feature area
   - Use consistent numbering (FR-001, FR-002, etc.)
   - Link requirements to user stories from 02-personas

2. **For Each Requirement:**

   **Format:**
   ```
   ### FR-XXX: [Requirement Title]

   **User Story:** As a [persona], I want [capability], so that [benefit]
   (Link to original user story in 02-personas/user-stories.md)

   **Description:**
   Detailed description of what the product must do

   **Behavior:**
   - Specific behavior 1
   - Specific behavior 2
   - Specific behavior 3

   **Acceptance Criteria:**
   - [ ] Criterion 1 (testable condition)
   - [ ] Criterion 2 (testable condition)
   - [ ] Criterion 3 (testable condition)

   **Priority:** P0 / P1 / P2

   **Dependencies:** [Other requirements this depends on]

   **Notes:**
   - Additional context
   - Edge cases to consider
   - Related features
   ```

3. **Requirement Categories:**

   Organize requirements by functional area, for example:

   - **Authentication & Authorization:**
     - User registration
     - Login/logout
     - Password reset
     - Session management
     - Permission controls

   - **Core Features (from MVP):**
     - List each P0 feature from MVP as detailed requirements
     - Expand with specific behaviors and edge cases

   - **Additional Features (P1/P2):**
     - Enhanced features beyond MVP
     - Nice-to-have capabilities

   - **User Profile & Settings:**
     - Profile management
     - User preferences
     - Account settings

   - **Data Management:**
     - Data creation
     - Data reading/viewing
     - Data updating
     - Data deletion
     - Data validation

   - **Notifications & Communications:**
     - Email notifications
     - In-app notifications
     - Push notifications (if applicable)

   - **Search & Discovery:**
     - Search functionality
     - Filtering and sorting
     - Navigation

4. **Cross-Cutting Requirements:**
   - Error handling and error messages
   - Loading states and feedback
   - Empty states
   - Accessibility requirements (WCAG 2.1 compliance)
   - Internationalization (i18n) if needed
   - Mobile responsiveness

**non-functional-requirements.md:**

Define quality attributes and constraints:

1. **Performance Requirements:**
   - **Response Time:**
     - Page load time targets (e.g., "< 2 seconds for 90th percentile")
     - API response time targets (e.g., "< 200ms for 95% of requests")
     - Time to interactive (TTI) targets

   - **Throughput:**
     - Concurrent user capacity (e.g., "support 10,000 concurrent users")
     - Transactions per second (TPS) targets
     - Request handling capacity

   - **Resource Usage:**
     - Browser memory limits
     - Bundle size targets (e.g., "initial JS bundle < 200KB gzipped")
     - Database query performance targets

2. **Scalability Requirements:**
   - Expected user growth trajectory
   - Peak load scenarios
   - Data growth projections
   - Scaling strategy (horizontal vs. vertical)
   - Geographic distribution needs

3. **Reliability & Availability:**
   - Uptime targets (e.g., "99.9% uptime")
   - Maximum tolerable downtime
   - Data backup and recovery requirements
   - Disaster recovery objectives (RTO, RPO)
   - Fault tolerance needs

4. **Security Requirements:**
   - **Authentication & Authorization:**
     - Authentication methods (OAuth, JWT, etc. - specify approach, not implementation)
     - Authorization model (RBAC, ABAC, etc.)
     - Session management requirements

   - **Data Security:**
     - Data encryption requirements (at rest and in transit)
     - Sensitive data handling (PII, payment info, etc.)
     - Data privacy requirements

   - **Security Controls:**
     - Input validation and sanitization
     - Protection against common vulnerabilities (XSS, CSRF, SQL injection, etc.)
     - Rate limiting and DDoS protection
     - Audit logging requirements

5. **Compliance Requirements:**
   - Regulatory compliance (GDPR, CCPA, HIPAA, etc.)
   - Industry standards (PCI-DSS, SOC 2, etc.)
   - Legal requirements (Terms of Service, Privacy Policy)
   - Data residency requirements
   - Cookie consent and tracking requirements

6. **Usability Requirements:**
   - Browser compatibility (which browsers and versions?)
   - Device compatibility (desktop, tablet, mobile)
   - Screen size support
   - Accessibility standards (WCAG 2.1 Level AA)
   - Keyboard navigation support
   - Screen reader compatibility

7. **Maintainability Requirements:**
   - Code documentation standards
   - Logging and monitoring requirements
   - Error tracking and reporting
   - Debugging capabilities
   - Update and deployment constraints

8. **Compatibility Requirements:**
   - Third-party service integrations
   - API compatibility requirements
   - Data format compatibility
   - Legacy system compatibility (if applicable)

**out-of-scope.md:**

Explicitly define what is NOT included in this PRD:

1. **Features Explicitly Excluded:**
   - Features that were considered but rejected
   - Features that are common in competitors but not needed
   - Features that might be requested but are out of scope
   - Future features that are definitely post-v1.0

2. **Platform Exclusions:**
   - Platforms not supported (e.g., "no native mobile apps in v1.0")
   - Browsers not supported (e.g., "no IE11 support")
   - Devices not supported

3. **Integration Exclusions:**
   - Third-party integrations deferred to later
   - External services not included in v1.0

4. **Technical Exclusions:**
   - Advanced features deferred (AI/ML, real-time collaboration, etc.)
   - Performance optimizations deferred
   - Internationalization deferred (if applicable)

5. **Business Exclusions:**
   - Business models not pursued
   - Market segments not targeted in v1.0
   - Monetization features deferred

6. **Clarifications:**
   - Common misconceptions about scope
   - Features that sound similar but are different
   - Boundary clarifications

**Purpose**: Prevent scope creep and align stakeholders on what's NOT being built.

### Step 4: Ensure Traceability

Make sure all requirements map back to:
- User stories from 02-personas/user-stories.md
- MVP scope from 03-mvp/mvp-scope.md
- Problem statement from 00-init-ideas (if available)
- Value proposition from 00-init-ideas (if available)

Verify that:
- All P0 features from MVP are fully specified as functional requirements
- P1/P2 features are included or explicitly deferred to out-of-scope
- Each requirement has clear acceptance criteria
- Requirements are testable and implementable

### Step 5: Final User Review

1. **Inform user that PRD is complete**
2. **Update README.md:**
   - Change **Status** from "In Progress" to "Completed"
   - Add a **Summary** section with key insights (2-3 paragraphs)
   - Add a **Created Files** section listing all created files

3. **Present completed work to user:**
   - Number of functional requirements (organized by category)
   - Key non-functional requirements (performance, security, compliance)
   - What's explicitly out of scope
   - How this builds on MVP definition
   - Phasing plan (MVP → v1.0 → future)
   - Explain the completeness: "This PRD locks down WHAT the product does, not HOW it's built"

4. Ask if they want to proceed to the next stage (UX design)
5. Make adjustments based on user feedback if needed

### Step 6: Commit to Git (if user confirms)

1. **If user confirms PRD is complete:**
   - Ask if they want to commit to git
2. **If user wants to commit:**
   - Stage all changes in `04-prd/`
   - Commit with message: "Create Product Requirements Document (Stage 4)"

## Expected Project Structure

```
project-root/
├── 00-init-ideas/
│   └── [existing files]
├── 01-market-research/ (optional)
│   └── [existing files if present]
├── 02-personas/
│   └── [existing files]
├── 03-mvp/
│   └── [existing files]
└── 04-prd/
    ├── README.md (with owners and summary)
    ├── prd.md (product overview, goals, users, journeys, MVP alignment)
    ├── functional-requirements.md (what product must do - behaviors)
    ├── non-functional-requirements.md (performance, security, compliance)
    └── out-of-scope.md (PRD-level exclusions)
```

## Key PRD Principles

1. **Behavior, Not Implementation**: Define WHAT the product does, not HOW it's built
2. **No Tech Stack**: Avoid specifying technologies, frameworks, or implementation details
3. **User-Centric**: Requirements should trace back to user needs and stories
4. **Testable**: Every requirement must have clear acceptance criteria
5. **Complete**: Cover all aspects of product behavior and quality attributes
6. **Unambiguous**: Requirements should be clear and have single interpretation
7. **Prioritized**: Clearly mark P0/P1/P2 to guide implementation phasing
8. **Traceable**: Link requirements to user stories and MVP scope

## Functional Requirements Best Practices

1. **Use consistent numbering**: FR-001, FR-002, etc.
2. **One requirement per item**: Don't combine multiple behaviors
3. **Start with user story**: Connect to user value
4. **Define specific behaviors**: Not vague goals
5. **Include edge cases**: What happens when things go wrong?
6. **Add acceptance criteria**: How do we test this?
7. **Note dependencies**: What must exist first?
8. **Avoid implementation**: Don't specify how to build it

## Non-Functional Requirements Best Practices

1. **Use measurable targets**: "< 2 seconds" not "fast"
2. **Set realistic goals**: Based on industry standards and MVP learnings
3. **Prioritize**: Not all NFRs are equally critical
4. **Consider trade-offs**: Performance vs. cost, security vs. UX
5. **Plan for scale**: Think beyond MVP to full product growth
6. **Document constraints**: What limits exist?

## Deliverables

By the end of this stage, you should have:
- Comprehensive PRD document with product overview, goals, and journeys
- Complete functional requirements mapped to user stories (typically 30-100 requirements)
- Detailed non-functional requirements (performance, security, compliance)
- Clear out-of-scope document preventing scope creep
- Traceability from requirements to user stories and MVP
- Foundation for UX design (next stage)
- Alignment between business goals, user needs, and product requirements
