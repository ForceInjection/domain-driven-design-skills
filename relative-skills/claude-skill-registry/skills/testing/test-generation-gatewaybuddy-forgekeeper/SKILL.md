---
name: test-generation
description: Generate comprehensive unit and integration tests for JavaScript/TypeScript code
tags: [testing, quality, vitest, javascript]
version: 1.0.0
author: forgekeeper-team
---

# Test Generation

## Overview
Generate comprehensive test suites for JavaScript and TypeScript code using Vitest framework following Forgekeeper testing conventions.

## When to Use
Use this skill when:
- User requests tests for a new module or function
- Code review identifies missing test coverage
- Implementing a new feature that requires testing
- User asks to "write tests" or "add test coverage"

## Prerequisites
- Access to the source code file to be tested
- Understanding of the code's purpose and behavior
- Vitest test framework available

## Instructions

### Step 1: Analyze the Code
Read and understand:
- Module exports (functions, classes, constants)
- Function signatures and parameters
- Return types and possible values
- Error conditions and edge cases
- Dependencies and imports

### Step 2: Determine Test Scope
Identify:
- **Unit tests**: Individual function/method behavior
- **Integration tests**: Module interactions
- **Edge cases**: Boundary conditions, null/undefined, empty arrays
- **Error paths**: Exception handling, invalid inputs

### Step 3: Structure the Test File
Create test file following Forgekeeper conventions:

```javascript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { functionToTest } from '../module.mjs';

describe('Module Name', () => {
  describe('functionToTest', () => {
    it('handles normal case correctly', () => {
      const result = functionToTest('input');
      expect(result).toBe('expected');
    });

    it('handles edge case: empty input', () => {
      const result = functionToTest('');
      expect(result).toBe('');
    });

    it('throws error for invalid input', () => {
      expect(() => functionToTest(null)).toThrow('Invalid input');
    });
  });
});
```

### Step 4: Write Comprehensive Tests
Include:
- **Happy path**: Normal expected usage
- **Edge cases**: Empty, null, undefined, zero, negative
- **Boundaries**: Min/max values, array limits
- **Error handling**: Invalid inputs, exceptions
- **Mocking**: External dependencies (if needed)

### Step 5: Validate Test Quality
Ensure tests:
- Are isolated (don't depend on each other)
- Have clear, descriptive names
- Test one thing per test case
- Use appropriate assertions
- Clean up resources (beforeEach/afterEach)

## Expected Output
Complete test file(s) with:
- Proper imports and setup
- Organized describe blocks
- Clear test case names
- Comprehensive coverage
- Appropriate mocking (if needed)

## Error Handling

**Error**: Cannot determine what to test
- **Cause**: Code structure unclear or too complex
- **Fix**: Ask user which specific functions/behavior to test

**Error**: Missing dependencies for mocking
- **Cause**: External dependencies not identified
- **Fix**: Review imports and identify which need mocking

**Error**: Test file already exists
- **Cause**: Tests may already be written
- **Fix**: Ask if user wants to add to existing tests or rewrite

## Examples

### Example 1: Simple Function Tests
```
User request: "Write tests for the formatSkillForPrompt function"

Skill invocation:
1. Read skills/loader.mjs to understand the function
2. Identify test cases:
   - Normal skill object
   - Missing tags
   - Empty instructions
3. Generate test file:

```javascript
import { describe, it, expect } from 'vitest';
import { formatSkillForPrompt } from '../loader.mjs';

describe('Skills Loader', () => {
  describe('formatSkillForPrompt', () => {
    it('formats skill with all fields correctly', () => {
      const skill = {
        name: 'test-skill',
        description: 'A test skill',
        tags: ['test', 'demo'],
        instructions: '## Step 1\nDo something'
      };

      const result = formatSkillForPrompt(skill);

      expect(result).toContain('## Skill: test-skill');
      expect(result).toContain('**Description**: A test skill');
      expect(result).toContain('**Tags**: test, demo');
      expect(result).toContain('## Step 1');
    });

    it('handles skill with no tags', () => {
      const skill = {
        name: 'no-tags',
        description: 'Skill without tags',
        tags: [],
        instructions: 'Instructions here'
      };

      const result = formatSkillForPrompt(skill);

      expect(result).toContain('**Tags**: none');
    });

    it('handles undefined tags gracefully', () => {
      const skill = {
        name: 'undefined-tags',
        description: 'Tags undefined',
        instructions: 'Instructions'
      };

      const result = formatSkillForPrompt(skill);

      expect(result).toContain('**Tags**: none');
    });
  });
});
```
```

### Example 2: Class Method Tests with Mocking
```
User request: "Test the SkillsRegistry class"

Skill invocation:
1. Read skills/registry.mjs
2. Identify key methods: initialize, reload, get, searchByTags
3. Generate comprehensive tests with mocking:

```javascript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { SkillsRegistry } from '../registry.mjs';

// Mock the loader module
vi.mock('../loader.mjs', () => ({
  loadAllSkills: vi.fn(async () => [
    { name: 'skill1', description: 'First skill', tags: ['test'], enabled: true },
    { name: 'skill2', description: 'Second skill', tags: ['demo'], enabled: true }
  ]),
  reloadSkills: vi.fn(async () => [
    { name: 'skill1', description: 'First skill', tags: ['test'], enabled: true }
  ])
}));

describe('SkillsRegistry', () => {
  let registry;

  beforeEach(() => {
    registry = new SkillsRegistry({ enableHotReload: false });
  });

  afterEach(async () => {
    if (registry) {
      await registry.shutdown();
    }
  });

  describe('initialize', () => {
    it('loads skills on initialization', async () => {
      await registry.initialize();

      expect(registry.initialized).toBe(true);
      expect(registry.getAll()).toHaveLength(2);
    });

    it('does not initialize twice', async () => {
      await registry.initialize();
      await registry.initialize();

      expect(registry.initialized).toBe(true);
    });
  });

  describe('get', () => {
    beforeEach(async () => {
      await registry.initialize();
    });

    it('returns skill by name', () => {
      const skill = registry.get('skill1');

      expect(skill).toBeDefined();
      expect(skill.name).toBe('skill1');
    });

    it('returns null for non-existent skill', () => {
      const skill = registry.get('nonexistent');

      expect(skill).toBeNull();
    });
  });

  describe('searchByTags', () => {
    beforeEach(async () => {
      await registry.initialize();
    });

    it('finds skills matching tags', () => {
      const results = registry.searchByTags(['test']);

      expect(results).toHaveLength(1);
      expect(results[0].name).toBe('skill1');
    });

    it('returns empty array for no matches', () => {
      const results = registry.searchByTags(['nonexistent']);

      expect(results).toHaveLength(0);
    });
  });
});
```
```

## Resources
- `frontend/test/` - Existing test files for reference
- Vitest documentation: https://vitest.dev/
- Project test examples in `frontend/test/mcp/`

## Notes
- Follow existing test patterns in the Forgekeeper codebase
- Use descriptive test names that explain what is being tested
- Keep tests fast and isolated
- Mock external dependencies (file system, network, etc.)
- Aim for high coverage but prioritize meaningful tests over 100% coverage

## Version History
- **1.0.0** (2025-11-21): Initial release
