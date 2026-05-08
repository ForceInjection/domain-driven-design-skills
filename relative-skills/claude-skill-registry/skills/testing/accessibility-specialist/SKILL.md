---
name: Accessibility Specialist
description: Ensures web applications are accessible to all users including those with disabilities, following WCAG standards
when_to_use: when designing UIs, reviewing frontend code, testing user interfaces, or ensuring compliance with accessibility standards
version: 1.0.0
swecom_area: "13. Human-Computer Interaction"
---

# Accessibility Specialist

## Overview

The Accessibility Specialist ensures digital products are usable by everyone, including people with disabilities. This skill applies WCAG (Web Content Accessibility Guidelines) standards and provides practical guidance for accessible design and development.

## When to Use This Skill

- Designing new user interfaces
- Reviewing frontend code for accessibility
- Testing with assistive technologies
- Ensuring WCAG compliance
- Remediating accessibility issues
- Before launching public-facing features

## Critical Rules

1. **Accessibility is not optional** - Legal requirement in many jurisdictions
2. **Test with real assistive tech** - Don't assume automated tools catch everything
3. **Include users with disabilities** - Nothing about us without us
4. **Build in from the start** - Retrofitting is expensive and incomplete

## WCAG 2.1 Principles: POUR

### 1. Perceivable
**Information must be presentable to users in ways they can perceive**

#### 1.1 Text Alternatives
- All non-text content has text alternatives
- Images have meaningful alt text
- Decorative images have empty alt (`alt=""`)

#### 1.2 Time-based Media
- Captions for videos
- Transcripts for audio
- Audio descriptions for video

#### 1.3 Adaptable
- Content can be presented in different ways without losing information
- Semantic HTML (headings, lists, tables)
- Logical reading order
- No information conveyed by shape, size, location, or sound alone

#### 1.4 Distinguishable
- Color is not the only visual means of conveying information
- Sufficient color contrast (4.5:1 for normal text, 3:1 for large text)
- Text can be resized to 200% without loss of content
- Images of text avoided (use real text)

### 2. Operable
**User interface components must be operable**

#### 2.1 Keyboard Accessible
- All functionality available via keyboard
- No keyboard traps
- Keyboard shortcuts don't interfere with assistive tech

#### 2.2 Enough Time
- Users can extend time limits
- No auto-updating or moving content (or provide control)
- Interruptions can be postponed or suppressed

#### 2.3 Seizures and Physical Reactions
- No content flashing more than 3 times per second
- Provide alternatives for motion-triggered interactions

#### 2.4 Navigable
- Skip navigation links
- Descriptive page titles
- Logical focus order
- Link purpose clear from text
- Multiple ways to find pages (sitemap, search)
- Visible focus indicator
- Breadcrumbs for navigation

#### 2.5 Input Modalities
- Touch targets at least 44x44 pixels
- Support for alternative input methods
- Motion actuation has keyboard alternative

### 3. Understandable
**Information and operation must be understandable**

#### 3.1 Readable
- Page language identified (`lang` attribute)
- Unusual words explained
- Abbreviations expanded on first use
- Reading level appropriate (lower secondary education level)

#### 3.2 Predictable
- Consistent navigation
- Consistent identification (same icons/labels for same functions)
- Changes of context only on user request (not automatic)

#### 3.3 Input Assistance
- Clear error identification
- Labels or instructions for inputs
- Error suggestions provided
- Error prevention for legal/financial/data transactions
- Confirmation for irreversible actions

### 4. Robust
**Content must be robust enough for assistive technologies**

#### 4.1 Compatible
- Valid HTML (no parsing errors)
- Name, role, value for all UI components
- Status messages identified (ARIA live regions)

## WCAG Conformance Levels

### Level A (Minimum)
- Must satisfy all Level A criteria
- Bare minimum, still has significant barriers

### Level AA (Standard)
- Must satisfy all Level A and AA criteria
- Industry standard, legal requirement in many places
- Removes most barriers

### Level AAA (Enhanced)
- Must satisfy all Level A, AA, and AAA criteria
- Gold standard, not always achievable for all content

**Recommendation**: Target Level AA for all public-facing content

## Common Accessibility Issues & Fixes

### 1. Missing Alt Text

**Bad**:
```html
<img src="chart.png">
```

**Good**:
```html
<!-- Informative image -->
<img src="chart.png" alt="Sales increased 25% in Q3, from $400k to $500k">

<!-- Decorative image -->
<img src="divider.png" alt="" role="presentation">

<!-- Functional image (button) -->
<button>
  <img src="search.png" alt="Search">
</button>
```

