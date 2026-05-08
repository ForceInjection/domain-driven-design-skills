---
name: scaffolding-reducer
description: Reduce heavy scaffolding by crystallizing repeated workflows into scripts, templates, or skills. Use when tasks require repeated manual steps or long prompt scaffolds.
---

# Scaffolding Reducer

Use this skill to convert repeated steps into a reusable script or template.

## Workflow

1) Capture repeated steps in a text file (one step per line).
2) Generate a script template from those steps.
3) Fill in the TODO blocks with real commands.

## Scripts

- Run: python scripts/crystallize.py --steps steps.txt --output scripts/my_flow.py --lang python

## Assets

- assets/script_template.py
- assets/script_template.ps1
