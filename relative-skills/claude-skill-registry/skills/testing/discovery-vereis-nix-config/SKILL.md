---
name: discovery
description: MANDATORY for discovering CI commands, features, functions, patterns, or tests in a codebase. Uses progressive disclosure - load specific discovery type as needed.
---

## Mandatory

**MANDATORY:** Use this skill to discover anything in a codebase.

**CRITICAL:** Load the specific discovery type file for detailed guidance.

**NO EXCEPTIONS:** Guessing = wasted time = broken builds.

## Subagent Context

**IF YOU ARE A SUBAGENT:** Follow the discovery process directly and return findings to the primary agent.

## Discovery Types

### Available Discovery Types

This skill provides discovery patterns for different contexts. **Load the appropriate file based on what you're discovering:**

| Type | File | Use Case |
|------|------|----------|
| `ci` | `$HOME/.config/opencode/skills/discovery/ci.md` | CI/CD commands, test/lint/build commands |
| `feature` | `$HOME/.config/opencode/skills/discovery/feature.md` | Feature implementations, patterns, conventions |
| `function` | `$HOME/.config/opencode/skills/discovery/function.md` | Function definitions, usages, call graphs |
| `pattern` | `$HOME/.config/opencode/skills/discovery/pattern.md` | Coding patterns, conventions, style guides |
| `test` | `$HOME/.config/opencode/skills/discovery/test.md` | Test patterns, fixtures, mocking strategies |

**Progressive Disclosure:**
1. This SKILL.md provides overview
2. Read specific `$TYPE.md` for detailed guidance
3. Follow that file's discovery process exactly

## Usage

### Invocation

Use `/code:discovery $TYPE` where `$TYPE` is one of: `ci`, `feature`, `function`, `pattern`, `test`

Example:
```
/code:discovery ci
/code:discovery feature authentication
/code:discovery function process_payment
```

## Core Principles

1. **Source of truth matters**
   - CI files > project files > guessing
   - Existing code > documentation > assumptions

2. **Exact replication**
   - Use EXACT commands/patterns found
   - Don't modify, simplify, or "improve"

3. **Never guess**
   - If not found, ask for guidance
   - Report what was searched

4. **Context awareness**
   - Check parent directories for monorepos
   - Consider project structure

## Quick Reference

| Discovery Type | Primary Sources | Fallback |
|---------------|-----------------|----------|
| `ci` | `.github/workflows/*.yml`, `.gitlab-ci.yml` | `package.json`, `mix.exs`, etc. |
| `feature` | Existing implementations, tests | Ask user |
| `function` | Codebase search, LSP | Ask user |
| `pattern` | Existing code, style guides | Ask user |
| `test` | Test files, fixtures | Ask user |

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"I know what commands to run"
**WRONG:** Discover from source of truth

"I'll simplify the command"
**WRONG:** Use EXACT command found

"Similar to other projects"
**WRONG:** Every project has unique patterns

**NO EXCEPTIONS**