**Guidelines**:
- Describe the information, not the image
- Keep it concise (<150 characters)
- Don't start with "Image of..." or "Picture of..."
- Decorative images: use empty alt (`alt=""`)

### 2. Poor Color Contrast

**Bad**:
```css
/* Light gray on white: 2.1:1 (FAIL) */
.text {
  color: #999;
  background: #fff;
}
```

**Good**:
```css
/* Dark gray on white: 7:1 (PASS AA & AAA) */
.text {
  color: #595959;
  background: #fff;
}

/* Or use high contrast mode */
@media (prefers-contrast: high) {
  .text {
    color: #000;
    background: #fff;
  }
}
```

**Tools**:
- WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/
- Chrome DevTools: Inspect > Accessibility > Contrast

**Thresholds**:
- Normal text: 4.5:1 (AA), 7:1 (AAA)
- Large text (18pt+): 3:1 (AA), 4.5:1 (AAA)
- UI components: 3:1 (AA)

### 3. Non-Keyboard Accessible

**Bad**:
```html
<div onclick="submit()">Submit</div>
```

**Good**:
```html
<!-- Use native button -->
<button onclick="submit()">Submit</button>

<!-- Or make div keyboard-accessible -->
<div
  role="button"
  tabindex="0"
  onclick="submit()"
  onkeypress="if(event.key==='Enter') submit()">
  Submit
</div>
```

**Best Practice**: Use native HTML elements (button, a, input) when possible

### 4. Missing Form Labels

**Bad**:
```html
<input type="text" placeholder="Email">
```

**Good**:
```html
<!-- Visible label -->
<label for="email">Email</label>
<input type="text" id="email" name="email">

<!-- Or use aria-label if visual label not desired -->
<input
  type="text"
  aria-label="Email"
  placeholder="you@example.com">
```

### 5. No Focus Indicators

**Bad**:
```css
/* Removes outline */
button:focus {
  outline: none;
}
```

**Good**:
```css
/* Custom visible focus indicator */
button:focus {
  outline: 3px solid #4A90E2;
  outline-offset: 2px;
}

/* Or use :focus-visible for keyboard-only */
button:focus-visible {
  outline: 3px solid #4A90E2;
  outline-offset: 2px;
}
```

### 6. Poor Heading Structure

**Bad**:
```html
<h1>Page Title</h1>
<h3>Section 1</h3> <!-- Skipped h2 -->
<h4>Subsection</h4>
<h3>Section 2</h3>
```

**Good**:
```html
<h1>Page Title</h1>
<h2>Section 1</h2>
<h3>Subsection</h3>
<h2>Section 2</h2>
```

**Rules**:
- One h1 per page
- Don't skip levels (h1 → h3)
- Use headings for structure, not styling

### 7. Inaccessible Modals/Dialogs

**Bad**:
```html
<div class="modal">
  <p>Are you sure?</p>
  <button>Yes</button>
  <button>No</button>
</div>
```

**Good**:
```html
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc">
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-desc">Are you sure you want to delete this item?</p>
  <button>Yes</button>
  <button>No</button>
</div>

<script>
// Trap focus within modal
// Return focus to trigger on close
// Close on Escape key
</script>
```

**Requirements**:
- Focus trapped in modal
- Escape key closes
- Focus returns to trigger element
- Background content inert (`aria-hidden="true"`)

### 8. No Skip Link

**Bad**:
```html
<!-- Long navigation, no way to skip -->
<nav><!-- 50 links --></nav>
<main>Content</main>
```

**Good**:
```html
<a href="#main" class="skip-link">Skip to main content</a>
<nav><!-- 50 links --></nav>
<main id="main">Content</main>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
</style>
```

## ARIA (Accessible Rich Internet Applications)

### When to Use ARIA

**First Rule of ARIA**: Don't use ARIA if native HTML works

**Good (Native HTML)**:
```html
<button>Click me</button>
```

**Unnecessary (ARIA on semantic HTML)**:
```html
<button role="button">Click me</button> <!-- redundant -->
```

**Necessary (Non-semantic element needs role)**:
```html
<div role="button" tabindex="0">Click me</div>
```

### ARIA Roles

**Landmark Roles**:
```html
<header role="banner">
<nav role="navigation">
<main role="main">
<aside role="complementary">
<footer role="contentinfo">
<form role="search"> <!-- for search forms -->
```

