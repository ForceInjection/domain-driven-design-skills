---
name: wcag-compliance-checker
description: Checks websites for WCAG 2.1 Level AA compliance, identifies accessibility violations, and provides remediation guidance. Use when user asks to "check accessibility", "wcag compliance", "a11y audit", "accessibility violations", or "screen reader testing".
allowed-tools: [Read, Write, Bash, Glob, Grep]
---

# WCAG Compliance Checker

Audits web applications for WCAG 2.1 Level AA compliance and provides detailed remediation guidance.

## When to Use

- "Check WCAG compliance"
- "Accessibility audit"
- "Find accessibility violations"
- "Is my site accessible?"
- "Screen reader testing"
- "ADA compliance check"

## Instructions

### 1. Install Accessibility Testing Tools

```bash
# axe-core for automated testing
npm install --save-dev @axe-core/cli

# pa11y for command-line testing
npm install --save-dev pa11y

# jest-axe for React testing
npm install --save-dev jest-axe

# Lighthouse for overall audit
npm install --save-dev lighthouse
```

### 2. Run Automated Scan

**Using axe:**
```bash
# Scan a URL
npx axe https://your-site.com --save results.json

# Scan local file
npx axe file:///path/to/index.html

# Scan with specific rules
npx axe https://your-site.com --rules color-contrast,image-alt
```

**Using pa11y:**
```bash
# Basic scan
npx pa11y https://your-site.com

# With specific standard
npx pa11y --standard WCAG2AA https://your-site.com

# Multiple URLs
npx pa11y --sitemap https://your-site.com/sitemap.xml

# Generate HTML report
npx pa11y https://your-site.com --reporter html > report.html
```

**Using Lighthouse:**
```bash
lighthouse https://your-site.com --only-categories=accessibility --output html --output-path ./accessibility-report.html
```

### 3. Categorize Issues

## WCAG 2.1 Level AA Criteria

**Perceivable:**
- 1.1.1 Non-text Content (A)
- 1.2.1-1.2.5 Time-based Media (A/AA)
- 1.3.1-1.3.5 Adaptable (A/AA)
- 1.4.1-1.4.10 Distinguishable (A/AA)

**Operable:**
- 2.1.1-2.1.4 Keyboard Accessible (A/AA)
- 2.2.1-2.2.2 Enough Time (A)
- 2.3.1 Seizures (A)
- 2.4.1-2.4.7 Navigable (A/AA)
- 2.5.1-2.5.4 Input Modalities (A/AA)

**Understandable:**
- 3.1.1-3.1.2 Readable (A/AA)
- 3.2.1-3.2.4 Predictable (A/AA)
- 3.3.1-3.3.4 Input Assistance (A/AA)

**Robust:**
- 4.1.1-4.1.3 Compatible (A/AA)

### 4. Common Violations and Fixes

**1. Images without alt text (1.1.1)**

```jsx
// ❌ VIOLATION
<img src="logo.png" />

// ✅ FIX
<img src="logo.png" alt="Company Logo" />

// ✅ FIX (decorative)
<img src="decoration.png" alt="" role="presentation" />
```

**2. Insufficient color contrast (1.4.3)**

```css
/* ❌ VIOLATION: 2.8:1 contrast */
.text {
  color: #777;
  background: #fff;
}

/* ✅ FIX: 4.6:1 contrast (meets AA) */
.text {
  color: #595959;
  background: #fff;
}

/* ✅ BETTER: 7.0:1 contrast (meets AAA) */
.text {
  color: #333;
  background: #fff;
}
```

**Contrast requirements:**
- Normal text (AA): 4.5:1
- Normal text (AAA): 7:1
- Large text (AA): 3:1
- Large text (AAA): 4.5:1

**3. Missing form labels (3.3.2)**

```jsx
// ❌ VIOLATION
<input type="email" placeholder="Email" />

// ✅ FIX
<label htmlFor="email">Email Address</label>
<input type="email" id="email" name="email" />

// ✅ FIX (aria-label)
<input
  type="email"
  aria-label="Email Address"
  placeholder="Email"
/>
```

**4. Non-semantic HTML (1.3.1)**

```jsx
// ❌ VIOLATION
<div onClick={handleClick}>Click me</div>

// ✅ FIX
<button onClick={handleClick}>Click me</button>

// ❌ VIOLATION
<div className="heading">Page Title</div>

// ✅ FIX
<h1>Page Title</h1>
```

**5. Missing page language (3.1.1)**

```html
<!-- ❌ VIOLATION -->
<!DOCTYPE html>
<html>
  <head>...</head>
</html>

<!-- ✅ FIX -->
<!DOCTYPE html>
<html lang="en">
  <head>...</head>
</html>
```

