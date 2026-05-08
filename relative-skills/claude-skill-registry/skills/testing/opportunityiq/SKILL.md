---
name: opportunityiq-mvp-scanner
description: Scans client data against revenue opportunity scenarios to identify and rank the top sales opportunities. Matches clients to scenarios like FIA replacements approaching surrender, cash drag opportunities, and concentrated portfolio positions. Calculates revenue potential and generates prioritized opportunity reports for financial advisors.
---

# OpportunityIQ MVP Scanner

Identifies revenue opportunities by matching clients against pre-defined scenarios and calculating potential revenue.

## When to Use This Skill

Use when the user asks to:
- "Scan my clients for opportunities"
- "Find revenue opportunities in my book"
- "Run OpportunityIQ on my client data"
- "Identify sales opportunities"
- "Generate my weekly opportunity report"

## Inputs Required

1. **Client Data**: Google Sheets link with tabs:
   - `Client_Master`: Client demographics, portfolio totals, cash balances
   - `Products`: FIAs, life insurance, annuities with details
   - `Holdings`: Investment positions for concentration analysis

2. **Scenario Selection** (defaults to MVP scenarios):
   - FIA Surrender Ending
   - Cash Drag Opportunity
   - Concentrated Position

## Reference Materials

For detailed guidance on specific topics, consult these reference files:

- **Data Structure**: See [data_structure_guide.md](references/data_structure_guide.md) for comprehensive guide on handling multi-source data with client identifiers
- **Classifications**: See [expanded_classifications.md](references/expanded_classifications.md) for 15+ classification categories with detailed explanations
- **Implementation**: See [implementation_guide.md](references/implementation_guide.md) for step-by-step deployment roadmap
- **Product Reference**: See [product_reference_system.md](references/product_reference_system.md) for maintaining product/carrier reference tables
- **Decision Guide**: See [decision_guide.md](references/decision_guide.md) for choosing between different approaches
- **Starter Scenarios**: See [starter_scenarios.md](references/starter_scenarios.md) for 12 fully-completed scenario examples

## Templates

Use these templates for creating new scenarios:
- **Excel Template**: [scenario_template.xlsx](assets/scenario_template.xlsx) - Excel workbook with Scenario Library, Classification Reference, and Example Scenarios
- **Markdown Template**: [scenario_template.md](assets/scenario_template.md) - Markdown version optimized for LLM processing

## Process Workflow

### Step 1: Load & Validate Data

```python
# Load Google Sheets data
client_master = load_sheet(url, 'Client_Master')
products = load_sheet(url, 'Products')
holdings = load_sheet(url, 'Holdings')

# Validate required columns exist
required_columns = {
    'Client_Master': ['Client_ID', 'Client_Name', 'Total_Portfolio', 'Cash_Balance', 'Cash_Yield'],
    'Products': ['Client_ID', 'Product_Type', 'Current_Value', 'Surrender_End_Date', 'Cap_Rate'],
    'Holdings': ['Client_ID', 'Current_Value', 'Percent_of_Portfolio']
}

# Report any missing data
```

### Step 2: Match Scenarios

#### Scenario 1: FIA Surrender Ending

**Criteria**:
- Product_Type = 'FIA'
- Surrender_End_Date within 12 months from today
- Cap_Rate < 5.5%

**Revenue Calculation**:
```python
revenue = product['Current_Value'] * 0.05  # 5% commission
```

**Output Template**:
```
Client: {client_name}
Type: FIA Replacement Opportunity
Details: {product_name} FIA with ${current_value:,} approaching surrender end in {months} months. Current cap rate of {cap_rate} is below market average of 5.5-6.5%.
Revenue Estimate: ${revenue:,}
Action: Schedule review meeting to discuss current product performance and illustrate replacement options with higher crediting rates.
```

#### Scenario 2: Cash Drag

**Criteria**:
- Cash_Balance > $50,000
- Cash_Yield < 3.0%

