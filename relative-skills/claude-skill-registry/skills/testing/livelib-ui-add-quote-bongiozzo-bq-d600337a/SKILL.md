---
name: livelib-ui-add-quote
description: Use Playwright to open a LiveLib quote page and add it to your own quotes/list via the website UI.
compatibility: Requires Playwright + Chromium; requires an authenticated LiveLib session (storage_state).
---

## Goal
Given `quote_url`, perform UI automation to add the quote to the authenticated user's list.

## Inputs
- `quote_url` (string)
- `storage_state_path` (string; Playwright storage_state JSON)

## Output
- `ok` (bool)

## Notes
- Use `storage_state` captured from a real interactive login.
- If UI elements change or CAPTCHA appears, the skill may fail.

See references in `references/`.
