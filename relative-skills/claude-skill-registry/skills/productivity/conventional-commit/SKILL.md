---
name: conventional-commit
description: Creates git commits following project-specific conventional commit conventions for a Quartz blog (content, fix, style, build prefixes)
allowed-tools: Bash, Read, Grep
---

# Conventional Commit Skill

This skill helps create properly formatted conventional commits for this Quartz blog repository.

## Commit Type Conventions

This project uses the following conventional commit prefixes:

- **content:** - For new blog posts or content additions
  - Format: `content: [title]` or `content(category): [title]`
  - Example: `content: Introduction to Static Site Generators`
  - Example: `content(tech): Understanding JAMstack Architecture`

- **fix:** - For corrections to existing content or code
  - Format: `fix: [what you fixed]` or `fix(scope): [what you fixed]`
  - Example: `fix: correct typo in about page`
  - Example: `fix(links): update broken external references`

- **style:** - For CSS, layout, or visual changes
  - Format: `style: [what you changed]` or `style(component): [what you changed]`
  - Example: `style: improve mobile navigation layout`
  - Example: `style(typography): adjust heading font sizes`

- **build:** - For Quartz generator configuration changes
  - Format: `build: [what you changed]` or `build(scope): [what you changed]`
  - Example: `build: enable syntax highlighting plugin`
  - Example: `build(config): update theme colors`

## Instructions

When the user asks you to create a commit:

1. **Analyze the changes:**
   - Run `git status` to see changed/new files
   - Run `git diff` to understand the nature of changes
   - Identify which commit type applies based on the files changed:
     - Files in `content/` → likely `content:` (unless fixing existing posts)
     - Files ending in `.css`, `.scss`, or style-related → `style:`
     - Files like `quartz.config.ts`, `quartz.layout.ts`, plugin configs → `build:`
     - Bug fixes or corrections → `fix:`

2. **Determine the scope (optional but recommended):**
   - For content: use the content category/folder (e.g., `tech`, `personal`, `about`)
   - For fixes: use the affected area (e.g., `links`, `formatting`, `frontmatter`)
   - For style: use the component/area (e.g., `typography`, `navigation`, `colors`)
   - For build: use the config area (e.g., `config`, `plugins`, `layout`)

3. **Craft the commit message:**
   - Use lowercase for the description
   - Be concise but descriptive (50 chars or less for the subject)
   - Use imperative mood (e.g., "add" not "added")
   - If needed, add a body with more details (separated by blank line)

4. **Stage and commit:**
   - Stage relevant files with `git add`
   - Create the commit with the formatted message
   - Do NOT include the Claude Code attribution footer for this project

## Examples

**New blog post:**
```bash
git add content/posts/my-new-post.md
git commit -m "content(posts): introduction to quartz"
```

**Fix typo in existing content:**
```bash
git add content/about.md
git commit -m "fix(about): correct university name"
```

**Update CSS styling:**
```bash
git add quartz/styles/custom.scss
git commit -m "style(typography): increase body font size for readability"
```

**Modify Quartz configuration:**
```bash
git add quartz.config.ts
git commit -m "build(config): enable LaTeX plugin and update theme"
```

**Multiple file changes with body:**
```bash
git add content/posts/*.md
git commit -m "content(posts): add three new articles on web development

- Introduction to React hooks
- CSS Grid vs Flexbox comparison
- Modern JavaScript features overview"
```

## Important Notes

- Always run `git status` and `git diff` first to understand what's being committed
- Do NOT add the "🤖 Generated with Claude Code" footer to commits in this repository
- If the user's changes span multiple types, ask which aspect they want to commit first or suggest breaking it into multiple commits
- For unclear cases, ask the user which commit type they prefer
- Never commit files that contain secrets (.env, credentials, etc.)
