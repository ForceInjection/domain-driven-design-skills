---
name: "specimin-review"
description: "Review a PR created through the spec/plan/implement flow. Analyzes changes against specification and provides actionable feedback. Only invoke when user explicitly requests to review a PR or review changes."
allowed-tools:
  - run_terminal_cmd
  - write
  - read_file
---

# PR Review Command

Analyze pull request changes against feature specification and provide structured, actionable feedback.

## Stage 1: Gather Context

**Actions**:
1. Get current branch: `git rev-parse --abbrev-ref HEAD` → store as `BRANCH`
2. Fetch PR info: `bash ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/skills/specimin-review/scripts/get-pr-info.sh "$BRANCH"`
3. Verify feature directory: `.specimin/plans/$BRANCH/` must exist
4. Read context files:
   - `.specimin/plans/$BRANCH/spec.md` → store key acceptance criteria
   - `.specimin/plans/$BRANCH/plan.md` → store component list and testing strategy
5. Get diff summary: `git diff main...$BRANCH --stat`
6. Get files changed: `git diff main...$BRANCH --name-only`

**Error Handling**:
- No PR found: `Error: No PR found for branch. Run /wrap to create PR first.` → Exit
- No feature dir: `Error: Branch not part of spec flow. Use this for Specimin-created PRs only.` → Exit
- `gh` not installed: `Error: GitHub CLI required. Install: https://cli.github.com/` → Exit

**Checkpoint**: Verify all context gathered (PR exists, spec/plan available, diff accessible).

## Stage 2: Analyze Changes

**Focus Areas** (in order of priority):
1. **Completeness**: All acceptance criteria from spec addressed?
2. **Alignment**: Changes match planned components and approach?
3. **Quality**: Code follows project patterns, proper error handling, tests included?
4. **Scope**: Any unplanned changes or scope creep?

**Analysis Process**:
- Compare acceptance criteria (from spec) to implemented features (from diff)
- Check planned components (from plan) appear in changed files
- Verify testing strategy (from plan) reflected in test files
- Identify gaps, misalignments, or concerns

**What to avoid**:
- Nitpicking style (trust project conventions)
- Suggesting rewrites without clear justification
- Commenting on every file (focus on issues and gaps)

## Stage 3: Generate Review

Write review to `/tmp/pr-review.md` using format below:

```markdown
# PR Review: [PR Title]

**Branch**: [branch] | **PR**: [url] | **Status**: [state]

## Summary
[2-3 sentences: what was implemented, overall assessment]

## Acceptance Criteria Coverage
[For each criterion from spec.md:]
- [x] [Criterion]: Implemented in [files]
- [ ] [Criterion]: **MISSING** - [what's needed]
- [~] [Criterion]: **PARTIAL** - [what's done, what's missing]

## Alignment with Plan
[Brief check against plan.md components:]
- ✓ [Component]: Found in [files]
- ⚠ [Component]: [concern or deviation]
- ✗ [Component]: Not found - [files expected]

## Testing Completeness
[Check against plan.md testing strategy:]
- Unit tests: [present/missing] - [details]
- Integration tests: [present/missing] - [details]
- Edge cases: [covered/missing] - [specific gaps]

## Issues Found
[Only if actual issues exist - numbered list:]
1. **[Severity: High/Med/Low]** [Issue description]
   - Location: [file:line]
   - Impact: [why this matters]
   - Suggestion: [specific fix]

[If no issues: "No blocking issues found."]

## Recommendations
[Optional improvements, not blockers:]
- [Specific suggestion with rationale]

## Decision
**[APPROVE / REQUEST CHANGES / COMMENT]**

[If requesting changes: "X items must be addressed before merge."]
[If approving: "Ready to merge once tests pass."]
```

**Checkpoint**: Review saved to `/tmp/pr-review.md`.

## Stage 4: Finalize

