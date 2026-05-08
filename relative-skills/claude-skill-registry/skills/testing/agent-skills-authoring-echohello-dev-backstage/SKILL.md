---
name: agent-skills-authoring
description: Create and maintain Agent Skills following the agentskills.io specification for AI agents
---

# Agent Skills Authoring Skill

Use this skill when creating new skills, updating existing skills, or helping others understand the Agent Skills format. This skill follows the open specification at [agentskills.io](https://agentskills.io).

## When to activate this skill

- User asks to create a new skill
- User wants to document a repeatable workflow for an agent
- User asks about the Agent Skills format or specification
- User wants to add scripts, references, or assets to a skill
- User needs to validate an existing skill

## What are Agent Skills?

Agent Skills are a lightweight, open format for extending AI agent capabilities. A skill is a folder containing instructions, scripts, and resources that agents can discover and use.

Key benefits:
- **Portable**: Skills are just files—easy to version, share, and edit
- **Self-documenting**: Anyone can read a SKILL.md and understand what it does
- **Progressive disclosure**: Agents load metadata first, full instructions on demand
- **Interoperable**: Works across multiple agent products (Claude, VS Code, Cursor, etc.)

## Directory structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
skill-name/
├── SKILL.md           # Required: instructions + metadata
├── scripts/           # Optional: executable code
├── references/        # Optional: documentation
└── assets/            # Optional: templates, resources
```

## SKILL.md format

### Required frontmatter

The file MUST start with YAML frontmatter:

```yaml
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

### Optional frontmatter fields

```yaml
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents.
license: Apache-2.0
compatibility: Requires Python 3.10+, pdfplumber
metadata:
  author: example-org
  version: "1.0"
allowed-tools: Bash(git:*) Read
---
```

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars, lowercase alphanumeric + hyphens, no leading/trailing/consecutive hyphens |
| `description` | Yes | 1-1024 chars, describe what the skill does AND when to use it |
| `license` | No | License name or reference to bundled LICENSE file |
| `compatibility` | No | Max 500 chars, environment requirements |
| `metadata` | No | Arbitrary key-value pairs for custom properties |
| `allowed-tools` | No | Space-delimited list of pre-approved tools (experimental) |

### Name validation rules

Valid:
- `pdf-processing`
- `data-analysis`
- `code-review`

Invalid:
- `PDF-Processing` (uppercase not allowed)
- `-pdf` (cannot start with hyphen)
- `pdf--processing` (consecutive hyphens not allowed)
- `pdf-` (cannot end with hyphen)

The `name` field MUST match the parent directory name.

### Body content

The Markdown body after frontmatter contains the skill instructions. No format restrictions, but recommended sections:

1. **When to activate this skill** - Clear triggers for activation
2. **Step-by-step instructions** - How to perform the task
3. **Examples** - Inputs and outputs
4. **Edge cases** - Common pitfalls and how to handle them
5. **Checklist** - Definition of done

## Progressive disclosure

Skills use progressive disclosure to manage context efficiently:

1. **Metadata (~100 tokens)**: `name` and `description` loaded at startup for all skills
2. **Instructions (< 5000 tokens recommended)**: Full `SKILL.md` body loaded when activated
3. **Resources (as needed)**: Files in `scripts/`, `references/`, `assets/` loaded only when required

**Best practice**: Keep your main `SKILL.md` under 500 lines. Move detailed reference material to separate files.

## Optional directories

### scripts/

Contains executable code that agents can run:

```
scripts/
├── extract.py
├── validate.sh
└── generate.js
```

Scripts should:
- Be self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases gracefully

### references/

Additional documentation loaded on demand:

```
references/
├── REFERENCE.md      # Detailed technical reference
├── FORMS.md          # Form templates
└── api-guide.md      # Domain-specific docs
```

Keep individual reference files focused—agents load these on demand.

### assets/

Static resources:

```
assets/
├── template.json     # Configuration templates
├── schema.yaml       # Data schemas
└── example.png       # Diagrams
```

## File references

When referencing files in your skill, use relative paths from the skill root:

```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script: scripts/extract.py
```

Keep file references one level deep from `SKILL.md`. Avoid deeply nested reference chains.

## Workflow: Creating a new skill

### Step 1: Create the directory

```bash
mkdir -p .claude/skills/my-skill
```

### Step 2: Create SKILL.md with frontmatter

```bash
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Brief description of what this skill does and when to use it.
---

# My Skill

Use this skill when [specific trigger conditions].

## When to activate this skill

- Trigger condition 1
- Trigger condition 2

## Instructions

1. Step one
2. Step two
3. Step three

## Examples

### Example: [Scenario]

Input: ...
Output: ...

## Checklist

- [ ] Item 1
- [ ] Item 2
EOF
```

### Step 3: Add to skill registration (if applicable)

For Claude Code/VS Code, skills in `.claude/skills/` are auto-discovered.

For other systems, you may need to register the skill in your agent configuration.

## Writing effective descriptions

The `description` field is critical—it determines when the skill is activated.

**Good example**:
```yaml
description: Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.
```

**Poor example**:
```yaml
description: Helps with PDFs.
```

Include:
- What the skill does (capabilities)
- When to use it (trigger keywords)
- Specific operations or workflows

## Writing effective instructions

### Use action-oriented headings

```markdown
## How to extract text from PDFs
## How to merge multiple documents
## How to validate output
```

### Include concrete examples

```markdown
## Example: Extracting tables

Input: A scanned invoice PDF
Expected output: JSON with line items, totals, and dates

```python
# scripts/extract_table.py
import pdfplumber
...
```
```

### Document edge cases

```markdown
## Edge cases

- **Scanned PDFs**: Use OCR fallback with `--ocr` flag
- **Password-protected**: Prompt user for password
- **Corrupted files**: Return clear error message
```

### Add a checklist

```markdown
## Checklist

Before finishing:

- [ ] Output validated against schema
- [ ] Edge cases handled
- [ ] User informed of any warnings
```

## Bundled scripts

This skill includes helper scripts in its `scripts/` directory:

```
<this-skill>/scripts/
├── new-skill.sh       # Create a new skill from template
└── validate-skill.sh  # Validate a skill directory
```

Run scripts using the path to this skill's location in your project.

### Create a new skill

```bash
# Syntax: <path-to-this-skill>/scripts/new-skill.sh <skill-name> "<description>"

# The script creates the skill in the default .claude/skills/ directory
# Edit SKILLS_DIR in the script to change the default location for your project
```

This creates `<skills-dir>/<skill-name>/SKILL.md` with a template following the spec.

### Validate an existing skill

```bash
# Syntax: <path-to-this-skill>/scripts/validate-skill.sh <skill-directory>

# Example - validate a skill at any path:
# ./scripts/validate-skill.sh path/to/my-skill
```

Checks:
- SKILL.md exists with valid frontmatter
- `name` matches directory name and follows naming rules
- `description` is present and under 1024 chars
- Warns if missing recommended sections (examples, checklist)
- Reports line count vs 500-line recommendation

### Validate all skills in a directory

```bash
# Validate all skills in any skills directory
for skill in <your-skills-dir>/*/; do
  <path-to-this-skill>/scripts/validate-skill.sh "$skill"
done
```

## External validation

Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) CLI for additional validation:

```bash
# Install
pip install skills-ref

# Validate a skill
skills-ref validate ./my-skill

# Generate prompt XML for agent integration
skills-ref to-prompt ./my-skill
```

## Agent integration

### How agents discover skills

Agents scan configured directories for valid skills (folders with `SKILL.md`).

### System prompt injection

Skill metadata is injected into the system prompt using XML:

```xml
<available_skills>
  <skill>
    <name>my-skill</name>
    <description>What this skill does...</description>
    <location>/path/to/skills/my-skill/SKILL.md</location>
  </skill>
</available_skills>
```

### Activation flow

1. **Discovery**: Agent loads `name` and `description` at startup
2. **Matching**: Agent matches user task to skill description
3. **Activation**: Agent reads full `SKILL.md` into context
4. **Execution**: Agent follows instructions, loading resources as needed

## Skills location

The Agent Skills spec does not mandate a specific folder. Skills can live anywhere in a project—agents discover them by scanning configured paths. The location depends on your project's conventions and which agent/editor you use.

Common conventions include:
- `.claude/skills/`
- `.cursor/skills/`
- `skills/` at project root
- `.github/skills/`

**Portability**: Skills are designed to be portable across projects and editors. Use relative paths within your skill directory, and avoid hardcoding project-specific paths in the skill instructions themselves.

To add a new skill:
1. Choose a skills directory appropriate for your project
2. Create a subdirectory matching your skill name: `<skills-dir>/<skill-name>/`
3. Create `SKILL.md` with required frontmatter
4. Optionally add `scripts/`, `references/`, or `assets/`

## Common mistakes to avoid

1. **Description too vague**: Be specific about triggers and capabilities
2. **SKILL.md too long**: Split into references if > 500 lines
3. **Name mismatch**: Directory name must match `name` field
4. **Missing frontmatter**: File must start with `---` YAML block
5. **Deep nesting**: Keep references one level deep
6. **No examples**: Always include concrete input/output examples
7. **No checklist**: Add "definition of done" criteria

## Checklist for new skills

Before finishing:

- [ ] Directory name matches `name` field
- [ ] `description` is specific (includes what AND when)
- [ ] SKILL.md under 500 lines
- [ ] "When to activate" section present
- [ ] At least one concrete example included
- [ ] Checklist/definition of done included
- [ ] File references use relative paths
- [ ] Tested that skill activates correctly

## References

- [Agent Skills Specification](https://agentskills.io/specification.md)
- [Example Skills](https://github.com/anthropics/skills)
- [skills-ref Library](https://github.com/agentskills/agentskills/tree/main/skills-ref)
- [Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)