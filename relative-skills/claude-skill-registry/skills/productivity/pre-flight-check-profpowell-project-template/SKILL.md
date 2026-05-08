---
name: pre-flight-check
description: "INVOKE FIRST before any code work. Validates git workflow (branch, issue, worklog) and checks approach. Use at START of every task and END before completing. Prevents skipped steps."
allowed-tools: Read, Glob, Grep, Bash
---

# Pre-Flight Check Skill

Before writing code, run through these checklists to validate your approach and catch potential issues early.

## ⚠️ MANDATORY: Git Workflow Check (DO THIS FIRST)

**STOP! Before ANY code changes, complete this checklist:**

### 1. Issue Check
```bash
# What issue are you working on?
bd show <issue-id>

# If no issue exists, create one first:
bd create --title="..." --type=feature|bug|task --priority=2
```
- [ ] Issue exists and is claimed (`bd update <id> --status=in_progress`)

### 2. Branch Check
```bash
# What branch are you on?
git branch --show-current

# Are you on main? CREATE A FEATURE BRANCH:
git checkout -b feature/<issue-id>-short-description
```
- [ ] On a feature branch (NOT main)
- [ ] Branch follows naming: `<type>/<issue-id>-description`

### 3. Worklog Check
```bash
# Does a worklog entry exist for this issue?
ls .worklog/*<issue-id>*
```
- [ ] Worklog entry exists or will be created before completing work

### Red Flags - STOP if any are true:
| Situation | Action Required |
|-----------|-----------------|
| No issue for this work | Run `bd create` first |
| On main branch | Run `git checkout -b feature/...` |
| Issue not claimed | Run `bd update <id> --status=in_progress` |

**Only proceed to code changes after ALL boxes are checked.**

---

## When to Use This Skill

Activate pre-flight checks when:
- Starting work on any issue (git workflow check FIRST)
- Creating a new file
- Making significant edits to existing code
- Implementing a new feature
- Uncertain about the right approach

## Quick Decision Tree

```
What are you creating?
│
├─ HTML page/component
│  └─ Use: HTML Pre-Flight Checklist
│     └─ Check: xhtml-author, accessibility-checker, metadata skills
│
├─ CSS file
│  └─ Use: CSS Pre-Flight Checklist
│     └─ Check: css-author, design-tokens skills
│
├─ JavaScript file
│  └─ Use: JavaScript Pre-Flight Checklist
│     └─ Check: javascript-author skill
│
├─ Form
│  └─ Use: Forms Pre-Flight Checklist
│     └─ Check: forms skill
│
├─ Image addition
│  └─ Use: Images Pre-Flight Checklist
│     └─ Check: responsive-images skill
│
└─ New site/project
   └─ Use: Site Essentials Pre-Flight Checklist
      └─ Check: site-scaffold skill
```

---

## Auto-Invoke Rules

These skills should be invoked automatically based on context:

| Context | Auto-invoke Skills |
|---------|-------------------|
| Any code change | **pre-flight-check** (this skill) - ALWAYS FIRST |
| Creating/editing .html | **xhtml-author**, **accessibility-checker** |
| Creating/editing .css | **css-author** |
| Creating/editing .js | **javascript-author** |
| Creating NEW .js/.ts file | **tdd** - Consider test-first approach |
| Adding icons/visual indicators | **icons** - NEVER use inline SVGs |
| Adding images | **responsive-images**, **placeholder-images** |
| Creating forms | **forms** - Use `<form-field>` pattern |
| API calls in code | **api-client** - Retry logic, error handling |
| Web Components | **custom-elements**, **state-management** |

### Common Multi-Skill Patterns

When building these features, invoke ALL listed skills:

| Feature | Skills to Invoke |
|---------|------------------|
| Theme toggle (dark/light) | css-author, javascript-author, data-storage, **icons**, progressive-enhancement |
| Contact form | xhtml-author, forms, accessibility-checker, javascript-author |
| Product card grid | xhtml-author, css-author, responsive-images, **icons** |
| Navigation menu | xhtml-author, css-author, **icons**, accessibility-checker |
| API integration | javascript-author, api-client, error-handling, state-management |
| User authentication | authentication, security, forms, javascript-author |

