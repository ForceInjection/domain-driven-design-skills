---
name: visual-verification
description: Visually verify implemented features work correctly before marking complete. Use when testing UI changes, verifying web features, or checking user flows work in the browser.
---

# Visual Verification

Verify implemented features work correctly through actual user interaction, not just automated tests.

## When to Use

- After implementing any UI feature
- Before marking an issue as complete
- When acceptance criteria involve user-visible behavior
- After fixing UI bugs

## Approaches

**Web Applications**: See [browser-verification.md](browser-verification.md) for Playwright MCP workflow.

**Mobile Applications**: See [mobile-verification.md](mobile-verification.md) *(Coming soon)*

## Verification Checklist

Before marking any UI task complete:

- [ ] Dev server is running and accessible
- [ ] Feature renders without console errors
- [ ] Elements render correctly and do not incorrectly overlap
- [ ] User interactions work as expected
- [ ] Edge cases handled (empty states, loading, errors)
- [ ] Screenshot captured as evidence

## What NOT to Do

- Skip visual verification because "tests pass"
- Mark issues complete without browser testing
- Assume dev mode catches all errors (run `npm run build` too)
- Test only happy paths
