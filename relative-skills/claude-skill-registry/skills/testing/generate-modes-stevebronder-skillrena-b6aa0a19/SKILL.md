---
name: generate-modes
description: Generates three project-specific behavioral mode skills (planner, debugger, qa-tester) from project memories and bundled templates, and makes them selectable via switching-modes. Use when creating project-local agent modes for a repository.
---

# Generate modes

## Goal

Create three **project-specific, behavioral** mode skills under `./.{AGENT_NAME}/skills/`:

* `{slug}-mode-planner`
* `{slug}-mode-debugger`
* `{slug}-mode-qa-tester`

Each mode must:

1. Always state **acceptance criteria** and **how to verify locally**.
2. Never change or weaken existing tests without explicit approval.
3. When drafting skills, follow the Agent Skills spec (valid frontmatter; keep `SKILL.md` under ~500 lines; use progressive disclosure).

The modes must be written so they do **not** reference any specific benchmark, puzzle set, or domain-specific toy terms. They must read as general-purpose operating procedures.

For concrete “golden” examples of what the generated mode `SKILL.md` files should look like after adaptation, see `references/examples.md`.

## Quick start

1. **Activate memories**
   - Run `$activating-memories`.
   - Ensure baseline memory skills exist under `./.{AGENT_NAME}/skills/memories/`
   - If memories are missing or stale, update them before generating modes.

2. **Choose a project slug**
   - Prefer a slug stated in `project_overview`.
   - Otherwise derive from the repository folder name.
   - Slug rules: lowercase, digits, hyphens; no leading/trailing hyphen; no consecutive hyphens.
   - **Length rule (spec compliance):** generated skill `name` must be ≤ 64 chars and match its directory name.
     - Longest suffix is `-mode-qa-tester` (15 chars), so `{slug}` must be **≤ 49 chars**.

3. **Read the bundled templates**
   - Read:
     - `assets/planner-template.md`
     - `assets/debugger-template.md`
     - `assets/qa-tester-template.md`

4. **Generate three mode skills**
   For each template:
   - Adapt it to the project by adding:
     - the `{slug}` mode name
     - links to relevant memories (do not paste memory contents)
     - project-specific verification commands (link to `suggested_commands-skl` for the canonical list)
   - Write the resulting skill to:
     - `./.{AGENT_NAME}/skills/{slug}-mode-planner/SKILL.md`
     - `./.{AGENT_NAME}/skills/{slug}-mode-debugger/SKILL.md`
     - `./.{AGENT_NAME}/skills/{slug}-mode-qa-tester/SKILL.md`

5. **Make the modes selectable via `$switching-modes`**
   - If `./.{AGENT_NAME}/skills/switching-modes/` exists, update its mode registry to include the three new modes.
     - Prefer editing an explicit “Mode registry” list in `./.{AGENT_NAME}/skills/switching-modes/SKILL.md` (if present).
   - If it does not exist, create a **project-local** `./.{AGENT_NAME}/skills/switching-modes/SKILL.md` that:
     - writes `./.{AGENT_NAME}/state.json` with `{ "mode": "<mode-name>" }`
     - documents both baseline modes (if used) and the three new project modes
     - start from `assets/switching-modes-stub.md` to avoid bikeshedding
   - After this, switching is done by running:
     - `$switching-modes {slug}-mode-planner`
     - `$switching-modes {slug}-mode-debugger`
     - `$switching-modes {slug}-mode-qa-tester`

6. **Validate the generated skills**
   - Minimum manual checks:
     - Each generated directory name exactly matches its SKILL frontmatter `name`.
     - Each generated `description` is third-person and includes “Use when …”.
   - Optional (if available): run `skills-ref validate` on each generated skill directory.

## Required structure of each generated mode skill

Each mode skill must be a valid Agent Skill.

### Frontmatter

Example for planner:

```yaml
---
name: {slug}-mode-planner
description: Behavioral mode for planning and design work in {slug}. Use when scoping changes, producing design docs, or deciding between approaches.
---
```

### Body

Include these sections (in any order):

* **When to use** (triggers)
* **Operating loop** (the step-by-step behavior)
* **Question protocol** (how to ask questions; allow questions in all modes)
* **Output discipline** (acceptance criteria + local verification; test-change guardrail)
* **Project context pointers** (links to memories)

Keep the body concise. If the mode needs lengthy reference material, create `references/` files and link them.

## Adaptation rules

When adapting templates:

* Prefer links to memories, e.g. `../memories/project_overview-skl/SKILL.md`, not copy/paste.
* Use the project’s terminology: module names, CLI names, test runner names, etc.
* Avoid generic fluff. Encode actionable guardrails, checks, and concrete steps.
* Ensure the mode is usable standalone by a future agent who has access to the memories.

## Failure modes and how to handle them

* **Unknown `{AGENT_NAME}`**: infer from the local agent folder present (e.g. `.claude`, `.codex`). If none exist, ask the user what agent folder to use.
* **Mode name collisions**: if a target directory already exists, do not overwrite silently. Either append a suffix (e.g. `-v2`) or ask the user which to keep.
* **No reliable test commands**: link to `suggested_commands-skl` and ask the user to confirm the correct test command(s) if missing.