### Critical: Icons

**ALWAYS invoke the icons skill when adding visual indicators.** Theme toggles, buttons with icons, navigation icons, status indicators - ALL should use `<x-icon>`, never inline SVGs.

See [COMPOSITIONS.md](../COMPOSITIONS.md) for more multi-skill patterns.

---

## HTML Pre-Flight Checklist

Before writing HTML, verify:

### Structure
- [ ] What page type is this? (homepage, article, product, contact, etc.)
- [ ] What semantic landmark elements are needed? (`<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`)
- [ ] Is there existing content to preserve or migrate?
- [ ] What heading hierarchy makes sense? (single `<h1>`, logical `<h2>`-`<h6>`)

### Patterns to Consider
- [ ] Does this match an existing pattern in `.claude/patterns/pages/`?
- [ ] Are there custom elements in `.claude/schemas/elements.json` that apply?
- [ ] Should this use a documented page pattern from the `patterns` skill?

### Metadata
- [ ] What metadata profile applies? (default, article, product, etc.)
- [ ] Is Open Graph data needed for social sharing?
- [ ] What canonical URL should be used?

### Accessibility
- [ ] Will all interactive elements be keyboard accessible?
- [ ] Are proper ARIA labels planned for navigation regions?
- [ ] Will images have meaningful alt text?

### Potential Issues
| Issue | Check For |
|-------|-----------|
| Multiple `<h1>` | Only one per page allowed |
| Missing landmarks | Every page needs `<main>` |
| Div soup | Use semantic elements instead |
| Inline styles | Will fail validation |
| Missing lang | `<html lang="...">` required |

---

## CSS Pre-Flight Checklist

Before writing CSS, verify:

### Architecture
- [ ] Which layer does this belong to? (`base`, `components`, `utilities`, `overrides`)
- [ ] Does a token already exist for this value in `_tokens.css`?
- [ ] Is this component-scoped, section-scoped, or page-scoped?

### Patterns to Consider
- [ ] Can this use existing custom properties?
- [ ] Should this use native nesting (max depth 3)?
- [ ] Would `:has()` enable CSS-only interactivity?
- [ ] Are there existing patterns in `.claude/patterns/` or `.claude/styles/`?

### Selectors
- [ ] Using element or attribute selectors? (preferred over classes)
- [ ] Using `data-*` attributes for state? (not classes)
- [ ] Avoiding overly specific selectors?

### Potential Issues
| Issue | Check For |
|-------|-----------|
| Nesting > 3 levels | Will trigger stylelint warning |
| Magic numbers | Use tokens for spacing, colors |
| Class-based state | Use `data-*` attributes |
| Missing layer | CSS should use `@layer` |
| Duplicate properties | Same property twice in block |

---

## JavaScript Pre-Flight Checklist

Before writing JavaScript, verify:

### TDD Check (Test-First)
- [ ] Is this a new file or significant new functionality?
- [ ] Does a corresponding test file exist?
- [ ] If not, will you create the test FIRST? (Red-Green-Refactor)

| TDD Mode | Behavior |
|----------|----------|
| Advisory (default) | Reminder shown, can proceed |
| Strict (`/tdd strict`) | Must create test file before implementation |

To check TDD mode: `/tdd status`
To change mode: `/tdd strict` or `/tdd advisory`

### Architecture
- [ ] Is JavaScript actually needed? (CSS-only alternatives?)
- [ ] Is this a Web Component? (needs Shadow DOM, lifecycle methods)
- [ ] What's the functional core? (pure getters, computed values)
- [ ] What's the imperative shell? (DOM updates, event handlers)

### File Structure
- [ ] Does this need separate template/styles/i18n files?
- [ ] Where should this file live? (`src/components/`, `src/scripts/`)
- [ ] What should be exported? (named exports only)

