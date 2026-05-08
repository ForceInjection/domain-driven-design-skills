---
name: skills-registry
description: |
  Dynamic skill discovery and matching for any task context.
  
  Invoke when:
  - Starting any task to discover relevant skills
  - Need to find specialized skills for current context
  - Agent/command needs skill recommendations
  
  Trigger phrases: "match skills", "find skills", "what skills for",
  "recommend skills", "which capabilities", "skill lookup", "applicable skills"
  
  Examples:
  - "Match skills for TDD cycle with zod validation" → outputs backend-zod, backend-vitest
  - "What skills for React landing page?" → outputs frontend-master, frontend-aceternity
allowed-tools: Read, Grep, Glob
---

# Skills Registry

Dynamic skill matching system. Analyzes task context and recommends skills to apply.

## Matching Protocol

### Step 1: Extract Context Keywords

From current task/input, identify:
- **Action**: analyze, fix, create, test, debug, review, implement, setup, deploy
- **Domain**: frontend, backend, API, database, validation, UI, auth, DevOps
- **Tech**: React, Next.js, Express, Prisma, tRPC, zod, Playwright, Docker
- **Problem**: error, bug, issue, failure, lint, type check, debugging

### Step 2: Match Against Registry

For each skill in registry:
1. Count keyword matches: `(task keywords) ∩ (skill keywords)`
2. Check if task situation matches skill's `when` condition
3. Match if: ≥2 keywords OR `when` applies

### Step 3: Rank Results

Order matched skills by:
1. `priority: high` → top of list
2. `enforcement: required` → above `suggest`
3. More keyword matches → higher rank

### Step 4: Output

**When matches found:**
```
Matched skills:

**Required:**
- Apply [Skill] skill — [reason]

**Suggested:**
- Apply [Skill] skill — [reason]
```

**When no matches (< 2 keywords, no `when` applies):**
```
No skills matched.
Context extracted: [keywords]
Clarify domain or tech stack for better matching.
```

---

## Skills Registry Data

### Core Skills

| Skill | Path | Keywords | When | Priority | Enforcement |
|-------|------|----------|------|----------|-------------|
| feature-analyzer | `.claude/skills/feature-analyzer/` | feature, artifacts, spec, plan, tasks, data-model, requirements, context, ux, contracts | Loading feature context OR reading documentation artifacts OR need requirements understanding | high | required |
| code-analyzer | `.claude/skills/code-analyzer/` | codebase, structure, dependencies, markers, AICODE, imports, modules, architecture, existing code | Need project structure OR dependency analysis OR find existing AICODE markers OR understand architecture | medium | suggest |
| git | `.claude/skills/git/` | branch, commit, push, merge, git, repository, checkout, stash | Any git operation — branch creation, commits, pushes, merges | high | required |
| sequential-thinking | `.claude/skills/sequential-thinking/` | complex, analysis, multi-step, root cause, debugging, unclear, diagnosis, investigation | Problem requires 3+ logical steps OR unclear root cause OR multiple valid approaches OR low confidence in solution | medium | suggest |
| context7 | `.claude/skills/context7/` | library, documentation, package, npm, pypi, external, api reference, third-party | Need library documentation OR unfamiliar package OR library-related error OR checking correct API usage | medium | suggest |
| self-commenting | `.claude/skills/self-commenting/` | AICODE, marker, NOTE, TODO, FIX, annotation, cross-session, context preservation | Writing code that needs context for future sessions OR documenting non-obvious logic OR leaving markers | low | suggest |

### Agent & Prompt Skills

| Skill | Path | Keywords | When | Priority | Enforcement |
|-------|------|----------|------|----------|-------------|
| agent-creator | `.claude/skills/agent-creator/` | agent, subagent, create agent, agent template, agent design, specialized agent, domain expert | Creating new agents OR designing agent prompts OR configuring agent tools and models | medium | suggest |
| self-improve | `.claude/skills/self-improve/` | intent, interpret, vague request, enrich, synthesize, findings, actionable, user request | Interpreting vague user intent OR preparing context for agent generation OR synthesizing actionable insights from project context | medium | suggest |
| prompt-optimizer | `.claude/skills/prompt-optimizer/` | prompt, TCRO, prompt engineering, optimize prompt, improve prompt, prompt template, structure prompt | Crafting prompts for code generation OR improving prompts not getting results OR structuring multi-step workflows OR debugging pattern drift | medium | suggest |

### Frontend Skills

