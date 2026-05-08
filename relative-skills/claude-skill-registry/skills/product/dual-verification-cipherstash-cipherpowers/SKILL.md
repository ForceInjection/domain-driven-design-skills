---
name: dual-verification
description: Use two independent agents for reviews or research, then collate findings to identify common findings, unique insights, and divergences
when_to_use: comprehensive audits, plan reviews, code reviews, research tasks, codebase exploration, verifying content matches implementation, quality assurance for critical content
version: 1.0.0
---

# Dual Verification Review

## Overview

Use two independent agents to systematically review content or research a topic, then use a collation agent to compare findings.

**Core principle:** Independent dual perspective + systematic collation = higher quality, managed context.

**Announce at start:** "I'm using the dual-verification skill for comprehensive [review/research]."

## When to Use

Use dual-verification when:

**For Reviews:**
- **High-stakes decisions:** Before executing implementation plans, merging to production, or deploying
- **Comprehensive audits:** Documentation accuracy, plan quality, code correctness
- **Quality assurance:** Critical content that must be verified against ground truth
- **Risk mitigation:** When cost of missing issues exceeds cost of dual review

**For Research:**
- **Codebase exploration:** Understanding unfamiliar code from multiple angles
- **Problem investigation:** Exploring a bug or issue with different hypotheses
- **Information gathering:** Researching a topic where completeness matters
- **Architecture analysis:** Understanding system design from different perspectives
- **Building confidence:** When you need high-confidence understanding before proceeding

**Don't use when:**
- Simple, low-stakes changes (typo fixes, minor documentation tweaks)
- Time-critical situations (production incidents requiring immediate action)
- Single perspective is sufficient (trivial updates, following up on previous review)
- Cost outweighs benefit (quick questions with obvious answers)

## Quick Reference

| Phase | Action | Output | User Action |
|-------|--------|--------|-------------|
| **Phase 1** | Dispatch 2 agents in parallel | Two independent reports | Wait |
| **Phase 2** | Collate findings, present to user | Collated report | Can `/revise common` |
| **Phase 3** | Cross-check exclusive issues (background) | Validated exclusive issues | Can `/revise exclusive` or `/revise all` |

**Confidence levels:**
- **VERY HIGH:** Both agents found (high confidence - act on this)
- **MODERATE:** One agent found (unique insight - needs cross-check)
- **INVESTIGATE:** Agents disagree (resolved during collation)

**Exclusive issue states (after cross-check):**
- **VALIDATED:** Cross-check confirmed issue exists → implement
- **INVALIDATED:** Cross-check found issue doesn't apply → skip
- **UNCERTAIN:** Cross-check couldn't determine → user decides

## Why This Pattern Works

**Higher quality through independence:**
- Common findings = high confidence (both found)
- Exclusive findings = unique insights one agent caught → validated by cross-check
- Divergences = resolved during collation

**Context management:**
- Two detailed reviews = lots of context
- Collation agent does comparison work
- Cross-check runs in background while user reviews
- Main context gets clean summary

**Confidence progression:**
- Both found → VERY HIGH → Fix immediately (`/revise common`)
- One found → MODERATE → Cross-check validates → VALIDATED/INVALIDATED/UNCERTAIN
- Disagree → INVESTIGATE → Resolved during collation

**Parallel workflow:**
- User gets collation results immediately
- Can start `/revise common` while cross-check runs
- Cross-check completes → `/revise exclusive` or `/revise all`

## The Three-Phase Process

### Phase 1: Dual Independent Review

**Dispatch 2 agents in parallel with identical prompts.**

**Agent prompt template:**
```
You are [agent type] conducting an independent verification review.

**Context:** You are one of two agents performing parallel independent reviews. Another agent is reviewing the same content independently. A collation agent will later compare both reviews.

**Your task:** Systematically verify [subject] against [ground truth].

**Critical instructions:**
- Current content CANNOT be assumed correct. Verify every claim.
- You MUST follow the review report template structure
- Template location: ${CLAUDE_PLUGIN_ROOT}templates/verify-template.md
- You MUST save your review with timestamp: `.work/{YYYY-MM-DD}-verify-{type}-{HHmmss}.md`
- Time-based naming prevents conflicts when agents run in parallel.
- Work completely independently - the collation agent will find and compare all reviews.

**Process:**

1. Read the review report template to understand the expected structure
2. Read [subject] completely
3. For each [section/component/claim]:
   - Identify what is claimed
   - Verify against [ground truth]
   - Check for [specific criteria]

4. Categorize issues by:
   - Category ([issue type 1], [issue type 2], etc.)
   - Location (file/section/line)
   - Severity ([severity levels])

5. For each issue, provide:
   - Current content (what [subject] says)
   - Actual [ground truth] (what is true)
   - Impact (why this matters)
   - Action (specific recommendation)

6. Save using template structure with all required sections

**The template provides:**
- Complete structure for metadata, issues, summary, assessment
- Examples of well-written reviews
- Guidance on severity levels and categorization
```

