---
name: openwebf-security
description: DEPRECATED umbrella Skill (backward compatibility). Use only for cross-cutting security reviews spanning remote content + XSS/sanitization + store compliance. Prefer focused openwebf-security-* Skills.
allowed-tools: Read, Grep, Glob, mcp__openwebf__docs_search, mcp__openwebf__docs_get_section, mcp__openwebf__docs_related
---

# OpenWebF Security Skill

## Deprecated

Prefer:
- `openwebf-security-remote-content`
- `openwebf-security-xss-sanitization`
- `openwebf-security-store-guidelines`

## Instructions

If this umbrella Skill is active, route to the most relevant focused security Skill based on trigger terms (“untrusted content”, “XSS”, “App Store/Play Store”). Do not modify files by default; provide findings and prioritized remediation.

If repo context is missing, start with `/webf:doctor` and then route to the focused Skill.

## Examples

- “Audit this app for risks related to remote updates and App Store compliance.”
