---
name: task-router
description: |
  Decision matrix for choosing optimal approach to any task. Helps Claude
  decide when to delegate to sub-agents vs. working directly. Use when
  starting a new task or unsure of best approach.
allowed-tools: [Read]
---

# Task Router Skill

This skill provides clear decision rules for choosing the optimal approach to any task.

## Purpose

**Problem**: Claude has many tools (sub-agents, direct work, parallel calls) but no clear guidance on when to use each.
**Solution**: Decision matrix with clear rules and examples.

## When to Use

Activate this skill when:
- Starting a new task and unsure of approach
- Task seems complex (>30 min, >5 files)
- User asks "what's the best way to do X?"
- Need to validate chosen approach

## Decision Matrix

### 🤖 Use `agent-developer` Sub-Agent

**Trigger Conditions**:
- Building/creating mini-agents (Python with OpenAI Agents SDK)
- Implementing executive agent configs (YAML)
- Adding skills to skill registry
- Writing job handlers for BullMQ
- Integrating MCP servers
- System Python Architecture tasks

**Examples**:
- "Create a Slack notification mini-agent"
- "Build job handler for experiment tracking"
- "Add Google Docs skill to registry"

**Why Delegate**:
- Specialized knowledge of agent patterns
- Knows OpenAI Agents SDK deeply
- Understands System Python Architecture
- Has MCP integration best practices
- 75% faster than manual implementation

**How to Invoke**:
```
Task tool with:
- subagent_type: "agent-developer"
- prompt: "Create [specific agent/handler] with [requirements]"
```

---

### 🔍 Use `Explore` Sub-Agent

**Trigger Conditions**:
- Finding files by pattern/keyword
- Understanding how a feature works
- Locating implementation of functionality
- Searching across multiple directories
- Don't know exact file location

**Examples**:
- "Where are errors from client handled?"
- "Find all authentication-related code"
- "How does the SSE streaming work?"

**Why Delegate**:
- Multi-round investigation capability
- Pattern matching across codebase
- Faster than manual Grep/Glob
- Systematic exploration approach

**How to Invoke**:
```
Task tool with:
- subagent_type: "Explore"
- prompt: "Find [what you're looking for]"
- Specify thoroughness: "quick", "medium", "very thorough"
```

---

### 🧪 Use `labs-specialist` Sub-Agent

**Trigger Conditions**:
- Experiment tracking logic
- Validation algorithms (Type A/B)
- Playbook generation
- ML service integration (Vertex AI)
- BigQuery query logic for Labs
- Reach/Creative intelligence features

**Examples**:
- "How does experiment validation work?"
- "Implement playbook confidence scoring"
- "Fix experiment tracking job"

**Why Delegate**:
- Expert in Labs domain logic
- Knows validation algorithms
- Understands ML service architecture
- Familiar with BigQuery integration

**How to Invoke**:
```
Task tool with:
- subagent_type: "labs-specialist"
- prompt: "Explain/fix/implement [Labs-specific task]"
```

---

### 🗄️ Use `database-navigator` Sub-Agent

**Trigger Conditions**:
- Understanding database schema
- Analyzing migrations
- Finding entity relationships
- Query optimization
- JSONB structure analysis
- Foreign key dependencies

**Examples**:
- "Show me the Labs database schema"
- "What tables are related to experiments?"
- "Explain the migration 175800000*"

**Why Delegate**:
- Specialized in schema analysis
- Understands TypeORM patterns
- Can trace relationships
- Migration expertise

**How to Invoke**:
```
Task tool with:
- subagent_type: "database-navigator"
- prompt: "Analyze [database/schema/migration topic]"
```

---

### 🏗️ Use `architecture-explorer` Sub-Agent

**Trigger Conditions**:
- Understanding service boundaries
- Data flow analysis
- Integration points between services
- API communication patterns
- System design questions

**Examples**:
- "How does Frontend talk to Cognitive Engine?"
- "Explain the SSE streaming architecture"
- "What's the agent execution flow?"

**Why Delegate**:
- Holistic system understanding
- Service boundary expertise
- Data flow visualization
- Integration pattern knowledge

**How to Invoke**:
```
Task tool with:
- subagent_type: "architecture-explorer"
- prompt: "Explain [system/integration/flow]"
```

---

### ✋ Work Directly (No Sub-Agent)

**When to Work Directly**:
- Simple file edits (<50 lines changed)
- Quick bug fixes (known location)
- Documentation updates
- Configuration changes
- Reading 1-3 specific files
- Small refactors

**Examples**:
- "Fix typo in labs.controller.ts:123"
- "Update CLAUDE.md with new model"
- "Change port in config"

