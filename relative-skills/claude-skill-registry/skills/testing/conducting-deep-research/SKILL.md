---
name: conducting-deep-research
description: Produces comprehensive, well-sourced research reports through iterative refinement using Time-Tested Diffusion methodology. Triggers on "deep research", "thorough analysis", "comprehensive report", "investigate", "due diligence", or when multiple sources are needed to answer complex questions.
---

# Conducting Deep Research

Iterative methodology treating research as a diffusion process: start with noise (rough draft), apply guidance (research brief), denoise through cycles of critique → research → refine until quality converges.

## Workflow

```
Progress:
- [ ] 1. Clarify scope (if ambiguous)
- [ ] 2. Write research brief (guidance signal)
- [ ] 3. Generate initial draft from knowledge (noisy starting point)
- [ ] 4. Red team critique (identify noise)
- [ ] 5. Targeted web_search with reflection
- [ ] 6. Score sources and track contradictions
- [ ] 7. Refine draft (denoise)
- [ ] 8. Evaluate quality (score < 7? repeat 4-7, max 3 cycles)
- [ ] 9. Finalize
```

### Step 1: Clarify Scope

Ask clarifying questions only if:
- Topic has multiple interpretations
- Key constraints missing (timeframe, geography, industry)
- Success criteria unclear

Skip for well-defined requests.

### Step 2: Research Brief (Guidance Signal)

```
RESEARCH BRIEF
Topic: [Specific question]
Scope: [Included/excluded]
Key Questions:
1. [Primary]
2. [Secondary]
3. [Tertiary]
Constraints: [Limits]
Language: [Match user's language]
```

### Step 3: Initial Draft (Noisy Starting Point)

Write from existing knowledge only. Mark gaps:
- `[NEEDS VERIFICATION]` - uncertain claims
- `[RESEARCH NEEDED]` - missing information
- `[CONFIDENCE: LOW/MED/HIGH]` - flag uncertainty levels

This draft intentionally contains "noise" - the refinement loop will denoise it.

### Step 4: Red Team Critique

Attack your draft for:
- **Logic**: Circular reasoning, false dichotomies, unsupported claims
- **Gaps**: Missing perspectives, incomplete coverage
- **Sources**: Unsourced claims, single-source reliance

Rate each issue 1-10 severity. See [references/critique-framework.md](references/critique-framework.md).

### Step 5: Targeted Research with Reflection

**Search budget by complexity:**
- Simple verification: 1-2 searches
- Moderate topics: 3-5 searches  
- Complex research: 5-10 searches

**CRITICAL: Think after EVERY search.** After each `web_search`, pause and reflect:
```
REFLECTION:
- What key facts did I find?
- What gaps remain?
- Do sources agree or conflict?
- Is another search needed, or do I have enough?
```

**Parallel research triggers** - pursue multiple threads when:
- Comparing alternatives (search each separately)
- Multiple independent sub-questions exist
- Different source types needed (academic vs news vs official)

See [references/search-patterns.md](references/search-patterns.md) for query techniques.

### Step 6: Source Scoring and Contradiction Handling

**Score each source (1-100 confidence):**

| Source Type | Base Score |
|-------------|------------|
| Official documentation, peer-reviewed | 85-100 |
| Government/institutional reports | 75-90 |
| Established news outlets | 60-80 |
| Industry publications | 50-75 |
| Blogs, forums | 20-50 |

Adjust based on: recency, author credentials, citation quality.

**Track facts with attribution:**
```
FACT: [Statement]
SOURCE: [URL]
CONFIDENCE: [1-100]
DISPUTED: [Yes/No - conflicts with other sources?]
```

**When sources contradict:**
1. Note the contradiction explicitly
2. Check publication dates (prefer recent)
3. Evaluate source authority
4. Search for additional sources to break tie
5. If unresolved, present both views with confidence levels

See [references/source-evaluation.md](references/source-evaluation.md) for detailed guidance.

### Step 7: Refine Draft (Denoise)

1. Replace `[NEEDS VERIFICATION]` with sourced facts
2. Add inline citations with confidence: "According to [Source] (high confidence), ..."
3. Qualify or remove unsupported claims
4. Address contradictions explicitly
5. Add counterarguments

**Context management:** If accumulating too much research, compress raw notes into key findings before continuing. Discard redundant/low-value information.

### Step 8: Evaluate Quality

Score 1-10 on:
- **Comprehensiveness**: All key questions addressed?
- **Accuracy**: Claims well-sourced with appropriate confidence?

**Track across iterations:**
```
QUALITY LOG:
Iteration 1: Comprehensiveness 5, Accuracy 4, Avg 4.5
Iteration 2: Comprehensiveness 7, Accuracy 6, Avg 6.5
Iteration 3: Comprehensiveness 8, Accuracy 8, Avg 8.0 ✓
```

If average < 7: Return to Step 4 (max 3 cycles).
If score drops between iterations: Focus critique on what regressed.

### Step 9: Finalize

```markdown
# [Title]

## Executive Summary
[Key findings in 2-3 paragraphs]

## Findings
[Organized by research questions, with inline citations]

## Methodology
[Brief: sources consulted, confidence levels, any unresolved contradictions]

## Limitations
[Gaps, uncertainties, disputed claims]

## Sources
[Numbered list with confidence indicators]
```

See [references/report-templates.md](references/report-templates.md) for format variants.

## Example

**Input**: "Research the current state of nuclear fusion energy"

**Research Brief**:
```
Topic: Current state of nuclear fusion energy
Key Questions:
1. What are the leading approaches and projects?
2. What milestones have been achieved recently?
3. What are realistic timelines for commercial fusion?
Constraints: Focus on scientific/engineering progress, not policy
```

**Draft Excerpt** (before research):
```
Nuclear fusion has made significant progress [CONFIDENCE: LOW]. 
The National Ignition Facility achieved ignition [NEEDS VERIFICATION].
Private companies like [RESEARCH NEEDED] are also pursuing fusion.
```

**Post-search reflection**:
```
REFLECTION after search 1 (NIF ignition):
- Found: NIF achieved ignition Dec 2022, 3.15 MJ from 2.05 MJ input
- Source: Lawrence Livermore (official) - Confidence 95
- Gap: Private sector landscape still unknown
- Next: Search for private fusion companies
```

**Source tracking**:
```
FACT: NIF achieved fusion ignition December 2022
SOURCE: llnl.gov/news/...
CONFIDENCE: 95
DISPUTED: No
```

**Quality log**:
```
Iteration 1: Comp 5, Acc 4 → Need private sector + timelines
Iteration 2: Comp 8, Acc 7 → Good coverage, strengthen citations
Iteration 3: Comp 9, Acc 8 → Done ✓
```

## When to Use

**Use**: Complex questions, comparisons, due diligence, state-of-art surveys
**Don't use**: Simple lookups (use web_search directly), opinions, creative writing

## References

- [references/search-patterns.md](references/search-patterns.md) - Query techniques, parallel research
- [references/critique-framework.md](references/critique-framework.md) - Red team methodology
- [references/source-evaluation.md](references/source-evaluation.md) - Confidence scoring, contradictions
- [references/report-templates.md](references/report-templates.md) - Output formats
