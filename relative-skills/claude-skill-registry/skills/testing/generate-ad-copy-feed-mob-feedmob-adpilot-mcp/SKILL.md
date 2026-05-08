---
name: generate-ad-copy
description: Generate two distinct, creative, and copyright-compliant ad copy variations based on campaign parameters and research insights. Use when creating advertising text content including headlines, body copy, and calls-to-action. Triggers on requests to write ad copy, create ad text, generate headlines, or develop platform-specific ad messaging for A/B testing.
---

# Generate Ad Copy

Generate two distinct ad copy variations with headlines, body copy, and CTAs based on campaign parameters. Each variation should be original, copyright-compliant, and platform-optimized.

## Workflow

### Step 1: Analyze Campaign Context

Extract from provided parameters:
- **product_or_service**: What is being advertised
- **target_audience**: Who the ad targets
- **platform**: Where ad appears (TikTok, Facebook, Instagram, LinkedIn)
- **creative_direction**: Tone and style requirements
- **kpi**: Success metrics

If research insights provided, incorporate audience behaviors, platform trends, and creative recommendations.

### Step 2: Generate Variation A

Create the first ad copy variation:

**Headline** (5-15 words):
- Attention-grabbing and benefit-focused
- Platform-appropriate length
- Aligned with creative direction

**Body Copy** (20-100 words depending on platform):
- Expand on headline's promise
- Address target audience pain points
- Include key product/service benefits
- Match specified tone and style

**CTA** (2-5 words):
- Clear, action-oriented
- Aligned with campaign KPI

**Tone**: Document the tone used

### Step 3: Generate Variation B

Create a DISTINCT second variation:
- Different messaging approach than A
- Alternative headline angle or benefit focus
- Different body copy structure
- May use different CTA phrasing

Variation B must NOT be a minor rewording of A. Provide genuine alternative for A/B testing.

### Step 4: Determine Recommendation

Recommend one variation based on:
- Campaign KPI alignment
- Platform best practices
- Audience appeal from insights

### Step 5: Return JSON Output

**CRITICAL**: Return a raw JSON object (NOT in a code block). The output must be valid JSON that can be parsed directly.

Return this exact structure:

{
  "generated_at": "ISO timestamp",
  "campaign_name": "name or null",
  "platform": "platform name or null",
  "target_audience": "audience description or null",
  "variations": [
    {
      "variation_id": "A",
      "headline": "Compelling headline",
      "body_copy": "Engaging body copy...",
      "cta": "Action CTA",
      "tone": "tone description",
      "platform_optimized": true
    },
    {
      "variation_id": "B",
      "headline": "Alternative headline",
      "body_copy": "Different approach...",
      "cta": "Alternative CTA",
      "tone": "tone description",
      "platform_optimized": true
    }
  ],
  "recommended_variation": "A or B",
  "recommendation_rationale": "why this variation is recommended",
  "disclaimer": "This ad copy is original content generated for your campaign. All copy is copyright-compliant and does not use trademarked phrases."
}

## References

- **Platform Guidelines**: See [references/platform-guidelines.md](references/platform-guidelines.md) for platform-specific copy lengths, tones, and CTAs
- **Examples**: See [references/examples.md](references/examples.md) for complete input/output examples

## Important Notes

- Return raw JSON only, not wrapped in code blocks
- Generate exactly two variations with distinct messaging
- Ensure all copy is original and copyright-compliant
- Tailor copy to platform best practices
- Match tone and style to creative direction
- Provide clear rationale for recommendation
- Include copyright compliance disclaimer
- Ensure variation B is genuinely different from A