**Example: Documentation Review**
- Agent type: technical-writer
- Subject: README.md and CLAUDE.md
- Ground truth: current codebase implementation
- Criteria: file paths exist, commands work, examples accurate

**Example: Plan Review**
- Agent type: plan-review-agent
- Subject: implementation plan
- Ground truth: 35 quality criteria (security, testing, architecture, etc.)
- Criteria: blocking issues, non-blocking improvements

**Example: Code Review**
- Agent type: code-review-agent
- Subject: implementation code
- Ground truth: coding standards, plan requirements
- Criteria: meets requirements, follows standards, has tests

### Phase 2: Collate Findings and Present

**Dispatch collation agent to compare the two reviews, then present to user immediately.**

**Dispatch collation agent:**
```
Use Task tool with:
  subagent_type: "cipherpowers:review-collation-agent"
  description: "Collate dual [review type] reviews"
  prompt: "You are collating two independent [review type] reviews.

**Critical instructions:**
- You MUST follow the collation report template structure
- Template location: ${CLAUDE_PLUGIN_ROOT}templates/verify-collation-template.md
- Read the template BEFORE starting collation
- Save to: `.work/{YYYY-MM-DD}-verify-{type}-collated-{HHmmss}.md`

**Inputs:**
- Review #1: [path to first review file]
- Review #2: [path to second review file]

**Your task:**

1. **Read the collation template** to understand the required structure

2. **Parse both reviews completely:**
   - Extract all issues from Review #1
   - Extract all issues from Review #2
   - Create internal comparison matrix

3. **Identify common issues** (both found):
   - Same issue found by both reviewers
   - Confidence: VERY HIGH

4. **Identify exclusive issues** (only one found):
   - Issues found only by Agent #1
   - Issues found only by Agent #2
   - Confidence: MODERATE (pending cross-check)

5. **Identify divergences** (agents disagree):
   - Same location, different conclusions
   - Contradictory findings

6. **IF divergences exist → Verify with appropriate agent:**
   - Dispatch verification agent for each divergence
   - Provide both perspectives and specific divergence point
   - Incorporate verification analysis into report

7. **Follow template structure for output:**
   - Metadata section (complete all fields)
   - Executive summary (totals and breakdown)
   - Common issues (VERY HIGH confidence)
   - Exclusive issues (MODERATE confidence - pending cross-check)
   - Divergences (with verification analysis)
   - Recommendations (categorized by action type)
   - Overall assessment

**The template provides:**
- Complete structure with all required sections
- Examples of well-written collation reports
- Guidance on confidence levels and categorization
- Usage notes for proper assessment
```

**Present collated report to user immediately:**

```
Collation complete. Report saved to: [path]

**Summary:**
- Common issues: X (VERY HIGH confidence) → Can `/revise common` now
- Exclusive issues: X (MODERATE - cross-check starting)
- Divergences: X (resolved/unresolved)

**Status:** Cross-check running in background...
```

**User can now `/revise common` while cross-check runs.**

### Phase 3: Cross-check Exclusive Issues

**Dispatch cross-check agent to validate exclusive issues against the codebase/implementation.**

This phase runs in the background after presenting collation to user.

**Purpose:** Exclusive issues have MODERATE confidence because only one reviewer found them. Cross-check validates whether the issue actually exists by checking against ground truth.

**Dispatch cross-check agent:**
```
Use Task tool with:
  subagent_type: "[appropriate agent for review type]"
  description: "Cross-check exclusive issues"
  prompt: "You are cross-checking exclusive issues from a dual-verification review.

**Context:**
Two independent reviewers performed a [review type] review. The collation identified
issues found by only one reviewer (exclusive issues). Your task is to validate
whether each exclusive issue actually exists.

**Collation report:** [path to collation file]

**Your task:**

For EACH exclusive issue in the collation report:

1. **Read the issue description** from the collation report
2. **Verify against ground truth:**
   - For doc reviews: Check if the claim is accurate against codebase
   - For code reviews: Check if the issue exists in the implementation
   - For plan reviews: Check if the concern is valid against requirements
3. **Assign validation status:**
   - VALIDATED: Issue confirmed to exist → should be addressed
   - INVALIDATED: Issue does not apply → can be skipped
   - UNCERTAIN: Cannot determine → escalate to user

**Output format:**
For each exclusive issue, provide:
- Issue: [from collation]
- Source: Reviewer #[1/2]
- Validation: [VALIDATED/INVALIDATED/UNCERTAIN]
- Evidence: [what you found that supports your conclusion]
- Recommendation: [action to take]

**Save to:** `.work/{YYYY-MM-DD}-verify-{type}-crosscheck-{HHmmss}.md`
```