### Patterns to Consider
- [ ] Language fallback chain pattern for i18n?
- [ ] CustomEvent for component communication?
- [ ] MutationObserver for lang changes?
- [ ] Cleanup in `disconnectedCallback`?

### Potential Issues
| Issue | Check For |
|-------|-----------|
| `var` usage | Use `const` or `let` |
| Default exports | Use named exports only |
| Missing cleanup | Memory leaks from listeners |
| No JSDoc | Document classes and public methods |
| Complexity > 10 | Refactor into smaller functions |

---

## Forms Pre-Flight Checklist

Before building forms, verify:

### Structure
- [ ] Using `<form-field>` custom element pattern?
- [ ] Is there a submit action and method defined?
- [ ] What validation is needed? (HTML5 attributes vs custom)

### Accessibility
- [ ] Every input has a `<label>` with matching `for`/`id`?
- [ ] Error messages have `<output>` containers?
- [ ] Required fields marked with `required` attribute?
- [ ] Field descriptions linked via `aria-describedby`?

### Patterns to Consider
- [ ] `<output>` for real-time validation feedback?
- [ ] `autocomplete` attributes for user convenience?
- [ ] `inputmode` for mobile keyboards?

### Potential Issues
| Issue | Check For |
|-------|-----------|
| Unlabeled inputs | Major accessibility violation |
| Missing autocomplete | Hurts user experience |
| No error containers | Where will errors display? |
| Hidden labels | Use `.visually-hidden`, not `display: none` |

---

## Images Pre-Flight Checklist

Before adding images, verify:

### Files
- [ ] Do WebP and AVIF alternatives exist?
- [ ] Is the file under 200KB?
- [ ] Are multiple sizes available for srcset?

### HTML Attributes
- [ ] `alt` attribute with meaningful description?
- [ ] `loading="lazy"` for below-fold images?
- [ ] `decoding="async"` for non-critical images?
- [ ] `width` and `height` for layout stability?

### Patterns to Consider
- [ ] Should this use `<picture>` for art direction?
- [ ] What `sizes` attribute values are needed?
- [ ] Should this be a `<figure>` with `<figcaption>`?

### Potential Issues
| Issue | Check For |
|-------|-----------|
| Missing alt | Accessibility violation |
| No modern formats | Large file sizes |
| Missing dimensions | Layout shift |
| No lazy loading | Performance impact |

---

## Site Essentials Pre-Flight Checklist

Before launching or when setting up a new site, verify these essentials exist:

### Core Files
- [ ] `robots.txt` - Search engine directives
- [ ] `sitemap.xml` - XML sitemap for crawlers
- [ ] `humans.txt` - Team credits and site info
- [ ] `manifest.json` - PWA web app manifest

### Error & Fallback Pages
- [ ] `404.html` - Not found error page
- [ ] `500.html` - Server error page (static, minimal dependencies)
- [ ] `offline.html` - Service worker offline fallback
- [ ] `noscript.html` - JavaScript-disabled fallback (if app requires JS)

### Security
- [ ] `.well-known/security.txt` - Security contact info (RFC 9116)

### Favicon Set
- [ ] `favicon.svg` - Vector favicon (modern browsers)
- [ ] `favicon.ico` - Legacy favicon (32x32)
- [ ] `apple-touch-icon.png` - iOS home screen (180x180)
- [ ] `icon-192.png` - PWA icon small
- [ ] `icon-512.png` - PWA icon large
- [ ] `og-image.png` - Social sharing (1200x630)

### Quick Check Command
```bash
# Check for essential files in site root
ls -la robots.txt sitemap.xml humans.txt manifest.json 404.html 500.html 2>/dev/null
ls -la .well-known/security.txt 2>/dev/null
```

### When to Create These

| File | When Required |
|------|---------------|
| robots.txt | All public sites |
| sitemap.xml | All public sites with multiple pages |
| 404.html | All sites |
| 500.html | All sites with server-side processing |
| offline.html | Sites with service workers |
| noscript.html | JS-required applications only |
| security.txt | Production sites accepting security reports |
| humans.txt | Optional, but good practice |

