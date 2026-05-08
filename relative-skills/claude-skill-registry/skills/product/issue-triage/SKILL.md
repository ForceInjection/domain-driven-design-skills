---
name: Issue Triage
description: This skill should be used when the user asks to "triage an issue", "evaluate a feature request", "should I accept this issue", "analyze GitHub issue", "review this pull request scope", "is this in scope", "how should I respond to this issue", "decline this request", "accept this contribution", "find similar bugs", "detect patterns", "root cause analysis", "fix this bug comprehensively", or discusses whether to accept, reject, adapt, defer, or redirect an external contribution to a project.
---

# Issue Triage Framework

A systematic approach for library maintainers to evaluate external issues against project philosophy and scope, with deep analysis that extracts maximum insight from every request.

## Core Philosophy

**"Every issue is an opportunity"** - Even declined requests can improve documentation, reveal API gaps, or inspire better alternatives. The goal is not to accept or reject, but to find the best path forward for the project.

**"Think 10 from 1"** - When given one request, think ten steps deeper. Every issue reveals something about the project's gaps, documentation quality, API design, or user mental models. Extract all possible learnings.

## Mindset: Deep Analysis Over Surface Judgment

Before making any decision, adopt this mindset:

1. **Root Cause Thinking**: Why did this request emerge? What gap in the project created this need?
2. **Systems Thinking**: What does this request reveal about the project's architecture, documentation, or user experience?
3. **Opportunity Discovery**: What improvements, even unrelated to the request, does this expose?
4. **Pattern Recognition**: Is this a recurring theme? What fundamental solution would prevent similar requests?
5. **Preventive Thinking**: How can the project evolve so this type of request becomes unnecessary?

## When to Apply This Framework

Apply this framework when:
- Evaluating GitHub/GitLab issues or feature requests
- Deciding whether a contribution fits project scope
- Responding to external pull requests
- Assessing bug reports vs. feature requests
- Determining library vs. application responsibility

## The Triage Process

### Step 1: Deep Understanding (Not Just Surface Analysis)

Go beyond what is asked to understand why it was asked:

1. **Surface Request**: Identify what the requester is literally asking for
2. **Underlying Need**: Determine what problem they are actually trying to solve
3. **Root Cause**: Why does this need exist? What project gap created it?
4. **Mental Model**: How does the requester think the project should work? Is that accurate?
5. **Job to be Done**: What job is this feature being hired to do?

**Critical Questions**:
- "Why can't this be accomplished with current capabilities?"
- "If they could, would they have asked differently?"
- "What would have prevented this request from being necessary?"
- "What does this request teach us about user expectations vs. reality?"

### Step 2: Assess Philosophy Alignment

Evaluate against four dimensions (score 1-5 each):

| Dimension | Question |
|-----------|----------|
| **Core Mission Fit** | Does this serve the project's primary purpose? |
| **Scope Alignment** | Is this library responsibility or application concern? |
| **Pattern Consistency** | Does it fit existing architecture and conventions? |
| **User Base Impact** | Does it benefit the majority or a niche use case? |

**Scoring Guide**:
- 5: Perfect fit, core to mission
- 4: Strong fit, natural extension
- 3: Acceptable, requires careful scoping
- 2: Marginal, stretches boundaries
- 1: Poor fit, conflicts with goals

Calculate average for overall alignment (High: 4-5, Medium: 3-3.9, Low: 1-2.9).

### Step 3: Assess Feasibility

Evaluate practical implementation factors:

| Factor | Rating Options |
|--------|----------------|
| Technical Complexity | Low / Medium / High |
| Breaking Changes | None / Minor / Major |
| Maintenance Burden | Low / Medium / High |
| Dependencies | None / Dev-only / Runtime |

Consider risks: What could go wrong? Impact on existing users?

### Step 4: Apply Decision Matrix

Use philosophy alignment and feasibility to determine verdict:

```
                 | Philosophy HIGH | Philosophy LOW  |
-----------------|-----------------|-----------------|
Feasibility HIGH | ACCEPT          | REDIRECT        |
Feasibility MED  | ADAPT           | DEFER/REDIRECT  |
Feasibility LOW  | DEFER           | DECLINE         |
```

**Decision Types**:

- **ACCEPT**: Fully aligned, implement as requested
- **ADAPT**: Good idea, implement differently than proposed
- **DEFER**: Valuable but not now; add to roadmap with conditions
- **REDIRECT**: Out of scope; provide alternative path (other library, extension point, workaround)
- **DECLINE**: Fundamentally misaligned; explain why respectfully

### Step 5: Craft Response

Every response should include:

1. **Acknowledge**: Thank them, show understanding of their need
2. **Explain**: Share reasoning transparently (reference project philosophy)
3. **Path Forward**: Always provide a constructive next step
4. **Invite**: Keep the door open for continued engagement

**Tone Guidelines**:
- Professional but warm
- Confident but not dismissive
- Educational - help them understand
- Grateful - they care about the project

## Quick Reference: Response Templates

**For ACCEPT**:
> Thank you! This aligns with [goal]. We'll implement it in [timeline]. PRs welcome!

**For ADAPT**:
> Great idea! We'd like to approach this differently: [explanation]. Would this work for you?

**For DEFER**:
> Valuable suggestion! We're prioritizing [focus] now. This is on our roadmap for [condition].

**For REDIRECT**:
> This falls outside our scope, but try: [alternative]. Here's why we maintain this boundary...

