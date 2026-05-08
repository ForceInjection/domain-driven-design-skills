---
name: Browser Testing Patterns
description: This skill should be used when performing browser-based exploratory testing of web applications, including functional testing, visual inspection, accessibility checks, and performance analysis. Triggers when testing web UIs, checking for browser bugs, validating WCAG compliance, or measuring Core Web Vitals.
version: 0.1.0
---

# Browser Testing Patterns

## Purpose

Provide systematic patterns and best practices for autonomous browser-based exploratory testing using Playwright MCP. Guide agents through comprehensive web application testing including functional validation, visual inspection, accessibility compliance, and performance measurement.

## Core Testing Methodology

### Systematic Exploration Approach

Test web applications using a structured layered approach:

1. **Initial reconnaissance**: Navigate to target, capture state
2. **Functional testing**: Interact with elements, test workflows
3. **Accessibility validation**: Check WCAG compliance
4. **Performance measurement**: Analyze Core Web Vitals
5. **Visual inspection**: Detect layout issues
6. **Reporting**: Categorize and document findings

### Prioritization Framework

Focus testing effort based on user impact:

**Critical (test thoroughly):**
- User authentication and authorization
- Payment and transaction flows
- Data submission and persistence
- Primary user workflows

**Important (test systematically):**
- Navigation and routing
- Form validation and error handling
- Search and filtering
- Content display

**Secondary (spot check):**
- Footer links and secondary pages
- Help documentation
- Administrative features

## Functional Testing Patterns

### Element Interaction Strategy

Test interactive elements systematically:

1. **Identify interactive elements**: Use browser_snapshot to find buttons, links, inputs
2. **Click testing**: Click each button/link, verify expected behavior
3. **Form testing**: Fill forms with valid and invalid data, submit and verify
4. **Keyboard testing**: Tab through forms, test Enter/Escape keys
5. **Error states**: Trigger validation errors, check messages

### Console Error Detection

Check for JavaScript errors:

```markdown
Use browser_console_messages with level "error" to detect:
- Uncaught exceptions
- Failed network requests
- Resource loading failures
- Runtime errors

Categorize console errors:
- **Critical**: Breaks functionality (TypeError, ReferenceError)
- **Warning**: Degraded experience (404 for non-critical resources)
- **Info**: Non-blocking issues (deprecation warnings)
```

### Network Request Validation

Analyze network traffic:

```markdown
Use browser_network_requests to check:
- Failed requests (404, 500 errors)
- Slow requests (>2 seconds)
- Large responses (>1MB)
- Excessive request count (>50 per page)

Report network issues clearly:
- URL and method
- Status code and response time
- Whether it blocks functionality
```

## Accessibility Testing Patterns

### WCAG 2.1 Level AA Checklist

Test for common accessibility violations:

**Perceivable:**
- All images have alt text
- Video/audio has captions or transcripts
- Color contrast meets 4.5:1 ratio
- Content is not conveyed by color alone

**Operable:**
- All functionality available via keyboard
- No keyboard traps
- Sufficient time for interactions
- Focus visible on interactive elements

**Understandable:**
- Form labels are clear and associated
- Error messages are helpful
- Consistent navigation
- Predictable behavior

**Robust:**
- Valid HTML structure
- Proper heading hierarchy (h1 → h2 → h3)
- ARIA labels where needed
- Form controls have accessible names

### Keyboard Navigation Testing

Test keyboard usability:

```markdown
Use browser_press_key to test:
1. Tab - Focus moves logically through page
2. Shift+Tab - Reverse focus order works
3. Enter - Activates buttons and links
4. Escape - Closes modals and dropdowns
5. Arrow keys - Navigate within components

Verify:
- Focus is visible (outline/highlight)
- Tab order is logical
- All interactive elements reachable
- No keyboard traps
```

## Performance Testing Patterns

### Core Web Vitals Measurement

Measure key performance metrics using browser_evaluate:

