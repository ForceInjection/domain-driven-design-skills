---
name: agents-md-authoring
description: Create and maintain AGENTS.md files following the open specification at agents.md. Use when setting up AI coding agent instructions for a project, updating project conventions for agents, or documenting build/test/deploy workflows for automated coding assistants.
---

# AGENTS.md Authoring Skill

Use this skill to create, update, or improve AGENTS.md files—dedicated instruction files that guide AI coding agents working on your project.

## When to activate this skill

- User asks to create an AGENTS.md file
- User wants to document project conventions for AI agents
- User asks to update or improve existing AGENTS.md
- Setting up a new project and need agent instructions
- Migrating from other instruction formats (CLAUDE.md, CURSOR.md, etc.)
- Adding nested AGENTS.md files for monorepo subprojects

## What is AGENTS.md?

AGENTS.md is a simple, open format for guiding AI coding agents. Think of it as a README for agents—a dedicated, predictable place to provide context and instructions that help AI coding assistants work effectively on your project.

**Key characteristics:**

- Just standard Markdown (no special syntax required)
- No required fields or structure
- One file works across many agents (Codex, Cursor, Claude, Gemini CLI, Amp, etc.)
- Steward by the Agentic AI Foundation under the Linux Foundation

**AGENTS.md vs README.md:**

| README.md                  | AGENTS.md                          |
| -------------------------- | ---------------------------------- |
| For humans                 | For AI coding agents               |
| Quick starts, descriptions | Build commands, test patterns      |
| Contribution guidelines    | Code conventions, security gotchas |
| Project overview           | Detailed context agents need       |

## File placement

### Single project

Place `AGENTS.md` at the repository root:

```
project/
├── AGENTS.md
├── README.md
├── package.json
└── src/
```

### Monorepos

Use nested AGENTS.md files for subprojects. Agents read the nearest file in the directory tree, so the closest one takes precedence:

```
monorepo/
├── AGENTS.md              # Root-level conventions
├── packages/
│   ├── frontend/
│   │   └── AGENTS.md      # Frontend-specific instructions
│   └── backend/
│       └── AGENTS.md      # Backend-specific instructions
└── services/
    └── api/
        └── AGENTS.md      # API service instructions
```

## Recommended sections

While AGENTS.md has no required structure, these sections are commonly helpful:

### 1. Project Overview

Brief context about what the project is and its architecture:

```markdown
# AGENTS.md

## Project Overview

This is a [type of project] using [key technologies]. The codebase is organized as [structure description].
```

### 2. Development Commands

Commands agents should use for common tasks:

```markdown
## Development Commands

- Install dependencies: `pnpm install`
- Start dev server: `pnpm dev`
- Run tests: `pnpm test`
- Lint code: `pnpm lint`
- Build: `pnpm build`
```

**Tip:** If your project uses a task runner like `mise`, `just`, or `make`, document those commands instead of the underlying tools.

### 3. Code Style & Conventions

Patterns and preferences agents should follow:

```markdown
## Code Style

- TypeScript strict mode
- Single quotes, no semicolons
- Use functional patterns where possible
- Prefer named exports over default exports
```

### 4. Testing Instructions

How to run and write tests:

```markdown
## Testing

- Run all tests: `pnpm test`
- Run specific test: `pnpm vitest run -t "<test name>"`
- Tests must pass before committing
- Add tests for new code, even if not requested
```

### 5. Architecture & Key Files

Help agents navigate the codebase:

```markdown
## Architecture

### Key Directories

- `src/components/` — React components
- `src/hooks/` — Custom React hooks
- `src/api/` — API client and types
- `src/utils/` — Shared utilities

### Important Files

- `src/App.tsx` — Main application entry
- `src/routes.ts` — Route definitions
- `vite.config.ts` — Build configuration
```

### 6. PR & Commit Guidelines

Standards for contributions:

```markdown
## PR Instructions

- Title format: `[scope] Description`
- Run `pnpm lint` and `pnpm test` before committing
- Keep PRs focused on a single change
- Update tests for modified code
```

### 7. Security & Gotchas

Critical information agents should know:

```markdown
## Security

- Never commit secrets or API keys
- Use environment variables for sensitive config
- Sanitize user input before database queries

## Gotchas

- The `config/` directory is generated—don't edit manually
- Always use `pnpm` not `npm` (workspace dependencies)
```

## Creating a new AGENTS.md

### Step 1: Analyze the project

Before writing, understand:

- Project type and technologies used
- Build system and task runner
- Testing framework and patterns
- Existing conventions (linting, formatting)
- Directory structure and key files

