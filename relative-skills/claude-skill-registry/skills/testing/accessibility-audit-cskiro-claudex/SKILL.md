---
name: accessibility-audit
version: 0.1.1
description: Use PROACTIVELY when user asks for accessibility review, a11y audit, WCAG compliance check, screen reader testing, keyboard navigation validation, or color contrast analysis. Audits React/TypeScript applications for WCAG 2.2 Level AA compliance with risk-based severity scoring. Includes MUI framework awareness to avoid false positives. Not for runtime accessibility testing in production, automated remediation, or non-React frameworks.
author: Connor
triggers:
  - accessibility audit
  - WCAG compliance
  - a11y review
  - screen reader
  - keyboard navigation
  - color contrast
---

# Accessibility Audit Skill

Comprehensive WCAG 2.2 Level AA accessibility auditing for React/TypeScript applications with MUI framework awareness.

## Quick Reference

| Severity | Impact | Examples |
|----------|--------|----------|
| **Critical** | Blocks access completely | Keyboard traps, missing alt on actions, no focus visible |
| **High** | Significantly degrades UX | Poor contrast on CTAs, no skip navigation, small touch targets |
| **Medium** | Minor usability impact | Missing autocomplete, unclear link text |
| **Low** | Best practice enhancement | Could add tooltips, more descriptive titles |

## Key Principle

> **Severity = Impact x Likelihood**, NOT WCAG conformance level.
> A Level A failure can be LOW severity; a Level AA failure can be CRITICAL.

## Required Tooling

```bash
# Install required tools
npm install --save-dev eslint-plugin-jsx-a11y jest-axe @axe-core/playwright

# Configure ESLint
# Add to .eslintrc: extends: ['plugin:jsx-a11y/recommended']
```

## Workflow

| Phase | Description |
|-------|-------------|
| 1. Setup | Install tooling, create output directories |
| 2. Static Analysis | ESLint jsx-a11y scan |
| 3. Runtime Analysis | jest-axe and Playwright |
| 4. Manual Validation | Keyboard, screen reader, contrast |
| 5. Report Generation | JSON + Markdown outputs |

### Phase 1: Setup

See [workflow/setup.md](workflow/setup.md) for installation and configuration.

### Phase 4: Manual Validation

See [workflow/manual-validation.md](workflow/manual-validation.md) for keyboard and screen reader testing.

## Reference

- [Severity Rubric](reference/severity-rubric.md) - Impact x Likelihood calculation
- [MUI Framework Awareness](reference/mui-awareness.md) - Built-in accessibility features

## Common False Positives to Avoid

| Component | Built-in Behavior | Don't Flag |
|-----------|-------------------|------------|
| MUI `<SvgIcon>` | Auto `aria-hidden="true"` | Icons without titleAccess |
| MUI `<Alert>` | Default `role="alert"` | Missing role attribute |
| MUI `<Button>` | 36.5px min height | Target size < 44px |
| MUI `<TextField>` | Auto label association | Missing label |
| MUI `<Autocomplete>` | Manages ARIA attrs | Missing aria-expanded |

## Quick Audit Command

```
Run accessibility audit on [component/page] following WCAG 2.2 AA standards
```

## Related Skills

- `codebase-auditor` - General code quality analysis
- `bulletproof-react-auditor` - React architecture review
