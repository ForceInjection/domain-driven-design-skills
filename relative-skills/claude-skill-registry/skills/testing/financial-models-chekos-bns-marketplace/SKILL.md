---
name: financial-models
description: |
  Load when working on revenue tracking, financial forecasting, P&L statements,
  unit economics, or business financial planning. Contains frameworks and
  templates for creator business financial management.
---

# Financial Models Skill

## Core Philosophy

Know your numbers. Track revenue and expenses religiously. Make data-driven decisions. Aim for profitability, not just revenue.

## Key Financial Metrics

### Revenue Metrics

#### Monthly Recurring Revenue (MRR)
```
MRR = Number of Subscribers × Monthly Price
```
Stable, predictable income from subscriptions or retainers.

#### Annual Recurring Revenue (ARR)
```
ARR = MRR × 12
```
Used for annual planning and valuation.

#### Average Revenue Per User (ARPU)
```
ARPU = Total Revenue / Total Customers
```
Helpful for comparing segments and tracking growth.

#### Revenue by Stream
Track each revenue source separately:
- Sponsorships
- Digital products (courses, templates)
- Subscriptions
- Consulting
- Affiliate

### Profitability Metrics

#### Gross Margin
```
Gross Margin = (Revenue - COGS) / Revenue × 100
```
For creators, COGS is typically low (platform fees, contractors).

**Target**: 70-90% for digital products, 60-80% for services

#### Net Profit Margin
```
Net Margin = (Revenue - All Expenses) / Revenue × 100
```

**Target**: 40-60% for lean operations (Justin Welsh achieves 90%+)

#### Operating Expenses
- Software/tools subscriptions
- Contractors/freelancers
- Marketing/advertising
- Professional services (legal, accounting)
- Education/training

### Customer Metrics

#### Customer Acquisition Cost (CAC)
```
CAC = Total Marketing Spend / New Customers Acquired
```

#### Customer Lifetime Value (LTV)
```
LTV = ARPU × Average Customer Lifespan (months)
```

For subscriptions:
```
LTV = Monthly Price / Monthly Churn Rate
```

#### LTV:CAC Ratio
```
LTV:CAC = Customer Lifetime Value / Customer Acquisition Cost
```

**Target**: 3:1 or higher
- Below 1:1: Losing money on acquisition
- 1:1 to 3:1: Sustainable but tight
- 3:1+: Healthy, can invest in growth

### Subscription Metrics

#### Churn Rate
```
Monthly Churn = Customers Lost / Starting Customers × 100
```

**Benchmarks**:
- <3% monthly: Excellent
- 3-5% monthly: Good
- 5-7% monthly: Needs attention
- 7%+ monthly: Problem

#### Retention Rate
```
Retention = 1 - Churn Rate
```

## P&L Statement Template

### Monthly P&L

```markdown
# Profit & Loss Statement
## [Month Year]

### Revenue
| Source | Amount | % of Total |
|--------|--------|-----------|
| Sponsorships | $X,XXX | XX% |
| Course Sales | $X,XXX | XX% |
| Subscriptions | $XXX | XX% |
| Consulting | $X,XXX | XX% |
| Affiliate | $XXX | XX% |
| **Total Revenue** | **$X,XXX** | **100%** |

### Cost of Goods Sold (COGS)
| Item | Amount |
|------|--------|
| Platform fees | $XXX |
| Payment processing | $XXX |
| Course hosting | $XXX |
| **Total COGS** | **$XXX** |

### Gross Profit
| | Amount | Margin |
|---|--------|--------|
| Gross Profit | $X,XXX | XX% |

### Operating Expenses
| Category | Amount |
|----------|--------|
| Software/Tools | $XXX |
| Contractors | $XXX |
| Marketing | $XXX |
| Professional services | $XXX |
| Other | $XXX |
| **Total OpEx** | **$XXX** |

### Net Profit
| | Amount | Margin |
|---|--------|--------|
| **Net Profit** | **$X,XXX** | **XX%** |
```

### Annual P&L Summary

