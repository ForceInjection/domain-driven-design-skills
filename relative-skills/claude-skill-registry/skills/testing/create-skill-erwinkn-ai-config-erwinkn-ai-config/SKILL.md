---
name: create-skill
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
---

# Skill Creator

Skills are modular packages extending Claude's capabilities with specialized knowledge, workflows, and tools. They transform Claude from general-purpose to specialized agent with procedural knowledge no model can fully possess.

## Skill Anatomy

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter: name, description (required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/     - Executable code (deterministic, reusable operations)
    ├── references/  - Documentation loaded into context as needed
    └── assets/      - Output files (templates, images, fonts)
```

### SKILL.md Requirements

**Frontmatter:** `name` (hyphen-case) and `description` determine when Claude uses the skill.

**Description writing style:** Maximum information density. Super concise. Save every token possible without reducing informational content. Pack meaning into minimal words. Use third-person ("This skill should be used when..." not "Use when...").

**Body writing style:** Imperative/infinitive form (verb-first). Objective, instructional ("To accomplish X, do Y" not "You should do X").

### Bundled Resources

| Type | Purpose | When to use |
|------|---------|-------------|
| `scripts/` | Executable code | Same code repeatedly rewritten, deterministic reliability needed |
| `references/` | Documentation | Large docs Claude references while working (>10k words: include grep patterns) |
| `assets/` | Output files | Templates, images, fonts used in final output (not loaded into context) |

**Avoid duplication:** Information lives in SKILL.md OR references, not both. Keep SKILL.md lean.

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited*)

*Unlimited because scripts can be executed without reading into context window.

## Skill Creation Process

### Step 1: Understand with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, clearly understand concrete examples of how the skill will be used. This understanding can come from either direct user examples or generated examples that are validated with user feedback.

For example, when building an image-editor skill, relevant questions include:

- "What functionality should the image-editor skill support? Editing, rotating, anything else?"
- "Can you give some examples of how this skill would be used?"
- "I can imagine users asking for things like 'Remove the red-eye from this image' or 'Rotate this image'. Are there other ways you imagine this skill being used?"
- "What would a user say that should trigger this skill?"

**If unclear, ask the user.** Don't proceed without understanding concrete use cases. Use the question tool if one is available.

Conclude when functionality is clearly defined.

### Step 2: Plan Reusable Contents

To turn concrete examples into an effective skill, analyze each example by:

1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and assets would be helpful when executing these workflows repeatedly

Example: When building a `pdf-editor` skill to handle queries like "Help me rotate this PDF," the analysis shows:

1. Rotating a PDF requires re-writing the same code each time
2. A `scripts/rotate_pdf.py` script would be helpful to store in the skill

Example: When designing a `frontend-webapp-builder` skill for queries like "Build me a todo app" or "Build me a dashboard to track my steps," the analysis shows:

1. Writing a frontend webapp requires the same boilerplate HTML/React each time
2. An `assets/hello-world/` template containing the boilerplate HTML/React project files would be helpful to store in the skill

Example: When building a `big-query` skill to handle queries like "How many users have logged in today?" the analysis shows:

1. Querying BigQuery requires re-discovering the table schemas and relationships each time
2. A `references/schema.md` file documenting the table schemas would be helpful to store in the skill

To establish the skill's contents, analyze each concrete example to create a list of the reusable resources to include: scripts, references, and assets.

**If user input needed (brand assets, company docs, schemas), ask for it.** Use the question tool if one is available.

### Step 3: Write the Skill

Create skill directory with a SKILL.md file following the guidelines above.

If reusable contents would be useful:
- Implement scripts that will be executed repeatedly
- Create references for documentation Claude needs
- Add assets for templates/files used in output


