---
name: frontend-setup
description: |
  Interactive multi-level skill for scaffolding frontend projects from source. Use when user wants to:
  (1) Create a new frontend project (web, mobile, desktop, or cross-platform)
  (2) Set up a React, Vue, Svelte, Angular, Flutter, React Native, Electron, or Tauri project
  (3) Configure shadcn/ui with custom styling, colors, fonts, and components
  (4) Set up architecture patterns (Bulletproof React, Clean Architecture, Feature-based, etc.)
  (5) Add state management, data fetching, forms, validation, testing, or tooling

  Triggers: "create frontend project", "setup react app", "new vue project", "scaffold mobile app", "setup shadcn", "create next.js app", "new expo project", "setup tauri app"
---

# Frontend Setup

Interactive skill for scaffolding frontend projects. Guides through platform, framework, and tooling selection using cascading questions, then generates commands and directory structure.

## Question Flow Strategy

Use `AskUserQuestion` with **max 4 options per question**. For categories with more options, use cascading questions:

1. First ask about **category/family**
2. Then ask for **specific choice** within that category

See [references/frameworks.md](references/frameworks.md) for all groupings and options.

## Workflow

### Level 1: Platform

```
? Select target platform:
  > Web
  > Mobile
  > Desktop
  > Cross-Platform
```

### Level 2: Framework

**Cascading pattern** - ask family first, then specific:

**Web:**
```
Q1: ? Framework family:
    > React-based
    > Vue-based
    > Svelte-based
    > Other

Q2 (if React): ? React framework:
    > TanStack Start (Recommended)
    > Vite (SPA)
    > Next.js

Q2 (if Vue): ? Vue framework:
    > Vite (SPA)
    > Nuxt (Full-stack)

Q2 (if Svelte): ? Svelte framework:
    > Vite (SPA)
    > SvelteKit (Full-stack)

Q2 (if Other): ? Select framework:
    > Angular
    > Solid / Qwik
    > Astro
    > Vanilla
```

**Mobile:**
```
Q1: ? Mobile approach:
    > React Native
    > Flutter
    > Native

Q2 (if RN): ? React Native setup:
    > Expo (Recommended)
    > Bare CLI

Q2 (if Native): ? Native platform:
    > iOS (Swift/SwiftUI)
    > Android (Kotlin)
```

**Desktop:**
```
Q1: ? Desktop approach:
    > Web-based (Electron/Tauri)
    > Cross-platform native
    > Platform-specific

Q2 (if Web-based): ? Framework:
    > Tauri (Recommended)
    > Electron

Q2 (if Cross-platform): ? Framework:
    > Flutter Desktop
    > .NET MAUI
```

### Level 3: Package Manager (Node.js only)

Skip for Flutter/Native.
```
? Package manager:
  > pnpm (Recommended)
  > npm
  > yarn
  > bun
```

### Level 4: Architecture

See [references/architecture.md](references/architecture.md) for patterns. Most frameworks have ≤4 options.

### Level 5: Design System

**Cascading pattern for React/Vue (>4 options):**

```
Q1: ? Design approach:
    > Tailwind-based
    > Component library
    > Unstyled / None

Q2 (if Tailwind): ? Tailwind system:
    > shadcn/ui (Recommended)
    > Tailwind CSS only
    > Headless UI + Tailwind

Q2 (if Component): ? Library:
    > Material UI
    > Chakra UI
    > Mantine
    > Ant Design
```

**If shadcn/ui selected:** Continue to Level 6 ([references/shadcn.md](references/shadcn.md))

### Level 6: shadcn/ui Configuration

Use cascading questions for options >4. See [references/shadcn.md](references/shadcn.md).

**Style (5 options):**
```
Q1: ? Style preference:
    > Classic (Vega)
    > Compact (Nova, Mira)
    > Soft (Maia)
    > Sharp (Lyra)

Q2 (if Compact): ? Compact style:
    > Nova (Reduced padding)
    > Mira (Dense interfaces)
```

**Theme Color (18 options):**
```
Q1: ? Color family:
    > Neutral tones
    > Cool colors
    > Warm colors
    > Greens

Q2 (Neutral): > neutral, stone, zinc, gray
Q2 (Cool): > blue, cyan, indigo, violet (then sky, purple, teal if needed)
Q2 (Warm): > red, orange, amber, rose (then pink, fuchsia, yellow if needed)
Q2 (Greens): > green, emerald, lime, teal
```

**Font (10 options):**
```
Q1: ? Font style:
    > Modern sans-serif
    > Classic sans-serif
    > Friendly/Rounded
    > Monospace

Q2 (Modern): > Inter, DM Sans, Public Sans, Outfit
Q2 (Classic): > Roboto, Noto Sans, Raleway
Q2 (Friendly): > Nunito Sans, Figtree
Q2 (Monospace): > JetBrains Mono (single option, skip Q2)
```

**Components (50+ multi-select):**
```
? Component bundle:
  > All components
  > Essentials (Button, Input, Form, Card, Dialog, Toast)
  > Dashboard kit (Table, Chart, Sidebar, Tabs, Command)
  > Custom selection

(if Custom): Ask by category - Forms, Data Display, Navigation, Overlay
```

