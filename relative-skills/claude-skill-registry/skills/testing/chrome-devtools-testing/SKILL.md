---
name: chrome-devtools-testing
description: "Browser testing and debugging with Playwright. QA testing, screenshots, form interactions, console errors, network analysis, performance profiling. Batch scripting for multiple actions per turn."
---

<chrome_devtools_testing_skill>
  <persona>QA Tester / Developer / Debugger</persona>
  <primary_goal>Browser automation with batch scripting and deep debugging capabilities</primary_goal>

  <overview>
    A Playwright-based browser testing skill that connects directly to Chrome via CDP.
    Supports batch scripting (multiple actions per turn), auto-wait, ARIA snapshots,
    and full DevTools debugging (console, network, performance).
  </overview>

  <prerequisites>
    <requirement>Server must be running: cd ~/.claude/skills/chrome-devtools-testing && bun run start-server</requirement>
    <requirement>First time setup: cd ~/.claude/skills/chrome-devtools-testing && bun install</requirement>
  </prerequisites>

  <workflow_loop>
    The core browser testing workflow:

    1. Write a script to perform actions (navigate, interact, verify)
    2. Run it via heredoc and observe output
    3. Evaluate - did it work? What's the current state?
    4. Decide - task complete, or need another script?
    5. Repeat until done

    Each script can contain MULTIPLE Playwright actions - no need for one action per turn.
  </workflow_loop>

  <scripting_pattern>
    Use heredoc TypeScript scripts for multi-action flows:

    ```bash
    cd ~/.claude/skills/chrome-devtools-testing && bun x tsx &lt;&lt;'EOF'
    import { connect } from "./src/client.js";

    const client = await connect();
    const page = await client.page("main");

    // Multiple actions in one script
    await page.goto("http://localhost:3000");
    await page.fill('[name="email"]', "test@example.com");
    await page.click('button[type="submit"]');
    await page.waitForSelector("text=Success");
    await page.screenshot({ path: "/tmp/result.png" });

    await client.disconnect();
    EOF
    ```

    Benefits:
    - Multiple actions execute in one turn (no round-trips)
    - Playwright auto-wait handles timing
    - Full TypeScript support
    - State persists between scripts (pages survive disconnections)
  </scripting_pattern>

  <key_principles>
    <principle>Small scripts - each does ONE logical task (login, submit form, verify state)</principle>
    <principle>Evaluate state at end - log results, take screenshots</principle>
    <principle>Use descriptive page names - "main", "login", "checkout"</principle>
    <principle>Disconnect when done - pages persist on server for next script</principle>
    <principle>Use Playwright locators - more robust than ARIA refs for most cases</principle>
  </key_principles>

  <client_api>
    <function name="connect(serverUrl?)">
      Connect to the browser server. Returns client object.
      Default: http://localhost:9222
    </function>

    <function name="client.page(name)">
      Get or create a named page. Returns Playwright Page object.
      Pages persist between script executions.
    </function>

    <function name="client.getAISnapshot(pageName)">
      Get ARIA accessibility tree as YAML. Use when you need to discover
      element structure or for complex targeting scenarios.
    </function>

    <function name="client.selectSnapshotRef(pageName, ref)">
      Get ElementHandle for a snapshot ref like "e5".
      Use after getAISnapshot to interact with discovered elements.
    </function>

    <function name="client.listPages()">
      List all named pages on the server.
    </function>

    <function name="client.closePage(name)">
      Close a specific page.
    </function>

    <function name="client.disconnect()">
      Disconnect from server. Pages persist for next script.
    </function>
  </client_api>

  <wait_for_page_load>
    Smart page load detection with network idle and ad filtering:

    ```typescript
    import { waitForPageLoad } from "./src/client.js";

    await page.goto("http://localhost:3000");
    const result = await waitForPageLoad(page);
    console.log(result);
    // { success: true, readyState: "complete", pendingRequests: 0, waitTimeMs: 850, timedOut: false }
    ```

    Options:
    ```typescript
    await waitForPageLoad(page, {
      timeout: 10000,        // Max wait time (default: 10s)
      pollInterval: 50,      // Check frequency (default: 50ms)
      minimumWait: 100,      // Initial wait (default: 100ms)
      waitForNetworkIdle: true  // Wait for no pending requests (default: true)
    });
    ```

    Smart filtering (requests that DON'T block loading):
    - Ad/tracking: Google Analytics, Facebook, Hotjar, Mixpanel, Sentry, etc.
    - Non-critical after 3s: images, fonts, icons
    - Stuck requests: anything loading >10 seconds
    - Data URLs and very long URLs (>500 chars)

    Returns detailed state even on timeout - graceful degradation.
  </wait_for_page_load>

  <playwright_locators>
    Prefer Playwright locators over ARIA refs for most interactions:

    ```typescript
    // By role (recommended)
    await page.getByRole('button', { name: 'Submit' }).click();
    await page.getByRole('textbox', { name: 'Email' }).fill('test@example.com');

    // By text
    await page.getByText('Welcome').waitFor();
    await page.getByLabel('Password').fill('secret');

    // By CSS selector
    await page.locator('.submit-btn').click();
    await page.locator('#email-input').fill('test@example.com');

    // By test ID (if available)
    await page.getByTestId('submit-button').click();
    ```

    Playwright auto-waits for elements - no manual waits needed.
  </playwright_locators>

  <aria_snapshots>
    Use getAISnapshot() when you need to discover page structure:

    ```typescript
    const snapshot = await client.getAISnapshot("main");
    console.log(snapshot);
    ```

    Output format (YAML):
    ```yaml
    - navigation:
      - link "Home" [ref=e1]
      - link "Products" [ref=e2]
    - main:
      - heading "Welcome" [level=1]
      - form:
        - textbox "Email" [ref=e5]
          /placeholder: "Enter email"
        - textbox "Password" [ref=e6]
        - button "Sign In" [ref=e7]
    ```

    Then interact using refs:
    ```typescript
    const emailInput = await client.selectSnapshotRef("main", "e5");
    await emailInput?.fill("test@example.com");
    ```
  </aria_snapshots>

  <debugging_features>
    <category name="Console Messages">
      ```typescript
      const logs = await client.getConsoleMessages(page, { types: ['error', 'warn'] });
      console.log('Errors:', logs);
      ```
    </category>

    <category name="Network Requests">
      ```typescript
      const requests = await client.getNetworkRequests(page, { types: ['xhr', 'fetch'] });
      console.log('API calls:', requests);
      ```
    </category>

    <category name="Performance Metrics">
      ```typescript
      const metrics = await client.getPerformanceMetrics(page);
      console.log('LCP:', metrics.lcp, 'FCP:', metrics.fcp);
      ```
    </category>

    <category name="Core Web Vitals">
      ```typescript
      const vitals = await client.getCoreWebVitals(page);
      console.log('LCP:', vitals.lcp, 'CLS:', vitals.cls, 'FID:', vitals.fid);
      ```
    </category>

    <category name="Performance Trace">
      ```typescript
      await client.startPerformanceTrace(page);
      await page.reload();
      const trace = await client.stopPerformanceTrace(page);
      ```
    </category>
  </debugging_features>

  <examples>
    <example name="Form Submission with Verification">
      ```bash
      cd ~/.claude/skills/chrome-devtools-testing && bun x tsx &lt;&lt;'EOF'
      import { connect } from "./src/client.js";

      const client = await connect();
      const page = await client.page("main");

      await page.goto("http://localhost:3000/contact");
      await page.getByLabel("Name").fill("John Doe");
      await page.getByLabel("Email").fill("john@example.com");
      await page.getByLabel("Message").fill("Hello from the test!");
      await page.getByRole("button", { name: "Send" }).click();

      await page.getByText("Thank you").waitFor();
      await page.screenshot({ path: "/tmp/success.png" });

      const errors = await client.getConsoleMessages(page, { types: ["error"] });
      if (errors.length) console.log("Errors found:", errors);

      await client.disconnect();
      EOF
      ```
    </example>

    <example name="Debug Page Load Issues">
      ```bash
      cd ~/.claude/skills/chrome-devtools-testing && bun x tsx &lt;&lt;'EOF'
      import { connect } from "./src/client.js";

      const client = await connect();
      const page = await client.page("debug");

      await page.goto("http://localhost:3000");

      const errors = await client.getConsoleMessages(page, { types: ["error", "warn"] });
      console.log("Console errors:", errors);

      const requests = await client.getNetworkRequests(page, { types: ["xhr", "fetch"] });
      console.log("API requests:", requests);

      const vitals = await client.getCoreWebVitals(page);
      console.log("Core Web Vitals:", vitals);

      await page.screenshot({ path: "/tmp/debug.png" });
      await client.disconnect();
      EOF
      ```
    </example>

    <example name="Discover Page Structure">
      ```bash
      cd ~/.claude/skills/chrome-devtools-testing && bun x tsx &lt;&lt;'EOF'
      import { connect } from "./src/client.js";

      const client = await connect();
      const page = await client.page("explore");

      await page.goto("http://localhost:3000");

      const snapshot = await client.getAISnapshot("explore");
      console.log("Page structure:");
      console.log(snapshot);

      await client.disconnect();
      EOF
      ```
    </example>

    <example name="Performance Analysis">
      ```bash
      cd ~/.claude/skills/chrome-devtools-testing && bun x tsx &lt;&lt;'EOF'
      import { connect } from "./src/client.js";

      const client = await connect();
      const page = await client.page("perf");

      await client.startPerformanceTrace(page);
      await page.goto("http://localhost:3000");
      const trace = await client.stopPerformanceTrace(page);

      const metrics = await client.getPerformanceMetrics(page);
      console.log("Performance metrics:", metrics);

      await client.disconnect();
      EOF
      ```
    </example>
  </examples>

  <screenshot_workflow>
    ```typescript
    // Viewport screenshot
    await page.screenshot({ path: "/tmp/page.png" });

    // Full page screenshot
    await page.screenshot({ path: "/tmp/full.png", fullPage: true });

    // Element screenshot
    await page.locator(".hero").screenshot({ path: "/tmp/hero.png" });
    ```

    Note: Playwright handles large screenshots automatically - no need for splitting.
  </screenshot_workflow>

  <server_management>
    Start server (required before testing):
    ```bash
    cd ~/.claude/skills/chrome-devtools-testing && bun run start-server
    ```

    Start headless (no visible browser):
    ```bash
    cd ~/.claude/skills/chrome-devtools-testing && bun run start-server -- --headless
    ```

    Custom port:
    ```bash
    cd ~/.claude/skills/chrome-devtools-testing && bun run start-server -- --port=9333
    ```
  </server_management>

  <troubleshooting>
    <issue name="Cannot connect to server">
      <symptom>fetch failed or connection refused</symptom>
      <solution>Ensure server is running: bun run start-server</solution>
    </issue>

    <issue name="Page not found">
      <symptom>Could not find page with targetId</symptom>
      <solution>Server may have restarted. Create a new page.</solution>
    </issue>

    <issue name="Element not found">
      <symptom>Timeout waiting for selector</symptom>
      <solution>Check selector, ensure page has loaded, use waitFor()</solution>
    </issue>

    <issue name="Module not found">
      <symptom>Cannot find module './src/client.js'</symptom>
      <solution>Run from skill directory: cd ~/.claude/skills/chrome-devtools-testing</solution>
    </issue>
  </troubleshooting>

  <important_notes>
    <note>Server must be running before scripts can connect</note>
    <note>Pages persist between script executions - great for multi-step flows</note>
    <note>Use Playwright locators for robust element targeting</note>
    <note>Use ARIA snapshots when you need to discover page structure</note>
    <note>Always disconnect() at end of scripts to release resources</note>
    <note>Console/network capture is automatic after first page access</note>
  </important_notes>
</chrome_devtools_testing_skill>
