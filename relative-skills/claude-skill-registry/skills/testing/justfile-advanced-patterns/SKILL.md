---
name: justfile-advanced-patterns
description: Level 3 patterns - test-smart, deploy, migrate, logs, status (production systems)
---

# Advanced Patterns (Level 3)

Production systems. Git-aware testing, deployment integration, migrations, observability.

## Commands

### test-smart

Git-aware test execution. Conditional expensive tests based on changed files.

```just
# Smart test execution (conditional component tests based on git changes)
test-smart mode="default":
    @scripts/test-smart.sh {{mode}}
```

**Implementation (`scripts/test-smart.sh`):**
```bash
#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-default}"

# Always run fast unit tests
echo "🧪 Unit tests (always)..."
pnpm vitest run --project unit --reporter=verbose

# Determine if component tests needed
NEED_COMPONENT=false

case "$MODE" in
  staged)   CHANGED=$(git diff --cached --name-only --diff-filter=ACMR || echo "") ;;
  push)     CHANGED=$(git diff --name-only origin/main...HEAD || echo "") ;;
  *)        CHANGED=$(git diff --name-only HEAD || echo "")
            CHANGED+=$'\n'$(git diff --cached --name-only --diff-filter=ACMR || echo "") ;;
esac

# Check if component-related files changed
if echo "$CHANGED" | grep -qE "src/(components|design-system|pages)/.*\.tsx?$"; then
  NEED_COMPONENT=true
fi

# Run component tests if needed
if [ "$NEED_COMPONENT" = true ]; then
  echo "🎨 Component changes detected..."
  pnpm vitest run --project component --reporter=verbose
else
  echo "⏭️  No component changes"
fi
```

**Usage:**
```bash
just test-smart         # Default (working + staged)
just test-smart staged  # Pre-commit hook
just test-smart push    # Pre-push hook
```

### deploy

Deploy to environment. Cloud provider integration.

```just
# Deploy to environment (default: dev)
deploy environment="dev":
    @scripts/deploy/check-auth.sh {{environment}}
    @scripts/deploy/full.sh {{environment}}
```

**Auth check (`scripts/deploy/check-auth.sh`):**
```bash
#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"

# Check gcloud auth
if ! gcloud auth list --filter=status:ACTIVE >/dev/null 2>&1; then
  echo "❌ Not authenticated"
  exit 1
fi

# Check project
EXPECTED="myproject-$ENV"
CURRENT=$(gcloud config get-value project 2>/dev/null)

if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "❌ Wrong project"
  echo "   Expected: $EXPECTED"
  echo "   Current:  $CURRENT"
  exit 1
fi

echo "✅ Authenticated: $(gcloud auth list --filter=status:ACTIVE --format='value(account)')"
```

**Partial deploys:**
```just
deploy-api environment="dev":
    @scripts/deploy/api.sh {{environment}}

deploy-web environment="dev":
    @scripts/deploy/web.sh {{environment}}
```

### migrate

Database migrations. Apply, rollback, create, history.

```just
# Apply database migrations
migrate:
    <apply all pending migrations>

# Rollback last migration
migrate-down:
    <rollback one migration>

# Create new migration
migrate-create message:
    <generate migration with description>

# View migration history
migrate-history:
    <show applied migrations timeline>
```

**Python (Alembic):**
```just
migrate:
    uv run alembic upgrade head

migrate-down:
    uv run alembic downgrade -1

migrate-create message:
    uv run alembic revision --autogenerate -m "{{message}}"

migrate-history:
    uv run alembic history --verbose
```

**Migration testing:**
```just
test-migration:
    uv run pytest -v -m "migration" --durations=10
```

### logs

Service logs. Tail cloud logs.

```just
# View service logs
logs service="api" environment="dev":
    @scripts/gcp/logs.sh {{service}} {{environment}}
```

**Implementation:**
```bash
#!/usr/bin/env bash
SERVICE="${1:-api}"
ENV="${2:-dev}"

gcloud logging tail \
  "resource.type=cloud_run_revision AND resource.labels.service_name=$ENV-$SERVICE" \
  --project="myproject-$ENV" \
  --format="table(timestamp, textPayload)"
```

### status

Deployment health check.

```just
# Check deployment status
status environment="dev":
    @scripts/gcp/status.sh {{environment}}
```

**Implementation:**
```bash
#!/usr/bin/env bash
ENV="${1:-dev}"

echo "Services:"
gcloud run services list \
  --project="myproject-$ENV" \
  --format="table(SERVICE,URL,LAST_DEPLOYED)"
```

## Pattern: Git-Aware Testing

Problem: Full test suite slow (unit 3s, component 18s). Running all tests every commit slows development.

Solution: Conditionally run expensive tests based on git diff.

**Modes:**
- `default`: Working directory + staged
- `staged`: Staged files only (pre-commit)
- `push`: Commits since origin/main (pre-push)

**Benefits:**
- Fast feedback (3s typical)
- Comprehensive when needed (21s UI changes)
- Safe (always runs unit tests)

## Pattern: Deployment Integration

Deployment as first-class justfile command. No context switching to console/scripts.

**Commands:**
- `deploy` - Full deployment
- `deploy-api`, `deploy-web` - Partial (fast iteration)
- `logs` - Debugging
- `status` - Health check

**Safety:**
- Auth checking before deploy
- Default to dev environment
- Explicit production deploys
- Tag images with git SHA

## Pattern: Migration Management

Migrations alongside tests/builds. First-class development operation.

**Workflow:**
1. Create migration: `just migrate-create "add users table"`
2. Apply locally: `just migrate`
3. Test: `just test-migration`
4. Deploy with migrations: deployment script runs migrate

**Testing:**
```python
@pytest.mark.migration
def test_upgrade_downgrade_cycle():
    downgrade(config, "base")
    upgrade(config, "head")
    downgrade(config, "-1")
    upgrade(config, "head")
```

## When to Add Level 3

Add when:
- Deploying to production
- Database-backed application
- Slow test suites (need optimization)
- Cloud-native systems

Skip when:
- No deployment workflows
- No database
- Fast test suites already
- Static sites/libraries

## Cloud Provider Examples

**GCP (Cloud Run):** Examples above

**AWS (ECS):**
```just
deploy environment="dev":
    aws ecs update-service --cluster {{environment}} --service api --force-new-deployment
```

**Azure (Container Apps):**
```just
deploy environment="dev":
    az containerapp update --name api --resource-group {{environment}} --image {{image}}
```
