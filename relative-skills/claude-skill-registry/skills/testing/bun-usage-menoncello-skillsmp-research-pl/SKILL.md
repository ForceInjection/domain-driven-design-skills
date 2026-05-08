---
name: bun-usage
description: This skill should be used when working with Bun, a fast JavaScript runtime and toolkit. Use this skill for tasks involving Bun runtime execution, package management, bundling, testing, or when users ask about Bun-specific features, APIs, or best practices. Trigger when users mention "bun" commands, Bun's APIs, or request help with Bun installation, configuration, or usage.
---

# Bun

## Overview

Bun is a fast JavaScript runtime that bundles transpilation, package management, testing, and bundling in one tool. Treat it as a drop-in Node.js replacement with better startup times, first-class TypeScript/JSX support, built-in watch/hot reload modes, and tooling for producing standalone executables.

## When to Trigger This Skill

- Users mention `bun`, `bunx`, `bun test`, or `bun build`
- Work requires Bun-specific runtime behavior, package installation, bundling, or testing
- Guidance is needed for Bun installation, upgrades, or cross-platform deployment
- Debugging Bun tasks, especially around databases, hot reload, or Node.js compatibility

## Quick Start Checklist

1. Confirm Bun is installed: `bun --version`. If missing, install with `curl -fsSL https://bun.sh/install | bash` and add `~/.bun/bin` to `PATH`.
2. Inspect `package.json`, `bunfig.toml`, or scripts the project expects. Use `bun install` to sync dependencies and respect workspaces.
3. Run scripts via `bun run <script>`, or run entrypoints directly (`bun src/index.ts`) to bypass script wrappers when debugging.
4. Run tests with `bun test` (use `--watch` for TDD) and prefer the Jest-style `bun:test` APIs.
5. Build or bundle with `bun build --compile --minify --sourcemap --bytecode ./entry.ts` when shipping binaries. Use `bun --watch`/`--hot` during development.

Keep this checklist in mind before loading additional references.

## Progressive Loading Map

Load only what is needed to stay within context limits.

- Read `references/runtime-and-apis.md` for detailed runtime execution, package manager commands, bundler flags, testing syntax, Web-standard APIs, and Node.js compatibility notes.
- Read `references/workflows-and-executables.md` for step-by-step workflows (project scaffolding, script execution, standalone binaries, native DB clients, bunx usage, hot reload guidance).
- Read `references/workspaces.md` for monorepo setup, dependency hoisting, filtered script execution, and workspace troubleshooting.
- Read `references/setup-and-best-practices.md` for installation instructions, system requirements, performance characteristics, and dev/prod best practices.
- Read `references/troubleshooting-and-frameworks.md` when debugging runtime errors, module cache issues, or when integrating React, Next.js, Remix, Express, or Hono.
- Read `references/llms.txt` for a condensed overview of Bun features and CLI syntax.
- Read `references/llms-full.txt` for deep architectural details, design philosophy, and deployment guidance.
- Read `references/bun-v1.3.md` for the latest release highlights (full-stack dev server, Bun.sql, Redis client, router upgrades, security scanner, etc.).

Only load the references relevant to the task at hand.

## Execution Playbooks

### Build or Debug an Existing Bun Project

1. Verify Bun version and upgrade if project requires a newer release.
2. Run `bun install` (or `bun install --production`) to sync dependencies.
3. If the repo declares `workspaces`, load `references/workspaces.md` for dependency hoisting, filtered script execution, and troubleshooting.
4. Start or test the app using project scripts (`bun run dev`, `bun test`, etc.).
5. For runtime behavior, bundler options, or Node compatibility questions, load `references/runtime-and-apis.md`.
6. If encountering runtime errors, stack traces, or cache issues, consult `references/troubleshooting-and-frameworks.md`.

### Scaffold or Migrate a Project to Bun

1. Use `bun init` (or `bun init --react`) to scaffold configs and entry points.
2. Wire up environment variables through `.env` files (auto-loaded).
3. Reference `references/workflows-and-executables.md` for React templates, bunx commands, database clients, and guidance on watch/hot reload modes.
4. Validate Node.js compatibility requirements and adjust imports per `references/runtime-and-apis.md`.
5. When splitting the project into multiple packages, follow `references/workspaces.md` to register packages, link local deps, and orchestrate scripts.

### Ship Production Builds or Executables

1. Confirm performance requirements and OS targets.
2. Follow the optimization flags in `references/setup-and-best-practices.md` (`--minify --sourcemap --bytecode --compile`).
3. Use `bun build --compile ./entry.ts --outfile <name>` for single-file binaries; add `--target` flags for cross-compilation when necessary.
4. Capture sourcemaps for debugging and document the generated artifacts.
5. For bundling frontend + backend into a single binary, rely on HTML imports and guidance from `references/workflows-and-executables.md`.

### Investigate Runtime, Test, or Compatibility Issues

1. Reproduce the failure with `bun run <entry>` or `bun test <file> --watch`.
2. If stack traces are truncated, run the entry file directly instead of via package scripts.
3. Load `references/troubleshooting-and-frameworks.md` for cache clearing, dependency restart steps, and framework-specific notes.
4. When dealing with Node APIs, confirm support status via `references/runtime-and-apis.md` or the full reference set (`references/llms*.txt`).
5. Escalate to official docs or release notes if a feature landed recently (v1.3 details live in `references/bun-v1.3.md`).

## Compatibility and Framework Notes

- Bun aims for Node compatibility but hooks/inspector APIs are still evolving; always validate modules that rely on those features.
- Framework integrations (React, Next.js, Remix, Express, Hono) are documented inside `references/troubleshooting-and-frameworks.md`. Load that file when configuring adapters, middleware, or dev servers.
- Databases (SQLite, PostgreSQL, MySQL, Redis) are accessible through Bun-native clients outlined in `references/workflows-and-executables.md`.

## Escalation Paths

If the bundled references do not cover a need:

1. Load `references/llms-full.txt` for in-depth architecture and deployment coverage.
2. Review official sources:
   - https://bun.sh/docs
   - https://github.com/oven-sh/bun
   - https://bun.sh/discord
3. Capture repro steps, commands, Bun version, and platform when escalating bugs to maintainers or the user.

Use the skill references rather than copying large sections into the active context.
