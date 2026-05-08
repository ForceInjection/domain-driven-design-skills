---
name: library-research
description: Research library documentation and API references using Context7 integration. Use when users ask about libraries, frameworks, packages, APIs, or need documentation for third-party code.
license: MIT
metadata:
  author: liaison-toolkit
  version: "1.0"
  keywords: "library, documentation, api, context7, research"
---

# Library Research

Research and retrieve documentation for libraries, frameworks, and packages using Context7 integration.

## When to use this skill

Use this skill when:
- User asks about a library or framework
- You need to research an API or package documentation
- User mentions "How do I use..." for a third-party library
- You need to find official documentation or examples

## How It Works

This skill integrates with Context7 to efficiently retrieve library documentation:

1. **Library Identification**: Parse user query to identify library/package name
2. **Resolution**: Use Context7 to resolve library name to standard ID
3. **Retrieval**: Fetch comprehensive documentation for the library
4. **Analysis**: Extract relevant sections for user's specific question
5. **Delivery**: Present findings in clear, actionable format

## Step-by-Step Process

### 1. Identify Library/Package

Parse the user's question to identify the library:

```
User: "How do I create a table with React?"
Library: React
Query: table component
```

### 2. Resolve Library ID

Use `context7_resolve_library_id` tool to get the official ID:

```
context7_resolve_library_id("react")
→ Returns: /facebook/react, /facebook/react/latest
```

### 3. Get Documentation

Use `context7_get_library_docs` to retrieve relevant documentation:

```
context7_get_library_docs("/facebook/react/latest", mode="code")
→ Returns: API reference, code examples, component guides
```

### 4. Extract Relevant Information

From the documentation, find:
- Relevant classes/functions
- Usage examples
- Common patterns
- Edge cases
- Error handling

### 5. Present to User

Format findings as:
- Brief explanation
- Code example (if applicable)
- Link to official docs
- Related resources

## Common Library Research Patterns

### Pattern: "How to..." Questions

```
User: "How do I validate JSON with TypeScript?"
Skill Response:
1. Identify: Zod, TypeScript, or JSON Schema
2. Get docs for selected library
3. Show validation example
4. Explain types and error handling
```

### Pattern: Version-Specific Questions

```
User: "Does React 18 support X?"
Process:
1. Resolve: /facebook/react/v18
2. Get mode-specific docs
3. Check API changes
4. Provide version notes
```

### Pattern: Comparison Questions

```
User: "What's the difference between A and B libraries?"
Process:
1. Research both libraries
2. Compare key features
3. Show usage differences
4. Recommend use cases
```

## Tools & Integration

### Context7 Tools

**context7_resolve_library_id**: Resolve library name to standard ID
- Input: Library name string
- Output: Standard library ID and alternatives
- Use when: User mentions library but you need official ID

**context7_get_library_docs**: Fetch library documentation
- Input: Library ID, mode (code/info)
- Output: Documentation content, examples, references
- Use when: You have library ID and need docs

**webfetch**: Retrieve external documentation
- Input: Documentation URL
- Output: Page content
- Use when: Need latest docs or examples outside Context7

### Safety & Best Practices

- **Read-Only**: Never modify user code without explicit permission
- **Rate Limiting**: Respect API limits on Context7 calls
- **Verification**: Always verify documentation is current
- **Attribution**: Link to official documentation sources
- **Error Handling**: Clearly explain if library not found

## Examples

### Example 1: React Table Implementation

```
User: "How do I create a sortable table in React?"

Process:
1. Resolve: /facebook/react
2. Get: Component examples, hooks, state management
3. Present: Table component pattern using useState
4. Show: Full working example with sorting logic
5. Link: Official React docs for tables and sorting
```

### Example 2: TypeScript Generics

```
User: "How do TypeScript generics work?"

Process:
1. Resolve: /microsoft/typescript
2. Get: Generic syntax, constraints, usage
3. Present: Generic function example
4. Explain: Type parameters and inference
5. Show: Common patterns and pitfalls
```

### Example 3: Python Package Query

```
User: "What does the pandas groupby() method do?"

Process:
1. Resolve: /pandas-dev/pandas
2. Get: groupby documentation and examples
3. Present: Method signature and parameters
4. Show: Practical groupby examples
5. Link: Official pandas groupby guide
```

## Troubleshooting

### Library Not Found

If Context7 can't find a library:
1. Try alternative names (npm vs PyPI names differ)
2. Search for official repository
3. Try webfetch with official docs URL
4. Inform user if library is very new/niche

### Documentation Gaps

If official docs are incomplete:
1. Check GitHub repository for examples
2. Search for Stack Overflow answers
3. Look for blog posts or tutorials
4. Note limitations to user

### Rate Limits

If hitting Context7 rate limits:
1. Cache previous queries
2. Batch multiple questions
3. Use less frequent calls
4. Fall back to webfetch

## Best Practices

1. **Always Link**: Provide links to official documentation
2. **Show Examples**: Code examples are crucial for libraries
3. **Verify Currency**: Check documentation is up-to-date
4. **Note Versions**: Specify which library version you're documenting
5. **Warn Changes**: Alert users to breaking changes between versions
6. **Test Examples**: Where possible, verify code examples work

## Related Resources

- **Context7 Documentation**: https://context7.io
- **Library Standards**: https://opensource.org
- **API Documentation Tools**: https://swagger.io
- **Code Example Best Practices**: https://www.oreilly.com

## Keywords

library, documentation, API, packages, frameworks, context7, research, code-example, integration
