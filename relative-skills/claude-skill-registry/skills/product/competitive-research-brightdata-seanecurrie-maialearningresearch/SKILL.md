---
name: competitive-research-brightdata
description: Enterprise-grade company research, competitive analysis, and market intelligence using Bright Data's professional web scraping and search capabilities. Use this skill when asked to research companies, conduct competitive analysis, create market reports, analyze industries, compare products/services, or gather business intelligence. Triggers include requests like "research [company]", "competitive analysis of X vs Y", "create a market report", "analyze the [industry] landscape", or "compare [products/companies]".
---

# Competitive Research with Bright Data

This skill provides enterprise consulting-grade methodologies for conducting comprehensive company research, competitive analysis, and market intelligence using Bright Data's professional search and web scraping tools.

## Skill Capabilities

This skill supports:

- **Company Research** - Deep dives into company background, business model, financials, strategy, and market position
- **Competitive Analysis** - Multi-company comparisons across products, pricing, positioning, and capabilities
- **Market Intelligence** - Industry landscape analysis, market sizing, trends, and dynamics
- **Product Comparison** - Feature-by-feature analysis of competing products or services
- **Strategic Analysis** - SWOT, Porter's Five Forces, positioning, and strategic recommendations
- **Custom Reports** - Tailored deliverables matching specific client needs and formats

## Available Tools

### Search Tools

**search_engine** - Search Google, Bing, or Yandex for company information
- Use Google for general company research and recent news
- Use Bing for cross-validation and Microsoft ecosystem content
- Use Yandex for companies with Eastern European operations
- Supports pagination with cursor for deep research

**search_engine_batch** - Run up to 10 searches simultaneously
- Use for multi-company research to gather parallel information
- Use for comprehensive single-company research across topics
- More efficient than sequential searches
- Returns JSON for Google, Markdown for Bing/Yandex

### Scraping Tools

**scrape_as_markdown** - Extract complete content from a single webpage
- Returns clean Markdown format
- Use for company websites, press releases, reports, articles
- Handles bot detection and CAPTCHAs automatically

**scrape_batch** - Scrape up to 10 URLs simultaneously
- Use for systematic company website extraction
- Use for parallel competitor website analysis
- More efficient than sequential scraping

## Workflow

### 1. Clarify the Research Objective

**Always start by understanding the specific request.** Ask clarifying questions before diving into research:

**Questions to Ask:**
- What is the primary purpose of this research? (Investment decision, competitive positioning, market entry, product development, etc.)
- Which companies/products should be analyzed?
- What specific aspects are most important? (Pricing, features, market share, strategy, financials, etc.)
- Who is the audience for this report? (Executive team, sales, product, investors, etc.)
- What format should the deliverable take? (Full report, executive summary, comparison matrix, presentation deck, etc.)
- Are there any specific questions that must be answered?
- What is the scope? (Comprehensive deep-dive vs. quick overview)
- Any time constraints or priorities?

**Adapt the approach based on responses** - The research methodology and report format should match the stated objective.

### 2. Plan the Research Approach

Based on the clarified objective, determine:

**Information Needed:**
- Company background and overview
- Financial data (revenue, funding, growth)
- Product/service details
- Pricing and business model
- Market position and share
- Recent news and developments
- Customer sentiment
- Strategic direction

**Search Strategy:**
- Identify key search queries for each information area
- Determine if batch searching would be efficient
- Select appropriate search engine(s)

**Scraping Strategy:**
- Identify target URLs (company sites, reports, articles)
- Determine if batch scraping would be efficient
- Prioritize official company sources

**Framework Selection:**
- Choose appropriate analytical frameworks (see `references/consulting-frameworks.md`)
- Determine report structure (see `references/report-templates.md`)

### 3. Execute Research Systematically

**Phase A: Initial Search and Discovery**

Start with broad searches to identify sources and get overview:

```
Company overview and background
Recent news and announcements
Product/service offerings
Competitive landscape
```

**Use batch searches when researching multiple topics simultaneously** - More efficient than sequential searches.

**Phase B: Deep Dive Information Gathering**

Based on initial findings, conduct targeted searches and scraping:

- Search for specific data points identified as important
- Scrape key company website pages (About, Products, Newsroom, Investors)
- Scrape relevant articles, reports, and announcements
- Cross-reference facts across multiple sources

**Use batch scraping for related URLs** - Scrape competitor websites or multiple company pages together.

**Phase C: Competitive/Comparative Research** (if applicable)

For competitive analysis:

- Research all competitors using parallel search batches
- Scrape all competitor websites systematically
- Gather same data points for each competitor
- Create comparison tables as research progresses

