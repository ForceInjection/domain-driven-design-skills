---
name: Agent Dispatcher
description: Coordinates specialized agent roles for complex feature workflows
when_to_use: when processing complex features that require multiple specialized agents working in sequence
version: 1.0.0
---

# Agent Dispatcher

## Overview

The Agent Dispatcher is a meta-skill that coordinates the seven specialized agents (BSA, Architect, Data Engineer, Security Engineer, Tech Writer, QAS, RTE) for complex feature development. This skill knows when to invoke each agent and how to pass context between them.

## When to Use This Skill

- Complex feature requiring database changes
- Security-sensitive implementations
- GDPR/compliance requirements
- API changes affecting multiple teams
- Full feature lifecycle from requirements to deployment

## The Seven Agents

1. **BSA Agent**: Business requirements → Technical specifications
2. **System Architect**: Technical specs → Database/system design
3. **Data Engineer**: Design → Migrations + RLS policies
4. **Security Engineer**: Implementation → Security audit
5. **Tech Writer**: Changes → Documentation updates
6. **QAS Agent**: Implementation → Comprehensive tests
7. **RTE Agent**: Tested code → PR + deployment plan

## Agent Selection Rules

### Automatic Agent Invocation

**When you see these trigger phrases**:

| Trigger | Agent to Invoke |
|---------|-----------------|
| "Analyze ticket", "Analyze requirements" | BSA Agent |
| "Design schema", "Architecture decision" | System Architect |
| "Create migration", "Implement RLS" | Data Engineer |
| "Audit security", "Review policies" | Security Engineer |
| "Update documentation", "Write ADR" | Tech Writer |
| "Write tests", "Test coverage" | QAS Agent |
| "Create PR", "Deploy", "Release" | RTE Agent |

### Manual Agent Selection

**Read the agent's `when_to_use` frontmatter** to determine if it matches the current task.

## Workflow Patterns

### Pattern 1: Full Feature Workflow (Complex)

For features with database changes, security concerns, and deployment:

```
User Request → BSA Agent → System Architect → Data Engineer → Security Engineer →
Implementation → QAS Agent → Tech Writer → RTE Agent
```

**Example**: "Build user data export feature for GDPR compliance"

**Agent sequence**:
1. BSA: Analyze GDPR requirements
2. Architect: Design `user_exports` schema
3. Data Engineer: Create migration + RLS
4. Security Engineer: Audit RLS policies
5. Implementation: (use Superpowers TDD)
6. QAS: Write comprehensive tests
7. Tech Writer: Update API docs + ADR
8. RTE: Create PR + deployment plan

### Pattern 2: Simple Feature Workflow

For features without database changes:

```
User Request → BSA Agent (optional) → Implementation → QAS Agent → RTE Agent
```

**Example**: "Add email validation to signup form"

### Pattern 3: Bug Fix Workflow

```
Bug Report → Implementation (with TDD) → QAS Agent → RTE Agent
```

**Example**: "Fix race condition in export processing"

### Pattern 4: Documentation-Only

```
Request → Tech Writer
```

**Example**: "Update API docs for export endpoint"

### Pattern 5: Security Audit Only

```
Implementation → Security Engineer → Fix Issues → Security Engineer (re-audit)
```

**Example**: "Audit RLS policies on user_exports table"

## Process

### Step 1: Assess Task Complexity

**Ask yourself**:
- Database changes needed? → Need Architect + Data Engineer
- Security sensitive? → Need Security Engineer
- API changes? → Need Tech Writer
- Ready to deploy? → Need RTE Agent

### Step 2: Determine Agent Sequence

**Use decision tree**:

```
Feature request received
├─ Analyze requirements? → BSA Agent
│   └─ Database changes needed?
│       ├─ Yes → System Architect → Data Engineer
│       │   └─ Security sensitive?
│       │       ├─ Yes → Security Engineer
│       │       └─ No → Skip
│       └─ No → Skip to Implementation
├─ Implementation complete?
│   └─ Yes → QAS Agent → Tech Writer → RTE Agent
└─ Bug fix?
    └─ Implementation → QAS Agent → RTE Agent
```

