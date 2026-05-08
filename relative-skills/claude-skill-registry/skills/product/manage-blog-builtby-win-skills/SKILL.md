---
name: manage-blog
description: Use when user wants to review, edit, expand, or publish draft blog posts
---

# Manage Blog - Review and Publish Drafts

Review pending draft posts, flesh them out, and publish when ready.

## When to Use

- User says `/blog` or wants to review drafts
- User wants to publish a blog post
- User wants to expand a quick note into a full post
- End of day blog review session

## Configuration

This skill requires `BLOG_CONTENT_DIR` to be set in your `CLAUDE.md`:

```markdown
## Blog Configuration
BLOG_CONTENT_DIR=/path/to/your/blog/content/directory
```

Example: `BLOG_CONTENT_DIR=/Users/you/portfolio/src/content/blog`

**If not configured**: Ask the user where their blog markdown files are located before proceeding.

## Workflow

### Step 0: Check Configuration

First, check if `BLOG_CONTENT_DIR` is set in the project's or user's `CLAUDE.md`.

If NOT set, ask the user:
```
Where are your blog posts located?

Please provide the absolute path to your blog content directory
(e.g., /Users/you/site/content/blog)

You can also add this to your CLAUDE.md to skip this prompt:
BLOG_CONTENT_DIR=/your/path/here
```

Store their answer and use it for the rest of the session.

### Step 1: Find Draft Posts

Scan the blog directory for posts with `draft: true`:

```bash
cd {BLOG_CONTENT_DIR}
grep -l "draft: true" *.md 2>/dev/null
```

For each draft, extract metadata:
```bash
# Get title and date from frontmatter
head -10 {file}.md
```

### Step 2: Display Draft List

Show the user pending drafts:

```
Found {N} draft posts:

1. {title} ({date})
   Tags: {tags}
   File: {filename}

2. {title} ({date})
   Tags: {tags}
   File: {filename}

...

Which would you like to work on? (enter number, or 'q' to quit)
```

If no drafts found:
```
No draft posts found. Use /note from any project to create one.
```

### Step 3: Select and Show Options

When user selects a draft, read the full content and show:

```
Selected: {title}

Current content:
---
{show current post content}
---

What would you like to do?
1. Expand - Add more content and detail
2. Edit - Make specific changes
3. Publish - Set draft: false and commit
4. Delete - Remove this draft
5. Back - Return to draft list
```

### Step 4: Handle Actions

#### Expand
- Ask what aspects to expand on
- Add more context, examples, or explanations
- Keep the user's voice and style
- Update the file with expanded content

#### Edit
- Ask what specific changes to make
- Apply the requested edits
- Show diff of changes
- Update the file

#### Publish
1. Read the current file
2. Change `draft: true` to `draft: false`
3. Optionally update the date to today
4. Write the updated file
5. Commit and optionally push:

```bash
cd {BLOG_CONTENT_DIR}
git add {filename}
git commit -m "post: {title}"
git push
```

Output:
```
Published: {title}
Location: {BLOG_CONTENT_DIR}/{filename}

Committed and pushed to main.
```

#### Delete
- Confirm with user: "Are you sure you want to delete '{title}'?"
- If confirmed:

```bash
cd {BLOG_CONTENT_DIR}
rm {filename}
git add -A .
git commit -m "remove draft: {title}"
```

### Step 5: Continue or Exit

After each action, ask:
```
Would you like to work on another draft? (y/n)
```

If yes, return to Step 2.

## Blog Post Quality Checklist

Before publishing, ensure:
- [ ] Title is compelling and clear
- [ ] Description is filled in (for SEO/previews)
- [ ] Content has a clear intro and conclusion
- [ ] Code snippets are properly formatted
- [ ] Tags are relevant and useful
- [ ] No placeholder text remains

## Example Session

```
/blog

Found 2 draft posts:

1. ESM vs CommonJS Dynamic Imports (2025-12-31)
   Tags: import-magic, javascript
   File: esm-commonjs-dynamic-imports.md

2. Building with Claude Max (2025-12-30)
   Tags: claude, productivity
   File: building-with-claude-max.md

Which would you like to work on? 1

Selected: ESM vs CommonJS Dynamic Imports

[shows current content]

What would you like to do?
1. Expand
2. Edit
3. Publish
4. Delete
5. Back

> 3

Updating draft status...

Published: ESM vs CommonJS Dynamic Imports
URL: https://builtby.win/ston/blog/2025-12-31/esm-commonjs-dynamic-imports

Would you like to work on another draft? n

Done! Your post is now live.
```

## Notes

- Set `BLOG_CONTENT_DIR` in your `CLAUDE.md` for convenience
- Posts are published to the main branch immediately
- The site rebuilds automatically on push (if CI/CD is set up)
- Use tags consistently to help readers find related posts