**Why Direct**:
- Faster for simple tasks
- No delegation overhead
- Clear, known scope

**How to Execute**:
- Use Read, Edit, Write tools directly
- Use TodoWrite for tracking if multi-step
- Parallel tool calls if multiple independent operations

---

## Special Cases

### Parallel Tool Calls

**Use When**:
- Reading multiple independent files
- Running multiple independent commands
- Checking multiple services
- Validating multiple configurations

**Example**:
```
Single message with:
- Read tool (file1.ts)
- Read tool (file2.ts)
- Read tool (file3.ts)
All in one response block
```

**Why**: 3x faster than sequential reads

---

### Plan Sub-Agent

**Use When**:
- Need to plan multi-step implementation
- Breaking down complex feature
- Creating implementation roadmap
- Analyzing technical approach

**Example**: "Plan the implementation of playbook management APIs"

---

### Exploration Journal

**Always Check When**:
- User says "continue", "resume", "pick up where we left off"
- Starting work on familiar topic
- Complex investigation (might have been explored before)

**Location**: `docs/exploration/CURRENT_SESSION.md`

**Why**: Avoid repeating work, maintain continuity

---

## Decision Flowchart

```
START: New Task Received
  ↓
Is it continuation work?
  YES → Read exploration journal first
  NO  → Continue
  ↓
Is it simple (<30 min, <5 files, known location)?
  YES → Work directly
  NO  → Continue
  ↓
Is it development (agent/handler/skill)?
  YES → Use agent-developer
  NO  → Continue
  ↓
Is it exploration (find/understand/locate)?
  YES → Use Explore sub-agent
  NO  → Continue
  ↓
Is it Labs-specific?
  YES → Use labs-specialist
  NO  → Continue
  ↓
Is it database/schema?
  YES → Use database-navigator
  NO  → Continue
  ↓
Is it architecture/integration?
  YES → Use architecture-explorer
  NO  → Continue
  ↓
DEFAULT → Work directly with TodoWrite tracking
```

---

## Quality Checks

After choosing approach, verify:

### ✅ Correct Choice If:
- Approach matches decision matrix
- Estimated time saved > delegation overhead
- Sub-agent has specialized knowledge for this task
- Task is complex enough to benefit from specialization

### ❌ Wrong Choice If:
- Using sub-agent for simple 1-file edit
- Working directly on complex multi-file feature
- Not using parallel calls for independent operations
- Forgetting to check exploration journal on continuation

---

## Examples: Good vs. Bad Decisions

### Example 1: Building Job Handler

**Task**: "Create experiment tracking job handler"

❌ **Bad**: Work directly
- Why bad: 200+ lines, needs BullMQ patterns, integration knowledge
- Result: Slow, might miss patterns, no validation

✅ **Good**: Use agent-developer sub-agent
- Why good: Specialized in job handlers, knows patterns, faster
- Result: Production-quality handler following best practices

---

### Example 2: Finding Implementation

**Task**: "Where is SSE streaming implemented?"

❌ **Bad**: Manual Grep + Read chain
- Why bad: Multiple rounds, trial and error, slow
- Result: Might miss files, incomplete understanding

✅ **Good**: Use Explore sub-agent
- Why good: Systematic search, multi-round investigation
- Result: Complete findings with file paths and line numbers

---

### Example 3: Simple Config Change

**Task**: "Update port in .env.example"

❌ **Bad**: Use agent-developer sub-agent
- Why bad: Massive overhead for 1-line change
- Result: Slower, overkill

✅ **Good**: Work directly
- Why good: Read → Edit → Done in 30 seconds
- Result: Fast, efficient

---

### Example 4: Reading Multiple Files

**Task**: "Check these 5 files for X pattern"

❌ **Bad**: Sequential reads (5 separate messages)
- Why bad: 5x slower than parallel
- Result: Wastes time and tokens

✅ **Good**: Parallel tool calls (single message, 5 Read tools)
- Why good: All reads execute simultaneously
- Result: 5x faster

---

## Integration with Hooks

This skill complements the hooks system:

1. **Pre-Task Analysis Hook** suggests which approach to use
2. **Task Router Skill** provides detailed decision matrix
3. **Quality Check Hook** validates approach was optimal

User can invoke this skill manually: "What's the best way to [task]?"

---

## Success Criteria

✅ Correct sub-agent chosen for specialized tasks
✅ Direct work used for simple operations
✅ Parallel calls used for independent operations
✅ Exploration journal checked on continuation
✅ No obvious inefficiencies in approach

---

**Remember**: The goal is OPTIMAL approach, not just ANY approach. Use sub-agents when they provide value, work directly when they don't!
