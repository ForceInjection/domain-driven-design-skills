---
name: openwebf-host-controller-manager
description: Manage WebF controllers safely with WebFControllerManager (lifecycle, reuse, pre-render, multiple controllers). Use when the user mentions WebFControllerManager, controller lifecycle, pre-render controller, or multi-page WebF integration.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, mcp__openwebf__project_profile, mcp__openwebf__docs_search, mcp__openwebf__docs_get_section, mcp__openwebf__templates_get, mcp__openwebf__templates_render
---

# OpenWebF Host: Controller Management

## Instructions

1. Detect current controller strategy (ad-hoc vs manager) and the navigation pattern.
2. Prefer `WebFControllerManager` when you have:
   - multiple WebF screens/subviews
   - preloading/pre-render needs
   - complex lifecycle requirements
3. Use MCP docs to confirm best practices and safe defaults.
4. Provide minimal code changes and verification steps.

More:
- [reference.md](reference.md)
- [doc-queries.md](doc-queries.md)
- [examples.md](examples.md)
