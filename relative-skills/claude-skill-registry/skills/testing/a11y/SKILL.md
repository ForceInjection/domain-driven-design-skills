---
name: a11y
description: |
  Production-grade accessibility skill for WCAG 2.2 AA compliance.
  Covers auditing, remediation, component authoring, and validation workflows.
  Auto-invoked for UI implementation, a11y fixes, and accessibility testing.
---

Accessibility implementation guide aligned with WCAG 2.2 Level AA, WAI-ARIA 1.2, and WCAG2ICT.

## Standards Reference

| Standard | Scope | Normative Source |
|----------|-------|------------------|
| WCAG 2.2 | Web content | https://www.w3.org/TR/WCAG22/ |
| WAI-ARIA 1.2 | Widget semantics | https://www.w3.org/TR/wai-aria-1.2/ |
| ARIA APG | Authoring patterns | https://www.w3.org/WAI/ARIA/apg/ |
| WCAG2ICT | Non-web ICT | https://www.w3.org/TR/wcag2ict-22/ |
| EN 301 549 | EU procurement | ETSI EN 301 549 V3.2.1 |

## WCAG 2.2 New Success Criteria

| SC | Level | Requirement | Implementation |
|----|-------|-------------|----------------|
| 2.4.11 | AA | Focus Not Obscured (Minimum) | Ensure focused element is at least partially visible |
| 2.4.13 | AAA | Focus Appearance | Focus indicator area ≥ 2px perimeter, 3:1 contrast |
| 2.5.7 | A | Dragging Movements | Provide single-pointer alternative to drag operations |
| 2.5.8 | AA | Target Size (Minimum) | 24×24 CSS pixels minimum |
| 3.2.6 | A | Consistent Help | Place help mechanisms in same relative location |
| 3.3.7 | A | Redundant Entry | Auto-populate previously entered information |
| 3.3.8 | AA | Accessible Authentication | No cognitive function test for login |

## Critical Success Criteria

### Perceivable

| SC | Requirement | Implementation | Test |
|----|-------------|----------------|------|
| 1.1.1 | Non-text content | `alt` on images, `aria-label` on icon buttons | `img[alt]`, `button[aria-label]` |
| 1.3.1 | Info and relationships | Semantic HTML, no `<div>` for structure | Landmark audit |
| 1.4.3 | Contrast (minimum) | 4.5:1 text, 3:1 large text | axe `color-contrast` |
| 1.4.11 | Non-text contrast | 3:1 UI components/graphics | Manual inspection |

### Operable

| SC | Requirement | Implementation | Test |
|----|-------------|----------------|------|
| 2.1.1 | Keyboard | All functions keyboard-accessible | Tab traversal |
| 2.4.3 | Focus order | Logical DOM sequence | Visual focus path |
| 2.4.7 | Focus visible | 2px+ visible indicator | `focus-visible:ring-2` |
| 2.5.8 | Target size | Minimum 24x24 CSS pixels | `min-w-6 min-h-6` |

### Understandable

| SC | Requirement | Implementation | Test |
|----|-------------|----------------|------|
| 3.2.1 | On focus | No context change on focus | Focus does not submit |
| 3.3.1 | Error identification | Text description, not color alone | `role="alert"` present |

### Robust

| SC | Requirement | Implementation | Test |
|----|-------------|----------------|------|
| 4.1.2 | Name, role, value | Accessible name on all controls | axe `button-name` |

## Semantic HTML (Mandatory)

```tsx
// REQUIRED: Landmark structure
<header role="banner">...</header>
<nav aria-label="Main">...</nav>
<main role="main">...</main>
<aside role="complementary">...</aside>
<footer role="contentinfo">...</footer>

// PROHIBITED: Div-based structure
<div class="header">  // SC 1.3.1 violation
<div onClick={...}>   // SC 2.1.1, 4.1.2 violation
```

## Top 10 Violations with Fixes

### 1. Missing button name (SC 4.1.2)

```tsx
// BAD
<button onClick={handleDelete}><Trash2 /></button>

// GOOD
<button type="button" aria-label="Delete" onClick={handleDelete}>
  <Trash2 aria-hidden="true" />
</button>
```

### 2. Div as interactive element (SC 2.1.1, 4.1.2)

```tsx
// BAD
<div className="btn" onClick={handleClick}>Save</div>

// GOOD
<button type="button" onClick={handleClick}>Save</button>
```

### 3. Missing form label (SC 1.3.1, 4.1.2)

```tsx
// BAD
<input placeholder="Search..." />

// GOOD
<label htmlFor="search">Search</label>
<input id="search" type="search" />
// OR
<input type="search" aria-label="Search files" />
```

### 4. Color-only information (SC 1.4.1)

```tsx
// BAD
<input className={error ? "border-red-500" : ""} />

// GOOD
<input aria-invalid={!!error} aria-describedby="error-msg" />
{error && <span id="error-msg" role="alert">{error}</span>}
```

### 5. Missing alt text (SC 1.1.1)

```tsx
// BAD
<img src="/logo.png" />

// GOOD: Informative
<img src="/logo.png" alt="Company logo" />

// GOOD: Decorative
<img src="/decoration.png" alt="" role="presentation" />
```

### 6. Insufficient contrast (SC 1.4.3)

