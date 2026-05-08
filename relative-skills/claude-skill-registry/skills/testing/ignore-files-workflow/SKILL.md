---
name: ignore-files-workflow
description: Ignore file management for .gitignore, .dockerignore, and .specstory directories. Includes synchronization, alphabetical ordering, organization, best practices, and testing guidelines. Activate when working with .gitignore, .dockerignore, .specstory files, or managing version control and Docker build context.
---

# Ignore Files Workflow

**Auto-activate when:** Working with `.gitignore`, `.dockerignore`, `.specstory/`, or when user mentions ignore files, version control organization, or Docker build context.

Comprehensive guidelines for maintaining `.gitignore` and `.dockerignore` files with proper organization, synchronization, and best practices.

---

## Purpose

Maintain `.gitignore` and `.dockerignore` files to:
- Exclude unnecessary files from Git version control
- Reduce Docker build context and image sizes
- Prevent accidental commits of secrets and credentials
- Improve build performance
- Keep repositories clean and focused

---

## Quick Reference

### Key Principles
1. **Alphabetical ordering** - Within sections, sort entries alphabetically (case-sensitive)
2. **Section organization** - Use comments to group related patterns
3. **Synchronization** - Keep shared entries consistent between `.gitignore` and `.dockerignore`
4. **Specificity** - Use precise patterns, avoid overly broad rules
5. **Documentation** - Comment platform-specific or non-obvious patterns
6. **Consistency** - Review and maintain quarterly

### File Organization Structure
```
# Comment describing section
specific-entry/
pattern-*.ext
another-entry.xyz

# Next section
other-entry/
```

---

## Alphabetical Ordering Rules

- **All entries within sections must be in alphabetical order**
- Case-sensitive ordering: uppercase letters before lowercase (ASCII sorting)
- Special characters sorted by ASCII value
- Sections themselves can be organized logically
- Makes files easier to scan and prevents duplicate patterns

**Example:**
```
# Build artifacts (alphabetical)
build/
dist/
*.egg-info/

# IDEs (alphabetical)
.idea/
.vscode/
*.swp
```

---

## Synchronization Rules

### Entries in Both .gitignore and .dockerignore

These should appear in both files (keep in sync):

```
# Build artifacts
build/
dist/
*.egg-info/

# Python bytecode
__pycache__/
*.pyc
*.pyo

# Testing outputs
.coverage
.pytest_cache/
htmlcov/

# Environment files
.env
.env.*

# Virtual environments
.venv/
venv/

# Temporary files
tmp/
temp/
*.tmp

# Logs
*.log
logs/

# OS files
.DS_Store
Thumbs.db

# Type checking (Python)
.mypy_cache/
```

### Entries ONLY in .gitignore

```
# Dev dependencies (keep locally)
.venv/
venv/
ENV/

# IDE configuration (version control is optional)
.idea/
.vscode/
*.swp
*~

# Test coverage reports
htmlcov/
```

### Entries ONLY in .dockerignore

```
# Git metadata
.git/
.gitattributes
.gitignore

# Documentation (don't need in image)
*.md
docs/

# CI/CD pipelines
.github/
.gitlab-ci.yml
Jenkinsfile

# Development tools
.devcontainer/

# Testing (keep in git, exclude from Docker)
tests/
.spec/
*.test.js

# SpecStory artifacts
.specstory/
```

### Why Synchronization Matters
- **Consistency** - Reduced confusion across build environments
- **Maintenance** - Less duplicated pattern management
- **Security** - Same files excluded from both Git and Docker
- **Performance** - Aligned optimization rules

---

## .gitignore Best Practices

### What to Include ✅

**Build artifacts:**
- `build/`, `dist/`, `*.egg-info/`, `bin/`, `lib/`, `out/`

**Dependencies:**
- `node_modules/`, `.venv/`, `venv/`, `vendor/`, `packages/`

**Compiled code:**
- `*.pyc`, `*.pyo`, `__pycache__/`, `*.o`, `*.so`

**Test outputs:**
- `.pytest_cache/`, `.coverage`, `htmlcov/`, `.tox/`, `.nox/`

**Environment files:**
- `.env` (secrets), `.env.*` (except `.env.example`)

**Logs:**
- `*.log`, `logs/`

**OS files:**
- `.DS_Store`, `Thumbs.db`, `Desktop.ini`

**IDE files:**
- `.vscode/`, `.idea/`, `*.swp`, `*.swo`, `*~`

**Temporary files:**
- `tmp/`, `temp/`, `*.tmp`

### What NOT to Include ❌

**Source code:**
- Never ignore application code or tests

**Configuration templates:**
- `.env.example`, `config.example.yml` (provide examples)

**Project documentation:**
- `README.md`, `docs/`, `*.md` (unless auto-generated)

**Essential config:**
- `pyproject.toml`, `package.json`, `Dockerfile`

