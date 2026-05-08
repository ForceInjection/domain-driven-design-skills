---
name: Lua Testing Best Practices
description: Comprehensive testing patterns for this Neovim plugin. Covers table-driven tests, async patterns, mocking, fixtures, and buffer testing. Apply when writing or reviewing tests.
---

# Lua Testing Best Practices

## When to Use
Writing or reviewing tests in `spec/`

## Essential Checklist

- [ ] Start with `dofile('spec/minimal_init.lua')`
- [ ] Use table-driven tests for multiple cases
- [ ] Import helpers: `require('spec.helpers.buffer_spec')` or `require('spec.helpers.fixture')`
- [ ] Clean up buffers in `after_each` with `helpers.delete_buffer()`
- [ ] Use modern APIs: `vim.api.nvim_set_option_value()` or `vim.bo[buf]`
- [ ] Single return value matching type annotations (avoid `gsub` direct return)
- [ ] Clear test names: `should [expected behavior]`
- [ ] One assertion focus per test
- [ ] Stub external deps only (vim.system, vim.ui.input, gh commands)
- [ ] Use `vim.wait()` for async operations with `vim.schedule`

## Quick Reference

### Test File Template
```lua
dofile('spec/minimal_init.lua')
local helpers = require('spec.helpers.buffer_spec')

describe('module_name', function()
  local module = require('github-actions.module_name')
  local test_bufnr

  before_each(function()
    test_bufnr = helpers.create_yaml_buffer('name: Test\non: push')
  end)

  after_each(function()
    helpers.delete_buffer(test_bufnr)
  end)

  describe('feature', function()
    local test_cases = {
      {name = 'normal case', input = 'x', expected = 'y'},
      {name = 'edge case', input = nil, expected = nil},
    }

    for _, tc in ipairs(test_cases) do
      it(tc.name, function()
        local result = module.feature(tc.input)
        if tc.expected == nil then
          assert.is_nil(result)
        else
          assert.equals(tc.expected, result)
        end
      end)
    end
  end)
end)
```

## Core Patterns

### 1. Table-Driven Tests
```lua
local test_cases = {
  {name = 'should parse v3', input = 'v3', expected = {3}},
  {name = 'should parse v3.5', input = 'v3.5', expected = {3, 5}},
  {name = 'should handle nil', input = nil, expected = nil},
}

for _, tc in ipairs(test_cases) do
  it(tc.name, function()
    assert.are.same(tc.expected, module.parse(tc.input))
  end)
end
```

### 2. Buffer Testing Pattern
```lua
local helpers = require('spec.helpers.buffer_spec')

before_each(function()
  test_bufnr = helpers.create_yaml_buffer([[
name: CI
on: push
jobs:
  test:
    steps:
      - uses: actions/checkout@v3
]])
end)

after_each(function()
  helpers.delete_buffer(test_bufnr)
end)
```

### 3. Fixture Loading Pattern
```lua
local fixture = require('spec.helpers.fixture')

it('should parse API response', function()
  local json_str = fixture.load('gh_api_releases_latest_success')
  local result = github.parse_response(json_str)
  assert.equals('v3.0.0', result.tag_name)
end)
```

### 4. Stub Pattern
```lua
local stub = require('luassert.stub')

-- Simple return value
stub(github, 'is_available')
github.is_available.returns(false)

-- Complex behavior
stub(vim, 'system')
vim.system.invokes(function(cmd, _, callback)
  callback({code = 0, stdout = 'output', stderr = ''})
end)

-- Verify calls
assert.stub(github.is_available).was_called()
assert.stub(github.is_available).was_called(2) -- exactly twice
```

### 5. Async Testing Pattern
```lua
local called = false
local result

module.async_function(function(value)
  called = true
  result = value
end)

vim.wait(100, function()
  return called
end)

assert.is_true(called)
assert.equals('expected', result)
```

### 6. Extmark Verification Pattern
```lua
display.set_version_text(bufnr, version_info)
local ns = display.get_namespace()
local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {details = true})

assert.equals(1, #marks, 'should have one extmark')

local details = marks[1][4]
local virt_text = details.virt_text
assert.is_true(#virt_text >= 2, 'should have icon and version')
```

## Assertion Styles

