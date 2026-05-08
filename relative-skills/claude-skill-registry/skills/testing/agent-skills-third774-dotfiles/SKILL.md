---
name: agent-skills
description: Author and improve Agent Skills following the agentskills.io specification. Use when creating new SKILL.md files, modifying existing skills, reviewing skill quality, or organizing skill directories with proper naming, descriptions, and progressive disclosure.
---

# Agent Skills

Agent Skills are folders of instructions, scripts, and resources that agents discover and load on demand. This skill covers creating, modifying, and reviewing skills to ensure they follow the specification and best practices.

## When to Use This Skill

- Creating a new skill from scratch
- Modifying or improving an existing skill
- Reviewing skill quality before sharing
- Reorganizing skill content for better progressive disclosure

## Specification Quick Reference

### Required Frontmatter

Every `SKILL.md` must start with YAML frontmatter containing `name` and `description`:

```yaml
---
name: skill-name
description: What this skill does and when to use it.
---
```

### Name Field Rules

The `name` field must:

- Be 1-64 characters
- Use only lowercase alphanumeric characters and hyphens (`a-z`, `0-9`, `-`)
- Not start or end with a hyphen
- Not contain consecutive hyphens (`--`)
- Match the parent directory name exactly

Valid: `pdf-processing`, `code-review`, `data-analysis`
Invalid: `PDF-Processing`, `-pdf`, `pdf--processing`, `my_skill`

### Description Field Rules

The `description` field must:

- Be 1-1024 characters
- Be written in third person (not "I can help you" or "You can use this")
- Include both what the skill does AND when to use it
- Contain specific keywords that help agents identify relevant tasks

**Good:**
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad:**
```yaml
description: Helps with PDFs.
```

### Optional Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `license` | License name or reference to bundled LICENSE file |
| `compatibility` | Environment requirements (max 500 chars) |
| `metadata` | Arbitrary key-value pairs for custom properties |
| `allowed-tools` | Space-delimited list of pre-approved tools (experimental) |

## Directory Structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required - main instructions
├── scripts/          # Optional - executable code
├── references/       # Optional - additional documentation
└── assets/           # Optional - static resources (templates, images, data)
```

### When to Add References

Add separate reference files when:

- SKILL.md exceeds ~300 lines
- Content applies to specific contexts (language-specific patterns, domain-specific schemas)
- Details are needed only for certain tasks (advanced features, edge cases)

Keep references one level deep from SKILL.md. Avoid nested reference chains.

## Best Practices

### Conciseness is Key

The context window is shared with conversation history, system prompts, and other skills. Challenge every piece of information:

- Does the agent really need this explanation?
- Can the agent be assumed to know this?
- Does this paragraph justify its token cost?

**Target:** Keep SKILL.md body under 500 lines. Move detailed reference material to separate files.

### Progressive Disclosure

Structure skills for efficient context usage:

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup for all skills
2. **Instructions** (<5000 tokens): Full SKILL.md loaded when skill activates
3. **Resources** (as needed): Reference files loaded only when required

SKILL.md serves as an overview that points to detailed materials. Like a table of contents.

### Degrees of Freedom

Match specificity to task fragility:

| Freedom Level | When to Use | Example |
|---------------|-------------|---------|
| **High** (text instructions) | Multiple valid approaches, context-dependent | Code review guidelines |
| **Medium** (templates/pseudocode) | Preferred pattern exists, some variation OK | Report generation template |
| **Low** (exact scripts) | Fragile operations, consistency critical | Database migrations |

### Workflow Checklists

For multi-step processes, provide a checklist the agent can copy and track:

```
Task Progress:
- [ ] Step 1: Analyze requirements
- [ ] Step 2: Create plan
- [ ] Step 3: Implement
- [ ] Step 4: Validate
```

### Feedback Loops

Include validation steps for quality-critical tasks:

1. Perform action
2. Run validation
3. If validation fails → fix and retry
4. Only proceed when validation passes

## Authoring Workflow

Copy this checklist when creating or modifying a skill:

```
Skill Authoring Progress:
- [ ] Step 1: Define purpose (what problem does this solve?)
- [ ] Step 2: Identify triggers (when should agent use this?)
- [ ] Step 3: Write frontmatter (name matches directory, description is specific)
- [ ] Step 4: Draft body (core instructions, workflows, examples)
- [ ] Step 5: Extract references (move detailed/contextual content)
- [ ] Step 6: Review against checklist (see references/best-practices-checklist.md)
- [ ] Step 7: Test with real tasks
```

### Writing Effective Descriptions

The description enables skill discovery. Include:

1. **What it does**: Core capabilities in active voice
2. **When to use it**: Specific triggers and keywords
3. **Third person**: "Extracts text from PDFs" not "I extract text from PDFs"

## Common Anti-Patterns

### Vague Descriptions

```yaml
# Bad - agent can't determine when to use this
description: Helps with documents.

# Good - specific capabilities and triggers
description: Extract text and tables from PDF files, fill PDF forms, merge multiple PDFs. Use when working with PDF files or document extraction.
```

### Over-Explaining Common Knowledge

```yaml
# Bad - agent knows what PDFs are
PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF...

# Good - get to the actionable content
Use pdfplumber for text extraction:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

### Deeply Nested References

```markdown
# Bad - agent may partially read nested files
SKILL.md → references/advanced.md → references/details.md

# Good - one level deep
SKILL.md → references/advanced.md
SKILL.md → references/details.md
```

### Time-Sensitive Information

```markdown
# Bad - becomes outdated
If you're doing this before August 2025, use the old API.

# Good - use "old patterns" section
## Current method
Use the v2 API endpoint.

## Old patterns (deprecated)
<details>
<summary>Legacy v1 API</summary>
The v1 API used: `api.example.com/v1/messages`
</details>
```

### Too Many Options Without Defaults

```markdown
# Bad - decision paralysis
You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image...

# Good - clear default with escape hatch
Use pdfplumber for text extraction.
For scanned PDFs requiring OCR, use pdf2image with pytesseract instead.
```

### Inconsistent Terminology

Pick one term and use it throughout:

- Always "API endpoint" (not mixing with "URL", "route", "path")
- Always "field" (not mixing with "box", "element", "control")

## Quality Review

Before finalizing a skill, review against the full checklist in `references/best-practices-checklist.md`.

For example patterns and structures, see `references/examples.md`.

<IMPORTANT>
Every skill should answer two questions clearly:
1. What does this skill enable the agent to do?
2. When should the agent use this skill?

If your description doesn't answer both, revise it.
</IMPORTANT>
