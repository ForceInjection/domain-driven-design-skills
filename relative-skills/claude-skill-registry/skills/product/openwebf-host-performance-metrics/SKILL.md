---
name: openwebf-host-performance-metrics
description: Instrument and diagnose WebF performance in Flutter (FP/FCP/LCP, dumpLoadingState, loading-state events). Use when the user mentions FP/FCP/LCP, dumpLoadingState, first render slow, LCP verification, or performance monitoring.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, mcp__openwebf__project_profile, mcp__openwebf__docs_search, mcp__openwebf__docs_get_section, mcp__openwebf__templates_get, mcp__openwebf__templates_render
---

# OpenWebF Host: Performance Metrics & Diagnosis

## Instructions

1. Establish measurement: capture FP/FCP/LCP and key lifecycle timings.
2. Use MCP docs for the official performance monitoring APIs and guidance.
3. Use `dumpLoadingState` (or equivalent) to diagnose where time is spent.
4. Offer scaffolding templates when useful:
   - `perf/loading-state-events`
   - `perf/loadingstate-dump`
   - `perf/lcp-content-verification`

More:
- [reference.md](reference.md)
- [doc-queries.md](doc-queries.md)
- [examples.md](examples.md)
