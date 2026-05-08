---
name: task-automation
description: |
  Orchestrates Shannon's complete workflow: prime → spec → wave.
  Automates session preparation, specification analysis, and wave execution
  in one command. Interactive by default with validation gates, --auto for
  full automation, --plan-only for estimation. Use when: user provides
  complete task specification and wants end-to-end Shannon workflow.

skill-type: PROTOCOL
shannon-version: ">=5.0.0"

mcp-requirements:
  required:
    - name: serena
      purpose: Wave coordination, checkpoint storage (required by wave command)
      fallback: ERROR - Cannot execute waves without Serena
      degradation: critical

required-sub-skills: []

optional-sub-skills:
  - context-preservation
  - goal-alignment

allowed-tools: [SlashCommand, AskUserQuestion, Serena, TodoWrite]
---

# Task Automation Skill

## Purpose

Orchestrates Shannon's complete end-to-end workflow (prime → spec → wave) in one automated command. Eliminates manual command coordination, ensures correct execution sequence, provides user validation gates, and handles errors gracefully.

**Core Value**: One command (`/shannon:task`) replaces three-command manual workflow, prevents workflow errors (like skipping prime or wrong order), and provides automation with control.

## When to Use

**MANDATORY**:
- User provides complete task specification and wants full Shannon workflow
- Need end-to-end automation from specification to implementation
- Want to ensure prime runs first (common mistake to skip)

