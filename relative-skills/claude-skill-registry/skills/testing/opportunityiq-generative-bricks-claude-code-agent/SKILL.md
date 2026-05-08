---
name: opportunityiq
description: Intelligent revenue opportunity discovery system for financial advisors. Extracts structured revenue scenarios from publications and matches them to client books of business to identify high-value opportunities. Use when analyzing industry articles to discover new scenarios, or when scanning client data to find revenue opportunities and generate Top 25 opportunity reports.
---

# OpportunityIQ Skill

## What This Skill Does

OpportunityIQ is a two-layer system that helps financial advisors systematically discover and capture revenue opportunities:

**Layer 1: Scenario Discovery** - Extract structured revenue scenarios from financial advisor publications, articles, and market trends. Transform industry insights into actionable opportunity templates.

**Layer 2: Client Matching** - Match clients to scenarios using systematic criteria, calculate revenue potential, and generate ranked opportunity lists (Top 25 weekly reports).

Together, these layers create a repeatable system for identifying opportunities that might otherwise be missed in day-to-day practice.

---

## When to Use This Skill

### Scenario Discovery Triggers
Use this skill when the user:
- Pastes or references an article from financial publications (ThinkAdvisor, Financial Advisor Magazine, Barron's, etc.)
- Says "help me find opportunities from this article"
- Asks to "extract a scenario" or "build my scenario library"
- Mentions wanting to discover new revenue opportunities from industry trends
- References specific publications: "I read an article about..."

### Client Matching Triggers
Use this skill when the user:
- Has client data and asks to "scan my book" or "find opportunities"
- Requests "Top 25 opportunities" or "weekly opportunity report"
- Asks "which clients should I call this week?"
- Wants to know "what opportunities exist in my book"
- Provides client data (Google Sheet, CSV) and asks for analysis
- Says "match my clients to scenarios"

### Combined Workflow Triggers
- "Build me a complete OpportunityIQ system"
- "Help me set up weekly opportunity scanning"
- "I want to discover scenarios AND find client matches"

---

## How to Use This Skill

### MODE 1: Scenario Extraction from Articles

**User provides:** Article text, URL, or publication content

**Claude's process:**
1. Read and analyze the article
2. Identify opportunity patterns using the Scenario Extraction Framework (see references/)
3. Ask the 6 key questions:
   - What's the opportunity?
   - Who is this for?
   - How do you identify them?
   - What's the revenue?
   - What are the exclusions?
   - What's the next action?
4. Structure the scenario using the standard template
5. Provide the completed scenario ready to add to the user's library

**Output format:** Structured scenario with:
- Scenario ID and name
- Business case (why it matters)
- Matching criteria (specific, testable)
- Revenue calculation formula
- Exclusions
- Implementation steps
- Source attribution

**Example interaction:**
```
User: "I found this ThinkAdvisor article about rising FIA rates. Help me extract a scenario."

Claude: [Reads article, identifies opportunity, asks clarifying questions, then provides:]

"**Scenario: FIA-001 - Surrender Period Ending Review**

Business Case: FIA rates have increased 2-3% over past 24 months. Clients who purchased during low-rate environment are earning significantly less. Post-surrender is optimal upgrade window.

Matching Criteria:
- Product_Type = 'FIA'
- Purchase_Date >= 5 years ago  
- Current_Cap_Rate < 5.5%
- Surrender_End_Date within 12 months

Revenue: FIA_Value × 0.05 (5% commission)
Example: $500K FIA = $25,000 revenue

Next Actions:
1. Pull surrender schedule
2. Run current vs. new product illustration
3. Schedule 30-min review call
..."
```

---

### MODE 2: Client Opportunity Matching

**User provides:** 
- Scenario library (scenarios they want to test)
- Client data (Google Sheet, CSV, or structured data)

**Claude's process:**
1. Review the scenario library
2. Understand the client data structure
3. For each scenario, apply matching criteria to client data
4. Identify all client-scenario matches
5. Calculate revenue potential using formulas from references/
6. Apply business rules (max 1 opportunity per client, urgency weighting)
7. Rank by revenue potential
8. Filter to Top 25 (or user-specified number)
9. Format as actionable report

**Output format:** Ranked opportunity list with:
- Client name/ID
- Opportunity scenario
- Why it's a match (specific data points)
- Revenue estimate with calculation shown
- Urgency indicator
- Next action recommendation

**Example interaction:**
```
User: "Here's my client data [Google Sheet link]. I have 12 scenarios in my library. Find my Top 25 opportunities."

Claude: [Analyzes data, applies matching criteria, calculates revenue, ranks]

"**Top 25 Opportunities - Week of [Date]**

1. **Martinez, Sofia - FIA Surrender Review**
   - Current FIA: $487K, purchased 2019, cap 4.2%
   - Surrender ends: 2 months
   - New rates: 6.5-7% available
   - Revenue Est: $24,350 (5% commission)
   - Action: Schedule review before March 15

2. **Johnson, Robert - Cash Drag Opportunity**
   - Cash balance: $180K earning 0.5%
   - Move to money market at 5.0%
   - Revenue Est: $1,800/year (1% AUM)
   - Action: 15-min call to reposition

3. **Davis, Jennifer - Concentrated Position**
   - 45% portfolio in AAPL ($320K)
   - Diversification opportunity
   - Revenue Est: $16,000 (alternatives placement)
   - Action: Risk review + hedging conversation
..."
```

---

### MODE 3: Combined Workflow

**User says:** "Help me build a complete OpportunityIQ system"

**Claude guides through:**
1. **Discovery setup**: Which publications to monitor, extraction schedule
2. **Library building**: Extract 10-15 starter scenarios or use provided library
3. **Data integration**: Connect to client data source
4. **First scan**: Run initial matching to prove concept
5. **Ongoing workflow**: Set up weekly discovery + weekly scanning cadence

---

## The Scenario Extraction Framework

When extracting scenarios from articles, always gather:

### 1. Opportunity Identification
**What's the specific action an advisor can take?**
- Not just "rates are rising" but "review clients with low-yielding cash"
- Must be actionable, not just informational

### 2. Client Segmentation  
**Who does this apply to?**
- Demographics (age, net worth, life stage)
- Product holdings (FIA, life insurance, concentrated positions)
- Behavioral triggers (recent events, concerns)

### 3. Matching Criteria
**How do you identify them systematically?**
- Must be specific, testable criteria
- Data-driven (can query from database)
- Example: `Product_Type = 'FIA' AND Purchase_Date > 5 years ago`

### 4. Revenue Calculation
**How do you monetize this?**
- Product commission formula
- AUM fee calculation  
- Planning fee estimate
- Must be quantifiable

### 5. Exclusions
**Who does this NOT apply to?**
- Prevents false positives
- Client preferences or circumstances
- Recent actions that disqualify

### 6. Implementation Path
**What's the actual next action?**
- First conversation/meeting
- Data gathering needed
- Implementation timeline

For detailed extraction methodology, see `references/scenario-extraction-framework.md`

---

## Revenue Calculation Methods

OpportunityIQ uses standard financial advisor revenue models:

### Product Sales (Commission-Based)
```
Revenue = Product_Value × Commission_Rate

FIA Replacement: 5-6% of product value
Life Insurance: 1% of face value (varies by product)
Annuity Sale: 4-7% depending on type
```

### Asset Management (AUM-Based)
```
Revenue = New_AUM × Annual_Fee_Rate

Standard: 1% annually
Examples:
- $100K to managed account = $1,000/year
- $500K portfolio reposition = $5,000/year
```

### Planning Services (Fee-Based)
```
Revenue = Hours × Hourly_Rate
OR
Revenue = Flat_Fee

Tax planning: $500-2,500
Estate planning: $2,000-10,000
Comprehensive plan: $3,000-15,000
```

For complete formulas and examples, see `references/revenue-calculation-formulas.md`

---

## Business Rules for Opportunity Ranking

When generating Top 25 lists, apply these rules:

1. **One Opportunity Per Client Rule**
   - If a client matches multiple scenarios, select highest revenue
   - Exception: Bundle complementary opportunities (tax + reposition)

2. **Urgency Weighting**
   - Time-sensitive (deadline): 1.3x multiplier
   - Urgent (next 30 days): 1.2x multiplier
   - Near-term (31-90 days): 1.1x multiplier
   - Strategic (90+ days): 1.0x multiplier

3. **Complexity Adjustment**
   - Simple (one call): No adjustment
   - Moderate (standard meeting): No adjustment
   - Complex (multiple meetings): ÷ 1.1x
   - Advanced (professional coordination): ÷ 1.2x

4. **Minimum Revenue Threshold**
   - Only include opportunities > $500 estimated revenue
   - Adjustable based on practice size

---

## Example Scenarios in Starter Library

Users can begin with these 12 pre-built scenarios:

### Fixed Indexed Annuities (3)
- **FIA-001**: Surrender Period Ending Review
- **FIA-002**: Low Crediting Rate Upgrade  
- **FIA-003**: Income Rider Optimization

### Market/Cash Management (3)
- **MKT-001**: Rising Rate Bond Ladder Opportunity
- **MKT-002**: Cash Drag Repositioning
- **MKT-003**: Equity Volatility Protection

### Diversification (3)
- **DIV-001**: Concentrated Position Review
- **DIV-002**: Single Sector Overweight
- **DIV-003**: International Equity Underweight

### Tax Planning (3)
- **TAX-001**: Year-End Tax Loss Harvesting
- **TAX-002**: Q1 Tax Loss + Roth Conversion
- **TAX-003**: Market Downturn Tax Loss

See `assets/starter-scenarios.md` for complete details on each scenario.

---

## Data Requirements

### For Scenario Extraction
**Input:** Article or publication content
**No data integration required**

### For Client Matching
**Required data fields:**
- Client ID/Name
- Basic demographics (age, net worth)
- Product holdings (type, value, purchase date)
- Account data (cash balances, yields, holdings)

**Optional but helpful:**
- Risk tolerance
- Recent communications/notes
- Life events
- Goals/objectives

**Supported formats:**
- Google Sheets (preferred)
- CSV files
- Structured data in conversation

---

## Output Formats

### Scenario Extraction Output
Structured scenario document with all fields completed, ready to add to library or test against client data.

### Client Matching Output
**Standard format:** Top 25 opportunities ranked by revenue

**Optional formats:**
- Top 10 for focused week
- Opportunities by scenario type
- Opportunities by client segment
- Urgency-sorted (deadlines first)

**Delivery options:**
- Text report in conversation
- Markdown document
- Email-ready format
- Google Sheet export

---

## Tips for Best Results

### Scenario Discovery
1. **Start with high-quality sources**: Stick to Financial Advisor Magazine, ThinkAdvisor, Barron's, Best's Review
2. **Look for specific triggers**: Articles with "opportunity for advisors" or "clients should review"
3. **Test scenarios**: Always validate matching criteria against sample clients before activating
4. **Build gradually**: Start with 10-15 scenarios, expand to 25-50 over time

### Client Matching
1. **Clean data first**: Ensure client data is current and accurate
2. **Validate matches**: Spot-check first 5-10 matches to ensure criteria work correctly
3. **Adjust thresholds**: Fine-tune minimum revenue or urgency weights based on your practice
4. **Act quickly**: Top 25 should be actionable THIS WEEK, not aspirational

### Combined System
1. **Weekly cadence**: Discover scenarios weekly (1-2 hours), scan clients weekly (automated)
2. **Track performance**: Note which scenarios generate actual revenue
3. **Retire underperformers**: Remove scenarios that don't produce opportunities after 3 months
4. **Refine criteria**: Adjust matching rules based on false positives/negatives

---

## Supporting Documentation

This skill references detailed methodologies in the `references/` directory:

- **scenario-extraction-framework.md**: Complete extraction methodology, examples, and templates
- **client-matching-methodology.md**: Detailed matching logic, business rules, and edge cases
- **revenue-calculation-formulas.md**: All revenue calculation methods with examples
- **publication-sources.md**: Recommended publications and how to monitor them

Pre-built assets in the `assets/` directory:

- **starter-scenarios.md**: Complete details on 12 ready-to-use scenarios
- **scenario-library-template.csv**: Template for building your own scenario library

---

## Skill Evolution

As you use OpportunityIQ, the skill improves through:

1. **Performance tracking**: Which scenarios generate actual revenue
2. **Criteria refinement**: Adjusting matching rules to reduce false positives
3. **Library expansion**: Growing from 12 → 50+ scenarios over 6-12 months
4. **Pattern recognition**: Identifying which types of opportunities work best for your practice

The goal is a self-improving system that gets better at finding opportunities the longer you use it.

---

## Quick Start Guide

**Week 1**: Prove the concept
1. Use the 12 starter scenarios (no extraction needed)
2. Provide client data (10-50 clients)
3. Run first scan
4. Review Top 25 opportunities
5. Validate: Would you act on at least 5 of these?

**Week 2-4**: Expand the system
1. Extract 5-10 new scenarios from recent articles
2. Re-scan clients with expanded library
3. Set up weekly discovery workflow (1 hour Friday)
4. Set up automated weekly scanning

**Month 2+**: Optimize and scale
1. Track which scenarios generate revenue
2. Retire underperformers, double down on winners
3. Expand library to 30-50 scenarios
4. Fine-tune matching criteria based on results

---

## Questions During Use

If the user asks:
- **"How do I find publications to monitor?"** → Reference publication-sources.md
- **"How do I calculate revenue for [X]?"** → Reference revenue-calculation-formulas.md
- **"Show me an example extraction"** → Reference scenario-extraction-framework.md
- **"What are the starter scenarios?"** → Reference starter-scenarios.md
- **"How do I test matching criteria?"** → Use a small sample of client data, validate matches manually
- **"What if I have too many matches?"** → Increase minimum revenue threshold or tighten criteria
- **"What if I have too few matches?"** → Loosen criteria, expand scenario library, or check data quality

Always guide users toward building a systematic, repeatable process rather than one-off analysis.
