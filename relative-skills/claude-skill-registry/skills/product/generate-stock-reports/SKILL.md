---
name: generate-stock-reports
description: Generates comprehensive reports on recent company developments using web search. Use when analyzing stocks, researching companies, evaluating investments, or when users mention company names, stock tickers, market analysis, or financial research.
---

# Generating Stock Reports

## Purpose

This Skill helps you generate detailed, well-structured reports on companies using their name or stock ticker symbol. Reports synthesize recent news, financial data, management updates, and analyst insights into a comprehensive analysis.

## When to Use This Skill

Automatically activate when users:
- Ask about a specific company or stock ticker (e.g., "What's happening with Apple?" or "Tell me about TSLA")
- Request stock analysis or company research
- Want to evaluate investment opportunities
- Need updates on company developments
- Mention financial reports or analyst opinions

## Instructions

When generating a stock report, follow these steps:

### 1. Identify the Company

- Accept company name (e.g., "Apple", "Microsoft") or ticker symbol (e.g., "AAPL", "MSFT")
- If the identifier is ambiguous, ask for clarification
- Verify the correct company before proceeding

### 2. Research Current Information

Use web search to gather recent information about:

1. **Product or Service News**
   - New product launches or updates
   - Service expansions or changes
   - Technology developments
   - Strategic partnerships

2. **Management Team News**
   - Leadership changes (CEO, CFO, board members)
   - Key executive statements or interviews
   - Strategic direction announcements
   - Management decisions

3. **Recent Financial Reports**
   - Latest quarterly or annual earnings
   - Revenue and profit trends
   - Key financial metrics (margins, growth rates)
   - Guidance and forecasts

4. **Analyst Reports**
   - Analyst ratings and price targets
   - Upgrade/downgrade news
   - Consensus estimates
   - Market sentiment

### 3. Structure the Report

Organize findings into clear sections:

```markdown
# Company Name (TICKER) - Report Date

## Executive Summary
Brief overview of key findings (2-3 paragraphs)

## Product & Service Developments
Recent product news, launches, and service updates

## Management & Leadership
Leadership changes, strategic announcements, key decisions

## Financial Performance
Latest financial results, metrics, and trends

## Analyst Insights
Ratings, price targets, and market sentiment

## Sources
List all sources with links
```

### 4. Save the Report

- Automatically save as a markdown file
- Use filename format: `{CompanyName}_{YYYY-MM-DD}.md`
- Alternative format: HTML file if requested by user
- Place in current working directory

## Quality Guidelines

### Content Standards

- **Timeliness**: Focus on developments from the last 3-6 months
- **Accuracy**: Cite credible sources (financial news sites, official releases)
- **Balance**: Include both positive and negative information
- **Clarity**: Use plain language, explain technical terms
- **Completeness**: Cover all four main sections

### Source Requirements

- Always include a "Sources" section at the end
- List all URLs as markdown hyperlinks: `[Source Title](URL)`
- Use reputable sources: Bloomberg, Reuters, CNBC, official company sites
- Verify information is current (check publication dates)

### Markdown Formatting

- Use proper heading hierarchy (# for title, ## for sections, ### for subsections)
- Use bullet points for lists
- Use tables for financial data when appropriate
- Bold key metrics and important findings
- Include links inline where relevant

## Examples

### Example 1: By Ticker Symbol

**User request**: `/stock-report AAPL`

**Expected behavior**:
1. Recognize AAPL as Apple Inc.
2. Search for recent Apple news across all four categories
3. Generate comprehensive report
4. Save as `Apple_2025-12-13.md`

### Example 2: By Company Name

**User request**: `Tell me about Tesla`

**Expected behavior**:
1. Recognize request as company research
2. Activate this Skill automatically
3. Identify Tesla, Inc. (TSLA)
4. Generate and save report

### Example 3: Specific Focus

**User request**: `What's the latest on Microsoft's AI products?`

**Expected behavior**:
1. Activate Skill for Microsoft
2. Emphasize product & service news section
3. Focus on AI-related developments
4. Include other sections for context
5. Save comprehensive report

## Best Practices

### Do's

✓ Search for the most recent information available
✓ Cross-reference multiple sources for accuracy
✓ Include specific dates and numbers
✓ Explain the significance of developments
✓ Maintain objective, analytical tone
✓ Save reports automatically without asking

### Don'ts

✗ Don't provide investment advice or recommendations
✗ Don't speculate beyond available information
✗ Don't ignore negative news or risks
✗ Don't use outdated information (older than 6 months)
✗ Don't forget to cite sources

## Handling Edge Cases

### Unknown or Ambiguous Ticker

If the company identifier is unclear:
```
I found multiple companies matching "United": United Airlines (UAL),
United Parcel Service (UPS), or United Health (UNH). Which one would
you like me to research?
```

### Limited Information

If information is scarce for a section:
```
## Analyst Insights
Limited recent analyst coverage found for this company. The last
available ratings from [date] showed [information].
```

### Private Companies

For non-public companies:
```
Note: [Company] is privately held, so financial information may be
limited. This report focuses on publicly available news and
announcements.
```

## Technical Requirements

### Tools to Use

- **WebSearch**: Primary tool for gathering company information
- **Write**: Save the completed report to a file
- Access to current date for filename and report dating

### Search Strategy

1. Start with broad searches: "{company name} news 2025"
2. Targeted searches for each section:
   - "TICKER earnings report Q4 2024"
   - "TICKER analyst ratings 2025"
   - "Company Name CEO news"
3. Verify information recency (within 3-6 months)

## File Output Specifications

### Default Format: Markdown

```
Filename: Apple_2025-12-13.md
Location: Current working directory
Encoding: UTF-8
```

### Alternative Format: HTML (if requested)

```
Filename: Apple_2025-12-13.html
Location: Current working directory
Include: Basic CSS for readability
```

## Related Resources

For additional skill documentation:
- See EXAMPLES.md for complete sample reports
- Check market data APIs for real-time pricing
- Refer to SEC EDGAR for official company filings

---

**Version**: 1.0
**Last Updated**: December 2025
**Maintained By**: Vibe Project
