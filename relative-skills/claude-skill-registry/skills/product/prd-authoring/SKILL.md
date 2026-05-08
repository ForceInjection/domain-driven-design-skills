---
name: prd-authoring
description: Use this skill for early-stage project planning through Product Requirements Documents (PRDs). Guides users from initial project ideas through product briefs, market research, PRD creation, validation, and epic decomposition. Triggers include "create PRD", "product brief", "validate requirements", or beginning project inception activities.
---

# PRD Authoring Skill

## Purpose

Manage early-stage project planning and requirements definition before entering the spec-driven development workflow. This skill integrates BMAD methodology's Product Manager and Business Analyst workflows to guide users from vague project ideas to well-defined Product Requirements Documents (PRDs) with clear success criteria, validated requirements, and actionable epic breakdowns.

The prd-authoring skill bridges the gap between "we have an idea" and "we're ready to write specs." It ensures that projects begin with:
- Clear problem statements and value propositions
- Data-driven market research and competitive analysis
- Specific, measurable, and testable requirements
- Well-defined success criteria and acceptance criteria
- Epic decomposition ready for sprint planning

PRDs created with this skill serve as strategic documents that can span multiple specs and persist across implementation iterations.

## When to Use

Use this skill in the following situations:

- Starting a new project from an initial concept or idea
- Creating a product brief to formalize a vague project vision
- Conducting market research and competitive analysis
- Writing a comprehensive PRD with requirements and success criteria
- Validating an existing PRD against quality standards
- Breaking down a PRD into epics for sprint planning
- Preparing to transition from planning to the spec-authoring workflow
- Assessing project readiness and determining next steps

Do NOT use this skill for:
- Implementation-level specifications (use spec-authoring instead)
- Sprint planning from approved specs (use sprint-planner instead)
- Code implementation tasks (use issue-executor instead)

## Prerequisites

- Project initialized with SynthesisFlow structure (docs/ directory exists)
- Basic understanding of product requirements and success criteria
- Stakeholder alignment on project goals (or willingness to develop it)

Optional but helpful:
- Market research or competitive analysis data
- User personas or target audience information
- Business objectives and constraints

## PRD Philosophy

**Strategy Before Tactics**: PRDs define WHAT we're building and WHY before specs define HOW we'll build it.

**Benefits**:
- **Stakeholder alignment**: Ensure everyone agrees on goals before development
- **Informed decisions**: Base requirements on research and data, not assumptions
- **Clear success metrics**: Know what "done" looks like before starting
- **Reduced waste**: Catch misalignment early when changes are cheap
- **Traceability**: Link all specs and tasks back to business objectives

**Workflow**:
1. Initial idea or concept identified
2. Product brief created (problem, solution, users, value)
3. Market research conducted (competitors, landscape, opportunities)
4. PRD created (objectives, requirements, constraints, assumptions)
5. PRD validated against quality standards
6. Epic decomposition prepares transition to development
7. Specs created from epics (via spec-authoring workflow)

## Workflow Commands

### The `status` Command

#### Purpose

Assess project readiness and provide guidance on next workflow steps. This is the recommended starting point for any new project or when you're unsure what to do next.

#### Workflow

##### Step 1: Run Status Assessment

Execute the status check to understand current project state:

```bash
bash scripts/prd-authoring.sh status [project-name]
```

If no project name is provided, the script checks for any existing PRD work in `docs/prds/`.

##### Step 2: Review Status Report

The status command analyzes:
- Existence of `docs/prds/` directory structure
- Presence of product brief document
- Presence of research document
- Presence of PRD document
- Completeness of each document (required sections present)

Output example:
```
=== PRD Status Report ===
Project: payment-gateway

Status: Research Phase
- ✓ Product brief exists (docs/prds/payment-gateway/product-brief.md)
- ✓ Brief is complete (all required sections present)
- ✗ Research document missing
- ✗ PRD not yet created

Recommendation: Run 'research' command to conduct market analysis
Next command: bash scripts/prd-authoring.sh research payment-gateway
```

##### Step 3: Follow Recommendations

Based on the status report, proceed with the recommended command. Common workflows:

- **No brief exists**: Run `brief` command first
- **Brief exists, no research**: Run `research` command
- **Brief and research exist**: Run `create-prd` command
- **PRD exists but incomplete**: Edit PRD or run `validate-prd` for specific issues
- **PRD complete and validated**: Run `decompose` command to create epics

#### Error Handling

**No docs directory**:
- Run project-init skill first to set up SynthesisFlow structure
- Or manually create `docs/prds/` directory

**Multiple projects detected**:
- Specify project name explicitly: `bash scripts/prd-authoring.sh status project-name`

**Partial documents**:
- Status report identifies missing sections
- Edit files to add missing content or re-run relevant command

---

### The `brief` Command

#### Purpose

Create a formal product brief from an initial project concept. The product brief is a lightweight document that captures the core vision: what problem we're solving, for whom, and why it matters.

#### Workflow

##### Step 1: Gather Initial Information

Discuss with the user:
- What problem does this project solve?
- Who experiences this problem?
- What solution are we proposing?
- What value does this provide?
- How will we measure success?

##### Step 2: Run Brief Creation Script

Execute the script to create product brief structure:

```bash
bash scripts/prd-authoring.sh brief "Project Name"
```

This will:
- Convert project name to kebab-case (e.g., "Payment Gateway" → "payment-gateway")
- Create `docs/prds/payment-gateway/` directory
- Create `product-brief.md` with YAML frontmatter and template sections

##### Step 3: Populate Product Brief

Work with the user to fill in the template sections:

```markdown
---
title: Payment Gateway Integration
type: product-brief
status: draft
created: 2025-11-04
updated: 2025-11-04
---

# Product Brief: Payment Gateway Integration

## Problem Statement

Our e-commerce platform currently lacks payment processing capabilities,
forcing customers to complete purchases via manual invoice. This creates
friction in the buying process and reduces conversion rates.

## Target Users

- Online shoppers making purchases on our platform
- Merchants managing sales and refunds
- Finance team reconciling payments

## Proposed Solution

Integrate a third-party payment gateway (Stripe) to enable secure,
real-time payment processing with support for multiple payment methods.

## Value Proposition

- Customers: Seamless checkout experience with instant confirmation
- Business: Increased conversion rates, automated payment reconciliation
- Merchants: Simplified refund and chargeback management

## Success Metrics

- 80% reduction in checkout abandonment rate
- 95% of payments processed within 3 seconds
- Zero PCI compliance violations
- Support for 5+ payment methods by launch
```

##### Step 4: Review and Refine

Review the brief with stakeholders:
- Ensure problem statement is clear and specific
- Validate target users are well-defined
- Confirm value proposition is compelling
- Verify success metrics are measurable

##### Step 5: Save and Commit

Once the brief is complete:

```bash
git add docs/prds/payment-gateway/product-brief.md
git commit -m "docs: Add product brief for payment gateway"
```

##### Step 6: Check Status

Run status command to confirm brief is complete:

```bash
bash scripts/prd-authoring.sh status payment-gateway
```

#### Usage Example

**Scenario**: Starting a new analytics dashboard project

```bash
# Create product brief
bash scripts/prd-authoring.sh brief "Analytics Dashboard"

# Edit docs/prds/analytics-dashboard/product-brief.md
# Fill in problem, users, solution, value, metrics

# Verify completion
bash scripts/prd-authoring.sh status analytics-dashboard
```

#### Error Handling