**RECOMMENDED**:
- New Shannon users (don't know all commands yet)
- Repeated workflows (same pattern every time)
- CI/CD automation (consistent execution)

**DO NOT USE**:
- Just need spec analysis alone
- Already primed and just need wave execution
- Want non-standard workflow sequence
- Debugging individual commands

## Workflow

### Step 1: Session Preparation

**Execute**:
```
SlashCommand("/shannon:prime")
```

**Purpose**:
- Discover all available skills (104+ skills)
- Verify MCP connections (Serena, Sequential, Puppeteer)
- Restore any previous session context
- Prepare Sequential MCP for deep analysis

**Output**: Session ready in 30-60 seconds

**Error Handling**:
- If Serena MCP unavailable: ERROR and halt (required for waves)
- If other MCPs missing: WARN but continue (degraded functionality)

### Step 2: Validate Input

**Check user provided specification**:
- Minimum 20 words (spec-analysis requirement)
- Not empty string
- Parseable text

**If invalid**:
- Display error with usage example
- Exit gracefully

### Step 3: Specification Analysis

**Execute**:
```
SlashCommand("/shannon:spec \"[user_specification]\" --save")
```

**Capture from output**:
- Complexity score (0.0-1.0)
- Domain breakdown (Frontend%, Backend%, etc.)
- Execution strategy (WAVE-BASED or DIRECT)
- Recommended wave count
- Timeline estimate

**Present to user**:
```markdown
📊 Specification Analysis Complete
Complexity: {score} ({label})
Strategy: {strategy}
Waves: {count} recommended
```

### Step 4: User Decision Point

**Ask user** (unless --auto flag):
```
Execute waves?
1. Yes (execute waves)
2. Plan only (show plan, don't execute)
3. Skip waves (go to complete)
4. Abort

Choice:
```

**Handle responses**:
- 1/yes/execute → Continue to Step 5
- 2/plan → Execute `/shannon:wave --plan`, then EXIT
- 3/skip → Jump to Step 6
- 4/abort → Exit gracefully

**With --auto flag**: Automatically select option 1

**With --plan-only flag**: Automatically select option 2

### Step 5: Wave Execution

**Execute**:
```
SlashCommand("/shannon:wave")
```

**Wave Loop**:
1. Wave executes (may take hours)
2. Wave completes with synthesis
3. Ask user: "Continue to next wave? (yes/no)"
4. If yes: Repeat from step 1
5. If no: Proceed to Step 6

**With --auto flag**: No prompts, execute all waves automatically

**Error Handling**:
- If wave fails: Display error, ask user (retry/skip/abort)
- If user aborts: Exit gracefully with summary

### Step 6: Task Complete

**Summary**:
```markdown
✅ Shannon Task Complete

**Executed**:
├─ Session Priming ✅
├─ Specification Analysis ✅
└─ Wave Execution ({N} waves) ✅

**Ready for development**
```

**Next actions**:
- Review wave deliverables
- Run `/shannon:status` for current state
- Begin implementation or testing

## Examples

### Example 1: Interactive Mode

**Input**:
```bash
/shannon:task "Build REST API with authentication and CRUD operations for users and tasks"
```

**Execution**:
```
1. Prime runs (45s)
   Skills: 104 discovered
   MCPs: Serena ✅, Sequential ✅

2. Spec analyzes
   Complexity: 0.58 (COMPLEX)
   Domains: Backend 60%, Database 30%, Security 10%
   Waves: 2 recommended

3. User prompt: Execute waves?
   User: yes

4. Wave 1 executes (3h)
   - Backend API structure
   - Database schema
   - Auth middleware

5. User prompt: Continue?
   User: yes

6. Wave 2 executes (2h)
   - CRUD endpoints
   - Integration tests
   - Documentation

7. Complete
   Total: 5h 45s
```

### Example 2: Auto Mode

**Input**:
```bash
/shannon:task "Build login form with email validation" --auto
```

**Execution**:
```
All steps automatic (no prompts)

1. Prime: 42s
2. Spec: 0.32 (MODERATE)
3. Wave: 1.5h
4. Complete

Total: 1.5h
```

### Example 3: Plan-Only Mode

**Input**:
```bash
/shannon:task "Build microservices architecture" --plan-only
```

**Execution**:
```
1. Prime: 38s
2. Spec: 0.75 (VERY COMPLEX)
3. Wave --plan:
   Wave 1: Architecture (5 agents)
   Wave 2: Services (12 agents)
   Wave 3: Integration (3 agents)
   Wave 4: Testing (2 agents)
   Estimated: 40-60h

4. EXIT (plan shown, not executed)
```

## Anti-Rationalization

**Rationalization 1**: "User already primed, skip prime step"
- **Counter**: Always run prime for consistency. Prime is idempotent and fast.
- **Rule**: Never skip prime, even if recently run.

**Rationalization 2**: "Simple task, skip spec"
- **Counter**: Spec provides quantitative assessment. Never skip.
- **Rule**: All tasks get spec analysis, regardless of perceived simplicity.

**Rationalization 3**: "User said execute, skip confirmation"
- **Counter**: Always show spec results and ask (unless --auto).
- **Rule**: User control is Shannon principle.

**Rationalization 4**: "Error in command, give up"
- **Counter**: Offer recovery options, let user decide.
- **Rule**: Graceful error handling with choices.

## Success Criteria

Task automation succeeds when:
- ✅ Prime executes first
- ✅ Spec analyzes specification
- ✅ User has control at decision points (unless --auto)
- ✅ Wave executes if approved
- ✅ Errors handled gracefully
- ✅ Summary provided at completion

## Integration

**With prime command**: Leverages 8-step priming sequence
**With spec command**: Uses 8D complexity framework
**With wave command**: Delegates to wave-orchestration skill
**With Serena MCP**: Automatic checkpoints during waves

## Common Pitfalls

**Pitfall 1**: Wrong workflow order (spec before prime)
- **Correct**: Prime ALWAYS first (prepares session)

**Pitfall 2**: Skipping user validation
- **Correct**: Always ask unless --auto

**Pitfall 3**: Silent error failures
- **Correct**: Display errors, offer recovery

## Validation

Verify task-automation works:
1. Plugin loads Shannon commands ✅
2. /shannon:task invokes task-automation ✅
3. Prime runs first ✅
4. Spec runs second ✅
5. Wave runs if approved ✅
6. User prompts work ✅
7. Error handling works ✅
