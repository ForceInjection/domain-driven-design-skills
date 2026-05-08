---
name: Test Pattern Library
description: Comprehensive library of testing patterns, best practices, and templates for unit, integration, and end-to-end tests across frameworks
---

# Test Pattern Library

## Purpose

Provide battle-tested patterns for:
- Unit testing (functions, classes, modules)
- Integration testing (APIs, databases, services)
- End-to-end testing (user workflows)
- Test organization and structure
- Mocking and stubbing strategies
- Test data management

## When to Use

Invoke this skill when:
- Writing tests for new code
- Improving test coverage
- Refactoring existing tests
- Teaching testing best practices
- Setting up testing infrastructure
- Debugging flaky tests

## Instructions

### Step 1: Identify Test Type

Determine what needs testing:
1. **Unit Test**: Single function/method/class
2. **Integration Test**: Multiple components working together
3. **E2E Test**: Complete user workflow
4. **Snapshot Test**: UI/output comparison
5. **Performance Test**: Speed/load testing

### Step 2: Choose Testing Framework

Select the appropriate framework:
- **JavaScript/TypeScript**: Jest, Vitest, Mocha, Jasmine
- **Python**: pytest, unittest
- **Go**: testing package
- **Rust**: built-in test framework
- **Java**: JUnit, TestNG

### Step 3: Apply AAA Pattern

Structure tests with:
1. **Arrange**: Set up test data and dependencies
2. **Act**: Execute the code being tested
3. **Assert**: Verify expected outcomes

### Step 4: Include Edge Cases

Test for:
- Happy path (normal operation)
- Edge cases (boundary conditions)
- Error conditions (failures, exceptions)
- Null/undefined/empty values
- Invalid inputs

## Testing Patterns

### JavaScript/TypeScript (Jest/Vitest)

#### Unit Test Pattern

```typescript
import { ${functionName} } from './${moduleName}';

describe('${functionName}', () => {
  // Happy path
  it('should ${expectedBehavior} when given valid input', () => {
    // Arrange
    const input = ${validInput};
    const expected = ${expectedOutput};

    // Act
    const result = ${functionName}(input);

    // Assert
    expect(result).toBe(expected);
  });

  // Edge cases
  it('should handle empty input', () => {
    const result = ${functionName}('');
    expect(result).toBe(${emptyResult});
  });

  it('should handle null input', () => {
    const result = ${functionName}(null);
    expect(result).toBeNull();
  });

  // Error conditions
  it('should throw error for invalid input', () => {
    expect(() => ${functionName}(${invalidInput}))
      .toThrow('${expectedErrorMessage}');
  });
});
```

#### Async Function Testing

```typescript
import { ${asyncFunction} } from './${moduleName}';

describe('${asyncFunction}', () => {
  it('should ${expectedBehavior}', async () => {
    // Arrange
    const input = ${validInput};
    const expected = ${expectedOutput};

    // Act
    const result = await ${asyncFunction}(input);

    // Assert
    expect(result).toEqual(expected);
  });

  it('should handle API errors', async () => {
    // Arrange
    const input = ${errorInput};

    // Act & Assert
    await expect(${asyncFunction}(input))
      .rejects
      .toThrow('${expectedErrorMessage}');
  });

  it('should timeout after ${duration}ms', async () => {
    jest.setTimeout(${timeout});

    await expect(${asyncFunction}(${slowInput}))
      .rejects
      .toThrow('Timeout');
  }, ${timeout});
});
```

#### Mock Function Pattern

```typescript
import { ${service} } from './${serviceName}';
import { ${dependency} } from './${dependencyName}';

// Mock the dependency
jest.mock('./${dependencyName}');

describe('${service}', () => {
  // Type-safe mock
  const mock${Dependency} = ${dependency} as jest.MockedObject<typeof ${dependency}>;

  beforeEach(() => {
    // Clear mocks before each test
    jest.clearAllMocks();
  });

  it('should call ${dependency}.${method} with correct arguments', async () => {
    // Arrange
    mock${Dependency}.${method}.mockResolvedValue(${mockReturnValue});
    const input = ${validInput};

    // Act
    await ${service}.${methodName}(input);

    // Assert
    expect(mock${Dependency}.${method}).toHaveBeenCalledWith(${expectedArgs});
    expect(mock${Dependency}.${method}).toHaveBeenCalledTimes(1);
  });

  it('should handle ${dependency} errors gracefully', async () => {
    // Arrange
    const error = new Error('${mockError}');
    mock${Dependency}.${method}.mockRejectedValue(error);

    // Act & Assert
    await expect(${service}.${methodName}(${input}))
      .rejects
      .toThrow('${expectedError}');
  });
});
```

