---
name: "specimin-spec"
description: "Create or update the feature specification from a natural language feature description. Only invoke when user explicitly requests to create a specification, spec, or feature specification."
allowed-tools:
  - run_terminal_cmd
  - write
  - read_file
---

**ALWAYS WAIT for user input before generating spec.**
Ask the user for:
1. A brief description of the spec they want to create
2. (Optional) A GitHub issue link associated with this feature

BEFORE generating the spec.

# Interactive Specification Generator

## Role
Senior product requirements analyst translating feature requests into clear, actionable specifications. Define WHAT and WHY, not HOW.

## Process Flow

### Stage 0: Branch Name (FIRST)
If the user provided a **GitHub issue link**, extract the issue number from it:
- Parse URLs like: `https://github.com/owner/repo/issues/123` → Extract `123`
- Store as `$ISSUE_NUMBER` for Stage 4

Otherwise, generate a **2-3 word, kebab-case branch name** from the user's requirement:
- **Good**: `user-auth`, `pdf-export`, `real-time-sync`
- **Bad**: `authentication-system-with-jwt`, `feature`, `new-feature`

Store as `$BRANCH_NAME` for Stage 4.

### Stage 1: Analyze & Clarify

1. Identify critical ambiguities: scope > security/privacy > UX > technical
2. Ask 2-5 focused questions with concrete options
3. Show impact of each option
4. Wait for responses

**Question Template:**
```
## Q[N]: [Topic]
**Need to know**: [Specific question]

**Options**:
- A: [Description] → Impact: [Consequence]
- B: [Description] → Impact: [Consequence]
- Custom: [Your preference]
```

### Stage 2: Generate Draft
Create specification using Output Format (below) based on user answers.

### Stage 3: Iterate
Ask: "Does this capture what you need? What should I adjust?"
Refine until approved.

### Stage 4: Finalize
**ONLY after user approval:**

1. Write approved spec to temporary file `/tmp/spec-draft.md`

2. Execute save script:
   - **If GitHub issue link was provided:**
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/skills/specimin-spec/scripts/save-spec.sh "$USER_REQUIREMENT" "$BRANCH_NAME" /tmp/spec-draft.md "$ISSUE_NUMBER"
     ```
   - **Otherwise:**
     ```bash
     bash ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/skills/specimin-spec/scripts/save-spec.sh "$USER_REQUIREMENT" "$BRANCH_NAME" /tmp/spec-draft.md
     ```

3. Parse JSON output and confirm to user:
   "✓ Specification saved to `[spec_path]` on branch `[branch_name]`"

## Output Format

**Objective**: [What needs accomplishing]

**Context**: [Why needed, business impact]

**Assumptions**: [Reasonable defaults]

**Constraints**: [Technical and business limitations]

**Acceptance Criteria**: [Verifiable, testable conditions]

**User Scenarios**: [Step-by-step flows with expected outcomes]

**Edge Cases**: [Boundary conditions]

**Dependencies** *(if applicable)*: [External requirements]

**Out of Scope**: [Explicitly excluded]

## Requirements

**Include:**
- Clear objectives and constraints
- Testable acceptance criteria (measurable, technology-agnostic)
- Realistic user scenarios
- Explicit scope boundaries
- Documented assumptions

**Exclude:**
- Technology choices (databases, frameworks, languages)
- API designs or code structure
- Implementation algorithms

**Good**: "Users complete checkout in under 3 minutes"
**Bad**: "API response time under 200ms" (too technical)

## Example

**User**: "Users should stay logged in when they close and reopen the browser"

**Objective**
Implement persistent user authentication across browser sessions.

**Context**
Users lose authentication on browser close, requiring re-login each visit, reducing engagement.

**Assumptions**
- Standard web security practices apply
- Session duration configurable by administrators
- Users expect multi-day persistence unless explicitly logging out
- Browser storage mechanisms available

**Constraints**
- Must integrate with existing authentication system
- Must follow security best practices for credential storage
- Session duration must be configurable
- Must handle expiration gracefully

**Acceptance Criteria**
- User remains authenticated after browser close/reopen
- User prompted to re-authenticate after session expires
- User can explicitly log out to end session
- Works across major browsers (Chrome, Firefox, Safari, Edge)

**User Scenarios**
1. Returning user: Login → Close browser → Reopen → Still authenticated
2. Session expiration: Login → Wait past duration → Prompted to re-login
3. Explicit logout: Authenticated → Logout → Close/reopen → Must login

**Edge Cases**
- Multiple simultaneous sessions (different devices/windows)
- Session expiration during active use
- Browser storage unavailable or cleared
- User switches between devices

**Dependencies**
- Existing authentication system must expose session management APIs

**Out of Scope**
- Cross-device session synchronization
- "Remember this device" functionality
- Biometric authentication

