---
name: web-tests
description: Complete browser automation with Playwright. **ALWAYS use when user needs browser testing, E2E testing, screenshots, form testing, or responsive design validation.** Auto-detects dev servers, saves test scripts to working directory. Examples - "test this page", "take screenshots of responsive design", "test login flow", "check for broken links", "validate form submission".
---

**IMPORTANT - Path Resolution:**
This skill is installed globally but saves outputs to the user's working directory. Always pass `CWD` environment variable when executing commands to ensure outputs go to the correct location.

Common installation paths:

- Plugin system: `~/.claude/plugins/marketplaces/claude-craftkit/plugins/ui-tests/skills/web-tests`
- Manual global: `~/.claude/skills/web-tests`
- Project-specific: `<project>/.claude/skills/web-tests`

# Web Testing & Browser Automation

General-purpose browser automation skill. I'll write custom Playwright code for any automation task you request and execute it via the universal executor.

**CRITICAL WORKFLOW - Follow these steps in order:**

1. **Auto-detect dev servers** - For localhost testing, ALWAYS run server detection FIRST:

   ```bash
   cd $SKILL_DIR && node -e "require('./lib/helpers').detectDevServers().then(servers => console.log(JSON.stringify(servers)))"
   ```

   - If **1 server found**: Use it automatically, inform user
   - If **multiple servers found**: Ask user which one to test
   - If **no servers found**: Ask for URL or offer to help start dev server

2. **Write scripts to user's working directory** - Save to `.web-tests/scripts/test-*.js` in user's repo

3. **Use visible browser by default** - Always use `headless: false` unless user specifically requests headless mode

4. **Parameterize URLs** - Always make URLs configurable via constant at top of script

## How It Works

