---
name: opensource-code-explorer
description: Explore open-source repositories, analyze implementation details of libraries/frameworks, and research official documentation. Use when you need to understand how features are implemented in popular open-source projects.
argument-hint: [question about open-source code]
---

# Open-Source Code Explorer Skill

This skill helps you explore open-source repositories, understand implementation details of specific libraries and frameworks, and research official documentation.

## When to Use This Skill

Use this skill when you need to:

- Understand how authentication, state management, or other features are implemented in popular frameworks
- Find implementation patterns in specific libraries (e.g., React, Django, Vue)
- Explore repository structure and architecture of open-source projects
- Search for official documentation and API references
- Compare implementation approaches across similar projects
- Analyze dependencies, build processes, and project organization

## How to Use

**Basic usage:**

```bash
/opensource-code-explorer How does React handle state management internally?
```

**With specific library:**

```bash
/opensource-code-explorer Show me authentication implementation in Django
```

**For architectural patterns:**

```bash
/opensource-code-explorer How is the plugin system implemented in Vite?
```

## Recommended MCP Servers

This skill works best when you have these MCP servers configured. Claude will automatically use them when available:

### DeepWiki (Documentation Explorer)

Provides access to documentation for popular open-source projects.

**Setup:**

```bash
# DeepWiki is typically configured via HTTP
# Check your mcp.json for configuration
```

**Tools available:**

- `read_wiki_structure` - Browse documentation structure
- `read_wiki_contents` - Read specific documentation pages
- `ask_question` - Query documentation with natural language

### Git Ingest (Repository Analysis)

Analyzes Git repositories and provides structured access to code.

**Setup:**

```bash
# Install via uvx
claude mcp add git-ingest --command uvx --args "--from" "git+https://github.com/adhikasp/mcp-git-ingest" "mcp-git-ingest"
```

**Tools available:**

- `git_directory_structure` - Get repository structure overview
- `git_read_important_files` - Read key files from repository

### Repomix (Code Analysis)

Provides comprehensive codebase analysis and summaries.

**Setup:**

```bash
# Install via npx
claude mcp add repomix --command npx --args "-y" "repomix" "--mcp"
```

**Note:** These MCP servers are configured separately from the skill. The skill will automatically discover and use them when appropriate for your task.

## Instructions

When exploring open-source code, follow these steps:

### 1. Understand the Request

First, identify what the user wants to explore:

- Specific feature implementation?
- Architectural pattern?
- Documentation lookup?
- Code organization?

### 2. Choose the Right Approach

**For documentation:**

- Use DeepWiki MCP tools to browse and search official docs
- Use WebSearch for finding documentation pages
- Use WebFetch to read specific documentation

**For repository exploration:**

- Use git-ingest to get repository structure
- Use git-ingest to read important files (README, package.json, etc.)
- Use Grep to search for specific patterns
- Use Glob to find relevant files

**For code analysis:**

- Use repomix for comprehensive codebase analysis
- Use Read to examine specific implementation files
- Use Grep to find function definitions, classes, or patterns

### 3. Provide Comprehensive Context

When presenting findings, always include:

- **File paths and locations:** Specific files within the repository
- **Code snippets:** Relevant implementation details
- **Architectural context:** Why certain choices were made
- **Documentation links:** Official docs supporting your explanation
- **Project information:** Maturity, maintenance status, community size

### 4. Explain the "Why"

Don't just show code - explain:

- The reasoning behind architectural decisions
- Trade-offs of the approach used
- Alternative patterns that could be used
- Best practices demonstrated in the code

## Examples

### Example 1: Understanding Framework Implementation

**User:** "How does Vue handle reactivity?"

**Approach:**

1. Use git-ingest to explore Vue.js repository structure
2. Search for reactivity-related files using Grep
3. Use DeepWiki to find official reactivity documentation
4. Read key implementation files
5. Explain the Proxy-based reactivity system with code examples

### Example 2: Finding Design Patterns

**User:** "Show me how Next.js implements middleware"

**Approach:**

1. Use WebSearch to find Next.js repository
2. Use git-ingest to get repository structure
3. Use Grep to find middleware-related code
4. Read middleware implementation files
5. Explain the pattern with file paths and code snippets

### Example 3: Comparing Implementations

**User:** "How do different frameworks handle routing?"

**Approach:**

1. Identify popular frameworks to compare (React Router, Vue Router, etc.)
2. Use git-ingest for each repository
3. Find routing implementation files
4. Compare approaches and explain trade-offs
5. Reference official documentation for each

## Best Practices

1. **Start broad, then narrow:** Begin with repository structure before diving into specific files
2. **Use TodoWrite:** Track multi-step exploration tasks
3. **Verify information:** Cross-reference code with official documentation
4. **Provide links:** Always include GitHub/GitLab URLs and doc links
5. **Be specific:** Include file paths, line numbers when relevant
6. **Explain clearly:** Technical details should be accessible
7. **Note project status:** Mention if a project is actively maintained

## Limitations

- Some private repositories may not be accessible
- Very large codebases may require focused queries
- MCP tools depend on server availability
- Documentation may be outdated for fast-moving projects

## After Exploration

Always summarize your findings with:

- Direct answer to the user's question
- Key file paths and code locations
- Links to relevant documentation
- Additional resources for deeper learning
