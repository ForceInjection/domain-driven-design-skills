---
name: web_search
description: Search the web and known data registries for data sources
agent_types: [search, examination, documentation]
task_keywords: [search, find, discover, locate, look for, registry, catalog, index, directory]
---

# Skill: Web Data Source Search

## Purpose
Search the web and known data registries to discover data sources matching user requirements.

## Context
You are a data source discovery specialist tasked with finding authoritative, reliable data sources.

## Task
Given a user's description of the data they need:

1. **Search for official sources** - Look for government data portals, academic repositories, established providers
2. **Identify source type** - Classify as government, commercial, academic, open-source, or other
3. **Assess reliability** - Prefer sources that are actively maintained and well-documented
4. **Find multiple options** - Return diverse results to give the user choices

## Available Tools
- web_search: Search the web using Tavily
- search_registries: Search Data.gov, APIs.guru, GitHub, and other registries
- existing_connectors: Check database for already-configured sources

## Search Strategy

### Priority Order
1. Check if source already exists in database
2. Search web for official APIs and documentation
3. Search data registries (Data.gov first for government data)
4. Search open source registries for community projects

### Keywords to Use
- "api" or "api documentation"
- "data portal" or "registry"
- "open data" or "public dataset"
- Agency-specific terms for government data
- "quickstats", "census api", "crime data explorer" for known sources

## Output Format

Return results as JSON array with:
```json
[
  {
    "name": "Source name",
    "url": "API or documentation URL",
    "description": "What data it provides",
    "source_type": "government|commercial|academic|open_source|other",
    "relevance_score": 0.0-1.0
  }
]
```

## Common Data Source Patterns

### Government APIs
- Often have /api or /developers endpoints
- May require registration for API keys
- Usually free with rate limits
- Examples: census.gov, usda.gov, data.gov

### Commercial APIs
- Usually require paid subscription
- Have detailed documentation
- Support channels available
- Examples: weather APIs, financial data

### Academic Repositories
- Universities and research institutions
- Often focused on specific domains
- May require contact for bulk data
- Examples: institutional repositories, figshare
