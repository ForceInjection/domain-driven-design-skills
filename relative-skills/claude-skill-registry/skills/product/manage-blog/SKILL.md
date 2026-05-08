---
name: manage-blog
description: Use when user wants to review, edit, expand, or publish draft blog posts
---

# Manage Blog - Dashboard & Post Management

View all blog posts, manage drafts, and quickly add content to existing posts from any repo.

## When to Use

- User says `/blog` → Show dashboard of all posts
- User says `/blog <query>` → Find and work on a specific post
- User wants to add learnings to an existing post
- User wants to publish, edit, or expand a draft
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

### Step 1: Scan All Posts

Scan the blog directory for ALL markdown files (not just drafts):

```bash
cd {BLOG_CONTENT_DIR}
ls *.md 2>/dev/null
```

For each file, extract metadata from frontmatter:
- `title` - Post title
- `date` - Publication/creation date
- `draft` - Boolean (true = draft, false/missing = published)
- `tags` - Array of tags
- `description` - Brief summary

### Step 2: Check for Arguments

Check if the user provided a search query with the command.

- **No arguments** (`/blog`) → Go to Step 3 (Dashboard)
- **With arguments** (`/blog tauri`) → Go to Step 4 (Fuzzy Search)

### Step 3: Display Dashboard

Show all posts grouped by status:

```
Blog Dashboard
==============

DRAFTS ({N})
  1. {title} ({date}) [{tags}]
  2. {title} ({date}) [{tags}]

PUBLISHED ({M})
  3. {title} ({date})
  4. {title} ({date})

Enter number to work on post, or 'q' to quit:
```

Sort each group by date descending (newest first).

If no posts found:
```
No blog posts found in {BLOG_CONTENT_DIR}.
Use /note from any project to create your first draft.
```

After user selects a post, go to Step 5 (Show Actions).

### Step 4: Fuzzy Search

When the user provides a search query (e.g., `/blog tauri`):

**Search these fields** (case-insensitive):
1. Title (highest priority)
2. Filename (without .md extension)
3. Tags

**Matching logic**:
- Check if query appears as substring in any field
- Match partial words (e.g., "tauri" matches "Building Floating macOS UI with Tauri")
- Score matches: title match > filename match > tag match

**Results**:

If **single match**:
```
Found: {title} ({draft status})

[Go directly to Step 5 - Show Actions]
```

If **multiple matches**:
```
Found {N} posts matching "{query}":

1. {title} ({draft/published})
2. {title} ({draft/published})
...

Which one? (enter number)
```

If **no matches**:
```
No posts found matching "{query}".

Try a different search term, or use /blog to see all posts.
```

### Step 5: Show Actions

After selecting a post, read its full content and show options.

**For DRAFT posts**:
```
Selected: {title}
Status: Draft
Date: {date}
Tags: {tags}

What would you like to do?
1. Add content - Append new learnings to this post
2. Expand - Flesh out existing content with more detail
3. Edit - Make specific changes
4. Publish - Set draft: false and commit
5. View - Show full content
6. Delete - Remove this draft
7. Back - Return to dashboard
```

**For PUBLISHED posts**:
```
Selected: {title}
Status: Published
Date: {date}
Tags: {tags}

What would you like to do?
1. Add content - Append new learnings to this post
2. Edit - Make specific changes
3. Unpublish - Set draft: true (hide from site)
4. View - Show full content
5. Back - Return to dashboard
```

### Step 6: Handle Actions

#### Add Content (NEW)
This is the key action for quickly appending learnings from any repo.

1. Ask what to add:
```
What would you like to add to "{title}"?

(Paste or describe new content, code snippets, learnings, etc.)
```

2. Ask where to insert (optional):
```
Where should this content go?
1. End of post (default)
2. After a specific section (I'll show you the headings)
3. Let me decide based on content
```

3. Read current post content
4. Insert the new content at the appropriate location
5. Show preview of the updated section:
```
Added to "{title}":

---
[new content preview]
---

Full post updated. Commit changes? (y/n)
```

6. If yes, commit:
```bash
cd {BLOG_CONTENT_DIR}
git add {filename}
git commit -m "update: {title}"
```

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

#### Unpublish (for published posts)
1. Read the current file
2. Add or change to `draft: true`
3. Write the updated file
4. Commit:

```bash
cd {BLOG_CONTENT_DIR}
git add {filename}
git commit -m "unpublish: {title}"
```

#### View
Show the full post content in a readable format.

#### Delete
- Confirm with user: "Are you sure you want to delete '{title}'?"
- If confirmed:

```bash
cd {BLOG_CONTENT_DIR}
rm {filename}
git add -A .
git commit -m "remove: {title}"
```

### Step 7: Continue or Exit

After each action, ask:
```
Would you like to work on another post? (y/n)
```

If yes, return to Step 3 (Dashboard).

## Example Sessions

### Dashboard View
```
/blog

Blog Dashboard
==============

DRAFTS (1)
  1. Building Floating macOS UI with Tauri (2025-01-03) [tauri, macos]

PUBLISHED (2)
  2. Hello World (2024-12-15)
  3. The Million Dollar Bet (2024-12-10)

Enter number to work on post, or 'q' to quit: 1

Selected: Building Floating macOS UI with Tauri
Status: Draft

What would you like to do?
1. Add content
2. Expand
3. Edit
4. Publish
5. View
6. Delete
7. Back

> 4

Updating draft status...

Published: Building Floating macOS UI with Tauri
Committed and pushed to main.
```

### Quick Add from Any Repo
```
# While working in a different project
/blog tauri

Found: Building Floating macOS UI with Tauri (draft)

What would you like to do?
1. Add content
2. Expand
3. Edit
4. Publish
5. View
6. Delete
7. Back

> 1

What would you like to add to "Building Floating macOS UI with Tauri"?

> Just discovered you can use `window.setAlwaysOnTop(true)` for floating windows.
> Also the `decorations: false` config removes the title bar completely.

Where should this content go?
1. End of post (default)
2. After a specific section
3. Let me decide

> 1

Added to "Building Floating macOS UI with Tauri":

---
## Additional Tips

Just discovered you can use `window.setAlwaysOnTop(true)` for floating windows.
Also the `decorations: false` config removes the title bar completely.
---

Commit changes? (y/n) y

Committed: update: Building Floating macOS UI with Tauri

Would you like to work on another post? n

Done!
```

### Fuzzy Search with Multiple Matches
```
/blog javascript

Found 2 posts matching "javascript":

1. ESM vs CommonJS Dynamic Imports (draft)
2. Modern JavaScript Patterns (published)

Which one? 1

Selected: ESM vs CommonJS Dynamic Imports
Status: Draft

[shows actions...]
```

## Blog Post Quality Checklist

Before publishing, ensure:
- [ ] Title is compelling and clear
- [ ] Description is filled in (for SEO/previews)
- [ ] Content has a clear intro and conclusion
- [ ] Code snippets are properly formatted
- [ ] Tags are relevant and useful
- [ ] No placeholder text remains

## Notes

- Set `BLOG_CONTENT_DIR` in your `CLAUDE.md` for convenience
- Use `/blog <query>` for quick access to specific posts from any repo
- "Add content" is ideal for capturing quick learnings without context switching
- Posts are published to the main branch immediately
- The site rebuilds automatically on push (if CI/CD is set up)
- Use tags consistently to help readers find related posts