### Step 2: Check for existing documentation

Look for existing instructions in:

- README.md (may have contribution guidelines)
- CONTRIBUTING.md
- .github/CONTRIBUTING.md
- Existing AGENTS.md, CLAUDE.md, CURSOR.md, etc.

### Step 3: Write the AGENTS.md

Start with the most critical information agents need:

```markdown
# AGENTS.md

## Project Overview

[One paragraph describing the project and architecture]

## Development Commands

[Essential commands for development workflow]

## Code Style

[Key conventions and patterns]

## Testing

[How to run and write tests]

## Architecture

[Directory structure and important files]
```

### Step 4: Add project-specific sections

Include any unique aspects:

- Environment setup requirements
- Database seeding/migration commands
- Deployment considerations
- Security requirements
- Known limitations or gotchas

## Updating existing AGENTS.md

### When to update

- New tools or commands added to the project
- Directory structure changes
- New conventions adopted
- Bugs caused by outdated instructions
- Feedback from agents following incorrect guidance

### How to update

1. **Review current content** — Check what's accurate and what's stale
2. **Verify commands** — Ensure all listed commands still work
3. **Check file paths** — Verify referenced files still exist
4. **Add missing context** — Include anything agents frequently need
5. **Remove obsolete content** — Delete outdated instructions

## Migrating from other formats

If you have CLAUDE.md, CURSOR.md, or similar files:

```bash
# Rename to AGENTS.md
mv CLAUDE.md AGENTS.md

# Create symlink for backward compatibility (optional)
ln -s AGENTS.md CLAUDE.md
```

Then review and consolidate content from any duplicates.

## Agent-specific configuration

Some agents read AGENTS.md by default. Others need configuration:

### Aider

Add to `.aider.conf.yml`:

```yaml
read: AGENTS.md
```

### Gemini CLI

Add to `.gemini/settings.json`:

```json
{ "contextFileName": "AGENTS.md" }
```

### Most other agents

Agents like Cursor, Claude, Amp, and Codex read AGENTS.md automatically when present at the project root.

## Example: Complete AGENTS.md

```markdown
# AGENTS.md

## Project Overview

This is a Next.js 14 web application using TypeScript, Tailwind CSS, and PostgreSQL. It follows the App Router pattern with server components by default.

## Development Commands

- Install: `pnpm install`
- Dev server: `pnpm dev` (runs on localhost:3000)
- Lint: `pnpm lint`
- Test: `pnpm test`
- Build: `pnpm build`
- Database migrations: `pnpm db:migrate`

## Code Style

- TypeScript strict mode enabled
- Use server components unless client interactivity needed
- Prefer `cn()` utility for conditional classNames
- Use absolute imports from `@/` prefix
- Functional components only, no class components

## Testing

- Framework: Vitest + React Testing Library
- Run all: `pnpm test`
- Run specific: `pnpm vitest run -t "test name"`
- Coverage: `pnpm test:coverage`
- Always add tests for new features

## Architecture

### Key Directories

- `app/` — Next.js App Router pages and layouts
- `components/` — Shared React components
- `lib/` — Utilities, database client, types
- `prisma/` — Database schema and migrations

### Important Files

- `app/layout.tsx` — Root layout with providers
- `lib/db.ts` — Prisma client singleton
- `prisma/schema.prisma` — Database schema

## PR Instructions

- Title: `[feat|fix|chore] Description`
- Run lint and tests before committing
- Squash commits when merging
- Update CHANGELOG.md for user-facing changes

## Security

- Environment variables in `.env.local` (gitignored)
- Never log or expose API keys
- Use Prisma parameterized queries (no raw SQL)

## Gotchas

- Use `pnpm` not `npm` (workspace setup)
- Don't import from `@prisma/client` directly—use `lib/db`
- Server actions must be in separate files with 'use server'
```

## Checklist

Before finishing an AGENTS.md:

- [ ] Project overview describes architecture clearly
- [ ] All development commands are accurate and tested
- [ ] Code conventions match actual project patterns
- [ ] Testing instructions are complete
- [ ] Key directories and files are documented
- [ ] PR/commit guidelines included if relevant
- [ ] Security considerations documented
- [ ] Known gotchas and pitfalls listed
- [ ] File placed in correct location (root or subproject)

## References

- [AGENTS.md Official Site](https://agents.md/)
- [60k+ Examples on GitHub](https://github.com/search?q=path%3AAGENTS.md+NOT+is%3Afork+NOT+is%3Aarchived&type=code)
- [Agentic AI Foundation](https://aaif.io/)