See `site-scaffold` skill for templates.

---

## Pattern Matching Guide

When the user says... suggest this pattern:

| User Intent | Suggested Pattern/Skill |
|-------------|------------------------|
| "add a page" | `patterns` skill, page templates |
| "create a form" | `forms` skill, `<form-field>` pattern |
| "add navigation" | `<nav>` with `aria-label` |
| "make it accessible" | `accessibility-checker` skill |
| "add an image" | `responsive-images` skill, `<picture>` |
| "style this" | `css-architecture` skill, layers |
| "add interactivity" | First check `progressive-enhancement` for CSS-only |
| "create a component" | `javascript-author` skill, Web Component |
| "add metadata" | `metadata` skill, profiles |
| "add dark mode" | `design-tokens` skill, color-scheme |

---

## Red Flags to Watch For

Stop and reconsider if you notice:

1. **"Just add a div"** - There's almost always a semantic element
2. **"Add a class for state"** - Use `data-*` attributes instead
3. **"Quick inline style"** - Will fail validation
4. **"Just copy this code"** - Check if a pattern/skill exists first
5. **"Add JavaScript for..."** - Check if CSS can do it first
6. **"Skip the alt text"** - Never acceptable
7. **"We'll fix it later"** - Validation catches issues now

---

## Verification Commands

After writing, verify with:

```bash
# HTML validation
npm run lint

# CSS validation
npm run lint:css

# JavaScript validation
npm run lint:js

# Accessibility check
npm run a11y

# Full validation
npm run lint:all
```

---

## ⚠️ MANDATORY: Completion Checklist (DO THIS LAST)

**Before saying "done", complete this checklist:**

### 1. Tests Pass
```bash
npm test
npm run lint:all
npm run test:coverage  # Check for missing tests
```
- [ ] All tests pass
- [ ] All linters pass
- [ ] New scripts have corresponding test files

### 2. Worklog Updated
- [ ] Worklog entry in `.worklog/` documents changes made
- [ ] Files modified are listed
- [ ] Any decisions/issues are noted

### 3. Commit Changes
```bash
git add <files>
git commit -m "type(scope): description"
```
- [ ] Changes committed with conventional commit format
- [ ] Commit message references issue if applicable

### 4. Request UAT
```bash
/uat request <feature-name>
# This adds uat:requested label to the issue
```
- [ ] UAT requested via `/uat request <feature-name>`
- [ ] Issue has `uat:requested` label
- [ ] Testing instructions provided for human in `.worklog/uat-<feature>.md`

### 5. Wait for Approval
```bash
# Check UAT status
/uat status <feature-name>
# Or check issue labels
bd show <issue-id>
```
- [ ] DO NOT close issue until `uat:approved` label is present
- [ ] If denied (`uat:denied` label), address feedback and re-request UAT
- [ ] Only close when approved: `bd close <issue-id>`

### Completion Red Flags:
| Situation | Action Required |
|-----------|-----------------|
| Tests failing | Fix before proceeding |
| No worklog entry | Create one now |
| On main branch | Should have been on feature branch |
| No UAT requested | Run `/uat request <feature-name>` |
| Closing without approval | STOP - check `bd show <id>` for `uat:approved` label |
| `uat:denied` label present | Address feedback, then `/uat request` again |

## Related Skills

- **git-workflow** - Enforce structured git workflow with conventional commits
- **tdd** - Test-Driven Development workflow for JS/TS files
- **unit-testing** - Write unit tests for JavaScript files
- **xhtml-author** - Write valid XHTML-strict HTML5 markup
- **css-author** - Modern CSS organization with @layer
- **javascript-author** - Vanilla JavaScript for Web Components
- **icons** - Lucide icon library with `<x-icon>` Web Component
- **forms** - HTML-first form patterns with CSS-only validation
- **accessibility-checker** - Ensure WCAG2AA accessibility compliance
