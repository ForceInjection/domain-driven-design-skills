---
name: find-related-work
description: Searches journal for past work related to current task, finding relevant context, solutions, and decisions
when_to_use: Use when tackling problems similar to past work, making architectural decisions, or when the user explicitly asks about past implementations. Helps avoid reinventing solutions.
---

# Find Related Work Skill

You have the ability to search the journal for past work related to the current task.

## When to Use This Skill

Use this skill **proactively** when:

1. **Facing similar problems**
   - Current task resembles past work
   - User asks to implement something you may have done before
   - Pattern recognition suggests related history

2. **Making technical decisions**
   - Architecture choices similar to past decisions
   - Technology selection (libraries, frameworks)
   - Design patterns or approaches

3. **Troubleshooting issues**
   - Bug seems familiar
   - Similar error messages or symptoms
   - Related to previously fixed issues

4. **Building on past work**
   - Extending existing features
   - Integrating with previous implementations
   - Following established patterns

5. **User explicitly asks**
   - "Have we done something like this before?"
   - "When did we implement X?"
   - "How did we solve Y last time?"
   - "Find anything about Z"

## How to Find Related Work

**Method 1: Keyword search**
```
journal_search(
  query="authentication",  # Technology, concept, or feature
  limit=10
)
```

**Method 2: Time-based search**
```
journal_time_query(
  time_expression="last month",
  query="caching"  # Optional: narrow down results
)
```

**Method 3: Project-specific search**
```
journal_search(
  query="database migration",
  project="my-api"  # Focus on specific project
)
```

**Method 4: Project history**
```
journal_list_recent(
  project="mobile-app",
  limit=20  # Get comprehensive project context
)
```

## Search Strategies

**Broad to narrow:**
1. Start with general terms ("auth", "cache")
2. Narrow if too many results ("OAuth2", "Redis cache")
3. Add project filter if needed

**Technology-focused:**
- Framework names: "React", "FastAPI", "PostgreSQL"
- Library names: "JWT", "Redis", "SQLAlchemy"
- Tool names: "Docker", "GitHub Actions", "pytest"

**Concept-focused:**
- Features: "authentication", "notifications", "file upload"
- Patterns: "caching", "rate limiting", "error handling"
- Operations: "deployment", "migration", "refactoring"

**Time-focused:**
- Recent: "last week", "last month"
- Historical: "january", "last year"
- Specific: "2024-03-15"

## Examples

**Example 1: Similar feature request**
```
User: "Add rate limiting to the API"
[Proactively search before starting]
→ journal_search(query="rate limiting")
→ Found previous rate limiting implementation in mobile-api
→ "I found we implemented rate limiting before in mobile-api using Redis.
   Want to use a similar approach? Here's what we did: [summary]"
```

**Example 2: Architectural decision**
```
User: "Should we use PostgreSQL or MongoDB for this?"
→ journal_search(query="PostgreSQL MongoDB database choice")
→ "We chose PostgreSQL over MongoDB for api-service last month because [reasons].
   Similar requirements here?"
```

**Example 3: Debugging with history**
```
User: "Getting timeout errors on the cache"
→ journal_search(query="cache timeout error")
→ "We fixed a similar cache timeout issue in March by [solution].
   Let me check if it's the same problem..."
```

**Example 4: Pattern reuse**
```
User: "Implement file upload for users"
→ journal_search(query="file upload")
→ "Found your file upload implementation for profiles from [date].
   You used [approach] with [storage]. Use the same pattern?"
```

**Example 5: Technology recall**
```
User: "What library did we use for JWT tokens?"
→ journal_search(query="JWT library")
→ "You used PyJWT for token handling in my-api.
   Here's how it was set up: [summary]"
```

## Presenting Related Work

**Format:**
```
**Related Past Work**

Found [N] related entries:

**Most relevant:**
[Entry title] ([date]) - [project]
[Brief summary of what was done]

**Also relevant:**
- [Entry 2]: [Quick summary]
- [Entry 3]: [Quick summary]

**Suggestions:**
[How this past work applies to current task]
```

## Best Practices

1. **Search proactively**: Don't wait for user to ask
2. **Be selective**: Show most relevant, not all results
3. **Provide context**: Explain how past work relates
4. **Suggest application**: How to use this information
5. **Time-aware**: Note if information might be outdated

## What to Look For

Search for:
- **Solutions**: How problems were solved
- **Decisions**: Why choices were made
- **Patterns**: Established approaches
- **Gotchas**: Issues encountered and avoided
- **Dependencies**: Libraries and tools used

## Integration with Other Skills

Combine with:
- **context-recovery**: When related work provides session context
- **journal-capture**: After applying past solutions to new problems

## When NOT to Search

Don't search for:
- Completely novel features with no precedent
- Trivial tasks unlikely to have been journaled
- Very recent work (use context-recovery instead)
- Information better found in documentation

## Advanced Techniques

**Combine multiple searches:**
```
1. journal_search(query="authentication")  # Broad search
2. journal_search(query="OAuth2", project="my-api")  # Narrow down
```

**Use project stats for overview:**
```
journal_stats()  # See which projects have relevant history
→ journal_list_recent(project="most-relevant-project")
```

**Time-based filtering:**
```
journal_time_query(
  time_expression="last 6 months",
  query="deployment"
)  # Recent relevant work only
```
