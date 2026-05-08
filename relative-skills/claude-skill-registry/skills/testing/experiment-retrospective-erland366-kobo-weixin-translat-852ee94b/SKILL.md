---
name: experiment-retrospective
description: >
  Turn experiment reports and notes into summaries and new/updated result skills.
metadata:
  short-description: "Summarize experiments and distill them into skills"
---

# Skill: experiment-retrospective

## When to use

Use this when:
- The user starts with `<retrospective>`, or
- Requests a summary/lessons-learned across one or more experiments.

## Behavior

1. **Select inputs**
   - Use the user's description to identify relevant:
     - `training_reports/*.md`
     - Sections of `references/experiment-log.md`
   - If ambiguous, list candidate reports and ask the user to choose.

2. **Summarize experiments**
   - For each report:
     - Extract: setup, hyperparameters, metrics, successes, failures.
   - Write a markdown summary with:
     - "What we tried"
     - "Key findings"
     - "What failed"
     - "Open questions"

3. **Update troubleshooting (if needed)**
   - If the experiments reveal new error patterns and their fixes:
     - Propose new rows for `references/troubleshooting.md`.
     - Ask the user for confirmation before editing the file.

4. **Propose or update skills**
   - Decide what **result skills** should reflect these findings.
   - For each skill:
     - If new: start from `templates/skills/result-skill-template.md`.
     - If existing: identify which sections to update.
   - Draft SKILL.md content that includes:
     - General description, context, results summary, recommended practice,
       failure modes, and explicit guidance for future Codex usage.
   - Use the user's description to fill in names, summaries, and assumptions,
     then remove any template sections that do not apply.

5. **Ask before writing**
   - Present the proposed skill changes.
   - Only create or modify files under `.codex/skills/` with user approval.

6. **Optional**
   - Append a summarized retrospective entry to `references/experiment-log.md`
     (e.g. "2025-12-26 – Retrospective on IMDb+Amazon mixture experiments").
   - Include a short "General description" line when logging.
