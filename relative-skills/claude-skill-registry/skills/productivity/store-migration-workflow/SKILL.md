---
name: "Store Migration Workflow"
description: "Migrate monolithic Zustand stores to domain-specific stores using GOAP planning, hive-mind coordination, and neural pattern learning. Use when refactoring god objects, decomposing state management, or improving architecture grades."
---

# Store Migration Workflow

## What This Skill Does

Orchestrates the migration from monolithic state stores to domain-driven stores using:
- **GOAP Planning**: A* pathfinding for optimal action sequences
- **Hive-Mind Coordination**: Collective intelligence for complex refactoring
- **Neural Pattern Learning**: Train on successful migration patterns
- **AgentDB Memory**: Persist migration state across sessions

## Prerequisites

- Claude Flow v2.0+ (`npx claude-flow@alpha`)
- Zustand-based state management
- Domain store targets identified

## Quick Start

```bash
# 1. Initialize hive-mind
npx claude-flow hive-mind init

# 2. Store GOAP world state
# Current: {monolithExists: true, domainStoresCreated: false}
# Goal: {monolithExists: false, domainStoresCreated: true, testsPass: true}

# 3. Generate action plan
# Actions: create_domain_stores → migrate_imports → deprecate_monolith → run_tests → commit
```

## GOAP Action Definitions

### Available Actions

| Action | Preconditions | Effects | Cost |
|--------|---------------|---------|------|
| `create_domain_stores` | monolith analyzed | domainStoresCreated=true | 5 |
| `migrate_imports` | domainStoresCreated=true | importsUpdated=true | 3 |
| `remove_export` | importsUpdated=true | monolithExported=false | 1 |
| `deprecate_monolith` | monolithExported=false | monolithExists=false | 2 |
| `run_tests` | any | testsPass=true/false | 3 |
| `commit_changes` | testsPass=true | migrationComplete=true | 1 |

### Example GOAP Plan

```json
{
  "currentState": {
    "monolithExists": true,
    "monolithExported": true,
    "domainStoresCreated": true,
    "importsUpdated": true,
    "testsPass": "unknown"
  },
  "goalState": {
    "monolithExists": false,
    "testsPass": true,
    "migrationComplete": true
  },
  "optimalPath": [
    "remove_export",
    "deprecate_monolith",
    "run_tests",
    "commit_changes"
  ],
  "totalCost": 7
}
```

## Hive-Mind Integration

```bash
# Spawn refactoring swarm
npx claude-flow hive-mind spawn "Migrate gameStore to domain stores" \
  --queen-type tactical \
  --max-workers 5 \
  --consensus weighted
```

### Worker Specialization

- **Analyzer Agent**: Identify store responsibilities
- **Coder Agent**: Create domain stores
- **Migrator Agent**: Update imports
- **Tester Agent**: Verify no regressions
- **Reviewer Agent**: Validate architecture

## Neural Pattern Training

```bash
# Train on migration patterns
npx claude-flow neural train \
  --pattern-type optimization \
  --data '{"domain":"store-migration","patterns":["decompose","migrate","verify"]}'
```

### Learned Patterns

1. **decompose-by-domain**: Split by business domain, not technical layer
2. **migrate-incrementally**: One import at a time with tests
3. **deprecate-not-delete**: Add JSDoc deprecation before removal
4. **verify-continuously**: Run tests after each migration step

## Memory Persistence

```typescript
// Store migration state
await memory.store('goap/world-state', currentState, 'goap');
await memory.store('goap/goal-state', goalState, 'goap');
await memory.store('goap/action-log/*', actionResults, 'goap');

// Retrieve for session resume
const worldState = await memory.retrieve('goap/world-state');
```

## Step-by-Step Migration

### Phase 1: Analysis
1. Identify god object (>500 LOC, >50 methods)
2. Map responsibilities to domains
3. Create domain store interfaces

### Phase 2: Creation
1. Create domain stores with single responsibility
2. Add store coordinator for cross-store communication
3. Export from barrel file

### Phase 3: Migration
1. Find all monolith imports (`grep -r "useGameStore"`)
2. Replace with domain store imports
3. Update component selectors

### Phase 4: Cleanup
1. Remove monolith export from index.ts
2. Add deprecation JSDoc to monolith
3. Run full test suite
4. Commit with migration message

### Phase 5: Deletion (Future)
1. Verify zero imports remain
2. Delete monolith file
3. Remove from git history (optional)

## Replanning Triggers

| Trigger | Response |
|---------|----------|
| Test failures | Insert `fix_test_failures` action |
| Circular deps | Add `resolve_circular_deps` action |
| Type errors | Insert `fix_type_errors` action |
| Merge conflicts | Add `resolve_conflicts` action |

## Success Criteria

- [ ] All imports migrated to domain stores
- [ ] Monolith export removed
- [ ] Deprecation JSDoc added
- [ ] All tests pass
- [ ] TypeScript compiles
- [ ] Lint passes
- [ ] Architecture grade improved

## Troubleshooting

### Issue: Circular Dependencies
**Solution**: Use store coordinator pattern with Zustand subscriptions

### Issue: Type Mismatches
**Solution**: Create shared type definitions in `@/types`

### Issue: Test Failures After Migration
**Solution**: Update test mocks to use domain stores

## Related Skills

- `agentdb-memory-patterns` - Persistent memory
- `hive-mind-advanced` - Collective coordination
- `goap-planning` - Action planning
- `sparc-methodology` - Structured development

## References

- [Architecture Assessment](docs/architecture/ARCHITECTURE_ASSESSMENT.md)
- [Zustand Best Practices](https://docs.pmnd.rs/zustand)
- [GOAP Algorithm](https://en.wikipedia.org/wiki/Goal-oriented_action_planning)

---

**Created**: 2025-12-03
**Version**: 1.0.0
**Category**: Architecture Refactoring
**Difficulty**: Intermediate
