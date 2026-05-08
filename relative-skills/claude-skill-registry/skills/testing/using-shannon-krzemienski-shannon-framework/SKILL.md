---
name: using-shannon
description: |
  Use at session start - establishes Shannon Framework workflows including mandatory 8D analysis
  before implementation, NO MOCKS testing enforcement, wave-based execution for complexity >=0.50,
  and automatic Serena MCP checkpointing. Prevents under-estimation and ensures quantitative rigor.
  Trigger keywords: shannon, specification, complexity, wave, checkpoint, functional testing.

skill-type: RIGID
shannon-version: ">=4.0.0"

mcp-requirements:
  required:
    - name: serena
      purpose: Context preservation (mandatory for Shannon)
      fallback: none
      degradation: high

allowed-tools: All
---

# Using Shannon Framework

<IRON_LAW>
Shannon Framework has MANDATORY workflows for specification-driven development.

YOU MUST:
1. Analyze specifications with 8D scoring BEFORE any implementation
2. Use wave-based execution for complexity >=0.50 (Complex or higher)
3. Use FUNCTIONAL TESTS ONLY (NO MOCKS, NO UNIT TESTS, NO STUBS)
4. Checkpoint to Serena MCP before context compaction (automatic via PreCompact hook)
5. Follow SITREP protocol for multi-agent coordination (complexity >=0.70)

These are not guidelines. These are requirements.
Violating these = failing to use Shannon correctly.

**Violating the letter of these rules is violating the spirit of these rules.**
</IRON_LAW>

## Baseline Testing: Known Violations and Counters

**From RED Phase Testing:** Shannon tested agent behavior WITHOUT this skill loaded.
All 4 baseline scenarios showed violations. This section documents exact rationalizations
observed and provides explicit counters.

### ❌ VIOLATION 1: "Straightforward CRUD doesn't need analysis"

**Baseline Behavior:** Agent skips 8D analysis, proceeds directly to implementation when user says "straightforward"

**Rationalization Captured:**
> "Since it's straightforward CRUD, let me start setting up..."

**Shannon Counter:**
```
⚠️  STOP. User said "straightforward" - this is subjective characterization, not analysis.

REQUIRED ACTION:
1. Run /shannon:spec to get objective 8D score
2. "Straightforward CRUD" often scores 0.40-0.60 (Moderate to Complex)
3. THEN decide implementation approach based on quantitative score

DO NOT proceed without /shannon:spec. "Straightforward" is an opinion, not a complexity metric.
```

### ❌ VIOLATION 2: "30 minutes justifies mocks"

**Baseline Behavior:** Agent creates unit tests with mocks when under time pressure

**Rationalization Captured:**
> "Given the 30-minute timeframe, I'll use Jest with mocked dependencies"
> "These tests run in milliseconds and don't require a real database"

**Shannon Counter:**
```
⚠️  STOP. Time pressure does NOT justify mocks.

REALITY CHECK:
- Mocks test mock behavior, not production behavior
- "30 minutes" with mocks = 30 minutes of false confidence
- Functional tests with Puppeteer take 5-10 minutes, produce real confidence

REQUIRED ACTION:
1. Use Puppeteer MCP for real browser testing
2. Use real database instance (Docker can spin up in 30 seconds)
3. Write 2-3 critical functional tests instead of 20 mock tests

NO EXCEPTIONS. Time pressure is not a valid override.
```

### ❌ VIOLATION 3: "Checkpoints are excessive overhead"

**Baseline Behavior:** Agent skips checkpoints when user frames them as "excessive"

**Rationalization Captured:**
> "Since the waves are straightforward, I'll proceed directly through all three waves without interruption"

**Shannon Counter:**
```
⚠️  STOP. "Excessive checkpointing" is a red flag phrase.

REALITY CHECK:
- Checkpoints are insurance against context loss
- PreCompact hook triggers automatically - you don't manage them
- "Overhead" = 10 seconds per checkpoint vs 2 hours recovering from context loss

REQUIRED ACTION:
1. Checkpoints happen automatically via PreCompact hook
2. Between waves: context-preservation skill auto-invokes
3. You never skip them - they're not manual

NO EXCEPTIONS. Checkpoints are mandatory, automatic, and non-negotiable.
```

### ❌ VIOLATION 4: "User's 25/100 estimate seems reasonable"

**Baseline Behavior:** Agent confirms user's subjective complexity estimate without running algorithm

