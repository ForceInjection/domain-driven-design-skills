---
name: repo-scaffold-skill
description: Create best-in-class repository scaffolds with modern tooling, security, CI/CD, testing, and documentation. Works for code, data science, ontologies, APIs, and CLI projects.
version: 1.0.0
license: CC-0
---

# repo-scaffold-skill

## Overview

Use this skill to scaffold and maintain production-ready repositories that follow modern best practices. This skill guides you through creating repositories with:

- **Security-first foundation**: Dependency scanning, secrets detection, vulnerability management
- **Automated quality gates**: Testing, linting, type checking, coverage enforcement
- **Exceptional developer experience**: One-command setup, pre-commit hooks, IDE configuration
- **Comprehensive documentation**: API docs, tutorials, troubleshooting guides
- **Observable systems**: Structured logging, performance benchmarking, monitoring

Applicable to: Python libraries, APIs, CLI tools, data science projects, ontologies, LinkML schemas, and web applications.

---

# Quick Start

When user says: **"Set up new repo in this folder"**

Execute this workflow:

1. **Assess project type**: Ask what kind of project (library, API, CLI, data science, ontology)
2. **Initialize repository structure**: Create foundational files and directories
3. **Configure tooling**: Set up uv, ruff, mypy, pytest, pre-commit
4. **Set up CI/CD**: Create GitHub Actions workflows
5. **Create documentation**: README, CONTRIBUTING, SECURITY, docs structure
6. **Initialize git**: Create repository with initial commit
7. **Configure GitHub**: Set up branch protection, security features (if requested)

---

# Principles

## Favored Copier Templates

For specific project types, prefer these blessed templates:

* **LinkML schemas**: https://github.com/linkml/linkml-project-copier
* **General code projects**: https://github.com/monarch-initiative/monarch-project-copier
* **Ontologies**: https://github.com/INCATools/ontology-development-kit (ODK framework)
* **AI integrations**: https://github.com/ai4curation/github-ai-integrations

Use these templates as starting points. This skill complements them with additional best practices.

## Modern Tooling Stack

### Python Development
* **Package management**: `uv` (fast, modern dependency resolver)
* **Linting & formatting**: `ruff` (replaces flake8, black, isort)
* **Type checking**: `mypy` in strict mode
* **Testing**: `pytest` with `pytest-cov` for coverage
* **Pre-commit**: Automated quality checks before commit

### Build Systems
* **Preferred**: `just` (for modern, readable task definitions)
* **Alternative**: `make` (for pipelines and compatibility)

### Documentation
* **Preferred**: `mkdocs` with Material theme (simple, beautiful)
* **Alternative**: `sphinx` (for legacy projects)
* **Framework**: Diátaxis (tutorials, how-to, reference, explanation)

### CLI Frameworks
* **Preferred**: `typer` (modern, type-based, beautiful output)
* **Alternative**: `click` (mature, widely used)
* **Output**: `rich` (colorful, formatted terminal output)

---

# Repository Scaffolding Workflow

## Step 1: Project Assessment

Ask these questions to understand project requirements:

### Project Type
- Library (reusable package for others)
- Application (deployable service/tool)
- CLI tool (command-line interface)
- API service (REST/GraphQL API)
- Data science project (analysis, ML models)
- Ontology (OWL/RDF knowledge representation)
- LinkML schema (data modeling)
- Documentation site only

### Technical Details
- Programming language (Python version if applicable)
- Target audience (developers, researchers, end-users)
- Deployment target (PyPI, Docker, cloud service, none)
- External dependencies (databases, APIs, services)
- Special requirements (performance, security, compliance)

### Team Context
- Solo developer or team
- Contribution model (open source, internal, private)
- Existing conventions or templates to follow

## Step 2: Initialize Structure

### Basic Directory Structure

**For Python Library:**
```
project-name/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── release.yml
│   │   └── security.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
├── docs/
│   ├── index.md
│   ├── tutorials/
│   ├── how-to/
│   ├── reference/
│   └── explanation/
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── cli.py (if CLI tool)
│       └── core.py
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── fixtures/
│   └── conftest.py
├── .gitignore
├── .pre-commit-config.yaml
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── justfile (or Makefile)
├── LICENSE
├── mkdocs.yml
├── pyproject.toml
├── README.md
├── SECURITY.md
└── uv.lock
```