---

## .gitignore Complete Template

```gitignore
# Python
__pycache__/
*.egg-info/
*.py[cod]
*.pyo
*.so
.Python

# Distribution / packaging
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

# Virtual environments
.venv/
venv/
ENV/
env/

# Testing
.coverage
.nox/
.pytest_cache/
.tox/
htmlcov/

# Type checking
.dmypy.json
.mypy_cache/
.pytype/
dmypy.json

# Linting
.ruff_cache/

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# Environment
.env
.env.*
!.env.example

# IDEs
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Temporary
temp/
tmp/
*.tmp
```

---

## .dockerignore Best Practices

### What to Include ✅

**Version control:**
- `.git/`, `.gitignore`, `.gitattributes`

**Documentation:**
- `README.md`, `docs/`, `*.md` (not needed in image)

**CI/CD:**
- `.github/`, `.gitlab-ci.yml`, `Jenkinsfile`

**Development:**
- `.devcontainer/`, `.vscode/`, `.idea/`

**Testing:**
- `tests/`, `.spec/`, `.specstory/`, `*.test.js`

**Build artifacts:**
- `build/`, `dist/`, `node_modules/`, `*.egg-info/`

**Environment:**
- `.env`, `.env.*`

**Logs:**
- `*.log`, `logs/`

**OS files:**
- `.DS_Store`, `Thumbs.db`

### What to KEEP ✅

**Source code** - Code needed in the image

**Dependencies files:**
- `requirements.txt`, `package.json`, `Gemfile`, `go.mod`

**Configuration** - Config needed at runtime

**Assets** - Static files served by the application

---

## .dockerignore Complete Template

```dockerignore
# Git
.git/
.gitattributes
.gitignore

# Documentation
*.md
docs/

# CI/CD
.github/
.gitlab-ci.yml
Jenkinsfile

# Development
.devcontainer/
.idea/
.vscode/

# Testing
.coverage
.pytest_cache/
.spec/
.specstory/
htmlcov/
tests/

# Python
__pycache__/
*.egg-info/
*.pyc
*.pyo
.mypy_cache/
.ruff_cache/

# Virtual environments
.venv/
venv/

# Build artifacts
build/
dist/

# Environment files
.env
.env.*

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# Temporary
temp/
tmp/
*.tmp
```

---

## Language-Specific Patterns

### Python

```gitignore
__pycache__/
*.py[cod]
*.egg-info/
*.so
.mypy_cache/
.pytest_cache/
.ruff_cache/
.venv/
venv/
.coverage
htmlcov/
```

### Node.js / JavaScript

```gitignore
node_modules/
npm-debug.log
.npm/
package-lock.json
yarn.lock
dist/
.next/
.nuxt/
```

### Go

```gitignore
*.exe
*.test
vendor/
*.out
go.sum
```

### Rust

```gitignore
target/
Cargo.lock
*.rlib
*.rmeta
```

### General Development (All Languages)

```gitignore
*.swp
*.swo
*~
.DS_Store
Thumbs.db
.vscode/
.idea/
```

---

## SpecStory Integration

### .specstory Directory Management

The `.specstory/` directory contains SpecStory extension artifacts (chat history, project metadata, backups).

### Recommended .gitignore Entry

```gitignore
# SpecStory artifacts (optional - exclude chat history from version control)
.specstory/history/

# SpecStory AI rules backups (optional - if you version control separately)
.specstory/ai_rules_backups/

# Full .specstory exclusion (if not using SpecStory)
.specstory/**
```

### Recommended .dockerignore Entry

```dockerignore
# SpecStory artifacts (development tool, not needed in image)
.specstory/
```

### When to Keep .specstory in Git

- Valuable for project context and decision history
- Useful for onboarding and meta-analysis
- Share chat history with team

### When to Exclude .specstory

- When chat history contains sensitive information
- When you want minimal repository bloat
- When .specstory is auto-generated

---

## Project-Specific Customization

### Adding Custom Patterns

For project-specific artifacts:

```gitignore
# Project-specific data
data/raw/
models/trained/
cache/

# Generated artifacts
api-docs/
coverage-reports/

# Platform-specific
*.local
```

### Excluding Important Files with Negation

Use `!` to override ignore patterns:

```gitignore
# Ignore all .env files
.env.*

# Except the example template
!.env.example

# Ignore all configs
config/*.yml

# Except the template
!config/template.yml

# Ignore Python cache but keep specific file
__pycache__/
!__pycache__/.gitkeep
```

---

## Common Mistakes to Avoid

### ❌ Too Broad Patterns

```gitignore
# BAD: Matches too much
*
*.py*
config/
```

### ✅ Specific Patterns

```gitignore
# GOOD: Precise patterns
*.pyc
*.pyo
__pycache__/
config/*.local
!config/template.yml
```

### ❌ Missing Comments

