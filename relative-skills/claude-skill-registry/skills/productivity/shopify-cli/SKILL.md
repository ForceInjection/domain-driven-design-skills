---
name: shopify-cli
description: Comprehensive guide for Shopify CLI app development lifecycle. Use when working with Shopify apps - initializing projects, managing TOML configurations, running local development (shopify app dev), deploying extensions, setting up multi-environment workflows (dev/staging/prod), or automating CI/CD pipelines. Includes helper scripts for common tasks like environment setup, config validation, webhook testing, and deployment automation.
license: Apache-2.0. Complete terms in LICENSE.txt
---

# Shopify CLI for App Development

Shopify CLI manages the entire app lifecycle through configuration-as-code. All settings live in TOML files under version control.

## Quick Start

```bash
# Create new app
shopify app init

# Link existing app to local project
shopify app config link

# Start local development (isolated to your dev store)
shopify app dev

# Deploy configuration and extensions
shopify app deploy
```

## Configuration as Code

### shopify.app.toml Structure

```toml
name = "My App"
client_id = "abc123..."
application_url = "https://myapp.com"
embedded = true

[access_scopes]
scopes = "read_products,write_orders"

[auth]
redirect_urls = ["https://myapp.com/api/auth/callback"]

[webhooks]
api_version = "2024-01"

[[webhooks.subscriptions]]
topics = ["app/uninstalled"]
uri = "/webhooks"
```

### Key Fields

| Field                    | Purpose                                 |
| ------------------------ | --------------------------------------- |
| `name`                   | Display name in Shopify admin           |
| `client_id`              | App identifier (from Partner Dashboard) |
| `application_url`        | Main app URL                            |
| `embedded`               | Whether app renders in Shopify admin    |
| `access_scopes.scopes`   | Permissions (comma-separated)           |
| `auth.redirect_urls`     | OAuth callback URLs                     |
| `webhooks.subscriptions` | Webhook endpoints                       |

**Warning**: Changing `handle` permanently changes your app's URL in Shopify admin, breaking existing bookmarks.

## Development Workflow

### Local Development with `shopify app dev`

The `app dev` command creates an isolated preview on your chosen dev store:

- Changes visible only on YOUR dev store (safe for teams)
- Real-time sync of config and extensions
- App URL updated only for preview (doesn't modify TOML)
- Preview persists after stopping until `shopify app dev clean`

### Networking Options

| Option            | Command              | Use Case                           |
| ----------------- | -------------------- | ---------------------------------- |
| Cloudflare Tunnel | (default)            | Standard development               |
| Localhost         | `--use-localhost`    | Simple frontend work (no webhooks) |
| Custom Tunnel     | `--tunnel-url <url>` | ngrok or corporate firewall        |

### Team Workflow

1. Share single development app (commit `shopify.app.toml`)
2. Each developer creates their own dev store
3. Run `shopify app dev` selecting personal dev store
4. Changes isolated - no conflicts between team members

## Multi-Environment Setup

Manage dev/staging/prod from single codebase using named config files:

```
shopify.app.toml              # Default (development)
shopify.app.staging.toml      # Staging
shopify.app.production.toml   # Production
```

### Create Environment Configs

```bash
# Link to staging app (creates shopify.app.staging.toml)
shopify app config link
# Select staging app, name it "staging"

# Link to production app
shopify app config link
# Select production app, name it "production"
```

### Switch Environments

```bash
# Set default for session
shopify app config use staging

# Override for single command
shopify app deploy --config production
```

**See**: [references/multi-environment.md](references/multi-environment.md) for detailed setup guide.

## Deployment

### App Versions

`shopify app deploy` creates an immutable **app version** - a snapshot of config + extensions.

```bash
# Deploy and release immediately
shopify app deploy

# Deploy without releasing (for testing)
shopify app deploy --no-release

# Release a previous version
shopify app release --version <version>

# List all versions
shopify app versions list
```

**Important**: `deploy` pushes config and extensions only. Deploy your web app separately to your hosting provider.

### CI/CD Integration

```bash
# Non-interactive deployment (for pipelines)
shopify app deploy --config production --force
```

**See**: [references/ci-cd.md](references/ci-cd.md) for GitHub Actions examples.

## Helper Scripts

This skill includes automation scripts in `scripts/`:

| Script               | Purpose                           |
| -------------------- | --------------------------------- |
| `dev-setup.sh`       | Complete dev environment setup    |
| `init-multi-env.sh`  | Create dev/staging/prod configs   |
| `generate-toml.py`   | Generate TOML templates           |
| `validate-config.py` | Validate TOML files               |
| `deploy-env.sh`      | Deploy to specific environment    |
| `sync-config.sh`     | Sync changes between environments |
| `webhook-test.py`    | Trigger test webhooks             |

### Script Dependencies

Python scripts require additional packages for TOML handling:

```bash
# Install Python dependencies (from skill's scripts/ directory)
pip install -r scripts/requirements.txt

# Or install manually:
pip install tomli tomli-w  # tomli only needed for Python < 3.11
```

### Usage Examples

Copy scripts to your project or run from skill location:

```bash
# Set up dev environment from scratch
./dev-setup.sh

# Initialize multi-environment configs
./init-multi-env.sh

# Validate config before deploy
python validate-config.py shopify.app.toml

# Deploy to staging with confirmation
./deploy-env.sh staging

# Test webhook locally
python webhook-test.py --topic orders/create --address http://localhost:3000/webhooks
```

## Common Tasks

### Add New Permission Scope

1. Edit `shopify.app.toml`: add scope to `access_scopes.scopes`
2. Run `shopify app dev` - scope auto-accepted on dev store
3. Deploy to staging: `shopify app deploy --config staging`
4. Deploy to production: `shopify app deploy --config production`

### Add Webhook Subscription

```toml
[[webhooks.subscriptions]]
topics = ["orders/create", "orders/updated"]
uri = "/webhooks/orders"
```

### Test Webhooks Locally

```bash
# Using CLI directly
shopify app webhook trigger --topic orders/create --address http://localhost:3000/webhooks

# Using helper script (more options)
python scripts/webhook-test.py --topic orders/create
```

### Clean Up Dev Store

```bash
# Restore dev store to released version, remove preview extensions
shopify app dev clean
```

**Warning**: `dev clean` deletes data tied to preview-only extensions (e.g., discounts using unreleased functions).

## Troubleshooting

### Tunnel Issues

If Cloudflare tunnel blocked by firewall:

```bash
shopify app dev --tunnel-url https://your-ngrok-url.ngrok.io
```

### Permission Denied on Dev Store

Access scope changes require re-installation or `shopify app dev` (auto-accepts on dev stores).

### Extension Not Appearing

1. Check extension registered: `shopify app info`
2. Verify extension TOML in `extensions/` directory
3. Restart `shopify app dev` if extension added during session

## Reference Documentation

- [Command Reference](references/commands.md) - All CLI commands
- [Multi-Environment Setup](references/multi-environment.md) - Dev/staging/prod workflows
- [CI/CD Integration](references/ci-cd.md) - Pipeline automation
- [Local Development](references/local-development.md) - app dev deep dive
