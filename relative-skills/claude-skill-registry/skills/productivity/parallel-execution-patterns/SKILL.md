---
name: parallel-execution-patterns
description: Use when performing multiple independent operations like reading multiple files, searching patterns, or querying memory - executes operations in parallel for 5-8x performance improvement by sending all tool calls in a single message
---

# Parallel Execution Patterns

## Overview

Execute independent operations in parallel for dramatic performance improvements. Instead of sequential tool calls (5 operations × 8 seconds = 40 seconds), use parallel calls (5 operations in 1 message = 8 seconds).

**Core principle:** If operations don't depend on each other, execute them in parallel (single message, multiple tool calls).

**How to invoke:**
```
Skill({ skill: "parallel-execution-patterns" })
```

**When to invoke:** Before reading 2+ files, running 2+ searches, or dispatching 2+ agents.

## When to Use

Use parallel execution when:
- Reading multiple files that don't depend on each other
- Searching for multiple patterns independently
- Querying memory for different contexts
- Making independent git commands (status, log, diff)
- Analyzing multiple files simultaneously
- Dispatching multiple agents for independent tasks

**Don't use when:**
- Operations have dependencies (output of one feeds into another)
- Need to process results before next operation
- Order matters for correctness
- Operations share mutable state

## Performance Impact

**Sequential execution:**
```
Read file A (8 sec)
→ Read file B (8 sec)
→ Read file C (8 sec)
Total: 24 seconds
```

**Parallel execution:**
```
Read file A ]
Read file B ] (all in single message)
Read file C ]
Total: 8 seconds (3x faster)
```

**Real-world improvement:** 5-8x faster for typical workflows

## Pattern 1: Parallel File Reading

### Sequential (Slow)

```
Read("README.md")
[wait 8 seconds]
Read("ARCHITECTURE.md")
[wait 8 seconds]
Read("package.json")
[wait 8 seconds]
Total: 24 seconds
```

### Parallel (Fast)

**Single message with multiple Read calls:**
```javascript
// All reads execute in parallel
Read({ file_path: "/path/to/README.md" })
Read({ file_path: "/path/to/ARCHITECTURE.md" })
Read({ file_path: "/path/to/package.json" })
Read({ file_path: "/path/to/CONTRIBUTING.md" })

// Total: 8 seconds (same as one read)
```

**When to use:**
- Gathering context from multiple documentation files
- Reading test files and implementation files together
- Loading configuration files
- Analyzing codebase structure

## Pattern 2: Parallel Search Operations

### Sequential (Slow)

```
Grep(pattern: "authentication")
[wait 8 seconds]
Grep(pattern: "OAuth")
[wait 8 seconds]
Glob(pattern: "**/*.test.ts")
[wait 8 seconds]
Total: 24 seconds
```

### Parallel (Fast)

**Single message with multiple search calls:**
```javascript
// All searches execute in parallel
Grep({ pattern: "authentication", output_mode: "files_with_matches" })
Grep({ pattern: "OAuth", output_mode: "files_with_matches" })
Grep({ pattern: "JWT", output_mode: "files_with_matches" })
Glob({ pattern: "**/*.test.ts" })
Glob({ pattern: "**/*.spec.ts" })

// Total: 8 seconds
```

**When to use:**
- Finding multiple patterns in codebase
- Locating different file types
- Searching for related concepts
- Pattern discovery phase

## Pattern 3: Parallel Memory Queries

### Sequential (Slow)

```
mcp__memory__search_nodes("authentication")
[wait 2 seconds]
mcp__memory__open_nodes(["ProjectArchitecture"])
[wait 2 seconds]
mcp__memory__search_nodes("OAuth patterns")
[wait 2 seconds]
mcp__memory__search_nodes("failed approach")
[wait 2 seconds]
Total: 8 seconds
```

### Parallel (Fast)

**Single message with multiple MCP calls:**
```javascript
// All queries execute in parallel
const [similar, architecture, patterns, failures] = await Promise.all([
  mcp__memory__search_nodes({ query: "authentication implementation" }),
  mcp__memory__open_nodes({ names: ["ProjectArchitecture"] }),
  mcp__memory__search_nodes({ query: "OAuth patterns" }),
  mcp__memory__search_nodes({ query: "authentication failed approach" })
]);

// Total: 2 seconds (same as one query)
```

**When to use:**
- Planning phase (query multiple contexts)
- Before implementation (gather patterns, constraints, failures)
- Testing research (patterns, mocking, edge cases)

## Pattern 4: Parallel Agent Dispatch

### Sequential (Slow)

```
Task(fix bug in file A)
[wait for agent to complete: 5 minutes]
Task(fix bug in file B)
[wait for agent to complete: 5 minutes]
Task(fix bug in file C)
[wait for agent to complete: 5 minutes]
Total: 15 minutes
```

### Parallel (Fast)

