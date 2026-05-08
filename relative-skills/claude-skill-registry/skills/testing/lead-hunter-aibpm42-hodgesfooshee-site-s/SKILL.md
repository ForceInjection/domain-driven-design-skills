---
name: lead-hunter
description: THE MOST CRITICAL FEATURE FOR HODGES & FOOSHEE REALTY. Ultimate distressed property intelligence system tracking 22 distress signals across financial, life event, property, legal, and market categories. Self-improving AI that monitors performance, spawns specialized skills to fix bottlenecks, runs A/B tests, and continuously optimizes lead conversion. This is the game-changer that finds homeowners in crisis BEFORE anyone else does. Use for ALL lead generation tasks, pipeline optimization, multi-source data ingestion, and automated lead intelligence.
---

# Lead Hunter Prime - Ultimate Distressed Property Intelligence System

## 🚨 PRIORITY STATUS: MOST IMPORTANT FEATURE IN ENTIRE PROJECT

This is not just a feature. This is **THE** revenue engine for Hodges & Fooshee Realty.

**Projected Impact:**
- 900-1,370 leads/month from 22 distress signals
- 20-50 deals/month @ 2-4% conversion
- $200k-500k monthly revenue potential
- $2.4M-6M annual revenue potential
- **ROI: 1,538x - 3,846x**

**Core Capability:** Track 22 types of distressed property signals, find homeowners in crisis BEFORE banks/agents/competitors, validate contacts automatically, score urgency based on multiple distress signals, and deliver qualified leads to agents with phone numbers and emails ready to call.

## When to Use This Skill

**ALWAYS trigger this skill when the user mentions:**
- Lead Hunter, distressed properties, foreclosures, pre-foreclosure
- Tax delinquent, tax liens, lis pendens, bankruptcy, probate, divorce
- Code violations, condemned properties, evictions, judgments
- Expired listings, days on market, price reductions
- Lead generation, lead pipeline, lead scoring, lead conversion
- N8N workflows for property data, Apify scrapers, Manus tasks
- Skip tracing, contact validation, phone/email enrichment
- Admin dashboard for leads, lead management page
- Multi-source data ingestion, distress signal tracking
- Any question about "finding motivated sellers" or "distressed homeowners"

**This is THE priority feature. Treat every Lead Hunter question with maximum urgency.**

## The 22 Distressed Property Signals

Lead Hunter Prime tracks **ALL types of property distress**, not just foreclosures:

### Tier 1: Financial Distress (🔥 CRITICAL - Highest conversion)
1. **Tax Delinquent** - Can't pay property taxes (March 1-April 1 golden window)
2. **Tax Liens** - Government liens for unpaid taxes
3. **Lis Pendens** - Foreclosure lawsuit filed
4. **Notice of Default** - 90+ days behind on mortgage
5. **Bankruptcy Ch 7** - Liquidation bankruptcy
6. **Bankruptcy Ch 13** - Reorganization bankruptcy
7. **IRS Tax Liens** - Federal tax debt

### Tier 2: Life Event Distress (💜 HIGH - Very motivated)
8. **Divorce Filings** - Need to liquidate marital home
9. **Probate Cases** - Inherited property, heirs need cash
10. **Estate Sales** - Death in family, property to sell
11. **Eviction (Landlord)** - Landlord in financial distress

### Tier 3: Property Distress (⚠️ MEDIUM - Can't afford upkeep)
12. **Code Violations** - Can't afford repairs
13. **Condemned Properties** - Major code issues
14. **Fire/Damage Reports** - Insurance claims, need repairs
15. **HOA Liens** - Can't pay HOA fees

### Tier 4: Legal Distress (⚖️ MEDIUM - Need cash for settlements)
16. **Criminal Cases (Incarceration)** - Family needs to sell
17. **Civil Judgments** - Lawsuits requiring cash
18. **Mechanic's Liens** - Unpaid contractor bills

### Tier 5: Market Distress (📉 LOW - Motivated but not desperate)
19. **Expired Listings** - Failed to sell, owner desperate
20. **High Days on Market** - 120+ days listed
21. **Price Reductions** - Multiple price drops
22. **Landlord with Vacancies** - Negative cash flow

