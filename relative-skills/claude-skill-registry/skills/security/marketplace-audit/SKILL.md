---
name: marketplace-audit
description: Display plugin versions from marketplace.json. Use when user asks to "audit versions", "show plugin versions", "list marketplace versions", or wants to see the current state of plugin versioning.
---

# Marketplace Audit

Display all plugin versions from the marketplace.

## Usage

Run this jq command to list all plugins and their versions:

```bash
jq '.plugins[] | {name, version}' .claude-plugin/marketplace.json
```

Present results in a table format:

| Plugin | Version |
|--------|---------|
| plugin-name | x.y.z |

## Notes

- The `version` field in marketplace.json is the marketplace entry version
- Each plugin also has its own version in `plugins/<name>/.claude-plugin/plugin.json`
- Skills within plugins do not have separate version fields

## Reference

- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
