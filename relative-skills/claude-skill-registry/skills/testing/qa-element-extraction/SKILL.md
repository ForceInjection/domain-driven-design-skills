---
name: qa-element-extraction
description: Extract and capture screenshots of specific UI elements mentioned in QA test procedures. Use when creating visual references for test steps to show exactly what buttons, fields, and components look like.
---

# QA Element Extraction Skill

Capture targeted screenshots of UI elements referenced in test procedures to create visual documentation.

## Purpose

When a test step says "Click the Login button", capture a screenshot of that specific button so testers know exactly what to look for. This creates a visual glossary alongside full-page screenshots.

## Element Screenshot Directory

```
qa-tests/
├── active/
│   └── QA-20250105-001-login.md        # QA test document
└── screenshots/
    └── QA-20250105-001/                 # Matches test-id
        ├── 01-initial-state.png         # Full page screenshots
        ├── 02-form-filled.png
        ├── 03-success-state.png
        └── elements/                     # Extracted UI elements
            ├── login-button.png
            ├── email-field.png
            └── password-field.png
```

**Note:** The `{test-id}` folder name (e.g., `QA-20250105-001`) matches the QA test document filename.

## Element Extraction Process

### Step 1: Parse Test Procedure

Identify actionable elements from test steps:

| Test Step Text | Element to Extract |
|----------------|-------------------|
| "Click the **Login** button" | Login button |
| "Enter email in the **Email** field" | Email input field |
| "Select **Settings** from dropdown" | Settings menu item |
| "Check the **Remember me** checkbox" | Remember me checkbox |
| "Click the **hamburger menu** icon" | Hamburger menu icon |

### Step 2: Element Identification Patterns

Look for these patterns in test steps:

```
Action + "the" + [Element Name] + element type
```

**Action verbs to scan:**
- Click, Tap, Press
- Enter, Type, Input
- Select, Choose, Pick
- Check, Uncheck, Toggle
- Hover, Focus
- Drag, Drop
- Scroll to

**Element type keywords:**
- button, btn, link
- field, input, textbox
- dropdown, select, combobox
- checkbox, radio, toggle
- icon, image, logo
- menu, nav, tab
- modal, dialog, popup
- card, tile, panel

### Step 3: Capture Element

Using Playwright MCP:

```javascript
// Find element by accessible name or text
const element = page.getByRole('button', { name: 'Login' });

// Capture just this element
await element.screenshot({
  path: 'qa-tests/screenshots/QA-20250105-001/elements/login-button.png'
});
```

## Element Screenshot Specifications

### Image Requirements

| Attribute | Specification |
|-----------|---------------|
| Format | PNG (transparency support) |
| Padding | 8-16px around element |
| Background | Capture with page background |
| State | Default state unless specified |
| Max width | 400px (scale down if larger) |

### Capture States

For interactive elements, capture multiple states:

```
elements/
├── login-button.png           # Default state
├── login-button-hover.png     # Hover state
├── login-button-focus.png     # Focus state
├── login-button-disabled.png  # Disabled state (if applicable)
```

## Element Reference Table

Generate a reference table in the test procedure:

```markdown
## Element Visual Reference

| Element | Screenshot | Selector | Notes |
|---------|------------|----------|-------|
| Login button | ![](./elements/login-button.png) | `button[name="login"]` | Blue primary button |
| Email field | ![](./elements/email-field.png) | `input#email` | With placeholder |
| Remember me | ![](./elements/remember-checkbox.png) | `input#remember` | Unchecked by default |
```

## Playwright Commands for Extraction

### By Role and Name
```javascript
// Button
const loginBtn = page.getByRole('button', { name: 'Login' });
await loginBtn.screenshot({ path: 'elements/login-button.png' });

// Link
const helpLink = page.getByRole('link', { name: 'Help' });
await helpLink.screenshot({ path: 'elements/help-link.png' });

