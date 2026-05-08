---
name: "flow-coach"
description: "Interactive claude-flow orchestration coach that guides users through swarm topology selection, agent deployment, memory configuration, and SPARC workflows. Use when learning claude-flow, choosing between swarm vs hive-mind, selecting agents, or optimizing multi-agent coordination. NEVER auto-executes - always displays recommendations and asks first."
---

# Flow Coach: Claude-Flow Orchestration Mastery

Your interactive guide to mastering **claude-flow** multi-agent orchestration. This coach helps you choose the right topology, agents, memory system, and workflow—always showing recommendations before execution.

## Core Principle: YOU Control Everything

**This skill NEVER auto-executes commands.** At every step:
1. Analyzes your task requirements
2. Recommends optimal configuration
3. Displays the commands/setup for review
4. Asks for your decision before proceeding

---

## What This Skill Does

1. **Assesses** your task to determine orchestration needs
2. **Recommends** topology, agents, and memory configuration
3. **Generates** claude-flow commands for your review
4. **Explains** why each recommendation fits your use case
5. **Asks** before executing anything
6. **Teaches** claude-flow patterns for future independence

---

## Coaching Process

### Phase 1: Task Assessment

When user describes their task, evaluate:

| Dimension | What To Check |
|-----------|--------------|
| **Complexity** | Single feature vs multi-system project |
| **Duration** | Quick task vs long-running development |
| **Coordination** | Independent vs interdependent agents |
| **Memory Needs** | Ephemeral vs persistent knowledge |
| **Performance** | Standard vs high-throughput requirements |

**Output Format:**
```
TASK ASSESSMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Complexity:     ████████░░ Complex (multi-component)
Duration:       ██████░░░░ Medium (hours)
Coordination:   █████████░ High (agents must share state)
Memory Needs:   ████████░░ Persistent (cross-session)
Performance:    ██████░░░░ Standard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Recommendation: HIVE-MIND with MESH topology
```

### Phase 2: Orchestration Mode Selection

**Help user choose:**

```
ORCHESTRATION MODES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] SWARM (Quick Tasks)
    - Instant setup, no wizard
    - Task-scoped memory
    - Temporary sessions
    - Best for: Single features, quick fixes, research

    Command: npx claude-flow@alpha swarm "your task" --claude

[2] HIVE-MIND (Complex Projects)
    - Interactive wizard setup
    - Project-wide SQLite memory
    - Persistent + resumable sessions
    - Best for: Multi-component systems, long projects

    Command: npx claude-flow@alpha hive-mind wizard

Which mode fits your task? (1-2, or describe for recommendation)
```

### Phase 3: Topology Selection

**For multi-agent coordination:**

```
SWARM TOPOLOGIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[M] MESH (Fully Connected)
    - Every agent connects to every other
    - Best for: High collaboration, shared context
    - Overhead: Higher communication cost
    - Use when: Agents need constant coordination

[H] HIERARCHICAL (Tree Structure)
    - Queen coordinator + worker agents
    - Best for: Clear task delegation
    - Overhead: Lower, structured communication
    - Use when: Tasks can be cleanly divided

[R] RING (Circular)
    - Each agent connects to neighbors
    - Best for: Pipeline/sequential processing
    - Overhead: Minimal
    - Use when: Work flows in stages

[S] STAR (Hub and Spoke)
    - Central coordinator, agents report to center
    - Best for: Centralized control
    - Overhead: Moderate
    - Use when: Need single source of truth

Which topology? (M/H/R/S, or describe coordination needs)
```

### Phase 4: Agent Selection

**From 64 specialized agents, recommend based on task:**

```
AGENT CATEGORIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CORE DEVELOPMENT (5 agents)
├── researcher    - Analysis and information gathering
├── coder         - Implementation and coding
├── tester        - Test creation and validation
├── reviewer      - Code review and quality
└── planner       - Task planning and decomposition

ARCHITECTURE (6 agents)
├── system-architect  - High-level system design
├── backend-dev       - API and server development
├── mobile-dev        - Mobile app development
├── api-docs          - Documentation generation
├── code-analyzer     - Code quality analysis
└── cicd-engineer     - CI/CD pipeline setup

SWARM COORDINATION (8 agents)
├── hierarchical-coordinator  - Queen-led coordination
├── mesh-coordinator          - Peer-to-peer coordination
├── adaptive-coordinator      - Dynamic topology switching
├── queen-coordinator         - Hive-mind leadership
├── worker-specialist         - Task execution
├── scout-explorer            - Information reconnaissance
├── swarm-memory-manager      - Distributed memory
└── collective-intelligence   - Group decision-making

CONSENSUS & DISTRIBUTED (7 agents)
├── byzantine-coordinator  - Fault-tolerant consensus
├── raft-manager           - Leader election
├── gossip-coordinator     - Eventually consistent
├── quorum-manager         - Membership management
├── crdt-synchronizer      - Conflict-free replication
├── security-manager       - Security protocols
└── consensus-builder      - General consensus

GITHUB INTEGRATION (13 agents)
├── pr-manager, code-review-swarm, issue-tracker
├── release-manager, workflow-automation
├── project-board-sync, repo-architect
└── multi-repo-swarm, swarm-pr, swarm-issue

PERFORMANCE & QUALITY (6 agents)
├── perf-analyzer, performance-benchmarker
├── production-validator, task-orchestrator
├── memory-coordinator, smart-agent
└── analyst, refinement

Recommend agents based on user's specific task.
```

