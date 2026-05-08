---
name: github-actions
# prettier-ignore
description: Use when creating GitHub Actions workflows for CI/CD - testing, building, publishing npm packages, and automating repository tasks
---

# GitHub Actions

## Quick Start

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npm test
```

## Common Patterns

### Matrix Testing

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
    os: [ubuntu-latest, windows-latest]
runs-on: ${{ matrix.os }}
```

### npm Publishing

```yaml
- run: npm publish
  env:
    NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Caching

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

## Triggers

| Event | Usage |
|-------|-------|
| `push` | On push to branches |
| `pull_request` | On PR open/update |
| `release` | On release publish |
| `workflow_dispatch` | Manual trigger |
| `schedule` | Cron schedule |

## Key Features

```yaml
# Conditional steps
- run: npm publish
  if: github.event_name == 'release'

# Job dependencies
jobs:
  build:
    # ...
  deploy:
    needs: build

# Environment variables
env:
  CI: true
  NODE_ENV: test

# Secrets
${{ secrets.MY_SECRET }}
```

## Tips

- Use `npm ci` (not `npm install`) for reproducible builds
- Cache node_modules with `actions/setup-node` cache option
- Use `workflow_dispatch` inputs for manual parameters
- Add `concurrency` to cancel in-progress runs on new pushes
