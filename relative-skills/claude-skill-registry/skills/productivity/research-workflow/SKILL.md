---
name: research-workflow
description: Apply systematic research methodology for multi-step research, fact-finding, web search, or verification tasks. Use when performing Brave Search, Puppeteer navigation, or synthesizing information from multiple sources.
---

# Research Workflow

Follow this systematic approach for research, fact-finding, or web verification tasks.

## Core Workflow

### 1. Initial Analysis

- Break down the query into core components
- Identify key concepts and relationships
- Plan search and verification strategy
- Determine which tools will be most effective

### 2. Primary Search (Brave Search)

- Start with broad context searches
- Use targeted follow-up searches for specific aspects
- Apply search parameters strategically (count, offset)
- Document and analyze search results

### 3. Deep Verification (Puppeteer/WebFetch)

- Navigate to key websites identified in search
- Take screenshots of relevant content
- Extract specific data points
- Click through and explore relevant links

### 4. Data Processing

- Use REPL/Analysis for complex calculations
- Process CSV files or structured data
- Create visualizations when helpful

### 5. Synthesis & Presentation

- Combine findings from all tools
- Present in structured format
- Highlight key insights and relationships

## Brave Search Guidelines

**CRITICAL RATE LIMIT**: 1 request per second

- NEVER make consecutive calls without sleeping 1+ seconds
- OR run a different command between searches

**Best practices**:
- Use `count` parameter for result volume
- Apply `offset` for pagination
- Combine multiple related searches
- Document queries for reproducibility
- Include full URLs, titles, descriptions
- Note search date/time for each query

## Puppeteer Guidelines

- Take screenshots of key evidence
- Use selectors precisely for interaction
- Handle navigation errors gracefully
- Document URLs and interaction paths
- Verify you arrived at correct page; retry if not

## Source Documentation Requirements

**All findings must include**:
- Full URLs and titles
- Access dates
- Source links for quotes
- Citation metadata from search results

## Best Practices

- Use tools proactively in parallel when appropriate
- Document each step of analysis
- Complex tasks should trigger the full workflow
- Always verify critical information from multiple sources
