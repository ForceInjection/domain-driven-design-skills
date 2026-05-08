---
name: eufy
description: Manage Eufy Security (HomeBase S380 + SoloCam S340/E340) from the `eufy` CLI—capture snapshots, forward alarms to the Tuya hub, and change guard/alarm modes through eufy-security-ws.
metadata: {"clawdis":{"emoji":"🛡️","requires":{"bins":["eufy"]},"install":[{"id":"pip","kind":"pip","cmd":"pip install -e $HOME/Coding/belidis/eufy","label":"Install eufycli"}]}}
---

# eufy skill

Use this when a task references the Eufy camera kit, S380 HomeBase, S340/S330/S230 cameras, or anything that needs alarms/images from those devices.

## Environment

1. Ensure the helper package is installed:
   ```bash
   pip install -e /Users/marianobelinky/Coding/belidis/eufy
   ```
2. Generate/edit the config once per operator:
   ```bash
   eufy config init
   $EDITOR ~/.config/eufycli/config.toml
   ```
   Fill `[account]` (email/password/app password), `[stations]` / `[cameras]` aliases, default `[paths]`, and optional `[webhook]` URL (usually `http://127.0.0.1:5000/api/eufy/events`).
3. Secrets hierarchy: `EUFY_PASSWORD` / `EUFYCLI_PASSWORD` env var → `account.password` → `account.password_command`.
4. Override config paths via `EUFYCLI_CONFIG` / CLI `--config` flag.
5. Optional guard/alarm control requires [`eufy-security-ws`](https://bropat.github.io/eufy-security-ws/):
   ```bash
   docker run --rm -p 3000:3000 -e USERNAME=... -e PASSWORD=... bropat/eufy-security-ws:latest
   ```
   Then set the `[ws]` block (`enabled = true`, `url`, `schema`) in `config.toml`.

## Common CLI flows

- **Account sanity check**
  ```bash
  eufy login            # lists stations/cameras/IPs
  ```
- **Pull a still**
  ```bash
  eufy snapshot driveway                # uses alias
  eufy snapshot T8140XXXXXXXXXXXX -o ./tmp
  ```
  Images land in `paths.media` unless `-o` overrides it.
- **Stream alarms into Tuya hub**
  ```bash
  eufy events watch --webhook http://<hub-ip>:5000/api/eufy/events
  ```
  Leave it running (LaunchAgent/systemd) so `/api/eufy/events` always has fresh motion history.
- **Guard / siren** (needs ws bridge)
  ```bash
  eufy ws guard homebase away
  eufy ws alarm homebase --seconds 60
  ```

## Tuya hub integration cheatsheet

The Flask hub (repo: `tuya-hub/tuya-hub`) exposes endpoints once the eufycli package is installed:

| Endpoint | Purpose |
| --- | --- |
| `GET /api/eufy/status` | Returns `{available,status}` to show config/install issues. |
| `GET /api/eufy/cameras` | Lists metadata/thumbnails for dashboards. |
| `POST /api/eufy/camera/<alias-or-serial>/snapshot` | Streams JPEG stills (headers include capture timestamp). |
| `POST /api/eufy/events` | Accepts `{"events": [...]}` (exact payload from `eufy events watch`). |
| `GET /api/eufy/events` | Returns the cached events buffer for UI panels/alerts. |

Pairing workflow:
1. Install eufycli inside the hub's virtualenv (`pip install -e /Users/.../belidis/eufy`).
2. Restart the Flask app so `services.eufy.EufyService` loads the config.
3. Launch `eufy events watch` on a machine that stays on the same LAN and point `--webhook` to the Flask endpoint.
4. Use the new REST endpoints (or `eufy snapshot ...`) from automations, Tuya flows, or Clawdis scripts.

## Troubleshooting

- **Config missing** – `/api/eufy/status` shows the exact error (e.g., `account.email missing`). Run `eufy config init` and edit the file.
- **CaptchaRequiredError** – rerun `eufy login`; the CLI will print a base64 captcha blob. Solve it and re-run with `--captcha-id/--captcha-code` (Typer prompts automatically). After a successful login the session refresh works silently.
- **403/InvalidCredentials** – Eufy accounts with 2FA require app passwords. Generate one inside the Eufy Security app and store it in the config or `EUFY_PASSWORD`.
- **Guard/Alarm commands fail** – confirm `docker logs` for `eufy-security-ws` show `client connected`, that the `[ws]` block has `enabled = true`, and that the CLI can reach the server (`eufy ws guard ...`). The Tuya hub does not call guard endpoints automatically; keep using the CLI or build an automation around it.
- **Snapshots stale** – `eufy snapshot ...` returns the last motion thumbnail. Trigger motion or use the Eufy app to refresh; RTSP livestreams require enabling RTSP per camera (inside the native app) and storing `rtsp_username/password` there, which the CLI will surface later.

## Related files

- Helper package: `/Users/marianobelinky/Coding/belidis/eufy`
- Flask hub: `/Users/marianobelinky/Coding/infra/tuya-hub/tuya-hub`
- Skill reference config: `~/.config/eufycli/config.toml`
