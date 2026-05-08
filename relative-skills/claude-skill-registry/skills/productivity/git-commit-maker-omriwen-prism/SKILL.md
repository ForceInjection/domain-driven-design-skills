---
name: git-commit-maker
description: Create well-formatted git commit messages following conventional commits standard. This skill should be used after completing coding tasks to create clear, descriptive commit messages that accurately reflect changes.
---

# Git Commit Maker

Create clear, conventional commit messages that accurately describe changes and follow best practices.

## Purpose

Good commit messages are essential for project history and collaboration. This skill ensures commits follow the Conventional Commits standard and accurately describe the "why" behind changes.

## When to Use

Use this skill when:
- Completing a refactoring step (50+ commits during PRISM refactoring)
- Need to create descriptive commit messages
- Following conventional commits standard
- Working in a team requiring consistent commit format

## Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring without changing functionality
- `perf`: Performance improvement
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build, etc.)
- `style`: Code formatting (no logic changes)
- `ci`: CI/CD configuration changes

### Examples

```bash
# Feature
git commit -m "feat(models): add ProgressiveDecoder with automatic cropping"

# Refactoring
git commit -m "refactor(optics): extract Telescope class to core/telescope.py"

# Performance
git commit -m "perf(transforms): vectorize FFT operations for 20% speedup"

# Documentation
git commit -m "docs(api): add comprehensive docstrings to telescope module"

# Bug fix
git commit -m "fix(telescope): correct mask centering calculation"

# Tests
git commit -m "test: add unit tests for telescope module"

# Chore
git commit -m "chore: remove dead code and commented blocks"
```

## Writing Good Descriptions

### Be Specific

```bash
# Bad - vague
git commit -m "fix: update code"

# Good - specific
git commit -m "fix(telescope): correct aperture radius calculation for non-circular masks"
```

### Focus on Why, Not What

```bash
# Okay - describes what
git commit -m "refactor: split models.py into three files"

# Better - explains why
git commit -m "refactor(models): split into networks/losses/layers for better organization"
```

### Use Imperative Mood

```bash
# Bad - past tense
git commit -m "Added type hints"
git commit -m "Fixed the bug"

# Good - imperative mood (command form)
git commit -m "Add type hints to telescope module"
git commit -m "Fix mask centering bug"
```

## Multi-Line Commits

For complex changes, add a body:

```bash
git commit -m "$(cat <<'EOF'
refactor(optics): extract Grid class to core/grid.py

Extract Grid class from monolithic optics.py to improve module organization.
This is part of Phase 2 restructuring to create proper package hierarchy.

Changes:
- Create prism/core/grid.py with Grid class
- Update imports in optics.py
- Add Grid export to core/__init__.py
- Update tests to import from new location

Related to REFACTORING_PLAN.md Phase 2, Step 2.2
EOF
)"
```

## Scopes for PRISM Project

Common scopes during refactoring:

- `core`: Core modules (telescope, grid, propagators)
- `models`: Neural network models
- `utils`: Utility functions
- `config`: Configuration system
- `viz`: Visualization
- `tests`: Test code
- `ci`: CI/CD configuration
- `deps`: Dependencies

## Commit Workflow

### Step 1: Review Changes

```bash
# See what changed
git status
git diff

# Review staged changes
git diff --staged
```

### Step 2: Stage Changes

```bash
# Stage specific files
git add prism/core/telescope.py
git add prism/core/__init__.py

# Stage all changes (use cautiously)
git add .

# Interactive staging
git add -p
```

### Step 3: Write Commit Message

Analyze the changes and determine:
- Type (feat, refactor, fix, etc.)
- Scope (which module/component)
- Description (what and why)
- Need for body/footer

### Step 4: Create Commit

```bash
# Simple commit
git commit -m "refactor(optics): extract Telescope class to core/telescope.py"

# With body (use heredoc for proper formatting)
git commit -m "$(cat <<'EOF'
refactor(models): split into networks, losses, and layers modules

Split monolithic models.py into focused modules:
- prism/models/networks.py: ProgressiveDecoder
- prism/models/losses.py: LossAgg
- prism/models/layers.py: CBatchNorm, ComplexAct, CropPad

Improves code organization and maintainability.
EOF
)"
```

## Special Cases

### Breaking Changes

Use `!` and `BREAKING CHANGE:` footer:

```bash
git commit -m "$(cat <<'EOF'
refactor(config)!: replace argparse with dataclass configuration

BREAKING CHANGE: Command-line arguments have changed.
Use YAML config files instead of CLI args.
See configs/default.yaml for examples.

Migration guide in docs/MIGRATION.md
EOF
)"
```

### Referencing Issues

```bash
git commit -m "fix(telescope): correct SNR calculation

Fixes #42
```

### Co-authors

For pair programming or AI-assisted code:

```bash
git commit -m "$(cat <<'EOF'
feat(visualization): add publication-quality plotting

Add matplotlib publication style with LaTeX support.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Amending Commits

If commit message needs correction:

```bash
# Amend last commit message
git commit --amend -m "refactor(optics): extract Telescope class to core/telescope.py"

# Amend and add more changes
git add forgotten_file.py
git commit --amend --no-edit
```

**Warning**: Only amend commits that haven't been pushed!

## Validation

Good commit checklist:
- [ ] Follows conventional commits format
- [ ] Type is accurate (feat/fix/refactor/etc.)
- [ ] Scope is specific and clear
- [ ] Description is concise (< 72 characters)
- [ ] Uses imperative mood ("Add" not "Added")
- [ ] Focuses on why, not just what
- [ ] Breaking changes properly marked
- [ ] Related issues referenced if applicable

## Common Patterns for Refactoring

```bash
# Phase 1: Cleanup
chore: remove dead code and commented blocks
docs: add module documentation and architecture notes

# Phase 2: Restructuring
refactor(optics): extract Grid class to core/grid.py
refactor(models): split into networks, losses, and layers modules
feat(config): add dataclass-based configuration system

# Phase 3: Quality
refactor: add type hints to telescope module
docs: add comprehensive docstrings using NumPy style
refactor: standardize variable naming conventions

# Phase 4: Performance
perf: vectorize telescope sampling operations
perf(memory): fix matplotlib figure leaks
perf: add caching for expensive FFT operations

# Phase 5: Visualization
feat(viz): add publication-quality plotting
feat(output): add structured experiment output management

# Phase 6: Testing
test: add unit tests for telescope module
ci: add GitHub Actions workflow
test: add integration tests for training pipeline
```