**Agent selection for cross-check:**
| Review Type | Cross-check Agent |
|-------------|-------------------|
| docs | cipherpowers:code-agent (verify against implementation) |
| code | cipherpowers:code-agent (verify against codebase) |
| plan | cipherpowers:plan-review-agent (verify against requirements) |
| execute | cipherpowers:execute-review-agent (verify against plan) |

**When cross-check completes:**

```
Cross-check complete. Report saved to: [path]

**Exclusive Issues Status:**
- VALIDATED: X issues (confirmed, should address)
- INVALIDATED: X issues (can skip)
- UNCERTAIN: X issues (user decides)

**Ready for:** `/revise exclusive` or `/revise all`
```

**Update collation report with cross-check results:**
- Read original collation file
- Update exclusive issues section with validation status
- Save updated collation (overwrite or append cross-check section)

## Parameterization

Make the pattern flexible by specifying:

**Subject:** What to review
- Documentation files (README.md, CLAUDE.md)
- Implementation plans (plan.md)
- Code changes (git diff, specific files)
- Test coverage (test files)
- Architecture decisions (design docs)

**Ground truth:** What to verify against
- Current implementation (codebase)
- Quality criteria (35-point checklist)
- Coding standards (practices)
- Requirements (specifications)
- Design documents (architecture)

**Agent type:** Which specialized agent to use
- technical-writer (documentation)
- plan-review-agent (plans)
- code-review-agent (code)
- rust-agent (Rust-specific)
- ultrathink-debugger (complex issues)

**Granularity:** How to break down review
- Section-by-section (documentation)
- Criteria-by-criteria (plan review)
- File-by-file (code review)
- Feature-by-feature (architecture review)

**Severity levels:** How to categorize issues
- critical/high/medium/low (general)
- BLOCKING/NON-BLOCKING (plan/code review)
- security/performance/maintainability (code review)

## When NOT to Use

**Skip dual verification when:**
- Simple, low-stakes changes (typo fixes)
- Time-critical situations (production incidents)
- Single perspective sufficient (trivial updates)
- Cost outweighs benefit (minor documentation tweaks)

**Use single agent when:**
- Regular incremental updates
- Following up on dual review findings
- Implementing approved changes

## Example Usage: Plan Review

```
User: Review this implementation plan before execution

You: I'm using the dual-verification skill for comprehensive review.

Phase 1: Dual Independent Review
  → Dispatch 2 plan-review-agent agents in parallel
  → Each applies 35 quality criteria independently
  → Agent #1 finds: 3 BLOCKING issues, 7 NON-BLOCKING
  → Agent #2 finds: 4 BLOCKING issues, 5 NON-BLOCKING

Phase 2: Collate Findings and Present
  → Dispatch review-collation-agent
  → Collator compares both reviews
  → Present to user immediately:

  Collated Report:
    Common Issues (VERY HIGH):
      - 2 BLOCKING issues both found
      - 3 NON-BLOCKING issues both found

    Exclusive Issues (MODERATE - cross-check starting):
      - Agent #1 only: 1 BLOCKING, 4 NON-BLOCKING
      - Agent #2 only: 2 BLOCKING, 2 NON-BLOCKING

    Divergences: None

  → User notified: "Can `/revise common` now. Cross-check running..."

Phase 3: Cross-check Exclusive Issues (background)
  → Dispatch plan-review-agent to validate exclusive issues
  → For each exclusive issue, verify against requirements
  → Results:
    - VALIDATED: 2 issues confirmed
    - INVALIDATED: 3 issues don't apply
    - UNCERTAIN: 1 issue needs user decision

  → User notified: "Cross-check complete. `/revise exclusive` or `/revise all`"
```

## Example Usage: Documentation Review

```
User: Audit README.md and CLAUDE.md for accuracy

You: I'm using the dual-verification skill for comprehensive documentation audit.

Phase 1: Dual Independent Review
  → Dispatch 2 technical-writer agents in parallel
  → Each verifies docs against codebase
  → Agent #1 finds: 13 issues (1 critical, 3 high, 6 medium, 3 low)
  → Agent #2 finds: 13 issues (4 critical, 1 high, 4 medium, 4 low)

Phase 2: Collate Findings and Present
  → Dispatch review-collation-agent
  → Identifies: 7 common, 6 exclusive, 0 divergences
  → Present to user immediately:

  Collated Report:
    Common Issues (VERY HIGH): 7
      - Missing mise commands (CRITICAL)
      - Incorrect skill path (MEDIUM)
      - Missing /verify command (HIGH)

    Exclusive Issues (MODERATE - cross-check starting): 6
      - Agent #1 only: 3 issues
      - Agent #2 only: 3 issues

  → User notified: "Can `/revise common` now. Cross-check running..."

Phase 3: Cross-check Exclusive Issues (background)
  → Dispatch code-agent to verify exclusive claims against codebase
  → Results:
    - VALIDATED: 4 issues (paths really don't exist, examples really broken)
    - INVALIDATED: 2 issues (files exist, agent #1 missed them)
    - UNCERTAIN: 0 issues

  → User notified: "Cross-check complete. `/revise exclusive` or `/revise all`"
```