**Single message with multiple Task calls:**
```javascript
// All agents execute in parallel
Task({
  subagent_type: "general-purpose",
  description: "Fix bug in file A",
  prompt: "Context file: tasks/session_context_bugfix_a.md. [details]"
})

Task({
  subagent_type: "general-purpose",
  description: "Fix bug in file B",
  prompt: "Context file: tasks/session_context_bugfix_b.md. [details]"
})

Task({
  subagent_type: "general-purpose",
  description: "Fix bug in file C",
  prompt: "Context file: tasks/session_context_bugfix_c.md. [details]"
})

// Total: 5 minutes (same as one agent)
```

**When to use:**
- Independent bug fixes in different files
- Parallel feature implementations
- Multiple code reviews
- Exploratory research tasks

## Pattern 5: Parallel Git Commands

### Sequential (Slow)

```
Bash("git status")
[wait 3 seconds]
Bash("git diff")
[wait 3 seconds]
Bash("git log --oneline -10")
[wait 3 seconds]
Total: 9 seconds
```

### Parallel (Fast)

**Single message with multiple Bash calls:**
```javascript
// All git commands execute in parallel
Bash({ command: "git status", description: "Show working tree status" })
Bash({ command: "git diff", description: "Show unstaged changes" })
Bash({ command: "git log --oneline -10", description: "Show recent commits" })

// Total: 3 seconds
```

**When to use:**
- Gathering git context before commit
- Analyzing repository state
- Preparing for PR creation

## Identifying Parallelization Opportunities

### Ask These Questions

1. **Does operation B need result from operation A?**
   - No → Can parallelize
   - Yes → Must be sequential

2. **Do operations modify same resource?**
   - No → Can parallelize
   - Yes → Must be sequential

3. **Does order matter for correctness?**
   - No → Can parallelize
   - Yes → Must be sequential

4. **Are operations reading vs writing?**
   - All reading → Can parallelize
   - Mix of read/write → Check dependencies

### Decision Tree

```
Multiple operations needed?
├─ Yes → Are they independent?
│  ├─ Yes → Do they modify shared state?
│  │  ├─ No → ✅ PARALLELIZE
│  │  └─ Yes → ❌ Sequential
│  └─ No → ❌ Sequential
└─ No → Single operation (no parallelization)
```

## Common Parallelizable Patterns

### Documentation Reading

**Scenario:** Gather context from multiple docs

**Operations:**
- Read README.md
- Read ARCHITECTURE.md
- Read CONTRIBUTING.md
- Read package.json

**Independent?** Yes (reading different files)

**Parallelize:** ✅ Yes

### Codebase Analysis

**Scenario:** Find patterns and implementations

**Operations:**
- Grep for "authentication"
- Grep for "OAuth"
- Glob for test files
- Glob for spec files

**Independent?** Yes (different search patterns)

**Parallelize:** ✅ Yes

### Memory Context Gathering

**Scenario:** Query memory before planning

**Operations:**
- Search for similar implementations
- Open ProjectArchitecture entity
- Search for relevant patterns
- Search for failed approaches

**Independent?** Yes (different queries)

**Parallelize:** ✅ Yes

### Test File Analysis

**Scenario:** Read implementation and tests

**Operations:**
- Read src/auth/auth.ts
- Read src/auth/auth.spec.ts
- Read src/auth/types.ts
- Read src/auth/utils.ts

**Independent?** Yes (reading different files)

**Parallelize:** ✅ Yes

## Common Non-Parallelizable Patterns

### Chained File Operations

**Scenario:** Search then read results

**Operations:**
1. Glob for "**/*.test.ts" → Get list of files
2. Read files from list → Depends on step 1 result

**Independent?** No (step 2 needs step 1's output)

**Parallelize:** ❌ No (must be sequential)

### Dependent Searches

**Scenario:** Search based on previous result

**Operations:**
1. Grep for "class User" → Find definition location
2. Read file containing class → Depends on step 1 result

**Independent?** No (step 2 needs step 1's output)

**Parallelize:** ❌ No (must be sequential)

### State-Modifying Operations

**Scenario:** Edit same file multiple times

**Operations:**
1. Edit file (change function A)
2. Edit file (change function B)

**Independent?** No (both modify same file)

**Parallelize:** ❌ No (must be sequential)

### Ordered Git Operations

**Scenario:** Commit and push

**Operations:**
1. git add .
2. git commit -m "message"
3. git push

**Independent?** No (must execute in order)

**Parallelize:** ❌ No (use chaining: `git add . && git commit -m "msg" && git push`)

## Implementation Techniques

### Technique 1: Group Independent Reads

**Before (sequential):**
```
Read architecture doc
[Commentary about architecture]
Read testing guide
[Commentary about testing]
Read API docs
[Commentary about API]
```

**After (parallel):**
```
[Read architecture doc, testing guide, API docs in parallel]
[Single commentary synthesizing all three]
```

### Technique 2: Batch Searches

**Before (sequential):**
```
Search for auth patterns
[Analyze results]
Search for OAuth code
[Analyze results]
Search for JWT usage
[Analyze results]
```

**After (parallel):**
```
[Search for auth patterns, OAuth code, JWT usage in parallel]
[Analyze all results together]
```

### Technique 3: Parallel Context Loading

**Before (sequential):**
```
Query memory for architecture
Query memory for patterns
Query memory for failures
[Apply findings]
```

**After (parallel):**
```
[Query all memory contexts in parallel]
[Synthesize and apply findings]
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Unnecessary Sequencing

```
# ❌ Bad: Sequential when could be parallel
Read README.md
[wait]
Read package.json
[wait]
Read tsconfig.json

# ✅ Good: Parallel reads
Read README.md, package.json, tsconfig.json (single message)
```

### Anti-Pattern 2: Batching Dependent Operations

```
# ❌ Bad: Trying to parallelize dependent operations
Glob("**/*.ts")  ]  Parallel attempt, but...
Read(glob_results) ]  This needs glob results!

