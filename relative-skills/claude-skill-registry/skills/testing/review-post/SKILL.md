---
name: review-post
description: Reviews a blog post for writing quality, spelling errors, and clarity. Use when asked to review, check, or give feedback on a blog post. Defaults to the most recent post in Public/_posts if no specific post is specified.
allowed-tools: Read, Glob, Grep
---

# Blog Post Review Skill

Review blog posts for writing quality without making any changes. This skill is read-only and provides feedback only.

## Finding the Post to Review

1. If a specific post path is provided, use that
2. Otherwise, find the most recent post by looking at `Public/_posts/` and selecting the textbundle with the latest date prefix (YYYY-MM-DD format)
3. Read the `text.md` file inside the textbundle

## Understanding the Author's Voice

Before providing feedback, read a sample of recent posts from `Public/_posts/` to understand the author's established voice and style:
- Read 5-10 recent posts to get a sense of tone, vocabulary, and writing patterns
- Note the typical post length, paragraph structure, and use of headers
- Observe how technical topics are explained and what level of assumed knowledge
- Look for recurring stylistic choices (e.g., humor, directness, storytelling approach)

Use this understanding to provide feedback that helps polish the post while preserving the author's authentic voice.

## Review Process

### 1. Spelling Check
Carefully scan the entire post for spelling errors. List each misspelled word with:
- The incorrect word
- The suggested correction
- The sentence context where it appears

### 2. Grammar and Style
Note any issues with:
- Awkward phrasing
- Passive voice overuse
- Run-on sentences
- Inconsistent tense
- Deviations from the author's typical voice (flag only if it seems unintentional)

### 3. Clarity Questions
Ask questions a reader might have while reading the post:
- Are there unexplained acronyms or jargon?
- Are there claims that need more context or evidence?
- Are there logical gaps in the narrative?
- Would a code example or screenshot help explain something?

### 4. Structure Feedback
Comment on:
- Does the opening hook the reader?
- Is there a clear through-line?
- Does the conclusion provide a satisfying ending or call to action?

## Output Format

Provide feedback in this structure:

```
## Post Review: [Post Title]

### Spelling Errors
- [list each error with correction and context, or "None found"]

### Grammar & Style Notes
- [bulleted list of issues]

### Questions for Clarity
- [numbered list of questions a reader might ask]

### Structure Feedback
- [comments on overall organization]

### Summary
[2-3 sentence overall assessment]
```

## Important

- **DO NOT** edit or overwrite any files
- **DO NOT** make changes to the post
- Only read and provide feedback
- Be specific with line references or quotes when pointing out issues
