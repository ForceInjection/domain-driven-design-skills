---
name: requirement-extraction
description: Extract structured requirements with REQ-* keys from raw intent. Transforms vague user intent into formal requirements with unique keys, acceptance criteria, and business context. Use when starting new features or analyzing user stories.
allowed-tools: [Read, Write, Edit, Grep, Glob]
---

# requirement-extraction

**Skill Type**: Actuator (Requirements Stage)
**Purpose**: Transform raw intent into structured requirements with REQ-* keys
**Prerequisites**: Raw intent or user story available

---

## Agent Instructions

You are extracting **structured requirements** from **raw user intent**.

Your goal is to transform vague intent into **formal requirements** with:
1. Unique REQ-* keys
2. Clear descriptions
3. Acceptance criteria
4. Business context
5. Traceability to intent

---

## Workflow

### Step 1: Analyze Intent

**Parse the raw intent**:
- What is the user trying to achieve?
- What problem are they solving?
- What are the key capabilities needed?
- Who are the users (personas)?
- What are the success criteria?

**Example Intent**:
```
INT-042: "We need a customer self-service portal where users can log in,
view their account balance, update their profile, and download invoices."
```

**Analysis**:
```
Goal: Customer self-service
Problem: Customers calling support for basic info
Capabilities needed:
  1. User authentication
  2. View account data
  3. Edit profile
  4. Download documents
Users: Existing customers
Success: Reduced support calls
```

---

### Step 2: Identify Requirements

**Break intent into discrete requirements**:

**Rule**: One requirement = one testable capability

**From INT-042, extract**:
1. User login (authentication capability)
2. View account balance (read account data)
3. Update profile (edit user data)
4. Download invoices (document access)

---

### Step 3: Assign REQ-* Keys

**Determine requirement type**:

**REQ-F-* (Functional)** - Features users can use:
- User login → `<REQ-ID>`
- View balance → `REQ-F-PORTAL-001`
- Update profile → `REQ-F-PORTAL-002`
- Download invoices → `REQ-F-PORTAL-003`

**REQ-NFR-* (Non-Functional)** - Quality attributes:
- Response time < 500ms → `REQ-NFR-PERF-001`
- SSL encryption → `REQ-NFR-SEC-001`
- 99.9% uptime → `REQ-NFR-AVAIL-001`

**REQ-DATA-* (Data Quality)** - Data requirements:
- Email must be valid → `REQ-DATA-AQ-001`
- PII must be encrypted → `REQ-DATA-PII-001`

**Key assignment rules**:
- Sequential IDs within domain (001, 002, 003...)
- Domain reflects feature area (AUTH, PORTAL, PAY, USER)
- Use existing domains where possible

---

### Step 4: Write Requirement Specifications

**Format for each requirement**:

```markdown
## <REQ-ID>: User Login with Email and Password

**Type**: Functional Requirement
**Domain**: Authentication
**Priority**: P0 (Critical)
**Intent**: INT-042

**Description**:
Users must be able to log in to the customer portal using their registered email address and password.

**Acceptance Criteria**:
1. User can enter email and password on login page
2. Valid credentials grant access to customer portal
3. Invalid credentials show clear error message
4. Account locks after 3 failed attempts for 15 minutes
5. Locked account shows clear lockout message with time remaining

**Business Context**:
- Current State: No customer self-service (customers call support)
- Problem: High support call volume for basic account info
- Solution: Self-service portal with authentication
- Value: Reduce support calls by 40%

**User Story**:
As a customer
I want to log in with my email and password
So that I can access my account information

**Related Requirements**:
- REQ-NFR-SEC-001: Password must be encrypted
- REQ-NFR-PERF-001: Login response < 500ms
- REQ-DATA-AQ-001: Email must be valid format

**Assumptions**:
- Users already registered (registration is separate feature)
- Email is unique identifier
- Session timeout is 30 minutes (standard)

**Out of Scope**:
- Social login (OAuth)
- Passwordless login
- Biometric authentication
```

**Key elements**:
- ✅ Unique REQ-* key
- ✅ Type, domain, priority
- ✅ Link to original intent (INT-*)
- ✅ Clear description
- ✅ Measurable acceptance criteria
- ✅ Business context (current state, problem, solution, value)
- ✅ User story format
- ✅ Related requirements
- ✅ Assumptions and out-of-scope

---

### Step 5: Create Requirements Document

**File structure**:
```
docs/requirements/
├── authentication.md       # REQ-F-AUTH-*
├── customer-portal.md      # REQ-F-PORTAL-*
├── performance.md          # REQ-NFR-PERF-*
└── security.md            # REQ-NFR-SEC-*
```

**Example file** (`docs/requirements/authentication.md`):
```markdown
# Authentication Requirements

**Domain**: Authentication
**Intent**: INT-042 (Customer self-service portal)
**Owner**: Product Team
**Created**: 2025-11-20
**Last Updated**: 2025-11-20

---

## <REQ-ID>: User Login with Email and Password

[Full specification as shown above]

---

## <REQ-ID>: Password Reset via Email

**Type**: Functional Requirement
**Domain**: Authentication
**Priority**: P1 (High)
**Intent**: INT-042

**Description**:
Users who forget their password must be able to reset it via email.

**Acceptance Criteria**:
1. User clicks "Forgot Password" link
2. User enters email address
3. System sends reset link via email within 5 seconds
4. Reset link expires after 1 hour
5. Reset link can only be used once
6. User sets new password meeting requirements

[Continue with Business Context, User Story, etc.]
```

---

### Step 6: Create Traceability Entry

**Map intent to requirements**:

```yaml
# docs/traceability/intent-to-requirements.yml

INT-042:
  title: "Customer self-service portal"
  date_created: "2025-11-20"
  status: "In Progress"
  requirements:
    - <REQ-ID>
    - <REQ-ID>
    - REQ-F-PORTAL-001
    - REQ-F-PORTAL-002
    - REQ-F-PORTAL-003
    - REQ-NFR-PERF-001
    - REQ-NFR-SEC-001
    - REQ-DATA-AQ-001
  requirement_count: 8
  completion: 0%  # Updated as requirements are implemented
```

---

### Step 7: Commit Requirements

**Create commit**:

```bash
git add docs/requirements/ docs/traceability/
git commit -m "REQUIREMENTS: Extract requirements from INT-042

Extract structured requirements from customer portal intent.

Requirements Extracted:
- <REQ-ID>: User login with email/password
- <REQ-ID>: Password reset via email
- REQ-F-PORTAL-001: View account balance
- REQ-F-PORTAL-002: Update user profile
- REQ-F-PORTAL-003: Download invoices
- REQ-NFR-PERF-001: Response time < 500ms
- REQ-NFR-SEC-001: SSL encryption
- REQ-DATA-AQ-001: Email validation

Total: 8 requirements

Traceability: INT-042 → 8 REQ-* keys

Source Intent: INT-042 (Customer self-service portal)
"
```

---

## Output Format

When you complete requirement extraction:

```
[REQUIREMENT EXTRACTION - INT-042]

Intent: Customer self-service portal

Requirements Extracted:

Functional Requirements (5):
  ✓ <REQ-ID>: User login with email/password
  ✓ <REQ-ID>: Password reset via email
  ✓ REQ-F-PORTAL-001: View account balance
  ✓ REQ-F-PORTAL-002: Update user profile
  ✓ REQ-F-PORTAL-003: Download invoices

Non-Functional Requirements (2):
  ✓ REQ-NFR-PERF-001: Response time < 500ms
  ✓ REQ-NFR-SEC-001: SSL encryption required

Data Quality Requirements (1):
  ✓ REQ-DATA-AQ-001: Email must be valid format

Total: 8 requirements

Files Created:
  + docs/requirements/authentication.md (<REQ-ID>, 002)
  + docs/requirements/customer-portal.md (REQ-F-PORTAL-001, 002, 003)
  + docs/requirements/performance.md (REQ-NFR-PERF-001)
  + docs/requirements/security.md (REQ-NFR-SEC-001)
  + docs/requirements/data-quality.md (REQ-DATA-AQ-001)

Traceability:
  Intent: INT-042 → 8 requirements
  Mapping: Created in docs/traceability/intent-to-requirements.yml

Commit: REQUIREMENTS: Extract requirements from INT-042

✅ Extraction Complete!
   Next: Invoke disambiguate-requirements to add BR-*, C-*, F-*
```

---

## Prerequisites Check

Before invoking this skill, ensure:
1. Raw intent available (user story, feature request, problem statement)
2. Intent has some level of detail (not just "make it better")

If prerequisites not met:
- Intent too vague → Ask user clarifying questions
- No intent → Ask user what they want to build

---

## Clarifying Questions

**If intent is vague, ask**:

1. **Who** is the user? (persona, role, context)
2. **What** are they trying to do? (goal, task, capability)
3. **Why** do they need this? (problem, value, business case)
4. **How** will we know it's done? (acceptance criteria, success metrics)
5. **When** is it needed? (timeline, priority)
6. **What if** edge cases? (error handling, boundary conditions)

**Example**:
```
Vague Intent: "Add payment processing"

Clarifying Questions:
  1. What payment methods? (credit card, PayPal, crypto?)
  2. What payment provider? (Stripe, Braintree, custom?)
  3. What compliance requirements? (PCI-DSS level?)
  4. What currencies? (USD only, multi-currency?)
  5. What transaction limits? (min/max amounts?)
  6. What error handling? (retry, refund, dispute?)

Refined Intent: "Add credit card payment processing via Stripe,
PCI-DSS Level 1 compliant, USD only, $0.01 to $10,000 per transaction,
with automatic retry on temporary failures."
```

---

## Next Steps

After requirement extraction:
1. **Disambiguate**: Invoke `disambiguate-requirements` to add BR-*, C-*, F-*
2. **Validate**: Invoke `validate-requirements` to check quality
3. **Design**: Move to Design stage (create architecture)

---

## Configuration

```yaml
plugins:
  - name: "@aisdlc/requirements-skills"
    config:
      extraction:
        auto_extract_on_intent: true          # Auto-invoke when intent detected
        require_acceptance_criteria: true      # All REQ-* must have AC
        min_requirements_per_intent: 1         # At least 1 REQ per intent
        ask_clarifying_questions: true         # Ask if intent vague
        max_clarifying_questions: 6            # Max questions to ask
```

---

## Notes

**Why requirement extraction?**
- **Clarity**: Transforms vague intent into specific requirements
- **Traceability**: Links requirements back to original intent
- **Testability**: Acceptance criteria become test cases
- **Prioritization**: Clear requirements enable better planning

**Good requirements characteristics** (SMART):
- **Specific**: Clear, unambiguous description
- **Measurable**: Acceptance criteria can be tested
- **Achievable**: Technically feasible
- **Relevant**: Linked to business value
- **Testable**: Can write tests to validate

**Homeostasis Goal**:
```yaml
desired_state:
  all_intents_have_requirements: true
  all_requirements_have_unique_keys: true
  all_requirements_have_acceptance_criteria: true
  all_requirements_traceable_to_intent: true
```

**"Excellence or nothing"** 🔥