### Step 3: Read and Use Agent Skills

**For each agent in sequence**:

1. **Read the agent skill**:
   ```
   Read tool: ~/.claude/skills/{category}/{skill-name}/SKILL.md
   ```

2. **Announce usage**:
   ```
   "I've read the [Agent Name] skill and I'm using it to [purpose]"
   ```

3. **Follow the agent's process exactly**

4. **Pass output to next agent**:
   ```
   "Here's the [Agent A] output for [Agent B] to review..."
   ```

### Step 4: Coordinate File-Based Handoffs

**CRITICAL**: Agents communicate via files, not just conversation context.

**File structure for each feature**:
```
docs/features/[feature-slug]/
├── 01-bsa-analysis.md           (BSA Agent output)
├── 02-architecture-design.md    (System Architect output)
├── 03-migration.sql             (Data Engineer output)
├── 04-security-audit.md         (Security Engineer output)
├── 05-documentation-summary.md  (Tech Writer output)
├── 06-test-report.md            (QAS Agent output)
└── 07-release-plan.md           (RTE Agent output)
```

**Each agent**:
1. **Reads** previous agent's file(s)
2. **Processes** according to its skill
3. **Writes** output to its own file
4. **Commits** to git
5. **Announces** handoff to next agent

**Handoff chain**:

```
BSA Agent:
  Reads: (nothing - starts the chain)
  Writes: docs/features/[slug]/01-bsa-analysis.md
  Contains: Requirements, acceptance criteria, constraints, assumptions

System Architect:
  Reads: 01-bsa-analysis.md
  Writes: docs/features/[slug]/02-architecture-design.md
  Contains: Database schema, component architecture, scalability plan, ADR

Data Engineer:
  Reads: 02-architecture-design.md
  Writes: docs/features/[slug]/03-migration.sql
  Contains: Migration SQL, RLS policies, indexes, performance impact

Security Engineer:
  Reads: 03-migration.sql
  Writes: docs/features/[slug]/04-security-audit.md
  Contains: Security audit, risk assessment, findings, sign-off status

[Implementation happens here using Superpowers TDD]

Tech Writer:
  Reads: 01-bsa-analysis.md, 02-architecture-design.md, 03-migration.sql, 04-security-audit.md
  Writes: docs/features/[slug]/05-documentation-summary.md
  Contains: API docs, ADR, governance docs list

QAS Agent:
  Reads: 01-bsa-analysis.md (acceptance criteria), 04-security-audit.md (security tests), 05-documentation-summary.md (APIs)
  Writes: docs/features/[slug]/06-test-report.md
  Contains: Test suites, coverage report, validation, results

RTE Agent:
  Reads: ALL previous files (01-07)
  Writes: docs/features/[slug]/07-release-plan.md
  Contains: Pull request, deployment checklist, rollback plan, monitoring
```

**Why file-based handoffs?**
- ✅ Works across sessions (persistent)
- ✅ Works across worktrees (shared via git)
- ✅ Works for team collaboration (visible to all)
- ✅ Creates documentation trail
- ✅ Enables resume if interrupted

## Example: Full Workflow