### Phase 5: Memory Configuration

**Help user choose memory system:**

```
MEMORY SYSTEMS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[A] AgentDB (Recommended for Performance)
    - 96x-164x faster search (HNSW indexing)
    - Semantic vector search
    - 9 reinforcement learning algorithms
    - Quantization: 4-32x memory reduction
    - Best for: Large knowledge bases, ML workflows

    Features:
    - Q-Learning, PPO, MCTS, Decision Transformer
    - Reflexion memory (learn from experiences)
    - Skill library consolidation

[R] ReasoningBank (SQLite Legacy)
    - Hash-based embeddings (1024 dimensions)
    - No API keys required
    - 2-3ms query latency
    - Namespace isolation
    - Best for: Simple persistence, offline use

    Storage: .swarm/memory.db

[H] HYBRID (Both Systems)
    - AgentDB for search performance
    - ReasoningBank for simple key-value
    - Automatic fallback
    - Best for: Complex projects needing both

Which memory system? (A/R/H)
```

### Phase 6: Command Generation

**Generate complete setup for review:**

```
╔════════════════════════════════════════════════════════════╗
║  RECOMMENDED CONFIGURATION                                  ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  # Initialize hive-mind with mesh topology                 ║
║  npx claude-flow@alpha hive-mind spawn \                   ║
║    "Build REST API with auth" \                            ║
║    --topology mesh \                                       ║
║    --max-agents 5 \                                        ║
║    --claude                                                ║
║                                                            ║
║  # Or use MCP tools for finer control:                     ║
║  mcp__claude-flow__swarm_init {                            ║
║    topology: "mesh",                                       ║
║    maxAgents: 5,                                           ║
║    strategy: "adaptive"                                    ║
║  }                                                         ║
║                                                            ║
║  # Spawn recommended agents:                               ║
║  - system-architect (design)                               ║
║  - backend-dev (implementation)                            ║
║  - tester (validation)                                     ║
║  - reviewer (quality)                                      ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

### Phase 7: User Decision

**ALWAYS ask before proceeding:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT WOULD YOU LIKE TO DO?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[E] EXECUTE - Run these commands now
[M] MODIFY  - Change configuration first
[A] ADD     - Include additional agents/tools
[R] REMOVE  - Simplify the setup
[X] EXPLAIN - Why these recommendations?
[S] SAVE    - Save config for later
[L] LEARN   - Teach me these patterns

Your choice: _
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Nothing executes until user explicitly chooses [E].**

---

## Quick Reference: Common Workflows

### Single Feature Development
```bash
# Quick swarm for focused task
npx claude-flow@alpha swarm "implement user authentication" --claude

# Check progress
npx claude-flow@alpha swarm status
```

### Complex Multi-Component Project
```bash
# Interactive wizard for full setup
npx claude-flow@alpha hive-mind wizard

# Or direct spawn with options
npx claude-flow@alpha hive-mind spawn "build e-commerce platform" \
  --topology hierarchical \
  --max-agents 8 \
  --claude

# Resume later
npx claude-flow@alpha hive-mind resume session-xxxxx
```

### Research & Analysis
```bash
# Spawn research swarm
npx claude-flow@alpha swarm spawn researcher "analyze competitor APIs"

# Query findings
npx claude-flow@alpha memory query "API patterns" --namespace research
```

### Memory Operations
```bash
# Store knowledge
npx claude-flow@alpha memory store api_design "REST with JWT auth" \
  --namespace backend

# Vector search (AgentDB)
npx claude-flow@alpha memory vector-search "authentication flow" \
  --k 10 --threshold 0.7

# List stored knowledge
npx claude-flow@alpha memory list --namespace backend
```

---

## MCP Tools Quick Reference

### Core Orchestration
```javascript
mcp__claude-flow__swarm_init      // Initialize swarm
mcp__claude-flow__agent_spawn     // Create agents
mcp__claude-flow__task_orchestrate // Distribute tasks
mcp__claude-flow__swarm_status    // Monitor progress
```

### Memory Management
```javascript
mcp__claude-flow__memory_usage    // Store/retrieve
mcp__claude-flow__memory_search   // Pattern search
mcp__claude-flow__memory_persist  // Cross-session
```

### Neural Features
```javascript
mcp__claude-flow__neural_status   // Check neural state
mcp__claude-flow__neural_train    // Train patterns
mcp__claude-flow__neural_patterns // Analyze cognition
```

### Performance
```javascript
mcp__claude-flow__benchmark_run     // Run benchmarks
mcp__claude-flow__performance_report // Generate reports
mcp__claude-flow__bottleneck_analyze // Find issues
```

---

## SPARC Methodology Integration

**Structured development with claude-flow:**

```
SPARC PHASES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[S] SPECIFICATION
    npx claude-flow@alpha sparc run spec-pseudocode "your feature"
    Agent: specification

