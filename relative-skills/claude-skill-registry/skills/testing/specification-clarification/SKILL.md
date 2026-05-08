---
name: Specification Clarification
description: Identify and resolve ambiguities in specifications through structured questioning. Use when specification has [NEEDS CLARIFICATION] markers, when user mentions unclear or ambiguous requirements, before creating implementation plans, or when planning reveals specification gaps.
degree-of-freedom: low
allowed-tools: Read, Write, Edit
---

@.claude/shared-imports/constitution.md
@.claude/templates/clarification-checklist.md

# Specification Clarification

**Purpose**: Systematically eliminate ambiguity from specifications through structured questioning before implementation planning.

**Constitutional Authority**: Article IV (Specification-First Development), Article V (Template-Driven Quality)

---

## Phase 1: Load Specification and Detect Ambiguities

### Step 1.1: Read Current Specification

Identify current feature from SessionStart hook context or user input.

```bash
Read specs/<feature-number>-<name>/spec.md
```

### Step 1.2: Scan Against Ambiguity Categories

Use `@.claude/templates/clarification-checklist.md` categories:

**10+ Ambiguity Categories**:
1. **Functional Scope & Behavior**: What exactly does "process" mean? Which actions are in/out of scope?
2. **Domain & Data Model**: What entities exist? What are their relationships and cardinality?
3. **Interaction & UX Flow**: How do users navigate? What's the exact sequence of screens/actions?
4. **Non-Functional Requirements**: Performance targets? Scale expectations? Security requirements?
5. **Integration & Dependencies**: Which external systems? What data flows in/out?
6. **Edge Cases & Failure Scenarios**: What happens when X fails? How to handle boundary conditions?
7. **Constraints & Tradeoffs**: Budget limits? Technology restrictions? Compliance requirements?
8. **Terminology & Definitions**: What does "active user" mean? How is "completion" defined?
9. **Permissions & Access Control**: Who can do what? What are the authorization rules?
10. **State & Lifecycle**: What states can entities be in? What triggers transitions?

### Step 1.3: Identify Gaps and Mark Coverage

For each category, assess coverage:
- **Clear**: Well-defined, no ambiguity
- **Partial**: Some aspects defined, others unclear
- **Missing**: Not addressed in specification

**Output**: Coverage matrix showing which categories need clarification

---

## Phase 2: Prioritize Clarification Questions

### Step 2.1: Extract [NEEDS CLARIFICATION] Markers

Count existing markers in specification (Article IV limit: max 3).

### Step 2.2: Prioritize by Impact

**Priority Order** (Article IV, Section 4.2):
1. **Scope** (highest impact) - Affects what gets built
2. **Security** - Affects risk and compliance
3. **UX Flow** - Affects user experience
4. **Technical** (lowest impact) - Implementation details

**Maximum 5 Questions Per Iteration** (Article IV requirement)

### Step 2.3: Generate Questions with Recommendations

Each question MUST include:
- **Context**: Why this matters
- **Question**: Specific, focused inquiry
- **Options**: 2-3 recommendations based on common patterns
- **Impact**: What depends on this answer

**Example**:
```
**Question 1: Authentication Method** (Priority: Security)

Context: Specification mentions "user login" but doesn't specify authentication approach.

Question: How should users authenticate?

Options:
A) Email/password (simplest, industry standard)
B) Social login only (Google, GitHub - reduces friction)
C) Both email/password + social (maximum flexibility)

Recommendation: Option C provides flexibility while maintaining control.

Impact: Affects data model (user table schema), security requirements (password hashing, OAuth), and UX flow (login screens).

Intelligence Evidence:
- project-intel.mjs found: src/auth/login.tsx:12 (existing email/password flow)
- Recommendation aligns with existing pattern
```

---

## Phase 3: Interactive Clarification

### Step 3.1: Present Questions Sequentially

**ONE QUESTION AT A TIME** for complex topics (Article IV requirement).

Present question with:
- Numbered options
- Recommendation highlighted
- Impact analysis
- Evidence from intelligence queries (if available)

### Step 3.2: Capture User Response

Record answer with rationale:
```
**Answer to Q1**: Option C (both methods)

**Rationale**: Need to support existing email users while enabling social login for new users.

**Additional Context**: Google and GitHub OAuth only (not Facebook).
```

### Step 3.3: Update Specification Incrementally

**After EACH answer**:
1. Edit specification to incorporate answer
2. Remove or resolve [NEEDS CLARIFICATION] marker
3. Add functional requirement with answer
4. Verify no contradictions introduced