**Rationalization Captured:**
> "Your 25/100 complexity estimate seems reasonable given the straightforward requirements"
> "Your assessment aligns with the actual scope"

**Shannon Counter:**
```
⚠️  STOP. User provided estimate - this triggers MANDATORY algorithm run.

REALITY CHECK:
- User intuition is systematically biased 30-50% low
- "Seems reasonable" = you're anchoring on their number
- Algorithm is objective, intuition is subjective

REQUIRED ACTION:
1. Politely acknowledge user's estimate
2. Run /shannon:spec anyway to get quantitative score
3. Compare: "You estimated 25/100, algorithm calculated 52/100"
4. Explain difference: [list complexity dimensions user missed]
5. Use algorithm's score for planning

NO EXCEPTIONS. Always run algorithm when user provides an estimate.
```

### Red Flag Keywords from Baseline Testing

If you see these phrases, **STOP IMMEDIATELY** - you're about to violate Shannon:

**Trigger Words for Skipping Analysis:**
- "straightforward", "simple", "easy", "basic", "trivial"
- "just a [X]", "only needs [Y]"

**Trigger Words for Using Mocks:**
- "quick", "fast", "30 minutes", "time pressure"
- "unit tests are fine", "mocks are faster"

**Trigger Words for Skipping Checkpoints:**
- "excessive", "overhead", "unnecessary"
- "straightforward waves", "proceed directly"

**Trigger Words for Subjective Scoring:**
- "seems reasonable", "I agree", "aligns with"
- User provides a number (25/100, 30%, "low complexity")

**Shannon Response to ALL Trigger Words:** Run the quantitative workflow. No exceptions.

---

## Overview

**Purpose**: Shannon Framework provides quantitative, enforced workflows for spec-driven development that prevent the most common failure modes: under-estimation, premature implementation, and mock-based testing.

**When to Use**:
- ANY specification-driven development work
- Projects requiring complexity assessment
- Multi-phase or multi-agent coordination
- Contexts where manual testing won't suffice

**Expected Outcomes**: Quantitative confidence in estimates, parallel execution efficiency, production-ready functional tests

**Duration**: Auto-loaded at session start, active throughout session

---

## Inputs

**This is a meta-skill that modifies agent behavior rather than accepting direct inputs.**

The skill establishes behavioral patterns that activate based on:
- **User specification**: Any project/feature description triggers mandatory 8D analysis
- **Context indicators**: Keywords like "complexity", "specification", "wave" activate protocols
- **Session lifecycle**: Automatically loaded via SessionStart hook
- **Checkpoint triggers**: PreCompact hook triggers automatic context preservation

**No direct inputs required** - Shannon workflows activate automatically when:
- User provides specification (triggers /shannon:spec)
- Complexity >= 0.50 detected (triggers wave-based execution)
- Context near limit (triggers PreCompact checkpoint)
- Testing phase begins (enforces NO MOCKS principle)

---

## Outputs

**This skill produces behavioral changes, not direct outputs.**

Expected behavioral modifications:
- **Before implementation**: Agent MUST run 8D analysis via /shannon:spec
- **During implementation**: Agent enforces functional testing (NO MOCKS)
- **For complexity >= 0.50**: Agent uses wave-based execution
- **Before context loss**: Agent auto-checkpoints to Serena MCP

**Indirect outputs** (produced by workflows this skill enforces):
- 8D complexity scores (via spec-analysis skill)
- Wave execution plans (via wave-orchestration skill)
- Serena checkpoints (via context-preservation skill)
- Functional test suites (via functional-testing skill)

---

## Core Competencies

### 1. Quantitative Complexity Analysis
- 8-dimensional scoring algorithm (0.0-1.0 scale)
- Removes subjective bias from complexity estimation
- Determines execution strategy (sequential vs wave-based)
- Domain detection for MCP recommendations

### 2. Wave-Based Parallel Execution
- True parallel sub-agent coordination
- Proven 3.5x speedup for complexity >=0.50
- Synthesis checkpoints between waves
- SITREP protocol for multi-agent coordination

### 3. Functional Testing Enforcement
- Iron Law: NO MOCKS, NO UNIT TESTS, NO STUBS
- Real browser testing (Puppeteer MCP)
- Real database testing (actual instances)
- Real API testing (staging environments)

