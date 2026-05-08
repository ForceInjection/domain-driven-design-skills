---
name: qualitative-research
description: Use when conducting customer discovery interviews, user research, surveys, focus groups, or observational research requiring rigorous analysis - provides systematic 6-phase framework with mandatory bias prevention (reflexivity, intercoder reliability, disconfirming evidence search) and reproducible methodology; peer to hypothesis-testing for qualitative vs quantitative validation
---

# Qualitative Research

## Overview

Systematic framework for conducting and analyzing qualitative research (interviews, surveys, focus groups, observations) with rigorous bias prevention and reproducible methodology.

**Core principle:** Rigor through mandatory checkpoints. Prevent confirmation bias by enforcing disconfirming evidence search, intercoder reliability, and reflexivity documentation.

**Peer to hypothesis-testing:** hypothesis-testing validates quantitative hypotheses with data analysis. qualitative-research validates qualitative hypotheses with systematic interview/survey analysis.

## When to Use

Use this skill when:
- Conducting customer discovery interviews to validate demand
- Running user research to understand pain points
- Analyzing survey responses for themes and patterns
- Conducting focus groups or observational research
- ANY qualitative data collection and analysis requiring rigorous, reproducible methodology

When NOT to use:
- Quantitative data analysis (use hypothesis-testing instead)
- Casual conversations or informal feedback (not systematic research)
- Literature review or secondary research (use internet-researcher agent)

## Mandatory Process Structure

**YOU MUST use TodoWrite to track progress through all 6 phases.**

Create todos at the start:

```markdown
- Phase 1: Research Design (question, method, instrument, biases) - pending
- Phase 2: Data Collection (execute protocol, track saturation) - pending
- Phase 3: Data Familiarization (immerse without coding) - pending
- Phase 4: Systematic Coding (codebook, reliability check) - pending
- Phase 5: Theme Development (build themes, search disconfirming evidence) - pending
- Phase 6: Synthesis & Reporting (findings, limitations, follow-ups) - pending
```

Update status as you progress. Mark phases complete ONLY after checkpoint verification.

**Flexible Entry:** If user has existing data (transcripts, survey responses), can start at Phase 3. Verify raw data exists in `raw-data/` directory.

---

## Phase 1: Research Design

**CHECKPOINT:** Before proceeding to Phase 2, you MUST have:
- [ ] Research question defined (specific, testable)
- [ ] Qualitative method selected (interview/survey/focus group/observation)
- [ ] Collection instrument created (interview guide, survey questions, protocol)
- [ ] Sampling strategy documented (who, how many, recruitment)
- [ ] **Reflexivity baseline documented** (YOUR assumptions and biases written down)
- [ ] Saved to `01-research-design.md`

### Instructions

1. **Select method and load appropriate template:**
   - Interview → Use `templates/interviews/phase-1-interview-guide.md`
   - Survey → Use `templates/surveys/phase-1-survey-design.md`
   - Focus Group → Use `templates/focus-groups/phase-1-facilitator-guide.md`
   - Observation → Use `templates/observations/phase-1-observation-protocol.md`

2. **Document reflexivity baseline (MANDATORY):**

**This is NON-NEGOTIABLE.** Before any data collection, write down:
- What you believe the answer will be
- What assumptions you're making
- What biases you bring (industry experience, expert opinions, prior hypotheses)
- What would surprise you

**Why this matters:** If you don't document biases BEFORE data collection, you cannot identify confirmation bias AFTER.

3. **Create neutral questions (use template guidance):**

Templates enforce neutral question design. Common mistakes:
- Leading: "How much would you pay for X?" (assumes they want X)
- Neutral: "How do you currently solve Y problem?" (explores actual behavior)

4. **Plan adequate sample size:**
- Interviews: Minimum 8-10 for saturation monitoring
- Surveys: Depends on question type and analysis goals
- Focus groups: 3-5 groups minimum
- Observations: Plan for 10-20 observation sessions

5. **Save to `01-research-design.md` using template**

6. **STOP and verify checkpoint:** Cannot proceed to Phase 2 until reflexivity baseline documented.

