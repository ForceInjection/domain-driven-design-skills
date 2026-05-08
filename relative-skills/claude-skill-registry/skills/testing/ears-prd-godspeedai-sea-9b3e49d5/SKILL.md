---
name: ears-prd
description: Write PRDs with EARS requirements and acceptance criteria that are testable.
---

# EARS PRD authoring


## EARS patterns
- **Ubiquitous**: The system shall <response>.
- **Event-driven**: When <trigger>, the system shall <response>.
- **State-driven**: While <state>, the system shall <response>.
- **Optional**: Where <condition>, the system shall <response>.
- **Unwanted**: If <condition>, the system shall <response>.

## Output checklist
- PRD-ID (`PRD-###`)
- `satisfies: [ADR-...]`
- Requirements labeled `REQ-###`
- Acceptance criteria per major feature
