---
name: analyzing-tam
description: Calculates Total Addressable Market (TAM), Serviceable Addressable Market (SAM), and Serviceable Obtainable Market (SOM) using multiple methodologies including top-down, bottom-up, and value theory approaches. Use when the user requests market sizing, TAM/SAM/SOM calculation, addressable market analysis, or wants to quantify market opportunity.
---

# Analyzing TAM

This skill performs comprehensive Total Addressable Market (TAM) analysis to quantify market opportunities using industry-standard methodologies.

## When to Use This Skill

Invoke this skill when the user:
- Requests TAM, SAM, or SOM calculations
- Asks for market sizing or opportunity quantification
- Needs addressable market analysis for business planning
- Mentions total available market or market opportunity
- Wants to validate market size for investors or stakeholders
- Asks "how big is the market?" or "what's the opportunity size?"

## Market Sizing Framework

### TAM, SAM, SOM Definition

**Total Addressable Market (TAM):**
- The total market demand for a product or service
- Assumes 100% market share with no constraints
- Represents maximum revenue opportunity

**Serviceable Addressable Market (SAM):**
- The portion of TAM you can realistically target
- Constrained by your product capabilities, geography, or business model
- The segment of TAM within your reach

**Serviceable Obtainable Market (SOM):**
- The portion of SAM you can realistically capture
- Accounts for competition, market penetration, and execution
- Your realistic short-to-medium term opportunity

```
Visualization:

┌─────────────────────────────────────────┐
│           TAM ($100B)                   │  Total market for category
│  ┌───────────────────────────────────┐  │
│  │     SAM ($20B)                    │  │  Your addressable segment
│  │  ┌─────────────────────────────┐  │  │
│  │  │    SOM ($2B)                │  │  │  Your realistic capture
│  │  │                             │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## TAM Calculation Methodologies

### Method 1: Top-Down Analysis

Start with broad market data and narrow down:

**Steps:**
1. Identify the total industry or category size from research
2. Determine what percentage applies to your specific solution
3. Apply geographic, demographic, or other filters
4. Calculate TAM based on filtered addressable market

**Formula:**
```
TAM = Total Market Size × % Relevant to Your Solution
```

**Example:**
```
Industry: Cloud Infrastructure Market = $200B (2024)
Relevant Segment: Serverless Computing = 15% of cloud infrastructure
Geographic Focus: North America = 45% of global market

