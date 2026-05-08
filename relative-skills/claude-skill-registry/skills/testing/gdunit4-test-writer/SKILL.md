---
name: gdUnit4 Test Writer
description: Write gdUnit4 test code with type-specific assertions, signal testing, and scene runner support. Use when creating or updating tests for GDScript files.
allowed-tools:
  - mcp__context7__resolve-library-id
  - mcp__context7__query-docs
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# gdUnit4 Test Writer

Write gdUnit4 test code for GDScript files with proper assertions and test structure.

## Workflow

1. **Analyze target file** - Read the GDScript file to understand what needs testing
2. **Check gdUnit4 docs** - Use Context7 (`/websites/godot-gdunit-labs_github_io_gdunit4`) if needed
3. **Select assertions** - Use type-specific assertions (see [references/assertions.md])
4. **Create test file** - Place in `res://tests/` directory with `test_*.gd` naming (e.g., `test_player.gd`)
5. **Validate** - Use gdscript-validate skill to check for errors

## Quick Reference

### Test File Template

```gdscript
extends GdUnitTestSuite

func test_example() -> void:
    assert_int(1).is_equal(1)
```

### Common Assertions

- **int**: `assert_int(value).is_equal(10)`
- **float**: `assert_float(value).is_equal_approx(3.14, 0.01)`
- **String**: `assert_str(text).contains("hello")`
- **Array**: `assert_array(items).has_size(5)`
- **Object**: `assert_object(node).is_not_null()`
- **Signal**: `await assert_signal(emitter).is_emitted("signal_name")`

### Memory Management

```gdscript
func test_with_node() -> void:
    var node: Node = auto_free(Node.new())  # Auto-freed after test
    assert_object(node).is_not_null()
```

## References

- [references/assertions.md](assertions.md) - Complete assertion reference
- [references/test-structure.md](test-structure.md)- Test lifecycle and structure
- [references/signals.md](signals.md) - Signal testing guide
- [references/scene-runner.md](scene-runner.md) - Scene runner for integration tests

## Context7 Library ID

For detailed gdUnit4 documentation:
- Library ID: `/websites/godot-gdunit-labs_github_io_gdunit4`
