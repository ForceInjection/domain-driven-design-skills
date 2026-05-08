---
name: monet
description: Landing page component registry integration for searching, browsing, and pulling pre-built React/TypeScript components from the monet MCP server. Use this skill when users want to (1) search for UI components (hero sections, pricing tables, testimonials, etc.), (2) pull/add components to their project, (3) browse available component categories, (4) get component details or code, or (5) explore the component registry statistics.
---

# Monet Component Registry

This skill provides integration with the monet MCP server, a landing page component registry that offers pre-built React/TypeScript components for rapid development.

## Overview

The monet server runs at `http://localhost:3001` and provides a REST API for accessing a curated collection of landing page components including hero sections, pricing tables, testimonials, feature showcases, and more.

## Core Workflows

### 1. Search for Components

Use `scripts/search.py` to find components matching specific criteria:

```bash
python3 scripts/search.py "hero section"
python3 scripts/search.py "pricing" --category pricing --style minimal
python3 scripts/search.py "testimonial" --limit 5
```

The search supports:

- Natural language queries
- Category filtering (hero, pricing, feature, testimonial, etc.)

### 2. Pull Component Code

After finding a component, use `scripts/pull.py` to download and save it:

```bash
# Default: saves to src/components/sections/{component-id}.tsx
python3 scripts/pull.py hero-001

# Custom filename
python3 scripts/pull.py hero-001 --name modern-hero

# Custom path
python3 scripts/pull.py hero-001 --output src/components/custom/hero.tsx
```

The pull script:

- Fetches the component's React/TypeScript code
- Creates necessary directories if they don't exist
- Saves the component with proper naming
- Displays integration guide and dependencies

**Default behavior**: Components are saved to `src/components/sections/` by default, which is the standard location for section components in this project.

### 3. Browse and Explore

**List categories**:

```bash
python3 scripts/list_categories.py
```

**Get registry statistics**:

```bash
python3 scripts/get_stats.py
python3 scripts/get_stats.py --no-examples
```

**Get component details**:

```bash
python3 scripts/get_details.py hero-001
python3 scripts/get_details.py hero-001 --no-similar
```

## Recommended Workflow

When a user asks to add a component:

1. **Search** for relevant components using keywords and filters
2. **Review** the search results and present options to the user
3. **Get details** (optional) for specific components to see full information
4. **Pull** the chosen component(s) to the project
5. **Inform** the user about dependencies and integration steps

## Available Categories

- `hero` - Hero sections and landing page headers
- `pricing` - Pricing tables and payment components
- `feature` - Feature showcases and benefit sections
- `testimonial` - Customer testimonials and reviews
- `stats` - Statistics and metrics displays
- `cta` - Call-to-action sections
- `contact` - Contact forms and information
- `faq` - Frequently asked questions
- `how-it-works` - Process explanations
- `biography` - Team member profiles
- `before-after` - Comparison sections
- `showcase` - Product or portfolio showcases

## Tag System

Components are organized with multiple tag types:

- **Functional**: What the component does (cta, hero, pricing, form)
- **Style**: Visual design (minimal, modern, dark-theme, gradient)
- **Layout**: Structure (centered, grid, full-width, split, cards)
- **Industry**: Target market (saas, ecommerce, landing, portfolio)

## Examples

**Example 1: Add a minimal hero section**

```bash
python3 scripts/search.py "hero" --style minimal --limit 3
# Review results, then:
python3 scripts/pull.py hero-minimal-001 --name hero
```

**Example 2: Add a pricing table for SaaS**

```bash
python3 scripts/search.py "pricing" --industry saas
# Review results, then:
python3 scripts/pull.py pricing-saas-003
```

**Example 3: Explore what's available**

```bash
python3 scripts/list_categories.py
python3 scripts/get_stats.py
```

## API Reference

For detailed API documentation, see [references/api_reference.md](references/api_reference.md).

## Notes

- All scripts require the monet MCP server to be running at `localhost:3001`
- Components are React/TypeScript with Tailwind CSS styling
- Check dependencies after pulling components (displayed in pull output)
- Components may require additional npm packages (shown in integration guide)
