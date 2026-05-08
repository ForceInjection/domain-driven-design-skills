---
name: automating-browser
description: >
  Interactive browser automation using claude-in-chrome MCP tools.
  Best for: demos, documentation GIFs, manual testing, live browser control.
  For automated E2E testing in CI/CD, use webapp-testing skill instead.
  Triggers: browser automation, ブラウザ自動化, screenshot, スクリーンショット,
  form fill, フォーム入力, click, navigate, GIF recording, GIF録画,
  ブラウザ操作, Chrome, demo, デモ, live browser.
allowed-tools: Read, Glob, mcp__claude-in-chrome__*
---

# Browser Automation Guide

Interactive browser control using claude-in-chrome MCP extension.

## Purpose

Enable **interactive** browser automation for:

- Demo recordings and GIF documentation
- Manual testing with live browser feedback
- Form filling and real-time interaction
- Screenshot capture for visual verification
- Web data extraction from current browser

## When to Use This Skill

| Use Case                      | This Skill      | webapp-testing (official) |
| ----------------------------- | --------------- | ------------------------- |
| GIF recording / demos         | [Best]          | [Not supported]           |
| Manual testing / verification | [Best]          | [OK]                      |
| CI/CD automated testing       | [OK]            | [Best]                    |
| Testing with server lifecycle | [Not supported] | [Best] with_server.py     |
| Using existing Chrome session | [Supported]     | [Not supported]           |

**Quick decision**: "Show & verify" → this skill, "Automate & run" → webapp-testing

## Getting Started

### 1. Tab Context Required

**Always start with**:

```text
mcp__claude-in-chrome__tabs_context_mcp
```

This provides available tab IDs for subsequent operations.

### 2. Create or Reuse Tab

```markdown
# Create new tab

mcp**claude-in-chrome**tabs_create_mcp

# Or use existing tab from context
```

### 3. Navigation

```text
mcp__claude-in-chrome__navigate
  url: "https://example.com"
  tabId: {obtained from tabs_context_mcp}
```

## Core Tools

| Tool               | Purpose                         |
| ------------------ | ------------------------------- |
| `tabs_context_mcp` | Get available tabs              |
| `tabs_create_mcp`  | Create new tab                  |
| `navigate`         | Go to URL                       |
| `read_page`        | Get page structure              |
| `find`             | Natural language element search |
| `form_input`       | Fill form fields                |
| `computer`         | Mouse/keyboard actions          |
| `get_page_text`    | Extract text content            |
| `gif_creator`      | Record interactions             |

## Reading Page Content

| Tool                                     | Use Case                               |
| ---------------------------------------- | -------------------------------------- |
| `read_page`                              | Get accessibility tree (DOM structure) |
| `read_page` with `filter: "interactive"` | Buttons, links, inputs only            |
| `find`                                   | Natural language element search        |
| `get_page_text`                          | Extract article/main text              |

### Example: Read Interactive Elements

```text
mcp__claude-in-chrome__read_page
  tabId: 123
  filter: "interactive"
```

## Common Patterns

### Form Filling

1. `read_page` with `filter: "interactive"` to find inputs
2. Identify input `ref_id` (e.g., `ref_1`, `ref_2`)
3. `form_input` with ref and value

```text
mcp__claude-in-chrome__form_input
  tabId: 123
  ref: "ref_5"
  value: "user@example.com"
```

### Click Actions

```text
mcp__claude-in-chrome__computer
  tabId: 123
  action: "left_click"
  ref: "ref_10"  # Or coordinate: [100, 200]
```

### Screenshot Capture

```text
mcp__claude-in-chrome__computer
  tabId: 123
  action: "screenshot"
```

### GIF Recording

1. Start recording
2. Take screenshot (initial frame)
3. Perform actions
4. Take screenshot (final frame)
5. Stop recording
6. Export

```markdown
# Start

mcp**claude-in-chrome**gif_creator
tabId: 123
action: "start_recording"

# ... perform actions with screenshots ...

# Stop

mcp**claude-in-chrome**gif_creator
tabId: 123
action: "stop_recording"

# Export

mcp**claude-in-chrome**gif_creator
tabId: 123
action: "export"
download: true
filename: "workflow-demo.gif"
```

## Detailed References

| Reference                                                                         | Purpose                     |
| --------------------------------------------------------------------------------- | --------------------------- |
| [@./references/claude-in-chrome-tools.md](./references/claude-in-chrome-tools.md) | Complete tool documentation |
| [@./references/common-patterns.md](./references/common-patterns.md)               | Reusable workflow patterns  |
| [@./references/e2e-testing.md](./references/e2e-testing.md)                       | E2E testing methodology     |

## Security Notes

- Always use `update_plan` for multi-domain operations
- Sensitive data handling requires user confirmation
- Never auto-submit forms with financial information
- Be aware of bot detection systems (CAPTCHA)

## References

### Related Skills

- `webapp-testing` (official) - Playwright E2E automated testing (CI/CD optimized)
- `utilizing-cli-tools` - CLI tools guide
- `generating-tdd-tests` - Test design

### Used by Commands

- `/e2e` - E2E test + documentation generation
- `/test` - E2E test execution (includes browser testing)

### See Also

- `/example-skills:webapp-testing` - Official skill (Playwright + with_server.py)
