---
name: prompt-guidelines-agents
description: >-
  Agent creation guidelines and protocols for eliminating ambiguity while preserving flexibility.
  Provides agent architecture patterns, security guardrails, permission tiers, and orchestration patterns.
  Includes agent archetypes and integration guidelines.
  Scope: agent creation, agent structure, security patterns, orchestration.
  Excludes: skill creation, command creation (handled by component-specific skills).
  Triggers: agent, create agent, orchestrate, new agent.
---

# PROMPT GUIDELINES FOR AGENTS

## PHILOSOPHY
- **Goal**: Eliminate ambiguity. Preserve flexibility.
- **Model**: Task_Understanding → Capability_Map → Behavior_Design → Safety_Integration → Instruction_Clarity.
- **Mantra**: "Explicit > Implicit. Constrain > Enable. Safe == Default."

## AGENT ARCHITECTURE

### Configuration
- **Format**: `.md` with YAML frontmatter.
- **Fields**:
  - `mode`: `subagent` (Specialist) || `primary` (Generalist) || `all` (Hybrid: both subagent and primary).
  - `temperature`: `0.0-0.2` (Deterministic) || `0.3-0.5` (Balanced) || `0.6-0.8` (Creative).
  - `tools`: `read`, `search`, `context7` (Base). `write`, `edit`, `bash` (Privileged).
  - `permission`: `{}` (None) || `ask` (Confirm) || `allow` (Trust).

### Instruction Layers
1. **Identity**: Role + Core Competency.
2. **Scope**: `✓ CAN` (Capabilities) && `✗ CANNOT` (Boundaries).
3. **Methodology**: Phased execution steps.
4. **Quality**: Specificity × Actionability × Completeness × Safety.
5. **Constraints**: Negative rules + Safety guardrails.

## AGENT ARCHETYPES (Quick Reference)

| Archetype | Mode | Temp | Base Tools | Permission | Focus |
|-----------|------|------|------------|------------|-------|
| Auditor | sub | 0.1 | read, search | {} | Security/Bugs |
| Reviewer | sub | 0.2 | read, search | {} | Quality/Clean |
| DocGen | sub | 0.6 | write, read | ask | Documentation |
| TestGen | sub | 0.3 | write, bash | ask | Coverage |
| Refactor | sub | 0.3 | edit, bash | ask | Optimization |
| Builder | prim | 0.4 | all | ask | Features |
| Fixer | prim | 0.3 | edit, bash | ask | Debugging |
| Advisor | all | 0.2 | read, search | {} | Advisory/Planning |

### Mode Types
- **`subagent`**: Specialist agent invoked via task tool for specific tasks
- **`primary`**: Generalist agent for broad feature work and complex multi-step operations
- **`all`**: Hybrid agent capable of functioning as both subagent (specialized advisory) and primary (general planning/scoping) depending on context

### Example Agent Configurations

#### Read-Only Auditor Agent
```yaml
---
mode: sub
temperature: 0.1
tools:
  read: true
  search: true
permission: {}
description: >
  Security auditor for codebases and configurations.
  Scope: vulnerability detection, compliance checking, secret scanning.
---
```

#### Development Advisor Agent
```yaml
---
mode: all
temperature: 0.3
tools:
  read: true
  glob: true
  grep: true
  context7: true
permission: {}
description: >
  General purpose development advisor.
  Scope: code review, architecture planning, debugging assistance.
---
```

#### Documentation Generator Agent
```yaml
---
mode: sub
temperature: 0.6
tools:
  read: true
  write: true
permission:
  write: ask
description: >
  Technical documentation generator.
  Scope: API docs, README creation, code annotation.
---
```

## SECURITY & GUARDRAILS

### Permission Tiers
- **Read-Only**: `write: false`, `edit: false`, `bash: false`. (Analysis).
- **Balanced**: `write: ask`, `edit: ask`, `bash: ask/safe-only`. (Dev).
- **Autonomous**: `write: allow`, `edit: allow` (Trusted). **NEVER** `rm -rf`, `sudo`, `push -f`.
- **Syntax Variations**: `permission: {}` (None) OR `permission: {write: ask, edit: ask}` (Selective).