```css
/* BAD: ~2.5:1 ratio */
.muted { color: oklch(75% 0 0); }

/* GOOD: 4.5:1+ ratio */
.muted { color: oklch(45% 0 0); }
```

### Color Vision Deficiency (CVD) Support

Never rely on color alone to convey information (SC 1.4.1):

```tsx
// BAD: Color-only status
<span className={status === "error" ? "text-red-500" : "text-green-500"}>
  {status}
</span>

// GOOD: Color + icon + text
<span className={status === "error" ? "text-red-500" : "text-green-500"}>
  {status === "error" ? <AlertCircle aria-hidden /> : <CheckCircle aria-hidden />}
  {status === "error" ? "Error" : "Success"}
</span>
```

**Testing tools:**
- Chrome DevTools: Rendering → Emulate vision deficiencies
- Sim Daltonism (macOS)
- Color Oracle (Windows)

### 7. Missing focus indicator (SC 2.4.7)

```tsx
// BAD
<button className="outline-none">Action</button>

// GOOD
<button className="focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2">
  Action
</button>
```

### 8. Skipped heading levels (SC 1.3.1)

```tsx
// BAD
<h1>Title</h1>
<h3>Subsection</h3>  // h2 skipped

// GOOD
<h1>Title</h1>
<h2>Subsection</h2>
```

### 9. Small touch target (SC 2.5.8)

```tsx
// BAD: 16x16
<button className="p-0.5"><X size={12} /></button>

// GOOD: 24x24 minimum
<button className="p-2 min-w-6 min-h-6"><X size={16} /></button>
```

### 10. Auto-playing media (SC 1.4.2)

```tsx
// BAD
<video src="/demo.mp4" autoPlay />

// GOOD
<video src="/demo.mp4" autoPlay muted />
```

## Component Patterns

### TreeView (APG)

```tsx
<ul role="tree" aria-label="File explorer">
  <li
    role="treeitem"
    aria-expanded={isExpanded}
    aria-selected={isSelected}
    aria-level={level}
    aria-setsize={siblingCount}
    aria-posinset={position}
    tabIndex={isFocused ? 0 : -1}  // Roving tabindex
  >
    <span>{name}</span>
    {hasChildren && (
      <ul role="group">{children}</ul>
    )}
  </li>
</ul>
```

**Keyboard:** `↓↑` navigate, `→` expand/child, `←` collapse/parent, `Enter` activate, `Space` toggle, `Home/End` boundaries

### Modal Dialog (APG)

```tsx
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  tabIndex={-1}
>
  <h2 id="dialog-title">Title</h2>
  {/* Focus trap: Tab cycles within */}
  {/* Escape: closes dialog */}
  {/* On close: restore focus to trigger */}
</div>
```

### Toast/Alert

```tsx
<div role="alert" aria-live="polite" aria-atomic="true">
  {message}
</div>
// Error: aria-live="assertive"
```

## Focus Management

### Roving Tabindex

```tsx
// Only focused item has tabIndex={0}
{items.map((item, i) => (
  <button
    key={item.id}
    tabIndex={focusedIndex === i ? 0 : -1}
    onKeyDown={(e) => handleArrowKeys(e, i)}
  />
))}
```

### Focus Restoration

```tsx
// Store trigger before modal opens
const triggerRef = useRef<HTMLElement>(null)
const openModal = (e) => { triggerRef.current = e.currentTarget; setOpen(true) }
const closeModal = () => { setOpen(false); triggerRef.current?.focus() }
```

## Motion Preferences

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Validation Workflow

### Automated (CI)

```bash
# axe-core
npx @axe-core/cli <url> --tags wcag2a,wcag2aa,wcag22aa --exit

# Lighthouse
npx lighthouse <url> --only-categories=accessibility --output=json

# pa11y
npx pa11y <url> --standard WCAG2AA
```

### Manual Checklist

1. **Keyboard**: Tab through all controls, verify reachability
2. **Focus**: Confirm visible 2px+ ring on every interactive element
3. **Screen reader**: Test with NVDA/VoiceOver, verify announcements
4. **Zoom**: Scale to 200%, verify no content loss
5. **Motion**: Enable `prefers-reduced-motion`, verify compliance
6. **Contrast**: Check text 4.5:1, UI components 3:1
7. **Color blindness**: Test with vision deficiency emulation

### Screen Reader Testing Guide

**NVDA (Windows)**:
1. Press `Insert+Space` to toggle focus mode
2. `Insert+Down` to read all
3. `H` to navigate headings, `D` for landmarks
4. Verify: role, name, state announced correctly

**VoiceOver (macOS)**:
1. `Cmd+F5` to enable
2. `VO+A` to read all
3. `VO+U` to open rotor (headings, links, landmarks)
4. Verify: proper navigation, state changes announced

**Mobile (TalkBack/VoiceOver)**:
1. Swipe right to move forward
2. Double-tap to activate
3. Verify: touch targets accessible, gestures work

## Testable Assertions Template

```markdown
## Component: [Name]

### WCAG Compliance
- [ ] SC 1.3.1: Semantic structure
- [ ] SC 2.1.1: Keyboard operable
- [ ] SC 2.4.7: Focus visible
- [ ] SC 4.1.2: Accessible name

### Screen Reader
Expected: "[Role]: [Name], [State]"
```
