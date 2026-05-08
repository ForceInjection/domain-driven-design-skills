---
name: skillstash-author
description: Author skillstash SKILL.md files from research or issue specs
---

# Skillstash Author

Use this skill to draft or update `SKILL.md` files for new skills.

## When this skill activates

- Research notes are ready
- An issue provides a clear spec for a skill

## What this skill does

1. Read research notes or issue specs.
2. Write `skills/<name>/SKILL.md` with required frontmatter and instructions.
3. Add optional `references/`, `scripts/`, or `assets/` when helpful.

## Requirements

- Frontmatter must include `name` and `description`.
- `name` must match the directory name (kebab-case).
