---
name: cli-creator
description: Create or extend Python command-line interfaces using Typer and wire them into pyproject.toml entry points. Use when asked to add a new CLI, add a subcommand, or expose a console script for a Python package, especially when pyproject.toml needs [project.scripts] updates or an empty directory needs full project initialization.
---

# Cli Creator

## Overview

Create a Python CLI module and expose it via pyproject.toml console scripts while matching existing project conventions.

## Workflow

### 0) Initialize an empty directory (only when no package exists)

- If the working directory is empty or lacks a Python package, bootstrap a new project:
  - Create a Python 3.13 virtual environment with uv (default).
  - Install Hatch in the venv.
  - Use Hatch to create an empty package; set the package name to the CLI name.
  - Ensure `pyproject.toml` is created by Hatch and reflects the package name.
- After initialization, continue with the workflow below.

Commands to run (replace `my-cli` with the desired name):

```bash
uv venv --python 3.13 .venv
source .venv/bin/activate
uv pip install hatch
hatch new my-cli
```

### 1) Inspect project layout

- Read `pyproject.toml` to detect packaging style ([project], [tool.poetry], [tool.hatch], existing scripts).
- Locate the package layout (`src/` vs flat) and any existing CLI modules or patterns.

### 2) Choose a CLI framework

- Use Typer. Reuse existing Typer patterns in the repo when present.

### 3) Gather command structure

- Ask for the top-level command name and at least one subcommand name.
- Prefer a concrete example command line (e.g., `atlas-trigger dataset list`) to infer subcommands and nesting.
- If the user only provides one subcommand, still structure the CLI with that subcommand.
- Ask whether the command handlers should delegate to another module for the "meat" of the logic.
- If the user wants delegation, import the target module inside the command function so `--help` remains fast.

### 4) Implement the CLI module

- Create a module under the package that defines a `main()` entry point (returning an exit code).
- Keep side effects out of module import; parsing and execution should happen in `main()`.
- For Typer, define `app = typer.Typer()` and invoke `app()` inside `main()` or use `typer.run(main)` for single-command CLIs.
- Implement the requested command(s) with dummy handlers that print `hello from <command>` using the full command path (e.g., `hello from atlas-trigger dataset list`).

### 5) Wire the console script

- For PEP 621 projects, add under `[project.scripts]`:
  - `my-cli = "package.module:main"`
- Preserve existing formatting, ordering, and naming conventions.

### 6) Validate behavior

- Ensure Typer is listed as a dependency in `pyproject.toml` (add it if missing).
- Add or update CLI tests to match existing patterns.
- Run a quick sanity check such as `python -m package --help` and the example command to verify the dummy output.

## Example Triggers

- "Create a new CLI called `acme` and add it to pyproject.toml."
- "Add a `status` subcommand to the existing CLI and wire it up."
- "Expose `package.cli:main` as a console script in this project."