**The Power of Multiple Signals:**
- 1 signal = maybe motivated (2-4% conversion)
- 2-3 signals = definitely motivated (8-12% conversion)
- 4+ signals = DESPERATE (20-40% conversion)

Example: "Tax delinquent + Probate + Divorce + Code violation" = **Tier S lead** (URGENT, call immediately)

## The Self-Improvement Loop

```
1. MONITOR → Track every lead through pipeline (22 sources)
2. ANALYZE → Identify bottlenecks automatically (which sources convert best)
3. SPAWN → Create specialized skill to fix problem (e.g., improve skip tracing for divorces)
4. TEST → Run A/B test with 50% of leads
5. DECIDE → Keep if it works, kill if it doesn't
6. REPEAT → Forever (continuous optimization)
```

## Workflow

### Step 1: Understand Current State

**If building from scratch:**
```bash
# Check for existing lead tracking infrastructure
view /mnt/user-data/uploads/supabase/migrations
view /mnt/user-data/uploads/app/api

# Look for existing lead forms, CRM integrations, or tracking systems
view /mnt/user-data/uploads/components
```

**Extract these details:**
- How are leads currently captured? (forms, API, integrations)
- Where do leads go? (database tables, CRM, email)
- What tracking exists? (conversion rates, source attribution, stage progression)
- What are the known bottlenecks? (low conversion, slow response, poor qualification)

**If improving existing system:**
Ask user:
1. "What's the current conversion rate from lead to qualified prospect?"
2. "Where do most leads drop off in the pipeline?"
3. "What lead sources perform best?"
4. "How long does it take to respond to new leads?"

### Step 2: Set Up Performance Monitoring

**Database Schema Required:**

Create tables to track:
- `leads` - Every incoming lead with source attribution
- `lead_events` - Every action on a lead (viewed, contacted, qualified, etc.)
- `lead_experiments` - A/B tests running on subsets of leads
- `lead_metrics` - Aggregated performance by source, agent, time period
- `lead_skills` - Spawned skills and their performance impact

**Key Metrics to Monitor:**
- Conversion rate (lead → qualified → appointment → deal)
- Time to first contact
- Response rate
- Lead source quality (which sources convert best)
- Agent performance (who converts leads best)
- Pipeline velocity (time from lead to close)

**Read references/monitoring-framework.md for complete schema and tracking implementation.**

### Step 3: Identify Bottlenecks

**Common Bottleneck Patterns:**

1. **Low Response Rate** → Spawn "instant-responder" skill
   - Auto-replies within 60 seconds
   - Uses LLM to personalize response based on lead details

2. **Poor Qualification** → Spawn "lead-scorer" skill
   - Analyzes property data, lead behavior, demographics
   - Assigns priority score (A/B/C/D leads)

3. **Slow Follow-Up** → Spawn "follow-up-sequencer" skill
   - Automated drip sequences based on lead temperature
   - Triggers reminders for agents

4. **Weak Lead Sources** → Spawn "source-optimizer" skill
   - Reallocates budget to high-converting sources
   - Flags underperforming channels

**Analysis Query Template:**
```sql
-- Find conversion rates by pipeline stage
SELECT
  stage,
  COUNT(*) as lead_count,
  COUNT(*) FILTER (WHERE converted = true) as converted_count,
  (COUNT(*) FILTER (WHERE converted = true)::float / COUNT(*)) * 100 as conversion_rate
FROM lead_events
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY stage
ORDER BY stage;

-- Identify slowest stage transitions
SELECT
  from_stage,
  to_stage,
  AVG(time_in_stage) as avg_duration,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY time_in_stage) as median_duration
FROM lead_stage_transitions
GROUP BY from_stage, to_stage
ORDER BY avg_duration DESC;
```

### Step 4: Spawn Specialized Skills

When a bottleneck is identified, create a targeted skill to fix it.

**Skill Spawning Protocol:**

1. **Define the problem clearly**
   - Metric being optimized (e.g., "Increase response rate from 40% to 80%")
   - Current baseline performance
   - Target improvement

2. **Design the intervention**
   - What specific action will the skill take?
   - What triggers it?
   - What data does it need?