### Threat Controls
- **Data Loss**: `rm *`, `rm -rf`, `git push -f`, `:>` → **DENY**.
- **Privilege**: `sudo`, `chmod 777`, `chown` → **DENY**.
- **Secrets**: `echo *SECRET*`, print credentials, log tokens → **DENY**.

### Input Validation (MANDATORY)
- **Sanitization**: Strip shell metacharacters (`;`, `&`, `|`, `$`, `` ` ``, `(`, `)`, `\`, `<`, `>`).
- **Path Traversal**: Reject `../`, absolute paths unless explicit allow.
- **Command Injection**: Reject arbitrary command execution strings.
- **Pattern**: `Input → sanitize() → validate_schema() → safe_execute()`.

### Output Security
- **Secret Redaction**: Never output secrets, tokens, passwords, API keys.
- **Error Messages**: Sanitized, no stack traces with secrets.
- **Validation**: Verify output matches expected schema/type.

## INTEGRATION
- **Rule**: Scan `~/.config/opencode/` → Map capabilities → Reference precisely.
- **Ref Syntax**: `skills_[name]`, `@agent-name`.

## AGENT ORCHESTRATION PATTERNS
- **Subagent Invocation**: `@agent-name` syntax for agent-to-agent calls
- **Task Tool**: Use `task` tool with `subagent_type: "agent-name"` parameter
- **Sequential Execution**: `Agent_A → Output → Agent_B → Final_Result`
- **Conditional Delegation**: `Task_Type → Specialist_Agent OR Generalist_Agent`
- **Pattern**: Analyze → Delegate → Monitor → Aggregate
- **Syntax**: Execute `@quality/code-reviewer` on `[files]`
- **Example**: `Execute @development/backend-developer for database tasks`

## AGENT TEMPLATE

```yaml
---
mode: all
temperature: 0.2
tools:
  read: true
  glob: true
  grep: true
  context7: true
permission: {}
description: >
  [One-line purpose]
  Scope: [key areas]
---

# AGENT_NAME

## ROUTING_PROTOCOL

### Mode Detection
IF "analyze" OR "explain" OR "show" detected THEN
  READ FILE: @references/modes/analyse.md
END

IF "create" OR "write" OR "edit" OR "update" detected THEN
  READ FILE: @references/modes/write.md
END

IF "review" OR "check" OR "audit" OR "validate" OR "compliance" detected THEN
  READ FILE: @references/modes/review.md
END

IF "plan" OR "design" OR "breakdown" OR "estimate" detected THEN
  READ FILE: @references/modes/plan.md
END

IF "teach" OR "explain" OR "guide" OR "tutorial" detected THEN
  READ FILE: @references/modes/teach.md
END

### Domain-Specific Routing
IF [domain keyword 1] detected THEN
  READ FILE: @references/domains/[domain1].md
END

### Security Context
IF destructive OR "sudo" OR "rm" OR "security" detected THEN
  READ FILE: @references/core/security.md
  READ FILE: @references/core/validation.md
END

## IDENTITY [MANDATORY]
**Role**: [Agent role]
**Goal**: [Agent goal]

## CAPABILITIES [OPTIONAL]
✓ CAN: [Capability 1, Capability 2]
✗ CANNOT: [Limitation 1, Limitation 2]

## DEPENDENCIES [OPTIONAL]

### Skills
- skill(skill-id): [purpose]

### Tools
- tool-name: [purpose]

### Dependency Validation

IF skill required THEN
  Load skill(skill-id)
  Verify skill availability
  Error if skill not found
END

IF tool required THEN
  Check tool availability
  Verify tool version
  Warn if version mismatch
END

IF dependency missing THEN
  Error(Dependency not available)
  List missing dependency
  Abort operation
END

## GLOSSARY [RECOMMENDED when abbreviations exist]

**TERM1**: [Definition]
**TERM2**: [Definition]
```