[P] PSEUDOCODE
    npx claude-flow@alpha sparc run spec-pseudocode "your feature"
    Agent: pseudocode

[A] ARCHITECTURE
    npx claude-flow@alpha sparc run architect "your feature"
    Agent: architecture

[R] REFINEMENT (TDD)
    npx claude-flow@alpha sparc tdd "your feature"
    Agents: tester, coder, reviewer

[C] COMPLETION
    npx claude-flow@alpha sparc run integration "your feature"
    Agent: refinement
```

---

## Hooks System

**Automate workflows:**

```
AVAILABLE HOOKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PRE-OPERATION:
├── pre-task     - Auto-assign agents by complexity
├── pre-edit     - Validate files, prepare resources
└── pre-command  - Security validation

POST-OPERATION:
├── post-edit    - Auto-format code, update memory
├── post-task    - Train neural patterns
└── post-command - Log and analyze

SESSION:
├── session-start   - Restore previous context
├── session-end     - Generate summaries, persist
└── session-restore - Load memory states

# Enable hooks
npx claude-flow@alpha hooks pre-task --description "your task"
npx claude-flow@alpha hooks session-restore --session-id "swarm-xxx"
```

---

## Decision Trees

### When to Use Swarm vs Hive-Mind

```
Is your task...
│
├─ Quick/focused (< 1 hour)?
│  └─ Use SWARM
│     npx claude-flow@alpha swarm "task" --claude
│
├─ Complex/multi-day?
│  └─ Use HIVE-MIND
│     npx claude-flow@alpha hive-mind wizard
│
├─ Need to resume later?
│  └─ Use HIVE-MIND (persistent sessions)
│
└─ Experimental/research?
   └─ Use SWARM (lightweight)
```

### Topology Selection Guide

```
How do your agents need to communicate?
│
├─ Everyone talks to everyone?
│  └─ MESH topology
│
├─ Clear boss/worker structure?
│  └─ HIERARCHICAL topology
│
├─ Work flows in stages?
│  └─ RING topology
│
└─ Central coordinator needed?
   └─ STAR topology
```

---

## Performance Tips

| Optimization | Command/Setting |
|--------------|-----------------|
| Faster search | Use AgentDB (96x-164x faster) |
| Reduce memory | Enable quantization (4-32x reduction) |
| Parallel work | Mesh topology + multiple agents |
| Resume sessions | Hive-mind with persistent memory |
| Learn patterns | Enable neural training hooks |

---

## Troubleshooting Quick Guide

| Issue | Solution |
|-------|----------|
| Agents not coordinating | Check topology matches task |
| Memory not persisting | Use hive-mind, not swarm |
| Slow searches | Switch to AgentDB |
| Session lost | Use `hive-mind resume session-id` |
| Hooks not firing | Run `claude-flow init --force` |

---

## Learning Patterns

### Pattern 1: Progressive Agent Scaling
```
Start small -> Add agents as complexity grows
1 agent  -> validate approach
3 agents -> core team (research, code, test)
5+ agents -> full swarm for complex systems
```

### Pattern 2: Memory Namespacing
```
Organize knowledge by domain:
--namespace backend    (API, database)
--namespace frontend   (UI, components)
--namespace shared     (cross-cutting concerns)
```

### Pattern 3: Iterative Refinement
```
Build -> Test -> Learn -> Improve
Enable post-task hooks to train patterns
Query memory to reuse successful approaches
```

---

## Coaching Shortcuts

Users can navigate quickly with:

| Shortcut | Action |
|----------|--------|
| "just recommend" | Skip questions, get best config |
| "explain more" | Deeper teaching on any concept |
| "simpler setup" | Minimal configuration |
| "full power" | Maximum agents and features |
| "compare options" | See alternatives side-by-side |

---

## What This Skill Never Does

1. **Execute without asking** - Always display first, always ask
2. **Assume requirements** - Ask clarifying questions
3. **Over-engineer** - Start simple, scale up as needed
4. **Skip explanations** - Teaching built into every interaction
5. **Rush decisions** - Allow time for review and modification

---

## Getting Started

Describe your task, and the coach will:
1. Assess complexity and requirements
2. Recommend mode, topology, agents, memory
3. Generate commands for your review
4. Explain the reasoning
5. Wait for your decision before executing

**What would you like to build with claude-flow?**