**Revenue Calculation**:
```python
revenue = client['Cash_Balance'] * 0.01  # 1% AUM fee
```

**Output Template**:
```
Client: {client_name}
Type: Cash Repositioning Opportunity
Details: ${cash_balance:,} in cash earning {cash_yield}. Money market funds currently yielding 4.5-5.5%.
Revenue Estimate: ${revenue:,} annually
Action: Quick call to reposition to higher-yielding money market or short-term treasury fund.
```

#### Scenario 3: Concentrated Position

**Criteria**:
- Any single position > 20% of portfolio
- Total_Portfolio > $500,000
- Accredited_Investor = 'Yes'

**Revenue Calculation**:
```python
# Assume 30% of concentrated position can be repositioned
reposition_amount = position['Current_Value'] * 0.30
# Alternative investment typically 5% upfront
revenue = reposition_amount * 0.05
```

**Output Template**:
```
Client: {client_name}
Type: Concentration Risk / Diversification
Details: {ticker} position of ${position_value:,} represents {percentage}% of portfolio. Significant single-stock concentration risk.
Revenue Estimate: ${revenue:,}
Action: Schedule portfolio review to discuss diversification into alternative investments or sector diversification.
```

### Step 3: Consolidate & Rank

```python
# Collect all opportunities
all_opportunities = []
all_opportunities.extend(fia_opportunities)
all_opportunities.extend(cash_opportunities)
all_opportunities.extend(concentration_opportunities)

# Deduplicate: One opportunity per client (keep highest revenue)
client_best_opp = {}
for opp in all_opportunities:
    client_id = opp['client_id']
    if client_id not in client_best_opp:
        client_best_opp[client_id] = opp
    elif opp['revenue'] > client_best_opp[client_id]['revenue']:
        client_best_opp[client_id] = opp

# Sort by revenue (highest first)
sorted_opportunities = sorted(
    client_best_opp.values(),
    key=lambda x: x['revenue'],
    reverse=True
)
```

### Step 4: Generate Report

**Report Format**:

```
═══════════════════════════════════════════════════
  OPPORTUNITYIQ MVP SCAN RESULTS
═══════════════════════════════════════════════════

Generated: {current_date_time}
Clients Scanned: {total_clients}
Opportunities Found: {total_opportunities}
Total Revenue Potential: ${total_revenue:,}

───────────────────────────────────────────────────

OPPORTUNITY #1 - ${revenue:,}

Client: {client_name} ({client_id})
Type: {scenario_name}

Details:
{detailed_description}

Recommended Action:
{next_steps}

───────────────────────────────────────────────────

[Repeat for each opportunity]

───────────────────────────────────────────────────

SUMMARY BY TYPE:
• FIA Replacement: {fia_count} opportunities - ${fia_total:,}
• Cash Repositioning: {cash_count} opportunities - ${cash_total:,}
• Concentration/Diversification: {conc_count} opportunities - ${conc_total:,}

PRIORITY ACTIONS:
1. High Priority (>$5,000): {high_priority_count} opportunities
2. Medium Priority ($2,000-$5,000): {medium_priority_count} opportunities
3. Quick Wins (<$2,000): {quick_win_count} opportunities

NEXT STEPS:
□ Review each opportunity for accuracy
□ Prioritize top 3-5 for immediate outreach
□ Note any false positives to refine criteria
□ Decide: Expand to more scenarios or scale client base?
```

## Error Handling

Handle common data issues gracefully:

```python
# Missing data
if 'Surrender_End_Date' not in products.columns:
    print("⚠️ Warning: Surrender_End_Date not found in Products sheet. Skipping FIA scenario.")

# Invalid dates
try:
    surrender_date = pd.to_datetime(product['Surrender_End_Date'])
except:
    print(f"⚠️ Invalid date format for client {client_id}, skipping this product")

# Empty dataframes
if holdings.empty:
    print("⚠️ No holdings data found. Skipping concentration scenario.")

# Division by zero
if total_portfolio > 0:
    percent = position_value / total_portfolio
else:
    percent = 0
```