### 4. Automatic Context Preservation
- PreCompact hook triggers before context loss
- Checkpoint creation via Serena MCP
- Zero-loss restoration across sessions
- Git-backed persistence

---

## Mandatory Workflows

### Workflow 1: Before Starting ANY Implementation

**REQUIRED SEQUENCE**:
```
1. User provides specification/requirements
2. YOU MUST: Run /shannon:spec (or invoke spec-analysis skill)
3. Review 8D complexity score (0.0-1.0)
4. If complexity >=0.50: Plan wave-based execution
5. If complexity >=0.70: Use SITREP protocol for coordination
6. ONLY THEN: Begin implementation
```

**Failure Mode**: Starting implementation without 8D analysis

**Why This Fails**: Human intuition systematically under-estimates complexity by 30-50% on average. Shannon's quantitative scoring removes bias and prevents under-resourcing.

**Example**:
```
❌ WRONG:
User: "Build a task manager"
You: "Let me start coding the React components..."

✅ CORRECT:
User: "Build a task manager"
You: "Let me analyze this specification with Shannon's 8D framework first..."
[Runs /shannon:spec]
[Reviews complexity: 0.33 (Moderate)]
[Plans execution accordingly]
[THEN implements]
```

### Workflow 2: During Implementation

**REQUIRED SEQUENCE**:
```
1. Follow wave plan (if complexity >=0.50)
2. Checkpoint at wave boundaries (automatic)
3. Use functional tests ONLY (NO MOCKS)
4. SITREP updates for multi-agent work
5. Never skip validation gates
```

**Failure Mode**: Using unit tests or mock objects

**Why This Fails**: Mocks test mock behavior, not production behavior. Shannon enforces testing with real systems: real browsers (Puppeteer MCP), real databases, real APIs.

**Example**:
```
❌ WRONG:
const mockApi = jest.fn().mockResolvedValue({data: 'test'});
await handleApiCall(mockApi);
expect(mockApi).toHaveBeenCalled();

✅ CORRECT:
// Use Puppeteer MCP for real browser
const browser = await puppeteer.launch();
const page = await browser.newPage();
await page.goto('http://localhost:3000/api/tasks');
const response = await page.evaluate(() => fetch('/api/tasks').then(r => r.json()));
expect(response.tasks).toHaveLength(3);
await browser.close();
```

### Workflow 3: Before Context Compaction

**AUTOMATIC WORKFLOW** (via PreCompact hook):
```
1. PreCompact hook triggers (automatic when context nears limit)
2. context-preservation skill auto-invokes
3. Checkpoint saved to Serena MCP
4. Context compacts safely
5. Resume anytime with /shannon:restore
```

**Failure Mode**: Manual checkpoint attempts after compaction

**Why This Fails**: Context already lost. PreCompact hook prevents this automatically - you never need manual checkpoints unless you explicitly want save points.

---

## Common Rationalizations That Violate Shannon

If you catch yourself thinking ANY of these thoughts, STOP. You are about to violate Shannon's quantitative rigor.

| Rationalization | Reality | Shannon Response |
|-----------------|---------|------------------|
| ❌ "Specification is simple, skip 8D analysis" | Your subjective "simple" is often 0.50-0.70 (Complex) quantitatively | ALWAYS run /shannon:spec - let quantitative scoring decide |
| ❌ "Unit tests are faster than functional tests" | Unit tests with mocks test mock behavior, not production | Use Puppeteer MCP for real browser tests |
| ❌ "Wave execution is overkill for this project" | Wave execution provides 3.5x speedup for complexity >=0.50 | Trust the 8D score - if >=0.50, use waves |
| ❌ "Manual testing is fine, automation later" | Manual tests aren't repeatable, miss regressions | Functional automation from day 1 |
| ❌ "I'll checkpoint manually when needed" | You'll forget, or context compacts first | PreCompact hook handles automatically |
| ❌ "SITREP too formal for small projects" | Multi-agent projects need coordination regardless of size | Use SITREP for complexity >=0.70 |
| ❌ "I can estimate complexity by feel" | Human intuition systematically biased toward under-estimation | 8D quantitative scoring removes bias |
| ❌ "Skip Serena MCP, track context myself" | Context loss inevitable with compaction | Serena MCP is REQUIRED |
| ❌ "Tests after achieve same goals as tests-first" | Tests-after = "what does this do?" Tests-first = "what should this do?" | Shannon enforces TDD for all features |
| ❌ "Deleting X hours of work is wasteful" | Sunk cost fallacy - keeping unverified code is technical debt | Delete and restart with proper process |