# ✅ Good: Sequential when necessary
Glob("**/*.ts")
[wait for results]
Read(specific files from results)
```

### Anti-Pattern 3: Over-Parallelization

```
# ❌ Bad: Parallelizing when result synthesis is complex
Read 50 files in parallel
[Now have to synthesize 50 file contents - overwhelming]

# ✅ Good: Reasonable parallelization
Read 5-10 most relevant files in parallel
[Manageable synthesis]
```

## Measuring Impact

**Before parallel execution:**
- Sequential reads: 5 files × 8 sec = 40 seconds
- Sequential searches: 3 patterns × 8 sec = 24 seconds
- Total: 64 seconds

**After parallel execution:**
- Parallel reads: 5 files in 1 call = 8 seconds
- Parallel searches: 3 patterns in 1 call = 8 seconds
- Total: 16 seconds

**Improvement:** 4x faster (64s → 16s)

**Typical workflow improvements:**
- Planning phase: 5-8x faster
- Codebase analysis: 3-5x faster
- Memory queries: 4x faster
- Agent dispatch: N× faster (N = number of agents)

## Integration with Commands

### plan-task Command

**Uses parallel execution for:**
1. Documentation reading (README, ARCHITECTURE, CONTRIBUTING in parallel)
2. Memory queries (similar tasks, architecture, patterns, failures in parallel)
3. Pattern searches (authentication, OAuth, testing in parallel)

**Result:** 5-8x faster codebase analysis

### implement-plan Command

**Uses parallel execution for:**
1. Reading implementation files and tests together
2. Checking git status, diff, log in parallel
3. Memory queries before implementation

**Result:** Faster context loading, quicker implementation start

### update-tests Command

**Uses parallel execution for:**
1. Memory queries (testing patterns, mocking, edge cases in parallel)
2. Reading test and implementation files together

**Result:** Faster test context gathering

## Quick Reference

### Parallelization Checklist

Before executing operations:
- [ ] Identify all operations needed
- [ ] Check if operations are independent
- [ ] Verify no shared state modifications
- [ ] Confirm order doesn't matter
- [ ] Group into single message
- [ ] Execute all in parallel

### Parallel Execution Template

```javascript
// Single message with multiple tool calls:

// Pattern 1: File reads
Read({ file_path: "path/to/file1.ts" })
Read({ file_path: "path/to/file2.ts" })
Read({ file_path: "path/to/file3.ts" })

// Pattern 2: Searches
Grep({ pattern: "pattern1" })
Grep({ pattern: "pattern2" })
Glob({ pattern: "**/*.test.ts" })

// Pattern 3: Memory queries
mcp__memory__search_nodes({ query: "query1" })
mcp__memory__search_nodes({ query: "query2" })
mcp__memory__open_nodes({ names: ["Entity1"] })

// Pattern 4: Agent dispatch
Task({ subagent_type: "type", prompt: "task1" })
Task({ subagent_type: "type", prompt: "task2" })

// All execute in parallel!
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Sequential reads of independent files | Read all in single message |
| One search at a time | Batch all searches in parallel |
| Sequential memory queries | Use Promise.all pattern |
| Dispatching agents in separate messages | Single message, multiple Task calls |
| Parallelizing dependent operations | Check dependencies first |
| Not batching git commands | Parallel for independent, chain for sequential |

## Quality Standards

**Good parallelization:**
- Groups all independent operations
- Single message with multiple tool calls
- No dependencies between operations
- Reasonable batch size (5-15 operations)
- Clear synthesis of results

**Bad parallelization:**
- Operations have dependencies
- Separate messages for each operation
- Too many operations (overwhelming results)
- Modifying shared state in parallel

## Real-World Impact

**With parallel execution:**
- 5-8x faster workflows
- Less waiting time
- More efficient context gathering
- Faster agent coordination
- Better user experience

**Without parallel execution:**
- Sequential bottlenecks
- Unnecessary waiting
- Slower planning and implementation
- Poor agent coordination performance
- Frustrating delays

## Related Skills

- **memory-driven-planning** - Uses parallel memory queries
- **context-file-management** - Efficient context loading