// Input field
const emailInput = page.getByLabel('Email');
await emailInput.screenshot({ path: 'elements/email-field.png' });
```

### By Text Content
```javascript
// Element containing specific text
const submitBtn = page.getByText('Submit', { exact: true });
await submitBtn.screenshot({ path: 'elements/submit-button.png' });
```

### By Test ID
```javascript
// Using data-testid attribute
const navMenu = page.getByTestId('main-navigation');
await navMenu.screenshot({ path: 'elements/main-nav.png' });
```

### With Padding/Context
```javascript
// Capture parent for context
const field = page.locator('.form-group:has(#email)');
await field.screenshot({ path: 'elements/email-field-with-label.png' });
```

## Element Naming Convention

```
{element-name}[-{state}][-{variant}].png
```

### Examples

| Element | Filename |
|---------|----------|
| Login button | `login-button.png` |
| Login button hovered | `login-button-hover.png` |
| Submit button disabled | `submit-button-disabled.png` |
| Email field with error | `email-field-error.png` |
| Primary nav expanded | `primary-nav-expanded.png` |

## Extraction from Test Steps

### Input Format

```markdown
### TC-001: User Login

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Navigate to login page | Login form displays |
| 2 | Enter "test@example.com" in **Email field** | Email accepted |
| 3 | Enter "password123" in **Password field** | Password masked |
| 4 | Click **Login button** | Redirects to dashboard |
```

### Output: Element Extraction List

```markdown
## Elements to Capture

From TC-001:
- [ ] Email field (`input[type="email"]`)
- [ ] Password field (`input[type="password"]`)
- [ ] Login button (`button[type="submit"]`)

Capture command:
1. Navigate to login page
2. Take element screenshots before any interaction
```

## Glossary Building

Create a reusable element glossary for the application:

```
elements-glossary/
├── buttons/
│   ├── primary-button.png
│   ├── secondary-button.png
│   ├── danger-button.png
│   └── icon-button.png
├── forms/
│   ├── text-input.png
│   ├── text-input-error.png
│   ├── select-dropdown.png
│   ├── checkbox.png
│   └── radio-button.png
├── navigation/
│   ├── main-nav.png
│   ├── breadcrumb.png
│   └── sidebar-menu.png
└── feedback/
    ├── success-toast.png
    ├── error-alert.png
    └── loading-spinner.png
```

## Integration with Test Documentation

### Inline Element References

```markdown
#### Step 2: Enter credentials

Enter your email in the Email field:

![Email field](./elements/email-field.png)

Then enter your password in the Password field:

![Password field](./elements/password-field.png)
```

### Element Annotation

When extracting, note identifying characteristics:

```markdown
| Element | Visual | Identification Tips |
|---------|--------|---------------------|
| Login button | ![](./elements/login-button.png) | Blue button, right side of form, text "Log In" |
| Forgot password | ![](./elements/forgot-password-link.png) | Gray link below password field |
```

## Automated Extraction Workflow

When creating a new QA test:

1. **Parse test steps** for element references (bold text, quoted names)
2. **Navigate to test URL** using Playwright
3. **Locate each element** using accessibility tree or selectors
4. **Capture element screenshot** with consistent naming
5. **Generate element reference table** in test document
6. **Link screenshots** to corresponding test steps

## Handling Edge Cases

### Element Not Visible
```markdown
⚠️ Element "Submit button" not visible on initial load.
   Trigger: Appears after form validation passes.
   Action: Capture after filling required fields.
```

### Dynamic Elements
```markdown
⚠️ Element "Loading spinner" is transient.
   Capture: Use video or multiple timed captures.
```

### Multiple Matching Elements
```markdown
⚠️ Multiple "Delete" buttons found (3 instances).
   Resolution: Capture each with context or specify row/position.
   Files: delete-button-row-1.png, delete-button-row-2.png
```

## Quality Checklist

Before finalizing element screenshots:

- [ ] Element is clearly visible and not cropped
- [ ] Sufficient padding around element
- [ ] Default state captured (unless specific state needed)
- [ ] Filename follows naming convention
- [ ] Referenced in test procedure with correct path
- [ ] Alt text or caption describes the element