TAM = $200B × 15% × 45% = $13.5B
```

**Best for:**
- Established markets with available data
- Broad categories with analyst coverage
- Initial rough estimates
- Investor presentations

**Limitations:**
- Relies on accuracy of published data
- May be too broad or imprecise
- Can miss nuances of your specific offering

### Method 2: Bottom-Up Analysis

Build from individual customer segments:

**Steps:**
1. Define your target customer segments precisely
2. Count the number of potential customers per segment
3. Estimate average revenue per customer (ARPC)
4. Calculate TAM by multiplying customers × ARPC

**Formula:**
```
TAM = (# of Potential Customers) × (Average Revenue per Customer)
```

**Example:**
```
Target: Mid-market SaaS companies (100-1000 employees) in North America

Segment 1: Series A-B SaaS companies
- Number: 5,000 companies
- ARPC: $50,000/year
- Subtotal: $250M

Segment 2: Series C+ SaaS companies
- Number: 2,000 companies
- ARPC: $150,000/year
- Subtotal: $300M

TAM = $250M + $300M = $550M
```

**Best for:**
- Well-defined customer segments
- Countable customer populations
- B2B markets
- Precise, defensible estimates

**Limitations:**
- Requires detailed customer data
- Time-intensive research
- May miss emerging segments

### Method 3: Value Theory Analysis

Estimate based on value created:

**Steps:**
1. Identify the problem your solution solves
2. Quantify the cost of the problem or value of the solution
3. Count affected customers/transactions
4. Calculate total value you could capture

**Formula:**
```
TAM = (# of Value Instances) × (Value per Instance) × (% You Can Capture)
```

**Example:**
```
Solution: Fraud detection for e-commerce

Problem: Online payment fraud losses = $41B globally
Your Solution: Reduces fraud by 70%
Value Created: $41B × 70% = $28.7B in fraud prevented
Your Pricing: Capture 5% of value created as fees

TAM = $28.7B × 5% = $1.44B
```

**Best for:**
- Innovative or new markets
- Quantifiable value propositions
- Replacement or displacement plays
- Cost-saving solutions

**Limitations:**
- Requires assumptions about value capture
- Value may be hard to quantify
- Customer willingness to pay may differ

## SAM Calculation

Narrow TAM to your serviceable market:

**Steps:**
1. Start with your calculated TAM
2. Apply constraints based on your business model:
   - Geographic limitations (regions you serve)
   - Product limitations (features you offer)
   - Customer size limitations (enterprise vs. SMB)
   - Channel limitations (direct sales vs. partners)
   - Regulatory limitations (compliance requirements)
3. Calculate filtered addressable market

**Example:**
```
TAM: $13.5B (serverless computing, North America)

Constraints:
- Only serving US (not Canada/Mexico): 80% of NA market
- Only targeting companies >50 employees: 60% of market
- Only AWS-compatible (not Azure/GCP): 40% market share

SAM = $13.5B × 80% × 60% × 40% = $2.59B
```

## SOM Calculation

Determine realistic obtainable market:

**Steps:**
1. Start with your calculated SAM
2. Apply realistic market penetration assumptions:
   - Expected market share in 3-5 years
   - Competitive positioning
   - Sales and marketing capacity
   - Product-market fit and adoption rates
3. Calculate based on realistic capture rate

**Common Approaches:**

**Approach 1: Market Share Based**
```
SOM = SAM × Expected Market Share %

Example:
SAM = $2.59B
Expected market share in Year 3 = 5%
SOM = $2.59B × 5% = $129.5M
```

**Approach 2: Sales Capacity Based**
```
SOM = (# of Sales Reps) × (Quota per Rep) × (Achievement Rate)

Example:
Sales team size: 20 reps
Quota per rep: $1M/year
Average achievement: 80%
SOM = 20 × $1M × 80% = $16M (Year 1)
```

**Approach 3: Growth Projection Based**
```
SOM = Current Revenue × (1 + Growth Rate)^Years

Example:
Current ARR: $5M
Target growth rate: 100% YoY
Year 3 projection: $5M × (1 + 1.0)^3 = $40M
SOM = $40M
```

## Research and Data Sources

**Top-Down Data Sources:**
- Industry analyst firms (Gartner, Forrester, IDC)
- Market research companies (Statista, IBISWorld, Grand View Research)
- Industry association reports
- Government statistical agencies
- Public company filings and earnings
- Trade publications

**Bottom-Up Data Sources:**
- Business directories (LinkedIn Sales Navigator, ZoomInfo, Crunchbase)
- Census and labor statistics
- Industry databases
- Company registries
- Your CRM and customer data
- Survey data

**Use WebSearch to find:**
- Recent market sizing reports
- Competitive intelligence
- Industry growth rates
- Customer population data

## TAM Analysis Template

Use this structure for comprehensive TAM analysis:

```markdown
# TAM/SAM/SOM Analysis: [Product/Market]

## Executive Summary
- TAM: $XXB
- SAM: $XXB
- SOM (Year 3): $XXM
- Methodology: [Top-down, Bottom-up, Value theory]
- Confidence Level: [High/Medium/Low]

## Market Definition
- Product/Service: [Description]
- Target Customer: [Who you serve]
- Geography: [Where you operate]
- Time Horizon: [Analysis year]

## TAM Calculation

### Methodology: [Selected approach]

**Data Sources:**
- [Source 1 with link/citation]
- [Source 2 with link/citation]

**Calculation:**
[Step-by-step breakdown]

**Result: TAM = $XXB**

### Validation (Cross-check with alternative method)
[Alternative calculation to validate]

## SAM Calculation

**Starting Point:** TAM = $XXB

**Constraints Applied:**
1. [Constraint 1]: reduces by XX%
2. [Constraint 2]: reduces by XX%
3. [Constraint 3]: reduces by XX%

**Calculation:**
[Step-by-step]

**Result: SAM = $XXB**

## SOM Calculation

**Starting Point:** SAM = $XXB

**Assumptions:**
- Market share target (Year 3): X%
- Competitive position: [Rationale]
- GTM capacity: [Sales/marketing capability]

**Calculation:**
[Step-by-step]

**Result: SOM = $XXM**

## Market Segmentation

### Segment 1: [Name]
- Size: $XXM
- Growth: XX%
- Characteristics: [Description]
- Competition: [Intensity]

### Segment 2: [Name]
- Size: $XXM
- Growth: XX%
- Characteristics: [Description]
- Competition: [Intensity]

## Market Growth

- Historical CAGR (past 5 years): XX%
- Projected CAGR (next 5 years): XX%
- Growth drivers: [List key factors]
- Headwinds: [List challenges]

## Competitive Landscape Impact

- Market concentration: [Fragmented/Consolidated]
- Top 3 players' market share: XX%
- Your competitive advantage: [Differentiation]
- Barriers to entry: [High/Medium/Low]

## Validation and Assumptions

**Key Assumptions:**
1. [Assumption 1 with justification]
2. [Assumption 2 with justification]
3. [Assumption 3 with justification]

**Sensitivity Analysis:**
- Best case: TAM = $XXB, SOM = $XXM
- Base case: TAM = $XXB, SOM = $XXM
- Worst case: TAM = $XXB, SOM = $XXM

**Confidence Level:** [High/Medium/Low]
**Reasoning:** [Why you have this confidence level]

## Strategic Implications

- Market is [large/medium/small] enough to support our goals
- Priority segments: [Which to focus on]
- Market timing: [Now/wait/too early]
- Investment recommendation: [Go/no-go rationale]
```

## Common Analysis Patterns

**Pattern 1: New Market Creation**
- No existing market data available
- Use value theory approach
- Estimate based on problem size
- Look at analogous markets
- Example: Estimating TAM for a novel AI application

**Pattern 2: Market Substitution**
- Replacing existing solution
- Size existing market being replaced
- Apply adoption curve assumptions
- Example: Cloud replacing on-premise software

**Pattern 3: Multi-Segment Rollup**
- Calculate TAM per segment separately
- Sum across segments
- Weight by priority/attractiveness
- Example: Horizontal SaaS serving multiple industries

**Pattern 4: Geographic Expansion**
- Start with proven market (SAM)
- Extrapolate to broader geography (TAM)
- Adjust for regional differences
- Example: US success expanding to Europe

## Validation Checklist

Before finalizing TAM analysis:

- [ ] Market clearly defined (product, customer, geography)
- [ ] Methodology appropriate for market maturity
- [ ] Data sources credible and recent
- [ ] Calculations shown step-by-step
- [ ] Assumptions explicitly stated and justified
- [ ] Cross-validated with alternative method
- [ ] TAM > SAM > SOM relationship logical
- [ ] Growth rates and trends included
- [ ] Competitive landscape considered
- [ ] Sensitivity analysis performed
- [ ] Strategic implications drawn
- [ ] Confidence level assessed
- [ ] All sources cited

## Common Pitfalls to Avoid

**Pitfall 1: TAM Too Broad**
- ❌ "The entire $500B software market"
- ✅ "The $5B project management software market for mid-market companies"

**Pitfall 2: Unrealistic SOM**
- ❌ Assuming 50% market share in Year 2
- ✅ Conservative 2-5% market share projection

**Pitfall 3: Confusing TAM and SAM**
- ❌ Presenting constrained market as TAM
- ✅ Clear distinction between total vs. addressable

**Pitfall 4: Outdated Data**
- ❌ Using 2018 market size for 2024 analysis
- ✅ Using recent data and applying growth rates

**Pitfall 5: Circular Logic**
- ❌ "TAM is large because VCs invested in competitors"
- ✅ Independent, data-driven calculation

**Pitfall 6: Missing Constraints**
- ❌ Ignoring product limitations in SAM
- ✅ Realistic filtering based on your capabilities

## Examples

**Example 1: B2B SaaS TAM (Bottom-Up)**

Input: "Calculate TAM for an AI-powered code review tool targeting software companies"

Process:
1. Define target: Companies with 10+ engineers
2. Research company count:
   - US companies with 10-50 engineers: 50,000
   - US companies with 50-200 engineers: 15,000
   - US companies with 200+ engineers: 5,000
3. Estimate ARPC:
   - Small teams (10-50): $5,000/year
   - Medium teams (50-200): $25,000/year
   - Large teams (200+): $100,000/year
4. Calculate:
   - Small: 50,000 × $5K = $250M
   - Medium: 15,000 × $25K = $375M
   - Large: 5,000 × $100K = $500M
   - TAM = $1.125B

Output: TAM = $1.125B for US market, with segment breakdown and assumptions

**Example 2: Consumer Market TAM (Top-Down)**

Input: "What's the TAM for a meal planning app in the US?"

Process:
1. Find total market size:
   - US meal kit delivery market: $10B (2024)
   - US cooking apps market: $500M (2024)
   - Adjacent market total: $10.5B
2. Determine relevant portion:
   - Digital-only solution: 5% of meal kit market
   - Your category: 100% of cooking apps
   - TAM = ($10B × 5%) + $500M = $1B
3. Validate bottom-up:
   - US households: 130M
   - Households who cook regularly: 70% = 91M
   - Willing to pay for meal planning: 5% = 4.55M
   - ARPC: $100/year
   - TAM = 4.55M × $100 = $455M
4. Average estimates: ~$700M TAM

Output: TAM = $700M (range: $455M-$1B) with methodology and validation

## Additional Notes

- Always use multiple methods to validate TAM
- Be conservative in assumptions - investors prefer defensible numbers
- Update TAM analysis annually as markets evolve
- Document all assumptions for future reference
- Consider both current TAM and projected TAM in 3-5 years
- Smaller, well-researched TAM is better than inflated guesswork
- Link TAM to business strategy and funding requirements
- Use market-research skill for supporting data collection
- Combine with market-mapping skill to visualize segments
