---
name: observability-ops
description: Operational observability for the .NET 8 WPF widget host app. Use when adding health checks, diagnostics exports, support tooling, or runtime inspection endpoints.
---

# Observability Ops

## Overview

Provide operational tooling that helps diagnose issues without developer intervention.

## Core areas

- Health checks and self-tests
- Diagnostics export (logs, config, environment)
- Support tools and debug views

## Definition of done (DoD)

- Health check endpoint/method for each critical subsystem (DB, sync, config)
- Diagnostics export includes: app version, OS info, logs (last N days), sanitized config
- Export redacts all tokens/secrets/PII before writing
- Support tools accessible from Settings or Help menu
- Health status visible in UI (system tray icon or status bar)

## Workflow

1. Define health checks for core subsystems.
2. Implement a diagnostics export bundle.
3. Add user-triggered support tools in settings.
4. Ensure sensitive data is redacted in exports.

## Guidance

- Keep support tooling behind a safe UI surface.
- Avoid exposing credentials or tokens.
- Time-bound logs and exports for privacy.

## References

- `references/health-checks.md` for checks and reporting.
- `references/diagnostics-export.md` for export structure.
- `references/support-tools.md` for UX patterns.
