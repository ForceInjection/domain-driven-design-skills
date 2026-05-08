---
name: project-context
description: Klassenzeit project structure, conventions, tooling, and workflows for context-aware assistance.
---

# Project Context

## Monorepo Structure

```
Klassenzeit/
├── backend/         # Spring Boot application (Java 21)
├── frontend/        # React 19 + Vite + TypeScript
├── e2e/             # Playwright E2E tests
├── tasks/           # Task management (kanban-style)
├── .claude/         # Claude Code configuration
├── .github/         # GitHub Actions workflows
├── Makefile         # Centralized commands
└── CLAUDE.md        # Project guidelines
```

## Technology Stack

| Layer | Technology |
|-------|------------|
| Backend Framework | Spring Boot 3.x |
| Backend Language | Java 21 |
| Database | PostgreSQL 17 |
| Auth | Keycloak |
| Frontend Framework | React 19 |
| Build Tool | Vite 7 |
| Styling | Tailwind CSS + shadcn/ui |
| Testing | JUnit, Vitest, Playwright |

## Pre-commit Hooks

Defined in `.pre-commit-config.yaml`:

**Backend**
- `spotless-check`: Code formatting (Google Java Format)
- `checkstyle`: Code style rules
- `pmd`: Static analysis
- `spotbugs`: Bug detection

**Frontend**
- `biome-check`: Linting + formatting
- `frontend-typecheck`: TypeScript validation

Run manually: `uv run pre-commit run --all-files`

## Task Management Workflow

```
tasks/
├── todo/           # Not started
│   ├── backend/
│   ├── frontend/
│   └── global/
├── doing/          # In progress
│   ├── backend/
│   ├── frontend/
│   └── global/
└── done/           # Completed
    ├── backend/
    ├── frontend/
    └── global/
```

### Task File Format
```markdown
# Task Title

## Description
What needs to be done and why.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Notes
Progress updates, blockers, related commits.

## Completion Notes (add when done)
What was implemented, key decisions, issues encountered.
```

### Workflow
1. **todo -> doing**: Move file when starting work
2. **doing -> done**: Move file when complete, add completion notes

## Key Configuration Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project guidelines for Claude Code |
| `.pre-commit-config.yaml` | Pre-commit hook definitions |
| `Makefile` | Centralized development commands |
| `lighthouserc.json` | Lighthouse CI configuration |
| `.github/workflows/ci.yml` | CI/CD pipeline |

## Common Make Commands

```bash
make dev              # Start services + backend
make frontend         # Start frontend dev server
make services-up      # Start PostgreSQL + Keycloak
make services-down    # Stop services
make test             # Run all unit tests
make test-backend     # Backend tests only
make test-frontend    # Frontend tests only
make test-e2e         # E2E tests
make lint             # Check all linting
make format           # Format all code
make help             # Show all commands
```

## Environment Setup

Required `.env` files:
- Root: Database config for Docker
- `frontend/.env`: API URL configuration
- `e2e/.env`: Test configuration

## Database Connection (Local Dev)

```
Host: localhost:5432
Database: klassenzeit
User: klassenzeit
Password: klassenzeit
```

## Project-Specific Rules

1. Use `uv` for Python commands (not `python` directly)
2. Never run `git add`, `commit`, or `push` automatically
3. Follow task management workflow in `tasks/` directory
4. Reference CLAUDE.md for project-specific standards
