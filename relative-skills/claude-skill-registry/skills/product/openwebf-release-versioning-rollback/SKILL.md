---
name: openwebf-release-versioning-rollback
description: Design versioning, cache busting, progressive rollout, and rollback for remote WebF bundles. Use when the user mentions version pinning, cache busting, force update, rollback, feature flags, or staged rollout.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, mcp__openwebf__docs_search, mcp__openwebf__docs_get_section, mcp__openwebf__docs_related
---

# OpenWebF Release: Versioning & Rollback

## Instructions

1. Define a version scheme and how the host selects a version (pin, latest, channel).
2. Define cache-busting strategy (path-based preferred for immutable assets).
3. Define rollback: how to revert quickly without breaking clients.
4. Use MCP docs (“Deploying Updates”, “Cache Management”, “Progressive Rollout”) as the baseline.

More:
- [reference.md](reference.md)
- [doc-queries.md](doc-queries.md)
- [examples.md](examples.md)