1. You describe what you want to test/automate
2. I auto-detect running dev servers (or ask for URL if testing external site)
3. I write custom Playwright code in `.web-tests/scripts/test-*.js` (in user's working directory)
4. I execute it via: `CWD=$(pwd) cd $SKILL_DIR && node run.js .web-tests/scripts/test-*.js`
5. Results displayed in real-time, browser window visible for debugging
6. Screenshots automatically saved to `.web-tests/screenshots/`

## Setup (First Time)

```bash
cd $SKILL_DIR
npm run setup
```

This installs Playwright and Chromium browser. Only needed once.

## Execution Pattern

**Step 1: Detect dev servers (for localhost testing)**

```bash
cd $SKILL_DIR && node -e "require('./lib/helpers').detectDevServers().then(s => console.log(JSON.stringify(s)))"
```

**Step 2: Write test script to user's .web-tests/scripts/ with URL parameter**

```javascript
// .web-tests/scripts/test-page.js
const { chromium } = require("playwright");

// Parameterized URL (detected or user-provided)
const TARGET_URL = "http://localhost:3001"; // <-- Auto-detected or from user

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto(TARGET_URL);
  console.log("Page loaded:", await page.title());

  await page.screenshot({
    path: ".web-tests/screenshots/page.png",
    fullPage: true,
  });
  console.log("📸 Screenshot saved to .web-tests/screenshots/page.png");

  await browser.close();
})();
```

**Step 3: Execute from skill directory with CWD**

```bash
CWD=$(pwd) cd $SKILL_DIR && node run.js $(pwd)/.web-tests/scripts/test-page.js
```

## Common Patterns

### Test a Page (Multiple Viewports)

```javascript
// .web-tests/scripts/test-responsive.js
const { chromium } = require("playwright");
const helpers = require("$SKILL_DIR/lib/helpers"); // Path will be resolved

const TARGET_URL = "http://localhost:3001"; // Auto-detected

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 100 });
  const page = await browser.newPage();

  // Desktop test
  await page.setViewportSize({ width: 1920, height: 1080 });
  await page.goto(TARGET_URL);
  console.log("Desktop - Title:", await page.title());
  await helpers.takeScreenshot(page, "desktop"); // Saves to .web-tests/screenshots/

  // Mobile test
  await page.setViewportSize({ width: 375, height: 667 });
  await helpers.takeScreenshot(page, "mobile");

  await browser.close();
})();
```

### Test Login Flow

```javascript
// .web-tests/scripts/test-login.js
const { chromium } = require("playwright");

const TARGET_URL = "http://localhost:3001"; // Auto-detected

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto(`${TARGET_URL}/login`);

  await page.fill('input[name="email"]', "test@example.com");
  await page.fill('input[name="password"]', "password123");
  await page.click('button[type="submit"]');

  // Wait for redirect
  await page.waitForURL("**/dashboard");
  console.log("✅ Login successful, redirected to dashboard");

  await browser.close();
})();
```

### Fill and Submit Form

```javascript
// .web-tests/scripts/test-form.js
const { chromium } = require("playwright");
const helpers = require("$SKILL_DIR/lib/helpers");

const TARGET_URL = "http://localhost:3001"; // Auto-detected

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 50 });
  const page = await browser.newPage();

  await page.goto(`${TARGET_URL}/contact`);

  await page.fill('input[name="name"]', "John Doe");
  await page.fill('input[name="email"]', "john@example.com");
  await page.fill('textarea[name="message"]', "Test message");

  await helpers.takeScreenshot(page, "form-filled");
  await page.click('button[type="submit"]');

  // Verify submission
  await page.waitForSelector(".success-message");
  console.log("✅ Form submitted successfully");
  await helpers.takeScreenshot(page, "form-success");

  await browser.close();
})();
```

### Check for Broken Links

```javascript
// .web-tests/scripts/test-broken-links.js
const { chromium } = require("playwright");

const TARGET_URL = "http://localhost:3001";

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto(TARGET_URL);

  const links = await page.locator('a[href^="http"]').all();
  const results = { working: 0, broken: [] };

  for (const link of links) {
    const href = await link.getAttribute("href");
    try {
      const response = await page.request.head(href);
      if (response.ok()) {
        results.working++;
      } else {
        results.broken.push({ url: href, status: response.status() });
      }
    } catch (e) {
      results.broken.push({ url: href, error: e.message });
    }
  }

  console.log(`✅ Working links: ${results.working}`);
  console.log(`❌ Broken links:`, results.broken);

  await browser.close();
})();
```

### Take Screenshot with Error Handling

```javascript
// .web-tests/scripts/screenshot-with-error-handling.js
const { chromium } = require("playwright");
const helpers = require("$SKILL_DIR/lib/helpers");

const TARGET_URL = "http://localhost:3001";

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  try {
    await page.goto(TARGET_URL, {
      waitUntil: "networkidle",
      timeout: 10000,
    });

    await helpers.takeScreenshot(page, "page-success");
    console.log("📸 Screenshot saved successfully");
  } catch (error) {
    console.error("❌ Error:", error.message);
    await helpers.takeScreenshot(page, "page-error");
  } finally {
    await browser.close();
  }
})();
```

### Test Responsive Design (Full)

```javascript
// .web-tests/scripts/test-responsive-full.js
const { chromium } = require("playwright");
const helpers = require("$SKILL_DIR/lib/helpers");

const TARGET_URL = "http://localhost:3001"; // Auto-detected

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  const viewports = [
    { name: "Desktop", width: 1920, height: 1080 },
    { name: "Tablet", width: 768, height: 1024 },
    { name: "Mobile", width: 375, height: 667 },
  ];

  for (const viewport of viewports) {
    console.log(
      `Testing ${viewport.name} (${viewport.width}x${viewport.height})`
    );

    await page.setViewportSize({
      width: viewport.width,
      height: viewport.height,
    });

    await page.goto(TARGET_URL);
    await page.waitForTimeout(1000);

    await helpers.takeScreenshot(page, viewport.name.toLowerCase());
  }

  console.log("✅ All viewports tested");
  await browser.close();
})();
```

## Inline Execution (Simple Tasks)

For quick one-off tasks, you can execute code inline without creating files:

```bash
# Take a quick screenshot
cd $SKILL_DIR && CWD=$(pwd) node run.js "
const browser = await chromium.launch({ headless: false });
const page = await browser.newPage();
await page.goto('http://localhost:3001');
await helpers.takeScreenshot(page, 'quick-test');
console.log('Screenshot saved');
await browser.close();
"
```

**When to use inline vs files:**

- **Inline**: Quick one-off tasks (screenshot, check if element exists, get page title)
- **Files**: Complex tests, responsive design checks, anything user might want to re-run

## Available Helpers

Optional utility functions in `lib/helpers.js`:

```javascript
const helpers = require("./lib/helpers");

// Detect running dev servers (CRITICAL - use this first!)
const servers = await helpers.detectDevServers();
console.log("Found servers:", servers);

// Safe click with retry
await helpers.safeClick(page, "button.submit", { retries: 3 });

// Safe type with clear
await helpers.safeType(page, "#username", "testuser");

// Take timestamped screenshot (auto-saves to .web-tests/screenshots/)
await helpers.takeScreenshot(page, "test-result");

// Handle cookie banners
await helpers.handleCookieBanner(page);

// Extract table data
const data = await helpers.extractTableData(page, "table.results");
```

See `lib/helpers.js` for full list.

## Directory Structure

When testing, the skill creates this structure in the user's working directory:

```
user-repo/
└── .web-tests/
    ├── scripts/          # Test scripts (reusable)
    │   ├── test-login.js
    │   ├── test-form.js
    │   ├── test-responsive.js
    │   └── test-broken-links.js
    └── screenshots/      # Screenshots with timestamps
        ├── desktop-2025-10-23T12-30-45.png
        ├── mobile-2025-10-23T12-30-51.png
        └── form-success-2025-10-23T12-31-05.png
```

## Tips

- **CRITICAL: Detect servers FIRST** - Always run `detectDevServers()` before writing test code for localhost testing
- **Save to .web-tests/** - Write scripts to `.web-tests/scripts/`, screenshots auto-save to `.web-tests/screenshots/`
- **Parameterize URLs** - Put detected/provided URL in a `TARGET_URL` constant at the top of every script
- **DEFAULT: Visible browser** - Always use `headless: false` unless user explicitly asks for headless mode
- **Headless mode** - Only use `headless: true` when user specifically requests "headless" or "background" execution
- **Slow down:** Use `slowMo: 100` to make actions visible and easier to follow
- **Wait strategies:** Use `waitForURL`, `waitForSelector`, `waitForLoadState` instead of fixed timeouts
- **Error handling:** Always use try-catch for robust automation
- **Console output:** Use `console.log()` to track progress and show what's happening
- **Use helpers:** The `helpers.takeScreenshot()` automatically saves to `.web-tests/screenshots/`

## Troubleshooting

**Playwright not installed:**

```bash
cd $SKILL_DIR && npm run setup
```

**Module not found:**
Ensure running from skill directory via `run.js` wrapper with CWD set

**Browser doesn't open:**
Check `headless: false` and ensure display available

**Element not found:**
Add wait: `await page.waitForSelector('.element', { timeout: 10000 })`

**Screenshots not in .web-tests/:**
Make sure `CWD` environment variable is set when executing

## Example Usage

```
User: "Test if the marketing page looks good"

Claude: I'll test the marketing page across multiple viewports. Let me first detect running servers...
[Runs: detectDevServers()]
[Output: Found server on port 3001]
I found your dev server running on http://localhost:3001

[Writes custom automation script to .web-tests/scripts/test-marketing.js with URL parameterized]
[Runs: CWD=$(pwd) cd $SKILL_DIR && node run.js .web-tests/scripts/test-marketing.js]
[Shows results with screenshots from .web-tests/screenshots/]
```

```
User: "Check if login redirects correctly"

Claude: I'll test the login flow. First, let me check for running servers...
[Runs: detectDevServers()]
[Output: Found servers on ports 3000 and 3001]
I found 2 dev servers. Which one should I test?
- http://localhost:3000
- http://localhost:3001

User: "Use 3001"

[Writes login automation to .web-tests/scripts/test-login.js]
[Runs: CWD=$(pwd) cd $SKILL_DIR && node run.js .web-tests/scripts/test-login.js]
[Reports: ✅ Login successful, redirected to /dashboard]
```

## Notes

- Each automation is custom-written for your specific request
- Not limited to pre-built scripts - any browser task possible
- Auto-detects running dev servers to eliminate hardcoded URLs
- Test scripts saved to `.web-tests/scripts/` for reusability
- Screenshots automatically saved to `.web-tests/screenshots/` with timestamps
- Code executes reliably with proper module resolution via `run.js`
- Works as global tool - no per-repo installation needed