| Skill | Path | Keywords | When | Priority | Enforcement |
|-------|------|----------|------|----------|-------------|
| frontend-master | `.claude/skills/frontend-master/` | frontend, Next.js, React, Tailwind, UI, components, styling, layout | Starting frontend task OR need decision framework for UI components, animations, assets, or theming | high | suggest |
| frontend-shadcn | `.claude/skills/frontend-shadcn/` | shadcn, button, input, dialog, form, table, modal, dropdown, Radix, components | Need standard UI components (buttons, inputs, dialogs, forms, tables) OR building React/Next.js UI | low | suggest |
| frontend-aceternity | `.claude/skills/frontend-aceternity/` | aceternity, spotlight, aurora, 3D card, hero effects, dramatic, wow factor, landing page | Need dramatic hero effects, spotlights, aurora backgrounds, 3D hover cards, or text reveal animations | low | suggest |
| frontend-magic-ui | `.claude/skills/frontend-magic-ui/` | magic ui, number ticker, marquee, bento grid, mockup, Safari, iPhone, shimmer button, SaaS | Need SaaS landing components like number tickers, logo marquees, bento grids, or device mockups | low | suggest |
| frontend-lottie | `.claude/skills/frontend-lottie/` | lottie, animation, loader, spinner, success, error, empty state, decorative | Need simple play/loop animations like loading spinners, success checkmarks, or empty state illustrations | low | suggest |
| frontend-rive | `.claude/skills/frontend-rive/` | rive, interactive animation, state machine, hover, click, data-driven, toggle, checkbox | Need animations that react to user input (hover, click, drag) OR have multiple states/transitions OR respond to data values | low | suggest |
| frontend-color-system | `.claude/skills/frontend-color-system/` | color, palette, theme, brand color, dark mode, WCAG, contrast, accessibility | Setting up project colors OR creating dark mode OR checking WCAG contrast OR generating theme from brand color | low | suggest |
| frontend-google-fonts | `.claude/skills/frontend-google-fonts/` | fonts, typography, Google Fonts, font pairing, Inter, Plus Jakarta, headings, body text | Setting up project fonts OR need font pairing recommendations OR optimizing font loading | low | suggest |
| frontend-iconify | `.claude/skills/frontend-iconify/` | icon, iconify, lucide, heroicons, SVG, icon search, icon set | Need to find icons by concept OR integrate icon library OR download SVG icons | low | suggest |
| frontend-image-generation | `.claude/skills/frontend-image-generation/` | avatar, placeholder, photo, illustration, DiceBear, Unsplash, unDraw, image assets | Need avatars, placeholder photos, or illustrations — use FREE resources first (DiceBear, Unsplash, unDraw) | low | suggest |
| frontend-debug-linting | `.claude/skills/frontend-debug-linting/` | lint, ESLint, TypeScript, type check, Prettier, format, debug, console errors | After writing React/Next.js code OR before delivery OR debugging frontend issues | medium | required |
| frontend-playwright | `.claude/skills/frontend-playwright/` | playwright, screenshot, browser, visual QA, responsive, viewport, console errors, UI testing | Before delivering UI changes OR need visual verification OR responsive testing OR debugging hydration issues | low | required |
| frontend-design-review | `.claude/skills/frontend-design-review/` | design review, UI review, UX, visual polish, accessibility, WCAG, responsive design, component standards | Building new interfaces OR reviewing visual changes OR validating design quality OR accessibility compliance | medium | suggest |

### Backend Skills

| Skill | Path | Keywords | When | Priority | Enforcement |
|-------|------|----------|------|----------|-------------|
| backend-master | `.claude/skills/backend-master/` | backend, API, server, TypeScript backend, Express, Node.js, microservices | Starting backend task OR need decision framework for APIs, auth, database, validation, logging, testing, or deployment | high | suggest |
| backend-trpc | `.claude/skills/backend-trpc/` | tRPC, type-safe API, procedure, router, query, mutation, middleware, end-to-end types | Building full-stack TypeScript API OR need type-safe API without GraphQL OR building internal APIs | low | suggest |
| backend-trpc-openapi | `.claude/skills/backend-trpc-openapi/` | OpenAPI, REST, Swagger, API documentation, third-party integration, external clients | Need REST endpoints from tRPC OR Swagger documentation OR third-party integrations need REST | low | suggest |
| backend-zod | `.claude/skills/backend-zod/` | zod, validation, schema, input validation, type inference, parse, safeParse, coerce | Validating API inputs OR form data OR environment variables OR any data crossing trust boundaries | low | suggest |
| backend-prisma | `.claude/skills/backend-prisma/` | prisma, database, ORM, schema, migration, PostgreSQL, MySQL, SQLite | Need database access with TypeScript types OR running migrations OR querying relational data | low | suggest |
| backend-auth-js | `.claude/skills/backend-auth-js/` | auth.js, NextAuth, OAuth, GitHub login, Google login, session, JWT, credentials | Building Next.js app with OAuth OR credentials login OR session management | low | suggest |
| backend-passport-js | `.claude/skills/backend-passport-js/` | passport, Express auth, JWT authentication, strategy, bearer token, login, register | Building Express API with JWT auth OR need custom auth strategies OR non-Next.js authentication | low | suggest |
| backend-pino | `.claude/skills/backend-pino/` | pino, logging, structured logs, JSON logs, request logging, child logger, redact, observability | Need structured logging for production OR request tracing OR sensitive data redaction | medium | suggest |
| backend-vitest | `.claude/skills/backend-vitest/` | vitest, test, unit test, mock, describe, expect, coverage, TDD | Writing unit tests OR testing tRPC procedures OR testing Zod schemas OR need fast test runner | low | suggest |

### DevOps Skills

| Skill | Path | Keywords | When | Priority | Enforcement |
|-------|------|----------|------|----------|-------------|
| docker-node | `.claude/skills/docker-node/` | docker, container, Dockerfile, docker-compose, deploy, CI/CD, multi-stage, production | Deploying Node.js application OR need consistent dev environment OR setting up CI/CD OR containerizing API | medium | suggest |

---

## Examples

### Example 1: TDD with Validation

**Input:** "Implementing user validation with zod schemas, need unit tests"

**Output:**
```
Matched skills:

**Suggested:**
- Apply backend-zod skill — validation, zod matched
- Apply backend-vitest skill — unit test, TDD matched
```

### Example 2: ESLint Errors (Required Enforcement)

**Input:** "ESLint errors after adding new React component, type check failing"

**Output:**
```
Matched skills:

**Required:**
- Apply frontend-debug-linting skill — ESLint, type check matched (enforcement: required)

**Suggested:**
- Apply frontend-master skill — React context
```

### Example 3: Complex Problem (Sequential Thinking)

**Input:** "Root cause analysis of auth failure, unclear why JWT validation fails"

**Output:**
```
Matched skills:

**Suggested:**
- Apply sequential-thinking skill — root cause, unclear, analysis matched
- Apply backend-auth-js skill — auth, JWT matched
- Apply backend-passport-js skill — JWT authentication matched
```