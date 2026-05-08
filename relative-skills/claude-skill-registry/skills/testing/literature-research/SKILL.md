---
name: literature-research
description: This skill should be used when the user asks to "搜索文献", "查找学术资料", "搜索最新研究", "literature search", "find papers", "search academic literature", "latest research", or mentions specific academic domains like AI, machine learning, computer science research. Provides comprehensive academic literature search and analysis capabilities for WeChat content creation.
version: 1.0.0
---

# Literature Research Skill

## Purpose

This skill enables systematic academic literature search and analysis for creating high-quality WeChat content. It provides workflows for finding relevant research papers, extracting key insights, and generating content suitable for public audience consumption.

## When to Use

Activate this skill when users need to:
- Search for latest academic papers in specific fields
- Find research on particular topics or technologies
- Analyze academic literature for content creation
- Understand current research trends
- Gather evidence-based information for articles

## Core Workflow

### 1. Define Search Strategy

Start by identifying the research domain and specific topics:
- Determine the primary field (AI, machine learning, computer science, etc.)
- Identify specific keywords and research areas
- Consider time range for literature search (recent papers vs. comprehensive review)
- Note any specific researchers, institutions, or conferences of interest

### 2. Execute Academic Search

Use appropriate search strategies:
- Search arXiv for preprints and latest research
- Use Google Scholar for comprehensive academic search
- Check specific conference proceedings (NeurIPS, ICML, CVPR, etc.)
- Look for survey papers and review articles for overview
- Find recent highly-cited papers in the field

### 3. Analyze and Extract Content

For each relevant paper found:
- Read abstract and introduction for core contribution
- Extract key findings and main contributions
- Identify novel methodologies or approaches
- Note experimental results and conclusions
- Assess relevance to target audience

### 4. Content Generation

Transform academic content into WeChat-friendly format:
- Start with engaging introduction highlighting importance
- Explain complex concepts in accessible language
- Use analogies and real-world examples
- Include practical implications and applications
- Maintain accuracy while simplifying technical details

## Search Templates

### General Academic Search
```
Search for recent papers on [TOPIC] published in [TIMEFRAME]
Focus on: [SPECIFIC_ASPECTS]
Look for: [PAPER_TYPES - survey papers, breakthrough research, etc.]
```

### Field-Specific Search
```
[FIELD] research on [SPECIFIC_TOPIC]
Latest developments in [TECHNOLOGY]
Recent advances in [RESEARCH_AREA]
```

## Content Structure Guidelines

### WeChat Article Structure
1. **Catchy Title**: Include key benefit or surprising finding
2. **Engaging Introduction**: Hook reader with real-world relevance
3. **Background Context**: Briefly explain why this research matters
4. **Key Findings**: Present main results in accessible language
5. **Practical Implications**: Explain how this affects readers
6. **Future Outlook**: Discuss potential developments
7. **References**: Link to original papers for credibility

### Writing Style
- Use conversational tone with professional credibility
- Incorporate storytelling elements where appropriate
- Include metaphors to explain complex concepts
- Maintain balance between accuracy and accessibility
- Use headings and bullet points for readability

## Quality Assessment

Before finalizing content, verify:
- [ ] Research papers are from reputable sources
- [ ] Key findings are accurately represented
- [ ] Technical explanations are simplified but not misleading
- [ ] Content provides genuine value to target audience
- [ ] References are properly credited
- [ ] Claims are supported by evidence

## Additional Resources

### Reference Files
- **`references/search-sources.md`** - List of academic databases and search strategies
- **`references/content-templates.md`** - WeChat article templates for different research topics

### Example Files
- **`examples/literature-analysis-example.md`** - Complete analysis of a research paper
- **`examples/wechat-article-example.md`** - Full WeChat article based on academic research

## Common Research Areas

### AI and Machine Learning
- Large Language Models and Transformers
- Computer Vision and Image Recognition
- Natural Language Processing
- Reinforcement Learning
- AI Ethics and Safety

### Computer Science
- Algorithms and Data Structures
- Software Engineering
- Human-Computer Interaction
- Networking and Distributed Systems
- Cybersecurity

### Emerging Technologies
- Quantum Computing
- Blockchain and Web3
- Internet of Things (IoT)
- Biotechnology and Bioinformatics
- Clean Technology and Sustainability

## Integration with Content Creation

After literature analysis:
1. Use the `create-article` command to generate structured content
2. Apply appropriate category classification
3. Generate date-stamped markdown files
4. Ensure content follows WeChat platform guidelines

## Tips for Effective Research

1. **Start Broad, Then Narrow**: Begin with general search, then focus on specific aspects
2. **Prioritize Recent Papers**: Focus on research from last 2-3 years for cutting-edge content
3. **Look for Survey Papers**: Excellent for understanding field landscape
4. **Check Citation Counts**: Highly-cited papers often indicate important work
5. **Follow Citation Chains**: Use reference lists to find related important work
6. **Consider Author Credibility**: Papers from well-known researchers/institutions

## Search Result Evaluation

Evaluate search results based on:
- **Relevance**: Direct connection to intended topic
- **Recency**: Publication date and current relevance
- **Impact**: Citation count and journal/conference quality
- **Accessibility**: Availability of full text and clear explanations
- **Novelty**: Originality of contributions and insights