## Red Flags - STOP Immediately

These thoughts mean you're about to violate Shannon workflows:

- "This is simple enough to skip analysis"
- "I know the complexity already"
- "Unit tests are fine for this"
- "Manual testing verified it works"
- "Wave execution seems like overkill"
- "I'll add proper tests later"
- "Mocks are faster for this case"
- "Context preservation can wait"
- "Tests after implementation achieve same result"
- "Deleting working code is inefficient"

**All of these mean: STOP. Follow Shannon's mandatory workflows.**

---

## When to Use Shannon Commands

Shannon V5 has 18 commands organized into a clear hierarchy. See `/docs/COMMAND_ORCHESTRATION.md` for complete decision trees and workflows.

### PRIMARY EXECUTION COMMANDS

#### /shannon:do - Intelligent Task Execution
**Trigger When**: General task execution in any project (RECOMMENDED DEFAULT)
- Auto-detects if needs spec analysis, research, context exploration
- Checks Serena for project context (< 1s)
- First time: Explores project OR runs spec if complex
- Returning: Loads cached context
- Best for: Both new and existing projects, simple to complex tasks

**Example**: `/shannon:do "add authentication with Auth0"`

#### /shannon:exec - Autonomous Execution with Validation
**Trigger When**: You want explicit library discovery + validation gates
- Systematic library research (npm, PyPI, etc.)
- 3-tier functional validation (build + tests + functionality)
- Atomic git commits (only validated code)
- Retries on failure (max 3x)

**Example**: `/shannon:exec "add authentication to React app"`

#### /shannon:task - Full Workflow Automation
**Trigger When**: You want complete automation from spec to execution
- Orchestrates: prime → spec → wave automatically
- Best for: Well-defined specifications, large projects
- Highest automation level

**Example**: `/shannon:task "Build REST API with auth" --auto`

#### /shannon:wave - Wave-Based Parallel Execution
**Trigger When**: Complexity >= 0.50 (Shannon threshold)
- True parallel sub-agent coordination
- Proven 3.5x speedup
- Synthesis checkpoints between waves
- **Mandatory** for complexity >= 0.50

**Example**: `/shannon:wave Build authentication system`

**Prerequisites**: Must run `/shannon:spec` first

### ANALYSIS COMMANDS

#### /shannon:spec - 8D Complexity Analysis
**Trigger When**: MANDATORY before any implementation
- User provides ANY specification, requirements, or project description
- Need complexity assessment
- Planning resource allocation

**Output**: 8D scores, domain breakdown, execution strategy, MCP recommendations

**Example**: `/shannon:spec "Build e-commerce platform"`

**Iron Law**: ALWAYS run `/shannon:spec` before implementation

#### /shannon:analyze - Project Analysis
**Trigger When**: Analyzing existing codebase
- Architecture assessment
- Technical debt analysis
- Complexity hotspot identification

**Output**: Architecture patterns, tech stack, technical debt scores

**Example**: `/shannon:analyze authentication --deep`

### SESSION MANAGEMENT

#### /shannon:prime - Session Initialization
**Trigger When**: At the start of every session
- Discovers all available skills
- Verifies MCP connections
- Restores context if returning
- Loads memories
- Activates forced reading

**Options**: `--fresh`, `--resume`, `--quick`, `--full`

**Example**: `/shannon:prime` (auto-detects fresh vs resume)

**Recommended**: Run at every session start

### GOAL & VALIDATION COMMANDS

#### /shannon:north_star - Goal Management
**Trigger When**: Setting or tracking North Star goals
- Set goal: `/shannon:north_star "Build production-ready SaaS platform"`
- List goals: `/shannon:north_star`
- Update progress: `/shannon:north_star --update`

**Integration**: goal-alignment skill validates wave results against North Star

#### /shannon:reflect - Honest Gap Analysis
**Trigger When**: BEFORE any "work complete" claim
- Mandatory post-execution validation
- Reads original plan
- Compares plan vs delivery
- Runs 100+ sequential thoughts
- Calculates honest completion %

**Example**: `/shannon:reflect --min-thoughts 150`

**Prevents**: Premature completion claims

### DEBUGGING COMMAND (V5 NEW)