**6. Keyboard navigation issues (2.1.1)**

```jsx
// ❌ VIOLATION: Not keyboard accessible
<div onClick={handleClick}>Menu</div>

// ✅ FIX
<button onClick={handleClick}>Menu</button>

// ✅ FIX (if must use div)
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick()
    }
  }}
>
  Menu
</div>
```

**7. Missing focus indicators (2.4.7)**

```css
/* ❌ VIOLATION */
button:focus {
  outline: none;
}

/* ✅ FIX */
button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ✅ BETTER: Custom but visible */
button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.5);
}
```

**8. Empty links/buttons (2.4.4)**

```jsx
// ❌ VIOLATION
<button onClick={handleDelete}>
  <TrashIcon />
</button>

// ✅ FIX
<button onClick={handleDelete} aria-label="Delete item">
  <TrashIcon aria-hidden="true" />
</button>
```

**9. Improper heading hierarchy (1.3.1)**

```jsx
// ❌ VIOLATION
<h1>Main Title</h1>
<h3>Subsection</h3> {/* Skipped h2 */}

// ✅ FIX
<h1>Main Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>
```

**10. Forms without error identification (3.3.1)**

```jsx
// ❌ VIOLATION
{error && <span className="error">{error}</span>}

// ✅ FIX
<input
  type="email"
  id="email"
  aria-invalid={!!error}
  aria-describedby={error ? "email-error" : undefined}
/>
{error && (
  <span id="email-error" role="alert">
    {error}
  </span>
)}
```

### 5. Automated Testing

**Jest + jest-axe:**

```javascript
import { render } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'

expect.extend(toHaveNoViolations)

test('should not have accessibility violations', async () => {
  const { container } = render(<MyComponent />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

**React Testing Library:**

```javascript
import { render, screen } from '@testing-library/react'
import { axe } from 'jest-axe'

test('button is accessible', async () => {
  const { container } = render(
    <button onClick={() => {}}>Click me</button>
  )

  const results = await axe(container)
  expect(results).toHaveNoViolations()

  // Also test keyboard
  const button = screen.getByRole('button')
  button.focus()
  expect(button).toHaveFocus()
})
```

**Cypress:**

```javascript
// Install cypress-axe
// npm install --save-dev cypress-axe

// cypress/support/e2e.js
import 'cypress-axe'

// Test
describe('Accessibility', () => {
  it('should not have violations', () => {
    cy.visit('/')
    cy.injectAxe()
    cy.checkA11y()
  })

  it('should check specific element', () => {
    cy.visit('/')
    cy.injectAxe()
    cy.checkA11y('.main-content')
  })
})
```

### 6. Manual Testing Checklist

**Keyboard Navigation:**
- [ ] All interactive elements reachable by Tab
- [ ] Focus order makes sense
- [ ] Focus indicators visible
- [ ] Can activate with Enter/Space
- [ ] Can escape from modals with Esc
- [ ] No keyboard traps

**Screen Reader Testing:**
- [ ] Test with NVDA (Windows, free)
- [ ] Test with JAWS (Windows, commercial)
- [ ] Test with VoiceOver (Mac/iOS, built-in)
- [ ] Test with TalkBack (Android, built-in)
- [ ] All content announced correctly
- [ ] Form errors announced
- [ ] Dynamic updates announced

**Visual Testing:**
- [ ] Color contrast meets 4.5:1 (normal text)
- [ ] Color contrast meets 3:1 (large text)
- [ ] Information not conveyed by color alone
- [ ] Text resizable to 200% without loss of content
- [ ] Content works at 320px width (mobile)

**Content Testing:**
- [ ] All images have alt text
- [ ] Videos have captions
- [ ] Audio has transcripts
- [ ] Forms have clear labels
- [ ] Error messages are clear
- [ ] Page titles are descriptive

### 7. Generate Compliance Report

**Report Template:**

```markdown
# WCAG 2.1 Level AA Compliance Report

**Site:** https://example.com
**Date:** 2024-01-15
**Standard:** WCAG 2.1 Level AA
**Tools:** axe-core, pa11y, Lighthouse, Manual testing

## Executive Summary

- **Total Issues:** 23
- **Critical:** 5
- **Serious:** 8
- **Moderate:** 7
- **Minor:** 3
- **Compliance Rate:** 78%

## Critical Issues (Must Fix)

### 1. Images missing alt text (1.1.1)
**Impact:** Screen reader users cannot understand image content
**Affected:** 15 images across 5 pages
**Fix:** Add descriptive alt attributes
**Priority:** Critical
**Effort:** Low