### Common Rationalization: "I don't have biases to document"

**Why this is wrong:** Everyone has assumptions. If you can't name them, they're controlling you invisibly.

**Do instead:** Write one sentence: "I believe [X] because [Y]." That's your bias. Document it.

### Common Rationalization: "Expert opinion reduces need for bias documentation"

**Why this is wrong:** Expert opinion IS a bias that must be documented. Authority backing is a strong prior.

**Do instead:** "Expert A said B. This is my assumption going in. Must verify with data."

### Common Rationalization: "Time pressure means I can't do formal process"

**Why this is wrong:** Documenting assumptions takes 5 minutes. Presenting biased findings wastes hours.

**Do instead:** Set timer for 5 minutes. Write down assumptions. Move on.

---

## Phase 2: Data Collection

**CHECKPOINT:** Before proceeding to Phase 3, you MUST have:
- [ ] Minimum sample collected (Phase 1 plan executed)
- [ ] Saturation monitoring documented
- [ ] All raw data captured (transcripts, responses, field notes)
- [ ] Raw data files in `raw-data/` directory
- [ ] Reflexive journal maintained during collection
- [ ] Saved to `02-data-collection-log.md`

### Instructions

1. **Execute method-specific protocol:**
   - Use Phase 2 template for your selected method
   - Maintain consistency (same questions, same facilitator when possible)
   - Document context for each data collection instance

2. **Track toward saturation:**

**Saturation = when new insights stop emerging**

After each interview/session/survey batch, ask:
- Did this reveal new themes I hadn't seen?
- Or was this reinforcing existing patterns?

Document in collection log. Plan to continue until 2-3 consecutive instances add nothing new.

3. **Maintain reflexive journal (MANDATORY):**

After each data collection instance, write:
- What surprised you
- What confirmed your assumptions
- What contradicted your expectations
- How your thinking is evolving

**Why this matters:** Reflexivity tracks how your interpretation changes. Prevents retroactively fitting data to initial beliefs.

4. **Create raw data files:**

**File structure:**
```
raw-data/
├── transcript-001.md
├── transcript-002.md
├── ...
```

OR for surveys:
```
raw-data/
├── survey-responses-batch-1.md
├── survey-responses-batch-2.md
```

One file per interview/session. Numbered sequentially.

5. **Save collection log to `02-data-collection-log.md`**

6. **STOP and verify checkpoint:** Cannot proceed to Phase 3 until minimum sample collected and raw data captured.

---

## Phase 3: Data Familiarization

**CHECKPOINT:** Before proceeding to Phase 4, you MUST have:
- [ ] All raw data read/reviewed multiple times
- [ ] Initial observations documented (NOT codes, just observations)
- [ ] Surprising findings noted (contradictions to assumptions)
- [ ] Reflexivity updated (how understanding evolved)
- [ ] Saved to `03-familiarization-notes.md`

### Instructions

1. **Read ALL data without coding:**

**This is critical:** Do NOT start coding yet. Just read and observe.

**Why:** Premature coding locks you into first impressions. Familiarization lets patterns emerge naturally.

2. **For large datasets (10+ interviews), use analyze-transcript agent:**

```
Invoke: analyze-transcript agent
Input: transcript-001.md through transcript-010.md
Output: Summary, key quotes, initial observations per transcript
```

Agent prevents context pollution. Returns structured observations for your review.

3. **Document observations in `03-familiarization-notes.md`:**

**Format:**
- Initial patterns noticed (not themes yet - just "I see X coming up")
- Surprising findings ("I expected A but saw B")
- Questions emerging ("Why did 3 people mention Y?")
- Reflexive notes ("This contradicts my assumption that...")

4. **STOP and verify checkpoint:** Cannot proceed to Phase 4 until all data reviewed and surprises documented.

### Common Rationalization: "I can code while familiarizing to save time"

**Why this is wrong:** Coding while familiarizing locks you into first impressions. Patterns shift after full dataset review.

**Do instead:** Finish familiarization completely. Then start fresh with coding.

---

## Phase 4: Systematic Coding

