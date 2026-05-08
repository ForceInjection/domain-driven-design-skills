---
name: grey-haven-pr-template
description: Generate pull request descriptions following Grey Haven Studio standards with clear summary, motivation, implementation details, testing strategy, and comprehensive checklist. Use when creating or reviewing pull requests.
# v2.0.43: Skills to auto-load for PR work
skills:
  - grey-haven-code-style
  - grey-haven-linear-workflow
  - grey-haven-testing-strategy
# v2.0.74: Tools for PR creation
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Grey Haven Pull Request Template

Create comprehensive, informative pull request descriptions that help reviewers understand the changes, context, and testing approach.

## PR Structure (Standard Template)

Every pull request should follow this structure:

```markdown
## Summary
[Concise 2-4 sentence description of changes]

## Motivation
[Why these changes are needed - business value, user impact, problem solved]

## Implementation Details
[Technical approach, key decisions, trade-offs considered]

## Testing
[Test strategy: unit/integration/e2e/benchmark, manual testing steps]

## Checklist
- [ ] Code follows Grey Haven style guidelines (90 char TS, 130 char Python)
- [ ] Type hints added (Python) or types maintained (TypeScript)
- [ ] Tests added/updated (unit, integration, e2e, benchmark)
- [ ] Database migrations tested (up and down)
- [ ] Multi-tenant isolation verified (tenant_id/RLS)
- [ ] Pre-commit hooks passing
- [ ] Documentation updated
- [ ] No breaking changes (or documented with migration guide)
```

## Section Guidelines

### Summary
**Purpose**: Provide a brief, clear overview of what changed.

**Guidelines**:
- 2-4 sentences maximum
- Focus on **what** changed from user/system perspective
- Reference Linear issues: `GREY-123`
- Mention multi-tenant or RLS changes
- Use present tense

**Example**:
```markdown
## Summary

This PR adds magic link authentication using better-auth with email verification.
Users can now sign in via emailed links instead of passwords. Addresses Linear
issue GREY-234 and integrates with multi-tenant RLS policies.
```

### Motivation
**Purpose**: Explain **why** these changes are necessary.

**Guidelines**:
- Describe the problem being solved
- Explain business value or user impact
- Reference Linear issues: `GREY-123`
- Include context not obvious from code
- Mention technical debt or performance concerns

**Example**:
```markdown
## Motivation

Users reported frustration with password-based auth (GREY-234). Analytics show
35% abandon signup at password creation. Magic links offer passwordless auth,
better security, reduced support burden, and built-in email verification.

Aligns with Q1 goal of improving onboarding conversion by 20%.
```

### Implementation Details
**Purpose**: Explain **how** the changes work at technical level.

