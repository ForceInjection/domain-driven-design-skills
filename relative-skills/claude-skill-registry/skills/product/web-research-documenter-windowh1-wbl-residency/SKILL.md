---
name: web-research-documenter
description: This skill should be used when users request research on any topic that requires web search, source analysis, and structured documentation saved to a file. It provides a systematic workflow for gathering information from multiple web sources, synthesizing findings into a comprehensive document, and saving results to a user-specified file path. This is a general-purpose research skill that works across all domains and languages.
---

# Web Research Documenter

## Overview

This skill provides a systematic workflow for researching any topic by conducting web searches, analyzing authoritative sources, synthesizing information into well-structured documents, and saving results to user-specified file paths. Unlike domain-specific research skills, this is a general-purpose skill that works across all topics and supports multiple languages.

## When to Use This Skill

Use this skill when users request:
- Research on any topic with file output
- Information gathering from web sources
- Structured documentation of findings
- Topic summaries or reports
- Multi-source analysis and synthesis

**Trigger patterns include:**
- "[Topic]을/를 검색하고 파일로 저장해줘" (Korean)
- "Research [topic] and save to file"
- "Search for [topic] and create a report"
- "Find information about [topic] and document it"
- "Investigate [topic] and save the summary"

**Key indicators:**
- Request involves web search/research
- Request specifies file output or saving results
- Request requires synthesis from multiple sources
- Request asks for structured documentation

## Workflow

Follow this systematic four-phase workflow:

### Phase 1: Initial Web Search

Conduct broad web search to identify key themes and authoritative sources.

**Steps:**
1. Formulate search query based on user's topic and language
2. Use `web_search` tool with appropriate `max_results` (typically 8-12)
3. Scan results to identify:
   - Major themes and key information
   - Authoritative sources
   - Specific data points or statistics
   - Key terminology and concepts

**Search Query Guidelines:**
- Match the user's language (if user asks in Korean, search in Korean)
- Include temporal indicators when relevant: "2024", "2025", "latest", "recent", "최신"
- Add context keywords based on topic type
- Be specific but not overly narrow
- Examples:
  - Good: "TypeScript 최신 트렌드 2024 2025"
  - Good: "climate change latest research 2024"
  - Good: "人工智能发展趋势 2024" (Chinese example)
  - Too narrow: "TypeScript 5.3.2 bug fixes"
  - Too broad: "technology"

**Available parameters:**
```python
await web_search({
    "query": "search terms here",
    "max_results": 10,  # default: 10
    "engine": "duckduckgo"  # default, can also use "brave" or "serper"
})
```

### Phase 2: Deep Source Analysis

Fetch and analyze 2-4 most relevant sources for detailed information.

