---
name: search
description: Unified memory search across synapse. Use to find past decisions, wisdom, patterns, and context.
execution: task
---

# Search

Spawn a Task agent to search the soul. This saves context.

## Execute

The user's query is in ARGUMENTS below.

```
Task(
  subagent_type="general-purpose",
  description="Soul memory search",
  prompt="""
Search the soul's memory for: {ARGUMENTS}

## 1. Execute Search

Call:
- mcp__soul__recall(query="{ARGUMENTS}", limit=10)

## 2. Parse Results

The tool returns matches with:
- Similarity score (percentage)
- Type: wisdom, belief, failure, episode, term
- Title and content

## 3. Format Response

Present findings clearly:

**Found N results for "{ARGUMENTS}"**

For each relevant result:
[Score%] [type] **Title**
> Content snippet (first 100 chars)

## 4. Synthesize

After listing results, briefly note:
- Common themes across matches
- Most relevant finding for the query
- Any patterns or connections

Keep response concise (10-15 lines max).
"""
)
```

After the agent returns, present the search results.
