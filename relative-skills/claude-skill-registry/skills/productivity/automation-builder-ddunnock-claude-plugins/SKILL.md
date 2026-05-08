---
name: automation-builder
description: Analyze codebases and generate Claude Code automation infrastructure including commands, scripts, and templates for systematic task execution. Use when the user wants to create reusable automation workflows, generate .claude/commands files, create supporting bash/python scripts, build markdown templates for structured outputs, or establish multi-step task execution frameworks that work across projects.
---

# Automation Builder

Generate Claude Code automation infrastructure: commands (`.claude/commands/*.md`), scripts (`.claude/scripts/bash/*.sh`), and templates (`.claude/templates/*.md`).

## Workflow

```
Discovery → Design → Generate → Validate → Integrate
```

1. **Discovery**: Analyze codebase, gather requirements through questions
2. **Design**: Plan components needed (commands, scripts, templates)
3. **Generate**: Create the automation files
4. **Validate**: Test generated artifacts
5. **Integrate**: Set up handoffs between commands

## Discovery Phase

### Codebase Analysis

First, understand the project structure:

```bash
# Identify project type and existing automation
find . -name "package.json" -o -name "pyproject.toml" -o -name "Cargo.toml" 2>/dev/null | head -5
ls -la .claude/ 2>/dev/null || echo "No .claude directory"
find . -name "*.sh" -path "*/scripts/*" 2>/dev/null | head -10
```

Look for:
- Project type (monorepo, library, application)
- Existing `.claude/` structure
- Current automation patterns (Makefiles, scripts, CI configs)
- Technology stack and frameworks

### Requirements Questions

Ask these targeted questions based on what the user needs:

**Task Scope:**
- What workflow or task needs automation?
- Is this repeatable or one-time?
- What are the inputs and outputs?

**Execution Model:**
- Interactive (requires decisions) or fully automated?
- What validation is needed?
- How should errors be handled?

**Integration:**
- Should this connect to other commands via handoffs?
- Are there existing patterns to follow?
- Any compliance or standards requirements?

## Design Phase

### Component Selection

| Need | Component | Location |
|------|-----------|----------|
| Interactive workflow with decisions | Command | `.claude/commands/task.md` |
| Deterministic automation | Script | `.claude/scripts/bash/task.sh` |
| Structured output format | Template | `.claude/templates/output.md` |

### Architecture Patterns

**Command-First** (interactive): Command calls scripts, uses templates
**Script-First** (automation): Script generates output from templates  
**Hybrid** (orchestrated): Command coordinates multiple scripts with checkpoints

## Generate Phase

### Command Structure

Commands in `.claude/commands/*.md`:

```markdown
---
description: One-line description for command discovery
handoffs:
  - label: Next Step
    agent: target-command
    prompt: Context for handoff
---

## User Input

```text
$ARGUMENTS
```

[Parse user arguments here]

## Purpose

[What this command does and when to use it]

## Workflow

1. **Step Name**: Description
   - Decision points with outcomes
   
## Completion Criteria

- [ ] Success condition
```

See `references/command-patterns.md` for detailed examples.

### Script Structure

Scripts in `.claude/scripts/bash/*.sh`:

```bash
#!/usr/bin/env bash
# Description of what script does
#
# Usage: ./script.sh [OPTIONS] [ARGS]
#
# OPTIONS:
#   --json    Output JSON for command parsing
#   --help    Show help

set -e

# Parse arguments
JSON_MODE=false
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h) sed -n '2,/^[^#]/p' "$0" | sed 's/^# \?//'; exit 0 ;;
    esac
done

# Main logic here

# Output results
if $JSON_MODE; then
    echo '{"status":"success","data":{}}'
else
    echo "Results..."
fi
```

See `references/script-patterns.md` for detailed examples.

### Template Structure

Templates in `.claude/templates/*.md`:

```markdown
# Template Title

<!--
Purpose: What this template is for
Updated by: Which command/script populates this
-->

**Last Updated**: [TIMESTAMP]
**Status**: [STATUS]

---

## Section

| Field | Value |
|-------|-------|
| Item  | [PLACEHOLDER] |

<!-- Guidance for complex sections -->
```

See `references/template-patterns.md` for detailed examples.

## Validate Phase

After generating, validate:

1. **Command YAML**: Check frontmatter syntax
2. **Script syntax**: Run `bash -n script.sh` or `shellcheck script.sh`
3. **Cross-references**: Verify handoff targets exist
4. **Template placeholders**: Ensure consistency

## Integrate Phase

### Handoff Configuration

Connect commands in YAML frontmatter:

```yaml
handoffs:
  - label: "Continue"
    agent: next-command
    prompt: "Context message"
    send: true  # Auto-execute
```

### Script References

Reference scripts from commands:

```markdown
Run `.claude/scripts/bash/check.sh --json` from project root.

Parse response:
```json
{"status":"success|error","data":{}}
```
```

### Memory/State Files

For persistent state across command runs:

```
.claude/memory/
├── status.md      # Progress tracking
└── decisions.md   # Decision log
```

## Directory Layout

```
.claude/
├── commands/
│   ├── task.md
│   └── task-subtask.md
├── scripts/
│   ├── bash/
│   │   ├── common.sh
│   │   ├── setup-*.sh
│   │   └── check-*.sh
│   └── python/
│       └── helpers.py
├── templates/
│   └── *-template.md
└── memory/
    └── *.md
```

## Resources

### References

- `references/command-patterns.md` - Command authoring patterns
- `references/script-patterns.md` - Bash/Python script patterns
- `references/template-patterns.md` - Template design patterns

### Scripts

- `scripts/init-automation.sh` - Initialize .claude/ structure
- `scripts/validate-automation.sh` - Validate generated artifacts

### Assets

- `assets/command-template.md` - Starter command template
- `assets/script-template.sh` - Starter script template
- `assets/output-template.md` - Starter output template