**CHECKPOINT:** Before proceeding to Phase 5, you MUST have:
- [ ] Codebook complete (definitions, inclusion/exclusion criteria, examples)
- [ ] Entire dataset coded systematically
- [ ] **Intercoder reliability check completed** (10-20% sample)
- [ ] Agreement percentage documented
- [ ] Audit trail of all coding decisions
- [ ] Saved to `04-coding-analysis.md`

### Instructions

1. **Develop initial codebook using agent:**

```
Invoke: generate-initial-codes agent
Input: 2-3 transcripts or data segments
Output: Suggested codes with definitions and examples
```

Review agent suggestions. Refine codes. Create codebook.

2. **Codebook structure (MANDATORY):**

For each code:
- **Name:** Short label
- **Definition:** What this code means
- **Inclusion criteria:** When to apply this code
- **Exclusion criteria:** When NOT to apply
- **Examples:** 2-3 data extracts demonstrating code

3. **Code all data systematically:**

Work through raw data files sequentially. Apply codes from codebook. Document any new codes discovered (add to codebook with rationale).

4. **Intercoder reliability check (MANDATORY - NON-NEGOTIABLE):**

```
Invoke: intercoder-reliability-check agent
Input: Codebook + 2 transcripts (10-20% of dataset)
Output: Independent coding + agreement analysis
```

**This step is REQUIRED.** Cannot skip. Cannot defer. Cannot substitute with user review.

**Why:** Even clear codebooks have subjective judgment. Second coder catches systematic bias in code application.

5. **Document in `04-coding-analysis.md`:**

**Sections:**
- Section 1: Codebook (all codes with definitions and examples)
- Section 2: Coding Process (how you applied codes, any refinements)
- Section 3: Intercoder Reliability (agent results, agreement %, disagreement resolution)
- Section 4: Audit Trail (all coding decisions documented)

6. **STOP and verify checkpoint:** Cannot proceed to Phase 5 without intercoder reliability check COMPLETED and documented.

### Common Rationalization: "Coding was straightforward, low risk of errors"

**Why this is wrong:** "Straightforward" is subjective. Even clear codes have interpretation variance.

**Do instead:** If coding is straightforward, intercoder reliability will be high and quick. Do the check.

### Common Rationalization: "Time constraints justify skipping verification"

**Why this is wrong:** Presenting flawed findings takes more time to fix than 1-hour verification.

**Do instead:** Verification takes 1 hour. Fixing flawed findings after presentation takes days. Do the math.

### Common Rationalization: "User reviewed coding, that's enough validation"

**Why this is wrong:** User can't catch their own interpretation bias. Second coder does.

**Do instead:** User review is pre-flight check. Intercoder reliability is the actual test. Both required.

### Common Rationalization: "Can do reliability check later if needed"

**Why this is wrong:** After themes developed, reliability check invalidates hours of work if problems found.

**Do instead:** Reliability MUST be verified in Phase 4, not Phase 6. Do it now.

---

## Phase 5: Theme Development & Refinement

