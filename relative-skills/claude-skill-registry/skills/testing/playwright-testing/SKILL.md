---
name: playwright-testing
description: Browser automation with Playwright for Python. Recommended for visual testing. (project)
---

# Playwright Testing

## When to Use

- Visual testing, screenshots, UI verification
- Mentions: "playwright", "screenshot", "visual test"

## Canonical Repo Rules

For Skriptoteket-specific setup (login env vars, SPA dev server vs built assets, macOS Intel vs Apple Silicon), follow:

- `.agent/rules/075-browser-automation.md`
- For CodeMirror (CM6) editor interaction patterns (hover, autocomplete, lint tooltips), follow:
  `.agent/rules/075-browser-automation.md` → “CodeMirror (CM6) interaction patterns (REQUIRED)”.

## Repo Commands

```bash
# Existing smoke tests
pdm run ui-smoke
pdm run ui-editor-smoke
pdm run ui-runtime-smoke

# Test tool fixtures: use repo script bank (no ad-hoc demo tools/scripts in DB)
pdm run seed-script-bank --slug <tool-slug>
pdm run seed-script-bank --slug <tool-slug> --sync-code

# Dev/HMR (Vite): use --base-url http://127.0.0.1:5173

# Prod (recommended): gitignored `.env.prod-smoke` with `BASE_URL` + `PLAYWRIGHT_*`
pdm run ui-smoke --dotenv .env.prod-smoke
pdm run ui-editor-smoke --dotenv .env.prod-smoke
pdm run ui-runtime-smoke --dotenv .env.prod-smoke

# Run an ad-hoc script
pdm run python -m scripts.<module>
```

## Script Bank Fixtures (REQUIRED)

If a Playwright script depends on a “demo tool/script” by slug, do **not** create it ad hoc in the dev DB and do not
overwrite other demo tools. Add a dedicated entry to the repo script bank (`src/skriptoteket/script_bank/`) and seed it
before running Playwright.

Refs:

- `.agent/rules/075-browser-automation.md`
- `docs/runbooks/runbook-script-bank-seeding.md`
- `docs/backlog/stories/story-06-09-playwright-test-isolation.md`

## One-Time Setup (Browsers)

Playwright needs browser binaries installed locally (per Playwright version).

```bash
# Install default browsers (Chromium + Firefox + WebKit)
pdm run playwright install

# Install a single browser
pdm run playwright install chromium

# CI/Linux: install browsers + OS deps
pdm run playwright install --with-deps

# List installed browsers
pdm run playwright install --list

# Force reinstall (useful if cache is inconsistent)
pdm run playwright install --force

# Uninstall browsers (all Playwright installs on this machine)
pdm run playwright uninstall --all
```

Playwright-managed browser cache locations:

- Windows: `%USERPROFILE%\\AppData\\Local\\ms-playwright`
- macOS: `~/Library/Caches/ms-playwright`
- Linux: `~/.cache/ms-playwright`

## macOS (Intel vs Apple Silicon)

On macOS, Playwright downloads different browser binaries depending on your architecture.

```bash
python -c "import platform; print(platform.machine())"
# Expect: arm64 (Apple Silicon) or x86_64 (Intel)
```

If you are on Apple Silicon but see Playwright looking for `mac-x64` binaries, you are likely running an x86_64
Python/terminal (Rosetta). Fix by using an arm64 Python/terminal, then reinstall browsers:

```bash
pdm run playwright uninstall --all
pdm run playwright install
```

## Troubleshooting

- Debug browser launches: `DEBUG=pw:browser pdm run ui-editor-smoke`
- Custom browser download location: set `PLAYWRIGHT_BROWSERS_PATH=/path` before `playwright install` (and when running tests).
- Use a system Node.js instead of Playwright's bundled driver: set `PLAYWRIGHT_NODEJS_PATH=/absolute/path/to/node`
- Disable automatic stale-browser cleanup: `PLAYWRIGHT_SKIP_BROWSER_GC=1`

## Quick Pattern (sync)

```python
from scripts._playwright_config import get_config

from playwright.sync_api import sync_playwright

config = get_config()
base_url = config.base_url
email = config.email
password = config.password

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.set_viewport_size({"width": 1440, "height": 900})

    # Login
    page.goto(f"{base_url}/login")
    page.fill('input[name="email"]', email)
    page.fill('input[name="password"]', password)
    page.click('button[type="submit"]')  # prefer role/label locators in repo scripts
    page.wait_for_url('**/dashboard**')

    # Screenshot
    page.goto(f"{base_url}/admin/tools")
    page.screenshot(path='/tmp/admin-tools.png')
    browser.close()
```

## Navigation Caveat

SPA route changes (and any legacy HTMX-style flows) do not always trigger full navigation events.
Prefer `page.wait_for_url()`, locator waits, or `expect(...)` over navigation waits.

## Context7

- Prefer `/websites/playwright_dev_python` for installation, browsers, env vars (topics: `browsers`, `ci`, `PLAYWRIGHT_BROWSERS_PATH`).
- Use `/microsoft/playwright-python` for Python API reference (sync/async APIs).