**Widget Roles**:
```html
<div role="button">
<div role="tab">
<div role="tabpanel">
<div role="dialog">
<div role="alert">
<div role="menu">
```

### ARIA States and Properties

**aria-label**: Provides accessible name
```html
<button aria-label="Close dialog">×</button>
```

**aria-labelledby**: References element(s) that label this element
```html
<div role="dialog" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Delete</h2>
</div>
```

**aria-describedby**: References element(s) that describe this element
```html
<input
  type="password"
  aria-describedby="password-hint">
<p id="password-hint">Must be at least 8 characters</p>
```

**aria-expanded**: Indicates expandable/collapsible state
```html
<button aria-expanded="false" aria-controls="submenu">
  Products
</button>
<ul id="submenu" hidden>...</ul>
```

**aria-hidden**: Hides content from assistive tech
```html
<span aria-hidden="true">★</span>
<span class="sr-only">4 out of 5 stars</span>
```

**aria-live**: Announces dynamic content changes
```html
<!-- Polite: announce when user is idle -->
<div aria-live="polite">Items in cart: 3</div>

<!-- Assertive: announce immediately -->
<div aria-live="assertive" role="alert">Error: Payment failed</div>
```

**aria-current**: Indicates current item in set
```html
<nav>
  <a href="/home">Home</a>
  <a href="/about" aria-current="page">About</a>
  <a href="/contact">Contact</a>
</nav>
```

## Testing Accessibility

### Automated Testing Tools

#### Browser Extensions
1. **axe DevTools** (Chrome/Firefox)
   - Comprehensive WCAG testing
   - Guided remediation

2. **WAVE** (Chrome/Firefox/Edge)
   - Visual feedback
   - Identifies issues inline

3. **Lighthouse** (Chrome DevTools)
   - Accessibility score
   - Performance + a11y

#### Command-Line Tools
```bash
# pa11y - automated testing
npm install -g pa11y
pa11y https://example.com

# axe-core CLI
npm install -g @axe-core/cli
axe https://example.com

# In CI/CD
npm test -- --a11y
```

#### Testing Libraries
```javascript
// Jest + jest-axe
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('Button is accessible', async () => {
  const { container } = render(<button>Click me</button>);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Manual Testing

#### Keyboard Navigation
**Test**:
- [ ] Tab through all interactive elements
- [ ] Shift+Tab to go backwards
- [ ] Enter/Space activates buttons
- [ ] Arrow keys for radio buttons, tabs, menus
- [ ] Escape closes dialogs
- [ ] No keyboard traps

**Common Issues**:
- Elements not reachable with keyboard
- Wrong tab order (use `tabindex` carefully)
- No visible focus indicator

#### Screen Reader Testing

**Tools**:
- **NVDA** (Windows, free): https://www.nvaccess.org/
- **JAWS** (Windows, commercial): https://www.freedomscientific.com/
- **VoiceOver** (Mac/iOS, built-in): Cmd+F5
- **TalkBack** (Android, built-in)

**Basic VoiceOver Commands** (Mac):
- Cmd+F5: Toggle on/off
- VO+A: Start reading
- VO+→: Next item
- VO+←: Previous item
- VO+Space: Activate

**Test Checklist**:
- [ ] All content is announced
- [ ] Navigation landmarks identified
- [ ] Form labels associated
- [ ] Buttons/links have meaningful text
- [ ] Images have alt text
- [ ] Tables have headers
- [ ] Dynamic content announced (aria-live)

#### Zoom/Magnification
**Test**:
- [ ] Zoom to 200% (Cmd/Ctrl + +)
- [ ] All content still visible
- [ ] No horizontal scrolling
- [ ] Text reflows properly

#### Color Blindness Simulation
**Tools**:
- Chrome DevTools > Rendering > Emulate vision deficiencies
- ColorOracle (desktop app)

**Test**:
- [ ] Red-green (protanopia/deuteranopia)
- [ ] Blue-yellow (tritanopia)
- [ ] Information not conveyed by color alone

## Accessibility Checklist

### Design Phase
- [ ] Color contrast ratios meet WCAG AA (4.5:1)
- [ ] UI components are at least 44x44px (touch targets)
- [ ] Information not conveyed by color alone
- [ ] Clear visual focus indicators designed
- [ ] Headings structure planned
- [ ] Form labels and error messages designed

### Development Phase
- [ ] Semantic HTML used (headings, lists, buttons, etc.)
- [ ] All images have alt text
- [ ] Forms have associated labels
- [ ] Keyboard navigation works
- [ ] Focus visible on all interactive elements
- [ ] ARIA used only when necessary
- [ ] Valid HTML (no parsing errors)
- [ ] Page language set (`<html lang="en">`)

### Testing Phase
- [ ] Automated tools pass (axe, WAVE, Lighthouse)
- [ ] Manual keyboard testing complete
- [ ] Screen reader testing complete
- [ ] Zoom to 200% works
- [ ] Color blindness simulation checked
- [ ] Tested on mobile (touch, zoom)

### Documentation Phase
- [ ] Accessibility statement published
- [ ] Keyboard shortcuts documented
- [ ] Known issues disclosed
- [ ] Feedback mechanism provided

## Common Patterns

### Accessible Dropdown Menu
```html
<nav>
  <button
    aria-expanded="false"
    aria-controls="submenu"
    id="menu-button">
    Products
    <span aria-hidden="true">▼</span>
  </button>
  <ul id="submenu" hidden>
    <li><a href="/product1">Product 1</a></li>
    <li><a href="/product2">Product 2</a></li>
  </ul>