## Example Usage: Codebase Research

```
User: How does the authentication system work in this codebase?

You: I'm using the dual-verification skill for comprehensive research.

Phase 1: Dual Independent Research
  → Dispatch 2 Explore agents in parallel
  → Each investigates auth system independently
  → Agent #1 finds: JWT middleware, session handling, role-based access
  → Agent #2 finds: OAuth integration, token refresh, permission checks

Phase 2: Collate Findings and Present
  → Dispatch review-collation-agent
  → Identifies: 4 common findings, 3 unique insights, 1 divergence
  → Resolves divergence during collation
  → Present to user immediately:

  Collated Report:
    Common Findings (VERY HIGH): 4
      - JWT tokens used for API auth (both found)
      - Middleware in src/auth/middleware.ts (both found)
      - Role enum defines permissions (both found)
      - Refresh tokens stored in Redis (both found)

    Exclusive Findings (MODERATE - cross-check starting): 3
      - Agent #1: Found legacy session fallback for admin routes
      - Agent #2: Found OAuth config for SSO integration
      - Agent #2: Found rate limiting on auth endpoints

    Divergence (RESOLVED):
      - Token expiry: Agent #1 says 1 hour, Agent #2 says 24 hours
      - → Verification: Config has 1h access + 24h refresh (both partially correct)

  → User notified: "Common findings ready. Cross-check running..."

Phase 3: Cross-check Exclusive Findings (background)
  → Dispatch Explore agent to verify exclusive claims
  → Results:
    - VALIDATED: All 3 findings confirmed in codebase
    - INVALIDATED: 0
    - UNCERTAIN: 0

  → User notified: "Cross-check complete. All exclusive findings validated."
```

## Related Skills

**When to use this skill:**
- Comprehensive reviews before major actions
- High-stakes decisions (execution, deployment, merge)
- Quality assurance for critical content

**Related commands:**
- `/cipherpowers:verify` - Dispatches this skill for all verification types
- `/cipherpowers:revise` - Implements findings from verification (common, exclusive, all scopes)

**Other review skills:**
- verifying-plans: Single plan-review-agent (faster, less thorough)
- conducting-code-review: Single code-review-agent (regular reviews)
- maintaining-docs-after-changes: Single technical-writer (incremental updates)

**Use dual-verification when stakes are high, use single-agent skills for regular work.**

## Common Mistakes

**Mistake:** "The reviews mostly agree, I'll skip detailed collation"
- **Why wrong:** Exclusive issues and subtle divergences matter
- **Fix:** Always use collation agent for systematic comparison

**Mistake:** "This exclusive issue is probably wrong since other reviewer didn't find it"
- **Why wrong:** May be valid edge case one reviewer caught
- **Fix:** Present with MODERATE confidence for user judgment, don't dismiss

**Mistake:** "I'll combine both reviews myself instead of using collation agent"
- **Why wrong:** Context overload, missing patterns, inconsistent categorization
- **Fix:** Always dispatch collation agent to handle comparison work

**Mistake:** "Two agents is overkill, I'll just run one detailed review"
- **Why wrong:** Missing the independence that catches different perspectives
- **Fix:** Use dual verification for high-stakes, single review for regular work

**Mistake:** "The divergence is minor, I'll pick one perspective"
- **Why wrong:** User needs to see both perspectives and make informed decision
- **Fix:** Mark as INVESTIGATE and let user decide

## Remember

- Dispatch 2 agents in parallel for Phase 1 (efficiency)
- Use identical prompts for both agents (fairness)
- Dispatch collation agent for Phase 2 (context management)
- Present collation to user immediately after Phase 2 (user can `/revise common`)
- Dispatch cross-check agent for Phase 3 in background (parallel workflow)
- Common issues = VERY HIGH confidence (both found) → implement immediately
- Exclusive issues = MODERATE confidence → cross-check validates → VALIDATED/INVALIDATED/UNCERTAIN
- Divergences = resolved during collation (verification agent determines correct perspective)
- Cross-check enables parallel workflow: user starts `/revise common` while cross-check runs
- Cost-benefit: Use for high-stakes, skip for trivial changes