1. Show review summary to user (Summary + Decision sections only)
2. Ask: "Save this review to feature directory? (yes/no)"
3. If yes: `bash ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/skills/specimin-review/scripts/save-review.sh "$BRANCH" /tmp/pr-review.md`
4. Parse JSON output (includes `review_number` and `review_path`)
5. Confirm: "✓ Review #[review_number] saved to `[review_path]`"

## Examples

### Example 1: Complete Implementation

**Spec criteria**: User auth with JWT, password reset, session management
**Plan components**: AuthService, TokenHandler, ResetController, SessionStore
**Changed files**: `services/auth.ts`, `handlers/token.ts`, `controllers/reset.ts`, `stores/session.ts`, `__tests__/auth.test.ts`

**Review summary**:
```
## Summary
Implements complete user authentication system with JWT tokens, password reset flow, and session management. All planned components present with comprehensive test coverage.

## Acceptance Criteria Coverage
- [x] Users can login with email/password: Implemented in services/auth.ts:45
- [x] JWT tokens for authentication: Implemented in handlers/token.ts:12
- [x] Password reset via email: Implemented in controllers/reset.ts:78
- [x] Sessions persist 7 days: Configured in stores/session.ts:23

## Alignment with Plan
- ✓ AuthService: Found in services/auth.ts
- ✓ TokenHandler: Found in handlers/token.ts
- ✓ ResetController: Found in controllers/reset.ts
- ✓ SessionStore: Found in stores/session.ts

## Testing Completeness
- Unit tests: Present - 23 test cases covering auth flows
- Integration tests: Present - E2E login/logout/reset tests
- Edge cases: Covered - expired tokens, invalid credentials, concurrent sessions

## Issues Found
No blocking issues found.

## Decision
**APPROVE** - Ready to merge once tests pass.
```

### Example 2: Incomplete Implementation

**Spec criteria**: Payment processing with Stripe, refund handling, webhook events
**Plan components**: PaymentService, WebhookHandler, RefundService
**Changed files**: `services/payment.ts`, `handlers/webhook.ts`

**Review summary**:
```
## Summary
Implements Stripe payment processing and webhook handling. Refund functionality missing from implementation.

## Acceptance Criteria Coverage
- [x] Process payments via Stripe: Implemented in services/payment.ts:34
- [x] Handle webhook events: Implemented in handlers/webhook.ts:12
- [ ] Support refunds: **MISSING** - No RefundService found
- [~] Retry failed charges: **PARTIAL** - Retry logic present but no exponential backoff

## Alignment with Plan
- ✓ PaymentService: Found in services/payment.ts
- ✓ WebhookHandler: Found in handlers/webhook.ts
- ✗ RefundService: Not found - expected services/refund.ts

## Testing Completeness
- Unit tests: Present - PaymentService covered
- Integration tests: Missing - No webhook event tests found
- Edge cases: Missing - Network failures, invalid webhooks not tested

## Issues Found
1. **[High]** Refund functionality missing
   - Location: services/refund.ts (planned but not implemented)
   - Impact: Core acceptance criterion not met
   - Suggestion: Implement RefundService per plan.md:67

2. **[Medium]** No webhook integration tests
   - Location: __tests__/webhook.test.ts (expected per plan testing strategy)
   - Impact: Webhook handling untested end-to-end
   - Suggestion: Add tests for all webhook event types

3. **[Low]** Retry lacks exponential backoff
   - Location: services/payment.ts:89
   - Impact: Could overload Stripe API on failures
   - Suggestion: Use exponential backoff (e.g., 1s, 2s, 4s delays)

## Decision
**REQUEST CHANGES** - 3 items must be addressed before merge.
```

---

**Optimization Notes**:
- Scripts handle data gathering (deterministic) → 60% token savings
- Model focuses on analysis (cognitive) → better quality
- Structured format → consistent, actionable feedback
- Context-aware (spec/plan) → meaningful review vs generic code review
- Prioritized (completeness > alignment > quality > style) → efficient attention allocation

**Research-backed**: Structured prompting (+13.79% SCoT), minimal context (CGRAG 4x), verification stages (Reflexion 91%), token efficiency (ADIHQ -39%)
