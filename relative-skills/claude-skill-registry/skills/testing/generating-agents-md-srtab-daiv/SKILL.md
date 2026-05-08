---
name: generating-agents-md
description: Generates or updates an AGENTS.md file by scanning a repository for structure, commands, tests, and conventions. Use when a user asks to create or improve `AGENTS.md` for a repository.
---

# Generating AGENTS.md templates

AGENTS.md is a dedicated, predictable place to store agent-focused project context (project structure, commands, testing recipes, and conventions) that would clutter a human-oriented README. Prefer concrete, repo-derived facts over generic advice.

## Inputs you MUST use
You have access to all files in the repository. Use them.

Prioritize these sources (if present):
- `AGENTS.md` (existing), `README.md`, `CONTRIBUTING.md`, `docs/`
- Build/task runners: `Makefile`, `package.json` scripts, `justfile`, `tox.ini`, `noxfile.py`
- Tooling configs: `pyproject.toml`, `setup.cfg`, `.pre-commit-config.yaml`, `.editorconfig`
- CI: `.github/workflows/*`, `.gitlab-ci.yml`, `azure-pipelines.yml`, etc.
- Release docs: `CHANGELOG.md`, release scripts, tagging docs

## Output contract
Produce **one** Markdown document: the full contents of `AGENTS.md`.

- If an `AGENTS.md` already exists: preserve useful content, update stale parts, and keep the same intent/tone.
- If you cannot find evidence for a required detail, insert a single-line marker:
  `> TODO: <what’s missing and where to confirm it>`
- Do **not** invent commands, versions, paths, or policies.

## Authoring workflow (do this in order)
1. **Inventory & evidence**
   - Identify the project’s language(s), key frameworks, and tooling by reading configs.
   - Locate canonical commands (lint/format/test/type-check/build) from task files.
   - Identify where tests live and how CI runs them.

2. **Draft the outline**
   - Use the exact section order in “AGENTS.md template” below.
   - Keep it “medium”: enough to execute common work correctly, but not a full handbook.

3. **Fill from repo facts**
   - Prefer verbatim commands (copy exactly).
   - Reference files by relative paths (e.g., `pyproject.toml`, `mtrust/calls.py`).

4. **Plan-first compatibility (no interactive approvals)**
   - Do not write “ask first / require confirmation” directives.
   - Instead, encode risk as **plan-time requirements**, e.g.:
     - “When proposing a plan that changes public interfaces, call out breaking-change risk.”
     - “When changing dependencies, include rationale and impact in the plan.”

5. **Quality checks**
   - Ensure required sections are present (repo map, testing, conventions, dependency/tooling).
   - Ensure Markdown only (no HTML), and keep lines ≤ 100 chars where practical.
   - Ensure TODOs are minimal and actionable (point to where to look).

## AGENTS.md template (keep exact order)

### 1) `# AGENTS.md`
- One paragraph: what the repo is, what it does, and who this file is for (agents + devs).

### 2) `## Repository Structure`
- Show a top-level tree or bullet map of directories and key files.
- For each item: **one sentence** purpose.
- Only drill into subdirectories when they are critical entry points.

### 3) `## Build & Development Commands`
- Group commands under short headings (e.g., Lint/Format/Test/Type-check/Build).
- Use fenced `bash` blocks.
- Copy commands exactly as found (Makefile targets, scripts, etc.).
- If multiple equivalent ways exist, list the canonical one first and mention alternatives.

### 4) `## Dependency & Tooling Notes`
Include only what you can prove from the repo:
- Language/runtime versions supported (e.g., `python = ">=3.11"`).
- Framework versions/ranges when pinned or constrained.
- Key tooling (linters/formatters/test runners/type checkers) and where configured.

### 5) `## Code Style & Conventions`
- Formatting/linting rules at a high level (line length, import order, formatter).
- Naming conventions (modules, tests, settings).
- Used changelog conventions (if present).

### 6) `## Testing Recipes`
- Where tests live (paths), and how to run:
  - Full suite
  - A single file / a single test / keyword filtering (use the repo’s framework)
  - Coverage (if present)
- Note any rules for external calls:
  - If tests mock network/third-party APIs, state where fixtures/mocks live.
  - If unclear, add a TODO.

### 7) `## Maintenance Notes`
- A short list of what must be kept current as the repo changes:
  - Update this file when structure/commands/tooling change.
  - Update `CHANGELOG.md` per the present changelog conventions.

## Writing rules
- Be specific: prefer “pytest + pytest-django” over “run tests”.
- Avoid duplication with README; link/point to it when appropriate.
- No marketing language; focus on operational accuracy.
- Do not mention any tool-specific behavior (no references to Codex CLI, etc.).