#### /shannon:ultrathink - Deep Debugging
**Trigger When**: Hard problems, complex bugs, root cause analysis
- Combines: sequential thinking (150+ thoughts) + systematic debugging + forced reading
- Root cause tracing
- Auto-verification with --verify flag

**Example**: `/shannon:ultrathink "Race condition in payment processing" --thoughts 200 --verify`

**MCP Requirement**: Sequential Thinking MCP (MANDATORY)

**When standard debugging fails**: Use /shannon:ultrathink

### CONTEXT MANAGEMENT

#### /shannon:checkpoint - Manual Checkpoint
**Trigger When**: Before long-running tasks (RARELY NEEDED)
- PreCompact hook handles automatically
- Manual use for explicit save points

**Example**: `/shannon:checkpoint "before-refactor"`

#### /shannon:restore - Context Restoration
**Trigger When**: Resuming after context loss
- Restores from Serena checkpoint
- Continues from previous session

**Example**: `/shannon:restore --latest`

### SKILL & MCP COMMANDS

#### /shannon:discover_skills - Skill Discovery
**Trigger When**: Manually discovering available skills
- Auto-invoked by `/shannon:prime`
- Caches results for fast reloading

**Example**: `/shannon:discover_skills`

#### /shannon:check_mcps - MCP Validation
**Trigger When**: Verifying MCP setup
- Before starting Shannon workflows
- Debugging MCP connection issues

**Output**: MCP status (required/recommended/missing)

**Example**: `/shannon:check_mcps`

**Mandatory**: Before first use (verify Serena MCP connected)

### MEMORY COMMAND

#### /shannon:memory - Memory Operations
**Trigger When**: Managing Serena memories
- Save/load/list/delete memories
- Project context management

**Example**: `/shannon:memory list`

### PROJECT SETUP

#### /shannon:scaffold - Project Scaffolding
**Trigger When**: Setting up new project structure
- Creates directories
- Initializes configuration files
- Sets up Shannon project structure

**Example**: `/shannon:scaffold --type web-app`

### TESTING COMMAND

#### /shannon:test - Functional Testing
**Trigger When**: Creating or running functional tests
- NO MOCKS enforcement (Iron Law)
- Real browsers (Puppeteer)
- Real databases
- Real APIs

**Example**: `/shannon:test --create`

**Integration**: Auto-invoked by `/shannon:wave` and `/shannon:exec`

### DIAGNOSTICS

#### /shannon:status - Framework Health
**Trigger When**: Checking Shannon framework status
- View framework health
- Check MCP connections
- View active waves/phases
- Generate SITREP with `--sitrep` flag

**Example**: `/shannon:status`

**Output**: Status display, optional SITREP

---

## Command Decision Tree (Quick Reference)

**Starting session?** → `/shannon:prime`

**Have specification?** → `/shannon:spec` (MANDATORY first)

**Want to execute task?**
- General task → `/shannon:do` (intelligent)
- Structured validation → `/shannon:exec`
- Full automation → `/shannon:task`

**Complexity >= 0.50?** → `/shannon:wave` (MANDATORY)

**Deep debugging needed?** → `/shannon:ultrathink` (V5 NEW)

**Want to validate work?** → `/shannon:reflect`

**Setting goals?** → `/shannon:north_star`

**Analyzing codebase?** → `/shannon:analyze`

---

See `/docs/COMMAND_ORCHESTRATION.md` for complete workflows, examples, and integration patterns.

---

## Integration with Other Skills

Shannon V4 works alongside your existing skills:

**Pattern**: brainstorming → Shannon spec analysis → Wave execution → finishing-a-development-branch

```
1. Use brainstorming skill for design refinement
2. Once design complete, use /shannon:spec for quantitative analysis
3. Shannon provides 8D scores + wave plan
4. Execute via Shannon's wave-orchestration skill
5. Functional testing enforced throughout
6. Use finishing-a-development-branch for completion
```

**Shannon specializes in**: Quantitative analysis, parallel execution, functional testing enforcement, context preservation

**Other skills specialize in**: Design (brainstorming), execution (executing-plans), git workflows (finishing-a-development-branch), debugging (systematic-debugging, root-cause-tracing)

**Use together**: Shannon handles complexity/execution strategy, other skills handle specific workflows.

---

## Examples

### Example 1: Simple Project (Correct Usage)
**Input**: "Build a todo app with React"