**Guidelines**:
- Mention Grey Haven tech stack: TanStack Start/Router/Query, FastAPI, Drizzle, SQLModel
- Reference Grey Haven patterns: repository pattern, multi-tenant RLS, server functions
- Note database schema changes (snake_case fields, tenant_id, indexes)
- Explain testing markers: unit, integration, e2e, benchmark
- Include code references with [file:line](file#Lline) format

**Example**:
```markdown
## Implementation Details

### Authentication Flow
1. Added magic link server function in [lib/server/functions/auth.ts:45](lib/server/functions/auth.ts#L45)
2. Created email template with Resend integration
3. Implemented token verification route at `/auth/verify`

### Key Changes
- **Server Functions**: New `sendMagicLink` and `verifyMagicLink` with tenant context
- **Database Schema**: Added `magic_link_tokens` table (snake_case, tenant_id, RLS)
- **Routes**: Magic link verification page with TanStack Router navigation

### Design Decisions
- Token expiry: 15 minutes (security vs UX balance)
- Single-use tokens with unique constraint
- Tenant isolation via RLS policies
- Email via Resend (better deliverability)
```

### Testing
**Purpose**: Describe testing strategy and manual testing steps.

**Guidelines**:
- List testing markers used: unit, integration, e2e, benchmark
- Include manual testing steps
- Mention test coverage
- Note any edge cases tested

**Example**:
```markdown
## Testing

### Automated Tests
- **Unit tests** (18 new): Token generation, validation, expiry logic
- **Integration tests** (6 new): Email sending, database operations
- **E2e tests** (3 new): Full magic link flow with Playwright

### Manual Testing
1. Request magic link from login page
2. Verify email received within 30 seconds
3. Click link in email
4. Verify successful auth and redirect
5. Test expired token (wait 16 minutes)
6. Test single-use token (use link twice)

### Coverage
- New code: 94% coverage
- Critical paths: 100% coverage
```

## Checklist

Use this checklist before requesting review:

- [ ] Code follows Grey Haven style guidelines (90 char TS, 130 char Python)
- [ ] Type hints added (Python) or types maintained (TypeScript)
- [ ] Tests added/updated (unit, integration, e2e, benchmark)
- [ ] Test coverage meets 80% threshold
- [ ] Database migrations tested (up and down)
- [ ] Multi-tenant isolation verified (tenant_id/RLS)
- [ ] Pre-commit hooks passing (Prettier, Ruff, mypy)
- [ ] Documentation updated (README, API docs)
- [ ] No breaking changes (or documented with migration guide)
- [ ] Linear issue referenced in description
- [ ] Commit messages follow commitlint format
- [ ] Virtual environment activated (Python projects)

## Supporting Documentation

All supporting files are under 500 lines per Anthropic best practices:

- **[examples/](examples/)** - Complete PR examples
  - [feature-pr.md](examples/feature-pr.md) - Feature PR example
  - [bugfix-pr.md](examples/bugfix-pr.md) - Bug fix PR example
  - [refactor-pr.md](examples/refactor-pr.md) - Refactoring PR example
  - [INDEX.md](examples/INDEX.md) - Examples navigation

- **[templates/](templates/)** - Copy-paste ready templates
  - [feature-template.md](templates/feature-template.md) - Feature PR template
  - [bugfix-template.md](templates/bugfix-template.md) - Bug fix PR template
  - [database-template.md](templates/database-template.md) - Database PR template

- **[checklists/](checklists/)** - Pre-PR validation
  - [pr-checklist.md](checklists/pr-checklist.md) - Comprehensive PR checklist

## Special Cases

### Breaking Changes
Always include migration guide:

```markdown
## Breaking Changes

**BREAKING:** User IDs are now UUIDs instead of sequential integers.

### Migration Guide
1. Update API clients to handle UUID format
2. Run database migration: `bun run db:migrate`
3. Update any hardcoded user IDs in tests
4. Verify multi-tenant isolation still works

### Timeline
- Migration available: 2025-01-15
- Required by: 2025-02-01
```

### Database Migrations
Include up and down testing:

```markdown
## Database Migration

### Changes
- Add `tenant_id` column to `organizations` table
- Create RLS policies for tenant isolation
- Add index on `tenant_id`

### Testing
- ✅ Migration up: Successful
- ✅ Migration down: Successful
- ✅ Data backfill: Verified for 1000+ records
- ✅ RLS policies: Tested with different tenants
```

## When to Apply This Skill

Use this skill when:
- Creating pull requests in Grey Haven projects
- Reviewing pull requests for completeness
- Onboarding new developers to PR standards
- Creating PR templates for new repos
- Documenting complex features or refactorings

## Template Reference

These standards come from Grey Haven's actual templates:
- **cvi-template**: TanStack Start + React 19
- **cvi-backend-template**: FastAPI + SQLModel

## Critical Reminders

1. **Summary: 2-4 sentences** - concise overview
2. **Motivation: explain why** - business value, user impact
3. **Implementation: explain how** - technical approach with file references
4. **Testing: comprehensive** - automated + manual steps
5. **Checklist: complete** - all items checked before review
6. **Linear issues: reference** - GREY-123 format
7. **Multi-tenant: verify** - tenant_id and RLS mentioned
8. **Breaking changes: document** - migration guide required
9. **Database: test migrations** - up and down
10. **Code references: clickable** - use [file:line](file#Lline) format
