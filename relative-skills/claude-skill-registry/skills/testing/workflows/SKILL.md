---
description: Create a new AI agent skill following the Agent Skills specification
---

# Create Skill Workflow

This workflow guides you through creating a new skill for the AI agent following the [Agent Skills specification](https://agentskills.io/specification).

## Prerequisites

Skills are stored in:
- **Workspace-specific**: `<workspace-root>/.agent/skills/<skill-name>/`
- **Global**: `~/.gemini/antigravity/skills/<skill-name>/`

## Steps

### 1. Understand the Skill Requirements

1. Ask the user what capability or expertise the skill should provide
2. Clarify the specific use cases and when the skill should be activated
3. Identify if the skill needs:
   - Scripts for executable code
   - References for documentation
   - Assets for templates or resources

### 2. Design the Skill

1. Choose a valid skill name (lowercase, hyphens only, 1-64 chars, no consecutive hyphens)
2. Write a clear description (1-1024 chars) that includes:
   - What the skill does
   - When to use it (keywords for agent discovery)
3. Outline the main instruction sections

### 3. Create Skill Directory Structure

```
.agent/skills/<skill-name>/
├── SKILL.md            # Required: instructions + metadata
├── scripts/            # Optional: executable helper scripts
├── references/         # Optional: detailed documentation
└── assets/             # Optional: templates, schemas, images
```

### 4. Write SKILL.md

Create the SKILL.md file with the following format:

```markdown
---
name: skill-name
description: Clear description of what this skill does and when to use it. Include keywords for discovery.
---

# Skill Title

## When to Use This Skill

Describe the scenarios where this skill applies...

## Instructions

### Step 1: ...

Detailed step-by-step instructions...

### Step 2: ...

Continue with clear, actionable steps...

## Examples

Provide input/output examples...

## Edge Cases

Document common edge cases and how to handle them...
```

### 5. Add Optional Components (if needed)

#### scripts/
- Include executable scripts with clear documentation
- Scripts should be self-contained or document dependencies
- Add helpful error messages and edge case handling

#### references/
- Add detailed technical references (REFERENCE.md)
- Include domain-specific documentation
- Reference from SKILL.md using relative paths

#### assets/
- Add templates, schemas, lookup tables
- Include any static resources the skill needs

### 6. Validate the Skill

1. Verify SKILL.md frontmatter:
   - `name` matches directory name
   - `description` is descriptive and includes keywords
2. Check instructions are clear and actionable
3. Ensure any referenced files exist
4. Token budget check:
   - Metadata: ~100 tokens
   - Instructions: <5000 tokens recommended
   - Resources: loaded only when needed

### 7. Document for User

1. Summarize what the skill does
2. Explain how to invoke it (describe task matching keywords)
3. Note any dependencies or requirements
4. Provide usage examples

## Best Practices

- **Single Responsibility**: Each skill should focus on one specific task
- **Effective Descriptions**: Include specific keywords the agent uses for matching
- **Progressive Disclosure**: Keep SKILL.md concise, use references/ for details
- **Script Integration**: If using scripts, document `--help` usage to save context
- **Decision Trees**: Include logic for choosing between approaches
