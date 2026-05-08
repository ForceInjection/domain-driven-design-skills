---
name: ideation
description: Creative ideation for new project concepts. USE WHEN user says "new idea", "what if we built", "I want to create", "brainstorm a project", or discusses ideas without an existing project. Creates IDEA.md and project structure. Not for in-project exploration—use exploration skill for that.
---

# Ideation

Collaborative creative thinking for new project concepts. Captures insights into IDEA.md and project structure.

## Available Environment Variables

These env vars are available in bash commands (use `${VAR}` syntax):

- `${PROJECT_NAME}` - Current project name
- `${PROJECT_ROOT}` - Current project code directory (e.g., `~/development/projects/argus`)
- `${WORKFLOW_PROJECTS}` - Obsidian projects root (e.g., `~/obsidian/projects`)

**Derived paths (placeholders for tool calls):**
- Project planning/IDEA.md: `{WORKFLOW_PROJECTS}/{project-name}/`
- Explorations: `{WORKFLOW_PROJECTS}/{project-name}/explorations/`
- Later backlog: `{WORKFLOW_PROJECTS}/{project-name}/later.md`

**Note**: The `{project-name}` references in this skill refer to the project being ideated about (extracted from user conversation), not the current `${PROJECT_NAME}` context.

## Workflow Decision Tree

```
User mentions idea/project
    ↓
Extract project name (ask if ambiguous)
    ↓
Check for existing {WORKFLOW_PROJECTS}/{project-name}/IDEA.md
    ↓
    ├─ Not found → NEW PROJECT flow
    ├─ Found + major pivot → BIG CHANGES flow
    └─ Found + new features → NEW FEATURES flow
    ↓
Engage in creative discussion
    ↓
Capture insights mentally during conversation
    ↓
User triggers save ("save this ideation", "capture this idea", etc.)
    ↓
Execute save based on detected flow
```

## Examples

**Example 1: New project from scratch**
```
User: "I have an idea for a tool that tracks reading habits"
→ Extract project name (ask if unclear)
→ Check for existing IDEA.md → not found → NEW PROJECT flow
→ Engage in creative discussion
→ On "save this ideation" → create IDEA.md
```

**Example 2: Evolving existing vision**
```
User: "I want to pivot argus to focus on home automation"
→ Read existing IDEA.md
→ Discuss major changes → BIG CHANGES flow
→ On save → update IDEA.md, preserve history
```

**Example 3: Adding features to backlog**
```
User: "What if we added dark mode to the dashboard?"
→ Read existing IDEA.md
→ Discuss feature → NEW FEATURES flow
→ On save → append to later.md with ID
```

## Phase 1: Project Detection

**BEFORE engaging in discussion**, determine the context:

### Extract Project Name

Identify the project name from the conversation. If ambiguous or not mentioned, ask directly.

### Check for Existing Project

Look for `{WORKFLOW_PROJECTS}/{project-name}/IDEA.md` using the Read tool.

### Classify Scope

Based on findings:

- **NEW PROJECT**: No IDEA.md exists, completely new concept
- **BIG CHANGES**: IDEA.md exists, but major pivot/vision shifts being discussed
- **NEW FEATURES**: IDEA.md exists, discussing additions/improvements

If IDEA.md exists, read it to understand the current vision before proceeding.

## Phase 2: Creative Discussion

**Approach:** Think WITH them, not for them. Build on excitement, challenge assumptions, stay concrete.

**Track mentally** (don't call out explicitly):
- Core problem, target users, key features
- Success criteria, constraints, unique value

**For existing projects:** Reference current IDEA.md, build on existing vision
**For new projects:** Focus on problem/solution fit, keep asking "who" and "why"

## Phase 3: Saving Ideation

### Trigger Phrases

Execute save immediately when user says:
- "save this ideation"
- "let's capture this idea"
- "document this concept"
- "create the project"

### Save Execution by Scope

#### NEW PROJECT

1. Create directory: `{WORKFLOW_PROJECTS}/{project-name}/`
2. Read `references/idea_template.md` from this skill
3. Generate new IDEA.md by filling template with discussion details
4. Write to `{WORKFLOW_PROJECTS}/{project-name}/IDEA.md`
5. Confirm: "Created project '{project-name}' at {path}"
6. If PROJECT is "workspace": Say "Run `momentum {project-name}` to start building."

**Template Filling Guidelines:**
- Replace `[Project Name]` with actual project name
- Fill bracketed placeholders with concrete details from discussion
- Use specific examples mentioned during conversation
- Leave sections empty if not discussed (don't invent content)
- Preserve the template structure and section headings

#### BIG CHANGES

1. Read existing `{WORKFLOW_PROJECTS}/{project-name}/IDEA.md`
2. Update with new vision while preserving relevant existing parts
3. Move superseded information to "Learning and Evolution" section
4. Write updated content back to same location
5. Confirm: "Updated vision for '{project-name}'"

**Preservation Guidelines:**
- Keep any "Learning and Evolution" entries
- Preserve success metrics and constraints that still apply
- Update "Evolution Notes" to document the pivot
- Maintain built features in status section

#### NEW FEATURES

1. Check if `{WORKFLOW_PROJECTS}/{project-name}/later.md` exists
2. Generate unique ID using `scripts/generate_id.py` for each feature
3. Format as: `- idea:: {description} id::{generated-id} captured::{today's date in YYYY-MM-DD format}`
4. Append to `later.md` (create file if needed)
5. Confirm: "Added feature ideas to '{project-name}' backlog"

**ID Format**: 6-character lowercase alphanumeric (e.g., `g7k2m9`, `x3p5n1`)

**Feature Description Guidelines:**
- Keep descriptions concise but specific
- Focus on user value, not implementation
- Capture enough context to recall the discussion later
- One line per feature idea

## Standards

- Use concrete details from conversation, not invented content
- Execute on trigger phrases—don't ask "would you like me to save?"
- Preserve discussion energy in outputs

## Resources

### references/idea_template.md

Complete template for creating new project IDEA.md files. Read this file when executing NEW PROJECT saves to ensure proper structure and all required sections.

### scripts/generate_id.py

Python script that generates 6-character lowercase alphanumeric IDs for feature tracking in later.md files. Execute without loading into context:

```bash
python scripts/generate_id.py
```

Returns format: `a1b2c3` (6 random chars from [a-z0-9])
