---
name: scoping
description: Conduct scoping conversation with user to define research question, key findings, and constraints. Generates scope.md that guides all subsequent steps. Second step of writer workflow. Requires inventory.md to exist.
---

# Scoping

Conducts a focused conversation to establish the research scope, then generates a scope document that guides all subsequent writing.

## Prerequisites

- `inventory.md` must exist (from context-ingestion step)
- `notes/ethics-summary.md` may exist (if ethics document was provided)
- Review inventory before starting conversation

## Workflow

```
[Read inventory.md and notes/ethics-summary.md]
     │
     ▼
[Ask: Research Question]
     │
     ▼
[Ask: Key Findings] ─── Cross-reference with data inventory
     │
     ▼
[Confirm: Constraints] ─── From config.md
     │
     ▼
[Ask: Additional Context]
     │
     ▼
[Ethics Scope Comparison] ─── If ethics docs exist, compare and confirm discrepancies
     │
     ▼
[Generate scope.md and notes/ethics-scope-comparison.md]
```

## Step 1: Review Inventory and Ethics Documents

Before asking questions, read `inventory.md` to understand:
- How many papers are available for literature context
- What data files exist (this informs what results are possible)
- What figures are already generated
- Whether code repository is available

Also check if `notes/ethics-summary.md` exists. If it does, read it to understand:
- Approved population and inclusion/exclusion criteria
- Approved procedures and endpoints
- Sample size justification
- Study design

This context helps ask informed questions and validate user responses. Note that ethics approval scope is often broader than actual research scope.

## Step 2: Scoping Conversation

Ask questions **one at a time**. Wait for response before proceeding.

### Question 1: Research Question

> "What research question does this study address?
>
> Try to frame it as a specific, answerable question. For example:
> - 'Does the proposed method outperform existing approaches on benchmark datasets?'
> - 'What factors predict the observed outcome in this population?'"

**Good research questions have:**
- Specific population/context
- Clear intervention or exposure
- Measurable outcome

If vague, ask follow-up to clarify.

### Question 2: Key Findings

> "What are the key findings from your analysis?
> 
> I can see from your data that you have [summarize data files from inventory]. 
> What were the main results?"

**Cross-check with inventory:**
- If user mentions statistics, verify data files could support them
- If user mentions figures, check they exist in `figures/`
- If claims seem inconsistent with available data, ask for clarification

Ask for:
1. Primary finding (the main result)
2. Secondary findings (supporting results)
3. Any unexpected or negative results

### Question 3: Constraints

> "I see from your config that you're targeting [journal] with a [word_limit] word limit.
> 
> Are there any other constraints I should know about?
> - Specific formatting requirements?
> - Required sections or subsections?
> - Exclusions (topics to avoid)?"

### Question 4: Additional Context (Optional)

> "Is there anything else I should know about this study?
>
> For example:
> - Study limitations you want to acknowledge
> - Specific papers you want to cite or respond to
> - Practical implications to emphasize"

## Step 3: Ethics Scope Comparison (If Ethics Docs Exist)

**Skip this step if `notes/ethics-summary.md` does not exist.**

After gathering user's stated scope, compare it against the ethics document and present discrepancies for confirmation.

### Comparison Table

Present to user:

> "I've compared your stated research scope with the ethics/governance document.
>
> | Aspect | Ethics Document | Your Stated Scope |
> |--------|-----------------|-------------------|
> | Population | [from ethics] | [from user] |
> | Sample size | [from ethics] | [from user] |
> | Endpoints | [from ethics] | [from user] |
> | Procedures | [from ethics] | [from user] |
>
> **Please confirm:**
> 1. Are these differences intentional? (subset of approved protocol)
> 2. Any context for the narrower scope? (e.g., 'subset of data analyzed')
> 3. Anything I've misunderstood?"

### Document User Responses

Create `notes/ethics-scope-comparison.md`:

```markdown
# Ethics vs Actual Scope Comparison

**Generated**: [timestamp]
**Ethics Source**: [filename from ethics-summary.md]

## Comparison

| Aspect | Ethics Document | Actual Scope | Explanation |
|--------|-----------------|--------------|-------------|
| Population | [from ethics] | [from user] | [user explanation] |
| Sample size | [from ethics] | [from user] | [user explanation] |
| Endpoints | [from ethics] | [from user] | [user explanation] |
| Procedures | [from ethics] | [from user] | [user explanation] |

## User Confirmation

- **Differences intentional?**: [yes/no + explanation]
- **Context for narrower scope**: [user response]
- **Clarifications**: [any corrections to understanding]

## Implications for Manuscript

- [Note any elements from ethics doc that should NOT appear in manuscript]
- [Note any elements that need careful framing]
```

This document provides audit trail and guides later steps when they need to understand why ethics approval scope and manuscript scope differ.

## Step 4: Generate scope.md

After conversation, generate structured scope document:

```markdown
# Manuscript Scope

Generated: [timestamp]

## Research Question

[User's research question, cleaned up if needed]

## Hypothesis

[Inferred or stated hypothesis]

## Key Findings

### Primary Finding
[Main result with expected statistics]

### Secondary Findings
1. [Finding 2]
2. [Finding 3]

### Negative/Null Results
- [If any]

## Target Publication

- **Journal**: [from config]
- **Word Limit**: [from config]
- **Citation Style**: [from config]

## Constraints

- [Any additional constraints from conversation]

## Study Context

### Population
[Inferred from data/conversation]

### Methods Overview
[Brief summary based on code inventory]

### Limitations to Address
- [User-specified limitations]

## Materials Available

### Literature
- [n] PDFs in papers/ folder
- Key papers to emphasize: [if mentioned]

### Data
- [List key data files and what they contain]

### Figures
- [List figures and what they show]

### Code
- Repository: [url]
- Analysis approach: [inferred from code inventory]

### Ethics Documents
- **Available**: [yes/no]
- **Ethics Approval Number**: [from ethics-summary.md or "to be added manually"]
- **Scope Notes**: [see notes/ethics-scope-comparison.md for differences]

## Writing Guidance

### Tone
[Infer from journal: clinical, technical, etc.]

### Emphasis
[What to highlight based on conversation]

### Avoid
[What to minimize or exclude]
```

## Validation Checklist

Before saving scope.md, verify:

- [ ] Research question is specific and answerable
- [ ] Key findings are supported by available data
- [ ] Word limit is realistic for content
- [ ] All necessary context is captured
- [ ] If ethics docs exist: discrepancies documented and confirmed by user

## Output

Save to:
- `project/scope.md` - Main scope document
- `notes/ethics-scope-comparison.md` - Ethics comparison (if ethics docs exist)

Summarize back to user:

> "I've created the scope document. Here's the summary:
> 
> **Research Question**: [question]
> **Primary Finding**: [finding]  
> **Target**: [journal], [word_limit] words
> 
> Ready to proceed with literature review?"

Return to parent skill.
