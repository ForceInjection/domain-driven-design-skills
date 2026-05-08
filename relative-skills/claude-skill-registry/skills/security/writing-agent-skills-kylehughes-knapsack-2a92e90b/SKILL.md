---
name: writing-agent-skills
description: Author and structure effective Agent Skills. Use when creating new skills, refining existing ones, or auditing skill structure and best practices.
---

# Writing Agent Skills

## Instructions

Follow these steps to create high-quality Agent Skills that Claude can discover and use effectively.

1.  **Define the Scope**: Identify the specific domain capability (e.g., "analyzing logs", "formatting dates").
2.  **Create the Directory**: Use a **gerund-based** name (verb + -ing) for the directory (e.g., `analyzing-logs`).
3.  **Create `SKILL.md`**: This is the entry point. It must contain YAML frontmatter.
4.  **Implement Progressive Disclosure**:
    *   Keep `SKILL.md` concise (under 500 lines).
    *   Move detailed reference material, extensive examples, or secondary workflows into separate files (e.g., `REFERENCE.md`, `forms/GUIDE.md`).
    *   Reference these files clearly in `SKILL.md` so Claude knows when to read them.
5.  **Add Utility Scripts (Optional)**:
    *   For deterministic logic, use scripts (Python/Bash) instead of text instructions.
    *   Ensure scripts handle errors explicitly; do not "punt" failures back to the agent without context.

## Critical: Naming & Discovery

Your skill's **name** and **description** determine whether an agent will ever use it. If these are vague, the agent will ignore your skill completely.

### YAML Frontmatter
Every `SKILL.md` must start with:
```yaml
---
name: your-skill-name
description: Brief description of what this Skill does and when to use it
---
```

### Naming Conventions
Use consistent naming patterns to make Skills discoverable.
*   **Format**: Lowercase letters, numbers, and hyphens only (max 64 chars).
*   **Pattern**: Use **gerunds** (verb + -ing) to describe the activity.

| Category | Examples | Status |
| :--- | :--- | :--- |
| **Good (Gerunds)** | `processing-pdfs`, `analyzing-spreadsheets`, `writing-documentation` | ✅ **Preferred** |
| **Acceptable** | `pdf-processing`, `analyze-spreadsheets` | ⚠️ OK |
| **Avoid** | `helper`, `utils`, `my-tools`, `anthropic-helper` | ❌ **Stop** |

### Writing Effective Descriptions
The `description` field is the **only** signal Claude uses to select your skill from 100+ options.

*   **Requirement**: Write in **third person**.
*   **Structure**: State **WHAT** it does + **WHEN** to use it.
*   **Keywords**: Include specific triggers (e.g., ".xlsx", "git diff").

#### Examples
*   **PDF Processing**: "Extract text and tables from PDF files. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
*   **Excel Analysis**: "Analyze Excel spreadsheets and generate charts. Use when analyzing Excel files, tabular data, or .xlsx files."
*   **Git Helper**: "Generate commit messages by analyzing git diffs. Use when the user asks for help writing commit messages."

## Best Practices Summary

*   **Conciseness**: Only add context Claude doesn't already have.
*   **One-Level Deep References**: Link directly from `SKILL.md` to reference files. Avoid nested links (A -> B -> C).
*   **File Paths**: Always use forward slashes (`scripts/run.py`), even on Windows.
*   **Evaluation**: Create test cases (evals) *before* writing extensive documentation to ensure the skill solves real problems.

## Checklist

Copy this checklist to verify your skill before finishing:

- [ ] **Name**: follows gerund pattern, lowercase/hyphens only.
- [ ] **Description**: written in 3rd person, includes specific trigger keywords.
- [ ] **Content**: `SKILL.md` is <500 lines; deep details are in `REFERENCE.md` or similar.
- [ ] **Paths**: All file paths use forward slashes (`/`).
- [ ] **Scripts**: Dependencies are listed; scripts handle errors gracefully.
- [ ] **Safety**: No hardcoded secrets or time-sensitive info (unless marked as legacy).

## Detailed Guidance

For deep dives on authoring patterns, anti-patterns, and examples, see [REFERENCE.md](REFERENCE.md).