```lua
-- Equality
assert.equals(expected, actual)
assert.are.equal(expected, actual)

-- Deep equality (tables)
assert.same({1, 2}, result)
assert.are.same({key = 'val'}, result)

-- Boolean
assert.is_true(value)
assert.is_false(value)

-- Nil checks
assert.is_nil(value)
assert.is_not_nil(value)

-- Type checks
assert.is_string(value)
assert.is_number(value)

-- Pattern matching
assert.matches('pattern', string)

-- Error handling
assert.has.no.errors(function()
  module.function(invalid_input)
end)

-- With messages (recommended for complex tests)
assert.equals(1, #marks, 'should have one extmark')
assert.equals(4, mark[2], 'extmark should be on line 4')
```

## Common Patterns by Use Case

### State Reset Pattern
```lua
describe('cache', function()
  before_each(function()
    cache.clear()
  end)

  it('should store value', function()
    cache.set('key', 'value')
    assert.equals('value', cache.get('key'))
  end)
end)
```

### Multi-Call Stub Pattern
```lua
local call_count = 0
stub(git, 'execute_git_command')
git.execute_git_command.invokes(function(_)
  call_count = call_count + 1
  if call_count == 1 then
    return 'first_output', 0, ''
  else
    return 'second_output', 0, ''
  end
end)
```

### Error Callback Pattern
```lua
it('should pass error to callback when gh unavailable', function()
  stub(github, 'is_available')
  github.is_available.returns(false)

  local err_msg

  github.dispatch_workflow('ci.yml', 'main', {}, function(_, err)
    err_msg = err
  end)

  assert.is_not_nil(err_msg)
  assert.matches('gh command not found', err_msg)
end)
```

## Best Practices

### DO
✅ Use table-driven tests for comprehensive coverage
✅ Clean up resources in `after_each`
✅ Clear, descriptive test names: `should [behavior]`
✅ One concept per test
✅ Use helpers for common operations
✅ Document complex data structures in comments
✅ Stub only external dependencies
✅ Include assertion messages for clarity

### DON'T
❌ Test multiple unrelated things in one `it` block
❌ Leave buffers uncleaned
❌ Use deprecated APIs (`nvim_buf_set_option`)
❌ Hardcode fixture paths
❌ Create test interdependencies
❌ Mock the code being tested
❌ Return multiple values from type-annotated functions

## Type-Safe Returns

```lua
-- ❌ Bad - returns (string, number)
---@return string
function M.clean(text)
  return text:gsub('^["\']', ''):gsub('["\']$', '')
end

-- ✅ Good - returns string only
---@return string
function M.clean(text)
  local cleaned = text:gsub('^["\']', ''):gsub('["\']$', '')
  return cleaned
end
```

## Modern API Usage

```lua
-- ✅ Good - modern
vim.api.nvim_set_option_value('filetype', 'yaml', {buf = buf})
vim.bo[buf].filetype = 'yaml'

-- ❌ Deprecated
vim.api.nvim_buf_set_option(buf, 'filetype', 'yaml')
```

## Test Organization

```lua
describe('module', function()
  describe('feature_group_1', function()
    it('should handle case A', function() end)
    it('should handle case B', function() end)
  end)

  describe('feature_group_2', function()
    it('should handle case C', function() end)
  end)
end)
```

## Quick Examples

**Simple Pure Function:**
```lua
describe('semver.parse', function()
  local test_cases = {
    {name = 'v3', input = 'v3', expected = {3}},
    {name = 'v3.5.2', input = 'v3.5.2', expected = {3, 5, 2}},
  }
  for _, tc in ipairs(test_cases) do
    it(tc.name, function()
      assert.are.same(tc.expected, semver.parse(tc.input))
    end)
  end
end)
```

**Buffer Operations:**
```lua
it('should extract workflow name', function()
  local buf = helpers.create_yaml_buffer('name: CI\non: push')
  local name = detector.get_workflow_name(buf)
  assert.equals('CI', name)
  helpers.delete_buffer(buf)
end)
```

**With Stubs:**
```lua
it('should call gh command', function()
  local stub = require('luassert.stub')
  stub(vim, 'system')

  github.fetch_latest_release('owner', 'repo', function() end)

  assert.stub(vim.system).was_called()
end)
```

---

**Remember:** Table-driven + helpers + cleanup = maintainable tests