### Levels 7-17: Additional Configuration

Continue with cascading pattern where needed. See [references/frameworks.md](references/frameworks.md).

**State Management (React - 8 options):**
```
Q1: ? State approach:
    > Minimal (Zustand/Jotai)
    > Full-featured (Redux/MobX)
    > Server + Client
    > None

Q2 (Minimal): > Zustand, Jotai, Context only
Q2 (Full): > Redux Toolkit, MobX, Recoil
```

**Data Fetching (JS - 9 options):**
```
Q1: ? Data fetching type:
    > Query libraries
    > GraphQL
    > Simple HTTP
    > None

Q2 (Query): > TanStack Query, SWR, RTK Query
Q2 (GraphQL): > Apollo Client, urql
Q2 (HTTP): > tRPC, Axios, Fetch API
```

**Authentication (8 options):**
```
Q1: ? Auth approach:
    > Managed service
    > BaaS auth
    > Self-hosted
    > None / Later

Q2 (Managed): > Clerk, Auth.js
Q2 (BaaS): > Supabase, Firebase, Amplify
Q2 (Self-hosted): > Lucia, Custom JWT
```

**Deployment (Web - 8 options):**
```
Q1: ? Deployment type:
    > Serverless platform
    > Full platform
    > Self-hosted
    > None / Later

Q2 (Serverless): > Vercel, Netlify, Cloudflare
Q2 (Full): > Railway, Fly.io, Amplify
```

**Additional Features (13 multi-select):**
```
? Feature bundle:
  > Common (i18n, Dark mode, Path aliases)
  > DevOps (CI/CD, Docker, Error tracking)
  > Full bundle
  > Custom selection
```

## Execution

After collecting selections:

1. **Generate commands** using reference below
2. **Run framework CLI** to create project
3. **Install dependencies** based on selections
4. **Create directory structure** based on architecture
5. **Generate config files** (tsconfig, eslint, etc.)

## Command Reference

### Package Manager Mapping

| Manager | Create | Execute |
|---------|--------|---------|
| npm | `npm create` | `npx` |
| pnpm | `pnpm create` | `pnpm dlx` |
| yarn | `yarn create` | `yarn dlx` |
| bun | `bun create` | `bunx` |

### Framework Commands

```bash
# TanStack Start (Recommended for React)
{pmx} create-start@latest {name}

# React (Vite)
{pm} create vite@latest {name} -- --template react-ts

# Next.js
{pmx} create-next-app@latest {name}

# Vue (Vite)
{pm} create vite@latest {name} -- --template vue-ts

# Nuxt
{pmx} nuxi@latest init {name}

# Svelte (Vite)
{pm} create vite@latest {name} -- --template svelte-ts

# SvelteKit
{pmx} sv create {name}

# Angular
{pmx} @angular/cli@latest new {name}

# Expo
{pmx} create-expo-app@latest {name}

# React Native CLI
{pmx} @react-native-community/cli@latest init {name}

# Flutter
flutter create {name}

# Tauri
{pm} create tauri-app@latest

# Electron
{pm} create electron-vite@latest
```

### shadcn/ui

```bash
# Create new project with preset (recommended)
{pmx} shadcn@latest create --preset "{preset_url}&template={template}" --template {template}

# Templates: next, vite, remix, gatsby, laravel, astro, tanstack-start, react-router
# Example:
{pmx} shadcn@latest create --preset "https://ui.shadcn.com/init?base=radix&style=vega&baseColor=neutral&theme=blue&iconLibrary=lucide&font=inter&radius=default&menuColor=default&menuAccent=subtle&template=next" --template next

# Init in existing project
{pmx} shadcn@latest init --preset "{preset_url}"

# Add components
{pmx} shadcn@latest add {components}
{pmx} shadcn@latest add --all
```

See [references/shadcn.md](references/shadcn.md) for preset URL construction.

### Common Dependencies

```bash
# State Management
{pm} install zustand
{pm} install @tanstack/react-query
{pm} install jotai
{pm} install @reduxjs/toolkit react-redux

# Forms & Validation
{pm} install react-hook-form zod

# Testing
{pm} install -D vitest @testing-library/react
{pm} init playwright@latest

# Tooling
{pm} install -D @biomejs/biome && {pmx} @biomejs/biome init
```

## Directory Structure

See [references/architecture.md](references/architecture.md) for complete structures.

### Quick Reference

```bash
# Bulletproof / Feature-based
mkdir -p src/components/ui src/components/layouts src/features src/hooks src/lib src/stores src/types src/styles

# Clean Architecture
mkdir -p src/domain/{entities,usecases} src/data/{repositories,datasources} src/presentation/{pages,components,hooks}

# Simple
mkdir -p src/{components,pages,hooks,utils,types}
```

## Post-Setup

1. Run `{pm} run dev` to verify
2. Initialize git if requested: `git init && git add . && git commit -m "Initial commit"`