**Project directory already exists**:
- Check if brief already created: `ls docs/prds/project-name/`
- Either use different name or edit existing brief
- Use status command to see what exists

**Vague problem statement**:
- Ask probing questions to get specifics
- What exactly is broken or missing?
- Who is affected and how often?
- What's the business impact?

**Unmeasurable success metrics**:
- Convert vague goals to specific numbers
- "Better performance" → "95th percentile response time < 200ms"
- "Improved UX" → "Task completion rate > 85%"

---

### The `research` Command

#### Purpose

Guide users through market research and competitive analysis to inform PRD requirements with data-driven insights.

#### Workflow

##### Step 1: Verify Brief Exists

Check that product brief is complete:

```bash
bash scripts/prd-authoring.sh status project-name
```

If brief is missing or incomplete, complete it first before conducting research.

##### Step 2: Run Research Creation Script

Execute the script to create research document structure:

```bash
bash scripts/prd-authoring.sh research project-name
```

This creates `docs/prds/project-name/research.md` with template sections.

##### Step 3: Define Research Questions

Work with the user to identify key questions:
- Who are the main competitors in this space?
- What features do they offer?
- What are their strengths and weaknesses?
- What market opportunities exist?
- What do users say about existing solutions?
- What technical approaches do competitors use?

##### Step 4: Conduct Research

Guide the user through research activities:

**Competitive Analysis**:
- Identify 3-5 direct competitors
- Document their key features and pricing
- Note what they do well and poorly
- Identify gaps in their offerings

**Market Analysis**:
- Research market size and trends
- Identify target market segments
- Document regulatory or compliance requirements
- Note industry standards and best practices

**User Research** (if applicable):
- Review user feedback on competitor products
- Conduct user interviews or surveys
- Analyze support tickets or feature requests
- Document pain points and unmet needs

##### Step 5: Populate Research Document

Document findings in structured format:

```markdown
---
title: Payment Gateway Research
type: research
status: complete
created: 2025-11-04
updated: 2025-11-04
---

# Research: Payment Gateway Integration

## Competitive Analysis

### Competitor 1: Stripe
- **Strengths**: Developer-friendly API, excellent documentation, 135+ currencies
- **Weaknesses**: Higher fees for international cards (3.9% + $0.30)
- **Key Features**: Recurring billing, fraud detection, mobile SDKs
- **Market Position**: Leader in developer-focused payment processing

### Competitor 2: PayPal
- **Strengths**: Brand recognition, buyer protection, wide adoption
- **Weaknesses**: Higher dispute rates, complex API
- **Key Features**: PayPal checkout, Venmo integration, buyer credit
- **Market Position**: Consumer-focused, trusted brand

### Competitor 3: Square
- **Strengths**: Unified POS and online payments, simple pricing
- **Weaknesses**: Limited international support, fewer currencies
- **Key Features**: In-person + online, inventory management, analytics
- **Market Position**: Small business focus, retail-oriented

## Market Insights

- Payment processing market growing 12% annually
- Mobile payments expected to reach 60% of e-commerce by 2026
- PCI DSS 4.0 compliance required by March 2025
- Buy-now-pay-later (BNPL) options increasing in demand

## User Feedback Analysis

Common pain points with existing solutions:
- Complex integration requiring weeks of development
- Hidden fees and confusing pricing structures
- Poor error messages during failed transactions
- Lack of real-time reconciliation with accounting systems

Desired features:
- One-click checkout experience
- Multiple payment method support (cards, wallets, BNPL)
- Instant refund processing
- Detailed transaction analytics

## Technical Considerations

- REST API vs SDK integration trade-offs
- Webhook reliability for async event handling
- PCI compliance scope (SAQ-A vs SAQ-A-EP)
- Tokenization for recurring payments
- 3D Secure 2.0 for fraud prevention

## Recommendations

1. **Choose Stripe**: Best developer experience, comprehensive features
2. **Priority features**: Card payments, Apple Pay, Google Pay
3. **Phase 2**: Add BNPL options (Klarna, Affirm)
4. **Compliance**: Implement SAQ-A eligible integration (no card data storage)
```

##### Step 6: Extract Key Insights

Summarize findings that will inform PRD:
- Which features are table stakes vs differentiators?
- What technical approaches are proven?
- What user needs are unmet by competitors?
- What constraints exist (compliance, budget, timeline)?

##### Step 7: Review and Commit

```bash
git add docs/prds/project-name/research.md
git commit -m "docs: Add market research for project-name"

# Verify research is complete
bash scripts/prd-authoring.sh status project-name
```

#### Usage Example

**Scenario**: Researching real-time notification system

```bash
# Create research document
bash scripts/prd-authoring.sh research notification-system

# Conduct analysis
# - Compare Firebase, Pusher, Ably, custom WebSocket
# - Review scalability and cost at different volumes
# - Document latency requirements from user research

# Document findings in docs/prds/notification-system/research.md

# Verify completion
bash scripts/prd-authoring.sh status notification-system
```

#### Error Handling

**Brief doesn't exist yet**:
- Complete product brief first
- Research should be informed by brief's problem statement

**Research is too broad**:
- Focus on questions that impact requirements
- Avoid analysis paralysis - perfect is the enemy of done
- Time-box research activities (e.g., 4 hours max)

**No clear competitors**:
- Research adjacent solutions or alternative approaches
- Document why no direct competitors exist
- Analyze components that could be assembled

**Conflicting data sources**:
- Document multiple perspectives
- Note confidence levels in findings
- Prioritize primary research over secondary

---

### The `create-prd` Command

#### Purpose

Generate a comprehensive Product Requirements Document from product brief and research findings. The PRD is the authoritative definition of what will be built and how success will be measured.

#### Workflow

##### Step 1: Verify Prerequisites

Check that brief and research are complete:

```bash
bash scripts/prd-authoring.sh status project-name
```

Both documents should exist and be marked complete before creating PRD.

##### Step 2: Run PRD Creation Script

Execute the script to create PRD structure:

```bash
bash scripts/prd-authoring.sh create-prd project-name
```

This creates `docs/prds/project-name/prd.md` with comprehensive template sections.

##### Step 3: Define Objectives

Work with the user to articulate clear project objectives:

**Good objectives are**:
- Specific: Clearly state what will be achieved
- Measurable: Include quantifiable targets
- Achievable: Realistic given constraints
- Relevant: Aligned with business goals
- Time-bound: Have clear deadlines

Example:
```markdown
## Objectives

### Primary Objectives

1. **Enable online payment processing**
   - Support credit/debit card payments with PCI compliance
   - Process payments in under 3 seconds (95th percentile)
   - Launch by Q2 2026

2. **Increase conversion rates**
   - Reduce checkout abandonment from 45% to 15%
   - Support 5+ payment methods by launch
   - Enable one-click checkout for returning customers

3. **Automate payment reconciliation**
   - Eliminate manual invoice processing
   - Real-time sync with accounting system
   - Reduce finance team reconciliation time by 80%

### Secondary Objectives

1. Enable subscription and recurring billing (Phase 2)
2. Support international currencies (Phase 2)
3. Provide merchant analytics dashboard (Phase 3)
```

##### Step 4: Define Success Criteria

Specify measurable criteria that indicate project success:

```markdown
## Success Criteria

### Launch Criteria (Must-Have)

- [ ] Successfully process 100 test transactions with 0% failure rate
- [ ] PCI DSS compliance validation passed (SAQ-A)
- [ ] Checkout flow completion time < 60 seconds (90th percentile)
- [ ] Support Visa, Mastercard, American Express, Apple Pay, Google Pay
- [ ] 99.9% payment processing uptime over 30-day period

### Success Metrics (3 Months Post-Launch)

- [ ] 10,000+ successful transactions processed
- [ ] Checkout abandonment rate < 20% (vs 45% baseline)
- [ ] Average payment processing time < 2.5 seconds
- [ ] Customer satisfaction score > 4.5/5 for checkout experience
- [ ] Zero security incidents or PCI compliance violations
- [ ] 90% reduction in manual payment reconciliation time

### Stretch Goals

- [ ] Checkout abandonment < 15%
- [ ] Support 10+ payment methods
- [ ] Process 50,000+ transactions per month
```

##### Step 5: Document Functional Requirements

List specific, testable functional requirements:

```markdown
## Functional Requirements

### FR1: Payment Processing
- **Description**: Process credit/debit card payments securely
- **Inputs**: Card details, payment amount, customer info
- **Outputs**: Transaction confirmation, receipt
- **Acceptance Criteria**:
  - Accepts Visa, Mastercard, American Express, Discover
  - Validates card details before submission
  - Returns clear error messages for failed transactions
  - Generates unique transaction ID for each payment
  - Sends confirmation email within 30 seconds

### FR2: Payment Method Management
- **Description**: Support multiple payment methods
- **Inputs**: Customer payment method preferences
- **Outputs**: Saved payment methods, default selection
- **Acceptance Criteria**:
  - Customers can save multiple payment methods
  - Supports cards, Apple Pay, Google Pay
  - Allows setting default payment method
  - Enables payment method deletion
  - Tokenizes card data (no raw card storage)

### FR3: Refund Processing
- **Description**: Enable full and partial refunds
- **Inputs**: Original transaction ID, refund amount
- **Outputs**: Refund confirmation, updated transaction status
- **Acceptance Criteria**:
  - Merchants can issue refunds within 90 days
  - Supports partial refunds
  - Refunds process within 5-7 business days
  - Customer receives refund notification
  - Accounting system updated automatically
```

##### Step 6: Document Non-Functional Requirements

Specify quality attributes and constraints:

```markdown
## Non-Functional Requirements

### NFR1: Performance
- Payment processing response time < 3 seconds (95th percentile)
- Checkout page load time < 2 seconds
- Support 1000 concurrent transactions
- 99.9% uptime SLA

### NFR2: Security
- PCI DSS Level 1 compliance
- TLS 1.3 for all payment data transmission
- Tokenization of card data (no storage of card numbers)
- 3D Secure 2.0 for fraud prevention
- Regular security audits and penetration testing

### NFR3: Reliability
- Automatic retry for transient failures
- Graceful degradation if payment gateway is down
- Transaction logging for audit trail
- Daily backups of transaction data

### NFR4: Usability
- Checkout flow completable in < 5 steps
- Mobile-responsive design
- WCAG 2.1 AA accessibility compliance
- Support for 10+ languages

### NFR5: Scalability
- Handle 10x traffic during peak shopping periods
- Horizontal scaling for increased load
- Database optimization for transaction queries
```

##### Step 7: Document Constraints and Assumptions

Be explicit about limitations and dependencies:

```markdown
## Constraints

- Must use Stripe as payment provider (existing contract)
- Cannot store raw credit card numbers (PCI compliance)
- Must integrate with existing Salesforce CRM
- Launch deadline: June 30, 2026 (non-negotiable)
- Budget: $150k for development and first year operational costs

## Assumptions

- Average transaction value: $75
- Expected transaction volume: 5,000/month initially
- Users have modern browsers (last 2 versions)
- Finance team will handle chargebacks manually
- Stripe API will maintain backward compatibility
- Customer support will handle payment-related inquiries
```

##### Step 8: Define Out of Scope

Clearly state what will NOT be included:

```markdown
## Out of Scope (For This Phase)

- Cryptocurrency payments
- Subscription/recurring billing (deferred to Phase 2)
- International currencies beyond USD (Phase 2)
- In-person/POS payment processing
- Custom payment gateway integration
- Buy-now-pay-later (BNPL) options (Phase 2)
- Merchant analytics dashboard (Phase 3)
```

##### Step 9: Review and Refine

Review the complete PRD with stakeholders:
- Are objectives clear and measurable?
- Are requirements specific and testable?
- Are success criteria appropriate?
- Are constraints and assumptions documented?
- Is scope well-defined?

##### Step 10: Save and Commit

```bash
git add docs/prds/project-name/prd.md
git commit -m "docs: Add PRD for project-name"

# Check status
bash scripts/prd-authoring.sh status project-name
```

#### Usage Example

**Scenario**: Creating PRD for mobile app authentication

```bash
# Verify prerequisites
bash scripts/prd-authoring.sh status mobile-auth

# Create PRD structure
bash scripts/prd-authoring.sh create-prd mobile-auth

# Populate PRD with:
# - Objectives: Enable secure mobile login
# - Success Criteria: 99.9% auth success rate, <2s login time
# - Functional Requirements: Biometric auth, 2FA, password reset
# - Non-Functional Requirements: Security (OAuth 2.0), Performance
# - Constraints: Must support iOS 15+ and Android 10+

# Commit completed PRD
git add docs/prds/mobile-auth/prd.md
git commit -m "docs: Add PRD for mobile authentication"
```

#### Error Handling

**Brief or research missing**:
- Complete prerequisites first
- Use status command to identify what's missing
- PRD quality depends on foundation work

**Requirements are too vague**:
- Make requirements specific and measurable
- Add clear acceptance criteria for each requirement
- Ask: "How would we test this?"

**Scope is too large**:
- Break into phases (MVP, Phase 2, Phase 3)
- Define clear out-of-scope items
- Focus on core value proposition first

**Success criteria not measurable**:
- Convert qualitative goals to quantitative metrics
- "Better UX" → "Task completion rate > 85%"
- "Fast performance" → "P95 response time < 200ms"

**Conflicting requirements**:
- Document the conflict explicitly
- Escalate to stakeholders for prioritization
- Note decision rationale in PRD

---

### The `validate-prd` Command

#### Purpose

Validate PRD quality against standards and best practices. Catches common issues like missing sections, vague requirements, and unmeasurable success criteria.

#### Workflow

##### Step 1: Run Validation Script

Execute the validation check:

```bash
bash scripts/prd-authoring.sh validate-prd project-name
```

##### Step 2: Review Validation Report

The script checks for:

**Completeness**:
- [ ] YAML frontmatter present with required fields
- [ ] Objectives section exists and non-empty
- [ ] Success criteria section exists with measurable items
- [ ] Functional requirements section exists
- [ ] Non-functional requirements section exists
- [ ] Constraints section exists
- [ ] Assumptions section exists

**Quality Checks**:
- [ ] Requirements are specific (not vague language like "should", "might", "probably")
- [ ] Success criteria are measurable (include numbers/percentages)
- [ ] Acceptance criteria defined for each requirement
- [ ] No ambiguous terms ("fast", "good", "better" without quantification)
- [ ] Out of scope section clarifies boundaries

**SMART Criteria** (for objectives and requirements):
- **Specific**: Clearly defined, not vague
- **Measurable**: Quantifiable success metrics
- **Achievable**: Realistic given constraints
- **Relevant**: Aligned with business goals
- **Time-bound**: Has clear deadlines

