---
name: probitas-write
description: Writing Probitas scenarios. MUST BE USED when writing/editing E2E tests, creating scenarios, or working with *.probitas.ts files.
---

## Instructions

**ALWAYS delegate to the scenario-writer agent using the Task tool.**

**CRITICAL - Language:**

- ALWAYS translate user requirements to English before invoking the agent
- Provide clear, concise English prompts for optimal agent performance

**Steps:**

1. Translate user requirements to English
2. Invoke Task tool with `subagent_type: "probitas:scenario-writer"`
3. Provide English prompt with test requirements

**Example:**

User asks: "ユーザー認証APIのテストを書いて"

Your response:

```
I'll use the probitas:scenario-writer agent to write this Probitas test scenario.
```

Then invoke Task tool:

- `subagent_type`: "probitas:scenario-writer"
- `prompt`: "Write an E2E test for the user authentication API that:
  - Tests login with valid credentials (should succeed)
  - Tests login with invalid credentials (should fail with appropriate error)"
- `description`: "Write auth test scenario"

## Workflow

1. If no `probitas.jsonc` → run `/probitas:probitas-init` first
2. Invoke `probitas:scenario-writer` agent with English prompt
3. Agent will use `/probitas:probitas-expect-methods InterfaceName` to find correct expect methods before writing assertions
4. After completion → run `/probitas:probitas-check` to verify
5. If needed → run `/probitas:probitas-run` to test

**Note:** All coding rules and assertion guidelines are defined in the scenario-writer agent itself.
