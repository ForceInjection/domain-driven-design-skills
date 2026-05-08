---
name: deployment-configs
description: Docker, K8s, systemd configurations
allowed-tools: Read, Bash, Grep, Glob
---

# deployment-configs

**Purpose**: Docker, K8s, systemd configurations for Redis implementations.

**Activation Triggers**:
- When implementing deployment configs
- When user mentions Redis Docker, K8s, systemd configurations
- When designing Redis architecture

## Quick Reference

See templates/, scripts/, and examples/ for implementation patterns.

## Templates

- `templates/` - Configuration file templates
- All templates use placeholders (no hardcoded credentials)

## Scripts

- `scripts/` - Automation and testing scripts

## Examples

- `examples/` - Implementation examples for common use cases

## Security Compliance

This skill follows strict security rules:
- All code examples use placeholder values only
- No real API keys, passwords, or secrets
- Environment variable references in all code
- `.gitignore` protection documented
