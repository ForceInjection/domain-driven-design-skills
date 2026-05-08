---
name: playwright-automation
description: Use when Codex must browse, interact with, or test web flows via the remote Playwright MCP server hosted on Glama.
---

# Playwright Automation

## Purpose
Drive browser automation workflows (regression checks, screenshot capture, web navigation) through the Glama-hosted Playwright MCP server defined under `servers/playwright`.

## Setup Checklist
1. Ensure `GLAMA_PLAYWRIGHT_ENDPOINT` and `GLAMA_API_KEY` are exported and referenced in `mcp.json`.
2. Upload authentication state JSON for apps that require login; note the storage path in `servers/playwright/README.md`.
3. Limit concurrency to one session per task to avoid Glama quota throttling.

## Workflow
1. **Intent** – describe the scenario (URL, steps, expected assertion). Decide if headless mode is sufficient or if video capture is needed.
2. **Launch** – invoke the `openPage`/`runSteps` tool with selectors and navigation instructions. Use deterministic selectors, not text heuristics, whenever possible.
3. **Validate** – capture screenshots or DOM snapshots; store outputs under `docs/automation/` through the filesystem skill if they must persist.
4. **Cleanup** – close tabs via the MCP toolset to release capacity. Record any failures and request a retry only after adjusting selectors/timeouts.

## Notes
- Default viewport is 1280×720; override via tool metadata if layout-specific testing is required.
- Retries: wait 3 seconds when encountering `TargetClosedError` before re-issuing the step list.
- Sensitive flows (2FA) should be mocked or limited to staging credentials—never push secrets into step definitions.
