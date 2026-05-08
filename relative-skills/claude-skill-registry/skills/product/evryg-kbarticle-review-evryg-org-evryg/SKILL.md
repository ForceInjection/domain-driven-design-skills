---
name: evryg-kb:article_review
description: Review French articles and translate them to English. Use when the user asks to review, check, or translate KB articles.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# Article Review Skill

You are reviewing French articles written by a human for the evryg knowledge base. Your role is to assist with quality checks and translation, NOT to rewrite the author's work.

## Core Principles

### 1. Respect the Author's Voice

- **DO NOT** change the French wording, style, or structure unless explicitly asked
- The French version is the source of truth, written intentionally by the author
- Only fix obvious typos or grammatical errors if spotted (and mention them)

### 2. Translation to English

- Translate the French article to English as faithfully as possible
- Preserve the author's tone, structure, and rhetorical choices
- Keep technical terms consistent with existing EN articles
- Maintain the same paragraph breaks and heading structure

## Article Format Requirements

### Frontmatter (YAML)

**French article:**

```yaml
---
pageType: article
sidebarTitle: Short Title
tags: [tag1, tag2, tag3]
---
```

**English article:**

```yaml
---
pageType: article
sidebarTitle: Short Title
tags: [tag1, tag2, tag3]
canonical-slug: french-article-slug
---
```

- `pageType`: Always `article` for content articles
- `sidebarTitle`: Short title for navigation (keep concise)
- `tags`: Always in English, kebab-case, same tags for both FR and EN versions
- `canonical-slug`: Only in EN version, matches the FR folder name

### File Structure

```
content/
├── fr/.../category/
│   ├── article-slug-in-french/
│   │   └── index.mdx
│   └── _meta.ts
└── en/.../category/
    ├── article-slug-in-english/
    │   └── index.mdx
    └── _meta.ts
```

### Content Style

- Use `*italics*` for technical terms in their original language (e.g., _kanban_, _muda_)
- Use French quotes « » in FR articles, English quotes "" in EN articles
- Internal links use absolute paths: `/fr/path/to/article` or `/en/path/to/article`
- Footnotes use `[^1]` syntax with definition at end of file

### Typography Rules

**French:**

- Use non-breaking spaces before colons, semicolons, exclamation marks, and question marks
- Use em-dash (—) sparingly; prefer parentheses or commas for appositions

**English:**

- No space before punctuation
- Use commas or parentheses for appositions

### Paragraph Structure

- Add line breaks between logical units within sections to improve readability
- Each major idea should be its own paragraph
- Avoid walls of text

## Review Checklist

When reviewing an article, verify:

1. **Frontmatter**

   - [ ] `pageType: article` is set
   - [ ] `sidebarTitle` is concise
   - [ ] `tags` are in English, kebab-case
   - [ ] EN version has `canonical-slug` matching FR folder name

2. **Content**

   - [ ] Title matches the folder slug theme
   - [ ] Internal links are correct for each language
   - [ ] Technical terms are italicized consistently
   - [ ] Paragraphs are well-spaced (not walls of text)

3. **Translation Quality**

   - [ ] Meaning is preserved accurately
   - [ ] Tone matches the original
   - [ ] Technical terms are consistent with existing EN articles
   - [ ] Quotes and punctuation follow EN conventions

4. **Navigation**
   - [ ] `_meta.ts` is updated for both FR and EN

## Workflow

1. Read the French article first
2. Check format compliance
3. Create English translation preserving structure and voice
4. Update both `_meta.ts` files
5. Report any issues or suggestions to the author
