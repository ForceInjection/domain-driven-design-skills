---
name: puppeteer-efficient-ui-verification
description: Fast, repeatable UI verification using Puppeteer without paying browser startup per test. Use scenario suites + deterministic fixtures before jumping to full Jest E2E.
---

# Puppeteer Efficient UI Verification

## Scope

- Choose the fastest *correct* browser-level verification method
- Run multiple UI scenarios per browser session (scenario suites)
- Build deterministic fixtures (server + seeded SQLite DB) for low-flake UI runs
- Capture evidence (artifacts + console/network logs) so failures are actionable

## Inputs

- What changed (files / feature)
- Do you need browser semantics (events, CSS/layout, client bundle activation)?
- Do you need a deterministic fixture (DB seed, HTTP record/replay, synthetic page)?

## Procedure (verification ladder)

1. Prefer server-side/SSR checks when possible
   - If the change is server-only or SSR-only, create/run `src/**/checks/*.check.js`.
   - If the change touches server startup, use the server `--check` mode.

2. If you need “one URL in a browser”, use `ui-console-capture`
   - Best for quick debugging of console errors and 404s.
   - Command:
     - `node tools/dev/ui-console-capture.js --server="src/ui/server/<server>.js" --url="http://localhost:3000"`

2.5. If you need **numeric layout facts** (text overflow, bounding boxes), run a purpose-built Puppeteer inspector
    - Prefer a dedicated script that prints JSON metrics (rects, computed styles, overflow flags).
    - Example (Decision Tree Viewer):
       - `node scripts/ui/inspect-decision-tree-layout.js`

3. If you need multiple interactions, use a scenario suite (single browser)
   - Use the runner:
     - `node tools/dev/ui-scenario-suite.js --suite=scripts/ui/scenarios/url-filter-toggle.suite.js --timeout=60000`
   - Debug fast:
     - `node tools/dev/ui-scenario-suite.js --suite=scripts/ui/scenarios/url-filter-toggle.suite.js --scenario=001 --headful --print-logs-on-failure`
   - Artifacts are written to `tmp/ui-scenario-suite/` by default.

4. Promote to Jest E2E when it’s a regression
   - Use repo policy:
     - `npm run test:by-path tests/ui/e2e/<file>.test.js`

## Suite authoring SOP (deterministic fixtures)

When creating a new scenario suite:

1. Put it under `scripts/ui/scenarios/<feature>.suite.js`.
2. Export `startServer()` that:
   - creates a fresh temp DB file under the suite artifacts directory
   - seeds a minimal dataset
   - starts the server on port `0` (random port)
   - returns `{ baseUrl, shutdown() }`
3. Add scenarios with stable ids (`"001"`, `"002"`, …).
4. Add **readiness gates** for client activation (jsgui3):
   - prefer `page.waitForFunction()` on deterministic signals (see references)
   - optionally use a fast-path attempt + hydration retry once
5. On failures, ensure you have evidence:
   - screenshot + HTML snapshot + captured logs (runner does this automatically)

## Validation

- Scenario suite run exits cleanly (no hanging server/browser)
- At least one scenario validates the user-visible invariant
- Failures produce artifacts that explain the bug (not just “timeout”)

## Escalation / Research request

Ask for dedicated research if:

- activation signals are missing/inconsistent and you need a canonical readiness gate for a subsystem
- a fixture requires complex multi-service orchestration (crawler + UI + DB) and you need a determinism strategy
- the suite needs new shared harness utilities (browser reuse, fixture builders, log capture)

## References

- Scenario suite guide: `docs/guides/PUPPETEER_SCENARIO_SUITES.md`
- One-shot console capture: `docs/guides/PUPPETEER_UI_WORKFLOW.md`
- Visual + numeric inspection workflow: `docs/workflows/ui-inspection-workflow.md`
- Hanging prevention discipline: `docs/guides/TEST_HANGING_PREVENTION_GUIDE.md`
- jsgui3 activation failure modes: `docs/guides/JSGUI3_UI_ARCHITECTURE_GUIDE.md`
- Example deterministic suite: `scripts/ui/scenarios/url-filter-toggle.suite.js`