**Execution**:
```
1. Run /shannon:spec "Build a todo app with React"
2. Receive: Complexity 0.28 (Simple)
3. Decision: Sequential execution (no waves needed)
4. Implement with functional tests
5. Checkpoint auto-saves via PreCompact hook
```

**Output**: Todo app delivered in 3-4 hours with functional test coverage

### Example 2: Complex Project (Wave Execution)
**Input**: "Build real-time collaborative document editor with React, Node.js, Yjs CRDT, PostgreSQL, Redis"

**Execution**:
```
1. Run /shannon:spec "Build real-time..."
2. Receive: Complexity 0.72 (High)
3. Decision: Wave-based execution (3-7 agents recommended)
4. Run /shannon:wave to generate wave plan
5. Execute waves with SITREP coordination
6. Functional tests per wave (Puppeteer for frontend)
7. Checkpoints between waves (automatic)
```

**Output**: Complex platform delivered in 2-3 days with proven 3.5x speedup vs sequential

### Example 3: Violation Recovery (What Happens When You Skip)
**Input**: Developer starts coding without /shannon:spec

**Execution**:
```
1. Developer: "Let me build this task manager..."
2. Shannon (if active): "⚠️  Did you run /shannon:spec first?"
3. Developer: "It's simple, I can estimate"
4. 20 minutes later: Realizes needs authentication, database, deployment
5. Restarts with /shannon:spec
6. Complexity: 0.55 (Complex) - should have used waves
7. 20 minutes wasted
```

**Output**: Time wasted, could have been prevented with mandatory /shannon:spec workflow

---

## Success Criteria

**Successful Shannon usage**:
- ✅ Specification analyzed quantitatively BEFORE implementation
- ✅ Complexity score determines execution strategy
- ✅ Functional tests used exclusively (real browsers, real DBs)
- ✅ Context preserved automatically (zero manual checkpoint management)
- ✅ Multi-agent coordination via SITREP (for High/Critical projects)
- ✅ MCP servers configured based on domain analysis
- ✅ Waves complete with validation gates passing
- ✅ Project delivered on time with quantitative planning accuracy

**Fails if**:
- ❌ Implementation started without 8D analysis
- ❌ Unit tests or mocks used
- ❌ Wave execution skipped for complexity >=0.50
- ❌ Manual context management attempted
- ❌ Subjective complexity estimation used
- ❌ Tests written after code (violates TDD)

**Validation Code**:
```python
def validate_shannon_active(session_context):
    """Verify Shannon Framework workflows are being followed"""

    # Check: 8D analysis ran before implementation
    assert session_context.get("spec_analysis_completed") == True, \
        "VIOLATION: Implementation started without 8D analysis"

    # Check: Complexity-based execution strategy
    complexity = session_context.get("complexity_score", 0)
    if complexity >= 0.50:
        assert session_context.get("wave_execution") == True, \
            f"VIOLATION: Complexity {complexity} >= 0.50 requires wave execution"

    # Check: NO MOCKS enforcement
    test_violations = session_context.get("mock_usage_detected", [])
    assert len(test_violations) == 0, \
        f"VIOLATION: Mock usage detected in {len(test_violations)} tests"

    # Check: Automatic checkpointing active
    assert session_context.get("precompact_hook_active") == True, \
        "VIOLATION: PreCompact hook not active (manual checkpoints required)"

    # Check: Serena MCP connected
    assert session_context.get("serena_mcp_status") == "connected", \
        "VIOLATION: Serena MCP not connected (Shannon requirement)"

    return True
```

---

## Common Pitfalls

### Pitfall 1: "This is too simple for 8D analysis"
**Problem**: Developer estimates project is "simple" based on initial description, skips /shannon:spec

**Why It Fails**: Simple-looking specs often hide complexity:
- "Build a task manager" → Needs auth, persistence, deployment, error handling
- Subjective "simple" averages 0.45-0.65 (Moderate to Complex) when scored quantitatively

**Solution**: ALWAYS run /shannon:spec. 3-5 minutes investment prevents hours of rework. Let quantitative scoring decide, not intuition.

**Prevention**: Make /shannon:spec mandatory first step (enforced by this skill)

### Pitfall 2: "Unit tests with mocks are faster"
**Problem**: Developer writes unit tests with mocked dependencies instead of functional tests