## Output Examples

### Example 1: FIA Opportunity

```
OPPORTUNITY #1 - $24,350

Client: John Smith (C001)
Type: FIA Replacement Opportunity

Details:
Allianz 222 FIA with $487,000 approaching surrender end in 7 months. Current cap rate of 4.5% is significantly below current market rates of 5.8-6.5%. Client has held product for 6.5 years through low-rate environment.

Recommended Action:
1. Schedule 45-minute review meeting within next 2 weeks
2. Run side-by-side illustration: Current product vs. best available replacement
3. Review surrender schedule details to confirm no penalties
4. Prepare 1035 exchange paperwork if client approves
5. Expected timeline: 30-60 days to completion

Revenue Estimate: $24,350 (5% commission on $487,000)
Confidence: High
```

### Example 2: Cash Drag Opportunity

```
OPPORTUNITY #3 - $1,500

Client: Mary Johnson (C002)
Type: Cash Repositioning Opportunity

Details:
$150,000 in cash earning 0.5% in traditional savings account. Money market funds currently yielding 4.5-5.5%. Client is losing approximately $6,000 annually in opportunity cost. No upcoming liquidity needs identified.

Recommended Action:
1. Quick 15-minute call to client
2. Explain opportunity cost (earning $750/year vs. $7,500/year)
3. Recommend repositioning to money market fund
4. Execute trade same day if approved
5. No-brainer quick win

Revenue Estimate: $1,500 annually (1% AUM fee)
Confidence: High
```

## Validation Checklist

After running scan, validate results:

- [ ] All opportunities have valid Client_IDs
- [ ] Revenue estimates are > $0
- [ ] Descriptions are specific (not generic)
- [ ] Recommended actions are actionable
- [ ] No obvious false positives (clients who don't match criteria)
- [ ] Revenue estimates seem realistic for your practice

## Customization Options

User can adjust:

**Revenue Commission Rates**:
```python
COMMISSION_RATES = {
    'FIA_replacement': 0.05,      # Default: 5%
    'Life_insurance': 0.01,       # Default: 1% of face value
    'AUM_fee': 0.01,              # Default: 1%
    'Alternative_product': 0.05,  # Default: 5%
}
```

**Threshold Values**:
```python
THRESHOLDS = {
    'cash_minimum': 50000,                    # Minimum cash balance
    'cash_yield_threshold': 3.0,              # Yield below which to flag
    'fia_cap_rate_threshold': 5.5,            # Cap rate below market
    'concentration_percentage': 20,            # Portfolio concentration %
    'concentration_minimum_portfolio': 500000, # Minimum portfolio for concentration
}
```

**Urgency Weighting** (if implementing ranking):
```python
URGENCY_WEIGHTS = {
    'Immediate': 1.3,
    'Near-term': 1.2,
    'Time-sensitive': 1.3,
    'Strategic': 1.0,
}
```

## Expansion Path

To add more scenarios:

1. Define matching criteria
2. Add revenue calculation logic
3. Create output template
4. Test with sample data
5. Add to scenario rotation

**Future scenarios to consider**:
- Tax loss harvesting (seasonal)
- RMD planning (pre-age 73)
- Life insurance coverage gaps
- Beneficiary reviews
- Estate planning triggers
- Portfolio rebalancing triggers

## Notes

- **Privacy**: Client data never leaves your Google Sheet. Skill only reads and analyzes.
- **Accuracy**: Revenue estimates are conservative. Actual results may vary.
- **Frequency**: Recommend running weekly (every Sunday night for Monday delivery).
- **Scale**: Tested with 10-50 clients. Can handle up to 500 clients per scan.

## Success Metrics

Track these over time:
- Opportunities identified per scan
- False positive rate (opportunities that aren't real)
- Conversion rate (opportunities → actions)
- Revenue generated (closed deals from opportunities)
- Time saved (vs. manual review)
