---
name: documentation-lookup
description: Look up library and framework documentation. Use when the user asks about API docs, library usage, framework features, or mentions specific libraries/packages by name.
---

# Documentation Lookup

**When to activate:**

- User says "check the docs"
- User needs API documentation or code examples
- User mentions a library/framework name
- Source code of a library is not available locally

**Two-step process:**

## Step 1: Find the library ID

Search for the library to get its context7 ID:

```bash
curl -s "https://context7.com/api/v2/search?query={library_name}" | jq '.results[:3]'
```

**Example - searching for "react":**

```bash
curl -s "https://context7.com/api/v2/search?query=react" | jq '.results[:3] | .[] | {id, title}'
```

This returns matching libraries. Use the `id` field (e.g., `/facebook/react` or `/websites/react_dev`).

## Step 2: Fetch documentation

Use the library ID from step 1:

```bash
curl -s "https://context7.com/api/v2/docs/code{library_id}?topic={topic}&page=1"
```

**Example - fetching React hooks docs:**

```bash
curl -s "https://context7.com/api/v2/docs/code/facebook/react?topic=hooks&page=1"
```

**Parameters:**

- `topic` - Focus area (e.g., `hooks`, `routing`, `authentication`)
- `page` - Pagination (1-10), use if first page doesn't have enough info

**Response:** Returns markdown-formatted documentation snippets with code examples.

**Fallback:** If context7 doesn't have the library or returns errors, use web search.
