---
name: check-links
description: Analyze and validate links and buttons on web pages. Use when users ask to check links, verify button hrefs, find empty links, detect javascript:void links, find broken navigation, or audit clickable elements. Detects empty href, javascript:void(0), hash-only links, missing href attributes, and non-accessible buttons.
---

# Check Links

Analyze and validate links (`<a>`) and buttons on web pages for proper navigation and accessibility.

## Quick Start

Run the link checker from the scripts directory:

```bash
cd /path/to/html-checker/scripts
bun src/check-links.ts <URL>
```

## CLI Options

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--verbose` | `-v` | false | Show all links including valid ones |
| `--json` | `-j` | false | Output results as JSON |
| `--check-external` | `-e` | false | Verify external links (slower) |

## Checks Performed

| Check | Severity | Description |
|-------|----------|-------------|
| Empty href | Error | Link with `href=""` or no href attribute |
| javascript:void | Warning | Link with `href="javascript:void(0)"` |
| Hash only | Warning | Link with `href="#"` (no destination) |
| Button no action | Error | `<button>` without click handler or form |
| Dead link | Error | Link returns 404 or unreachable |
| Missing text | Warning | Link with no accessible text content |

## Usage Examples

### Basic check

```bash
bun src/check-links.ts https://example.com
```

### Verbose output showing all links

```bash
bun src/check-links.ts https://example.com --verbose
```

### Check external links (verify 404s)

```bash
bun src/check-links.ts https://example.com --check-external
```

### JSON output for automation

```bash
bun src/check-links.ts https://example.com --json
```

## Output

The checker provides:

1. **Summary** - Total links/buttons analyzed
2. **Issues** - List of problems with severity and location
3. **Statistics** - Breakdown by issue type
4. **Recommendations** - How to fix each issue

### Example Output

```
Link Analysis for https://example.com

Summary:
  Total Links: 45
  Total Buttons: 12
  Issues Found: 7

Issues:
  [ERROR] Empty href at line 23
    <a href="" class="cta-button">Click here</a>

  [WARNING] javascript:void at line 56
    <a href="javascript:void(0)" onclick="openModal()">Learn More</a>

  [WARNING] Hash-only link at line 89
    <a href="#">Back to top</a>

  [ERROR] Button without action at line 112
    <button class="submit-btn">Submit</button>

Statistics:
  Empty href: 2
  javascript:void: 3
  Hash-only: 1
  Button no action: 1

Recommendations:
  - Replace javascript:void with proper button elements
  - Add href destinations or use <button> for actions
  - Ensure all buttons have onclick or form association
```

## Common Issues and Fixes

### Empty href

**Bad:**
```html
<a href="" class="btn">Click</a>
```

**Good:**
```html
<a href="/destination" class="btn">Click</a>
<!-- or use button for actions -->
<button type="button" class="btn" onclick="handleClick()">Click</button>
```

### javascript:void(0)

**Bad:**
```html
<a href="javascript:void(0)" onclick="doSomething()">Action</a>
```

**Good:**
```html
<button type="button" onclick="doSomething()">Action</button>
```

### Hash-only links

**Bad:**
```html
<a href="#">Scroll to top</a>
```

**Good:**
```html
<a href="#top">Scroll to top</a>
<button type="button" onclick="scrollToTop()">Scroll to top</button>
```

## Accessibility (WCAG)

- **SC 2.4.4**: Link purpose must be clear
- **SC 4.1.2**: All interactive elements need accessible names
- **SC 1.3.1**: Buttons must be properly identified

## SEO Impact

- Empty/invalid links waste crawl budget
- javascript:void links are not crawlable
- Broken links harm site authority
- Internal linking improves page discovery

## Related Files

- **Scripts**: `/plugins/html-checker/scripts/`
- **Check Headings**: `/plugins/html-checker/skills/check-headings/`
