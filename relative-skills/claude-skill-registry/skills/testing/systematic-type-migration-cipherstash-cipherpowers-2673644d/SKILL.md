---
name: Systematic Type Migration
description: Safe refactoring workflow for replacing old types with new type-safe implementations through integration-test-first, file-by-file migration with incremental verification
when_to_use: when refactoring to new type-safe implementations, replacing components across codebase, migrating to new domain types
version: 1.0.0
---

# Systematic Type Migration

## Overview

When refactoring components to new type-safe implementations, use this systematic workflow to prevent "works in isolation but broken integration" bugs.

**Core principle:** Integration test FIRST → file-by-file migration → incremental verification → cleanup

## The Problem

**Recurring issue during major refactoring:**
- Old component definitions remain in the codebase
- Some files spawn entities with old types
- Other files query for new types
- Systems become disconnected (queries find zero entities)
- User functionality breaks despite all systems being "properly registered"

**Example:** After introducing type-safe `MovementState` enum, if `setup.rs` spawns entities with the old `MovementState` but `planning.rs` queries for the new `MovementState`, queries will silently fail.

## The Workflow

### Phase 1: Preparation

**Step 1: Document the change**
- Create work directory (e.g., `docs/work/YYYY-MM-DD-type-safe-X`)
- Document scope and goals

**Step 2: Identify all uses**
```bash
# Find all references to the type being replaced
grep -r "ComponentName" src/
rg "OldType" --type rust
```

**Step 3: Create integration test FIRST**
- Write test that exercises **full user flow** (not just isolated system behavior)
- Test should verify end-to-end functionality
- This test MUST pass before starting AND after completion

**Step 4: Run baseline tests**

- Run project test command
- Run project check command
- Capture baseline to compare against

### Phase 2: Implementation

**Step 1: Create new component**
- Implement in canonical location (e.g., `src/components/movement/states.rs`)
- Include all required derives

**Step 2: Do NOT delete old component yet**
- Keep both during migration
- Enables gradual migration without breaking everything
- Allows atomic commits per file

### Phase 3: Migration (Systematic, File-by-File)

For EACH file using the old component:

**Step 1: Update imports**
```rust
// Before
use old_module::OldType;

// After
use new_module::NewType;
```

**Step 2: Update type usage**
- Pattern matching if enum variants changed
- Entity spawning to use new type
- Queries to use new type

**Step 3: Test after each file**
```bash
cargo check  # Or language-specific quick check
```
- Catch type errors immediately
- Don't accumulate errors across files

**Step 4: Commit atomically**
```bash
git add path/to/file.rs
git commit -m "refactor: migrate FileX to new ComponentName"
```
- One commit per file or logical group
- Enables easy rollback if needed

**Common file locations to check:**
- Entity spawning files (e.g., `setup.rs`, `spawners.rs`)
- System logic files (business logic using the component)
- UI display files (rendering component state)
- Component definition files
- Integration test files

### Phase 4: Cleanup

**Step 1: Delete old component definition**
- Remove from original module
- Only after ALL references migrated

**Step 2: Remove obsolete imports**
```bash
# Find unused imports
cargo clippy -- -W unused_imports
```

**Step 3: Remove obsolete helper code**
- Builder functions
- Conversion utilities
- Deprecated APIs

**Step 4: Update exports**
- Remove old type from `mod.rs` public API
- Ensure new type properly exported

### Phase 5: Verification

**Step 1: Compile clean**
```bash
cargo check --all-targets
# Or language-specific equivalent
```

**Step 2: Run all tests**

Run project test command
- All unit tests must pass
- All integration tests must pass

**Step 3: Verify integration test passes**
- The test created in Phase 1 MUST pass
- This verifies end-to-end functionality

**Step 4: Run checks**

Run project check command
- Linting, formatting, type checking

**Step 5: Manual testing**
- Test actual user flows
- Verify UI updates correctly
- Check edge cases

### Phase 6: Documentation

**Step 1: Update pattern docs**
- If new pattern emerged, document it

**Step 2: Document in retrospective**
- Capture lessons learned in work directory
- Note any pitfalls encountered

**Step 3: Update project docs**
- If pattern is important, reference from CLAUDE.md or README

