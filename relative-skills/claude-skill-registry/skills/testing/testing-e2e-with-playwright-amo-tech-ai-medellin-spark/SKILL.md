---
name: Testing E2E with Playwright
description: Run end-to-end browser tests using Playwright MCP. Use when testing web applications, validating user journeys, checking UI interactions, or when the user mentions E2E tests, browser automation, or Playwright.
version: 1.0.0
---

# Testing E2E with Playwright

## Quick Start

Run a complete E2E test using Playwright MCP:

1. **Take snapshot** to see page structure
2. **Click elements** using accessible names
3. **Fill forms** with user data
4. **Capture screenshots** for evidence
5. **Check console/network** for errors

## Basic Test Pattern

```typescript
// 1. Navigate
await browser_navigate({ url: "http://localhost:8080/pitch-deck-wizard" });

// 2. Get page structure
const snapshot = await browser_snapshot();

// 3. Interact with elements
await browser_type({
  element: "Chat input",
  ref: "input-chat",
  text: "Create a pitch deck for AI startup"
});

await browser_click({
  element: "Send button",
  ref: "btn-send"
});

// 4. Wait for response
await browser_wait_for({ text: "success" });

// 5. Capture evidence
await browser_take_screenshot({ filename: "result.png" });

// 6. Verify no errors
const errors = await browser_console_messages({ onlyErrors: true });
if (errors.length > 0) throw new Error("Console errors found");
```

## Available Playbooks

Choose the right playbook for your test type:

**Smoke test** (2 min) - Quick health check
- See [playbooks/smoke.md](playbooks/smoke.md)
- Verifies app loads, navigation works, no console errors

**Auth flow** (5 min) - Complete authentication journey
- See [playbooks/auth.md](playbooks/auth.md)
- Tests login, signup, protected routes, logout

**Pitch deck wizard** (10 min) - Full user journey
- See [playbooks/pitch-deck-wizard.md](playbooks/pitch-deck-wizard.md)
- AI conversation → data collection → deck generation → export

## Core Tools

### Essential (use in 90% of tests)

| Tool | Purpose | Example |
|------|---------|---------|
| `browser_navigate` | Go to URL | `browser_navigate({ url: "/dashboard" })` |
| `browser_snapshot` | Get page structure | `browser_snapshot()` |
| `browser_click` | Click elements | `browser_click({ element: "Button", ref: "btn-1" })` |
| `browser_type` | Enter text | `browser_type({ element: "Input", ref: "input-email", text: "test@example.com" })` |
| `browser_wait_for` | Wait for text/time | `browser_wait_for({ text: "Success" })` |
| `browser_take_screenshot` | Capture evidence | `browser_take_screenshot({ filename: "step1.png" })` |
| `browser_console_messages` | Check errors | `browser_console_messages({ onlyErrors: true })` |
| `browser_network_requests` | Verify API calls | `browser_network_requests()` |

### Advanced (use when needed)

- `browser_fill_form` - Fill multiple fields at once
- `browser_file_upload` - Upload files
- `browser_drag` - Drag and drop
- `browser_evaluate` - Run JavaScript
- `browser_handle_dialog` - Handle alerts/confirms

## Best Practices

### 1. Always snapshot first

```typescript
// ✅ GOOD: Get structure, then interact
const snapshot = await browser_snapshot();
// Find element refs in snapshot, then use them
await browser_click({ element: "Submit", ref: "btn-submit" });

// ❌ BAD: Guessing element references
await browser_click({ element: "Button", ref: "unknown" });
```

### 2. Wait for state changes

```typescript
// ✅ GOOD: Wait for confirmation
await browser_click({ element: "Save", ref: "btn-save" });
await browser_wait_for({ text: "Saved" });

// ❌ BAD: Assume immediate success
await browser_click({ element: "Save", ref: "btn-save" });
await browser_take_screenshot({ filename: "saved.png" }); // Too early!
```

### 3. Capture evidence

Take screenshots before and after critical actions:

```typescript
await browser_take_screenshot({ filename: "before-submit.png" });
await browser_click({ element: "Submit", ref: "btn-submit" });
await browser_wait_for({ text: "Success" });
await browser_take_screenshot({ filename: "after-submit.png" });
```

### 4. Check console and network

Always verify no errors at the end:

```typescript
const errors = await browser_console_messages({ onlyErrors: true });
if (errors.length > 0) {
  throw new Error(`Found ${errors.length} console errors`);
}

const requests = await browser_network_requests();
const failed = requests.filter(r => r.status >= 400);
if (failed.length > 0) {
  throw new Error(`${failed.length} API calls failed`);
}
```

## Common Workflows

### Testing a form submission

```typescript
await browser_navigate({ url: "http://localhost:8080/contact" });
await browser_fill_form({
  fields: [
    { name: "Email", type: "textbox", ref: "input-email", value: "test@example.com" },
    { name: "Message", type: "textbox", ref: "textarea-msg", value: "Test message" }
  ]
});
await browser_click({ element: "Submit", ref: "btn-submit" });
await browser_wait_for({ text: "Message sent" });
```

### Testing a complete user journey

See [playbooks/pitch-deck-wizard.md](playbooks/pitch-deck-wizard.md) for a full example with:
- Multi-step conversation flow
- Progress tracking validation
- Deck generation and verification
- Network/console monitoring

## Troubleshooting

### Element not found
- Run `browser_snapshot()` to see current page structure
- Check element is visible and has correct `ref`
- Wait for page load: `browser_wait_for({ time: 2 })`

### Timeout waiting for text
- Increase timeout: `browser_wait_for({ text: "Loading", timeout: 30000 })`
- Check if text appears at all (manual browser check)
- Look for alternative success indicators

### Dialog blocks test
- Handle dialogs immediately: `browser_handle_dialog({ accept: true })`
- Or dismiss: `browser_handle_dialog({ accept: false })`

## Running Tests

### Quick test (smoke)
```bash
npm run test:smoke
```

### Full journey (pitch deck wizard)
```bash
npm run test:pitch-deck
```

### With video recording
```bash
npx @playwright/mcp --save-video=1280x720 --output-dir=./test-results < playbooks/pitch-deck-wizard.md
```

### CI mode (headless)
```bash
npm run test:ci
```

## Reference

**Complete tool list**: See [../docs/04-playwrite.md](../docs/04-playwrite.md)
**Performance tips**: Use `--headless`, `--shared-browser-context`
**Security**: Use `--secrets .env` for credentials
