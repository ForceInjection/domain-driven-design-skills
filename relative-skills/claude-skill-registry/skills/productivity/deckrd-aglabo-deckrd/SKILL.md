---
name: deckrd
description: Stepwise derivation workflow from requirements to executable tasks.
---

<!-- textlint-disable ja-technical-writing/sentence-length -->
<!-- textlint-disable ja-technical-writing/max-comma -->
<!-- markdownlint-disable line-length -->

# Deckrd - Your Goals to Tasks framework

Deckrd is a document-centered framework for structuring and refining ideas through iterative discussion with AI.
It guides the creation of requirements, decisions, specifications, and implementation plans as derived documents, not final outputs.
Each document captures reasoning at a specific stage, preserving context and intent.
Through a strict, state-driven workflow, these documents are progressively shaped into executable development tasks.
Deckrd enables documentation to function as a practical engine for action, not just description.

## Commands

| Command           | Description                                    |
| ----------------- | ---------------------------------------------- |
| `init <ns>/<mod>` | Initialize module directory and session        |
| `req`             | Derive requirements from goals                 |
| `dr`              | Manage Decision Records (req step only)        |
| `dr --add`        | Append a new Decision Record                   |
| `spec`            | Derive specifications from requirements        |
| `impl`            | Derive implementation plan from specifications |
| `tasks`           | Derive executable tasks from implementation    |
| `status`          | Display current workflow progress and status   |

## Session Resolution

Session state is stored in `docs/.deckrd/.session.json`.

**Before executing any command:**

1. Read `.session.json` to get active module and current step
2. Validate the command matches expected workflow progression
3. Load the appropriate reference from `references/commands/`

**Reference selection:**

| Current State  | Next Command | Load Reference                                    |
| -------------- | ------------ | ------------------------------------------------- |
| (none)         | init         | [commands/init.md](references/commands/init.md)   |
| init completed | req          | [commands/req.md](references/commands/req.md)     |
| req completed  | spec         | [commands/spec.md](references/commands/spec.md)   |
| spec completed | impl         | [commands/impl.md](references/commands/impl.md)   |
| impl completed | tasks        | [commands/tasks.md](references/commands/tasks.md) |

**For workflow overview:** [workflow.md](references/workflow.md)
**For session management details:** [session.md](references/session.md)
**For status command:** [commands/status.md](references/commands/status.md)