#### React Component Testing (React Testing Library)

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ${ComponentName} } from './${ComponentName}';

describe('${ComponentName}', () => {
  const defaultProps = {
    ${prop1}: ${value1},
    ${prop2}: ${value2},
  };

  it('should render correctly', () => {
    render(<${ComponentName} {...defaultProps} />);

    expect(screen.getByText('${expectedText}')).toBeInTheDocument();
    expect(screen.getByRole('${role}')).toBeInTheDocument();
  });

  it('should call ${callback} when ${action}', async () => {
    const mock${Callback} = jest.fn();
    render(<${ComponentName} {...defaultProps} ${callback}={mock${Callback}} />);

    const button = screen.getByRole('button', { name: '${buttonText}' });
    await userEvent.click(button);

    expect(mock${Callback}).toHaveBeenCalledWith(${expectedArgs});
  });

  it('should display loading state', () => {
    render(<${ComponentName} {...defaultProps} isLoading={true} />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();
    expect(screen.queryByText('${contentText}')).not.toBeInTheDocument();
  });

  it('should display error message', () => {
    const error = '${errorMessage}';
    render(<${ComponentName} {...defaultProps} error={error} />);

    expect(screen.getByText(error)).toBeInTheDocument();
  });

  it('should match snapshot', () => {
    const { container } = render(<${ComponentName} {...defaultProps} />);
    expect(container).toMatchSnapshot();
  });
});
```

---

### Python (pytest)

#### Unit Test Pattern

```python
import pytest
from ${module_name} import ${function_name}

class Test${FunctionName}:
    """Tests for ${function_name}"""

    def test_${behavior}_with_valid_input(self):
        """Should ${expected_behavior} when given valid input"""
        # Arrange
        input_value = ${valid_input}
        expected = ${expected_output}

        # Act
        result = ${function_name}(input_value)

        # Assert
        assert result == expected

    def test_handles_empty_input(self):
        """Should handle empty input"""
        result = ${function_name}("")
        assert result == ${empty_result}

    def test_handles_none_input(self):
        """Should handle None input"""
        result = ${function_name}(None)
        assert result is None

    def test_raises_error_for_invalid_input(self):
        """Should raise ${ErrorType} for invalid input"""
        with pytest.raises(${ErrorType}, match="${error_message}"):
            ${function_name}(${invalid_input})

    @pytest.mark.parametrize("input_value,expected", [
        (${input1}, ${output1}),
        (${input2}, ${output2}),
        (${input3}, ${output3}),
    ])
    def test_multiple_cases(self, input_value, expected):
        """Should handle multiple input cases"""
        assert ${function_name}(input_value) == expected
```

#### Async Testing (pytest-asyncio)

```python
import pytest
from ${module_name} import ${async_function}

@pytest.mark.asyncio
class Test${AsyncFunction}:
    """Tests for ${async_function}"""

    async def test_${behavior}(self):
        """Should ${expected_behavior}"""
        # Arrange
        input_value = ${valid_input}
        expected = ${expected_output}

        # Act
        result = await ${async_function}(input_value)

        # Assert
        assert result == expected

    async def test_handles_api_errors(self):
        """Should handle API errors"""
        with pytest.raises(${ErrorType}):
            await ${async_function}(${error_input})

    async def test_timeout(self):
        """Should timeout after ${duration} seconds"""
        with pytest.raises(asyncio.TimeoutError):
            await asyncio.wait_for(
                ${async_function}(${slow_input}),
                timeout=${duration}
            )
```

#### Fixture Pattern

```python
import pytest
from ${module_name} import ${ClassName}

@pytest.fixture
def ${fixture_name}():
    """Fixture providing ${description}"""
    # Setup
    instance = ${ClassName}(${init_args})
    yield instance
    # Teardown
    instance.cleanup()

@pytest.fixture
def ${database_fixture}(tmp_path):
    """Fixture providing test database"""
    db_path = tmp_path / "test.db"
    db = Database(db_path)
    db.setup()
    yield db
    db.teardown()

class Test${ClassName}:
    """Tests for ${ClassName}"""

    def test_${method}_with_fixture(self, ${fixture_name}):
        """Should ${expected_behavior}"""
        result = ${fixture_name}.${method}(${args})
        assert result == ${expected}
```

#### Mock Pattern (unittest.mock)

```python
import pytest
from unittest.mock import Mock, patch, MagicMock
from ${module_name} import ${service}

class Test${Service}:
    """Tests for ${service}"""

    @patch('${module_name}.${dependency}')
    def test_calls_dependency(self, mock_dependency):
        """Should call ${dependency} with correct arguments"""
        # Arrange
        mock_dependency.${method}.return_value = ${mock_return}
        service = ${Service}()

        # Act
        result = service.${method_name}(${args})

        # Assert
        mock_dependency.${method}.assert_called_once_with(${expected_args})
        assert result == ${expected_result}

    def test_with_mock_object(self):
        """Should work with mock object"""
        # Arrange
        mock_dep = Mock()
        mock_dep.${method}.return_value = ${mock_return}
        service = ${Service}(dependency=mock_dep)

        # Act
        result = service.${method_name}(${args})

        # Assert
        mock_dep.${method}.assert_called_once()
        assert result == ${expected_result}
```

---

### Integration Test Patterns

#### API Integration Test (Express)

```typescript
import request from 'supertest';
import app from '../app';
import { setupTestDB, cleanupTestDB } from './helpers/db';

describe('${Resource} API', () => {
  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await cleanupTestDB();
  });

  describe('GET /api/${resources}', () => {
    it('should return all ${resources}', async () => {
      const response = await request(app)
        .get('/api/${resources}')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('should require authentication', async () => {
      await request(app)
        .get('/api/${resources}')
        .expect(401);
    });
  });

  describe('POST /api/${resources}', () => {
    it('should create new ${resource}', async () => {
      const new${Resource} = {
        ${field1}: ${value1},
        ${field2}: ${value2},
      };

      const response = await request(app)
        .post('/api/${resources}')
        .set('Authorization', `Bearer ${testToken}`)
        .send(new${Resource})
        .expect(201);

      expect(response.body.data).toMatchObject(new${Resource});
      expect(response.body.data.id).toBeDefined();
    });

    it('should validate input', async () => {
      const invalid${Resource} = {
        ${field1}: '', // Invalid
      };

      const response = await request(app)
        .post('/api/${resources}')
        .set('Authorization', `Bearer ${testToken}`)
        .send(invalid${Resource})
        .expect(400);

      expect(response.body.errors).toBeDefined();
    });
  });
});
```

#### Database Integration Test

```typescript
import { ${Model} } from '../models/${model}';
import { db } from '../db';

describe('${Model} Database Operations', () => {
  beforeEach(async () => {
    await db.migrate.latest();
    await db.seed.run();
  });

  afterEach(async () => {
    await db.migrate.rollback();
  });

  afterAll(async () => {
    await db.destroy();
  });

  describe('create', () => {
    it('should create ${resource} in database', async () => {
      const data = {
        ${field1}: ${value1},
        ${field2}: ${value2},
      };

      const ${resource} = await ${Model}.create(data);

      expect(${resource}.id).toBeDefined();
      expect(${resource}.${field1}).toBe(${value1});

      // Verify in database
      const found = await ${Model}.findById(${resource}.id);
      expect(found).toMatchObject(data);
    });

    it('should enforce unique constraints', async () => {
      const data = { ${uniqueField}: ${value} };

      await ${Model}.create(data);

      await expect(${Model}.create(data))
        .rejects
        .toThrow('Unique constraint violation');
    });
  });
});
```

## Best Practices

### General
1. **AAA Pattern**: Arrange, Act, Assert
2. **One Assertion**: Each test should verify one thing
3. **Descriptive Names**: Test names should describe behavior
4. **Independence**: Tests should not depend on each other
5. **Fast**: Tests should run quickly
6. **Repeatable**: Same input should give same output
7. **Isolated**: No external dependencies (use mocks)

### Test Organization
1. **Group Related**: Use describe/context blocks
2. **Setup/Teardown**: Use beforeEach/afterEach
3. **Test Data**: Use fixtures/factories
4. **Naming**: `test_<behavior>_<condition>_<expected>`

### Coverage Goals
- **Unit Tests**: 80-90% code coverage
- **Integration Tests**: Critical paths
- **E2E Tests**: Main user workflows

### Anti-Patterns to Avoid
❌ Testing implementation details
❌ Brittle tests (too specific)
❌ Slow tests (no mocks)
❌ Flaky tests (random failures)
❌ Testing third-party code
❌ Large test files (split them)

## Output Format

```
## Test Suite: ${SuiteName}

**Testing**: ${whatIsBeingTested}

**Type**: ${testType}

**Code**:
```${language}
${testCode}
```

**Coverage**:
- Happy path: ✅
- Edge cases: ✅
- Error conditions: ✅

**Notes**:
- ${note1}
- ${note2}
```

## Related Skills

- `assertion-helper`: For better assertions
- `mock-generator`: For creating mocks
- `test-data-factory`: For test data
- `coverage-analyzer`: For coverage reports
