---
name: parallel-prompt-generator
short: Generate agent prompts from task specs
description: Generate agent-ready prompts from existing task specification files. Use when regenerating prompts after editing tasks, updating prompt templates, or preparing tasks for cpo execution.
when: User wants to generate prompts from tasks, regenerate prompts after task edits, create agent-ready instructions from task specs, or refresh the prompts/ folder
---

# Prompt Generator

Generate agent-ready prompts from existing task specification files in `tasks/`.

## CRITICAL: Prompt Template Requirements

Every generated prompt file MUST include ALL of these sections (see Step 4 for full template):

| Section | Purpose | Required |
|---------|---------|----------|
| `=== REQUIRED SKILLS ===` | Skills to invoke at start | YES |
| `=== CONTEXT ===` | Shared project context | YES |
| `=== OBJECTIVE ===` | Task goal | YES |
| `=== CONTRACTS ===` | Contract file references | YES |
| `=== FILES TO CREATE ===` | Scope CREATE | YES |
| `=== FILES TO MODIFY ===` | Scope MODIFY | YES |
| `=== DO NOT MODIFY ===` | Scope BOUNDARY | YES |
| `=== IMPLEMENTATION REQUIREMENTS ===` | Requirements | YES |
| `=== ACCEPTANCE CRITERIA ===` | Checklist | YES |
| `=== EXECUTION INSTRUCTIONS ===` | How to implement | **MANDATORY** |
| `=== IMPORTANT RULES ===` | Constraints | **MANDATORY** |
| `=== COMPLETION SIGNAL ===` | touch .claude-task-complete | **MANDATORY** |

**DO NOT generate prompts without the EXECUTION INSTRUCTIONS, IMPORTANT RULES, and COMPLETION SIGNAL sections.**

## When to Use

- After editing task files in `tasks/`
- To regenerate prompts with updated template
- Before running `cpo run` if prompts are missing
- To test different prompt formats

## Input Requirements

The parallel directory must have:
```
parallel/TS-XXXX-slug/
  manifest.json       # Required: wave structure, agents
  context.md          # Required: shared context
  contracts/          # Required: types.py, api-schema.yaml
  tasks/              # Required: task-*.md files
    task-001-users.md
    task-002-products.md
```

## Output

Generates:
```
parallel/TS-XXXX-slug/
  prompts/
    agent-prompts.md   # Wave summary and launch commands
    task-001.txt       # Individual agent prompt
    task-002.txt
    ...
```

## Workflow

```mermaid
flowchart TB
    Start[("tasks/ folder")]
    Read["1. Read manifest.json"]
    Context["2. Load context.md"]
    Parse["3. Parse each task file"]
    Generate["4. Generate task-NNN.txt"]
    Summary["5. Create agent-prompts.md"]
    Done[("prompts/ ready")]

    Start --> Read
    Read --> Context
    Context --> Parse
    Parse --> Generate
    Generate --> Summary
    Summary --> Done
```

## Step 1: Read manifest.json

Extract:
- Wave structure and task ordering
- Agent assignments per task
- Tech spec reference
- Technology stack

## Step 2: Load context.md

The shared context is injected into every prompt for efficiency.

## Step 3: Parse Task Files

For each `tasks/task-NNN-*.md`:

1. **Extract YAML frontmatter**:
   ```yaml
   id: task-001
   component: users
   wave: 1
   deps: []
   agent: python-experts:django-expert
   contracts: [contracts/types.py, contracts/api-schema.yaml]
   ```

2. **Extract Markdown sections**:
   - `## Scope` -> CREATE, MODIFY, BOUNDARY
   - `## Requirements` -> Implementation requirements
   - `## Checklist` -> Acceptance criteria

3. **Resolve skills for each task**:
   - Read `parallel-agents/agent-skills-mapping.yaml` for agent-to-skills mapping
   - Look up the agent from task frontmatter (e.g., `python-experts:django-expert`)
   - Get the skills list for that agent
   - Format as full skill names: `plugin:skill-name`

Note: The Output Format section is **not** in task files. It's a **static template** that the prompt generator always includes in generated prompts.

## Step 4: Generate Individual Prompts

**CRITICAL: Copy content EXACTLY from task files. Do not summarize or rewrite.**

When generating prompts:
1. Include FULL context.md content (do not summarize - include every line)
2. COPY the ## Requirements section VERBATIM - every bullet point, every field name, every type
3. COPY the ## Checklist section VERBATIM - every item exactly as written
4. Match exact field names from contracts (e.g., use `principal_id` not `user_id`)

Create `prompts/task-NNN.txt` using this template:

```
TASK-{id}: {title}
Agent: {agent}
Wave: {wave}
Dependencies: {deps or "None"}

=== REQUIRED SKILLS ===
Before starting implementation, invoke these skills to load best practices:
{list of skills from agent-skills-mapping.yaml, formatted as bullets}

Invoke skills using: skill: "plugin:skill-name"

=== CONTEXT ===
{contents of context.md}

=== OBJECTIVE ===
{First line of task description or component name}

=== CONTRACTS ===
Reference these contract files before implementing:
{list of contract files with full paths}

=== FILES TO CREATE ===
{CREATE section from Scope}

=== FILES TO MODIFY ===
{MODIFY section from Scope}

=== DO NOT MODIFY ===
{BOUNDARY section from Scope}

=== IMPLEMENTATION REQUIREMENTS ===
{Requirements section content}

=== ACCEPTANCE CRITERIA ===
{Checklist section content}

=== EXECUTION INSTRUCTIONS ===

You MUST write code, not just describe it. Follow these steps:

1. **Read contracts first**: Read all files in contracts/ to understand interfaces
2. **Read existing code**: If modifying files, read them first
3. **Implement**: Use Write/Edit tools to create/modify code
4. **Test & Fix Loop**:
   - Run tests for your implementation
   - If ANY test fails, FIX the issue and rerun tests
   - REPEAT until ALL tests pass
   - Do NOT proceed to step 5 until tests pass
5. **Lint**: Run linters (ruff, mypy, eslint as appropriate)
6. **Commit**: Create atomic commit with conventional format (only after tests pass)

=== IMPORTANT RULES ===

- Do NOT ask for confirmation - proceed immediately with implementation
- Do NOT modify files listed in DO NOT MODIFY section
- Do NOT skip writing tests
- Do NOT deviate from contract interfaces
- Do NOT commit or signal completion until ALL tests pass
- If tests fail, you MUST fix the issues and keep running until they pass
- STOP if you encounter blocking issues and report in output

**CRITICAL - CONTRACTS ARE DESIGN DOCUMENTS:**
- Contracts in `parallel/` are DESIGN SPECIFICATIONS ONLY
- READ them to understand the interface you must implement
- RECREATE the types/interfaces in your actual project code
- NEVER import from `parallel/` directory
- NEVER use sys.path manipulation to access parallel/ files
- The `parallel/` directory is NOT part of the deployed codebase

=== COMPLETION SIGNAL ===

Upon successful completion (ALL tests passing), run: touch .claude-task-complete

CRITICAL: Only signal completion if:
- All tests pass (pytest exits with 0)
- All linting passes
- Code is committed
```

## Step 5: Create agent-prompts.md

Summary file with launch commands:

```markdown
# Agent Prompts for {name}

Generated: {timestamp}
Tech Spec: {tech_spec_id}
Total Tasks: {count}

## Wave Execution Order

### Wave 1 (Parallel)
| Task | Agent | Component |
|------|-------|-----------|
| task-001 | python-experts:django-expert | users |
| task-002 | python-experts:django-expert | products |

### Wave 2 (Parallel, depends on Wave 1)
| Task | Agent | Component |
|------|-------|-----------|
| task-003 | python-experts:django-expert | orders |

## Launch Commands

### Using cpo (Recommended)
```bash
cpo run parallel/{slug}/
```

### Manual Execution (Wave 1)
```bash
# Run in parallel terminals or with &
claude --prompt-file prompts/task-001.txt --agent python-experts:django-expert &
claude --prompt-file prompts/task-002.txt --agent python-experts:django-expert &
wait
```

### Manual Execution (Wave 2)
```bash
# After Wave 1 completes
claude --prompt-file prompts/task-003.txt --agent python-experts:django-expert
```

## Prompt Files

| File | Task | Lines |
|------|------|-------|
| prompts/task-001.txt | task-001-users | ~150 |
| prompts/task-002.txt | task-002-products | ~145 |
| prompts/task-003.txt | task-003-orders | ~160 |
```

## Validation Before Generation

Check these conditions:

- [ ] `manifest.json` exists and is valid JSON
- [ ] `context.md` exists
- [ ] `contracts/` directory exists with at least one file
- [ ] `tasks/` directory has at least one task file
- [ ] All tasks referenced in manifest exist in `tasks/`

## Error Handling

### Task Not in Manifest
```
WARNING: task-005-api.md exists but not in manifest.json
  -> Skipping prompt generation (add to manifest first)
```

### Missing Contract Reference
```
WARNING: task-001 references contracts/types.py but file doesn't exist
  -> Generate prompt with warning comment
```

## Regeneration Mode

When prompts already exist:

1. **Backup existing**: Move to `prompts.backup-{timestamp}/`
2. **Generate fresh**: Create new prompts from current tasks
3. **Report diff**: Show what changed

```bash
# Command triggers regeneration
/parallel-generate-prompts parallel/TS-0042-inventory/ --force
```

## Token Optimization

The generated prompts are optimized for token efficiency:

- Context is included once (not repeated per section)
- Contract paths reference files (agent reads them)
- Scope uses compact CREATE/MODIFY/BOUNDARY notation
- Checklist is actionable, not verbose

## Integration with cpo

The `cpo run` command expects:
1. `manifest.json` with wave structure
2. `prompts/task-NNN.txt` for each task in manifest

This skill ensures prompts match what `cpo` expects.

## Post-Generation Validation

After generating prompts, verify EACH prompt file contains:

```bash
# Quick validation - each prompt should have these markers
for f in prompts/task-*.txt; do
  echo "=== $f ==="
  grep -c "=== REQUIRED SKILLS ===" "$f" || echo "MISSING: REQUIRED SKILLS"
  grep -c "=== EXECUTION INSTRUCTIONS" "$f" || echo "MISSING: EXECUTION INSTRUCTIONS"
  grep -c "=== COMPLETION SIGNAL" "$f" || echo "MISSING: COMPLETION SIGNAL"
done
```

**If any prompt is missing these sections, regenerate it using the exact template from Step 4.**

Note: Output format and JSON summary blocks are managed via system prompt by the external execution tool, not included in generated prompts.

## Related Skills

| Skill | Relationship |
|-------|--------------|
| `parallel-decompose` | Creates tasks/ that this skill reads |
| `parallel-task-format` | Defines the task YAML format parsed here |
| `parallel-execution` | Consumes the prompts/ this skill generates |
| `parallel-agents` | Overall workflow context + agent-skills-mapping.yaml |

## Reference Files

- `parallel-agents/agent-skills-mapping.yaml` - Maps agents to their recommended skills
