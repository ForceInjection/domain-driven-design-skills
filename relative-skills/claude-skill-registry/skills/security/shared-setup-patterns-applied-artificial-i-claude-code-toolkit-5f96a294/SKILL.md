---
name: shared-setup-patterns
description: Shared configuration patterns for project setup commands. Provides security hooks, Claude framework structure templates, and framework detection patterns used across multiple setup commands.
---

# Shared Setup Patterns

**Purpose**: Common configuration patterns and templates shared across all project setup commands.

**Used by**: `/setup:python`, `/setup:javascript`, `/setup:existing`, `/setup:explore`, `/setup:user`

**Token Impact**: Provides ~1,700 tokens of shared templates loaded once, avoiding duplication across 5+ commands (saves ~3,200 tokens through reuse).

---

## Contents

This skill contains ONLY patterns shared by multiple setup commands:

1. **Security Hooks** - PreToolUse and PostToolUse hooks for all project types
2. **Claude Framework Structure** - .claude/ directory templates and memory files
3. **Framework Detection** - Patterns for auto-detecting project languages and frameworks

Language-specific templates (Python, JavaScript, etc.) are kept inline in their respective commands.

---

## 1. Security Hooks

Located: `templates/security_hooks.json`

Comprehensive security and quality hooks configuration:
- **PreToolUse**: Blocks dangerous commands (rm -rf, sudo, chmod 777)
- **PostToolUse**: Auto-formats code (ruff, prettier, eslint), validates JSON/markdown

Used by: ALL setup commands that create projects

---

## 2. Claude Framework Structure

Located: `templates/claude_framework/`

Templates for .claude/ directory structure:
- `structure.md` - Directory layout and purpose
- `memory_templates/` - project_state.md, dependencies.md, conventions.md, decisions.md
- `work_structure.md` - Work directory organization

Used by: ALL setup commands

---

## 3. Framework Detection Patterns

Located: `templates/framework_detection.md`

Patterns for auto-detecting:
- Languages: Python, JavaScript/TypeScript, Go, Rust
- Frameworks: FastAPI, Django, Flask, Next.js, React, Express
- Tools: pytest, Jest, Mocha, go test, cargo test

Used by: `/setup:existing`, `/setup` (if dispatcher exists)

---

## Usage Pattern

Commands reference this skill in frontmatter:
```yaml
skills: [shared-setup-patterns]
```

Then access specific templates:
- Security hooks: Load from `templates/security_hooks.json`
- Framework structure: Generate from `templates/claude_framework/` templates
- Detection: Use patterns from `templates/framework_detection.md`

---

## Design Principle

**Only truly shared content lives here.** Language-specific templates (Python pyproject.toml, JavaScript package.json) stay inline in their respective commands to avoid skill overhead for single-use templates.

This keeps each command self-contained while sharing common infrastructure patterns.