See `references/research-methodology.md` for detailed search query examples and best practices.

### 4. Analyze and Synthesize

**Apply Analytical Frameworks:**

Depending on the research objective, apply relevant frameworks from `references/consulting-frameworks.md`:

- **Strategic Analysis** - Porter's Five Forces, SWOT, Value Chain
- **Competitive Positioning** - Strategic groups, positioning matrix
- **Market Analysis** - TAM/SAM/SOM, customer segmentation
- **Financial Analysis** - Unit economics, growth metrics
- **Product Analysis** - Feature comparison, technology assessment

**Generate Insights:**
- Go beyond raw data to interpretation
- Identify patterns and implications
- Draw evidence-based conclusions
- Make strategic recommendations when requested

**Quality Assurance:**
- Verify key facts across multiple sources
- Flag conflicting information
- Note data gaps clearly
- Assess recency of information
- Prioritize primary sources

### 5. Create the Report

**Select Appropriate Report Structure:**

Choose from templates in `references/report-templates.md` based on the request:

- **Company Profile Report** - For single-company deep dives
- **Competitive Analysis Report** - For multi-company comparisons
- **Market Entry Analysis** - For new market assessment
- **Product Comparison Report** - For product/service evaluation
- **Industry Analysis Report** - For sector-level intelligence
- **Quick Comparison Matrix** - For rapid comparative analysis
- **Presentation Deck** - For client-facing presentations

**Report Quality Standards:**

- **Executive Summary** - Lead with key findings and recommendations
- **Clear Structure** - Use headings and sections from templates
- **Data Presentation** - Tables for comparisons, bullets for lists, prose for analysis
- **Source Attribution** - Cite sources for key claims
- **Professional Tone** - Enterprise consulting quality
- **Actionable Insights** - Provide clear implications and recommendations
- **Completeness** - Address all clarifying questions answered at the start

**Format Flexibility:**
- Adapt templates to specific needs
- Combine elements from multiple templates if needed
- Match the format to the stated audience and purpose

## Best Practices

### Research Excellence

1. **Triangulate Information** - Verify key facts from 2-3 independent sources
2. **Prioritize Primary Sources** - Company websites, SEC filings, official reports
3. **Check Recency** - Note publication dates, prefer recent data
4. **Flag Gaps** - Clearly state when information is unavailable
5. **Maintain Objectivity** - Seek disconfirming evidence, not just supporting
6. **Provide Context** - Explain what numbers mean in industry context

### Efficiency

1. **Batch Operations** - Use batch search and scrape tools when researching multiple items
2. **Start Broad** - Get overview first, then drill down into specifics
3. **Organize As You Go** - Build comparison tables during research, not after
4. **Time-Box Research** - Know when enough data is enough
5. **Template-Based** - Start with report structure, fill in findings

### Professional Quality

1. **Clear Methodology** - Explain how research was conducted
2. **Evidence-Based** - Support claims with data and sources
3. **Balanced Analysis** - Present strengths and weaknesses fairly
4. **Strategic Framing** - Connect findings to business implications
5. **Executive-Ready** - Make reports actionable for decision-makers

## Common Use Cases

### Single Company Deep Dive
1. Clarify: What aspects to focus on, audience, format
2. Research: Batch search across company topics, scrape company website
3. Analyze: Apply SWOT or relevant framework
4. Report: Use Company Profile Report template

### Head-to-Head Competitive Analysis
1. Clarify: Which companies, key comparison dimensions, decision being made
2. Research: Parallel batch searches for all companies, scrape all company sites
3. Analyze: Create comparison matrices, positioning map
4. Report: Use Competitive Analysis Report template

### Market Landscape Analysis
1. Clarify: Market definition, level of detail needed, strategic questions
2. Research: Industry trends, major players, market dynamics
3. Analyze: Porter's Five Forces, strategic group mapping
4. Report: Use Industry Analysis Report or Market Entry Analysis template

### Product/Service Comparison
1. Clarify: Products being compared, evaluation criteria, use cases
2. Research: Product pages, documentation, reviews for all products
3. Analyze: Feature matrices, use case fit analysis
4. Report: Use Product Comparison Report template

## References

- **consulting-frameworks.md** - Strategic analysis frameworks (Porter's Five Forces, SWOT, Business Model Canvas, competitive positioning, market sizing, financial analysis)
- **report-templates.md** - Proven report structures for different deliverable types (company profiles, competitive analysis, market entry, product comparison, quick matrices)
- **research-methodology.md** - Detailed search strategies, query examples, scraping best practices, source prioritization, and quality assurance processes

Load these references as needed based on the specific research objective and analytical requirements.
