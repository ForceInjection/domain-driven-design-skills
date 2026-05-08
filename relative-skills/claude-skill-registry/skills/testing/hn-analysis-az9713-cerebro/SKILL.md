---
name: hn-analysis
description: Analyze Hacker News posts and discussions to extract insights from tech community discourse. Use when the user mentions Hacker News, HN, news.ycombinator, YC, or provides a HN URL.
---

# Hacker News Post Analysis

Analyze Hacker News posts and their discussions to generate structured reports covering both linked content and community insights.

## When to Use

Activate this skill when the user:
- Mentions "Hacker News", "HN", "Y Combinator news"
- Provides a news.ycombinator.com URL
- Asks about a HN discussion or comments
- Mentions "Show HN", "Ask HN", or "Launch HN"
- Wants to understand tech community sentiment on a topic

## Instructions

1. **Parse the HN URL**:
   - Accept news.ycombinator.com/item?id=XXXXX format
   - Extract item ID
2. **Fetch the HN post** using WebFetch:
   - Get post title, link, points, author
   - Get top comments (aim for 20-30 top comments)
3. **If post links to content**: Also fetch linked article
4. If fetching fails:
   - Inform user of issue
   - Suggest checking URL format
   - Stop here
5. **Read the analysis prompt** from `prompts/hn.md`
6. **Extract metadata**:
   - Title, author, points
   - Post type (Show HN, Ask HN, etc.)
   - Comment count
7. **Generate analysis** covering both content AND discussion
8. **Create output directory** `reports/hackernews/` if needed
9. **Save the report** to `reports/hackernews/YYYY-MM-DD_sanitized-title.md`
10. **Update the activity log** at `logs/YYYY-MM-DD.md`:
    - Add entry under "## HN Discussions" section
    - Format: `- [Title](../reports/hackernews/filename.md) - HH:MM`
11. **Confirm to user** what was saved

## Report Format

```markdown
# [Post Title]

**Source**: [HN URL]
**Linked Content**: [Original URL if any]
**Points**: [Score]
**Comments**: [Count]
**Date**: YYYY-MM-DD
**Type**: Hacker News Discussion

---

[Analysis content following prompts/hn.md structure]

---

## My Notes

[Empty space for user notes]
```

## Error Handling

- If URL format wrong: Suggest correct format
- If post deleted: Inform user
- If comments fail: Analyze post only
- If prompts/hn.md missing: Use prompts/default.md

## Related

- Slash command: `/hn <url>`
- Prompt file: `prompts/hn.md`
- Output: `reports/hackernews/`
