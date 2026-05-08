---
name: tmux-playwright-dev
description: Live UI development workflow using tmux panes + Playwright for visual feedback. Start dev server in one pane, use Playwright for testing, screenshots, and mobile/responsive verification in real-time.
---

# Tmux + Playwright Live Development

Enables tight feedback loop for UI development with live visual verification.

## When to Use

- Building/debugging UI features
- Responsive design work (mobile/tablet/desktop)
- Visual regression testing
- Any task requiring "eyes on the UI"

## What This Does

1. **Detect tmux environment** - Find active pane to run commands
2. **Start dev server** - Launch in background (e.g., `just dev-noauth`)
3. **Playwright verification** - Navigate, screenshot, measure, interact
4. **Iterate** - Code changes → hot reload → verify → repeat

## Prerequisites

- Running inside tmux session
- MCP tmux tools available
- Playwright MCP server configured
- Dev server command known (just/npm/etc)

## Workflow Pattern

### 1. Setup Phase
```bash
# Find current tmux pane
mcp__tmux-mcp__list-sessions
mcp__tmux-mcp__list-windows
mcp__tmux-mcp__list-panes

# Start dev server in available pane
mcp__tmux-mcp__execute-command(paneId, "just dev-noauth")
# or: npm run dev, yarn dev, etc.
```

### 2. Development Loop
```typescript
// Navigate to localhost
mcp__playwright__browser_navigate("http://localhost:3000")

// Set viewport for testing
mcp__playwright__browser_resize(375, 667)  // mobile
mcp__playwright__browser_resize(768, 1024) // tablet
mcp__playwright__browser_resize(1920, 1080) // desktop

// Take screenshots for comparison
mcp__playwright__browser_take_screenshot("feature-mobile.png")

// Measure/verify (e.g., overflow detection)
mcp__playwright__browser_evaluate(() => {
  return {
    scrollWidth: document.body.scrollWidth,
    viewportWidth: window.innerWidth,
    hasOverflow: document.body.scrollWidth > window.innerWidth
  };
})

// Interact with UI
mcp__playwright__browser_click(element, ref)
mcp__playwright__browser_type(element, ref, text)
mcp__playwright__browser_snapshot() // accessibility tree
```

### 3. Make Changes
- Edit code in editor
- Hot reload updates browser automatically
- Playwright re-verifies
- Take new screenshots to compare

### 4. Cleanup
```typescript
mcp__playwright__browser_close()
// Dev server keeps running in tmux pane
```

## Example Use Cases

### Mobile Overflow Debugging
```
1. Start dev server in pane
2. Playwright → mobile viewport (375px)
3. Measure overflow with evaluate()
4. Find offending elements
5. Fix code → hot reload → verify
6. Screenshot before/after
```

### Component Visual Testing
```
1. Navigate to component page
2. Take baseline screenshot
3. Make styling changes
4. Auto-reload shows changes
5. Compare screenshots
6. Iterate until satisfied
```

### Responsive Design Validation
```
1. Test mobile (375px) → screenshot
2. Test tablet (768px) → screenshot
3. Test desktop (1920px) → screenshot
4. Verify layouts work at all breakpoints
```

## Best Practices

**Use tmux pane for:**
- Long-running dev server
- Background processes
- Keeping terminal visible for logs

**Use Playwright for:**
- Visual verification
- Measurement (widths, overflows, positions)
- Interaction testing
- Screenshot comparison
- Mobile/responsive testing

**Iteration speed:**
- Don't restart dev server between changes
- Let hot reload do its job
- Use evaluate() for quick measurements
- Screenshot for before/after comparison

## Tips

- **Viewport sizes**: 375 (mobile), 768 (tablet), 1920 (desktop)
- **Screenshot naming**: Use descriptive names with context (e.g., `mobile-card-overflow-fixed.png`)
- **Measure everything**: scrollWidth, clientWidth, computed styles
- **Test both views**: If app has list/card views, test both
- **Check actual rendering**: evaluate() > assumptions

## Example Session

```
User: "I need to add a new modal dialog"

1. Check tmux pane → dev server already running
2. Build modal component
3. Playwright navigate to page
4. Click trigger button
5. Screenshot modal open state
6. Test on mobile (375px)
7. Verify modal fits viewport
8. Test close button works
9. Screenshot different states
10. Done - modal works across viewports
```

## Integration with Existing Workflow

- **Complements** your existing development
- **No special setup** - uses tools you already have
- **On-demand** - only when you need visual feedback
- **Fast** - hot reload keeps iteration tight

## Common Patterns

**Pattern: "Does this fit mobile?"**
```
1. Resize to 375px
2. Evaluate scrollWidth > viewportWidth
3. If overflow: find elements, fix, verify
```

**Pattern: "How does this look across breakpoints?"**
```
1. Screenshot mobile (375px)
2. Screenshot tablet (768px)
3. Screenshot desktop (1920px)
4. Compare layouts
```

**Pattern: "Did my change break anything?"**
```
1. Baseline screenshot before change
2. Make change → hot reload
3. New screenshot after change
4. Visual diff comparison
```