### 2. Insufficient color contrast (1.4.3)
**Impact:** Low vision users cannot read text
**Affected:** Navigation links (2.8:1 ratio, needs 4.5:1)
**Fix:** Darken text color from #777 to #595959
**Priority:** Critical
**Effort:** Low

### 3. Form fields without labels (3.3.2)
**Impact:** Screen readers cannot identify form purpose
**Affected:** Contact form (3 inputs)
**Fix:** Add <label> elements or aria-label
**Priority:** Critical
**Effort:** Low

### 4. Keyboard trap in modal (2.1.2)
**Impact:** Keyboard users cannot exit modal
**Affected:** Newsletter signup modal
**Fix:** Add focus trap with Escape key handler
**Priority:** Critical
**Effort:** Medium

### 5. Missing page language (3.1.1)
**Impact:** Screen readers use wrong pronunciation
**Affected:** All pages
**Fix:** Add lang="en" to <html> tag
**Priority:** Critical
**Effort:** Very Low

## Serious Issues (Should Fix)

[... more issues ...]

## Remediation Plan

### Phase 1: Critical Fixes (Week 1)
- Add alt text to all images
- Fix color contrast issues
- Add form labels
- Fix keyboard trap
- Add language attribute

**Estimated Time:** 8 hours
**Resources Needed:** 1 developer

### Phase 2: Serious Fixes (Week 2-3)
[...]

### Phase 3: Moderate Fixes (Week 4)
[...]

## Testing Strategy

1. Fix issues
2. Re-run automated tests
3. Manual keyboard testing
4. Screen reader testing (NVDA, VoiceOver)
5. User testing with people with disabilities

## Success Criteria

- Zero critical issues
- < 5 serious issues
- 95% compliance rate
- Pass manual testing
- User testing feedback positive
```

### 8. CI/CD Integration

**GitHub Actions:**

```yaml
name: Accessibility Check

on: [pull_request]

jobs:
  a11y:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Start server
        run: npm run serve &
        env:
          CI: true

      - name: Wait for server
        run: npx wait-on http://localhost:3000

      - name: Run accessibility tests
        run: |
          npm run test:a11y
          npx pa11y-ci

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: a11y-results
          path: a11y-results/
```

### 9. Ongoing Monitoring

**Setup continuous monitoring:**

```javascript
// In production, report violations
if (process.env.NODE_ENV === 'production') {
  import('react-axe').then((axe) => {
    axe.default(React, ReactDOM, 1000)
  })
}
```

**Monitor with Lighthouse CI:**

```javascript
// .lighthouserc.js
module.exports = {
  ci: {
    collect: {
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'color-contrast': 'error',
        'image-alt': 'error',
        'label': 'error',
        'html-has-lang': 'error',
      },
    },
  },
}
```

### 10. Documentation and Training

**Create accessibility guidelines:**

```markdown
# Accessibility Guidelines for Developers

## Before You Code
- [ ] Design includes focus indicators
- [ ] Color contrast checked
- [ ] Content structure defined (headings)

## While You Code
- [ ] Use semantic HTML
- [ ] Add ARIA only when needed
- [ ] Test with keyboard
- [ ] Run automated tests

## Before You Commit
- [ ] No axe violations
- [ ] Keyboard navigation works
- [ ] Focus visible on all elements
- [ ] Form labels present

## Before You Deploy
- [ ] Manual testing complete
- [ ] Screen reader testing done
- [ ] User testing feedback addressed
```

### Best Practices

**DO:**
- Start with semantic HTML
- Test early and often
- Use automated tools
- Do manual testing
- Include users with disabilities in testing
- Document accessibility decisions
- Train team on accessibility

**DON'T:**
- Remove focus outlines without replacement
- Use color alone to convey information
- Create keyboard traps
- Hide content that should be accessible
- Forget mobile accessibility
- Skip manual testing
- Assume automated tools catch everything

### Testing Tools Summary

**Automated:**
- axe-core: Most accurate, developer-friendly
- pa11y: Good for CI/CD
- Lighthouse: Overall score, Google-backed
- WAVE: Visual feedback, browser extension

**Manual:**
- NVDA: Free screen reader (Windows)
- JAWS: Professional screen reader (Windows)
- VoiceOver: Built-in (Mac/iOS)
- TalkBack: Built-in (Android)

**Browser Extensions:**
- axe DevTools
- WAVE
- Accessibility Insights
- Lighthouse

### Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM](https://webaim.org/)
- [A11Y Project](https://www.a11yproject.com/)
- [Inclusive Components](https://inclusive-components.design/)
