---
name: sso-guide
description: SSO integration guidance for fort-nix services. Use when adding authentication to a service, choosing an SSO mode, configuring oauth2-proxy, or troubleshooting auth issues.
---

# SSO Integration Guide

This skill helps you configure authentication for services exposed via `fortCluster.exposedServices`.

## Quick Reference: SSO Modes

| Mode | Use When | fort.nix Provides | You Provide |
|------|----------|-------------------|-------------|
| `none` | No auth needed, or app handles its own | Plain reverse proxy | Nothing |
| `oidc` | App supports OIDC natively | Credential delivery to `/var/lib/fort-auth/<svc>/` | OIDC config in app |
| `headers` | App reads `X-Auth-*` headers | oauth2-proxy + nginx wiring | Header consumption in app |
| `basicauth` | App only supports HTTP Basic Auth | oauth2-proxy translating to Basic | Basic auth config in app |
| `gatekeeper` | Login wall, no identity needed | oauth2-proxy blocking unauthenticated | Nothing |

## Mode Selection Flowchart

```
Does the app need authentication?
├─ No → mode = "none"
└─ Yes → Does the app support OIDC natively?
         ├─ Yes → mode = "oidc" (see oidc.md)
         └─ No → Can the app read X-Auth-* headers?
                  ├─ Yes → mode = "headers" (see headers.md)
                  └─ No → Does it support HTTP Basic Auth?
                           ├─ Yes → mode = "basicauth" (see basicauth.md)
                           └─ No → Just need login gate? → mode = "gatekeeper" (see gatekeeper.md)
```

## Detailed Mode Documentation

- [oidc.md](oidc.md) - Native OIDC integration (has working examples)
- [headers.md](headers.md) - Proxy-injected headers (has working examples)
- [basicauth.md](basicauth.md) - Basic auth translation (no working examples yet)
- [gatekeeper.md](gatekeeper.md) - Login wall only (no working examples yet)
- [troubleshooting.md](troubleshooting.md) - Common issues and debugging

## Common Options

All SSO modes support:

```nix
sso = {
  mode = "headers";  # or oidc, basicauth, gatekeeper
  groups = [ "admins" ];  # Planned: restrict to LDAP groups (not yet working)
};
```

**Note**: The `groups` option is defined in the schema but **not yet functional**. See `fort-040` for tracking. When implemented, it will pass through to oauth2-proxy's `--allowed-group` flag for all SSO modes.