```markdown
# Annual Summary [Year]

| Quarter | Revenue | COGS | Gross Profit | OpEx | Net Profit |
|---------|---------|------|--------------|------|------------|
| Q1 | $XX,XXX | $X,XXX | $XX,XXX | $X,XXX | $XX,XXX |
| Q2 | $XX,XXX | $X,XXX | $XX,XXX | $X,XXX | $XX,XXX |
| Q3 | $XX,XXX | $X,XXX | $XX,XXX | $X,XXX | $XX,XXX |
| Q4 | $XX,XXX | $X,XXX | $XX,XXX | $X,XXX | $XX,XXX |
| **Total** | **$XXX,XXX** | **$XX,XXX** | **$XX,XXX** | **$XX,XXX** | **$XX,XXX** |
```

## Revenue Forecasting

### Bottom-Up Forecasting

#### For Sponsorships
```markdown
Available slots per month: [X]
Expected fill rate: [X]%
Average deal size: $[X]
= Monthly sponsorship revenue: $[X]

Variables to adjust:
- Subscriber growth → higher rates
- More placements → more inventory
- Better engagement → higher rates
```

#### For Products
```markdown
Monthly traffic to landing page: [X]
Conversion rate: [X]%
Average order value: $[X]
= Monthly product revenue: $[X]

Variables to adjust:
- More traffic
- Better conversion rate
- Higher prices / upsells
```

#### For Subscriptions
```markdown
Current subscribers: [X]
Monthly growth: [X]%
Monthly churn: [X]%
Monthly price: $[X]
= MRR: $[X]

Projection:
Month 1: [X] subs × $[X] = $[X]
Month 2: [X] subs × $[X] = $[X]
...
```

### 12-Month Revenue Projection Template

```markdown
| Month | Sponsors | Products | Subs | Consulting | Affiliate | Total |
|-------|----------|----------|------|------------|-----------|-------|
| Jan | $X | $X | $X | $X | $X | $X |
| Feb | $X | $X | $X | $X | $X | $X |
| Mar | $X | $X | $X | $X | $X | $X |
| Apr | $X | $X | $X | $X | $X | $X |
| May | $X | $X | $X | $X | $X | $X |
| Jun | $X | $X | $X | $X | $X | $X |
| Jul | $X | $X | $X | $X | $X | $X |
| Aug | $X | $X | $X | $X | $X | $X |
| Sep | $X | $X | $X | $X | $X | $X |
| Oct | $X | $X | $X | $X | $X | $X |
| Nov | $X | $X | $X | $X | $X | $X |
| Dec | $X | $X | $X | $X | $X | $X |
| **Total** | $X | $X | $X | $X | $X | **$X** |

**Assumptions**:
- [List key assumptions]
```

## Unit Economics

### For Courses

```markdown
## [Course Name] Unit Economics

**Revenue per sale**: $[X]
**Costs per sale**:
- Payment processing (2.9% + $0.30): $[X]
- Platform fee (X%): $[X]
- Affiliate commission (X%): $[X]
**Net per sale**: $[X]

**Fixed costs** (one-time):
- Creation time: [X] hours × $[X]/hr = $[X]
- Tools/software: $[X]
- Marketing launch: $[X]
**Total fixed**: $[X]

**Break-even**: [X] sales
**Current sales**: [X]
**Profit so far**: $[X]
```

### For Sponsorships

```markdown
## Sponsorship Unit Economics

**Revenue per sponsor**: $[X] average
**Costs per sponsor**:
- Sales time: [X] hours × $[X]/hr = $[X]
- Creative review: [X] hours = $[X]
- Reporting: [X] hours = $[X]
**Net per sponsor**: $[X]

**Monthly capacity**: [X] sponsors
**Break-even (for time)**: [X] sponsors
**Target**: [X] sponsors at $[X] average = $[X] net
```

## Financial Planning

### Budget Template

```markdown
# [Year] Budget

## Revenue Targets
| Source | Annual Target | Monthly Avg |
|--------|---------------|-------------|
| Sponsorships | $[X] | $[X] |
| Products | $[X] | $[X] |
| Subscriptions | $[X] | $[X] |
| Consulting | $[X] | $[X] |
| Affiliate | $[X] | $[X] |
| **Total** | **$[X]** | **$[X]** |

## Expense Budget
| Category | Annual | Monthly | Notes |
|----------|--------|---------|-------|
| Tools/Software | $[X] | $[X] | [List] |
| Contractors | $[X] | $[X] | [Who] |
| Marketing | $[X] | $[X] | [Channels] |
| Professional | $[X] | $[X] | Legal, accounting |
| Education | $[X] | $[X] | Courses, conferences |
| Reserve | $[X] | $[X] | Emergency fund |
| **Total** | **$[X]** | **$[X]** | |

## Profit Target
- Target Revenue: $[X]
- Target Expenses: $[X]
- **Target Profit**: $[X] ([X]% margin)
```