</nav>

<script>
const button = document.getElementById('menu-button');
const menu = document.getElementById('submenu');

button.addEventListener('click', () => {
  const isExpanded = button.getAttribute('aria-expanded') === 'true';
  button.setAttribute('aria-expanded', !isExpanded);
  menu.hidden = isExpanded;
});

// Close on Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !menu.hidden) {
    button.setAttribute('aria-expanded', 'false');
    menu.hidden = true;
    button.focus();
  }
});
</script>
```

### Accessible Tab Interface
```html
<div class="tabs">
  <div role="tablist" aria-label="Content sections">
    <button role="tab" aria-selected="true" aria-controls="panel1" id="tab1">
      Tab 1
    </button>
    <button role="tab" aria-selected="false" aria-controls="panel2" id="tab2">
      Tab 2
    </button>
  </div>

  <div role="tabpanel" id="panel1" aria-labelledby="tab1">
    Content 1
  </div>
  <div role="tabpanel" id="panel2" aria-labelledby="tab2" hidden>
    Content 2
  </div>
</div>

<script>
// Arrow key navigation
// Home/End to first/last tab
// Activate on click or Enter/Space
</script>
```

### Accessible Modal Dialog
```html
<button id="open-dialog">Open Dialog</button>

<div
  id="dialog"
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  hidden>
  <h2 id="dialog-title">Dialog Title</h2>
  <p>Dialog content</p>
  <button id="close-dialog">Close</button>
</div>

<script>
const openBtn = document.getElementById('open-dialog');
const dialog = document.getElementById('dialog');
const closeBtn = document.getElementById('close-dialog');

openBtn.addEventListener('click', () => {
  dialog.hidden = false;
  // Trap focus in dialog
  closeBtn.focus();
  // Set background inert
  document.body.setAttribute('aria-hidden', 'true');
});

closeBtn.addEventListener('click', () => {
  dialog.hidden = true;
  // Return focus
  openBtn.focus();
  // Remove inert
  document.body.removeAttribute('aria-hidden');
});

// Close on Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !dialog.hidden) {
    closeBtn.click();
  }
});
</script>
```

## Output Format

After accessibility review:

```markdown
# Accessibility Audit: [Feature/Page Name]

## Summary
- **WCAG Level**: AA (Target)
- **Automated Score**: 87/100 (Lighthouse)
- **Manual Testing**: Completed
- **Critical Issues**: 2
- **Moderate Issues**: 5
- **Minor Issues**: 3

## Critical Issues (Must Fix Before Launch)

### 1. Missing Skip Navigation Link
**Location**: All pages
**WCAG**: 2.4.1 Bypass Blocks (Level A)
**Impact**: Keyboard users must tab through entire nav (50+ links)
**Fix**:
```html
<a href="#main" class="skip-link">Skip to main content</a>
```
**Effort**: 30 minutes

### 2. Form Inputs Without Labels
**Location**: Login page, Contact form
**WCAG**: 3.3.2 Labels or Instructions (Level A)
**Impact**: Screen reader users don't know what to enter
**Fix**: Associate labels with inputs
```html
<label for="email">Email</label>
<input type="email" id="email">
```
**Effort**: 1 hour

## Moderate Issues (Address Soon)

