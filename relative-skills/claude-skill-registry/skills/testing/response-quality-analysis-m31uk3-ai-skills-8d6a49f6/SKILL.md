---
name: response-quality-analysis
description: "Analyze whether your response addresses the actual question asked before posting. Use when: (1) About to post response to forum/Slack question, (2) Want to validate response coverage, (3) Need to ensure solving the right problem, (4) Want specific improvement suggestions for gaps in response"
license: Public domain - shared for AI engineering community
---

# Response Quality Analysis

Validates that your response actually solves the problem asked, not the problem you're comfortable addressing. Systematically analyzes problem quality, decomposes into components, calculates coverage, and provides actionable improvements.

## When to Use

Before posting substantive answers to:
- Forum questions (Slack, internal channels, Stack Overflow)
- Mailing list responses
- Documentation contributions
- Any situation where you want to ensure helpfulness

## Quick Start

Ask user for:
- `original_problem` - The question/problem statement
- `draft_response` - Your proposed answer
- `response_context` - Where posting (optional)
- `work_dir` - Artifact location (default: ".sop/response-analysis")

Support multiple input methods: direct paste, screenshot, link, file.

## Workflow

### 1. Problem Intake Validation (Score: X/5)

Check original problem for required elements:

1. ✅ Specific question (concrete, not "help me with X")
2. ✅ Current state (what exists now)
3. ✅ Desired state (what "solved" looks like)
4. ⚠️ Constraints (environment, tools, culture)
5. ❌ Prior attempts (what's been tried)

**Scoring:**
- ✅ Present (clearly stated)
- ⚠️ Partial (mentioned but vague)
- ❌ Missing (not addressed)

Save to `{work_dir}/intake-validation.md`

**Present to user:**
```
Problem Quality: X/5 elements

✅ Present: [list with evidence]
⚠️ Partial: [list with what's unclear]
❌ Missing: [list with why needed]

Options:
[A] Proceed (score >= 3/5)
[B] Generate clarifying questions for OP
[C] Note limitations, proceed anyway
[D] Too vague - cannot analyze
```

**MUST NOT proceed if < 3/5 without user confirmation**

### 2. Problem Decomposition (N components)

Extract components ONLY from evidence in original problem.

**Format each:**
```markdown
## Component: [Name]

**Evidence:** "[Direct quote]"
**What they're asking:** [Specific need]
**Success criteria:** [Observable outcome]
**Priority:** Critical / Important / Nice-to-have
```

Priority based on:
- Critical: Core to question, must address
- Important: Explicitly mentioned or strongly implied
- Nice-to-have: Would add value, not strictly necessary

Target: 2-5 components (more = not distinct)

Save to `{work_dir}/decomposition.md`

**Checkpoint:**
```
I've identified [N] components:
1. [Name] - [Priority] - [One line]
2. [Name] - [Priority] - [One line]

Questions:
- Match your understanding?
- Missed or incorrect components?
- Adjust priorities?
```

**MUST get user confirmation before proceeding**

### 3. Coverage Analysis (Overall: Y%)

Map draft response to each component.

**Coverage calculation:**
- 0% - Not mentioned
- 1-40% - Mentioned but vague (no specifics)
- 41-80% - Addressed with details but incomplete
- 81-100% - Fully addressed, concrete, actionable

**For each component:**
```markdown
## Component: [Name] - Coverage: X%

**Needed:** [Success criteria]

**Provided:** "[Quote from response]"

**Analysis:**
✅ Strengths: [What covered well]
❌ Gaps: [What missing/vague]
📏 Specificity: [Concrete enough?]

**Justification:** [Why this score]
```

**Calculate weighted coverage:**
- Critical: 2x weight
- Important: 1x weight
- Nice-to-have: 0.5x weight

**Coverage Matrix:**
```
Component      | Priority  | Coverage | Weight | Contribution
--------------------------------------------------------
[Name]         | Critical  | X%      | 2.0    | Y
[Name]         | Important | X%      | 1.0    | Y
```

Save to `{work_dir}/coverage-analysis.md`

**MUST NOT inflate scores - be honest**

### 4. Context Grounding Check

Verify response fits original context.

**Check for:**

1. **Environment mismatch:**
   - Different org structure?
   - Requires tools/processes not mentioned?
   - Assumes different culture?

2. **Problem substitution:**
   - Solving YOUR past problem?
   - Related but different problem?
   - More general problem?

3. **Constraint violation:**
   - Violates stated constraints?
   - Requires unavailable resources?
   - Assumes capabilities they lack?

**Document each:**
```markdown
## Mismatch: [Type]
**They have:** [Their context]
**You assumed:** [Your assumption]
**Impact:** [Why matters]
**Severity:** Minor / Moderate / Critical
```

**Summary:**
```
Context Grounding: Strong / Moderate / Weak
- Environment: Matches / Partial / Mismatches
- Problem: Same / Related / Different  
- Constraints: Respected / Some violations / Major violations
```

Save to `{work_dir}/context-check.md`

**Ask:**
```
Are you solving THEIR problem or similar one you faced?
[A] Their exact problem
[B] Similar (need to adapt)
[C] Different (reconsider approach)
```

### 5. Response Quality Validation (Z/6 tests)

Run testable conditions:

**Test 1: Restatement** (Pass/Fail)
- Can you restate problem accurately?
- Would OP say "yes, that's it"?

**Test 2: Coverage** (Pass/Partial/Fail)
- Weighted coverage >= 80%? (Pass)
- All Critical >= 80%? (Pass)
- >= 60% OR Criticals >= 60%? (Partial)

**Test 3: Specificity** (Pass/Partial/Fail)
- Can implement tomorrow?
- Includes concrete mechanisms?

**Test 4: Gap Acknowledgment** (Pass/Fail)
- Explicitly stated what not addressed?

**Test 5: Context Grounding** (Pass/Partial/Fail)
- Fits their environment?
- No critical mismatches?

**Test 6: Implementation Path** (Pass/Partial/Fail)
- Can trace: current → advice → solved?
- Steps connected without gaps?

**Scoring:**
- Pass = 1.0
- Partial = 0.5
- Fail = 0.0

**Present:**
```
Response Quality Assessment
===========================

Coverage: X% (weighted)
Quality Score: Y/6 tests

✅ PASS: [list]
⚠️ PARTIAL: [list]
❌ FAIL: [list]

Overall: Excellent / Good / Needs Work / Poor

Critical Gap: [Most important missing piece]

Recommendation: [Specific action]
```

Save to `{work_dir}/validation-results.md`

**MUST be honest - don't inflate**

### 6. Improvement Suggestions

For each gap (coverage < 80%):

```markdown
## Gap: [Component] - Currently X% coverage

**What's missing:** [Specific elements needed]

**Current text:** "[Quote or indicate missing]"

**Suggested addition:**
"[Concrete text to add - be specific enough to copy/paste]"

**Why helps:** [How addresses gap]

**Priority:** Critical / Important / Enhancement
```

Order by priority (Critical first)

**MUST NOT provide vague suggestions:**
❌ "Add more detail"  
✅ "Add: 'For intake, create shared spreadsheet where Teams A,B,C submit requests with [fields]...'"

**Present:**
```
Improvement Suggestions
======================

I've identified [N] gaps:

Critical (must fix):
1. [Component]: [Gap summary]

Important (should fix):
2. [Component]: [Gap summary]

Which gaps address?
[A] All critical
[B] Critical + important
[C] Specific gaps (which?)
[D] None - proceed to decision
```

Save to `{work_dir}/improvements.md`

### 7. Revision Support (if requested)

Work on ONE gap at a time.

**For each:**
```
Revision: [Component]
=====================

Coverage: X% → Target: Y%

--- BEFORE ---
[Current text or "Not addressed"]

--- SUGGESTED ADDITION ---
[New text]

--- INTEGRATED RESULT ---
[How fits into full response]

New coverage: Y%

Approve?
[A] Yes, apply
[B] Modify (how?)
[C] Skip this gap
```

**MUST:**
- Wait for approval on each
- Update `{work_dir}/draft-response.md`
- Track in `{work_dir}/revision-history.md`
- Re-run coverage analysis after all revisions

**Show impact:**
```
Revision Impact
===============

Before: X% coverage, Y/6 quality
After:  X% coverage, Y/6 quality

Improved:
- [Component]: X% → Y%
- [Test]: FAIL → PASS
```

### 8. Decision Point

**Present final assessment:**
```
Final Response Assessment
=========================

Problem Quality: X/5
Response Coverage: Y%
Quality Score: Z/6

Overall: [Excellent/Good/Acceptable/Needs Work/Poor]

Strengths:
- [What covered well]

Remaining Gaps:
- [Critical/important gaps]

Context Alignment: [Strong/Adequate/Weak]

Recommendation: [Specific advice]

Options:

[A] Post as-is
    → Coverage adequate
    → Acknowledge limitations

[B] Make revisions
    → Address: [gaps]
    → Expected: X% → Y%

[C] Reconsider approach
    → May not fit context
    → Consider: [alternative]

[D] Request clarification first
    → Missing: [what need]
    → Generate questions

[E] Don't post
    → Coverage too low
    → Start over
```

**MUST NOT recommend posting if:**
- Critical components < 50% coverage
- Severe context mismatches
- Quality score < 3/6

Save to `{work_dir}/final-assessment.md`

### 9. Post-Response Support (optional)

If posting, offer help with:

**[A] Gap acknowledgment section:**
```
"This addresses [covered], but doesn't cover [gaps].
For [gap], consider [pointer]."
```

**[B] Frame limitations appropriately**
- Don't over-apologize
- Frame as "areas for discussion"

**[C] Add clarifying questions to OP**

**[D] Format for platform** (Slack/forum)

Save final to `{work_dir}/final-response.md`

### 10. Learning Capture (optional)

Document insights in `{work_dir}/learnings.md`:

```markdown
## Common Issue: [Pattern]
Example: "I solve feature overlap vs dependency coordination"

## Improvement
Watch for: [What to check next time]

## Meta-patterns
[Recurring blind spots]
```

Offer: "Analyze past responses for patterns?"

## Example: Slack Response

**Problem (3/5 quality):**
"How to handle multiple xfn dependency requests? Work flying everywhere (left diagram). Want centralized coordination (right diagram)."

**Components identified:**
1. Intake mechanism (Critical) - 40% coverage
2. Prioritization framework (Critical) - 0% coverage  
3. Communication (Important) - 30% coverage
4. Transition path (Important) - 10% coverage

**Initial coverage: 16% weighted**

**Critical gap:** No prioritization method

**After revisions: 68% coverage**

**Key improvement:**
Added concrete prioritization mechanism:
"Establish weekly dependency review where TPM scores requests by impact/urgency/capacity, publishes priority queue visible to all requesters."

## Troubleshooting

**Low coverage despite effort:**
- Solving related but different problem
- Go back to decomposition - reread question
- Map each paragraph to components
- Cut unmapped content

**Context mismatches:**
- List all assumptions made
- Check each against original
- Use conditional language: "If you have X..."

**Tests pass but feels wrong:**
- Being too generous with scores
- Re-read original fresh
- Ask: "Would this satisfy me?"

**Takes too long:**
- Simple questions: Skip to Step 3
- Obvious gaps: Skip validation
- Use judgment on rigor needed

## Quick Heuristics

- Simple factual Q → Don't need full process
- Advice/approach Q → Use full process
- Vague/complex Q → Definitely use full process

## Key Constraints

- MUST ask for both original_problem and draft_response upfront
- MUST NOT proceed with analysis if problem score < 3/5 without confirmation
- MUST NOT add components without evidence in original text
- MUST NOT inflate coverage scores - be honest
- MUST wait for user confirmation at checkpoints
- MUST work on one revision at a time with approval
- MUST NOT recommend posting if critical components < 50% or quality < 3/6

## Meta-Validation

Before completing, verify:
- [ ] All 5 phases executed
- [ ] User confirmed at checkpoints
- [ ] Coverage honestly assessed
- [ ] Context mismatches identified
- [ ] Specific improvements provided
- [ ] Final recommendation justified

## Version

v1.0 - Based on universal AI workflow pattern, tested with real Slack example
