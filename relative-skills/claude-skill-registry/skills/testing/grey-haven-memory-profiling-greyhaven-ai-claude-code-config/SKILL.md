---
name: grey-haven-memory-profiling
description: "Identify memory leaks, inefficient allocations, and optimization opportunities in JavaScript/TypeScript and Python applications. Analyze heap snapshots, allocation patterns, garbage collection, and memory retention. Use when memory grows over time, high memory consumption detected, performance degradation, or when user mentions 'memory leak', 'memory usage', 'heap analysis', 'garbage collection', 'memory profiling', or 'out of memory'."
# v2.0.43: Skills to auto-load for memory profiling
skills:
  - grey-haven-code-style
  - grey-haven-performance-optimization
  - grey-haven-observability-monitoring
# v2.0.74: Tools for memory profiling
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Memory Profiling Skill

Identify memory leaks, inefficiencies, and optimization opportunities in running applications through systematic heap analysis and allocation profiling.

## Description

Specialized memory profiling skill for analyzing allocation patterns, heap usage, garbage collection behavior, and memory retention in JavaScript/TypeScript (Node.js, Bun, browsers) and Python applications. Detect memory leaks, optimize memory usage, and prevent out-of-memory errors.

## What's Included

### Examples (`examples/`)
- **Memory leak detection** - Finding and fixing common leak patterns
- **Heap snapshot analysis** - Interpreting Chrome DevTools heap snapshots
- **Allocation profiling** - Tracking memory allocation over time
- **Real-world scenarios** - E-commerce app leak, API server memory growth

### Reference Guides (`reference/`)
- **Profiling tools** - Chrome DevTools, Node.js inspector, Python memory_profiler
- **Memory concepts** - Heap, stack, GC algorithms, retention paths
- **Optimization techniques** - Object pooling, weak references, lazy loading
- **Common leak patterns** - Event listeners, closures, caching, timers

### Templates (`templates/`)
- **Profiling report template** - Standardized memory analysis reports
- **Heap snapshot comparison template** - Before/after analysis
- **Memory budget template** - Setting and tracking memory limits

### Checklists (`checklists/`)
- **Memory leak checklist** - Systematic leak detection process
- **Optimization checklist** - Memory optimization verification

## Use This Skill When

- ✅ Memory usage growing continuously over time
- ✅ High memory consumption detected (> 500MB for Node, > 1GB for Python)
- ✅ Performance degradation with prolonged runtime
- ✅ Out of memory errors in production
- ✅ Garbage collection causing performance issues
- ✅ Need to optimize memory footprint
- ✅ User mentions: "memory leak", "memory usage", "heap", "garbage collection", "OOM"

## Related Agents

- `memory-profiler` - Automated memory analysis and leak detection
- `performance-optimizer` - Broader performance optimization including memory

## Quick Start

```bash
# View leak detection examples
cat examples/memory-leak-detection.md

# Check profiling tools reference
cat reference/profiling-tools.md

# Use memory leak checklist
cat checklists/memory-leak-checklist.md
```

## Common Memory Issues

1. **Event Listener Leaks** - Unremoved listeners holding references
2. **Closure Leaks** - Variables captured in closures never released
3. **Cache Leaks** - Unbounded caches growing indefinitely
4. **Timer Leaks** - setInterval/setTimeout not cleared
5. **DOM Leaks** - Detached DOM nodes retained in memory
6. **Circular References** - Objects referencing each other preventing GC

## Typical Workflow

1. **Detect**: Run profiler, take heap snapshots
2. **Analyze**: Compare snapshots, identify growing objects
3. **Locate**: Find retention paths, trace to source
4. **Fix**: Remove references, clean up resources
5. **Verify**: Re-profile to confirm fix

---

**Skill Version**: 1.0
**Last Updated**: 2025-11-09