```gitignore
.DS_Store
Thumbs.db
.vscode/
```

### ✅ Well-Documented

```gitignore
# OS files
.DS_Store    # macOS
Thumbs.db    # Windows

# IDEs
.vscode/     # VS Code
.idea/       # JetBrains
```

### ❌ Accidentally Ignoring Important Files

```gitignore
*.example    # Too broad, catches .example files you need
.env.*       # Without negation for .env.example
test/        # Might ignore real tests
```

### ✅ Precise Patterns with Exceptions

```gitignore
.env
.env.*
!.env.example

tests/       # Only the tests directory
!tests/.gitkeep
```

---

## Maintenance Guidelines

### Regular Review Schedule

- **Quarterly review** - Check for obsolete patterns
- **New tool/framework** - Add patterns immediately after adoption
- **Performance issues** - Review when builds or operations slow down
- **Team feedback** - Incorporate suggestions from team members

### Review Checklist

- [ ] All patterns alphabetically sorted within sections
- [ ] No duplicate patterns
- [ ] Comments describe each section clearly
- [ ] Patterns are specific, not overly broad
- [ ] No accidentally ignored important files
- [ ] `.env.example` and templates NOT ignored
- [ ] Docker build context size is reasonable
- [ ] Tests confirmed still tracked in Git

### Testing Ignore Patterns

```bash
# Check what Git ignores (shows all ignored files)
git status --ignored

# Check what .gitignore would ignore (dry run)
git check-ignore -v *

# List what's being tracked
git ls-files

# Verify specific file not ignored
git check-ignore -v path/to/file.txt

# Docker build context size
docker build --no-cache . 2>&1 | grep "Sending build context"

# See what Docker would send (requires buildkit)
DOCKER_BUILDKIT=1 docker build --progress=plain . 2>&1 | head -20
```

---

## Verification Checklist

Before committing changes to ignore files:

- [ ] All patterns are in alphabetical order within sections
- [ ] Each section has a descriptive comment header
- [ ] No overly broad patterns (`*`, `.*`)
- [ ] Templates and examples NOT ignored (`.env.example`, `config.example.yml`)
- [ ] Critical files still tracked: `git status | grep -E "package.json|requirements.txt|Dockerfile"`
- [ ] No duplicate patterns between sections
- [ ] Platform-specific patterns are commented (`# macOS`, `# Windows`)
- [ ] `.specstory/` handled appropriately (included/excluded consistently)
- [ ] Docker build context is reasonable size
- [ ] `git status --ignored` shows expected ignored files
- [ ] Run `make test` or equivalent test suite passes (if applicable)

---

## Complete Example: Synchronized Python Project

### .gitignore

```gitignore
# Build artifacts
build/
dist/
*.egg-info/

# Python
__pycache__/
*.py[cod]
*.pyo
*.so
.Python

# Virtual environments
.venv/
venv/
ENV/
env/

# Testing
.coverage
.pytest_cache/
.tox/
htmlcov/

# Type checking
.mypy_cache/
.dmypy.json
dmypy.json
.pytype/

# Linting
.ruff_cache/

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# Environment
.env
.env.*
!.env.example

# IDEs
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Temporary
temp/
tmp/
*.tmp

# SpecStory (optional)
.specstory/history/
```

### .dockerignore

```dockerignore
# Git
.git/
.gitattributes
.gitignore

# Documentation
*.md
docs/

# CI/CD
.github/
.gitlab-ci.yml
Jenkinsfile

# Development
.devcontainer/
.idea/
.vscode/

# Testing
.coverage
.pytest_cache/
.spec/
.specstory/
htmlcov/
tests/

# Python
__pycache__/
*.egg-info/
*.pyc
*.pyo
.mypy_cache/
.ruff_cache/

# Virtual environments
.venv/
venv/

# Build artifacts
build/
dist/

# Environment files
.env
.env.*

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# Temporary
temp/
tmp/
*.tmp
```

---

## Performance Impact

### Git Perspective
- Smaller `.git` directory
- Faster `git status` / `git add`
- Faster clones and fetches
- Reduced disk space

### Docker Perspective
- Faster build context transfer
- Smaller Docker layers
- Reduced image size (if context files not copied)
- Improved build times

### Measurements

```bash
# Check .git size
du -sh .git

# Check what's in Docker build context
docker build --progress=plain . 2>&1 | grep "Sending build context"
```

---

## Synchronization Workflow

### When Adding New Patterns

1. Identify which files should be ignored (Git, Docker, or both)
2. Add to appropriate file(s)
3. Sort alphabetically within section
4. Add comment if non-obvious
5. Test with `git status --ignored` or Docker build
6. Verify important files still tracked

### Pattern Consistency

- **Shared entries** - Must be in both files if filtering is common
- **Version control** - Document why entry needed
- **Review together** - Changes should consider both files
