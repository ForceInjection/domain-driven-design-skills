---
name: Implementing Features with TDD
description: Guides Test-Driven Development for this Neovim plugin project. Use when implementing new features or fixing bugs that require behavioral changes. Includes project-specific tooling (make test/lint/check) and Lua/Busted testing patterns. Follows strict RED-GREEN-REFACTOR cycle.
---

# Implementing Features with TDD

## When to Use

- Implementing new features
- Fixing bugs with behavioral changes
- Adding functionality affecting application logic

**Don't use for**: Pure refactoring, documentation, configuration, or exploration.

## Project Context

### Testing Stack
- **Framework**: Busted
- **Tests**: `spec/**/*_spec.lua`
- **Implementation**: `lua/github-actions/**/*.lua`

### Quality Commands (ALL REQUIRED)
```bash
make test     # 100% pass required
make lint     # 0 warnings/errors required
make check    # Formatting check
make format   # Apply stylua
```

### Navigation Tools
- `get_symbols_overview` - File structure
- `find_symbol` - Find functions/classes
- `find_referencing_symbols` - Find usage
- `search_for_pattern` - Search patterns

## TDD Workflow

### 1. Clarify Requirements (MANDATORY)

If **anything** is unclear, use `AskUserQuestion` immediately.

Example:
```javascript
AskUserQuestion({
  questions: [{
    question: "Which icon should be used?",
    header: "Icon",
    multiSelect: false,
    options: [
      {label: "Error icon", description: "🔴 GitHubActionsVersionError"},
      {label: "Warning icon", description: "⚠️ GitHubActionsVersionOutdated"}
    ]
  }]
})
```

Common clarifications: display format, error handling, edge cases, performance.

### 2. RED Phase - Write Failing Tests

Add tests to `spec/**/*_spec.lua`:

```lua
describe('module.new_feature', function()
  local test_cases = {
    {name = 'should handle normal case', input = 'value', expected = 'result'},
    {name = 'should handle edge case', input = 'edge', expected = 'edge_result'},
    {name = 'should handle nil input', input = nil, expected = 'error'},
  }

  for _, tc in ipairs(test_cases) do
    it(tc.name, function()
      assert.are.equal(tc.expected, module.new_feature(tc.input))
    end)
  end
end)
```

Verify: `make test` must show errors.

### 3. GREEN Phase - Minimal Implementation

Add minimum code to pass tests in `lua/github-actions/**/*.lua`:

```lua
---Brief description
---@param input string|nil Input parameter
---@return string result Result value
function M.new_feature(input)
  if not input then
    return 'error'
  end

  if input == 'edge' then
    return 'edge_result'
  end

  return 'result'
end
```

Verify: `make test` must pass 100%.

### 4. REFACTOR Phase - Improve Quality

After tests are green, refactor for clarity:

```lua
function M.new_feature(input)
  if not input then
    return handle_error_case()
  end
  return process_input(input)
end

local function handle_error_case()
  return 'error'
end

local function process_input(input)
  if is_edge_case(input) then
    return 'edge_result'
  end
  return 'result'
end
```

Verify: `make test` still passes.

### 5. Quality Gates (ALL REQUIRED)

```bash
make check   # ✅ Must pass
make lint    # ✅ 0 warnings/errors
make test    # ✅ 100% success
```

## Project-Specific Patterns

### Test File Structure
```lua
dofile('spec/minimal_init.lua')

describe('module_name', function()
  local module = require('github-actions.module_name')

  describe('feature_name', function()
    local test_cases = { ... }
    for _, tc in ipairs(test_cases) do
      it(tc.name, function()
        -- Test implementation
      end)
    end
  end)
end)
```

### Error Display Pattern
```lua
-- Set error in version_info
version_info.error = 'error message'
version_info.is_latest = false

-- Display shows: [🔴] error message
-- Uses: GitHubActionsVersionError highlight
```

### Version Comparison Pattern
```lua
local status = semver.get_version_status(current, latest)
-- Returns: "newer" | "latest" | "outdated" | "invalid"

if status == 'newer' then
  -- Treat as error
elseif status == 'latest' then
  -- Mark as up-to-date
else
  -- Handle outdated/invalid
end
```

## Complete Example

See [TDD Implementation Examples](../lua-neovim-testing-best-practices/tdd-examples.md) for the full "newer than latest" feature implementation showing all phases.

## Commit Format

```
✨ feat: brief description

Detailed explanation of change and why.

Changes:
- Change 1
- Change 2

Why this matters:
Value explanation.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Emoji prefixes**: ✨ feat, 🐛 fix, ♻️ refactor, ✅ test

## Quality Checklist

- [ ] Requirements clarified (AskUserQuestion if needed)
- [ ] Tests written first (RED)
- [ ] Tests pass (GREEN)
- [ ] Code refactored (REFACTOR)
- [ ] `make check/lint/test` all pass
- [ ] Related code updated
- [ ] Display/UI verified

## Key Principles

1. **No test, no code** - Tests always first
2. **Clarify first** - Never assume requirements
3. **Minimum implementation** - Only enough to pass
4. **Refactor when green** - Improve only after passing
5. **All checks pass** - Mandatory quality gates

---

**Remember**: Strict TDD required. Ask when uncertain. Never assume.