**CHECKPOINT:** Before proceeding to Phase 6, you MUST have:
- [ ] Themes defined with supporting codes
- [ ] **Disconfirming evidence search completed** (MANDATORY for ALL themes)
- [ ] Negative cases explained (data that doesn't fit themes)
- [ ] Themes refined based on full dataset review
- [ ] Verbatim data extracts supporting each theme
- [ ] Saved to `05-theme-development.md`

### Instructions

1. **Group codes into potential themes using agent:**

```
Invoke: identify-themes agent
Input: Codebook + all coded segments
Output: Potential themes with supporting codes and data extracts
```

Review agent suggestions. Refine theme definitions.

2. **Disconfirming evidence search (MANDATORY - NON-NEGOTIABLE):**

**For EACH theme, you MUST run:**

```
Invoke: search-disconfirming-evidence agent
Input: Theme definition + full dataset
Output: Contradictory evidence, edge cases, exceptions to pattern
```

**This is REQUIRED.** No exceptions. No shortcuts. No "pattern is obvious so no need."

**Why:** Clear patterns are MOST vulnerable to confirmation bias. Obvious themes need MOST rigorous verification.

3. **Document negative cases:**

For each theme, explain:
- How many participants DON'T fit this theme?
- What did those participants say instead?
- Why doesn't the theme apply to them?
- Is there a boundary condition (theme applies only in specific contexts)?

**Example:**
```
Theme 1: "Cost concerns are primary barrier" - 8 of 10 participants

NEGATIVE CASES:
- Participant 3: Didn't mention cost. Focused entirely on integration complexity.
- Participant 7: Said price was "not a concern if it solves the problem"

EXPLANATION: Theme applies to majority but not universal. Subset willing to pay premium for right solution.
```

4. **Refine themes based on disconfirming evidence:**

After seeing contradictions, revise theme definitions for accuracy. "8 of 10" is more honest than "all participants."

5. **Extract supporting quotes using agent:**

```
Invoke: extract-supporting-quotes agent
Input: Theme definition + coded dataset
Output: Best representative verbatim quotes for each theme
```

6. **Document in `05-theme-development.md`:**

**Format:**
- Theme name and definition
- Supporting codes
- Prevalence (X of Y participants)
- Verbatim quotes (use extract-supporting-quotes agent output)
- Disconfirming evidence (from search-disconfirming-evidence agent)
- Negative case explanation

7. **STOP and verify checkpoint:** Cannot proceed to Phase 6 without disconfirming evidence search for ALL themes.

### Common Rationalization: "Themes are clearly supported by majority of participants"

**Why this is wrong:** Majority agreement doesn't eliminate contradictory evidence. Must explain ALL data.

**Do instead:** "8 of 10 mentioned cost. What about the 2 who didn't? Must explain."

### Common Rationalization: "Expert prediction validates findings"

**Why this is wrong:** Expert prediction + matching findings = confirmation bias red flag, not validation.

**Do instead:** When predictions match findings perfectly, search HARDEST for contradictions.

### Common Rationalization: "High consistency (8/10, 9/10) indicates robust themes"

**Why this is wrong:** High unanimity can indicate leading questions or selective interpretation.

**Do instead:** Real customer sentiment is messy. 9/10 agreement deserves scrutiny, not celebration.

### Common Rationalization: "Disconfirming evidence search unnecessary when pattern is obvious"

**Why this is wrong:** Obvious patterns are MOST vulnerable to confirmation bias.

**Do instead:** Obvious patterns require MOST rigorous disconfirmation. Search is mandatory.

---

## Phase 6: Synthesis & Reporting

**CHECKPOINT:** Before marking complete, you MUST have:
- [ ] Findings documented with verbatim quotes for each theme
- [ ] **Limitations explicitly stated** (sample, method, researcher bias, context)
- [ ] Confidence assessment (credibility, dependability, confirmability, transferability)
- [ ] 2-3 follow-up research questions identified
- [ ] Overview updated with final summary
- [ ] Saved to `06-findings-report.md` and `00-overview.md` updated

### Instructions

1. **Write findings report:**

**Structure:**
- **Main Findings:** Each theme with supporting quotes
- **Prevalence:** Honest reporting (X of Y, not "all" or "most")
- **Negative Cases:** Exceptions explained
- **Context:** When/where does this apply?

2. **Document limitations (MANDATORY - be HONEST):**

**You MUST address:**
- Sample limitations (size, homogeneity, recruitment source)
- Method constraints (interviews vs. observations, question design)
- Researcher bias (documented in Phase 1, how it may have influenced)
- Context limitations (geography, time period, industry)

**Why:** Acknowledging limitations STRENGTHENS credibility. False certainty undermines trust.

3. **Assess confidence (trustworthiness criteria):**

- **Credibility:** Do findings accurately represent participant experiences?
- **Dependability:** Would another researcher reach similar conclusions?
- **Confirmability:** Are findings based on data, not researcher bias?
- **Transferability:** Do findings apply beyond this specific sample?

Rate each: High / Medium / Low. Provide justification.

4. **Identify 2-3 follow-up questions:**

Every analysis should raise new questions:
- What would you investigate next?
- What surprised you that needs deeper exploration?
- What would strengthen confidence in findings?

5. **Update `00-overview.md` with summary:**

Add final summary section with:
- Main findings (3-5 bullet points)
- Signal classification (if invoked by marketing-experimentation): Positive/Negative/Null/Mixed
- Confidence level
- Follow-up recommendations

6. **Save to `06-findings-report.md`**

7. **Mark Phase 6 complete:** All checkpoints verified.

### Common Rationalization: "Limitations will undermine findings, downplay them"

**Why this is wrong:** Stating limitations INCREASES credibility. Readers trust honest uncertainty.

**Do instead:** State limitations clearly. Be honest about what you don't know.

---

## Common Rationalizations - STOP

These are violations of skill requirements:

| Excuse | Reality |
|--------|---------|
| "I don't have biases to document" | Everyone has assumptions. If you can't name them, they're controlling you invisibly. |
| "Expert opinion reduces need for bias documentation" | Expert opinion IS a bias. Authority backing is a strong prior that MUST be documented. |
| "Time pressure justifies skipping formal process" | Documenting assumptions takes 5 minutes. Presenting biased findings wastes hours. |
| "Coding was straightforward, low risk" | "Straightforward" is subjective. Even clear codes have interpretation variance. |
| "Time constraints justify skipping verification" | Verification takes 1 hour. Fixing flawed findings after presentation takes days. |
| "Informal spot-check is sufficient" | Spot-checks catch obvious errors. Intercoder reliability catches systematic bias. Both required. |
| "User reviewed coding, enough validation" | User can't catch their own interpretation bias. Second coder does. Non-negotiable. |
| "Can do reliability check later if needed" | After themes developed, reliability check invalidates hours of work. Do it in Phase 4. |
| "Themes clearly supported by majority" | Majority agreement doesn't eliminate contradictory evidence. Must explain ALL data. |
| "Expert prediction validates findings" | When predictions match findings perfectly, that's when to search hardest for contradictions. |
| "High consistency (8/10, 9/10) indicates robustness" | Real customer sentiment is messy. 9/10 agreement deserves scrutiny. |
| "Disconfirming evidence search unnecessary for obvious patterns" | Obvious patterns MOST vulnerable to confirmation bias. Search is mandatory. |
| "Limitations undermine findings" | Stating limitations INCREASES credibility. False certainty undermines trust. |
| "This is just initial/exploratory research" | Exploratory means open-ended questions. Doesn't mean skip rigor. Follow the phases. |
| "I'm following the spirit of the rules" | Violating checkpoints violates both letter AND spirit. No shortcuts. |

**All of these mean: Checkpoint violated. Cannot proceed.**

## Red Flags - STOP

If you catch yourself thinking ANY of these, you are rationalizing. STOP and follow the checkpoint:

- "I recommend..." (should be "You MUST...")
- "Would you like to..." (should be "Cannot proceed without...")
- "This is optional" (critical steps are MANDATORY)
- "Spot-check" instead of "intercoder reliability check"
- "I'll look for contradictions" instead of "Invoking search-disconfirming-evidence agent"
- "This is just initial validation" (rigor required at all stages)
- "Expert backing reduces need for X" (authority is bias, must be documented)
- "Pattern is obvious" (obvious patterns need MOST rigorous verification)
- "Can skip X and do it later" (checkpoints are mandatory NOW, not later)

**All of these mean: Violated skill requirements. Go back and complete checkpoint.**

---

## Summary

This skill ensures rigorous, reproducible qualitative research by:

1. **Preventing confirmation bias:** Reflexivity baseline, neutral questions, disconfirming evidence search
2. **Ensuring systematic analysis:** Codebook rigor, intercoder reliability, audit trails
3. **Enforcing checkpoints:** Cannot skip critical steps (reflexivity, reliability, disconfirmation)
4. **Using agent-based methods:** Sub-agents handle data-intensive operations, prevent context pollution
5. **Demanding intellectual honesty:** Explicit limitations, confidence assessment, honest prevalence reporting

**Follow this process and you'll produce defensible, credible qualitative research that stands up to scrutiny.**