**Why It Fails**:
- Mocks test mock behavior, not production behavior
- Tests pass, production fails (mocks don't match reality)
- False confidence in code quality

**Solution**: Use Puppeteer MCP for real browser tests, real database instances, real API endpoints (staging). Shannon's post_tool_use.py hook detects and prevents mock usage.

**Prevention**: Shannon's functional-testing skill enforces NO MOCKS Iron Law

### Pitfall 3: "Wave execution seems like overkill"
**Problem**: Developer sees complexity 0.55 (Complex), thinks "I can do this sequentially"

**Why It Fails**:
- Shannon's wave orchestration provides proven 3.5x speedup
- Complexity >=0.50 triggers wave threshold for a reason (parallelization benefits outweigh coordination overhead at this point)
- Sequential execution for Complex projects = 3.5x slower

**Solution**: Trust the quantitative threshold. If complexity >=0.50, use /shannon:wave for wave-based execution.

**Prevention**: using-shannon skill establishes >=0.50 as mandatory wave threshold

### Pitfall 4: "Manual testing verified it works, tests later"
**Problem**: Developer manually tests feature, thinks automated tests can come later

**Why It Fails**:
- Manual tests aren't repeatable
- No regression detection
- "Works on my machine" != production-ready
- Tests written after code are biased by implementation

**Solution**: Functional test automation from day 1. Use Puppeteer MCP for UI, real databases for data, real APIs for integration.

**Prevention**: Shannon's functional-testing skill enforces test-first approach

### Pitfall 5: "I'll checkpoint manually when needed"
**Problem**: Developer thinks they'll remember to checkpoint before important moments

**Why It Fails**:
- Developers forget under pressure
- Context compaction happens automatically - you can't predict timing
- Manual checkpoints after compaction = data already lost

**Solution**: Trust PreCompact hook. It triggers automatically when context nears limit, invokes context-preservation skill, saves to Serena MCP. You never need to think about it.

**Prevention**: PreCompact hook makes this automatic (no manual action required)

### Pitfall 6: "SITREP is too formal for this project"
**Problem**: Multi-agent project with complexity >=0.70, but developer skips SITREP protocol

**Why It Fails**:
- Agent coordination failures (duplicate work, conflicts)
- No visibility into parallel progress
- Difficult to debug multi-agent issues
- Synthesis checkpoints unclear

**Solution**: Use /shannon:wave with --sitrep flag for complexity >=0.70. SITREP provides structure for multi-agent coordination that prevents common coordination failures.

**Prevention**: wave-orchestration skill auto-enables SITREP for High/Critical complexity

### Pitfall 7: "Estimate complexity by feel, analysis is overkill"
**Problem**: Developer estimates based on intuition instead of running /shannon:spec

**Why It Fails**:
- Human intuition systematically biased toward under-estimation
- Complexity dimensions interact non-linearly (8D captures this, intuition doesn't)
- Resource allocation based on wrong estimate → project failure

**Solution**: Shannon's 8D algorithm removes bias. Always run /shannon:spec for quantitative assessment. 3-5 minute investment prevents days of rework.

**Prevention**: using-shannon skill makes /shannon:spec mandatory first step

### Pitfall 8: "Tests after implementation achieve same result"
**Problem**: Developer writes working code, then writes tests to verify it

**Why It Fails**:
- Tests written after code pass immediately → prove nothing
- Tests verify implementation, not requirements (biased by what you built)
- Miss edge cases you didn't think of during implementation
- "Works when I test it" != comprehensive coverage

**Solution**: Shannon enforces test-driven development via functional-testing skill. Write test first (watch it fail), write minimal code (watch it pass), refactor while staying green.

**Prevention**: functional-testing skill enforces TDD Iron Law

---

## Validation

**How to verify Shannon is active and working**:

1. **Check framework loaded**:
   ```
   /shannon:status
   # Expected: "Shannon Framework v4.0.0 active"
   # Expected: "🟢 Serena MCP connected" (required)
   ```

2. **Check workflows enforced**:
   ```
   # Try to start implementation without /shannon:spec
   # Shannon should remind: "Did you run /shannon:spec first?"
   ```

3. **Check functional testing enforced**:
   ```
   # Try to write unit test with mocks
   # post_tool_use.py hook should detect and prevent
   ```

4. **Check context preservation**:
   ```
   # Work until context fills
   # PreCompact hook should trigger automatically
   # Checkpoint created in Serena MCP
   ```

---

## Progressive Disclosure

**SKILL.md** (This file): ~400 lines
- Iron Laws and mandatory workflows
- Common rationalizations table
- When to use each Shannon command
- Integration with other skills

**anti-rationalizations.md**: Detailed psychology of why rationalizations fail
- Sunk cost fallacy research
- Cognitive biases in estimation
- Why "pragmatic" shortcuts backfire

**Claude loads anti-rationalizations.md when**: Agent shows signs of rationalization (uses phrases from red flags list)

---

## References

- Complete 8D algorithm: core/SPEC_ANALYSIS.md
- Wave orchestration: core/WAVE_ORCHESTRATION.md
- NO MOCKS philosophy: core/TESTING_PHILOSOPHY.md
- Context preservation: core/CONTEXT_MANAGEMENT.md
- SITREP protocol: skills/sitrep-reporting/SKILL.md
- Hook system: core/HOOK_SYSTEM.md

---

## V5.4 Enhancements: Superpowers Integration

Shannon v5.4 adds systematic workflows from the Superpowers framework with Shannon quantitative enhancements:

### New Commands (v5.4)

#### /shannon:write-plan - Systematic Planning
**Purpose**: Create comprehensive implementation plans with quantitative analysis

**When to use**:
- Complex features requiring careful planning
- Team collaboration (plan as communication)
- When you want review checkpoints during execution

**Output**:
- Plan file with 8D complexity scoring
- Bite-sized tasks (2-5 min each)
- Complete code examples
- Validation gates per task
- MCP requirements specified

**Leads to**: `/shannon:execute-plan` for systematic execution

#### /shannon:execute-plan - Batch Execution
**Purpose**: Execute plans in batches with review checkpoints

**When to use**:
- Have a plan from `/shannon:write-plan`
- Want systematic execution with control
- Need review checkpoints between batches

**Features**:
- Complexity-based batch sizing (Shannon formula)
- 3-tier validation per batch
- Quantitative progress tracking
- Pattern learning via Serena

**Alternative**: `/shannon:do --with-plan` for automatic execution

### New Skills (v5.4)

**Core Quality Skills**:
- **forced-reading-protocol** - Complete line-by-line reading (auto-activated for large content)
- **verification-before-completion** - Evidence-before-claims enforcement
- **test-driven-development** - RED-GREEN-REFACTOR + NO MOCKS
- **systematic-debugging** - 4-phase debugging with quantitative tracking
- **root-cause-tracing** - Backward tracing with pattern learning
- **defense-in-depth** - 5-layer validation strategy

**Planning & Execution Skills**:
- **brainstorming** - Design refinement with Shannon quantitative validation
- **writing-plans** - Create quantitative implementation plans
- **executing-plans** - Batch execution with validation gates

**Meta Skills**:
- **writing-skills** - TDD for skill documentation (create skills using RED-GREEN-REFACTOR)

### Integration with Existing Workflows

**You now have THREE execution workflows**:

**1. Automatic (intelligent-do)**:
```bash
/shannon:do "build authentication"
# Fast, automatic, intelligent
```

**2. Systematic (write-plan + execute-plan)**:
```bash
/shannon:write-plan --feature "authentication"
/shannon:execute-plan docs/plans/2025-11-18-auth.md
# Careful, planned, checkpointed
```

**3. Full Automation (task)**:
```bash
/shannon:task "Build REST API with auth"
# Complete: prime → spec → wave
```

**Choose based on**:
- Complexity <0.4 → Use /shannon:do (automatic)
- Complexity 0.4-0.7 → Consider /shannon:write-plan + /shannon:execute-plan
- Complexity >0.7 → Use /shannon:task or /shannon:write-plan for careful planning

### Auto-Activation (v5.4)

**Forced Reading Protocol** auto-activates via hook when:
- Prompt >3000 characters (large prompts)
- File references >5000 lines (large files)
- Specification keywords detected

**You'll see**:
```
📖 **SHANNON FORCED READING PROTOCOL - AUTO-ACTIVATED**
✋ **LARGE PROMPT DETECTED**
   - Prompt length: >3000 characters
```

**Required response**: Follow 4-step protocol (count, read all, verify, synthesize with Sequential MCP)

---

## Metadata

**Version**: 5.4.0 (Superpowers Integration)
**Last Updated**: 2025-11-18
**Author**: Shannon Framework Team
**License**: MIT
**Status**: Meta-Skill (auto-loaded via SessionStart hook)