3. **Create A/B test plan**
   - Control group: existing process (50% of leads)
   - Treatment group: new skill applied (50% of leads)
   - Duration: minimum 2 weeks or 100 leads per group
   - Success criteria: statistical significance (p < 0.05)

4. **Implement tracking**
   - Log which leads get which treatment
   - Track outcome metrics for both groups
   - Calculate lift and statistical significance

**Example Spawned Skill: instant-responder**

```typescript
// Auto-respond to new leads within 60 seconds
export async function handleNewLead(lead: Lead) {
  // Check if this lead is in the treatment group for instant-responder experiment
  const experiment = await getActiveExperiment('instant-responder');
  const isControl = lead.id % 2 === 0; // Simple 50/50 split

  if (isControl) {
    // Control group: existing process (manual agent follow-up)
    await assignToAgent(lead);
    return;
  }

  // Treatment group: instant AI response
  const personalizedMessage = await generateResponse(lead);
  await sendSMS(lead.phone, personalizedMessage);
  await logEvent(lead.id, 'instant_response_sent', { experiment_id: experiment.id });

  // Still assign to agent for human follow-up
  await assignToAgent(lead);
}
```

### Step 5: Run A/B Tests

**Testing Framework:**

Read references/ab-testing-protocol.md for detailed implementation, but core principles:

1. **Random assignment** - Leads randomly split 50/50
2. **Consistent assignment** - Same lead always gets same treatment
3. **Sufficient sample size** - Minimum 100 leads per group
4. **Statistical significance** - Don't call winners early
5. **Isolate variables** - Only test one change at a time

**Decision Criteria:**

```typescript
interface ExperimentResults {
  control: {
    sample_size: number;
    conversion_rate: number;
    avg_time_to_convert: number;
  };
  treatment: {
    sample_size: number;
    conversion_rate: number;
    avg_time_to_convert: number;
  };
  lift: number; // % improvement
  p_value: number; // statistical significance
  recommendation: 'KEEP' | 'KILL' | 'CONTINUE_TESTING';
}
```

**Keep the skill if:**
- Lift > 10% AND p_value < 0.05 → KEEP
- Make treatment the new baseline
- Spawn next skill to optimize next bottleneck

**Kill the skill if:**
- Lift < 5% OR p_value > 0.10 → KILL
- Revert to control
- Analyze why it failed, try different approach

**Continue testing if:**
- Promising trend but not significant yet → CONTINUE
- Let it run longer
- Increase sample size

### Step 6: Iterate Forever

**The Continuous Improvement Cycle:**

1. **Weekly Analysis** - Every Monday, analyze previous week's metrics
2. **Bottleneck Identification** - Find the biggest conversion leak
3. **Hypothesis Formation** - Why is this happening? What might fix it?
4. **Skill Design** - Create intervention to test hypothesis
5. **Deployment** - Launch A/B test on 50% of leads
6. **Monitor** - Track daily results
7. **Decision** - After 2 weeks or sufficient sample, decide: keep/kill/continue
8. **Repeat** - Move to next bottleneck

**Priority Ranking System:**

Always optimize in this order:
1. **Response time** (fastest impact on conversion)
2. **Lead qualification** (prevents wasting time on bad leads)
3. **Follow-up cadence** (nurtures warm leads)
4. **Lead source quality** (more good leads in, fewer bad leads)
5. **Agent performance** (route leads to best converters)

## Special Cases

### When Starting from Zero

If no lead system exists:
1. First, build basic infrastructure (forms, database, tracking)
2. Collect baseline data for 2 weeks (no interventions)
3. Calculate baseline conversion rates for each stage
4. THEN start spawning skills to optimize

**Don't optimize what you haven't measured first.**

### When Metrics Are Inconsistent

If conversion rates vary wildly week-to-week:
1. Increase sample size before testing (wait for more leads)
2. Segment by lead source (optimize each source separately)
3. Control for external factors (seasonality, market conditions, agent availability)

### When Multiple Bottlenecks Exist

Prioritize by **potential impact**:
- Which stage has the biggest drop-off?
- Which stage is fastest/cheapest to improve?
- Which improvement unlocks downstream improvements?

**Only test ONE skill at a time.** Running multiple experiments simultaneously creates confounding variables.

