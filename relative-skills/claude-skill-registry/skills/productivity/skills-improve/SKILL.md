---
name: skills-improve
description: Capture and apply continuous improvements to Codex CLI skills during regular work. Use when a user wants to refine a skill, add a new skill after repeating a workflow, or keep skills up to date based on recent tasks.
---

# Skills Improve

## Overview

Turn day-to-day Codex CLI usage into a continuous improvement loop for skills. This helps identify repetitive steps, update existing skills, or create new ones with minimal friction.

## Workflow

### 1. Capture the improvement

Ask for the smallest useful change:
- “What was repetitive or slow?”
- “Which step should be automated or documented?”
- “Is this a new skill or an update to an existing one?”

### 2. Decide the action

Pick one path:

- **Update existing skill**: adjust SKILL.md, add scripts, or prune redundancy.
- **Create new skill**: use the skill-creator workflow and write a lean SKILL.md.

### 3. Implement the change

Apply edits in the skills repo, validate new skills, and keep instructions concise. If you add a new skill, update `README.md`:
- Add it to the **Available skills** table.
- Add a short **Example prompts** line using `$skill-name`.

### 4. Validate

- Run `quick_validate.py` for new or renamed skills.
- Remove redundant examples, outdated references, or unused scripts/assets.

### 5. Sync and verify

If the user wants it live immediately:
- Run `scripts/sync-skills.sh` to update `~/.codex/skills`.
- Restart Codex CLI to pick up new metadata.

## Example prompts

```
$skills-improve Turn my last task into a reusable skill.
$skills-improve Update the existing git-commit skill with new checks.
$skills-improve I keep repeating this workflow—make it a skill.
```
