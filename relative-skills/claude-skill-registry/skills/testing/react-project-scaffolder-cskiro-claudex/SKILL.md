---
name: react-project-scaffolder
version: 0.2.1
description: Use PROACTIVELY when creating new React projects requiring modern tooling and best practices. Provides three modes - sandbox (Vite + React for quick experiments), enterprise (Next.js with testing and CI/CD), and mobile (Expo + React Native). Enforces TypeScript strict mode, Testing Trophy approach, and 80% coverage. Not for non-React projects or modifying existing applications.
---

# React Project Scaffolder

## Overview

This skill automates the creation of React projects with three distinct modes tailored to different use cases. Each mode provides a complete, production-ready project structure with modern tooling and best practices.

**Three Modes**:
1. **Sandbox** - Vite + React + TypeScript (~15s setup)
2. **Enterprise** - Next.js + Testing + CI/CD (~60s setup)
3. **Mobile** - Expo + React Native (~60s setup)

All modes follow Connor's standards: TypeScript strict mode, Testing Trophy approach, 80% coverage, conventional commits.

## When to Use This Skill

**Trigger Phrases**:
- "create a React project"
- "scaffold a new React app"
- "set up a React sandbox"
- "create an enterprise React project"
- "build a mobile React app"

**Use Cases**:
- Quick React experiments without framework overhead
- Enterprise web applications with industry-standard tooling
- Cross-platform mobile apps with React Native
- Establishing consistent project structure across teams

**NOT for**:
- Non-React projects (Vue, Angular, Svelte)
- Backend-only projects
- Modifying existing React projects
- Ejected Expo projects (bare workflow)

## Response Style

- **Efficient**: Minimize questions, maximize automation
- **Guided**: Clear mode selection with pros/cons
- **Standards-driven**: Apply Connor's standards automatically
- **Transparent**: Explain what's being set up and why

## Mode Selection

| User Request | Mode | Framework | Time |
|--------------|------|-----------|------|
| "quick React test" | Sandbox | Vite | ~15s |
| "React sandbox" | Sandbox | Vite | ~15s |
| "production React app" | Enterprise | Next.js | ~60s |
| "enterprise React" | Enterprise | Next.js | ~60s |
| "mobile app" | Mobile | Expo | ~60s |
| "React Native project" | Mobile | Expo | ~60s |

## Mode Overview

### Sandbox Mode
Lightning-fast Vite + React + TypeScript for quick experiments.
→ **Details**: `modes/sandbox.md`

### Enterprise Mode
Production-ready Next.js with testing, linting, and CI/CD.
→ **Details**: `modes/enterprise.md`

### Mobile Mode
Cross-platform Expo + React Native with enterprise standards.
→ **Details**: `modes/mobile.md`

## Workflow

### Phase 1: Mode Selection & Prerequisites

1. Detect mode from user request
2. If ambiguous, ask which type:
   - Sandbox: Quick experiments, minimal setup
   - Enterprise: Production web apps, full tooling
   - Mobile: Cross-platform iOS/Android apps

3. Validate prerequisites:
   ```bash
   node --version  # >= 18.x
   npm --version   # >= 9.x
   ```

4. Get project name and validate:
   - Valid directory name
   - No conflicts with existing directories

### Phase 2: Mode-Specific Setup

Execute the selected mode's workflow (see mode files for details).

## Important Reminders

- **Sandbox is for experiments**: Don't add testing/CI to sandbox mode
- **Enterprise defaults to yes**: Testing and CI/CD are included by default
- **Mobile uses managed workflow**: For ejected/bare workflow, provide manual guidance
- **Always strict TypeScript**: All modes use strict mode
- **80% coverage threshold**: Enterprise and mobile enforce this

## Limitations

- Requires Node.js >= 18 and npm >= 9
- Enterprise mode creates Next.js App Router projects only
- Mobile mode uses Expo managed workflow only
- Cannot scaffold into existing directories

## Reference Materials

| Resource | Purpose |
|----------|---------|
| `modes/sandbox.md` | Vite + React setup details |
| `modes/enterprise.md` | Next.js + full tooling details |
| `modes/mobile.md` | Expo + React Native details |

## Success Criteria

- [ ] Prerequisites validated (Node.js, npm)
- [ ] Project directory created
- [ ] Framework scaffolded (Vite/Next.js/Expo)
- [ ] TypeScript strict mode configured
- [ ] Linting and formatting set up
- [ ] Testing configured (enterprise/mobile)
- [ ] Git initialized with initial commit
- [ ] Next steps provided to user