**For Data Science Project:**
```
project-name/
├── .github/workflows/
├── data/              # Git-ignored
│   ├── raw/
│   ├── processed/
│   └── results/
├── notebooks/         # Exploratory analysis
├── src/
│   └── project_name/
│       ├── data/
│       ├── features/
│       ├── models/
│       └── visualization/
├── tests/
├── .dvc/             # If using DVC
├── pyproject.toml
└── README.md
```

**For API Service:**
```
project-name/
├── .github/workflows/
├── src/
│   └── project_name/
│       ├── api/
│       │   ├── routes/
│       │   └── dependencies.py
│       ├── core/
│       │   ├── config.py
│       │   └── security.py
│       ├── models/
│       ├── services/
│       └── main.py
├── tests/
├── docker-compose.yml
├── Dockerfile
└── pyproject.toml
```

## Step 3: Create Foundational Files

### pyproject.toml

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "project-name"
version = "0.1.0"
description = "Brief project description"
readme = "README.md"
requires-python = ">=3.9"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]
keywords = ["keyword1", "keyword2"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    # Runtime dependencies
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-xdist>=3.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
]
docs = [
    "mkdocs>=1.5.0",
    "mkdocs-material>=9.0.0",
    "mkdocstrings[python]>=0.24.0",
]

[project.scripts]
project-name = "project_name.cli:main"

[project.urls]
Homepage = "https://github.com/org/project-name"
Documentation = "https://project-name.readthedocs.io"
Repository = "https://github.com/org/project-name"
Issues = "https://github.com/org/project-name/issues"

[tool.ruff]
line-length = 88
target-version = "py311"
src = ["src"]

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "UP",   # pyupgrade
    "ARG",  # flake8-unused-arguments
    "SIM",  # flake8-simplify
    "S",    # flake8-bandit (security)
]
ignore = []

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101", "ARG"]  # Allow assert and unused args in tests

[tool.mypy]
strict = true
warn_unreachable = true
pretty = true
show_column_numbers = true
show_error_context = true
python_version = "3.11"

