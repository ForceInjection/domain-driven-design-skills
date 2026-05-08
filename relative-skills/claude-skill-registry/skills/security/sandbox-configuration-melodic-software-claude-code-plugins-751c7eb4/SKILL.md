---
name: sandbox-configuration
description: Central authority for Claude Code sandboxing and isolation. Covers sandboxed bash tool, /sandbox command, filesystem isolation (blocked access, custom paths), network isolation (domain restrictions, proxy support), OS-level enforcement (bubblewrap on Linux, Seatbelt on macOS), sandbox configuration options, escape hatches (dangerouslyDisableSandbox, allowUnsandboxedCommands), and sandbox security limitations. Assists with configuring sandbox settings, understanding isolation mechanisms, and troubleshooting sandbox issues. Delegates 100% to docs-management skill for official documentation.
allowed-tools: Read, Glob, Grep, Skill
---

# Sandbox Configuration Skill

## MANDATORY: Invoke docs-management First

> **STOP - Before providing ANY response about Claude Code sandboxing:**
>
> 1. **INVOKE** `docs-management` skill
> 2. **QUERY** for the user's specific topic
> 3. **BASE** all responses EXCLUSIVELY on official documentation loaded
>
> **Skipping this step results in outdated or incorrect information.**

### Verification Checkpoint

Before responding, verify:

- [ ] Did I invoke docs-management skill?
- [ ] Did official documentation load?
- [ ] Is my response based EXCLUSIVELY on official docs?

If ANY checkbox is unchecked, STOP and invoke docs-management first.

---

## Overview

Central authority for Claude Code sandboxing and isolation. This skill uses **100% delegation to docs-management** - it contains NO duplicated official documentation.

**Architecture:** Pure delegation with keyword registry. All official documentation is accessed via docs-management skill queries.

## When to Use This Skill

**Keywords:** sandboxing, sandbox, /sandbox, filesystem isolation, network isolation, bubblewrap, Seatbelt, dangerouslyDisableSandbox, allowUnsandboxedCommands, excludedCommands, httpProxyPort, socksProxyPort, domain restrictions, sandbox configuration, blocked access

**Use this skill when:**

- Configuring sandbox settings
- Understanding filesystem isolation
- Setting up network isolation
- Troubleshooting sandbox blocking commands
- Understanding OS-level enforcement
- Configuring escape hatches
- Setting up proxy support

## Keyword Registry for docs-management Queries

Use these keywords when querying docs-management skill for official documentation:

### Sandbox Overview

| Topic | Keywords |
| --- | --- |
| Overview | "sandboxing", "sandboxed bash tool", "/sandbox command" |
| Why Sandbox | "why sandboxing", "approval fatigue", "sandbox productivity" |
| OS Enforcement | "bubblewrap", "Seatbelt", "OS-level enforcement" |

### Filesystem Isolation

| Topic | Keywords |
| --- | --- |
| Default Behavior | "filesystem isolation", "sandbox filesystem", "default writes" |
| Blocked Access | "blocked access", "sandbox blocked patterns" |
| Custom Paths | "custom allowed paths", "custom denied paths" |
| Protection | "critical file modification", "filesystem protection" |

### Network Isolation

| Topic | Keywords |
| --- | --- |
| Domain Restrictions | "network isolation", "domain restrictions", "sandbox network" |
| Proxy Support | "httpProxyPort", "socksProxyPort", "custom proxy" |
| User Confirmation | "user confirmation domains", "new domain approval" |

### Configuration Options

| Topic | Keywords |
| --- | --- |
| Settings | "sandbox configuration", "sandbox settings" |
| Escape Hatch | "dangerouslyDisableSandbox", "allowUnsandboxedCommands" |
| Excluded Commands | "excludedCommands", "sandbox exclusions" |
| Security Limitations | "sandbox security limitations", "domain fronting" |

## Quick Decision Tree

**What do you want to do?**

1. **Enable/disable sandbox** -> Query docs-management: "sandboxing", "/sandbox command"
2. **Configure filesystem access** -> Query docs-management: "filesystem isolation", "sandbox filesystem"
3. **Configure network access** -> Query docs-management: "network isolation", "domain restrictions"
4. **Allow specific commands** -> Query docs-management: "excludedCommands", "allowUnsandboxedCommands"
5. **Set up proxy** -> Query docs-management: "httpProxyPort", "socksProxyPort"
6. **Understand limitations** -> Query docs-management: "sandbox security limitations"

## Topic Coverage

### Sandbox System

- Sandboxed bash tool overview
- /sandbox slash command
- Why sandboxing matters (approval fatigue, productivity, autonomy)
- OS-level enforcement (bubblewrap on Linux, Seatbelt on macOS)
- Open source sandbox runtime

### Filesystem Isolation Topics

- Default writes behavior
- Default read behavior
- Blocked access patterns
- Custom allowed and denied paths
- Protection against critical file modification

### Network Isolation Topics

- Domain restrictions
- User confirmation for new domains
- Custom proxy support
- Comprehensive coverage for subprocesses
- httpProxyPort and socksProxyPort settings

### Configuration Options Topics

- dangerouslyDisableSandbox escape hatch
- allowUnsandboxedCommands configuration
- excludedCommands list
- Security limitations and considerations

## Troubleshooting Quick Reference

| Issue | Keywords for docs-management |
| --- | --- |
| Sandbox blocking commands | "excludedCommands", "allowUnsandboxedCommands" |
| Network requests blocked | "network isolation", "domain restrictions" |
| Filesystem access denied | "filesystem isolation", "blocked access" |
| Proxy not working | "httpProxyPort", "socksProxyPort" |

## Related Skills

- **permission-management** - For allow/deny/ask rules
- **enterprise-security** - For managed policies
- **settings-management** - For general configuration

## Version History

- **v1.0.0** (2025-11-30): Initial release (split from security-meta)
  - Focused on sandboxing and isolation only
  - Pure delegation architecture
  - Comprehensive keyword registry

---

## Last Updated

**Date:** 2025-11-30
**Model:** claude-opus-4-5-20251101
