---
name: qa-screenshot-management
description: Screenshot capture, organization, and comparison for QA testing. Use when taking screenshots during test execution to ensure proper naming, organization, and traceability back to test cases.
---

# QA Screenshot Management Skill

Standardize screenshot capture and organization during QA testing.

## Directory Structure

```
qa-tests/
├── draft/                           # QA test documents by status
├── active/
├── executed/
├── archived/
└── screenshots/
    ├── {test-id}/                   # e.g., QA-20250105-001
    │   ├── 01-initial-state.png     # Numbered sequence
    │   ├── 02-form-filled.png
    │   ├── 03-success-state.png
    │   └── elements/                # Extracted UI elements
    │       ├── login-button.png
    │       ├── email-field.png
    │       └── password-field.png
    ├── baseline/                    # Reference screenshots for comparison
    │   └── {feature}/
    │       └── {state}.png
    └── failures/                    # Failed test evidence
        └── {date}/
            └── {test-id}-{timestamp}.png
```

**Key:** Screenshots are stored in `qa-tests/screenshots/{test-id}/` where `{test-id}` matches the QA test document name (e.g., `QA-20250105-001`).

## Naming Convention

### Format
```
{sequence}-{state-description}.{png|jpeg}
```

### Sequence Numbers
- `01-` through `99-` for ordered steps
- Preserves execution order in file listings

### State Descriptions
Use descriptive, kebab-case names:

| State | Example Filename |
|-------|------------------|
| Initial page load | `01-initial-state.png` |
| After form fill | `02-form-filled.png` |
| Validation error | `03-validation-error.png` |
| Success message | `04-success-message.png` |
| Modal open | `05-modal-open.png` |
| Dropdown expanded | `06-dropdown-expanded.png` |

### Bad vs Good Names

| Bad | Good |
|-----|------|
| `screenshot1.png` | `01-login-page-loaded.png` |
| `test.png` | `02-credentials-entered.png` |
| `error.png` | `03-invalid-password-error.png` |
| `final.png` | `04-dashboard-after-login.png` |

## When to Capture Screenshots

### Always Capture

1. **Initial State** - Before any test actions
2. **After Critical Actions** - Form submissions, navigation
3. **Error States** - Any validation or system errors
4. **Success States** - Confirmation messages, completed flows
5. **Final State** - End of test case

### Conditional Capture

- Unexpected behavior (document with timestamp)
- Performance issues (loading spinners, delays)
- UI anomalies (layout issues, missing elements)

## Screenshot Metadata

Include metadata in test documentation:

```markdown
### Screenshots

| # | Filename | Description | Step |
|---|----------|-------------|------|
| 1 | 01-initial-state.png | Login page before input | TC-001 Step 1 |
| 2 | 02-credentials-entered.png | Form with test credentials | TC-001 Step 2 |
| 3 | 03-dashboard-loaded.png | Dashboard after successful login | TC-001 Step 3 |
```

## Playwright Screenshot Commands

### Basic Capture
```javascript
// Full viewport
await page.screenshot({ path: 'screenshots/01-initial-state.png' });

// Full page (scrollable)
await page.screenshot({
  path: 'screenshots/02-full-page.png',
  fullPage: true
});
```

### Element Screenshot
```javascript
// Specific element only
const element = page.locator('.error-message');
await element.screenshot({ path: 'screenshots/03-error-detail.png' });
```

### With Timestamp
```javascript
const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
await page.screenshot({
  path: `screenshots/failure-${timestamp}.png`
});
```

## Visual Comparison Strategy

### Baseline Management

1. **Create Baseline**
   - Capture reference screenshots on approved build
   - Store in `screenshots/baseline/{feature}/`
   - Version control baselines

2. **Compare During Testing**
   - Capture current state
   - Compare against baseline
   - Document differences

### Acceptable Differences

| Type | Action |
|------|--------|
| Dynamic content (dates, times) | Mask or ignore region |
| User-specific data | Use consistent test data |
| Animations | Wait for stable state |
| Random elements (ads) | Exclude from comparison |

## Failure Documentation

When a test fails, capture:

```
screenshots/failures/2025-01-05/
├── QA-20250105-001-TC-002-1704456789.png  # Actual state
├── QA-20250105-001-TC-002-expected.png    # Expected (if applicable)
└── QA-20250105-001-TC-002-diff.png        # Visual diff (if generated)
```

### Failure Screenshot Checklist

- [ ] Capture full page showing context
- [ ] Capture specific element with issue
- [ ] Note browser console errors
- [ ] Record timestamp
- [ ] Link to test case and step

## Cross-Browser Screenshots

Organize by browser when testing multiple browsers:

```
screenshots/{test-id}/
├── chrome/
│   ├── 01-initial-state.png
│   └── 02-final-state.png
├── firefox/
│   └── ...
└── safari/
    └── ...
```

## Responsive Screenshots

Capture at standard breakpoints:

| Device | Width | Suffix |
|--------|-------|--------|
| Mobile | 375px | `-mobile` |
| Tablet | 768px | `-tablet` |
| Desktop | 1280px | `-desktop` |
| Wide | 1920px | `-wide` |

Example:
```
01-homepage-mobile.png
01-homepage-tablet.png
01-homepage-desktop.png
```

## Screenshot Cleanup

### Retention Policy

| Category | Retention |
|----------|-----------|
| Passing tests | Delete after test run |
| Failing tests | Keep until issue resolved |
| Baselines | Keep in version control |
| Regression evidence | Keep 30 days minimum |

### Cleanup Command

```bash
# Remove screenshots older than 30 days from failures
find qa-tests/screenshots/failures -mtime +30 -delete
```

## Integration with Test Reports

Reference screenshots in test execution logs:

```markdown
## Test Execution Log

| Date | Tester | Result | Evidence |
|------|--------|--------|----------|
| 2025-01-05 | Jane | FAIL | [Screenshots](./screenshots/QA-20250105-001/) |
```

## Accessibility Screenshot Guidelines

When documenting accessibility issues:

1. **Highlight Problem Area**
   - Use browser dev tools to highlight element
   - Capture with focus indicator visible

2. **Include Context**
   - Show surrounding elements
   - Capture screen reader output if relevant

3. **Document Fix Verification**
   - Before screenshot
   - After screenshot
   - Side-by-side comparison