**For DECLINE**:
> After consideration, this doesn't align with [reason]. What we would welcome: [alternative].

## Key Questions to Ask

Before making a decision, consider:

1. Does this expand scope in a sustainable direction?
2. Would accepting create precedent for similar requests?
3. Is this library infrastructure or application logic?
4. What would the maintenance burden look like in 2 years?
5. Can this be achieved through extension points instead?

## Step 6: Strategic Insight Extraction

**Beyond the immediate decision, extract deeper insights:**

### Project Gap Analysis
- **Documentation Gap**: Did this request arise because something wasn't clearly documented?
- **API Gap**: Does the current API make this use case unnecessarily difficult?
- **Example Gap**: Would a better example have answered this question?
- **Architecture Gap**: Does the project structure make this harder than it should be?

### Improvement Opportunities
Even if declining the specific request, identify:
- Related improvements that ARE aligned with project philosophy
- Documentation that should be added or clarified
- API refinements that would serve the underlying need differently
- Extension points that would enable users to solve this themselves

### Pattern Analysis
- Is this part of a recurring request pattern?
- What category of requests does this represent?
- What fundamental change would address the entire category?
- Should the project's scope or philosophy documentation be updated?

### Preventive Actions
- What would prevent similar requests in the future?
- Should FAQ be updated?
- Is there a blog post or guide opportunity?
- Could error messages or warnings guide users better?

## Knowledge Capture

After each significant triage:

1. Update CLAUDE.md if scope clarification needed
2. Add FAQ entry if common question pattern
3. Consider ADR (Architecture Decision Record) for major decisions
4. Document discovered gaps and improvement opportunities
5. Track patterns for future strategic planning

## Deep Bug Resolution (When Issue is a Bug)

When an issue is identified as a bug/error, apply **Deep Resolution Analysis** to fix not just the reported issue (N), but also discover and prevent similar latent defects (M).

### Bug Detection Signals

Automatically classify as bug when:
- **Labels**: `bug`, `error`, `fix`, `defect`, `regression`, `crash`, `exception`
- **Keywords**: "error", "broken", "fail", "crash", "not working", "exception"
- **Patterns**: Stack traces, error messages, "expected vs actual"

### Root Cause Analysis

Go beyond symptoms:

1. **Symptom vs. Cause**: What user reports ≠ what's broken
2. **Hypothesis Tree**: Generate multiple possible causes, gather evidence for each
3. **Cause Chain**: Trace `[Action] → [Component] → [ROOT CAUSE] → [Symptom]`

**Critical Questions**:
- Why did this fail NOW? What changed?
- What assumption was violated?
- Where else might this assumption be violated?

### Similar Pattern Detection

After identifying root cause, find ALL similar patterns:

**Search Strategies**:
1. **Syntactic**: Same function names, API patterns, error handling
2. **Semantic**: Similar logic flow, data transformations, parallel code paths
3. **Architectural**: Same layer violations, coupling patterns, anti-patterns

**Risk Classification**:
| Risk | Meaning |
|------|---------|
| 🔴 Critical | Same bug, different location |
| 🟠 High | Very likely has same latent defect |
| 🟡 Medium | Should be reviewed |
| 🟢 Low | Monitor only |

**Output**: Table of `[Risk] [Location] [Pattern] [Assessment]`

### Solution Research (Complex Bugs)

Auto-trigger research when:
- Affects 5+ files or requires architectural changes
- <3 similar patterns exist (unfamiliar territory)
- Issue mentions "best practice", "latest", "modern approach"
- Involves third-party library/API
- Security or performance critical

**Research Strategy**:
- Query: "[technology] [problem] best practices [current year]"
- Sources: Official docs → GitHub issues → Stack Overflow → Expert blogs
- Tool: Try Tavily MCP first, fallback to WebSearch

### Comprehensive Fix Approach

Instead of fixing just N:
1. Fix the reported issue (N)
2. Fix all Critical (🔴) patterns immediately
3. Include High (🟠) patterns in the same fix
4. Schedule Medium (🟡) patterns for follow-up
5. Document the pattern to prevent recurrence

For detailed methodology, see:
- **`references/pattern-detection-guide.md`** - Complete pattern detection methodology
- **`references/research-methodology.md`** - Web research best practices

## Additional Resources

### Reference Files

For detailed guidance, consult:
- **`references/decision-examples.md`** - Real-world decision examples with detailed reasoning for each decision type
- **`references/response-templates.md`** - Complete response templates for ACCEPT, ADAPT, DEFER, REDIRECT, and DECLINE decisions
- **`references/philosophy-alignment-guide.md`** - Detailed scoring methodology for philosophy alignment assessment

### Example Files

Working examples demonstrating complete triage sessions:
- **`examples/sample-triage-accept.md`** - Complete ACCEPT decision walkthrough
- **`examples/sample-triage-decline.md`** - Complete DECLINE decision walkthrough
- **`examples/sample-triage-adapt.md`** - Complete ADAPT decision walkthrough
- **`examples/sample-triage-defer.md`** - Complete DEFER decision walkthrough
- **`examples/sample-triage-redirect.md`** - Complete REDIRECT decision walkthrough

### Full Workflow Command

For a complete formatted triage report with all phases, use the `/iyu:issue` command:
```bash
/iyu:issue <url | file | "text">
/iyu:issue <input> --quick    # Decision only, skip execution
/iyu:issue <input> --save     # Save report to file
```
