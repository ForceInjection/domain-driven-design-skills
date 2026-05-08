---
name: recall-project-memory
description: Automatically search and retrieve relevant project memory from Mem0 when working on tasks that might benefit from past decisions, patterns, or learnings. Use this skill when starting new features, fixing bugs, or making architectural decisions to leverage historical context.
allowed-tools:
  - MCP(mem0:*)
---

# Recall Project Memory Skill

## Purpose

This skill enables you to automatically search project memory for relevant context before making decisions or implementing features. It helps maintain consistency with past decisions and avoid repeating mistakes.

## When to Invoke

Automatically consider using this skill when:

1. **Starting new features**: Check if similar features exist or related patterns were established
2. **Making architectural decisions**: See if similar decisions were made and what rationale was used
3. **Debugging**: Look for past solutions to similar problems
4. **Refactoring**: Understand why current structure exists before changing
5. **User asks about history**: "How did we handle X?", "Why did we choose Y?"

## How to Use

### Step 1: Identify Context

From the current task or conversation, extract:
- Technical domain (auth, database, API, frontend, etc.)
- Specific components or files being discussed
- Type of work (decision, implementation, debugging, refactoring)
- Key concepts or patterns mentioned

### Step 2: Formulate Search Query

Create semantic search query combining:
- Domain keywords
- Problem/feature description
- Technology stack terms

Example queries:
- "authentication JWT token refresh"
- "database migration strategy postgres"
- "error handling async functions"
- "API rate limiting implementation"

### Step 3: Query Mem0

Use MCP mem0 tools to:
```
search_memories(
  query: "<semantic query>",
  user_id: "${CLAUDE_PROJECT_DIR_NAME}",
  limit: 5-10
)
```

Filter by:
- Project scope (always use project name as user_id)
- Relevance threshold (>0.7)
- Memory types (decisions, patterns, constraints)

### Step 4: Apply Retrieved Context

**If relevant memories found:**
- Briefly mention: "Found relevant past decision about X"
- Apply patterns/constraints to current task
- Maintain consistency with established approaches
- If conflicting with past, explain why deviation is needed

**If no relevant memories:**
- Proceed normally
- Consider capturing new decision if significant

**If memories are outdated:**
- Note the change in context
- Suggest updating the memory

## Examples

### Example 1: Feature Implementation

**User:** "Add user authentication to the API"

**You should:**
1. Search: "authentication API security user"
2. Find memory: "Decision [2024-10]: Use JWT with 15min expiry, refresh tokens"
3. Apply: "I'll implement authentication using JWT tokens as previously decided..."
4. Reference: "This aligns with our established auth pattern [mem0:xyz]"

### Example 2: Debugging

**User:** "The async function is throwing errors randomly"

**You should:**
1. Search: "error handling async functions"
2. Find memory: "Pattern: Always use Result<T, E> for async operations"
3. Check: Review current code against pattern
4. Fix: "I see the issue - we should wrap this in Result<> per our pattern..."

### Example 3: No Relevant Memory

**User:** "Add caching layer"

**You should:**
1. Search: "caching cache layer"
2. No results
3. Proceed: "I don't see any past caching decisions. Let's design this..."
4. Later: Suggest capturing the decision

## Output Format

When memory is relevant:

```markdown
🧠 **Project Memory**: Found relevant context from <date>
- <brief summary of memory>
- <how it applies to current task>
```

Keep it concise - don't overwhelm the user. The goal is to:
- Surface relevant context seamlessly
- Maintain consistency
- Avoid redundant explanations

## Best Practices

1. **Don't over-retrieve**: Only search when genuinely relevant
2. **Be specific**: Use precise search terms related to current task
3. **Stay concise**: Mention memory briefly, focus on applying it
4. **Update proactively**: If memory is outdated, suggest updating it
5. **Trust the search**: Mem0 uses semantic similarity, so approximate terms work

## Error Handling

- **Mem0 unavailable**: Proceed without memory, log gracefully
- **Search timeout**: Fall back to local knowledge, continue task
- **No API key**: Skip memory retrieval, work normally
- **Ambiguous results**: Ask user for clarification on which approach to follow

## Progressive Loading

If you need more details about a memory:
1. Initial search returns summary
2. If needed, retrieve full memory by ID
3. If memory references files, read those files for complete context
