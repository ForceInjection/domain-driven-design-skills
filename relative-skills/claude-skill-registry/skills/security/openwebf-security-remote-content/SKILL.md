---
name: openwebf-security-remote-content
description: Review security risks and mitigations for remote WebF content (untrusted bundles, URL allowlists, HTTPS, trust boundaries, clickjacking). Use when the user mentions untrusted remote bundles, bundle URL validation/allowlists, or remote updates risk.
allowed-tools: Read, Grep, Glob, mcp__openwebf__docs_search, mcp__openwebf__docs_get_section, mcp__openwebf__docs_related
---

# OpenWebF Security: Remote Content & Trust Boundaries

## Instructions

1. Identify trust boundaries:
   - remote bundle URLs
   - user-generated content
   - bridge/native plugins
2. Review how URLs are constructed and validated (allowlists, HTTPS, pinning/versioning).
3. Use MCP docs (“Security”, “Store Guidelines”) as the baseline for recommendations.
4. Provide remediation steps ordered by severity; do not modify files by default.

If the user is primarily asking about store policy/compliance for remote updates, prefer `openwebf-security-store-guidelines`.

More:
- [reference.md](reference.md)
- [doc-queries.md](doc-queries.md)
- [examples.md](examples.md)
