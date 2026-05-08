---
name: "Test Design Patterns"
description: "Apply testing patterns like AAA (Arrange-Act-Assert), mocking, fixtures, and parameterization for maintainable test suites"
category: "testing"
required_tools: ["Read", "Write", "Bash"]
---

# Test Design Patterns

## Purpose
Apply proven testing patterns to create maintainable, reliable test suites that effectively validate functionality.

## When to Use
- Writing unit, integration, or system tests
- Organizing test code
- Creating test fixtures and data
- Designing test strategies

## Key Capabilities
1. **AAA Pattern** - Arrange-Act-Assert structure
2. **Test Fixtures** - Reusable test data and setup
3. **Mocking/Stubbing** - Isolate units under test

## Approach
1. **Arrange**: Set up test data and conditions
2. **Act**: Execute the code being tested
3. **Assert**: Verify expected outcomes
4. Use descriptive test names
5. Keep tests independent and isolated

## Example
**Context**: Testing a task creation function
````python
def test_add_task_with_valid_input_creates_task():
    # Arrange
    queue = TaskQueue()
    task_data = {"title": "Test", "agent": "tester"}
    
    # Act
    task_id = queue.add_task(task_data)
    
    # Assert
    assert task_id is not None
    assert queue.get_task(task_id).title == "Test"
````

## Best Practices
- ✅ One logical assertion per test
- ✅ Descriptive test names explaining scenario
- ✅ Independent tests (no shared state)
- ❌ Avoid: Testing multiple unrelated things together