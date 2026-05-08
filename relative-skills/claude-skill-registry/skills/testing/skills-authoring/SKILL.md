---
name: skills-authoring
version: 1.0.0
description: Creates or updates skills with proper YAML frontmatter, progressive disclosure, and best practices per the open Agent Skills specification. Supports simple, tool-restricted, multi-file, and script-based skills. Use when creating new skills, authoring skills, extending agent capabilities, or when `--create-skill` or `--new-skill` flag is mentioned.
allowed-tools: Read Write Edit Grep Glob TodoWrite
---

# Skill Authoring

Create skills that follow the [Agent Skills specification](https://agentskills.io/specification)—an open format supported by Claude Code, Cursor, VS Code, GitHub, and other agent products.

## Quick Start

1. **Clarify requirements**
   - What capability does this provide?
   - What triggers should activate it?
   - Location: personal (`~/.claude/skills/`) or project (`.claude/skills/`)?

2. **Choose archetype** from [`templates/skill-archetypes/`](templates/skill-archetypes/):
   - `simple/` - Single SKILL.md file
   - `api-wrapper/` - External API integration with client script
   - `dev-workflow/` - Development automation with runner script
   - `document-processor/` - File processing with processing script
   - `research-synthesizer/` - Research and synthesis workflow

3. **Generate name**
   - Pattern: lowercase, hyphens only (e.g., `pdf-processing`, **code-review**)
   - Gerund form recommended: `processing-pdfs`, `analyzing-data`
   - Must match directory name

4. **Write SKILL.md**
   - Valid YAML frontmatter
   - Third-person description with triggers
   - Clear, concise instructions
   - Concrete examples

5. **Add supporting files** (if needed)
   - `references/` - detailed documentation
   - `scripts/` - executable utilities
   - `assets/` - templates, data files

6. **Validate**
   - Use `skills-ref validate ./my-skill` or **skill-validation**

## Directory Structure

```
skill-name/
├── SKILL.md           # Required: instructions + metadata
├── scripts/           # Optional: executable code
├── references/        # Optional: documentation
└── assets/            # Optional: templates, resources
```

## SKILL.md Format

```yaml
---
name: skill-name
description: What it does and when to use it. Include trigger keywords.
license: Apache-2.0                    # optional
compatibility: Requires git and jq     # optional
metadata:                              # optional
  author: your-org
  version: "1.0"
allowed-tools: Read Grep Glob          # optional, experimental
---

# Skill Name

## Quick Start
[Minimal working example]

## Instructions
[Step-by-step guidance]

## Examples
[Concrete, runnable examples]

For cross-tool compatibility details, see the [references/](references/) directory.
```

## Frontmatter Fields

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars, lowercase/numbers/hyphens, must match directory |
| `description` | Yes | 1-1024 chars, describes what + when |
| `license` | No | License name or reference to bundled file |
| `compatibility` | No | 1-500 chars, environment requirements |
| `metadata` | No | Key-value pairs for additional info |
| `allowed-tools` | No | Space-delimited tool list (experimental) |

Refer to the [Agent Skills Specification](https://agentskills.io/specification) for complete schema.

## Core Principles

### Concise is key

The context window is shared. Only include what the agent doesn't already know. Challenge each paragraph—does it justify its token cost?

### Third-person descriptions

Descriptions inject into system prompt. Use third person:
- ✓ "Extracts text from PDFs"
- ✗ "I can help you extract text from PDFs"

### Progressive disclosure

Keep SKILL.md under 500 lines. Move details to:
- `references/` - Detailed docs, API references
- `scripts/` - Executable utilities (code never enters context)
- `assets/` - Templates, data files

Token loading:
1. **Metadata** (~100 tokens): name + description loaded at startup for all skills
2. **Instructions** (<5000 tokens): SKILL.md body loaded when skill activates
3. **Resources** (as needed): files loaded only when referenced

## Description Formula

**[WHAT] + [WHEN] + [TRIGGERS]**

```yaml
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

Include trigger keywords that users would naturally say when they need this skill.

## Naming Requirements

- Lowercase letters, numbers, hyphens only
- Cannot start/end with hyphen or contain `--`
- Must match parent directory name
- Cannot contain `anthropic` or `claude`

**Recommended**: Gerund form (`processing-pdfs`, `reviewing-code`)

## Tool Restrictions

Use `allowed-tools` to limit capabilities (experimental):

```yaml
# Read-only
allowed-tools: Read Grep Glob

# With shell access
allowed-tools: Bash(git:*) Bash(jq:*) Read

# Full access (default)
# Omit field entirely
```

## Skill Types

**Simple** - Single SKILL.md file for basic capabilities

**Tool-Restricted** - Uses `allowed-tools` to limit tool access

**Multi-File** - SKILL.md with supporting `references/` documentation

**Script-Based** - Includes executable scripts in `scripts/`

## Validation

Use the official [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) library:

```bash
skills-ref validate ./my-skill
```

Or use **skill-validation** for integrated validation and review.

### Quick Self-Check

Before finalizing, verify:
- [ ] YAML frontmatter valid (opens/closes with `---`)
- [ ] Name lowercase, matches directory
- [ ] Description uses third-person voice
- [ ] Description includes 3-5 trigger keywords
- [ ] SKILL.md under 500 lines
- [ ] All referenced files exist

### Common Description Mistakes

- ❌ "Helps with files" → Too vague
- ❌ "I can help you..." → Wrong voice (first-person)
- ❌ "You can use this to..." → Wrong voice (second-person)
- ❌ No "Use when..." → Missing triggers

Use the **skill-validation** skill to validate your skill before finalizing.

## Best Practices

1. **Concise**: Challenge each paragraph—does the agent need this?
2. **Third-person**: Descriptions inject into system prompt
3. **Under 500 lines**: Keep SKILL.md focused
4. **One level deep**: File references should be direct from SKILL.md
5. **Single responsibility**: One skill, one capability
6. **Concrete examples**: Show real usage, not abstract concepts
7. **Test with real queries**: Verify the skill triggers correctly

## After Creation

1. **Check**: Run **skill-validation** to validate and review
2. **Test**: Ask a question that should trigger it
3. **Iterate**: Fix issues and re-check until passing
4. **Share**: Commit to git or distribute via plugin

## Troubleshooting

```bash
# Find all skills
find ~/.claude/skills .claude/skills -name "SKILL.md" 2>/dev/null

# Check for tab characters (YAML requires spaces)
grep -P "\t" SKILL.md

# Find broken markdown links
grep -oE '\[[^]]+\]\([^)]+\)' SKILL.md | while read link; do
  file=$(echo "$link" | sed 's/.*(\(.*\))/\1/')
  [ ! -f "$file" ] && echo "Missing: $file"
done
```

## References

For cross-tool compatibility and implementation details:
- [implementations.md](references/implementations.md) - Per-tool storage paths and features
- [invocations.md](references/invocations.md) - How each tool activates skills
- [compatibility.md](references/compatibility.md) - Path compatibility matrix

## External Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Best Practices Guide](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Example Skills Repository](https://github.com/anthropics/skills)
- [skills-ref Validation Library](https://github.com/agentskills/agentskills/tree/main/skills-ref)