### When A Skill Performs Differently by Segment

Example: Instant-responder works great for Zillow leads but hurts conversion on referral leads.

**Solution: Segment-specific deployment**
- Apply skill only to segments where it works
- Kill it for segments where it hurts
- Track performance by segment in `lead_experiments` table

## Resources

### references/monitoring-framework.md
Complete database schema for tracking:
- Lead capture and attribution
- Pipeline stage progression
- Event logging
- Experiment tracking
- Metric aggregation

**Read this when:** Setting up performance monitoring or designing tracking infrastructure.

### references/ab-testing-protocol.md
Detailed guide to running statistically valid A/B tests:
- Sample size calculation
- Random assignment algorithms
- Statistical significance testing
- Common pitfalls to avoid

**Read this when:** Launching a new experiment or analyzing test results.

### references/skill-spawning-patterns.md
Library of pre-built skills for common bottlenecks:
- Instant responder (fast response time)
- Lead scorer (qualification)
- Follow-up sequencer (nurture campaigns)
- Source optimizer (lead quality)
- Agent router (performance-based assignment)

**Read this when:** Identifying a bottleneck and need a proven solution pattern.

## Critical Principles

1. **Measure first, optimize second** - Collect baseline data before intervening
2. **One variable at a time** - Don't confound experiments
3. **Statistical rigor** - Don't call winners early
4. **Segment awareness** - What works for one lead source may not work for another
5. **Continuous iteration** - Never stop improving
6. **Kill bad ideas fast** - Don't let ego keep underperforming skills alive
7. **Document everything** - Track why skills were spawned, what they tested, and results

## Example Use Cases

### Example 1: Low Response Rate

**User:** "Only 40% of our leads are getting contacted within 24 hours. How do we fix this?"

**Response:**
```
[Analyzes current lead routing and agent workflow]

The bottleneck is agent response time. Let me spawn an instant-responder skill.

**The Skill:**
- Triggers within 60 seconds of lead capture
- Uses LLM to generate personalized SMS based on property address and lead source
- Still assigns to agent, but lead gets immediate acknowledgment

**A/B Test Design:**
- Control: existing process (agent contacts within 24h)
- Treatment: instant AI response + agent follow-up
- Metric: % of leads that respond to initial contact
- Sample size: 200 leads (100 per group)
- Duration: 2 weeks

**Hypothesis:** Instant response increases engagement rate from 40% to 65%+

[Implements skill, sets up tracking, launches experiment]

I'll check results in 2 weeks and decide: keep, kill, or continue testing.
```

### Example 2: Poor Lead Quality

**User:** "We're getting tons of leads but only 10% are qualified. We're wasting time on tire-kickers."

**Response:**
```
[Analyzes lead sources and qualification criteria]

The bottleneck is lead scoring. Most leads aren't pre-qualified before agent contact.

**Spawning lead-scorer skill:**

Analyzes each incoming lead for:
- Property characteristics (price, condition, equity position)
- Lead behavior (time on site, pages viewed, form urgency signals)
- Demographics (location, device type, referral source)

Assigns A/B/C/D score:
- A leads: high equity, motivated seller signals → immediate agent contact
- B leads: potential, needs nurturing → follow-up sequence
- C leads: low quality, may convert later → drip campaign
- D leads: spam or unqualified → archive

**A/B Test Design:**
- Control: all leads routed to agents equally
- Treatment: leads prioritized by score (A/B get fast response, C/D get automated nurture)
- Metric: % of agent time spent on qualified leads that convert
- Duration: 3 weeks

[Implements lead scoring model, sets up routing rules, launches test]
```

## Quick Reference: When to Use Lead Hunter

**Use this skill when:**
- Building lead generation systems from scratch
- Optimizing existing lead pipelines
- Creating automated lead qualification
- Analyzing conversion funnel metrics
- Running A/B tests on lead workflows
- Designing self-improving lead systems

**Don't use this skill for:**
- One-off lead list exports (use data query instead)
- Manual lead research (use research agent instead)
- CRM configuration (use vendor docs instead)
- Marketing campaign creation (use marketing-writer instead)

---

Built for Hodges & Fooshee Realty by AICA 🔥