Output example:
```
=== PRD Validation Report ===
Project: payment-gateway
File: docs/prds/payment-gateway/prd.md

Completeness: 8/8 ✓
- ✓ YAML frontmatter present
- ✓ Objectives section (3 objectives defined)
- ✓ Success criteria section (12 criteria, 10 measurable)
- ✓ Functional requirements (8 requirements)
- ✓ Non-functional requirements (5 requirements)
- ✓ Constraints (5 constraints documented)
- ✓ Assumptions (6 assumptions documented)
- ✓ Out of scope (7 items excluded)

Quality Issues: 3
⚠ Line 45: Success criterion lacks measurement - "improve user experience"
  Suggestion: Specify measurable UX metric (e.g., "task completion rate > 85%")

⚠ Line 67: Vague language in FR3 - "reasonable time"
  Suggestion: Define specific time threshold (e.g., "within 5 seconds")

⚠ Line 89: Ambiguous requirement - "should support most payment methods"
  Suggestion: List specific payment methods required

Recommendations:
1. Quantify vague success criteria
2. Replace ambiguous terms with specific values
3. Add acceptance criteria to FR5 and FR6

Overall: GOOD (Minor revisions recommended)
```

##### Step 3: Address Issues

For each issue identified:
1. Locate the line number in the PRD
2. Understand the specific problem
3. Revise the content to address the issue
4. Re-run validation to confirm fix

Common fixes:
- "Improve performance" → "Reduce P95 response time to <200ms"
- "Support many users" → "Support 10,000 concurrent users"
- "Should work well" → "Must achieve 99.9% uptime"

##### Step 4: Re-validate

After making changes, run validation again:

```bash
bash scripts/prd-authoring.sh validate-prd project-name
```

Continue iterating until validation passes with no critical issues.

##### Step 5: Commit Validated PRD

Once validation passes:

```bash
git add docs/prds/project-name/prd.md
git commit -m "docs: Validate and refine PRD for project-name"
```

#### Validation Modes

**Strict Mode** (default):
- Flags any vague or ambiguous language
- Requires all sections present
- Enforces SMART criteria strictly

**Lenient Mode**:
- Allows some sections to be optional (for early drafts)
- Warnings instead of errors for minor issues
- Useful during initial PRD creation

To use lenient mode:
```bash
bash scripts/prd-authoring.sh validate-prd project-name --lenient
```

#### Usage Example

**Scenario**: Validating API redesign PRD

```bash
# Run validation
bash scripts/prd-authoring.sh validate-prd api-redesign

# Review issues:
# - Missing success criteria for performance objectives
# - Vague requirement: "should be fast"
# - No acceptance criteria for FR7

# Edit docs/prds/api-redesign/prd.md to fix issues

# Re-validate
bash scripts/prd-authoring.sh validate-prd api-redesign

# Validation passes ✓
```

#### Error Handling

**PRD file doesn't exist**:
- Run `create-prd` command first
- Check project name spelling
- Use `status` command to confirm PRD location

**Too many validation errors**:
- Use lenient mode during drafting
- Focus on completing content first, polish later
- Address critical issues before minor ones

**False positives**:
- Some domain-specific terms may be flagged incorrectly
- Document rationale in PRD if intentionally using flagged term
- Validation is a guide, not absolute law

**Requirements conflict with constraints**:
- Validation may flag logical conflicts
- Review with stakeholders to resolve
- Update either requirements or constraints

---

### The `decompose` Command

#### Purpose

Break down a validated PRD into epics for sprint planning. Epics are independently deliverable units of work that align with PRD objectives and can be further broken down into user stories during sprint planning.

#### Workflow

##### Step 1: Validate PRD First

Ensure PRD passes validation:

```bash
bash scripts/prd-authoring.sh validate-prd project-name
```

Only decompose validated PRDs to ensure quality input.

##### Step 2: Run Decomposition Script

Execute the epic decomposition:

```bash
bash scripts/prd-authoring.sh decompose project-name
```

This creates `docs/prds/project-name/epics.md` with epic breakdown.

##### Step 3: Identify Epic Boundaries

Work with the user to group requirements into logical epics:

**Epic Definition Criteria**:
- Independently deliverable (provides value on its own)
- Aligns with one or more PRD objectives
- Can be completed in 2-4 sprints
- Has clear scope boundaries
- Minimal dependencies on other epics (where possible)

**Common Epic Patterns**:
- By user flow (e.g., "User Registration Epic", "Checkout Epic")
- By technical layer (e.g., "API Development Epic", "UI Epic")
- By component (e.g., "Payment Processing Epic", "Notification Epic")
- By phase (e.g., "MVP Epic", "Phase 2 Features Epic")

##### Step 4: Define Each Epic

For each epic, document:

```markdown
---
title: Payment Gateway Epics
type: epic-breakdown
prd: docs/prds/payment-gateway/prd.md
status: draft
created: 2025-11-04
updated: 2025-11-04
---

# Epic Breakdown: Payment Gateway

## Epic 1: Payment Processing Core

**Objective**: Enable basic credit/debit card payment processing

**Scope**:
- Integrate Stripe SDK
- Implement payment form with card input
- Process payment transactions
- Handle success/failure responses
- Generate transaction receipts

**Requirements Coverage**:
- FR1: Payment Processing (100%)
- NFR1: Performance (payment processing time)
- NFR2: Security (TLS, tokenization)

**Success Criteria**:
- Process 100 test transactions with 0% failure
- P95 processing time < 3 seconds
- PCI SAQ-A compliance validated

**Dependencies**:
- None (foundational epic)

**Estimated Effort**: 3 sprints

**Out of Scope**:
- Refund processing (Epic 3)
- Multiple payment methods (Epic 2)
- Subscription billing (Phase 2)

---

## Epic 2: Payment Methods

**Objective**: Support multiple payment methods (Apple Pay, Google Pay)

**Scope**:
- Integrate Apple Pay SDK
- Integrate Google Pay SDK
- Add payment method selection UI
- Save payment methods for returning customers
- Set default payment method

**Requirements Coverage**:
- FR2: Payment Method Management (100%)
- NFR4: Usability (checkout flow simplicity)

**Success Criteria**:
- Support 5+ payment methods by launch
- One-click checkout for returning customers
- Payment method save rate > 60%

**Dependencies**:
- Epic 1 (Payment Processing Core) must be complete

**Estimated Effort**: 2 sprints

**Out of Scope**:
- Cryptocurrency payments
- BNPL options (Phase 2)

---

## Epic 3: Refunds and Reconciliation

**Objective**: Enable refund processing and accounting integration

**Scope**:
- Implement full and partial refund flows
- Integrate with accounting system (Salesforce)
- Real-time transaction sync
- Automated reconciliation reporting
- Refund notification emails

**Requirements Coverage**:
- FR3: Refund Processing (100%)
- Objective 3: Automate payment reconciliation

**Success Criteria**:
- Refunds process within 5-7 business days
- 100% transaction sync accuracy
- 80% reduction in manual reconciliation time

**Dependencies**:
- Epic 1 (Payment Processing Core) must be complete

**Estimated Effort**: 2 sprints

**Out of Scope**:
- Chargeback handling (manual process)
- Dispute management (Phase 2)

---

## Epic 4: Security and Compliance

**Objective**: Achieve PCI DSS compliance and implement fraud prevention

**Scope**:
- Implement 3D Secure 2.0
- Complete PCI DSS self-assessment (SAQ-A)
- Set up transaction logging and audit trails
- Implement fraud detection rules
- Security audit and penetration testing

**Requirements Coverage**:
- NFR2: Security (100%)
- NFR3: Reliability (transaction logging)

**Success Criteria**:
- PCI DSS compliance certification
- Zero security incidents post-launch
- Fraud detection blocks 95%+ of suspicious transactions

**Dependencies**:
- Epic 1 (Payment Processing Core) - security built on top

**Estimated Effort**: 2 sprints

**Out of Scope**:
- Advanced fraud ML models (Phase 2)
- Biometric authentication (future)
```