```javascript
// Largest Contentful Paint (LCP)
const lcp = performance.getEntriesByType('largest-contentful-paint')[0]?.renderTime;

// First Input Delay (FID)
const fid = performance.getEntriesByType('first-input')[0]?.processingStart;

// Cumulative Layout Shift (CLS)
const cls = performance.getEntriesByType('layout-shift').reduce((sum, entry) => sum + entry.value, 0);
```

**Thresholds (Google standards):**
- LCP: <2.5s (good), 2.5-4s (needs improvement), >4s (poor)
- FID: <100ms (good), 100-300ms (needs improvement), >300ms (poor)
- CLS: <0.1 (good), 0.1-0.25 (needs improvement), >0.25 (poor)

### Network Performance Analysis

Analyze request patterns:

```markdown
Check network_requests for:
- Total request count (>50 = potential issue)
- Total data transferred (>2MB = optimization needed)
- Slow requests (>2s)
- Failed requests (404, 500)
- Unnecessary requests (duplicate fetches)
```

## Visual Testing Patterns

### Layout Issue Detection

Identify visual problems:

**Look for:**
- Overlapping elements (z-index issues)
- Cut-off text or content (overflow problems)
- Elements positioned outside viewport
- Missing spacing (elements touching)
- Inconsistent styling

**When to screenshot:**
- Visual issue detected (not routinely)
- Layout appears broken
- Content is cut off or overlapping
- Responsive design fails

### Screenshot Strategy

Take screenshots efficiently:

```markdown
Use browser_take_screenshot:
- ONLY when visual issue detected
- Include context (full page or specific element)
- Use descriptive filenames
- Reference in report clearly

Avoid:
- Screenshots of every action
- Screenshots with no issues
- Redundant screenshots
```

## Testing Depth Management

### Single Page Testing (depth=1)

Test only the provided URL:
- Complete functional testing
- Full accessibility audit
- Performance measurement
- Visual inspection
- Console error check

### Shallow Crawl (depth=2)

Test main page + linked pages:
- Identify all links on main page
- Follow internal links (same domain)
- Apply smoke tests to linked pages
- Report critical issues on any page

### Deep Crawl (depth=3+)

Recursive exploration:
- Track visited URLs (avoid loops)
- Follow links up to specified depth
- Prioritize critical flows over exhaustive crawling
- Respect time limits (don't test forever)

## Reporting Best Practices

### Categorize by Severity

**Critical ❌:**
- Prevents core functionality
- Blocks users from completing tasks
- Exposes security vulnerabilities
- Causes data loss

**Warning ⚠️:**
- Degrades user experience
- Inconsistent behavior
- Poor error messages
- Performance issues

**Info ℹ️:**
- Best practice violations
- Accessibility improvements
- Performance optimizations
- UX enhancements

### Provide Actionable Details

For each issue include:
- **Location**: Specific selector or URL
- **Reproduction**: Steps to reproduce
- **Expected vs Actual**: What should happen vs what happens
- **Impact**: How this affects users
- **Priority**: Critical/High/Medium/Low

### Balance Thoroughness with Clarity

Report both problems and successes:
- Don't only report failures (show what works)
- Don't report every minor issue (focus on impactful findings)
- Group related issues (don't duplicate similar problems)
- Prioritize by user impact, not alphabetically

## Additional Resources

### Reference Files

For detailed testing techniques, consult:
- **`references/playwright-mcp-tools.md`** - Complete Playwright MCP tool reference
- **`references/accessibility-testing.md`** - Comprehensive WCAG testing guide
- **`references/performance-metrics.md`** - Detailed performance analysis patterns

These references provide deeper technical details while keeping this core skill focused on essential patterns and workflows.

## Quick Reference

**Testing checklist:**
- [ ] Navigate to target URL
- [ ] Capture initial state (snapshot, console, network)
- [ ] Test interactive elements
- [ ] Validate accessibility
- [ ] Measure performance
- [ ] Inspect for visual issues
- [ ] Report findings by severity

**Remember:** Focus on finding real bugs autonomously. Be thorough but scoped to context. Report actionably.