## Key Principles

| Principle | Rationale |
|-----------|-----------|
| **Integration test FIRST** | Prevents "works in parts, broken as whole" |
| **Keep both during migration** | Enables atomic commits per file |
| **File-by-file, not all-at-once** | Easier debugging, clear progress |
| **Incremental verification** | Catch errors immediately (5 min) vs batch (30+ min) |
| **Atomic commits** | Easy rollback if specific change breaks something |

## Prevention: Integration Tests

The best prevention is **integration tests that verify the full user flow**, not just isolated system behavior.

### What Makes a Good Integration Test

**Good integration test:**
```rust
#[test]
fn test_user_can_move_vehicle() {
    // Setup: Spawn entities with realistic component combinations
    let world = setup_test_world();
    let vehicle = spawn_vehicle_with_all_components(&mut world);

    // Act: Trigger user action (click → select → move)
    click_vehicle(&mut world, vehicle);
    issue_move_order(&mut world, target_position);

    // Assert: Verify end result, not internal state
    run_systems_until_complete(&mut world);
    assert!(vehicle_arrived_at_target(&world, vehicle));
}
```

**Bad integration test:**
```rust
#[test]
fn test_planning_system_queries() {
    // Only tests one system in isolation
    // Doesn't verify components are actually compatible
}
```

**Integration test should:**
- Spawn entities with ALL required components (like real usage)
- Exercise multiple systems together (full pipeline)
- Verify user-visible outcome, not internal state
- Use realistic component combinations

## Common Mistakes

### Mistake 1: Skipping Integration Test
**Problem:** Discover breakage during manual testing (too late)
**Solution:** Write integration test FIRST, watch it pass LAST

### Mistake 2: Big-Bang Migration
**Problem:** Migrate all files at once, giant debug session when it fails
**Solution:** File-by-file with `cargo check` after each

### Mistake 3: Deleting Old Type Too Early
**Problem:** Can't compile during migration, hard to debug
**Solution:** Keep both until migration complete

### Mistake 4: Batching Commits
**Problem:** Hard to identify which change broke tests
**Solution:** Atomic commits per file

### Mistake 5: Testing Only Units
**Problem:** Units pass, integration broken (components incompatible)
**Solution:** Integration test MUST exercise full user flow

## Example Workflow

```bash
# Phase 1: Preparation
mkdir -p docs/work/2025-10-23-type-safe-movement-state
grep -r "MovementState" src/ > docs/work/2025-10-23-type-safe-movement-state/references.txt
# Write integration test: tests/movement_integration.rs
# Run project test command to establish baseline

# Phase 2: Implementation
# Create src/components/movement/states.rs with new MovementState
# Keep old src/space/components.rs::MovementState

# Phase 3: Migration (file-by-file)
# File 1: src/space/systems/setup.rs
nvim src/space/systems/setup.rs  # Update import, spawning
cargo check  # Verify
git add src/space/systems/setup.rs
git commit -m "refactor: migrate setup.rs to new MovementState"

# File 2: src/space/systems/planning.rs
nvim src/space/systems/planning.rs  # Update import, queries
cargo check  # Verify
git add src/space/systems/planning.rs
git commit -m "refactor: migrate planning.rs to new MovementState"

# ... repeat for each file ...

# Phase 4: Cleanup
# Delete old MovementState from src/space/components.rs
git add src/space/components.rs
git commit -m "refactor: remove old MovementState definition"

# Phase 5: Verification
cargo check --all-targets
# Run project test command - integration test MUST pass
# Run project check command
# Manual testing

# Phase 6: Documentation
# Write docs/work/2025-10-23-type-safe-movement-state/summary.md
```

## Related Practices

**Before using this skill:**
- Read: `${CLAUDE_PLUGIN_ROOT}principles/development.md` - Code structure principles
- Read: `${CLAUDE_PLUGIN_ROOT}principles/testing.md` - Testing principles

**After migration:**
- Use: `${CLAUDE_PLUGIN_ROOT}skills/requesting-code-review/SKILL.md` - Request code review

## Testing This Skill

See `test-scenarios.md` for pressure tests validating this workflow prevents integration breakage.