##### Step 5: Map Epic Dependencies

Create dependency graph:

```markdown
## Epic Dependencies

```
Epic 1: Payment Processing Core (Foundational)
  │
  ├─→ Epic 2: Payment Methods (Depends on Epic 1)
  ├─→ Epic 3: Refunds and Reconciliation (Depends on Epic 1)
  └─→ Epic 4: Security and Compliance (Depends on Epic 1)

Recommended Sequence:
1. Epic 1 (Sprint 1-3)
2. Epic 4 in parallel with Epic 1 sprints 2-3 (Sprint 2-4)
3. Epic 2 and Epic 3 can proceed in parallel (Sprint 4-6)
```
```

##### Step 6: Verify Coverage

Ensure all PRD requirements are covered by at least one epic:

```markdown
## Requirements Traceability

| Requirement | Epic(s) | Coverage |
|-------------|---------|----------|
| FR1: Payment Processing | Epic 1 | 100% |
| FR2: Payment Method Management | Epic 2 | 100% |
| FR3: Refund Processing | Epic 3 | 100% |
| NFR1: Performance | Epic 1 | 100% |
| NFR2: Security | Epic 4 | 100% |
| NFR3: Reliability | Epic 3, Epic 4 | 100% |
| NFR4: Usability | Epic 2 | 100% |
| NFR5: Scalability | Epic 1 | 100% |

Total Coverage: 100% ✓
```

##### Step 7: Review and Commit

Review epic breakdown with stakeholders:
- Are epics independently deliverable?
- Are dependencies realistic?
- Is effort estimation reasonable?
- Does sequence make sense?

Commit the epic breakdown:

```bash
git add docs/prds/project-name/epics.md
git commit -m "docs: Add epic decomposition for project-name"
```

##### Step 8: Transition to Spec Authoring

For each epic, optionally generate initial spec proposals:

```bash
bash scripts/prd-authoring.sh generate-specs project-name
```

This creates spec proposal structure in `docs/changes/` for each epic:
```
docs/changes/payment-processing-core/
  ├── proposal.md      (Epic scope and objectives)
  ├── spec-delta.md    (Technical specifications)
  └── tasks.md         (Initial task breakdown)
```

Each spec proposal links back to the PRD and epic for traceability.

#### Usage Example

**Scenario**: Decomposing user management PRD

```bash
# Validate PRD first
bash scripts/prd-authoring.sh validate-prd user-management

# Decompose into epics
bash scripts/prd-authoring.sh decompose user-management

# Review generated epics:
# - Epic 1: User Registration and Login
# - Epic 2: Profile Management
# - Epic 3: Role-Based Access Control
# - Epic 4: Audit and Compliance

# Verify coverage and dependencies
# Edit docs/prds/user-management/epics.md if needed

# Generate spec proposals
bash scripts/prd-authoring.sh generate-specs user-management

# Ready for spec-authoring workflow
```

#### Error Handling

**PRD not validated**:
- Run `validate-prd` first
- Fix validation issues before decomposition
- Quality input → quality output

**Epic scope too large**:
- Break down further into smaller epics
- Aim for 2-4 sprint delivery per epic
- Consider phased approach (MVP + enhancements)

**Epic scope too small**:
- Combine related epics
- Avoid over-fragmenting work
- Ensure each epic delivers standalone value

**Circular dependencies**:
- Review dependency graph
- Refactor epic boundaries if needed
- Some coupling may be unavoidable (document it)

**Incomplete requirements coverage**:
- Review traceability matrix
- Add missing epics for uncovered requirements
- Update PRD if requirements are truly out of scope

---

## Integration with Other Skills

### Transition to spec-authoring

After completing PRD decomposition:

1. **Generate spec proposals** from epics (optional):
   ```bash
   bash scripts/prd-authoring.sh generate-specs project-name
   ```

2. **For each epic**, use spec-authoring to create detailed specs:
   - Run `bash scripts/spec-authoring.sh propose epic-name`
   - Populate proposal.md with epic scope and objectives
   - Populate spec-delta.md with technical requirements
   - Populate tasks.md with implementation breakdown
   - Create Spec PR for review

3. **Maintain traceability**:
   - Link spec proposals back to PRD and epic
   - Reference PRD requirements in spec-delta.md
   - Ensure spec success criteria align with PRD success criteria

Example spec proposal linking to PRD:
```markdown
# Proposal: Payment Processing Core

## Context

This spec implements **Epic 1: Payment Processing Core** from the
Payment Gateway PRD (docs/prds/payment-gateway/prd.md).

## PRD Requirements Covered

- FR1: Payment Processing
- NFR1: Performance (payment processing time < 3s)
- NFR2: Security (TLS, tokenization, PCI compliance)

## Success Criteria (from PRD)

- Process 100 test transactions with 0% failure
- P95 processing time < 3 seconds
- PCI SAQ-A compliance validated

[Rest of spec proposal...]
```

### Integration with sprint-planner

After specs are approved:

1. Use sprint-planner to select approved specs for sprint
2. Epic structure from PRD informs sprint scope
3. PRD success criteria guide sprint goals

### Integration with doc-indexer

PRD documents are indexed alongside specs:

```bash
# Doc-indexer includes PRD documents
bash scripts/doc-indexer.sh

# Output includes:
# - Product Briefs (docs/prds/*/product-brief.md)
# - Research Documents (docs/prds/*/research.md)
# - PRDs (docs/prds/*/prd.md)
# - Epic Breakdowns (docs/prds/*/epics.md)
```

### Integration with project-init

When initializing new projects:

1. Project-init may suggest running prd-authoring for new projects
2. Creates `docs/prds/` directory structure
3. Recommends starting with `status` command

---

## Common Workflows

### Greenfield Project (Idea to PRD)

Complete workflow for brand new project:

```bash
# 1. Assess starting point
bash scripts/prd-authoring.sh status

# 2. Create product brief
bash scripts/prd-authoring.sh brief "New Project"
# Edit docs/prds/new-project/product-brief.md

# 3. Conduct research
bash scripts/prd-authoring.sh research new-project
# Edit docs/prds/new-project/research.md

# 4. Create PRD
bash scripts/prd-authoring.sh create-prd new-project
# Edit docs/prds/new-project/prd.md

# 5. Validate PRD
bash scripts/prd-authoring.sh validate-prd new-project
# Fix any issues and re-validate

# 6. Decompose into epics
bash scripts/prd-authoring.sh decompose new-project
# Review docs/prds/new-project/epics.md

# 7. Generate spec proposals
bash scripts/prd-authoring.sh generate-specs new-project

# 8. Transition to spec-authoring for each epic
```

### Brownfield Enhancement (Existing System)

Workflow for adding features to existing system:

```bash
# 1. Start with research (brief may be lightweight)
bash scripts/prd-authoring.sh brief "System Enhancement"
# Brief can reference existing system docs

bash scripts/prd-authoring.sh research system-enhancement
# Research focuses on gap analysis

# 2. Create focused PRD for enhancement
bash scripts/prd-authoring.sh create-prd system-enhancement
# PRD defines delta from current state

# 3. Validate and decompose
bash scripts/prd-authoring.sh validate-prd system-enhancement
bash scripts/prd-authoring.sh decompose system-enhancement

# 4. Proceed to spec-authoring
```

