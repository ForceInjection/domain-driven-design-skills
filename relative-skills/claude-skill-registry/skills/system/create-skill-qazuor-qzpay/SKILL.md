---
name: create-skill
type: meta
category: system
description: Interactive wizard to create reusable skills for specialized workflows
---

# Create Skill Command

## Purpose

Interactive wizard for creating skills - specialized, reusable workflows invoked by agents. Ensures skills follow standards and integrate properly.

## ⚙️ Configuration

| Setting | Description | Example |
|---------|-------------|---------|
| `skill_categories` | Available categories | `testing, development, validation, documentation, automation` |
| `skill_types` | Skill types | `workflow, validation, utility, template, analysis` |
| `base_path` | Skills directory | `.claude/skills/` |
| `name_pattern` | Validation regex | `^[a-z][a-z0-9-]*[a-z0-9]$` |
| `template_types` | Template options | `workflow, validation, utility` |

## Usage

```bash
/create-skill [options]
```

### Options

- `--name <name>`: Skill name (kebab-case)
- `--category <category>`: Skill category
- `--interactive`: Full interactive mode (default)
- `--template <type>`: Use template

## When to Use

- Reusable workflows needed
- Domain expertise codification
- Complex procedures documentation
- Best practice standardization

## Skill Creation Process

### Step 1: Discovery & Planning

**Wizard Questions**:

1. Skill name (kebab-case)
2. Skill category
3. One-line description
4. Detailed purpose
5. Primary users (agents)
6. Skill type

### Step 2: Workflow Definition

**Define**:

1. Input requirements
2. Process steps
3. Output/deliverables
4. Success criteria

### Step 3: File Generation

**File Created**: `{base_path}/{category}/{skill-name}.md`

**YAML Frontmatter**:

```yaml
---
name: {skill-name}
category: {category}
description: {description}
usage: {usage_context}
input: {input_requirements}
output: {output_produced}
---
```

**Structure**:

```markdown
# {Skill Name}

## Overview
{purpose_and_users}

## When to Use
{scenarios}

## Prerequisites
{requirements}

## Workflow
### Step 1: {name}
{actions_and_validation}

## Output
{deliverables_and_criteria}

## Examples
{scenarios}

## Error Handling
{errors_and_solutions}
```

### Step 4: Integration & Documentation

**Updates**:

- Skills README
- Agent documentation (if agent-specific)
- Quick start (if widely used)

### Step 5: Validation

**Checks**:

- Name follows conventions
- YAML valid
- All sections complete
- Workflow clear and actionable
- Prerequisites defined
- Success criteria measurable
- File in correct directory

**Test**: Invoke from agent context

### Step 6: Commit

**Format**:

```bash
feat(skills): add {skill-name} skill

- {description}
- Primary users: {agents}

Workflow: {key_steps}
Output: {deliverables}

Updates:
- {skill_file} (new)
- README.md (updated)
```

## Interactive Wizard Flow

```text
🎯 Create New Skill Wizard

📝 Step 1: Skill Identity
Skill Name: {input}
Category: {selection}
Description: {input}
Type: {selection}

📋 Step 2: Purpose & Users
Purpose: {input}
Primary users: {input}

🔧 Step 3: Workflow Definition
Steps: {input}
Input: {input}
Output: {input}
Success criteria: {input}

📝 Step 4: Review & Confirm
{summary}
Proceed? (y/n)

✨ Creating Skill
✓ Generated file
✓ Updated documentation
✓ Validation passed
```

## Skill Templates

### Workflow Skill

```markdown
---
name: {name}
category: {category}
description: {desc}
usage: Invoke when {context}
input: {requirements}
output: {deliverables}
---

# {Name}

## Overview
**Purpose**: {purpose}
**Primary Users**: {agents}

## Workflow
### Step 1: {name}
**Objective**: {goal}
**Actions**: {steps}
**Validation**: {checks}
**Output**: {result}

## Output
**Produces**: {outputs}
**Success Criteria**: {criteria}
```

### Validation Skill

```markdown
---
name: {name}
category: validation
description: {desc}
usage: Use to validate {what}
input: {what_to_validate}
output: Validation report
---

# {Name}

## Validation Checklist
### {Category}
- [ ] {check}

## Validation Process
{steps}

## Output Format
{report_format}
```

## Validation Rules

### Skill Name

- Format: kebab-case
- Length: 3-40 characters
- Pattern: Configured regex
- Must be unique

### YAML Frontmatter

**Required**: name, category, description, usage, input, output

**Valid Categories**: Configured categories

**Valid Types**: Configured types

### Directory Structure

```text
{base_path}/
├── testing/
├── development/
├── validation/
├── documentation/
├── automation/
└── analysis/
```

## Best Practices

### Design

- Generic and reusable
- Parameterized for context
- Modular steps
- Clear objectives
- Actionable steps
- Validated at each step

### Documentation

- Realistic examples
- Error scenarios documented
- Clear prerequisites
- Agent-aware design

## Common Patterns

### Testing Workflow

1. Prerequisites check
2. Test planning
3. Test implementation
4. Validation
5. Documentation

### Validation Workflow

1. Input validation
2. Criteria checking
3. Result compilation
4. Report generation

## Related Commands

- `/create-agent` - Create new agent
- `/create-command` - Create new command
- `/help` - System help

## Notes

- Skills invoked by agents, not users
- Keep focused on single responsibility
- Comprehensive docs critical
- Test from actual agent context
- Skills evolve with patterns
- Use action-oriented names
