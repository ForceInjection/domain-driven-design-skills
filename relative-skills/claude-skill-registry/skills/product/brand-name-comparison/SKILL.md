---
name: Brand Name Comparison
description: Use this skill when the user wants to compare multiple brand name fates side-by-side to divine which is destined for success.
version: 0.1.0
---

# Brand Name Comparison Skill

Compare multiple brand name candidates side-by-side to help users divine the best destiny.

## When to Use

- User has 2+ brand name candidates and wants to compare them
- User asks "which name is better?"
- User wants a side-by-side analysis of options
- User is making a final decision between shortlisted names

## Comparison Framework

For each name being compared, evaluate:

### 1. Availability Score (0-25 points)
- Domain .com available: +10
- Domain alternatives available (.io, .co, .ai): +5
- Social handles available (majority): +5
- Trademark clear: +5

### 2. Linguistic Score (0-25 points)
- Easy to pronounce (1-2 syllables ideal): +10
- Easy to spell from hearing: +5
- No international issues: +5
- Memorable/distinctive: +5

### 3. Brand Fit Score (0-25 points)
- Evokes appropriate industry: +10
- Aligns with stated mission (if provided): +10
- Differentiates from competitors: +5

### 4. Practical Score (0-25 points)
- Short length (under 10 characters): +10
- Works as a verb ("let's google it"): +5
- Visual/logo potential: +5
- SEO-friendly (not too generic): +5

**Total: 100 points possible**

## Output Format

```
## Brand Name Comparison

Comparing: {Name1} vs {Name2} vs {Name3}

### Quick Summary

| Criteria | {Name1} | {Name2} | {Name3} |
|----------|---------|---------|---------|
| Availability | X/25 | X/25 | X/25 |
| Linguistic | X/25 | X/25 | X/25 |
| Brand Fit | X/25 | X/25 | X/25 |
| Practical | X/25 | X/25 | X/25 |
| **Total** | **X/100** | **X/100** | **X/100** |

### Winner: {Name}

{1-2 sentence explanation of why this name wins}

### Detailed Breakdown

#### {Name1}: X/100
**Strengths:**
- {strength 1}
- {strength 2}

**Weaknesses:**
- {weakness 1}
- {weakness 2}

**Best for:** {scenario where this name excels}

#### {Name2}: X/100
...

#### {Name3}: X/100
...

### Recommendation

{Final recommendation with reasoning. If scores are close, explain the tradeoffs and what factors should drive the decision.}

### Next Steps
- Run full availability checks on top choice
- Test pronunciation with target audience
- Check trademark availability in detail
```

## Comparison Tips

**When scores are close (within 5 points):**
- Weight criteria based on user's priorities
- Ask what matters most: availability, brand fit, or memorability
- Consider the specific use case (B2B vs B2C, tech vs traditional)

**When one name clearly wins:**
- Still highlight what the other names do well
- Note if runner-up might work for a sub-brand or product line
- Confirm the winner addresses user's stated requirements

**Handling ties:**
- Recommend additional research (focus groups, A/B testing)
- Suggest checking with target customers
- Consider which name has better long-term potential

## Example

User: "Compare 'Luminary', 'Brightpath', and 'Eduvance' for an education technology company focused on corporate training"

Then provide full comparison using the framework, noting that:
- Corporate training suggests professional/serious tone
- B2B context means domain availability critical
- "Eduvance" clearly signals education
- "Luminary" has broader appeal but less specific
- "Brightpath" is descriptive but potentially generic