**Steps:**
1. Select sources based on:
   - Recency (prefer recent content when researching trends)
   - Authority (official sources, major publications, recognized experts)
   - Comprehensiveness (detailed content over brief mentions)
   - Relevance to user's specific question
   - Language match (prefer sources in user's language when available)

2. Use `fetch` tool to retrieve full content:
   - Set appropriate `max_length` (6000-10000 for detailed articles)
   - Fetch multiple sources when possible
   - Handle fetch failures gracefully (some sites may block access)
   - Prioritize sources that provide different perspectives

3. Extract key information:
   - Main points and themes
   - Specific data, statistics, or metrics
   - Expert opinions or authoritative statements
   - Examples or case studies
   - Future predictions or trends

**Available parameters:**
```python
await fetch({
    "url": "https://example.com/article",
    "max_length": 8000,  # default: 5000
    "start_index": 0,     # default: 0
    "raw": False          # default: False (returns markdown)
})
```

**Handling fetch failures:**
- If a source fails to fetch, continue with other sources
- Log the failure but don't let it stop the workflow
- Ensure at least 2 sources are successfully fetched
- If all fetches fail, synthesize from search results only

### Phase 3: Information Synthesis

Organize and synthesize information into a structured document.

**Language Matching:**
- **CRITICAL**: Match the document language to the user's request language
- If user asks in Korean, write the entire document in Korean
- If user asks in English, write in English
- If user asks in another language, write in that language
- Maintain consistency throughout the document

**Structure Guidelines:**

Core sections to include:
1. **Header**: Title, date, topic overview
2. **Executive Summary**: 2-3 paragraph overview in user's language
3. **Main Content**: Organized sections with clear headings
   - Use numbered sections or topic-based organization
   - Include subheadings for clarity
4. **Key Points**: Important findings, data, or insights
5. **Context**: Background information, current state, significance
6. **Conclusion**: Key takeaways and synthesis
7. **References**: Source links and citations

**Formatting Standards:**
- Use clear hierarchy: Headers with `===`, subheaders with `---`, bullet points
- Include specific data: percentages, dates, numbers, names
- Provide examples when relevant
- Add visual separation: line breaks, section dividers
- Use symbols for emphasis: ✓, •, →, ★, 📌
- Keep paragraphs concise: 3-5 sentences maximum
- Use lists and bullet points for readability

**Content Quality Standards:**
- **Accuracy**: Verify claims across multiple sources
- **Completeness**: Cover all major themes identified in Phase 1
- **Balance**: Include multiple perspectives when available
- **Specificity**: Avoid vague statements; provide concrete details
- **Clarity**: Write in clear, accessible language
- **Attribution**: Cite sources for key claims and data

**Document Length:**
- Aim for comprehensive but readable documents
- Typical range: 150-250 lines for thorough research
- Adjust based on topic complexity and user needs
- Better to be thorough than superficial

### Phase 4: File Documentation

Save the synthesized document to the user's specified file path.

**Steps:**
1. Confirm file path from user request
   - Use absolute paths when provided
   - Default to `/tmp/` if no path specified and ask user for confirmation
2. Use `write_file` tool with `mode='rewrite'`
3. Include the complete structured document from Phase 3
4. Confirm successful save to user

**Available parameters:**
```python
await write_file({
    "path": "/absolute/path/to/file.txt",
    "content": "Document content here...",
    "mode": "rewrite"  # or "append"
})
```

**File Naming Conventions:**
- Use descriptive names based on topic
- Include date if relevant: `topic_2024.txt`
- Use underscores for spaces: `climate_research.txt`
- Prefer `.txt` or `.md` extensions for text documents
- Match user's specified filename if provided

## Best Practices

### Search Strategy

- **Cast wide net first**: Initial search should be broad to capture full picture
- **Multiple angles**: Consider different search terms for comprehensive coverage
- **Language awareness**: Search in the user's language when possible
- **Validate recency**: Check publication dates when researching current topics

### Source Selection

- **Quality over quantity**: Better to have 2-3 excellent sources than 5 mediocre ones
- **Diversity**: Seek different perspectives and types of sources
- **Authority**: Prioritize official sources, experts, and reputable publications
- **Accessibility**: Some sources may block fetch; have backup options

### Synthesis Quality

- **Structure matters**: Well-organized content is more valuable than comprehensive chaos
- **Context is key**: Explain significance and implications, not just facts
- **Be objective**: Present balanced view and acknowledge limitations
- **Stay focused**: Address user's question directly; avoid tangents

### Language and Localization

- **Match user's language**: If user asks in Korean, respond in Korean
- **Maintain consistency**: Don't mix languages within the document
- **Cultural context**: Consider cultural relevance when selecting sources
- **Clear translation**: When sources are in different languages, integrate smoothly

### Common Pitfalls to Avoid

- **Stopping too early**: Don't rely only on initial search results
- **Language mismatch**: Don't respond in English when user asks in another language
- **Poor structure**: Avoid walls of text; use clear organization
- **Missing attribution**: Always cite sources for key information
- **Ignoring failures**: Handle fetch failures gracefully and continue
- **Vague content**: Provide specific information and concrete details

## Quality Checklist

Before saving the file, verify:
- ✓ Document language matches user's request language
- ✓ All major themes from initial search are covered
- ✓ At least 2 authoritative sources were analyzed
- ✓ Specific data points and examples are included
- ✓ Document follows clear structural format
- ✓ Content is well-formatted with headers and organization
- ✓ Conclusion provides meaningful synthesis
- ✓ Sources are cited in references section
- ✓ File path is correct (absolute path)
- ✓ No placeholder text or incomplete sections

## Workflow Example

**User Request**: "Python 머신러닝 라이브러리 트렌드를 조사해서 ~/Documents/ml_trends.txt로 저장해줘"

**Execution**:

1. **Phase 1 - Search**:
   - Query: "Python 머신러닝 라이브러리 최신 트렌드 2024"
   - Results: 10 sources about ML libraries, frameworks, trends

2. **Phase 2 - Fetch**:
   - Fetch 2-3 Korean or English sources with detailed ML library information
   - Extract: Library names, usage statistics, new features, comparison data

3. **Phase 3 - Synthesize**:
   - Write document in Korean (matching user's language)
   - Structure: 개요 → 주요 라이브러리 트렌드 → 비교 분석 → 결론
   - Include: TensorFlow, PyTorch, scikit-learn statistics and trends
   - Format: Clear headers, bullet points, data points

4. **Phase 4 - Save**:
   - Write to: `/Users/user/Documents/ml_trends.txt`
   - Confirm: "✅ 머신러닝 라이브러리 트렌드 리포트가 저장되었습니다!"

## Cross-Domain Adaptability

This skill works across all domains and topics:

**Technology**: Programming languages, frameworks, tools, trends
**Science**: Research findings, discoveries, methodologies
**Business**: Market analysis, industry trends, company research
**Health**: Medical research, treatments, health trends
**Culture**: Arts, entertainment, social trends
**Education**: Learning resources, educational trends, courses
**Current Events**: News, developments, ongoing situations
**Any topic**: The workflow adapts to any research subject

## Multi-Language Support

This skill supports research in any language:

- **Korean**: Full support for Korean queries and Korean documents
- **English**: Full support for English queries and English documents
- **Other languages**: Adaptable to any language (Chinese, Japanese, Spanish, etc.)
- **Mixed sources**: Can synthesize from sources in multiple languages
- **Language matching**: Always match output language to user's request language

## Notes

- **Objectivity**: Present balanced, factual information
- **Timeliness**: Check publication dates for time-sensitive topics
- **User's language**: Always match the document language to user's request
- **File permissions**: Verify user has write access to specified path
- **Follow-up**: Be prepared to expand or clarify sections if user requests
- **Flexibility**: Adapt structure and depth based on topic and user needs
