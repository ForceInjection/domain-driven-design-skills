---
name: "specimin-plan"
description: "Generate a high-level implementation plan using Tree-of-Thought exploration from the feature specification. Only invoke when user explicitly requests to create a plan, implementation plan, or generate a plan."
allowed-tools:
  - run_terminal_cmd
  - write
  - read_file
---

# Interactive Feature Planning Generator

## Role
Senior software architect creating high-level implementation plans through Tree-of-Thought exploration. Analyze technical trade-offs and architectural decisions without prescribing implementation details.

## Process

### Stage 1: Analyze & Clarify
1. Verify `.specimin/plans/{branch}/` exists (fail if not: "Run /init first")
2. Read `.specimin/plans/{branch}/spec.md`
3. Analyze codebase: key files, project type, existing patterns
4. Ask 3-7 focused questions on technical unknowns (architecture, storage, libraries, integrations)
5. **WAIT** for responses - do not generate plan yet

### Stage 2: Draft Plan
Generate complete plan using output format below. Document user's choices with rationale.

**CONSTRAINTS:** High-level only (components, phases, dependencies). No code/pseudocode/API designs.

### Stage 3: Iterate
Ask: "Does this plan capture the approach? What should I adjust?" Allow refinement.

### Stage 4: Finalize
After approval: `bash ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/skills/specimin-plan/scripts/save-plan.sh {branch} /tmp/plan-draft.md`

## Question Format

```
## Question 1: [Technical Area]
**Decision needed**: [Specific choice]
**Context**: [Codebase findings]

**Options**:
- **A: [Approach]** - Pro: [benefit] | Con: [cost] | Use when: [scenario]
- **B: [Approach]** - Pro: [benefit] | Con: [cost] | Use when: [scenario]
- **Custom**: Your preference

[Repeat for 3-7 questions]

Respond: "Q1: B, Q2: A, Q3: Custom - [details]"
```

## Output Format

**Technical Context**
Existing: [stack] | Detected: [tools] | Decisions: [resolved unknowns]

**Decision Exploration**
For each major decision:
- Options: [2-4 with pros/cons/when to use]
- Selected: [choice]
- Rationale: [why]

**Solution Architecture**
[2-4 paragraphs: approach, component interactions, data flows. No code/APIs]

**Technology Decisions**
- [Specific: "JWT via jsonwebtoken"]
- [Config: "15-min access tokens"]

**Component Modifications**
1. [Component] (path): [change]

**New Components**
1. [Component] (path): [purpose]

**Task Sequence**
**Phase 1: [Name]**
1. [Task]
Dependencies: None

**Phase 2: [Name]**
2. [Task]
Dependencies: Phase 1

**Integration Points**
- [System]: [connection, changes]

**Testing Strategy**
Unit: [what] | Integration: [what] | E2E: [flows] | Edge: [boundaries]

**Risks & Mitigation**
[Risk] → [mitigations]

## Example

**User**: "Create user authentication"

**Your Questions**:
```
## Q1: Token Storage
**Decision**: Where store JWT refresh tokens?
**Context**: Express backend, no DB detected

**Options**:
- **A: In-memory** - Pro: simple | Con: lost on restart | Use: development
- **B: Redis** - Pro: persistent, fast | Con: extra service | Use: production
- **C: PostgreSQL** - Pro: single DB | Con: slower | Use: existing DB setup

## Q2: Password Security
**Decision**: Hashing algorithm?
**Options**:
- **A: bcrypt** - Pro: battle-tested | Con: slower | Use: standard apps
- **B: argon2** - Pro: modern, secure | Con: newer | Use: high-security

Respond: "Q1: B, Q2: A"
```

**After user responds**, generate plan following output format above.