### Skipping Steps (When Prerequisites Exist)

If some work already exists:

```bash
# Check what exists
bash scripts/prd-authoring.sh status project-name

# If research exists but no PRD, skip to create-prd
bash scripts/prd-authoring.sh create-prd project-name

# If PRD exists but needs validation
bash scripts/prd-authoring.sh validate-prd project-name

# If PRD validated, go straight to decompose
bash scripts/prd-authoring.sh decompose project-name
```

---

## Error Handling and Troubleshooting

### General Issues

**docs/prds/ directory doesn't exist**:
```bash
# Solution: Create directory structure
mkdir -p docs/prds
# Or run project-init if full structure needed
```

**Permission denied when running scripts**:
```bash
# Solution: Make script executable
chmod +x scripts/prd-authoring.sh
```

**Script not found**:
```bash
# Solution: Run from project root or use absolute path
cd /path/to/project
bash scripts/prd-authoring.sh status
```

### Command-Specific Issues

**brief: Product name conflicts with existing**:
- Check `ls docs/prds/` for existing projects
- Use different name or append version (e.g., "payment-gateway-v2")
- Or work with existing brief if intentional

**research: Brief incomplete, can't proceed**:
- Run `status` to identify missing brief sections
- Complete brief first, then return to research
- Research quality depends on brief clarity

**create-prd: Prerequisites missing**:
- Run `status` to see what's needed
- Brief and research should be complete first
- Can skip research for small projects, but not recommended

**validate-prd: Too many errors to fix**:
- Use lenient mode during drafting: `--lenient` flag
- Focus on content completeness first, polish later
- Address critical issues (missing sections) before minor ones

**decompose: Requirements don't cluster into clear epics**:
- Review PRD structure - may be too granular or too broad
- Try different epic boundaries (by user flow vs by component)
- Consult with architect or tech lead on technical decomposition
- It's okay to have some overlap between epics (document it)

### Quality Issues

**PRD requirements are still vague after validation**:
- Validation catches patterns but can't ensure full clarity
- Review each requirement with stakeholder
- Ask: "How would we test this?" and "What does done look like?"
- Iterate with user to refine language

**Success criteria not truly measurable**:
- Convert qualitative to quantitative where possible
- For subjective measures, define evaluation method
- Example: "Intuitive UX" → "User testing shows 80% task success without help"

**Epic dependencies are complex and blocking**:
- This may indicate PRD scope is too ambitious
- Consider phasing: MVP with fewer dependencies first
- Document dependencies clearly and plan sprint sequence accordingly
- Some coupling is normal (just make it explicit)

### Process Issues

**Stakeholders disagree on objectives**:
- PRD authoring surfaces alignment issues early (this is good!)
- Document competing perspectives in PRD
- Escalate to decision-maker for prioritization
- Update PRD to reflect final decision with rationale

**Research is taking too long**:
- Time-box research activities (e.g., 4-8 hours max)
- Focus on questions that impact requirements
- Perfect information is impossible - make best decision with available data
- Document confidence levels and assumptions

**PRD keeps changing during validation**:
- Some iteration is normal and healthy
- If excessive, may indicate unclear initial vision
- Lock PRD after 2-3 validation cycles and proceed
- Future changes can be versioned (e.g., prd-v2.md)

---

## Best Practices

### For Product Briefs

- Keep brief to 1-2 pages (lightweight document)
- Focus on "why" over "how"
- Make problem statement specific and evidence-based
- Define success metrics early (sets direction for PRD)

### For Research

- Time-box research to prevent analysis paralysis
- Focus on actionable insights that inform requirements
- Document sources and confidence levels
- Prioritize primary research (user interviews) over secondary (articles)

### For PRDs

- Requirements should be testable - ask "How would we verify this?"
- Success criteria should be measurable - include numbers
- Be explicit about constraints and assumptions
- Define "out of scope" to prevent scope creep
- Link requirements back to objectives (traceability)
- Version PRDs if substantial changes occur (prd-v2.md)

### For Epic Decomposition

- Epics should deliver standalone value
- Aim for 2-4 sprints per epic (not too large)
- Minimize dependencies where possible
- Document dependencies clearly when unavoidable
- Ensure 100% requirements coverage (no orphans)
- Maintain traceability back to PRD

### For Overall Process