### Cash Flow Considerations

#### Revenue Timing
- Sponsorships: Usually paid before or after campaign
- Products: Immediate (minus refund period)
- Subscriptions: Monthly, predictable
- Consulting: Often net 30-60 days

#### Expense Timing
- Software: Monthly or annual
- Contractors: Per project or monthly
- Taxes: Quarterly estimated payments

#### Cash Buffer
Keep 3-6 months of expenses in reserve
```
Monthly expenses: $[X]
Buffer target: $[X] (X months)
```

## Financial Reporting

### Monthly Report Template

```markdown
# Financial Report: [Month Year]

## Summary
| Metric | This Month | Last Month | Change |
|--------|------------|------------|--------|
| Revenue | $[X] | $[X] | [+/-X%] |
| Expenses | $[X] | $[X] | [+/-X%] |
| Net Profit | $[X] | $[X] | [+/-X%] |
| Profit Margin | [X]% | [X]% | [+/-X%] |

## Revenue Breakdown
[Pie chart or table by source]

## Notable Items
- [Highlight: Best performing revenue source]
- [Concern: Any issues to address]
- [Opportunity: Potential for next month]

## vs. Budget
| Metric | Actual | Budget | Variance |
|--------|--------|--------|----------|
| Revenue | $[X] | $[X] | [+/-X%] |
| Expenses | $[X] | $[X] | [+/-X%] |

## Next Month Focus
1. [Priority 1]
2. [Priority 2]
3. [Priority 3]
```

### Quarterly Business Review

```markdown
# Q[X] [Year] Review

## Financial Performance
| Metric | Q[X] | Q[X-1] | YoY Change |
|--------|------|--------|------------|
| Revenue | $[X] | $[X] | [+/-X%] |
| Net Profit | $[X] | $[X] | [+/-X%] |
| Customers | [X] | [X] | [+/-X%] |

## Revenue Mix
[Chart showing revenue by source]

## Key Wins
1. [Achievement 1]
2. [Achievement 2]
3. [Achievement 3]

## Challenges
1. [Issue 1]
2. [Issue 2]

## Next Quarter Goals
1. [Goal 1] - Target: [Metric]
2. [Goal 2] - Target: [Metric]
3. [Goal 3] - Target: [Metric]
```

## Tax Considerations (General)

### Track for Taxes
- All income by source
- All deductible expenses
- Home office usage (if applicable)
- Equipment purchases
- Software subscriptions
- Professional development

### Common Creator Deductions
- Software and tools
- Home office
- Equipment (computer, mic, camera)
- Professional services
- Education and training
- Marketing expenses
- Travel for business

### Quarterly Estimated Taxes
If you expect to owe $1,000+ in taxes:
- Q1: April 15
- Q2: June 15
- Q3: September 15
- Q4: January 15

**Disclaimer**: Consult a tax professional for specific advice

## Pricing Analysis Tools

### Price Sensitivity Analysis

```markdown
## [Product] Pricing Analysis

| Price | Expected Volume | Revenue | Notes |
|-------|----------------|---------|-------|
| $29 | 200 | $5,800 | High volume |
| $49 | 150 | $7,350 | Sweet spot? |
| $79 | 80 | $6,320 | Premium positioning |
| $99 | 50 | $4,950 | Too expensive? |

**Recommendation**: $[X] based on [reasoning]
```

### Discount Impact Calculator

```markdown
## Discount Impact on [Product/Service]

| Discount | Price | Break-even Volume Increase |
|----------|-------|---------------------------|
| 10% | $90 (was $100) | +11% |
| 20% | $80 | +25% |
| 30% | $70 | +43% |
| 40% | $60 | +67% |
| 50% | $50 | +100% |

**Question to ask**: Will this discount really drive [X]% more volume?
```

## Resources

- [Baremetrics - SaaS Metrics](https://baremetrics.com/academy)
- [ChartMogul - Subscription Analytics](https://chartmogul.com/blog/)
- [Stripe Atlas Guides](https://stripe.com/atlas/guides)
- [Justin Welsh - Solopreneur Financials](https://www.justinwelsh.me/newsletter)
