---
name: github-actions-ci
description: GitHub Actions CI/CD guide for the dotfiles repository. Use when creating or modifying GitHub Actions workflows, adding CI/CD pipelines, setting up build/test automation, configuring matrix builds, working with artifacts, implementing E2E tests in containers, or troubleshooting workflow issues. Covers workflow patterns, security best practices, caching strategies, and multi-platform testing.
---

# GitHub Actions CI/CD Guide

## Project Context

Current workflows:
- **installer-ci.yml**: Build → test → E2E test (matrix: ubuntu, debian, fedora, centos containers, macOS)
- **release.yml**: GoReleaser on version tags

## Core Workflow Template

```yaml
name: CI

on:
  pull_request:
    paths:
      - "component/**"
      - ".github/workflows/ci.yml"
  push:
    branches: [main]
    paths:
      - "component/**"

concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
  cancel-in-progress: true

permissions: {}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go build -v ./...
```

## Essential Patterns

### Concurrency Control
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
  cancel-in-progress: true
```

### Permissions
```yaml
permissions: {}  # Top-level default

jobs:
  build:
    permissions:
      contents: read  # Job-level grants
```

### Caching
```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-
```

### Artifacts
```yaml
# Upload
- uses: actions/upload-artifact@v4
  with:
    name: build-artifacts
    path: dist/
    retention-days: 1
    compression-level: 0
    if-no-files-found: error

# Download
- uses: actions/download-artifact@v4
  with:
    name: build-artifacts
    path: dist/
```

### Matrix Builds
```yaml
strategy:
  fail-fast: false
  matrix:
    include:
      - os: ubuntu-latest
        platform: ubuntu
      - os: ubuntu-latest
        platform: debian
        container: debian:bookworm
      - os: macos-latest
        platform: macos

runs-on: ${{ matrix.os }}
container: ${{ matrix.container }}
```

## When to Read References

**[testing-patterns.md](references/testing-patterns.md)** - E2E tests, interactive testing with expect, platform-specific binary selection, container testing, test isolation

**[security.md](references/security.md)** - Permissions beyond read/write, secret handling, input validation, pull_request vs pull_request_target, token security, script injection prevention

**[optimization.md](references/optimization.md)** - Debugging failing workflows, cache optimization, performance tuning, conditional execution, timeout handling, troubleshooting

## Common Actions

```yaml
# Checkout with full history
- uses: actions/checkout@v4
  with:
    fetch-depth: 0

# Setup Go from go.mod
- uses: actions/setup-go@v5
  with:
    go-version-file: go.mod

# GoReleaser build
- uses: goreleaser/goreleaser-action@v6
  with:
    version: latest
    args: build --clean --snapshot
    workdir: installer
```

## Quick Reference

**Triggers**: `push`, `pull_request`, `release`, `workflow_dispatch`, `schedule`

**Runners**: `ubuntu-latest`, `macos-latest`, `macos-13`, `windows-latest`

**Contexts**: `${{ github.event_name }}`, `${{ github.ref }}`, `${{ github.head_ref }}`, `${{ runner.os }}`, `${{ matrix.platform }}`