- Don't skip steps - each builds on the previous
- Involve stakeholders early and often
- Document decisions and rationale
- Commit work incrementally (don't wait until perfect)
- Use validation to catch issues early
- Maintain traceability throughout workflow

---

## Examples

Comprehensive examples are available in the `skills/prd-authoring/examples/` directory:

### Payment Gateway Integration Example

A complete, realistic example project showing the full PRD authoring workflow:

**Project Overview**:
- Problem: 45% cart abandonment due to manual invoice processing
- Solution: Integrate Stripe for real-time online payment processing
- Value: Recover $1.8M in lost revenue, save $100K in operational costs
- Timeline: 6 months to launch (Q2 2026)

**Example Files**:

1. **Product Brief** (`01-product-brief-example.md`)
   - Clear problem statement with quantified business impact
   - Well-defined user personas (Online Shopper Sarah, Sales Rep Mike)
   - Specific value propositions: 60s checkout vs 24-48h manual process
   - Measurable success metrics: 55% → 75% conversion rate

2. **Research Document** (`02-research-example.md`)
   - Competitive analysis: Stripe, PayPal/Braintree, Square
   - Market insights: $154B digital payment market, 14.2% CAGR
   - User feedback: 70% cite checkout complexity as pain point
   - Technical considerations: PCI compliance, fraud detection, APIs
   - Recommendation: Use Stripe for best developer experience

3. **PRD - Abbreviated** (`03-prd-example-abbreviated.md`)
   - 3 SMART primary objectives with measurable targets
   - Launch criteria: 100 test transactions, <3s processing, PCI compliance
   - 5 functional requirements (FR1-FR5) with full acceptance criteria
   - 4 non-functional requirements: Performance, Security, Reliability, Usability
   - Constraints, assumptions, and explicit out-of-scope items

4. **Workflow Test Log** (`workflow-test-log.md`)
   - Complete happy path: status → brief → research → PRD → validate → decompose → generate-spec
   - 10 edge cases tested: missing files, duplicates, invalid input, error handling
   - Validation quality tests: vague language, unmeasurable criteria, missing sections
   - All tests passed with proper error handling

**Key Patterns Demonstrated**:

**Problem Statement Format**:
```
What problem + Who experiences + Frequency + Business impact

Example: "Our e-commerce platform lacks payment processing, forcing
customers through manual invoices. This affects 100% of transactions
(1,000/month), causing 45% cart abandonment and $2.4M lost revenue annually."
```

**Success Metric Format**:
```
Metric name: Baseline → Target within Timeframe

Example: "Checkout conversion rate: 55% → 75% within 30 days post-launch"
```

**Functional Requirement Structure**:
- Description: What the system must do
- User Story: As a [user], I want [capability], so that [benefit]
- Inputs: What triggers this functionality
- Outputs: What results or changes occur
- Business Rules: Constraints or special conditions
- Acceptance Criteria: Specific, testable conditions (Given/When/Then)
- Priority: Must Have / Should Have / Could Have
- Dependencies: Other requirements or systems

**Example Functional Requirement**:
```markdown
### FR1: Credit/Debit Card Payment Processing

**Description**: Process credit and debit card payments securely in real-time

**User Story**: As an online shopper, I want to pay with my credit/debit card
directly on the checkout page, so that I can complete my purchase immediately

**Inputs**: Card number, expiration, CVV, billing address, purchase amount

**Outputs**: Payment confirmation, transaction ID, order receipt via email

**Business Rules**:
- Accept Visa, Mastercard, Amex, Discover
- Require CVV for all transactions
- Maximum transaction: $10,000

**Acceptance Criteria**:
- [ ] Given valid card, when submitted, then processes in <3 seconds
- [ ] Given invalid card, when submitted, then clear error message displays
- [ ] Given successful payment, when completes, then email sent within 30 seconds

**Priority**: Must Have

**Dependencies**: Stripe API integration, email service
```

**Running the Example Workflow**:

```bash
# Set up test environment
mkdir -p /tmp/test-prd && cd /tmp/test-prd
mkdir -p docs/prds

# Step 1: Check status (no projects yet)
bash /path/to/prd-authoring.sh status

# Step 2: Create product brief
bash /path/to/prd-authoring.sh brief "Payment Gateway Integration"
# Edit docs/prds/payment-gateway-integration/product-brief.md

# Step 3: Verify brief completeness
bash /path/to/prd-authoring.sh status payment-gateway-integration

# Step 4: Create research document
bash /path/to/prd-authoring.sh research payment-gateway-integration
# Edit docs/prds/payment-gateway-integration/research.md

# Step 5: Create PRD
bash /path/to/prd-authoring.sh create-prd payment-gateway-integration
# Edit docs/prds/payment-gateway-integration/prd.md

# Step 6: Validate PRD (lenient mode for drafts)
bash /path/to/prd-authoring.sh validate-prd payment-gateway-integration --lenient

# Step 7: Validate PRD (strict mode when complete)
bash /path/to/prd-authoring.sh validate-prd payment-gateway-integration

# Step 8: Decompose into epics
bash /path/to/prd-authoring.sh decompose payment-gateway-integration
# Edit docs/prds/payment-gateway-integration/epics.md

# Step 9: Generate spec proposal for first epic
bash /path/to/prd-authoring.sh generate-spec payment-gateway-integration "Payment Processing Core"
# Edit files in docs/changes/payment-processing-core/
```

**Expected Timeline for Example Project**:
- Product brief: 2-4 hours (stakeholder interviews + writing)
- Research: 4-8 hours (competitive analysis + market research)
- PRD creation: 8-16 hours (requirements definition + validation)
- Epic decomposition: 4-8 hours (breaking into deliverable units)
- Total: 18-36 hours of upfront planning before any code is written

**ROI of Planning**:
- Upfront time: ~1 week of planning work
- Prevents: Weeks of rework from misalignment or unclear requirements
- Enables: Parallel development, clear sprint planning, stakeholder buy-in
- Result: Faster delivery with less rework and higher quality outcomes

For complete examples with full content, see the `examples/` directory.

---

## Troubleshooting

### Common Errors and Solutions

#### Error: "docs/prds/ directory does not exist"

**Symptom**: Any command fails with this error

**Cause**: Project not initialized with SynthesisFlow structure

**Solution**:
```bash
# Create directory structure manually
mkdir -p docs/prds

# OR use project-init skill to create full SynthesisFlow structure
# (if available)
```

**Prevention**: Always run from project root, ensure docs/ directory exists

---

#### Error: "Product brief already exists"

**Symptom**: `brief` command fails when trying to create new brief

**Cause**: Project directory and brief file already exist

**Solution**:
```bash
# Option 1: Use different project name
bash scripts/prd-authoring.sh brief "Payment Gateway V2"

# Option 2: Edit existing brief
vim docs/prds/payment-gateway-integration/product-brief.md

# Option 3: Delete and recreate (CAUTION: loses work)
rm -rf docs/prds/payment-gateway-integration
bash scripts/prd-authoring.sh brief "Payment Gateway Integration"
```

**Prevention**: Run `status` command first to check what exists

---

#### Error: "Project directory does not exist. Run 'brief' command first"

**Symptom**: `research`, `create-prd`, or other commands fail

**Cause**: Trying to run commands before creating product brief

**Solution**:
```bash
# Follow proper workflow order
bash scripts/prd-authoring.sh brief "Project Name"  # Step 1
bash scripts/prd-authoring.sh research project-name # Step 2
bash scripts/prd-authoring.sh create-prd project-name # Step 3
```

**Prevention**: Always run `status` command to see what step you're on

---

#### Warning: "Research document not found. PRD quality may be reduced"

**Symptom**: When running `create-prd`, prompted to continue without research

**Cause**: Skipping research step before creating PRD

**Solution**:
```bash
# Recommended: Cancel and create research first
# Press 'n' when prompted

# Create research
bash scripts/prd-authoring.sh research project-name
# Edit research.md

# Then create PRD
bash scripts/prd-authoring.sh create-prd project-name
```

**When to skip**: Very small projects or internal tools where competitive landscape doesn't matter

**Risk**: PRD may lack data-driven insights, miss competitive features, or make invalid assumptions

---

#### Validation Error: "Vague language detected"

**Symptom**: `validate-prd` reports vague terms like "should", "might", "probably", "good", "fast"

**Cause**: Requirements or success criteria are not specific enough

**Solution**:
Replace vague language with specific, measurable terms:

| Vague | Specific |
|-------|----------|
| "fast performance" | "response time <200ms at 95th percentile" |
| "good user experience" | "task completion rate >85% without help" |
| "should support many users" | "must support 10,000 concurrent users" |
| "might improve conversion" | "target 25% increase in conversion rate" |
| "better security" | "zero critical vulnerabilities in security audit" |

**Example Fix**:
```markdown
# Before (vague)
The system should provide fast payment processing with good security.

# After (specific)
The system must process payments in under 3 seconds at 95th percentile
with PCI DSS Level 1 compliance and zero critical security vulnerabilities.
```

---

#### Validation Error: "Success criteria may lack measurable targets"

**Symptom**: `validate-prd` warns that success criteria are not measurable

**Cause**: Success criteria use qualitative language without numeric targets

**Solution**:
Add specific numbers, percentages, or metrics to each success criterion:

```markdown
# Before (unmeasurable)
- Improve customer satisfaction
- Reduce checkout time
- Increase conversion rates

# After (measurable)
- Customer satisfaction: NPS score 35 → 55 within 3 months
- Checkout time: Reduce from 180 seconds to 45 seconds (90th percentile)
- Conversion rate: Increase from 55% to 75% within 30 days post-launch
```

**Format**: `[Metric name]: [Baseline] → [Target] within [Timeframe]`

---

#### Validation Error: "Some functional requirements may lack acceptance criteria"

**Symptom**: Validation reports missing acceptance criteria for requirements

**Cause**: Requirements defined without testable acceptance criteria

**Solution**:
Add specific, testable acceptance criteria in Given/When/Then format:

```markdown
### FR1: Payment Processing

**Acceptance Criteria**:
- [ ] Given valid card details, when customer submits payment,
      then transaction processes in <3 seconds
- [ ] Given invalid card number, when customer submits,
      then error message displays and payment is not processed
- [ ] Given successful payment, when transaction completes,
      then confirmation email sent within 30 seconds
- [ ] Given network timeout, when Stripe API fails,
      then system retries 3 times before showing error
```

**Rule of thumb**: 3-5 acceptance criteria per functional requirement

---

#### Error: "Epics document already exists"

**Symptom**: `decompose` command fails

**Cause**: Epic decomposition already created for this project

**Solution**:
```bash
# Option 1: Edit existing epics document
vim docs/prds/project-name/epics.md

# Option 2: Delete and regenerate (CAUTION: loses work)
rm docs/prds/project-name/epics.md
bash scripts/prd-authoring.sh decompose project-name

# Option 3: Create new version
bash scripts/prd-authoring.sh decompose project-name-v2
```

---

#### Error: "Spec proposal directory already exists"

**Symptom**: `generate-spec` command fails

**Cause**: Spec proposal already generated for this epic

**Solution**:
```bash
# Option 1: Edit existing spec proposal
vim docs/changes/epic-name/proposal.md

# Option 2: Use different epic name
bash scripts/prd-authoring.sh generate-spec project-name "Epic Name V2"

# Option 3: Delete and regenerate (CAUTION: loses work)
rm -rf docs/changes/epic-name
bash scripts/prd-authoring.sh generate-spec project-name "Epic Name"
```

---

### Quality Issues

#### Issue: PRD validation passes but requirements are still unclear

**Symptom**: Validation says "GOOD" but team still doesn't understand what to build

**Cause**: Validation catches patterns but can't ensure complete clarity

**Solution**:
1. Review each requirement with stakeholders
2. Ask: "How would we test this?" and "What does 'done' look like?"
3. Add concrete examples to requirements
4. Create mock-ups or wireframes for UI requirements
5. Write example API requests/responses for backend requirements

**Prevention**: Use peer review - have another team member read the PRD

---

#### Issue: Epic dependencies are complex and create bottlenecks

**Symptom**: Many epics depend on each other, limiting parallel work

**Cause**: PRD scope may be too ambitious or epics not properly sized

**Solution**:
1. Consider phasing: MVP with fewer dependencies first, enhancements later
2. Refactor epic boundaries to reduce coupling
3. Document dependencies explicitly and plan sprint sequence accordingly
4. Accept some coupling is normal (just make it visible)

**Example refactoring**:
```markdown
# Before (high coupling)
Epic 1: Full payment system
Epic 2: Full CRM integration
Epic 3: Full accounting integration

# After (reduced coupling)
Epic 1: Basic payment processing (foundation, no dependencies)
Epic 2: Payment methods & saved cards (depends on Epic 1)
Epic 3: CRM integration (depends on Epic 1, can parallelize with Epic 2)
Epic 4: Accounting integration (depends on Epic 1, can parallelize with Epic 2-3)
```

---

#### Issue: Stakeholders disagree on objectives during PRD review

**Symptom**: PRD review meeting reveals conflicting goals among stakeholders

**Cause**: PRD authoring surfaced alignment issues early (this is actually good!)

**Solution**:
1. Document all perspectives in PRD
2. Escalate to decision-maker for prioritization
3. Update PRD to reflect final decision with rationale
4. Add assumptions section documenting deferred concerns

**This is a feature, not a bug**: Better to discover misalignment during planning than during development

**Example documentation**:
```markdown
## Decision Log

**Decision**: Prioritize B2C checkout experience over B2B invoice workflow

**Rationale**: 80% of revenue from B2C, B2B customers can continue with
manual invoices short-term. B2C automation has higher ROI ($1.8M vs $400K).

**Stakeholder Positions**:
- Sales Team: Wanted B2B priority (their main workflow)
- Product: Recommended B2C (higher revenue impact)
- Final Decision (CEO): B2C for MVP, B2B in Phase 2

**Assumptions**: B2B customers tolerate manual invoices for 6 more months
```

---

#### Issue: Research is taking too long and delaying project start

**Symptom**: Week 3 of research and still gathering data

**Cause**: Analysis paralysis, trying to achieve perfect information

**Solution**:
1. Time-box research: 4-8 hours maximum
2. Focus on questions that impact requirements (not interesting tangents)
3. Use 80/20 rule: Get 80% of insights from 20% of research
4. Document confidence levels and assumptions
5. Perfect information is impossible - make best decision with available data

**Time-boxing template**:
```markdown
## Research Time Budget (8 hours total)

- Competitive analysis (3 hours): Review 3-5 competitors
- Market research (2 hours): Size, trends, growth rate
- User feedback (2 hours): Review existing support tickets, user interviews
- Technical research (1 hour): Industry standards, compliance requirements

## Out of Scope for This Research:
- Deep dive into every competitor feature
- Primary user research (use existing data)
- Building prototypes
- Financial modeling beyond high-level ROI
```

---

#### Issue: PRD keeps changing during validation iterations

**Symptom**: After 5+ rounds of validation, still making changes

**Cause**: Unclear initial vision or excessive perfectionism

**Solution**:
1. Accept that PRDs iterate - 2-3 validation cycles is normal
2. After 3 cycles, lock the PRD and proceed
3. Future changes can be versioned (create prd-v2.md if needed)
4. Use lenient mode for draft validation, strict mode for final pass

**Locking criteria**:
- All required sections present
- Zero critical validation errors
- Stakeholders have reviewed and approved
- Team understands what to build

**Version control**:
```bash
# Lock v1
mv docs/prds/project/prd.md docs/prds/project/prd-v1.md

# Create v2 for major changes
bash scripts/prd-authoring.sh create-prd project-v2

# OR: Make incremental updates with changelog
# Add "## Changelog" section to PRD documenting changes
```

---

### Integration Issues

#### Issue: Unclear how to transition from PRD to spec-authoring

**Symptom**: PRD complete but don't know what to do next

**Solution**:
Follow the epic → spec transition workflow:

```bash
# 1. Ensure PRD decomposed into epics
bash scripts/prd-authoring.sh decompose project-name

# 2. Review and populate epics.md with requirements breakdown

# 3. Generate spec proposal for first epic
bash scripts/prd-authoring.sh generate-spec project-name "Epic 1 Name"

# 4. Populate the spec proposal files:
#    - proposal.md: Epic scope and objectives
#    - spec-delta.md: Technical requirements and design
#    - tasks.md: Implementation breakdown

# 5. Transition to spec-authoring workflow
#    Use spec-authoring skill to create Spec PR from proposal
```

**Traceability chain**:
```
Business Goal
  → PRD Objective
    → Epic
      → Spec Proposal
        → Spec PR
          → GitHub Issues
            → Code Implementation
```

---

#### Issue: Multiple people working on same PRD causing conflicts

**Symptom**: Git merge conflicts in PRD files

**Solution**:
1. Designate one PRD author (typically Product Manager or Tech Lead)
2. Use comments/suggestions for collaboration instead of direct edits
3. Hold review meetings to discuss changes instead of simultaneous editing
4. Use git branches for major structural changes

**Workflow**:
```bash
# Author makes changes
git checkout -b prd-update-objectives
# Edit PRD
git commit -m "Update objectives based on stakeholder feedback"
git push

# Reviewers comment on GitHub PR
# Author incorporates feedback
# Merge when approved
```

---

## Notes

- **PRDs are strategic documents**: They define WHAT and WHY, not HOW
- **Specs provide implementation details**: Use spec-authoring for HOW
- **PRDs can span multiple specs**: One PRD may generate 3-10 specs via epics
- **Research informs better decisions**: Don't skip it (even if brief)
- **Validation is a guide, not gospel**: Use judgment on what to enforce
- **Epic decomposition bridges strategy and execution**: Critical handoff point
- **Iteration is expected**: Few PRDs are perfect on first draft
- **Traceability is essential**: Link specs → epics → PRD → business objectives
- **This workflow is front-loaded**: Invest time early to save rework later
- **Stakeholder alignment is the goal**: Documents are the medium, not the end
