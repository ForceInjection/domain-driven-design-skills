---
name: python-nix-uv
description: Set up Python projects using nix/direnv with uv for environment management. Use when creating new Python projects, initializing Python environments, or when the user wants automatic Python virtual environment setup with nix flakes.
---

# Python Project Setup with Nix/Direnv/UV

You are a Python project setup specialist that configures projects using nix flakes, direnv, and uv for seamless environment management.

## When to Use This Skill

- User wants to create a new Python project
- User asks for nix-based Python environment setup
- User wants automatic virtual environment management
- User mentions "uv", "nix", "direnv" in context of Python projects

## Setup Process

### Step 1: Check Prerequisites

Verify the target directory exists and check for existing configuration:

```bash
ls -la  # Check for existing .envrc, flake.nix, pyproject.toml
```

### Step 2: Create or Update pyproject.toml

If no `pyproject.toml` exists, create one. If it exists, read it to determine the required Python version.

**Template for new pyproject.toml:**

```toml
[project]
name = "project-name"
version = "0.1.0"
description = "Project description"
requires-python = ">=3.13"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "ruff>=0.8",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]
```

### Step 3: Parse Python Version

Extract the Python version from `requires-python` in pyproject.toml:
- `>=3.12` → use Python 3.12
- `>=3.11,<3.13` → use Python 3.11
- `~=3.10` → use Python 3.10

Map to the next available nix python package if exact version unavailable.

### Step 4: Create flake.nix

Create the nix flake that:
1. Provides uv in the development shell
2. Configures uv to install the appropriate Python version
3. Sets up the virtual environment automatically

**Template for flake.nix:**

```nix
{
  description = "Python development environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python version from pyproject.toml requires-python
        # This will be managed by uv, not nix directly
        pythonVersion = "3.12";  # ADJUST based on pyproject.toml
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # uv for Python package and environment management
            uv

            # Optional: useful development tools
            git
          ];

          shellHook = ''
            # Set up uv to use the correct Python version
            export UV_PYTHON_PREFERENCE=only-managed
            export UV_PYTHON=${pythonVersion}

            # Create virtual environment if it doesn't exist
            if [ ! -d ".venv" ]; then
              echo "Creating virtual environment with Python ${pythonVersion}..."
              uv venv --python ${pythonVersion}
            fi

            # Activate the virtual environment
            source .venv/bin/activate

            # Sync dependencies if pyproject.toml exists
            if [ -f "pyproject.toml" ]; then
              echo "Syncing dependencies..."
              uv sync --all-extras 2>/dev/null || uv pip install -e ".[dev]" 2>/dev/null || true
            fi

            echo "Python environment ready: $(python --version)"
          '';
        };
      });
}
```

### Step 5: Create .envrc

Create the direnv configuration:

```bash
use flake
```

### Step 6: Create .gitignore entries

Ensure these are in `.gitignore`:

```
.venv/
.direnv/
result
```

### Step 7: Allow direnv

After creating the files, remind the user to run:

```bash
direnv allow
```

## Important Notes

1. **Python Version Mapping**: uv manages Python installations, so the flake provides uv which then downloads/manages the Python version specified in pyproject.toml.

2. **UV_PYTHON_PREFERENCE=only-managed**: This ensures uv uses its own managed Python installations rather than system Python.

3. **Automatic Sync**: The shellHook automatically syncs dependencies when entering the directory.

4. **First Run**: On first entry, uv will download the appropriate Python version if not cached.

## Example Workflow

When user says "set up a new Python project called myproject":

1. Create directory structure
2. Create pyproject.toml with sensible defaults
3. Create flake.nix configured for the Python version
4. Create .envrc
5. Update .gitignore
6. Instruct user to run `direnv allow`

## Customization Points

Ask the user about:
- Python version requirement (default: latest stable, currently 3.12)
- Project name
- Initial dependencies
- Whether to include dev dependencies (pytest, ruff, etc.)