**Example Update**:
```markdown
## Functional Requirements

- **FR-001**: System MUST support email/password authentication
- **FR-002**: System MUST support OAuth2 social login (Google, GitHub)
- **FR-003**: Users MUST be able to link multiple auth methods to one account
```

**Remove**:
```markdown
- **FR-XXX**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified]
```

---

## Phase 4: Validation and Completion

### Step 4.1: Verify Consistency

**Check for contradictions**:
- Do new requirements conflict with existing ones?
- Are priorities consistent?
- Do user stories align with clarifications?

### Step 4.2: Update Clarification Checklist

Mark categories as **Clear** after resolution:

```markdown
## Clarification Status

| Category | Status | Notes |
|----------|--------|-------|
| Functional Scope | Clear | All features defined |
| Domain Model | Clear | User/Auth entities specified |
| UX Flow | Clear | Login/register flows documented |
| Non-Functional | Partial | Need performance targets |
| Integration | Clear | Google/GitHub OAuth |
...
```

### Step 4.3: Report Completion

**Output**:
```
✓ Clarification complete: <N> questions resolved

Resolved:
- Q1: Authentication method → Email/password + Social (Google, GitHub)
- Q2: User roles → Admin, User, Guest with specified permissions
- Q3: Data retention → 90 days for inactive accounts

Updated Specification:
- Added FR-001 through FR-008 (authentication requirements)
- Updated User Stories with auth flow details
- Removed all [NEEDS CLARIFICATION] markers

Remaining Ambiguities: 0 (ready for planning)

Next Step: Use create-implementation-plan skill to define HOW
```

---

## Phase 5: Re-Clarification (If Needed)

### When to Re-Run

Trigger clarification again if:
- Implementation planning reveals new ambiguities
- User requests changes to requirements
- New [NEEDS CLARIFICATION] markers added during planning

### Iterative Approach

Each iteration:
- Maximum 5 new questions
- Focus on highest-priority gaps
- Update specification incrementally
- Validate consistency

---

## Anti-Patterns to Avoid

**DO NOT**:
- Ask more than 5 questions per iteration (Article IV limit)
- Ask open-ended questions without recommendations
- Present all questions at once (use sequential for complex topics)
- Make assumptions instead of asking
- Skip updating specification after each answer
- Accept ambiguous answers (press for specifics)

**DO**:
- Prioritize by impact (scope > security > UX > technical)
- Provide 2-3 options with recommendations
- Use intelligence queries for context
- Update spec incrementally (after each answer)
- Verify consistency after updates
- Limit [NEEDS CLARIFICATION] markers to max 3

---

## Example Execution

**Input**: Specification with markers:
```markdown
- **FR-004**: System MUST handle [NEEDS CLARIFICATION: concurrent user limit?]
- **FR-005**: Data MUST be stored [NEEDS CLARIFICATION: how long?]
- **FR-006**: Errors MUST be [NEEDS CLARIFICATION: logged where?]
```

**Phase 1**: Scan shows Missing coverage for:
- Non-functional requirements (no performance targets)
- Integration (no error logging system specified)

**Phase 2**: Generate 3 questions (all markers + 1 gap):

```
Q1: Concurrent User Limit (Priority: Technical/NFR)
Options:
A) 100 concurrent users (small team)
B) 1,000 concurrent users (department)
C) 10,000+ concurrent users (enterprise)
Recommendation: B (1,000) based on "department-scale" in problem statement

Q2: Data Retention Policy (Priority: Security/Compliance)
Options:
A) 30 days (minimal retention)
B) 90 days (standard)
C) Indefinite (until user deletes)
Recommendation: B (90 days) balances compliance and user needs

Q3: Error Logging Destination (Priority: Technical)
Options:
A) File-based logging (local files)
B) Centralized logging service (Sentry, DataDog)
C) Both (files + service)
Recommendation: C (both) for redundancy

Additional Gap:
Q4: Response Time Target (Priority: NFR)
Options:
A) < 200ms p95 (fast)
B) < 500ms p95 (standard)
C) < 1000ms p95 (acceptable)
Recommendation: B (500ms) standard for web apps
```

**Phase 3**: Present Q1, get answer (Option B), update spec:
```markdown
- **FR-004**: System MUST support 1,000 concurrent users with < 500ms p95 latency
```

**Phase 4**: After all questions resolved:
```
✓ 4 questions resolved
✓ 0 [NEEDS CLARIFICATION] markers remaining
✓ Specification ready for implementation planning
```

---

**Skill Version**: 1.0.0
**Last Updated**: 2025-10-19