### 3. Insufficient Color Contrast
**Locations**:
- Button text: 3.2:1 (needs 4.5:1)
- Link color: 3.8:1 (needs 4.5:1)
**WCAG**: 1.4.3 Contrast (Level AA)
**Impact**: Users with low vision can't read text
**Fix**: Darken text colors
**Effort**: 2 hours

### 4. Images Missing Alt Text
**Location**: Product gallery (12 images)
**WCAG**: 1.1.1 Non-text Content (Level A)
**Impact**: Screen reader users don't know what images show
**Fix**: Add descriptive alt text
**Effort**: 3 hours

## Minor Issues (Nice to Have)

### 5. No Focus Indicator on Custom Buttons
**Location**: Navigation menu
**WCAG**: 2.4.7 Focus Visible (Level AA)
**Impact**: Keyboard users can't see where they are
**Fix**: Add `:focus-visible` styles
**Effort**: 1 hour

## Testing Results

### Automated Testing
| Tool | Score | Issues Found |
|------|-------|--------------|
| Lighthouse | 87/100 | 10 |
| axe DevTools | 8 issues | 2 critical, 6 serious |
| WAVE | 6 errors | 12 alerts |

### Manual Testing
- [x] Keyboard navigation (2 traps found, fixed)
- [x] Screen reader (NVDA on Windows)
- [x] Zoom to 200% (minor reflow issue)
- [x] Color blindness simulation (passed)

### Assistive Technology Coverage
- [x] NVDA (Windows screen reader)
- [ ] JAWS (Windows screen reader) - Need license
- [x] VoiceOver (Mac screen reader)
- [x] Mobile (iOS VoiceOver, Android TalkBack)

## Recommendations

### Immediate Actions (Before Launch)
1. Fix critical issues (#1, #2)
2. Fix moderate issues (#3, #4)
3. Re-test with automated tools
4. Final screen reader test

### Short-Term (Within 30 Days)
1. Fix minor issues
2. Conduct user testing with people with disabilities
3. Publish accessibility statement
4. Set up automated a11y tests in CI/CD

### Long-Term (Ongoing)
1. Train team on accessibility
2. Include accessibility in design system
3. Regular audits (quarterly)
4. Monitor for regressions (automated)

## Accessibility Statement Draft

```markdown
# Accessibility Statement

[Company] is committed to ensuring digital accessibility for people with disabilities. We are continually improving the user experience for everyone and applying relevant accessibility standards.

## Conformance Status
We aim to conform to WCAG 2.1 Level AA standards.

## Feedback
We welcome your feedback on accessibility. Please contact:
- Email: accessibility@example.com
- Phone: 555-0100

## Known Issues
- Video content does not yet have captions (in progress)
- Some PDF documents are not fully accessible (converting)

Last updated: [Date]
```

## Next Steps
1. Fix 2 critical issues (skip link, form labels)
2. Fix 5 moderate issues (contrast, alt text)
3. Re-audit with axe/WAVE
4. Schedule user testing with assistive tech users
5. Publish accessibility statement
```

## Boundaries

**This skill does NOT**:
- Design UX flows (that's UX design)
- Implement features (that's development)
- Make product decisions (that's product management)

**This skill DOES**:
- Audit accessibility compliance
- Identify WCAG violations
- Recommend fixes
- Test with assistive technologies
- Create accessibility documentation

## Related Skills

- Code Quality Engineer (`~/.claude/skills/lifecycle/construction/code_quality/SKILL.md`) - Enforces accessible coding standards
- QAS Agent (`~/.claude/skills/lifecycle/testing/acceptance_testing/SKILL.md`) - Includes a11y tests in test suites
- Tech Writer (`~/.claude/skills/crosscutting/quality/documentation/SKILL.md`) - Documents accessibility features

## Resources

### Standards
- **WCAG 2.1**: https://www.w3.org/WAI/WCAG21/quickref/
- **ARIA Authoring Practices**: https://www.w3.org/WAI/ARIA/apg/

### Tools
- **axe DevTools**: Browser extension for testing
- **WAVE**: Visual accessibility evaluation
- **Pa11y**: Automated testing CLI
- **Lighthouse**: Chrome DevTools audit

### Training
- **WebAIM**: https://webaim.org/
- **Deque University**: https://dequeuniversity.com/
- **A11ycasts** (YouTube): Short accessibility videos

### Testing with Assistive Tech
- **NVDA** (free): https://www.nvaccess.org/
- **VoiceOver** (built-in Mac/iOS)
- **TalkBack** (built-in Android)

## Version History
- 1.0.0 (2025-10-17): Initial skill creation (SWECOM gap fill)
