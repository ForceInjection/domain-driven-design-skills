---
name: springfield
description: Orchestrates autonomous development workflows through specialized character-based phases - research (Lisa), complexity assessment (Mayor Quimby), planning (Professor Frink), documentation (Martin Prince), implementation (Ralph), and quality validation (Comic Book Guy). Handles multi-step development tasks end-to-end with automatic error recovery, kickback routing, and iterative refinement. Use for complex feature development, bug fixes requiring investigation, or any task benefiting from structured research-plan-implement-validate cycles.
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - TodoWrite
  - AskUserQuestion
  - BashOutput
  - KillShell
---

# Springfield - Autonomous Workflow Orchestration

*"I'm learnding!"* - Ralph Wiggum

Springfield orchestrates autonomous development workflows through character-based phases: research, planning, documentation, implementation, and validation.

## Table of Contents

1. [How Springfield Works](#how-springfield-works)
2. [Workflow Phases](#workflow-phases)
   - [Phase: Lisa (Research)](#phase-lisa-research)
   - [Phase: Mayor Quimby (Decide Complexity)](#phase-mayor-quimby-decide-complexity)
   - [Phase: Professor Frink (Plan)](#phase-professor-frink-plan)
   - [Phase: Principal Skinner (Review)](#phase-principal-skinner-review)
   - [Phase: Martin Prince (Documentation)](#phase-martin-prince-documentation)
   - [Phase: Ralph (Implement)](#phase-ralph-implement)
   - [Phase: Comic Book Guy (QA)](#phase-comic-book-guy-qa)
3. [Workflow State Machine](#workflow-state-machine)
4. [Error Handling](#error-handling)
5. [Springfield Philosophy](#springfield-philosophy)

## How Springfield Works

Springfield orchestrates development through a CLI-controlled workflow. All orchestration flows through the Springfield CLI script.

**Workflow:**
1. Infer task from conversation (use AskUserQuestion if unclear)
2. Initialize session: `${CLAUDE_PLUGIN_ROOT}/scripts/springfield.sh init "TASK_DESCRIPTION"`
3. Run autonomous workflow: `${CLAUDE_PLUGIN_ROOT}/scripts/springfield.sh auto`
4. Monitor output and report results

The CLI handles all phase execution, state management, and error handling automatically.

## Workflow Phases

The CLI executes these phases in sequence:

### Phase: Lisa (Research)
Researches the codebase to understand task context and identify relevant patterns. See [REFERENCE-LISA.md](REFERENCE-LISA.md).

### Phase: Mayor Quimby (Decide Complexity)
Reviews research and decides: SIMPLE or COMPLEX? See [REFERENCE-QUIMBY.md](REFERENCE-QUIMBY.md).

### Phase: Professor Frink (Plan)
Creates implementation plans using scientific methodology. See [REFERENCE-FRINK.md](REFERENCE-FRINK.md).

### Phase: Principal Skinner (Review)
Reviews Frink's plan for complex tasks with strict standards. See [REFERENCE-SKINNER.md](REFERENCE-SKINNER.md).

### Phase: Martin Prince (Documentation)
Creates prospective documentation before implementation. See [REFERENCE-MARTIN.md](REFERENCE-MARTIN.md).

### Phase: Ralph (Implement)
Runs the implementation loop iteratively with small changes and regular commits. See [REFERENCE-RALPH.md](REFERENCE-RALPH.md).

### Phase: Comic Book Guy (QA)
Validates implementation against acceptance criteria. Verdicts: APPROVED, KICK_BACK, or ESCALATE. See [REFERENCE-COMIC-BOOK-GUY.md](REFERENCE-COMIC-BOOK-GUY.md).

## Workflow State Machine

```
lisa → quimby → frink → [skinner → frink] → martin → ralph → comic-book-guy
                         (complex only)                             ↓
                                                             APPROVED ✓
                                                             KICK_BACK → (lisa|frink|ralph)
                                                             ESCALATE → USER
```

## Error Handling

- Max 100 orchestration loop iterations (balance: enough for complex workflows with kickbacks, prevents runaway loops)
- Character scripts exit non-zero → mark failed in state.json
- Ralph timeout: 60 minutes max (typical feature implementation timeframe, prevents stuck sessions)
- Kickback limits: Max 2 per target, then ESCALATE (allows refinement attempts, prevents infinite kickback loops)

## Springfield Philosophy

Springfield orchestrates autonomous development through eventual consistency and iterative refinement. Each phase is handled by a different character, with Ralph running the implementation loop. See [REFERENCE.md](REFERENCE.md) for the Ralph pattern philosophy.
