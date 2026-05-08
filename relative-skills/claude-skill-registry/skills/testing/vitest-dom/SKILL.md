---
name: vitest-dom
description: Use vitest + jsdom for fast, lightweight unit tests for front-end apps
---

- Use [vitest](http://npmjs.com/package/vitest) and [jsdom](https://www.npmjs.com/package/jsdom) for front-end testing.
- Avoid `vitest.config.*`; default ESM import works, launch via `"test": "npx -y vitest run"` in `package.json`. Add `jsdom` as a `devDependency`. Add `npm test` to `prepublishOnly`
- Treat tests as lightweight integration, not unit. Load the full HTML + scripts and verify real DOM mutations; ensures refactors don't silently break UI wiring.
- Log browser `console.*` output.
- Mount local HTML. `settings.fetch.virtualServers = [{url:"https://test/", directory: <root>}]`. Use `page.goto("https://test/...")` to load files without a dev-server.
- Create a fresh page for each test to isolate `window`, `document`, etc.
- Fake timers for deterministic testing.
  - Call `vi.useFakeTimers()` in `beforeAll`, `vi.useRealTimers()` in `afterAll`.
  - Re-bind `window.setTimeout = setTimeout` so app code sees the mocked clock.
  - Drive async paths with `vi.advanceTimersByTime(ms)` instead of `await sleep`.
- Stub external APIs with `vi.fn()` - e.g. `window.fetch = vi.fn(() => Promise.resolve({ok:true,...}))` avoids network and lets you assert payloads.
- Spy on side-effects - `vi.spyOn(console, "error")`, clipboard reads, etc.; always `mockRestore()` afterwards to prevent bleed-through.
- Add timeouts per test case, e.g. `{ timeout: 10_000 }`, for long-running tests.