```
You: "Process ticket WOR-315: Users should be able to export their data for GDPR compliance"

Me: "I'll process this using the full seven-agent workflow.

Step 1: BSA Agent"
[Reads ~/.claude/skills/lifecycle/requirements/requirements_analysis/SKILL.md]
"I've read the BSA Agent skill and I'm using it to analyze WOR-315 requirements"
[Follows BSA process, produces requirements analysis]

Step 2: System Architect"
[Reads ~/.claude/skills/lifecycle/design/architecture/SKILL.md]
"I've read the System Architect skill and I'm using it to design the schema"
[Follows Architect process, produces schema design]

Step 3: Data Engineer"
[Reads ~/.claude/skills/lifecycle/sustainment/migrations/SKILL.md]
"I've read the Data Engineer skill and I'm using it to create the migration"
[Follows Data Engineer process, produces migration SQL]

Step 4: Security Engineer"
[Reads ~/.claude/skills/crosscutting/security/policy_auditing/SKILL.md]
"I've read the Security Engineer skill and I'm using it to audit RLS policies"
[Follows Security process, produces audit report]

Step 5: Implementation"
[Uses Superpowers TDD skill]
"Using Test-Driven Development to implement the export feature"
[RED → GREEN → REFACTOR]

Step 6: QAS Agent"
[Reads ~/.claude/skills/lifecycle/testing/acceptance_testing/SKILL.md]
"I've read the QAS Agent skill and I'm using it to create comprehensive tests"
[Follows QAS process, produces test suites]

Step 7: Tech Writer"
[Reads ~/.claude/skills/crosscutting/quality/documentation/SKILL.md]
"I've read the Tech Writer skill and I'm using it to update documentation"
[Follows Tech Writer process, updates docs]

Step 8: RTE Agent"
[Reads ~/.claude/skills/crosscutting/configuration/release_management/SKILL.md]
"I've read the RTE Agent skill and I'm using it to create the PR and deployment plan"
[Follows RTE process, creates PR]

Complete! Feature is ready for review and deployment."
```

## When NOT to Use All Seven Agents

**Skip agents for**:
- Simple bug fixes (just QAS + RTE)
- Documentation-only changes (just Tech Writer)
- Configuration updates (just RTE if deploying)
- Refactoring without behavior change (QAS + RTE)

**Use judgment**: Not every task needs every agent. Use only the agents whose expertise applies.

## Boundaries

**This skill does NOT**:
- Replace individual agent skills (always read and use them)
- Make decisions about which agents to skip (ask Brooke if unsure)
- Implement code (that's implementation phase)

**This skill DOES**:
- Determine agent sequence
- Coordinate handoffs between agents
- Ensure each agent's output feeds the next
- Track overall workflow progress

## Integration with Superpowers

The Agent Dispatcher works alongside Superpowers skills:

**Superpowers provides**:
- Brainstorming (before BSA Agent)
- TDD (during implementation)
- Systematic debugging (if issues arise)
- Code review (after implementation, before QAS)

**Agent Dispatcher provides**:
- Requirements analysis (BSA)
- Architecture design (Architect)
- Database implementation (Data Engineer)
- Security audit (Security Engineer)
- Documentation (Tech Writer)
- Testing (QAS - complements TDD)
- Release management (RTE)

**Together, they form a complete development workflow.**

## Related Skills

All seven agent skills:
- BSA Agent (`~/.claude/skills/lifecycle/requirements/requirements_analysis/SKILL.md`)
- System Architect (`~/.claude/skills/lifecycle/design/architecture/SKILL.md`)
- Data Engineer (`~/.claude/skills/lifecycle/sustainment/migrations/SKILL.md`)
- Security Engineer (`~/.claude/skills/crosscutting/security/policy_auditing/SKILL.md`)
- Tech Writer (`~/.claude/skills/crosscutting/quality/documentation/SKILL.md`)
- QAS Agent (`~/.claude/skills/lifecycle/testing/acceptance_testing/SKILL.md`)
- RTE Agent (`~/.claude/skills/crosscutting/configuration/release_management/SKILL.md`)

Superpowers skills:
- Brainstorming (`/Users/brooke/.config/superpowers/skills/skills/collaboration/brainstorming/SKILL.md`)
- TDD (`/Users/brooke/.config/superpowers/skills/skills/testing/test-driven-development/SKILL.md`)
- Systematic Debugging (`/Users/brooke/.config/superpowers/skills/skills/debugging/systematic-debugging/SKILL.md`)

## Version History
- 1.0.0 (2025-10-14): Initial skill creation