[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q --strict-markers --cov=src --cov-report=term-missing --cov-report=html"
testpaths = ["tests"]
markers = [
    "integration: marks tests as integration tests (deselect with '-m \"not integration\"')",
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
]

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/__pycache__/*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
]
```

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.14
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies:
          - types-requests
          - types-PyYAML

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-toml
      - id: check-merge-conflict
      - id: check-added-large-files
        args: [--maxkb=1000]
      - id: detect-private-key
      - id: check-case-conflict
      - id: mixed-line-ending
```

### justfile

```justfile
# List available commands
default:
    @just --list

# Install development environment
install:
    uv venv
    uv pip install -e ".[dev,docs]"
    pre-commit install
    @echo "✓ Setup complete! Run 'just test' to verify"

# Run all tests
test:
    pytest tests/ -v

# Run tests with coverage
test-cov:
    pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing
    @echo "Coverage report: htmlcov/index.html"

# Run only unit tests (fast)
test-unit:
    pytest tests/unit/ -v

# Run only integration tests
test-integration:
    pytest tests/integration/ -v -m integration

# Run linting
lint:
    ruff check .
    mypy src/

# Format code
format:
    ruff format .

# Fix linting issues
fix:
    ruff check --fix .
    ruff format .

# Run type checking
typecheck:
    mypy --strict src/

# Build documentation
docs:
    mkdocs serve

# Build documentation for deployment
docs-build:
    mkdocs build --strict

# Run all checks (simulate CI)
check: lint typecheck test-cov
    @echo "✓ All checks passed!"

# Clean build artifacts
clean:
    rm -rf build/ dist/ *.egg-info htmlcov/ .coverage .pytest_cache .mypy_cache .ruff_cache
    find . -type d -name __pycache__ -exec rm -rf {} +
    find . -type f -name "*.pyc" -delete

# Build package
build: clean
    uv pip install build
    python -m build

# Publish to PyPI (requires setup)
publish: build
    uv pip install twine
    twine upload dist/*

# Run security audit
security:
    uv pip install pip-audit bandit
    pip-audit
    bandit -r src/

# Update dependencies
update:
    uv pip compile pyproject.toml --upgrade
    pre-commit autoupdate
```

### .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Testing
.pytest_cache/
.coverage
.coverage.*
htmlcov/
.tox/
.nox/
coverage.xml
*.cover

# Type checking
.mypy_cache/
.dmypy.json
dmypy.json
.pytype/

# Ruff
.ruff_cache/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Documentation
site/
docs/_build/

# Data (for data science projects)
data/raw/
data/processed/
data/results/
*.csv
*.xlsx
*.parquet

# Models (for ML projects)
models/*.pkl
models/*.joblib
models/*.h5
models/*.pt

# Secrets
.env.local
.env.*.local
secrets/
*.key
*.pem

# Logs
logs/
*.log

# Temporary files
tmp/
temp/
*.tmp
```

## Step 4: Create Documentation Files

### README.md Template

```markdown
# Project Name

Brief description of what this project does (1-2 sentences).

[![CI](https://github.com/org/project-name/actions/workflows/ci.yml/badge.svg)](https://github.com/org/project-name/actions)
[![Coverage](https://codecov.io/gh/org/project-name/branch/main/graph/badge.svg)](https://codecov.io/gh/org/project-name)
[![PyPI](https://img.shields.io/pypi/v/project-name.svg)](https://pypi.org/project/project-name/)
[![Python Versions](https://img.shields.io/pypi/pyversions/project-name.svg)](https://pypi.org/project/project-name/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Features

* **Feature 1**: Specific description with metrics
* **Feature 2**: Concrete capability with example
* **Feature 3**: Technical detail with validation
* **Feature 4**: Performance characteristic with numbers

## Quick Start

### Installation

```bash
pip install project-name
```

### Basic Usage

```python
from project_name import main_function

result = main_function(arg1, arg2)
print(result)
```

### CLI Usage

```bash
project-name --help
project-name command --option value
```

## Documentation

Full documentation: https://project-name.readthedocs.io

* [Tutorials](docs/tutorials/) - Step-by-step guides
* [How-To Guides](docs/how-to/) - Task-oriented recipes
* [API Reference](docs/reference/) - Technical documentation
* [Architecture](docs/explanation/) - Design decisions

## Development

### Setup

```bash
git clone https://github.com/org/project-name.git
cd project-name
just install
```

### Running Tests

```bash
just test         # Run all tests
just test-cov     # Run tests with coverage
just lint         # Run linting and type checking
just check        # Run all checks (CI simulation)
```

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Citation

If you use this project in your research, please cite:

```bibtex
@software{project_name,
  title = {Project Name},
  author = {Your Name},
  year = {2025},
  url = {https://github.com/org/project-name}
}
```
```

### CONTRIBUTING.md Template

```markdown
# Contributing to Project Name

Thank you for your interest in contributing! This guide will help you get started.

## Development Setup

### Prerequisites

* Python 3.9 or higher
* git
* uv (recommended) or pip

### Setup Steps

1. Fork and clone the repository:
```bash
git clone https://github.com/your-username/project-name.git
cd project-name
```

2. Set up development environment:
```bash
just install
```

This will:
- Create a virtual environment
- Install all dependencies
- Set up pre-commit hooks
- Run initial tests

3. Verify setup:
```bash
just check
```

## Development Workflow

### Creating a Branch

Always work on a feature branch:
```bash
git checkout -b feature/your-feature-name
```

Branch naming convention:
* `feature/description` - New features
* `fix/issue-123` - Bug fixes
* `docs/description` - Documentation changes
* `refactor/description` - Code refactoring

### Making Changes

1. Write code following our style guidelines (enforced by ruff)
2. Add tests for new functionality
3. Update documentation as needed
4. Run checks locally:
```bash
just lint      # Linting and type checking
just test      # Run tests
just check     # All checks
```

### Commit Messages

Use conventional commits format:
```
feat: add new feature
fix: resolve bug in module
docs: update API documentation
test: add tests for feature
refactor: improve code structure
chore: update dependencies
```

For breaking changes:
```
feat!: change API signature

BREAKING CHANGE: old_function() is now new_function()
```

### Running Tests

```bash
just test              # All tests
just test-unit         # Only unit tests (fast)
just test-integration  # Only integration tests
just test-cov          # Tests with coverage report
```

### Code Quality

Pre-commit hooks automatically run:
* Ruff (linting and formatting)
* Mypy (type checking)
* YAML/JSON validation
* Trailing whitespace removal
* Secrets detection

To run manually:
```bash
pre-commit run --all-files
```

## Pull Request Process

1. **Update your branch** with latest main:
```bash
git fetch origin
git rebase origin/main
```

2. **Push your changes**:
```bash
git push origin feature/your-feature-name
```

3. **Create Pull Request**:
   * Use descriptive title (conventional commits format)
   * Fill out PR template completely
   * Link related issues (Fixes #123)
   * Add screenshots for UI changes

4. **Address review comments**:
   * Make requested changes
   * Push updates to same branch
   * Respond to reviewers

5. **Merge**:
   * Squash commits if requested
   * Delete branch after merge

## Code Style Guidelines

### Python Style
* Follow PEP 8 (enforced by ruff)
* Line length: 88 characters
* Use type hints for all functions
* Write docstrings for public APIs

### Type Hints
```python
def function_name(arg1: str, arg2: int) -> bool:
    """Function docstring."""
    ...
```

### Docstrings
Use Google style:
```python
def calculate_total(items: list[Item], tax_rate: float = 0.08) -> float:
    """Calculate total price including tax.

    Args:
        items: List of items to calculate
        tax_rate: Tax rate as decimal (default: 0.08)

    Returns:
        Total price including tax

    Raises:
        ValueError: If tax_rate is negative

    Examples:
        >>> calculate_total([Item(10.0)], 0.08)
        10.8
    """
```

## Testing Guidelines

### Test Organization
* Unit tests: `tests/unit/`
* Integration tests: `tests/integration/`
* Test fixtures: `tests/fixtures/`

### Writing Tests
```python
import pytest
from project_name import function

def test_function_success():
    """Test function with valid input."""
    result = function("input")
    assert result == "expected"

def test_function_error():
    """Test function with invalid input."""
    with pytest.raises(ValueError):
        function("invalid")

@pytest.mark.integration
def test_integration():
    """Integration test requiring external service."""
    ...
```

### Coverage Requirements
* Minimum 80% coverage for all code
* 100% coverage for critical paths
* New code must not decrease coverage

## Documentation

### Adding Documentation
* Tutorials: `docs/tutorials/`
* How-to guides: `docs/how-to/`
* API reference: Auto-generated from docstrings
* Explanations: `docs/explanation/`

### Building Docs Locally
```bash
just docs  # Starts local server at http://localhost:8000
```

### Documentation Style
* Use clear, concise language
* Include code examples
* Add images/diagrams when helpful
* Link to related documentation

## Getting Help

* **Questions**: Open a [GitHub Discussion](https://github.com/org/project-name/discussions)
* **Bugs**: Open an [Issue](https://github.com/org/project-name/issues)
* **Security**: See [SECURITY.md](SECURITY.md)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
```

### SECURITY.md Template

```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: security@example.com

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include:
* Description of the vulnerability
* Steps to reproduce
* Potential impact
* Suggested fix (if any)

## Security Update Process

1. Vulnerability report received
2. Confirmation and assessment (within 48 hours)
3. Fix developed and tested
4. Security advisory published
5. Patch released
6. Users notified

## Security Best Practices

When using this project:
* Keep dependencies updated
* Use latest stable version
* Follow principle of least privilege
* Validate all inputs
* Use secrets management for credentials
```

### CHANGELOG.md Template

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [0.1.0] - 2025-01-18

### Added
- Initial release
- Core functionality
- Documentation
- Test suite
- CI/CD pipeline

[Unreleased]: https://github.com/org/project-name/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/org/project-name/releases/tag/v0.1.0
```

## Step 5: Set Up CI/CD

### .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Install dependencies
        run: |
          uv pip install --system ruff mypy

      - name: Run ruff
        run: ruff check .

      - name: Run ruff format check
        run: ruff format --check .

      - name: Run mypy
        run: mypy --strict src/

  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ["3.9", "3.10", "3.11", "3.12"]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Install dependencies
        run: |
          uv pip install --system -e ".[dev]"

      - name: Run tests
        run: |
          pytest tests/ -v --cov=src --cov-report=xml --cov-report=term-missing

      - name: Upload coverage to Codecov
        if: matrix.os == 'ubuntu-latest' && matrix.python-version == '3.11'
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
          fail_ci_if_error: true

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Install dependencies
        run: |
          uv pip install --system pip-audit bandit

      - name: Run pip-audit
        run: pip-audit --require-hashes --disable-pip
        continue-on-error: true

      - name: Run bandit
        run: bandit -r src/ -f json -o bandit-report.json
        continue-on-error: true

      - name: Upload bandit report
        uses: actions/upload-artifact@v3
        with:
          name: bandit-report
          path: bandit-report.json

  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Install dependencies
        run: |
          uv pip install --system -e ".[docs]"

      - name: Build documentation
        run: mkdocs build --strict

      - name: Upload docs artifact
        uses: actions/upload-artifact@v3
        with:
          name: documentation
          path: site/
```

### .github/workflows/release.yml

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install uv
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Install build
        run: uv pip install --system build

      - name: Build package
        run: python -m build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  pypi-publish:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: pypi
      url: https://pypi.org/p/project-name
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist/

      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1

  github-release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist/

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*
          generate_release_notes: true
```

### .github/dependabot.yml

```yaml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "maintainer-username"
    labels:
      - "dependencies"
      - "automated"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

## Step 6: Initialize Git Repository

```bash
# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "chore: initial project scaffold

- Set up project structure
- Configure modern tooling (uv, ruff, mypy, pytest)
- Add CI/CD workflows
- Create documentation structure
- Configure pre-commit hooks

Generated with repo-scaffold-skill
"

# Create main branch (if not already on main)
git branch -M main
```

## Step 7: GitHub Configuration (Optional)

If creating GitHub repository:

```bash
# Create GitHub repo
gh repo create org/project-name --public --source=. --description "Brief description"

# Push code
git push -u origin main

# Configure branch protection
gh api repos/org/project-name/branches/main/protection \
  --method PUT \
  --field required_status_checks[strict]=true \
  --field required_status_checks[contexts][]=lint \
  --field required_status_checks[contexts][]=test \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field enforce_admins=true \
  --field restrictions=null
```

Enable GitHub security features:
1. Go to Settings → Security & analysis
2. Enable:
   - Dependency graph
   - Dependabot alerts
   - Dependabot security updates
   - Secret scanning
   - Code scanning (CodeQL)

---

# Best Practices Reference

## Testing Strategy

### Testing Pyramid
* **Many unit tests**: Fast, isolated, deterministic
* **Fewer integration tests**: Test component interactions
* **Minimal end-to-end tests**: Slow but validate full workflows

### Coverage Requirements
* Minimum 80% line coverage
* 100% coverage for critical paths (validation, security, auth)
* Use `pytest-cov` with `--cov-report=term-missing` to identify gaps
* Set coverage ratchet: never allow coverage to decrease

### Test Organization
```python
# tests/unit/test_module.py
def test_function_success():
    """Test function with valid input."""
    result = function("valid")
    assert result == expected

def test_function_validation():
    """Test function validates input."""
    with pytest.raises(ValueError, match="Invalid input"):
        function("invalid")

# tests/integration/test_api.py
@pytest.mark.integration
def test_api_endpoint(client):
    """Test API endpoint integration."""
    response = client.get("/api/endpoint")
    assert response.status_code == 200
```

### Fixtures and Factories
```python
# tests/conftest.py
import pytest
from project_name import create_app

@pytest.fixture
def app():
    """Create application fixture."""
    app = create_app(testing=True)
    yield app

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()

# Use factories for complex objects
from polyfactory.factories.pydantic_factory import ModelFactory
from project_name.models import User

class UserFactory(ModelFactory[User]):
    __model__ = User

# In tests
def test_user_creation():
    user = UserFactory.build()
    assert user.email.endswith("@example.com")
```

## Security Best Practices

### Dependency Security
* Use Dependabot for automated updates
* Run `pip-audit` in CI for vulnerability scanning
* Review dependency licenses for compatibility
* Minimize dependencies to reduce attack surface

### Secrets Management
* Never commit secrets to git
* Use `.env` files (gitignored) with `python-dotenv`
* For CI/CD: GitHub Actions secrets
* For production: Vault, AWS Secrets Manager, etc.

### Code Security
* Validate all user inputs (use Pydantic)
* Use parameterized queries (prevent SQL injection)
* Avoid `os.system()` with user input (command injection)
* Set security headers for web apps (CSP, HSTS, X-Frame-Options)
* Run `bandit` for Python security linting

### Security Policy
* Create SECURITY.md with reporting process
* Respond to vulnerabilities within 48 hours
* Publish security advisories for fixes
* Notify users of critical updates

## Performance and Observability

### Profiling
```bash
# Profile script execution
python -m cProfile -o profile.stats script.py
python -m pstats profile.stats

# Sampling profiler (no code changes)
pip install py-spy
py-spy record -o profile.svg -- python script.py
```

### Benchmarking
```python
# tests/benchmark/test_performance.py
def test_performance(benchmark):
    """Benchmark expensive operation."""
    result = benchmark(expensive_function, arg1, arg2)
    assert result == expected

# Run benchmarks
pytest tests/benchmark/ --benchmark-only
```

### Structured Logging
```python
import structlog

logger = structlog.get_logger()

# Log with context
logger.info(
    "user_action",
    user_id=user.id,
    action="login",
    ip=request.ip,
    duration_ms=duration,
)
```

### Monitoring (Production)
* Health check endpoint: `/health`
* Metrics endpoint: `/metrics` (Prometheus format)
* Monitor: request rate, error rate, response time (p50, p95, p99)
* Set up alerting for critical failures

## Documentation Standards

### README Structure
1. **Brief description** (1-2 sentences)
2. **Badges** (CI, coverage, version, license)
3. **Features** (3-5 bullet points with specifics)
4. **Quick start** (installation + basic usage)
5. **Documentation link**
6. **Development setup**
7. **License and citation**

### Docstring Style (Google Format)
```python
def calculate(items: list[Item], rate: float = 0.08) -> float:
    """Calculate total with rate applied.

    Args:
        items: List of items to process
        rate: Rate to apply as decimal (default: 0.08)

    Returns:
        Calculated total

    Raises:
        ValueError: If rate is negative

    Examples:
        >>> calculate([Item(10.0)], 0.08)
        10.8
    """
```

### Documentation Site (Diátaxis)
* **Tutorials**: Step-by-step learning for beginners
* **How-to guides**: Task-oriented recipes for goals
* **Reference**: Technical API documentation (auto-generated)
* **Explanation**: Conceptual understanding and design

## Git and GitHub Workflow

### Branch Naming
* `feature/description` - New features
* `fix/issue-123` - Bug fixes
* `docs/description` - Documentation
* `refactor/description` - Code refactoring

### Conventional Commits
```
feat: add new feature
fix: resolve bug
docs: update documentation
test: add tests
refactor: improve code
chore: update tooling
perf: improve performance

# Breaking changes
feat!: change API

BREAKING CHANGE: Description of breaking change
```

### Branch Protection
Configure on main branch:
* Require PR reviews (minimum 1)
* Require status checks (lint, test, typecheck)
* Require branches up to date
* No direct pushes to main
* Require signed commits (optional)

### Pull Request Best Practices
* Keep PRs small (< 400 lines)
* One PR = one logical change
* Write descriptive title (conventional commits)
* Fill out PR template completely
* Link issues (Fixes #123)
* Respond to reviews promptly

## Code Quality Enforcement

### Pre-commit Hooks
Automatically run before each commit:
* Ruff (linting and formatting)
* Mypy (type checking)
* YAML/JSON validation
* Trailing whitespace removal
* Secrets detection
* Large file detection

### CI Quality Gates
All must pass before merge:
* Linting (ruff check)
* Formatting (ruff format --check)
* Type checking (mypy --strict)
* Tests (pytest with coverage)
* Security scanning (pip-audit, bandit)
* Documentation build (mkdocs build --strict)

### Coverage Ratchet
```yaml
# In CI
- name: Check coverage threshold
  run: pytest --cov=src --cov-fail-under=80
```

## Release Management

### Semantic Versioning
* **MAJOR**: Breaking changes (1.0.0 → 2.0.0)
* **MINOR**: New features, backwards compatible (1.0.0 → 1.1.0)
* **PATCH**: Bug fixes, backwards compatible (1.0.0 → 1.0.1)
* **Pre-release**: 1.0.0-alpha.1, 1.0.0-beta.1, 1.0.0-rc.1

### Release Process
1. Update version in `pyproject.toml`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. CI automatically builds and publishes to PyPI
6. GitHub release created with notes

### Changelog Format
Follow [Keep a Changelog](https://keepachangelog.com/):
* Added - new features
* Changed - changes to existing functionality
* Deprecated - soon-to-be removed features
* Removed - removed features
* Fixed - bug fixes
* Security - security fixes

---

# Framework-Specific Patterns

## FastAPI Projects

### Structure
```
src/project_name/
├── api/
│   ├── routes/
│   │   ├── users.py
│   │   └── items.py
│   ├── dependencies.py
│   └── middleware.py
├── core/
│   ├── config.py
│   └── security.py
├── models/
│   └── schemas.py
├── services/
│   └── user_service.py
└── main.py
```

### Best Practices
* Use Pydantic V2 for validation
* Health check endpoint: `/health`
* OpenAPI docs auto-generated
* Async by default, sync when needed
* Dependency injection for DB sessions
* Separate routes from business logic

### Example
```python
from fastapi import FastAPI, Depends
from pydantic import BaseModel

app = FastAPI(
    title="Project Name",
    description="API description",
    version="1.0.0",
)

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/api/v1/items")
async def list_items(
    skip: int = 0,
    limit: int = 100,
    service: ItemService = Depends(get_item_service),
):
    return await service.list_items(skip, limit)
```

## CLI Tools (Typer)

### Structure
```
src/project_name/
├── cli/
│   ├── main.py        # Typer app
│   ├── commands/
│   │   ├── init.py
│   │   └── run.py
│   └── utils.py
└── core/              # Business logic
```

### Best Practices
* Use Typer for beautiful CLIs
* Rich for colorful output
* Progress bars for long operations
* Config file support (YAML/TOML)
* Shell completion support

### Example
```python
import typer
from rich import print
from rich.progress import track

app = typer.Typer(
    name="project-name",
    help="CLI tool description",
)

@app.command()
def process(
    input_file: Path = typer.Argument(..., help="Input file"),
    output: Path = typer.Option(None, "--output", "-o"),
    verbose: bool = typer.Option(False, "--verbose", "-v"),
):
    """Process input file."""
    for item in track(items, description="Processing..."):
        # Process
        pass
    print("[green]✓ Done![/green]")

if __name__ == "__main__":
    app()
```

## Data Science Projects

### Structure
```
project/
├── data/              # Gitignored
│   ├── raw/
│   ├── processed/
│   └── results/
├── notebooks/         # Exploration
├── src/
│   └── project_name/
│       ├── data/      # Data loading
│       ├── features/  # Feature engineering
│       ├── models/    # Model definitions
│       └── viz/       # Visualization
└── tests/
```

### Best Practices
* DVC for data versioning
* Core logic in `src/`, not notebooks
* Strip notebook outputs before committing
* Document data sources and preprocessing
* Model registry (MLflow, W&B)
* Reproducible environments

### Tools
```toml
[project.optional-dependencies]
ml = [
    "pandas",
    "numpy",
    "scikit-learn",
    "matplotlib",
    "seaborn",
]
notebook = [
    "jupyter",
    "ipykernel",
]
```

---

# Troubleshooting

## Common Issues

### Tests Pass Locally, Fail in CI
**Causes**: Python version mismatch, environment differences

**Solutions**:
```bash
# Check Python version
python --version

# Test in clean environment
uv venv --python 3.11
source .venv/bin/activate
uv pip install -e ".[dev]"
pytest tests/
```

### Dependency Resolution Fails
**Causes**: Version conflicts, corrupted cache

**Solutions**:
```bash
# Clear cache
uv cache clean

# Check dependency tree
uv pip tree

# Verbose resolution
uv pip install -r requirements.txt -v
```

### Type Checking Errors
**Causes**: Missing type stubs, version mismatch

**Solutions**:
```bash
# Install type stubs
uv add --dev types-requests types-PyYAML

# Check with error codes
mypy --show-error-codes src/
```

### Slow Tests
**Diagnosis**:
```bash
pytest --durations=10
```

**Solutions**:
* Separate slow integration tests
* Use fixtures efficiently
* Mock external services
* Parallelize: `pytest -n auto`

### Import Errors
**Diagnosis**:
```bash
python -X importtime -c "import mymodule"
```

**Solutions**:
* Lazy import heavy dependencies
* Move imports inside functions
* Optimize module-level code

## Development Pitfalls

### Hardcoded Paths
❌ Don't: `open("/Users/me/file.txt")`
✅ Do: `Path(__file__).parent / "file.txt"`

### Not Testing Clean Environment
❌ Don't: Only test in your dev environment
✅ Do: Test in fresh virtualenv regularly

### Mixing Concerns in PRs
❌ Don't: One PR with bug fix + refactor + feature
✅ Do: Separate PRs for each concern

### Forgetting Documentation
❌ Don't: Update code without updating docs
✅ Do: Update README, docstrings, CHANGELOG together

---

# Migration Guide

## For Existing Projects

### Assessment Checklist
- [ ] README with description
- [ ] LICENSE file
- [ ] CONTRIBUTING.md
- [ ] Tests with >50% coverage
- [ ] CI/CD configured
- [ ] Type hints used
- [ ] Linting configured
- [ ] Dependencies documented
- [ ] Security scanning
- [ ] Branch protection
- [ ] Documentation site
- [ ] Pre-commit hooks

### Incremental Migration

**Week 1: Foundation**
1. Add missing docs (README, CONTRIBUTING, LICENSE)
2. Set up basic CI (tests, linting)
3. Enable GitHub security features

**Week 2: Code Quality**
1. Add pre-commit hooks
2. Configure ruff
3. Add type hints to new code

**Week 3: Testing**
1. Add coverage reporting
2. Write tests for critical paths
3. Separate unit/integration tests

**Week 4: Modernization**
1. Migrate to uv
2. Add mypy
3. Update dependencies

**Ongoing**:
* Increase coverage progressively
* Add type hints to existing code
* Refactor hot paths

### Tool Migrations

**pip → uv**:
```bash
uv init --lib
uv add $(cat requirements.txt)
```

**flake8/black → ruff**:
```bash
pip uninstall flake8 black isort
uv add --dev ruff
```

**setup.py → pyproject.toml**:
See pyproject.toml template above

---

# Installation Instructions

## Global Installation (All Projects)

Add to `~/.claude/CLAUDE.md`:

```markdown
## Repository Scaffolding

When I say "set up new repo in this folder" or similar phrases about creating a new repository:

1. Use the repo-scaffold-skill to guide repository creation
2. Ask about project type (library, API, CLI, data science, etc.)
3. Create appropriate directory structure and configuration files
4. Set up modern tooling (uv, ruff, mypy, pytest, pre-commit)
5. Create comprehensive documentation (README, CONTRIBUTING, SECURITY)
6. Configure CI/CD workflows
7. Initialize git repository with initial commit
8. Optionally help with GitHub setup and branch protection

The skill is located at: /path/to/repo-scaffold-skill/SKILL.md
```

## Project-Local Installation

For specific project, create `.claude/CLAUDE.md`:

```markdown
# Project-Specific Instructions

This project follows repo-scaffold-skill best practices.

## Development Commands
* `just install` - Set up development environment
* `just test` - Run tests
* `just check` - Run all checks (CI simulation)
* `just lint` - Run linting and type checking
* `just docs` - Serve documentation locally

## Repository Standards
* Minimum 80% test coverage
* All code must have type hints
* Use conventional commits
* Keep PRs < 400 lines
* Update CHANGELOG with each PR
```

---

# Skill Metadata

**Version**: 1.0.0
**Last Updated**: 2025-01-18
**Maintained By**: Your Organization
**License**: CC-0 (Public Domain)

**Changelog**:
* 1.0.0 (2025-01-18): Initial comprehensive skill release

**Contributing**:
To improve this skill, submit issues or PRs to the skill repository.
