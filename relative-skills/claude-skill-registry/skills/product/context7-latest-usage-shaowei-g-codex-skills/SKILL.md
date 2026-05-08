---
name: context7-latest-usage
description: Fetch the latest, docs-grounded API details and best practices for a library/framework using Context7 MCP tools `resolve-library-id` and `get-library-docs`. Use when a user asks for “最新用法/最新寫法/最佳實務/latest usage/current best practice/latest API” of a package, or asks how to implement a feature with a library and wants the newest docs-based guidance.
---

# Context7 Latest Usage

## Workflow

### 1) Clarify the target library and environment

- Extract the library/framework name and ecosystem (npm/pip/cargo/go/etc).
- Extract language + runtime (e.g., Node.js 20, Python 3.12) and any required version constraints.
- Extract the user’s intent (which feature/task they want to build).
- If any of these are missing or ambiguous, ask a brief clarification question before calling Context7.

### 2) Resolve the library identifier (Context7)

- Call Context7 MCP tool `resolve-library-id` with the library name (and ecosystem if supported).
- If multiple candidates are plausible, pick the best match and confirm with the user.

### 3) Fetch the newest relevant docs (Context7)

- Call Context7 MCP tool `get-library-docs` for the resolved id, scoped to the user’s task.
- Prefer latest stable docs; include migration notes if the user is upgrading.
- If the docs are large, fetch only the sections needed (install, quickstart, the specific API symbols, config, and pitfalls).

### 4) Produce the response in a fixed format

Return exactly:

1. **Up-to-date API / best practices**: concise bullet summary grounded in the fetched docs
2. **Copy-paste snippet**: tailored to the user’s language/runtime/version, includes minimal setup
3. **Sources**: Context7-provided citations/links for every important claim (especially API signatures, defaults, and behavior)

### 5) Failure handling (no guessing)

- If Context7 MCP tools are unavailable or any call fails, say so clearly and ask the user to enable Context7 MCP or paste/link the docs.
- Do not provide “latest API” claims without sources from Context7 output.
